# ADR: OAuth Application タイプ導入と LoginSpaApplication の役割整理

- **日付**: 2025-12-25
- **ステータス**: 決定済み
- **決定者**: Akira Suenami

## コンテキスト

### 現状の問題

1. **すべての OAuth クライアントが同じログイン URL にリダイレクトされる**
   - `doorkeeper.rb` の `resource_owner_authenticator` で `Tenant.current.login_spa_application.login_url` を参照
   - Traditional Web アプリケーション（Rails, Express 等）でも SPA のログイン画面にリダイレクトされてしまう

2. **LoginSpaApplication の役割が不明確**
   - 外部 OAuth クライアント用のログイン設定（`login_url` 等）
   - マイページ機能の有効/無効（`enable_web_login` 等）
   - この2つが混在している

3. **Auth0 のようなアプリケーションタイプの概念がない**
   - SPA, Native, Traditional Web, M2M の区別ができない

### OAuth の範囲

```
OAuth フロー（auth-platform の責務）
┌─────────────────────────────────────────────┐
│ 認可リクエスト → ログイン → 認可 → トークン発行 │
└─────────────────────────────────────────────┘
                    ↓
              アクセストークン
                    ↓
┌─────────────────────────────────────────────┐
│ API（プロフィール、決済情報等）              │  ← OAuth の範囲外
│ トークンで保護されるが、仕様は各サービス次第  │     （普通の REST API）
└─────────────────────────────────────────────┘
```

OAuth Application を作成しなければトークンを取得できず、API も叩けない。したがって `enable_api_*` フラグは不要。

### auth-platform の機能分離

```
auth-platform
├── IdP 機能（OAuth/OIDC）     ← 必須
│   └── /oauth/authorize, /oauth/token, etc.
│
├── API（プロフィール等）      ← 必須（OAuth で保護）
│   └── /api/v1/users/me, etc.
│
└── マイページ Web UI          ← オプション（enable_my_page）
    └── /my, /my/profile, etc.
    └── OAuth とは独立した、セッションベースの Web アプリ
```

マイページは OAuth クライアントとして扱う必要はない。auth-platform 自身のセッションで動作する Web アプリケーションであり、外部クライアントとは異なる。

## 決定

### 1. OAuth Application に `application_type` を追加

Auth0 に倣い、アプリケーションタイプを導入する。

**今回実装するタイプ**:

| タイプ | 説明 | ログイン画面 |
|--------|------|-------------|
| `spa` | React, Vue 等（デフォルト） | 外部 `login_url` |
| `traditional_web` | Rails, Express 等 | 内部 `/user_area/logins` |

**将来的に追加予定のタイプ**（構想のみ、短期的には実装しない）:

| タイプ | 説明 | ログイン画面 |
|--------|------|-------------|
| `native` | iOS, Android, Electron 等 | 外部 `login_url`（PKCE 必須等の制約を追加予定） |
| `m2m` | バックエンドサービス | なし（Client Credentials Grant のみ） |

### 2. LoginSpaApplication の役割を「マイページ設定」に限定

LoginSpaApplication の役割を以下のように整理する：

**OauthApplication に移行する設定**:
- `login_url` → 各 OauthApplication が持つ
- `sign_up_url` → 各 OauthApplication が持つ

**LoginSpaApplication に残す設定（マイページ用）**:
- `enable_web_login` → マイページ（`/my`）のWebログイン機能の有効/無効
- `enable_web_sign_up` → マイページのWebサインアップ機能の有効/無効
- `redirect_url_on_password_reset` → パスワードリセット後のリダイレクト先

**削除する設定**:
- `enable_api_login` → 不要（OAuth Application がなければ API も叩けない）
- `enable_api_sign_up` → 不要（同上）

### 3. 将来的な簡略化

LoginSpaApplication を以下のように簡略化することを検討：
- `enable_my_page: boolean` のみに簡略化
- または `TenantSetting` に統合

## 理由

### application_type を OauthApplication に持たせる理由

- OAuth フローの起点は `client_id` で決まる
- クライアントごとにログイン方式が異なるのは自然
- Auth0 等の既存 IdP と同様の概念モデル

### enable_api_* を削除する理由

- OAuth Application を作成しなければトークンを取得できない
- トークンがなければ保護された API にアクセスできない
- したがって、API アクセスの ON/OFF は OAuth Application の存在で制御される

### マイページを OAuth クライアントとして扱わない理由

- マイページは auth-platform 自身の機能
- OAuth フローを通す必要がない（セッションベースで十分）
- 設計がシンプルになる

## 影響

### 変更が必要なコンポーネント

| コンポーネント | 変更内容 |
|---------------|----------|
| `oauth_applications` スキーマ | `application_type`, `login_url`, `sign_up_url` 追加 |
| `login_spa_applications` スキーマ | `enable_api_*` 削除 |
| `OauthApplication` モデル | `application_type` enum 追加 |
| `doorkeeper.rb` | `application_type` による分岐 |
| 管理画面 | OauthApplication の設定項目追加 |

### 後方互換性

- 既存の OauthApplication は `application_type: 'spa'` がデフォルト
- `login_url` が未設定の場合は LoginSpaApplication の設定をフォールバック
- 段階的に移行可能

## 実装フェーズ

### Phase 1: 最小の変更（今回のスコープ）

1. `oauth_applications` スキーマに `application_type`, `login_url`, `sign_up_url` 追加
   - `application_type` は `spa`（デフォルト）と `traditional_web` のみ
   - `native`, `m2m` は将来の拡張として enum 定義に含めるが、今回は未実装
2. `login_spa_applications` スキーマから `enable_api_*` 削除
3. `doorkeeper.rb` で `application_type` による分岐を実装
   - `spa`: 外部 `login_url` にリダイレクト（従来の動作）
   - `traditional_web`: 内部 `/user_area/logins` にリダイレクト
4. 管理画面で OauthApplication の設定項目追加

### Phase 2: LoginSpaApplication の整理（将来）

- LoginSpaApplication を `MyPageSetting` にリネーム
- `enable_web_login`, `enable_web_sign_up` → `enable_my_page` に簡略化
- `login_url`, `sign_up_url` を OauthApplication への移行完了後に削除

### Phase 3: マイページ機能の整理（将来）

- `enable_my_page = true` の場合のみ `/my`, `/user_area/*` にアクセス可能
- `enable_my_page = false` の場合は 404 または無効化メッセージ

## 最終的な構造

```
Tenant
├── OauthApplication（複数）        ← 外部クライアント用
│   ├── application_type: spa | traditional_web（将来: native | m2m）
│   ├── login_url, sign_up_url（SPA用、traditional_web では不要）
│   └── その他 OAuth 設定
│
└── MyPageSetting（1つ）            ← マイページ機能の設定（将来）
    └── enable_my_page             ← マイページ機能の有効/無効
```

## 関連

- [Auth0 Application Types](https://auth0.com/docs/get-started/applications)
- `config/initializers/doorkeeper.rb`
- `app/models/oauth_application.rb`
- `app/models/login_spa_application.rb`
