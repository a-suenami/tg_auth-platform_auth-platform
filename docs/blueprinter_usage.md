# Blueprinter 使用方法

このプロジェクトでは、既存のjbuilderと並行してblueprinterを使用できます。

## 概要

- **既存のjbuilder**: そのまま維持
- **新しいAPI**: blueprinterを使用して実装
- **段階的移行**: 必要に応じてjbuilderからblueprinterに移行可能

## Blueprintの作成

### 基本的なBlueprint

```ruby
# app/blueprints/user_blueprint.rb
class UserBlueprint < Blueprinter::Base
  identifier :id

  fields :email, :enabled, :email_verified, :sms_verified

  field :uid do |user|
    user.id
  end

  association :profile, blueprint: UserProfileBlueprint
  association :contact_address, blueprint: ContactAddressBlueprint
end
```

### 関連データのBlueprint

```ruby
# app/blueprints/user_profile_blueprint.rb
class UserProfileBlueprint < Blueprinter::Base
  fields :first_name, :last_name, :first_name_kana, :last_name_kana, :birth_date, :gender
end
```

## コントローラーでの使用

### 基本的な使用方法

```ruby
class API::V1::UsersController < ApplicationController
  def show
    user = User.find(params[:id])
    render_blueprint(UserBlueprint, user)
  end

  def index
    users = User.all
    render_blueprint_collection(UserBlueprint, users)
  end
end
```

### 関連データを含める

```ruby
def show_with_includes
  user = User.includes(:user_profile, :contact_address).find(params[:id])
  render_blueprint(UserBlueprint, user, include: [:profile, :contact_address])
end
```

### スコープに基づくフィールド制御

```ruby
def show_with_scopes
  user = User.find(params[:id])

  # スコープに基づいてフィールドを制御
  blueprint = create_scoped_blueprint
  render json: blueprint.render_as_hash(user)
end

private

def create_scoped_blueprint
  Class.new(Blueprinter::Base) do
    identifier :id
    fields :email, :enabled

    if @doorkeeper_token&.acceptable?(:uid)
      field :uid do |user|
        user.id
      end
    end

    if @doorkeeper_token&.acceptable?(:name)
      association :profile, blueprint: UserProfileBlueprint
    end
  end
end
```

## ヘルパーメソッド

API ApplicationControllerに以下のヘルパーメソッドが追加されています：

- `render_blueprint(blueprint_class, object, options = {})`
- `render_blueprint_collection(blueprint_class, collection, options = {})`

## 設定

blueprinterの設定は `config/initializers/blueprinter.rb` で管理されています：

- 日時フォーマット: ISO8601
- 関連データのデフォルト制限: 25件
- has_oneのデフォルト制限: 1件

## 既存のjbuilderとの比較

### jbuilder
```ruby
# app/views/api/v1/users/show.json.jb
json.id user.id
json.email user.email
json.profile do
  json.first_name user.user_profile&.first_name
  json.last_name user.user_profile&.last_name
end
```

### blueprinter
```ruby
# app/blueprints/user_blueprint.rb
class UserBlueprint < Blueprinter::Base
  identifier :id
  fields :email
  association :profile, blueprint: UserProfileBlueprint
end

# コントローラー
render_blueprint(UserBlueprint, user)
```

## メリット

1. **パフォーマンス**: jbuilderより高速
2. **型安全性**: より明確な構造定義
3. **再利用性**: blueprintを複数のエンドポイントで使用可能
4. **テスト容易性**: blueprint単体でのテストが可能
5. **メンテナンス性**: 関連データの管理が容易

## 移行ガイド

既存のjbuilderからblueprinterへの移行は段階的に行えます：

1. 新しいAPIエンドポイントはblueprinterで実装
2. 既存のjbuilderはそのまま維持
3. 必要に応じてjbuilderをblueprintに移行

## サンプル

詳細な使用例は `app/controllers/api/v1/blueprint_example_controller.rb` を参照してください。

## Membership API

### エンドポイント

#### GET /api/v1/public/memberships
全てのメンバーシップを取得します。

**レスポンス例:**
```json
[
  {
    "id": "uuid",
    "name": "basic",
    "display_name": "ベーシックプラン",
    "position": 1,
    "tier": "basic",
    "groups": [
      {
        "id": "uuid",
        "name": "general",
        "display_name": "一般"
      }
    ],
    "membership_plans": [
      {
        "id": "uuid",
        "billing_cycle": "monthly",
        "validity_period": "month",
        "amount": 1000,
        "plan_payment_methods": [
          {
            "payment_type": "credit_card"
          }
        ]
      }
    ]
  }
]
```

#### GET /api/v1/public/memberships/:id
特定のメンバーシップを取得します。

#### GET /api/v1/public/memberships/by_group?group_id=:group_id
指定されたグループに属するメンバーシップを取得します。

### Blueprint構造

```ruby
# app/blueprints/membership_blueprint.rb
class MembershipBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :display_name, :position, :tier
  association :groups, blueprint: MembershipGroupBlueprint
  association :membership_plans, blueprint: MembershipPlanBlueprint
end

# app/blueprints/membership_group_blueprint.rb
class MembershipGroupBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :display_name
end

# app/blueprints/membership_plan_blueprint.rb
class MembershipPlanBlueprint < Blueprinter::Base
  identifier :id
  fields :billing_cycle, :validity_period, :amount
  association :plan_payment_methods, blueprint: MembershipPlanPaymentMethodBlueprint
end
```
