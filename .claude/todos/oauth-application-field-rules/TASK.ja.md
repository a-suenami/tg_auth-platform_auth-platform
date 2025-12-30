# OAuth Application Field Rules UI 設計

## 概要

OAuth Application 登録時に、アプリケーションごとのフィールドルールを設定する UI 設計。

## 設計方針

1. **既存 UI からの差分を最小化** - 既存のフォームは変更しない
2. **2段階フロー** - 基本情報登録後、field rule 設定画面に遷移
3. **デフォルト required** - 離脱時も安全な状態を保証

## 現在のフロー

```
[新規作成] → [フォーム入力] → [保存] → [詳細画面]
```

## 提案フロー

```
[新規作成] → [フォーム入力] → [保存] → [Field Rules 設定] → [詳細画面]
                                              ↓
                                        (離脱しても OK:
                                         デフォルト全て required)
```

## 画面仕様

### 1. OAuth Application 新規作成画面（既存：変更なし）

`app/views/ruler_area/tenants/oauth_applications/new.html.slim`

現在のフォームをそのまま維持：
- name
- redirect_uri
- scopes
- allowed_logout_urls
- enable_client_credential_flow
- enable_push_event
- require_sms_mfa
- confidential

### 2. Field Rules 設定画面（新規）

`app/views/ruler_area/tenants/oauth_applications/field_rules.html.slim`

#### 画面構成

```slim
.uk-margin-top.uk-container
  h2 フィールドルール設定

  .uk-alert.uk-alert-primary
    | このアプリケーションを利用するユーザーに必須入力を求めるフィールドを設定します。

  .uk-margin-top.uk-card.uk-card-default.uk-card-body
    h3 #{@oauth_application.name}

    = form_with model: @oauth_application,
                url: update_field_rules_ruler_area_tenant_oauth_application_path,
                method: :patch do |f|

      table.uk-table.uk-table-divider
        thead
          tr
            th フィールド
            th テナント設定
            th 必須にする
        tbody
          - @field_rules.each do |field|
            tr
              td
                = field[:label]
                .uk-text-meta= field[:key]
              td
                - case field[:tenant_status]
                - when :required
                  span.uk-label.uk-label-warning 必須
                - when :hidden
                  span.uk-label.uk-label-danger 非表示
                - when :editable
                  span.uk-label 編集可
              td
                - if field[:tenant_status] == :required
                  = check_box_tag "field_rules[#{field[:key]}]", true, true,
                                  disabled: true, class: "uk-checkbox"
                  .uk-text-meta テナント設定で必須
                - elsif field[:tenant_status] == :hidden
                  | −
                - else
                  = check_box_tag "field_rules[#{field[:key]}]", true,
                                  field[:required], class: "uk-checkbox"

      .uk-alert.uk-alert-warning
        | ⚠️ デフォルトですべての編集可能なフィールドが「必須」に設定されています。
        | 不要なものはオフにしてください。

      .uk-margin-top
        = f.submit "設定を保存", class: "uk-button uk-button-primary"
        = link_to "スキップ（全て必須のまま）",
                  ruler_area_tenant_oauth_application_path(@oauth_application.tenant_id, @oauth_application),
                  class: "uk-button uk-button-default uk-margin-left"
```

#### 表示フィールド一覧

| Key | Label | Table |
|-----|-------|-------|
| `first_name` | 名 | user_profiles |
| `last_name` | 姓 | user_profiles |
| `first_name_kana` | 名（カナ） | user_profiles |
| `last_name_kana` | 姓（カナ） | user_profiles |
| `birth_date` | 生年月日 | user_profiles |
| `gender` | 性別 | user_profiles |
| `phone_number` | 電話番号 | user_contact_addresses |
| `postal_code` | 郵便番号 | user_contact_addresses |
| `prefecture` | 都道府県 | user_contact_addresses |
| `city` | 市区町村 | user_contact_addresses |
| `address1` | 住所1 | user_contact_addresses |
| `address2` | 住所2 | user_contact_addresses |

### 3. 詳細画面の拡張

`app/views/ruler_area/tenants/oauth_applications/show.html.slim`

Field Rules セクションを追加：

```slim
/ 既存のテーブルの後に追加
h3.uk-margin-top フィールドルール

- if @oauth_application.user_facing?
  table.uk-table.uk-table-divider
    thead
      tr
        th フィールド
        th 必須
    tbody
      - @oauth_application.field_rules_summary.each do |field|
        tr
          td= field[:label]
          td
            - if field[:required]
              span.uk-label.uk-label-success ✓
            - else
              | −

  = link_to "フィールドルールを編集",
            field_rules_ruler_area_tenant_oauth_application_path(@oauth_application.tenant_id, @oauth_application),
            class: "uk-button uk-button-default uk-button-small"
- else
  p.uk-text-muted M2M専用アプリケーションのため、フィールドルールは設定できません。
```

## コントローラの変更

### `oauth_applications_controller.rb`

```ruby
def create
  @oauth_application = OauthApplication.create(oauth_application_params)
  if @oauth_application.persisted?
    # Field rules をデフォルト (全て required) で作成
    create_default_field_rules(@oauth_application)

    if @oauth_application.user_facing?
      # User-facing app の場合は field rules 設定画面へ
      redirect_to field_rules_ruler_area_tenant_oauth_application_path(
        @oauth_application.tenant_id,
        @oauth_application
      ), notice: t('helpers.messages.created_configure_field_rules')
    else
      # M2M app の場合は詳細画面へ
      redirect_to ruler_area_tenant_oauth_application_path(
        @oauth_application.tenant_id,
        @oauth_application
      ), notice: t('helpers.messages.created')
    end
  else
    render :new, status: :unprocessable_entity
  end
end

def field_rules
  @oauth_application = OauthApplication.find(params[:id])
  @field_rules = build_field_rules_for_form(@oauth_application)
end

def update_field_rules
  @oauth_application = OauthApplication.find(params[:id])

  if @oauth_application.update_field_rules(field_rules_params)
    redirect_to ruler_area_tenant_oauth_application_path(
      @oauth_application.tenant_id,
      @oauth_application
    ), notice: t('helpers.messages.field_rules_updated')
  else
    @field_rules = build_field_rules_for_form(@oauth_application)
    render :field_rules, status: :unprocessable_entity
  end
end

private

def create_default_field_rules(oauth_application)
  # テナント設定を取得
  tenant_setting = TenantSetting.find_by(tenant_id: oauth_application.tenant_id)
  tenant_rules = JSON.parse(tenant_setting&.profile_field_rules || '{}')

  # 編集可能なフィールドをすべて required で作成
  CONFIGURABLE_FIELDS.each do |table, fields|
    fields.each do |field|
      tenant_rule = tenant_rules.dig(table.to_s, field.to_s) || {}

      # テナントで hidden でなければ required で作成
      unless tenant_rule['hidden']
        OauthApplicationFieldRule.create!(
          tenant_id: oauth_application.tenant_id,
          oauth_application_id: oauth_application.id,
          table_name: table.to_s,
          field_name: field.to_s,
          required: true
        )
      end
    end
  end
end
```

## ルーティング

```ruby
resources :oauth_applications do
  member do
    get :field_rules
    patch :update_field_rules
  end
end
```

## データベース

別途作成予定: `.claude/todos/oauth-application-field-rules/TASK.md`

```ruby
create_table :oauth_application_field_rules do |t|
  t.citext :tenant_id, null: false
  t.uuid   :oauth_application_id, null: false
  t.string :table_name, null: false   # 'user_profiles', 'user_contact_addresses'
  t.string :field_name, null: false   # 'first_name', 'phone_number', etc.
  t.boolean :required, default: false
  t.timestamps
end

add_index :oauth_application_field_rules,
          [:tenant_id, :oauth_application_id, :table_name, :field_name],
          unique: true,
          name: 'idx_oauth_app_field_rules_unique'
```

## 編集フロー

既存アプリケーションの編集時：

1. 詳細画面から「フィールドルールを編集」をクリック
2. field_rules 画面で編集
3. 保存 → 詳細画面に戻る

## M2M アプリの処理

`user_facing?` が `false` の場合（将来 grant_types テーブル実装後）：

- 新規作成時: field rules 設定画面をスキップ
- 詳細画面: "M2M専用アプリケーションのため設定できません" と表示
- field_rules は作成しない

現時点（grant_types テーブル未実装）では、`user_facing?` は常に `true` を返す。

## 関連ドキュメント

- `docs/spec/profile_field_rules.md` - テナントレベルのフィールドルール仕様
- `.claude/todos/grant-types-per-application/TASK.md` - Grant Types 実装タスク
