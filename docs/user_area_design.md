# User Area 設計ドキュメント

## 背景

現状、一般ユーザー向けのログイン・サインアップは API 経由（外部 SPA）でのみ可能。
Rails で直接 HTML 画面を描画してログイン・サインアップを実現したい。

## 現状の構造

```
oauth_area/     - OAuth 認可フロー、ログアウト、アカウントロック解除
api/v1/         - 認証 API（ログイン、サインアップ、MFA など）
```

- `tenants.domain` に設定されたドメインで API も oauth_area も動作
- `request.host` でテナントを特定
- セッション管理は `ExpirableCookie`（Cookie ベース）

## 決定事項

### 1. namespace のリネーム

`oauth_area` → `user_area` にリネームする。

理由：
- `ruler_area`, `admin_area` がシステムアクターに基づいているため、一貫性を持たせる
- OAuth だけでなくログイン画面も含むため、`oauth_area` は実態に合わない

### 2. API は分離しない

`api/v1/authentication` はそのまま残す。`user_area` には統合しない。

理由：
- 別ドメインにすると Cookie 共有が面倒（SameSite、サードパーティ Cookie 制限）
- Auth0 も 1 テナント = 1 ドメインで API と Web を同じドメインで提供している

### 3. ドメイン設計

1 テナント = 1 ドメイン（Auth0 方式）

```
auth.tenant-a.com
  ├── /login              (Web - ログイン画面)
  ├── /sign_up            (Web - サインアップ画面)
  ├── /oauth/authorize    (Web - OAuth 認可)
  ├── /api/v1/...         (API)
  └── /sessions/logout    (Web - ログアウト)
```

`tenant_web_supports` / `tenant_api_supports` テーブルは不要。
現状の `tenants.domain` をそのまま使用。

### 4. セッション管理

現状の Cookie ベース（`ExpirableCookie`）を継続。

JWT への移行は将来的な検討事項として残す。
- OAuth 認可フロー（`/oauth/authorize`）はブラウザリダイレクトで動くため、Authorization ヘッダーが使えない
- JWT を使う場合は「JWT in Cookie」方式が現実的

## 実装内容

### 新規作成するファイル

| ファイル | 概要 |
|----------|------|
| `app/controllers/user_area/logins_controller.rb` | ログイン画面・処理 |
| `app/controllers/user_area/sign_ups_controller.rb` | サインアップ画面・処理（複数ステップ） |
| `app/controllers/user_area/mfa_controller.rb` | SMS MFA 画面・処理（ログイン後用） |
| `app/controllers/user_area/profiles_controller.rb` | プロフィール登録・編集画面 |
| `app/views/user_area/logins/new.html.slim` | ログインフォーム |
| `app/views/user_area/sign_ups/*.html.slim` | サインアップの各ステップ画面 |
| `app/views/user_area/mfa/new.html.slim` | SMS MFA 認証コード入力 |
| `app/views/user_area/profiles/edit.html.slim` | プロフィール登録・編集フォーム |

### リネーム・移行するファイル

| 変更前 | 変更後 |
|--------|--------|
| `app/controllers/oauth_area/` | `app/controllers/user_area/` |
| `app/views/oauth_area/` | `app/views/user_area/` |
| `config/routes/oauth_area_routes.rb` | `config/routes/user_area_routes.rb` |

### 変更するファイル

| ファイル | 変更内容 |
|----------|----------|
| `config/initializers/doorkeeper.rb` | `OauthArea::` → `UserArea::` |
| `db/schemas/login_spa_applications.schema` | `enable_web_login`, `enable_api_login` 等追加 |

## DB 変更

### login_spa_applications テーブル

```ruby
# 追加カラム
t.boolean :enable_web_login, null: false, default: false
t.boolean :enable_api_login, null: false, default: true
t.boolean :enable_web_sign_up, null: false, default: false
t.boolean :enable_api_sign_up, null: false, default: true
```

- `enable_web_*`: Rails 版（サーバーサイドレンダリング）を有効にする
- `enable_api_*`: API 版（SPA）を有効にする（既存動作、デフォルト true）
- 両方 true で併用可能

## サインアップフロー

```
Step 1: メールアドレス入力 → SendVerificationEmailService → 6桁コード送信
Step 2: メール検証コード入力 → VerifyEmailService → email_verified=true
Step 3: パスワード設定
Step 4: 電話番号入力（SMS 検証が必要な場合）→ SendVerificationSmsService
Step 5: SMS 検証コード入力 → VerifySmsService → sms_verified=true
```

## ルーティング

```ruby
# config/routes/user_area_routes.rb
scope module: :user_area do
  # ログイン
  get 'login', to: 'logins#new'
  post 'login', to: 'logins#create'

  # サインアップ（複数ステップ）
  get 'sign_up', to: 'sign_ups#new'
  post 'sign_up', to: 'sign_ups#create'
  get 'sign_up/verify_email', to: 'sign_ups#verify_email'
  post 'sign_up/verify_email', to: 'sign_ups#verify_email_submit'
  # ... 以下省略

  # SMS MFA（ログイン時）
  get 'mfa/sms', to: 'mfa#new'
  post 'mfa/sms', to: 'mfa#create'
  post 'mfa/sms/resend', to: 'mfa#resend'

  # ログアウト
  get 'logout', to: 'sessions#logout'

  # マイページ
  get 'my', to: 'mypage#show'
  get 'my/profile', to: 'profiles#edit'
  patch 'my/profile', to: 'profiles#update'
  get 'my/memberships', to: 'memberships#my_memberships'

  # メンバーシッププラン
  get 'memberships', to: 'memberships#index'
  get 'memberships/:id', to: 'memberships#show'
  post 'memberships/:id/purchase', to: 'memberships#purchase'

  # 既存（oauth_area から移行）
  resources :authorizations, only: [] do
    collection do
      get :relaunch
    end
  end
  # ...
end
```

## 実装状況

### 完了

- [x] `oauth_area` → `user_area` リネーム（コントローラー、ビュー、ルーティング、フロントエンド）
- [x] `doorkeeper.rb` の `OauthArea::` → `UserArea::` 変更
- [x] `LoginsController` 作成（ログイン画面・処理）
- [x] `SignUpsController` 作成（複数ステップのサインアップフロー）
- [x] `MfaController` 作成（SMS二要素認証）
- [x] `ProfilesController` 作成（プロフィール登録・編集、`profile_field_rules` による項目出し分け対応）
- [x] `MypageController` 作成（マイページ）
- [x] `MembershipsController` 作成（プラン一覧・詳細・購入・契約一覧）
- [x] ビューファイル作成（logins, sign_ups, mfa, profiles, mypage, memberships）
- [x] ルーティング追加（`config/routes/user_area_routes.rb`）
- [x] `login_spa_applications` テーブルに `enable_web_login`, `enable_web_sign_up` カラム追加
- [x] ルーティング変更（`/logout`, `/my`, `/my/profile`, `/my/memberships`）

### 未完了

- [ ] テストの作成
- [ ] フロントエンドの詳細なスタイリング
- [ ] クレジットカード登録画面（決済連携）

## 参考

- [Auth0 Custom Domains](https://auth0.com/docs/customize/custom-domains) - 1テナント1ドメインの参考
