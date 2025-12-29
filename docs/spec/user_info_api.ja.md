# ユーザー情報 API

## 概要

このプラットフォームは、ユーザー情報を取得するための2種類のAPIを提供しており、それぞれ異なる目的と対象者に向けたものです。

## API エンドポイント

### 1. Private Userinfo API（OIDC スタイル）

**エンドポイント**: `GET /api/v1/private/userinfo`

**目的**: 認証されたユーザー自身の情報を取得（OIDC の userinfo エンドポイントに相当）

**必要なスコープ**: `uid`, `email`, `name`, `profile`, `contact`, `delivery_address` のいずれか

**対象**: ユーザー自身（アクセストークン経由）

```ruby
# app/controllers/api/v1/private/userinfo_controller.rb
module API::V1::Private
  class UserinfoController < ApplicationController
    before_action -> { doorkeeper_authorize! :uid, :email, :name, :profile, :contact, :delivery_address }

    def index
      @doorkeeper_token = doorkeeper_token
      render :index
    end
  end
end
```

### 2. Admin Users API（SP 管理 API）

**エンドポイント**:
- `GET /api/v1/admin/users` - SP に連携しているユーザー一覧
- `GET /api/v1/admin/users/:id` - 特定ユーザーの詳細

**目的**: サービスプロバイダー（SP）が、自サービスに連携しているユーザーの情報を取得

**必要なスコープ**: `admin_users`

**対象**: SP に連携しているユーザー（`users__linked_applications` 経由）

```ruby
# app/controllers/api/v1/admin/users_controller.rb
module API::V1::Admin
  class UsersController < ApplicationController
    before_action -> { doorkeeper_authorize! :admin_users }

    def index
      users = current_application.users.includes(:user_profile, :contact_address, :delivery_addresses)
      # ...
    end

    def show
      user = User.find(params[:id])
      # ...
    end
  end
end
```

## スコープベースのフィールド制御

両APIは、アクセストークンのスコープに基づいて返すフィールドを制御します：

```ruby
# app/views/api/v1/admin/users/_user.json.jb
json = {}

json[:uid] = user.id if @doorkeeper_token.acceptable?(:uid)
json[:email] = user.email if @doorkeeper_token.acceptable?(:email)
json[:phone_number] = user.phone_number if @doorkeeper_token.acceptable?(:phone_number)

if @doorkeeper_token.acceptable?(:name)
  profile_json[:first_name] = user.user_profile&.first_name
  profile_json[:last_name] = user.user_profile&.last_name
  profile_json[:first_name_kana] = user.user_profile&.first_name_kana
  profile_json[:last_name_kana] = user.user_profile&.last_name_kana
end

if @doorkeeper_token.acceptable?(:profile)
  profile_json[:birth_date] = user.user_profile&.birth_date
  profile_json[:gender] = user.user_profile&.gender
  contact_address_json[:prefecture_code] = user.contact_address&.prefecture_code_jis
  contact_address_json[:prefecture] = user.contact_address&.prefecture&.name
end

if @doorkeeper_token.acceptable?(:contact)
  contact_address_json[:zip_code] = user.contact_address&.zip_code
  contact_address_json[:city] = user.contact_address&.city
  contact_address_json[:street] = user.contact_address&.street
  contact_address_json[:building] = user.contact_address&.building
  contact_address_json[:phone_number] = user.contact_address&.phone_number
  contact_address_json[:country_code] = user.contact_address&.country_code
end

if @doorkeeper_token.acceptable?(:delivery_address)
  json[:delivery_addresses] = user.delivery_addresses.map { |address| ... }
end
```

## スコープとフィールドの対応

| スコープ | フィールド |
|----------|------------|
| `uid` | `id` |
| `email` | `email` |
| `phone_number` | `phone_number` |
| `name` | `first_name`, `last_name`, `first_name_kana`, `last_name_kana` |
| `profile` | `birth_date`, `gender`, `prefecture_code`, `prefecture` |
| `contact` | `zip_code`, `prefecture_code`, `prefecture`, `city`, `street`, `building`, `phone_number`, `country_code` |
| `delivery_address` | `delivery_addresses`（配列） |

## 比較

| 項目 | Private Userinfo | Admin Users API |
|------|------------------|-----------------|
| エンドポイント | `/api/v1/private/userinfo` | `/api/v1/admin/users` |
| 目的 | 自分の情報を取得 | 連携ユーザーの情報を取得 |
| スコープ | `uid`, `email` など | `admin_users` |
| 対象ユーザー | 自分のみ | 連携している全ユーザー |
| ページネーション | なし | あり |
| ユースケース | ユーザー向けアプリ | SP のバックエンドシステム |

## OIDC 標準エンドポイント

上記のカスタム API に加えて、`doorkeeper-openid_connect` による標準 OIDC エンドポイントも提供しています：

```ruby
# config/routes.rb
use_doorkeeper_openid_connect
```

これにより、OpenID Connect 仕様で定義された標準の `/oauth/userinfo` エンドポイントが提供されます。

## 関連ファイル

- `app/controllers/api/v1/private/userinfo_controller.rb` - Private userinfo コントローラー
- `app/controllers/api/v1/admin/users_controller.rb` - Admin users コントローラー
- `app/views/api/v1/admin/users/_user.json.jb` - ユーザー JSON テンプレート
- `config/routes/api/v1/private_routes.rb` - Private API ルーティング
- `config/routes/api/v1/admin_routes.rb` - Admin API ルーティング
