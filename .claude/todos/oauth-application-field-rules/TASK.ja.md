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

| Key | Label |
|-----|-------|
| `first_name` | 名 |
| `last_name` | 姓 |
| `first_name_kana` | 名（カナ） |
| `last_name_kana` | 姓（カナ） |
| `birth_date` | 生年月日 |
| `gender` | 性別 |
| `phone_number` | 電話番号 |
| `postal_code` | 郵便番号 |
| `prefecture` | 都道府県 |
| `city` | 市区町村 |
| `address1` | 住所1 |
| `address2` | 住所2 |

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

  # 全フィールドについてルールを作成
  CONFIGURABLE_FIELDS.each do |field|
    tenant_rule = tenant_rules.dig(field.to_s) || {}

    # テナントで hidden のフィールドは hidden、それ以外は required
    rule = tenant_rule['hidden'] ? 'hidden' : 'required'

    OauthApplicationFieldRule.create!(
      tenant_id: oauth_application.tenant_id,
      oauth_application_id: oauth_application.id,
      field_name: field.to_s,
      rule: rule
    )
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

スキーマファイル: `db/schemas/oauth_application_field_rules.schema`

```ruby
create_table :oauth_application_field_rules, force: :cascade, id: :uuid, default: -> { 'gen_random_uuid()' } do |t|
  t.references :tenant, type: :citext, null: false
  t.references :oauth_application, type: :uuid, null: false
  t.string :field_name, null: false   # 'first_name', 'phone_number', etc.
  t.string :rule, null: false         # 'required', 'editable', 'hidden'

  t.timestamps null: false

  t.index [:oauth_application_id, :field_name],
          name: :idx_oauth_app_field_rules_unique,
          unique: true
end

add_foreign_key :oauth_application_field_rules, :oauth_applications,
                column: [:tenant_id, :oauth_application_id],
                primary_key: [:tenant_id, :id],
                name: :fk_oauth_application_field_rules_oauth_applications
```

### Rule の値

| 値 | 説明 |
|-------|-------------|
| `required` | ユーザーは認可完了のためにこのフィールドを入力する必要がある |
| `editable` | ユーザーは任意でこのフィールドを入力できる |
| `hidden` | このアプリケーションではフィールドをユーザーに表示しない |

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

---

# ユーザー側: 認可フローでのフィールド収集

## 概要

OAuth 認可フロー中に、アプリケーションが要求するフィールドが未入力の場合、入力フォームを表示してユーザーに入力を求める。

## 認可フロー

```
[SP] → [認可リクエスト] → [ログイン/会員登録]
                              ↓
                    [必須フィールドチェック]
                              ↓
              ┌───────────────┴───────────────┐
              ↓                               ↓
        [未入力あり]                    [すべて入力済み]
              ↓                               ↓
        [入力フォーム表示]                    │
              ↓                               │
        [フォーム送信]                        │
              ↓                               ↓
              └───────────────┬───────────────┘
                              ↓
                    [認可完了・コールバック]
```

## 実装オプション

### Option A: 未入力フィールドがある場合のみフォーム表示（推奨）

```ruby
# app/controllers/oauth/authorizations_controller.rb
class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
  before_action :ensure_required_fields_filled, only: [:create]

  private

  def ensure_required_fields_filled
    return unless user_signed_in?

    missing_fields = calculate_missing_fields(current_user, oauth_application)

    if missing_fields.any?
      # 認可パラメータをセッションに保存
      session[:pending_authorization] = authorization_params

      redirect_to oauth_profile_completion_path(
        oauth_application_id: oauth_application.id,
        missing_fields: missing_fields.map(&:field_name)
      )
    end
  end

  def calculate_missing_fields(user, application)
    application.field_rules.where(rule: 'required').select do |field_rule|
      value = get_field_value(user, field_rule.field_name)
      value.blank?
    end
  end
end
```

**メリット:**
- リピートユーザーにとって UX が良い（入力済みなら追加ステップなし）
- プロフィール完備ユーザーは高速なフロー

**デメリット:**
- フィールド完了チェックの条件分岐が必要

### Option B: 常にフォーム表示（プリセット済み）

```ruby
# 常にプロフィール入力画面にリダイレクト、既存値はプリセット
def ensure_required_fields_filled
  return unless user_signed_in?

  session[:pending_authorization] = authorization_params

  redirect_to oauth_profile_completion_path(
    oauth_application_id: oauth_application.id
  )
end
```

**メリット:**
- 実装がシンプル（条件分岐なし）
- ユーザーが常に情報を確認できる

**デメリット:**
- 毎回追加ステップが発生（UX 悪化）
- ユーザーが「なぜ毎回確認が必要？」と感じる可能性

### 推奨: Option A（コントローラ共通化）

Option A を採用しつつ、フォーム表示/スキップの判定ロジックをコントローラで共通化する。

## プロフィール入力画面

`app/views/oauth/profile_completions/show.html.slim`

```slim
.uk-margin-top.uk-container
  h2 追加情報の入力

  .uk-alert.uk-alert-primary
    | 「#{@oauth_application.name}」をご利用いただくには、以下の情報が必要です。

  .uk-margin-top.uk-card.uk-card-default.uk-card-body
    = form_with model: @profile_form,
                url: oauth_profile_completion_path,
                method: :patch do |f|

      - @required_fields.each do |field|
        .uk-margin
          = f.label field.field_name
          - if field.already_filled?
            = f.text_field field.field_name, class: "uk-input",
                           value: field.current_value, readonly: true
            .uk-text-meta.uk-text-success ✓ 入力済み
          - else
            = f.text_field field.field_name, class: "uk-input"
            - if field.required?
              span.uk-text-danger *

      .uk-margin-top
        = f.submit "確認して続行", class: "uk-button uk-button-primary"
```

## コントローラ: ProfileCompletionsController

```ruby
# app/controllers/oauth/profile_completions_controller.rb
module Oauth
  class ProfileCompletionsController < ApplicationController
    before_action :authenticate_user!
    before_action :load_oauth_application
    before_action :ensure_pending_authorization

    def show
      @required_fields = build_required_fields
      @profile_form = ProfileCompletionForm.new(current_user, @required_fields)
    end

    def update
      @profile_form = ProfileCompletionForm.new(current_user, @required_fields)

      if @profile_form.update(profile_params)
        # 認可フローを再開
        redirect_to oauth_authorization_path(session[:pending_authorization])
      else
        @required_fields = build_required_fields
        render :show, status: :unprocessable_entity
      end
    end

    private

    def load_oauth_application
      @oauth_application = OauthApplication.find(params[:oauth_application_id])
    end

    def ensure_pending_authorization
      unless session[:pending_authorization]
        redirect_to root_path, alert: "認可リクエストが見つかりません"
      end
    end

    def build_required_fields
      @oauth_application.field_rules.where(rule: 'required').map do |field_rule|
        FieldPresenter.new(
          field_rule: field_rule,
          current_value: get_current_value(current_user, field_rule)
        )
      end
    end
  end
end
```

## ルーティング

```ruby
namespace :oauth do
  resource :profile_completion, only: [:show, :update]
end
```

## Doorkeeper 統合

Doorkeeper の認可フローにフックするには、`Doorkeeper::AuthorizationsController` を継承してカスタマイズする。

```ruby
# config/initializers/doorkeeper.rb
Doorkeeper.configure do
  # ...

  # カスタム認可コントローラを使用
  controllers authorizations: 'oauth/authorizations'
end
```

## セッション管理

認可パラメータをセッションに保存し、プロフィール入力完了後に復元する。

```ruby
# 保存
session[:pending_authorization] = {
  client_id: params[:client_id],
  redirect_uri: params[:redirect_uri],
  response_type: params[:response_type],
  scope: params[:scope],
  state: params[:state],
  code_challenge: params[:code_challenge],
  code_challenge_method: params[:code_challenge_method]
}

# 再開
redirect_to oauth_authorization_path(session.delete(:pending_authorization))
```

## バリデーション

フィールドルールに基づいてバリデーションを動的に適用する。

```ruby
class ProfileCompletionForm
  include ActiveModel::Model

  def initialize(user, required_fields)
    @user = user
    @required_fields = required_fields

    # 動的にバリデーションを追加
    required_fields.each do |field|
      if field.required? && !field.already_filled?
        validates field.field_name, presence: true
      end
    end
  end
end
```

## エッジケース

### 1. ユーザーがプロフィール入力をキャンセル

「キャンセル」ボタンで SP に戻れるようにする（認可拒否として処理）。

```slim
= link_to "キャンセル",
          oauth_authorization_path(session[:pending_authorization].merge(error: 'access_denied')),
          class: "uk-button uk-button-default"
```

### 2. 入力済みフィールドが後から hidden になった場合

テナント設定で後から hidden にされたフィールドは、既存の値を保持しつつ、新規入力は求めない。

### 3. 複数アプリケーションで要求フィールドが異なる場合

各アプリケーションの field_rules が異なる場合、認可時にそのアプリケーションのルールのみをチェックする。

## 関連ドキュメント

- `docs/spec/profile_field_rules.md` - テナントレベルのフィールドルール仕様
- `.claude/todos/grant-types-per-application/TASK.md` - Grant Types 実装タスク
