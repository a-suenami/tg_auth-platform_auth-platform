# プロフィールフィールドルール

## 概要

プロフィールフィールドルールは、テナント単位でユーザープロフィールフィールドの挙動を制御する仕組みです。`tenant_setting.profile_field_rules` に JSONB として保存されます。

## 保存場所

- テーブル: `tenant_settings`
- カラム: `profile_field_rules` (JSONB)
- スコープ: テナント単位

## データ構造

```json
{
  "user_profiles": {
    "first_name": { "required": true, "hidden": false, "editable": false },
    "last_name": { "required": true, "hidden": false, "editable": true },
    "first_name_kana": { "required": true, "hidden": false, "editable": false },
    "last_name_kana": { "required": true, "hidden": false, "editable": true },
    "birth_date": { "required": true, "hidden": false, "editable": false },
    "gender": { "required": true, "hidden": false, "editable": false }
  },
  "contact_address": {
    "zip_code": { "required": true, "hidden": false, "editable": true },
    "prefecture_code": { "required": true, "hidden": false, "editable": true },
    "city": { "required": true, "hidden": false, "editable": true },
    "street": { "required": true, "hidden": false, "editable": true },
    "building": { "required": false, "hidden": false, "editable": true },
    "phone_number": { "required": false, "hidden": false, "editable": true },
    "country_code": { "required": false, "hidden": false, "editable": true }
  }
}
```

## フィールド属性

| 属性 | 型 | 説明 |
|------|------|------|
| `required` | boolean | ユーザーアカウントを有効化するために必須かどうか |
| `hidden` | boolean | プロフィール編集画面で非表示にするかどうか |
| `editable` | boolean | 初回入力後に編集可能かどうか |

## 影響する画面

| 画面 | 影響 |
|------|------|
| ユーザープロフィール編集 (`UserArea::ProfilesController`) | あり |
| Admin API (`API::V1::Admin::UsersController`) | なし |
| Ruler Area（テナント設定） | なし |

## 動作の仕組み

### 1. ルールのマージ

テナント固有のルールはデフォルトルールと `deep_merge` でマージされます：

```ruby
# app/forms/user_form.rb
merged_rules = if tenant&.tenant_setting&.profile_field_rules.present?
  persed_rules = safe_parse_json(tenant&.tenant_setting&.profile_field_rules)
  deep_merge(DEFAULT_PROFILE_FIELD_RULES, persed_rules)
else
  DEFAULT_PROFILE_FIELD_RULES
end
```

### 2. ユーザーアカウントの有効化

ユーザーがプロフィールを完了すると、すべての必須フィールドが入力されているかチェックされます：

```ruby
# app/forms/user_form.rb
def check_and_enable_user
  return true if user.enabled

  # 1. パスワードが設定済み
  return false if user.password_digest.blank?
  # 2. SMS認証済み（テナントで必須の場合）
  return false if user.tenant&.sms_verification_required && !user.sms_verified
  # 3. すべての必須フィールドが入力済み
  return false unless check_required_fields_filled?

  user.enabled = true
  user.save!
end
```

### 3. 編集可能フィールドのロジック

`editable: false` のフィールドでも、値が未設定の場合は編集可能です：

```ruby
# app/controllers/user_area/profiles_controller.rb
def field_editable?(table_name, field)
  rules = @profile_field_rules[table_name][field]
  return true if rules[:editable]

  # editable: false でも、値が未設定なら編集可能
  case table_name
  when :user_profiles
    current_user.user_profile&.public_send(field).blank?
  when :contact_address
    current_user.contact_address&.public_send(field).blank?
  else
    true
  end
end
```

## 属性の組み合わせ

3つの属性（`required`, `hidden`, `editable`）は独立したフラグとして実装されていますが、論理的に無効な組み合わせが存在します。

### 有効な組み合わせ

| required | hidden | editable | 説明 |
|----------|--------|----------|------|
| `true` | `false` | `true` | 表示、必須、常に編集可能 |
| `true` | `false` | `false` | 表示、必須、初回入力後はロック |
| `false` | `false` | `true` | 表示、任意、常に編集可能 |
| `false` | `false` | `false` | 表示、任意、初回入力後はロック |
| `false` | `true` | `*` | 非表示（ユーザーから収集しない） |

### 無効な組み合わせ

| required | hidden | editable | 問題点 |
|----------|--------|----------|--------|
| `true` | `true` | `*` | フォームから非表示なのにバリデーションで必須 - ユーザーは入力できないがバリデーションエラーになる |

## 既知の課題

### 無効な属性の組み合わせに対するバリデーションがない

現在の実装では、属性の組み合わせの論理的整合性を検証していません。管理者が `required: true` と `hidden: true` を同時に設定した場合、システムは以下の動作をします：

1. `hidden: true` によりプロフィール編集フォームからフィールドを非表示にする
2. `required: true` によりユーザーが送信時にバリデーションエラーになる
3. 結果としてプロフィールを完成できず、ユーザーのアカウントを有効化できなくなる

**回避策**: 管理者は `required: true` と `hidden: true` を同時に設定しないよう手動で注意する必要があります。

## 関連ファイル

- `app/forms/user_form.rb` - プロフィールフィールドルールを扱うメインフォーム
- `app/forms/user_profile_form.rb` - ユーザープロフィールフォーム
- `app/forms/contact_address_form.rb` - 連絡先住所フォーム
- `app/controllers/user_area/profiles_controller.rb` - プロフィール編集コントローラー
- `app/models/tenant_setting.rb` - テナント設定モデル
