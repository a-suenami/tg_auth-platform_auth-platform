# OAuth アプリケーションタイプ

## 概要

このドキュメントでは、auth-platform における OAuth アプリケーションの現在の実装を説明し、業界標準（Auth0、Okta 等）と比較し、今後の改善点を特定します。

## 業界標準: Auth0 のアプリケーションタイプ

Auth0 ではアプリケーション作成時にタイプの選択が必要です：

| タイプ | 説明 | クライアント種別 | デフォルト Grant Types |
|--------|------|------------------|----------------------|
| Native | モバイル/デスクトップアプリ（iOS, Android） | Public | authorization_code, refresh_token, device_code |
| SPA | ブラウザベースのJSアプリ（React, Vue） | Public | authorization_code, refresh_token, implicit |
| Regular Web | サーバーサイドアプリ（Rails, Express） | Confidential | authorization_code, refresh_token, implicit |
| Machine to Machine | バックエンドサービス、デーモン、CLI | Confidential | client_credentials |

### Confidential vs Public クライアント

| クライアント種別 | `token_endpoint_auth_method` | Client Secret |
|------------------|------------------------------|---------------|
| Public | `none` | 安全に保管できない（ソースコードが見える） |
| Confidential | `client_secret_post`, `client_secret_basic`, `private_key_jwt` | サーバー側で安全に保管 |

**重要な制約**: `client_credentials` grant は Confidential クライアントのみ使用可能。

## 現在の auth-platform 実装

### oauth_applications テーブルスキーマ

```ruby
t.string  "name", null: false
t.string  "uid", null: false                    # client_id
t.string  "secret", null: false                 # client_secret
t.text    "redirect_uri", null: false
t.string  "scopes", default: "", null: false
t.boolean "confidential", default: true         # Doorkeeper 標準
t.boolean "enable_client_credential_flow"       # 独自拡張
t.boolean "enable_push_event"                   # 独自拡張
t.boolean "require_sms_mfa"                     # 独自拡張
t.text    "allowed_logout_urls"                 # 独自拡張
```

### Doorkeeper 必須カラム

Doorkeeper が必要とするのは以下のカラムのみ：
- `name`, `uid`, `secret`, `redirect_uri`, `scopes`, `confidential`, `timestamps`

追加カラムは Doorkeeper の機能に影響なく自由に追加可能。

### 現在の Grant Flow 制御

```ruby
# config/initializers/doorkeeper.rb
allow_grant_flow_for_client do |grant_flow, client|
  if grant_flow == 'client_credentials'
    client.enable_client_credential_flow  # カスタムフラグで M2M アクセスを制御
  else
    true  # 他のフローは常に許可
  end
end
```

## 比較: auth-platform vs Auth0

| 項目 | Auth0 | auth-platform | 差異 |
|------|-------|---------------|------|
| アプリタイプ | `app_type`（4種類） | **なし** | ❌ 区別できない |
| クライアント種別 | `token_endpoint_auth_method` | `confidential`（boolean） | △ 簡易版 |
| M2M 許可 | タイプで自動決定 | `enable_client_credential_flow` | △ 手動フラグ |
| Grant types | タイプごとにデフォルト設定 | **暗黙的に全許可** | ❌ 制御不足 |

## `confidential` カラム

### `confidential` 値による Doorkeeper の挙動

| confidential | Token Endpoint 認証 | 認可スキップ | トークン失効 |
|:------------:|---------------------|-------------|-------------|
| `true` | `client_secret` **必須** | 既存トークンでスキップ可 | `client_secret` 必須 |
| `false` | `client_secret` **不要** | 常に確認画面を表示すべき | `client_secret` 不要 |

### 重要な注意点

- Secret は `confidential` の値に関係なく**常に生成される**
- Public クライアント（`confidential: false`）では、secret は存在するが検証されない
- Public クライアントは Authorization Code フローで PKCE を使用すべき

## 既知の課題

### 危険な組み合わせのバリデーションがない

現在の実装では以下を防いでいない：

```ruby
OauthApplication.create!(
  confidential: false,                    # Public Client
  enable_client_credential_flow: true     # なのに Client Credentials を許可
)
```

これは**セキュリティリスク** - Public クライアントは認証情報を安全に保管できないため、Client Credentials grant は禁止すべき。

### アプリケーションタイプの区別がない

`app_type` がないため、以下ができない：
- SPA と Native アプリを区別する
- タイプ固有のデフォルトを自動適用する
- M2M アプリがユーザー向け設定（`required_user_fields` など）を持つことを防ぐ

## 今後の検討事項

### 選択肢 A: `app_type` カラムを追加

```ruby
t.string :app_type  # 'native', 'spa', 'regular_web', 'machine_to_machine'

# タイプに基づいてデフォルトを自動設定
# 組み合わせをバリデーション（例: M2M は confidential 必須）
```

### 選択肢 B: `confidential` + `grant_types` のみ使用

```ruby
t.boolean :confidential
t.string  :grant_types, array: true  # ['authorization_code', 'client_credentials', ...]

# app_type はこれらの設定のショートカットに過ぎない
```

### 追加すべきバリデーション

```ruby
validates :enable_client_credential_flow, inclusion: { in: [false] },
          unless: :confidential?,
          message: "Public クライアントでは Client Credentials を有効にできません"
```

## 他の IdP のアプローチ

| IdP | アプローチ |
|-----|----------|
| **Auth0** | 単一テーブル + `app_type` |
| **Okta** | 「API Services」を別タイプとして用意 |
| **Azure AD** | 同じ App Registration UI、設定で区別 |
| **Google Cloud** | **別エンティティ**: OAuth Client ID vs Service Account |

## 関連ファイル

- `app/models/oauth_application.rb` - OAuth アプリケーションモデル
- `config/initializers/doorkeeper.rb` - Doorkeeper 設定
- `app/views/ruler_area/tenants/oauth_applications/_form.html.slim` - 管理画面フォーム
- `db/schema.rb` - データベーススキーマ

## 参考資料

- [RFC 6749 - OAuth 2.0 Authorization Framework](https://datatracker.ietf.org/doc/html/rfc6749)
- [Auth0 Application Types](https://auth0.com/docs/get-started/applications)
- [Doorkeeper Custom Models](https://doorkeeper.gitbook.io/guides/configuration/models)
