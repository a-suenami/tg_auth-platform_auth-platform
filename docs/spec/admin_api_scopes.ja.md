# Admin API スコープ

## 概要

このドキュメントでは、auth-platform における Admin API 用 OAuth スコープの現在の実装を説明し、今後の改善点を特定します。

## OAuth スコープの標準仕様

### 標準で定義されているもの

| 仕様 | 定義されているスコープ |
|------|----------------------|
| **OAuth 2.0 (RFC 6749)** | なし - 意図的に実装依存 |
| **OIDC** | `openid`, `profile`, `email`, `phone`, `address`, `offline_access` |
| **SCIM** | API スキーマのみ、スコープは未定義 |

> "scope" の値は実装依存であり、中央集権的なレジストリは存在しない。許可される値は認可サーバーによって定義される。
> — RFC 6749

**管理/Admin API スコープの標準仕様は存在しません。** 各 IdP が独自に定義しています。

### 他の IdP の対応

| IdP | Admin スコープ |
|-----|---------------|
| **Okta** | `okta.users.read`, `okta.users.manage`, `okta.apps.read` など（細粒度） |
| **Auth0** | `read:users`, `update:users`, `delete:users` など（アクションベース） |
| **Slack** | `admin`, `scim:enterprise` |
| **GitHub** | `admin:org`, `scim:enterprise` |

## 現在の auth-platform 実装

### 定義されているスコープ

```ruby
# config/initializers/doorkeeper.rb
default_scopes  :public
optional_scopes :uid, :email, :name, :profile, :phone_number, :contact,
                :delivery_address, :openid, :sms_mfa, :admin_users
```

### スコープのカテゴリ

| スコープ | 種別 | 用途 |
|----------|------|------|
| `openid` | OIDC 標準 | OIDC を有効化 |
| `email` | OIDC 標準 | メールアドレス取得 |
| `profile` | カスタム（OIDC 類似） | 生年月日、性別、都道府県 |
| `phone_number` | カスタム（OIDC `phone` 類似） | 電話番号 |
| `uid` | カスタム | ユーザーID |
| `name` | カスタム | 氏名 |
| `contact` | カスタム | 完全な住所 |
| `delivery_address` | カスタム | 配送先住所 |
| `sms_mfa` | カスタム | SMS MFA 要求 |
| `admin_users` | カスタム | **Admin API アクセス** |

### Admin API でのスコープ使用方法

```ruby
# app/controllers/api/v1/admin/users_controller.rb
before_action -> { doorkeeper_authorize! :admin_users }
```

```ruby
# app/views/api/v1/admin/users/_user.json.jb
json[:email] = user.email if @doorkeeper_token.acceptable?(:email)
json[:phone_number] = user.phone_number if @doorkeeper_token.acceptable?(:phone_number)
# ... ユーザー向け API と同じスコープでフィールドレベル制御
```

### 現在の構造

```
admin_users  →  Admin API エンドポイントへのアクセス権を付与
     +
uid, email, profile, ...  →  どのフィールドを返すかを制御
```

## 既知の課題

### 同じスコープがユーザー向け API と Admin API の両方を制御

| スコープ | Private Userinfo API | Admin Users API |
|----------|---------------------|-----------------|
| `email` | 自分のメール | **全ユーザー**のメール |
| `profile` | 自分のプロフィール | **全ユーザー**のプロフィール |

**問題**: `admin_users` + `email` を持つ SP は、現在のユーザーのメールだけにアクセスするつもりでも、全ユーザーのメールにアクセスできてしまう。

### Admin スコープの標準がない

OIDC 標準スコープと異なり、管理/Admin API スコープには業界標準が存在しない。

## 今後の検討課題: スコープの分離

### 提案する構造

ユーザー向けスコープと Admin スコープを分離：

```ruby
# ユーザー向け（自分のデータにアクセス）
:uid, :email, :profile, :phone, :address

# Admin API（全ユーザーのデータにアクセス）
:'admin:uid', :'admin:email', :'admin:profile', :'admin:phone', :'admin:address'

# または別の形式
:'admin_users:uid', :'admin_users:email', :'admin_users:profile', ...
```

### メリット

1. **明示的な分離**: 自分のデータと全ユーザーのデータを明確に区別
2. **最小権限**: SP は各 API に必要なものだけを要求可能
3. **同意の明確化**: ユーザーは何を認可しているか理解しやすい

### 使用例

```ruby
# ログイン用にユーザー自身のメールのみ必要な SP
scopes: 'openid email'

# 全ユーザーのメールを自社システムに同期する必要がある SP
scopes: 'admin:email'

# 両方必要な SP
scopes: 'openid email admin:email admin:profile'
```

### 実装上の考慮事項

- 既存アプリケーションのマイグレーションが必要
- Admin API を更新して新しいスコープ名をチェック
- 後方互換性期間を検討

## OIDC スコープとの比較

| OIDC スコープ | 現在の auth-platform | 提案する Admin 版 |
|--------------|---------------------|------------------|
| `openid` | `uid`（カスタム） | `admin:uid` |
| `email` | `email` | `admin:email` |
| `profile` | `name` + `profile` | `admin:name` + `admin:profile` |
| `phone` | `phone_number` | `admin:phone` |
| `address` | `contact` | `admin:contact` |

## 関連ファイル

- `config/initializers/doorkeeper.rb` - スコープ定義
- `app/controllers/api/v1/admin/users_controller.rb` - Admin API コントローラー
- `app/views/api/v1/admin/users/_user.json.jb` - スコープベースのフィールド制御
- `app/controllers/api/v1/private/userinfo_controller.rb` - ユーザー向け API コントローラー

## 参考資料

- [RFC 6749 - OAuth 2.0 Scope](https://datatracker.ietf.org/doc/html/rfc6749#section-3.3)
- [OpenID Connect Core - Scope Values](https://openid.net/specs/openid-connect-core-1_0.html#ScopeClaims)
- [Okta OAuth 2.0 Scopes](https://developer.okta.com/docs/api/oauth2/)
