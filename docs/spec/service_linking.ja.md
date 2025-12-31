# サービス連携 (Linked Applications)

## 概要

サービス連携は、どのユーザーがどの OAuth アプリケーション（サービス）と連携しているかを追跡する仕組みです。ユーザーが OAuth アプリケーションを認可してアクセストークンが発行されると、`users__linked_applications` に自動的にレコードが作成されます。

## データモデル

### テーブル: `users__linked_applications`

| カラム | 型 | 説明 |
|--------|------|------|
| `id` | UUID | 主キー |
| `tenant_id` | CITEXT | テナントID |
| `user_id` | UUID | ユーザーID |
| `oauth_application_id` | UUID | OAuthアプリケーション（サービス）ID |
| `scopes` | STRING | 許可されたスコープ（スペース区切り） |
| `last_linked_at` | DATETIME | 最終連携日時 |
| `created_at` | DATETIME | 作成日時 |
| `updated_at` | DATETIME | 更新日時 |

**ユニーク制約**: `(tenant_id, user_id, oauth_application_id)`

### リレーションシップ

```
oauth_applications (サービス/SP)
    ↓ has_many
users__linked_applications (連携関係)
    ↓ belongs_to
users (ユーザー)
```

## 動作の仕組み

### トークン発行時の自動作成

OAuth アクセストークンが発行されると、`after_create` コールバックが自動的に連携レコードを作成または更新します：

```ruby
# app/models/oauth_access_token.rb
class OauthAccessToken < ApplicationRecord
  after_create :update_linked_application

  def update_linked_application
    # パスワードクレデンシャルグラントの場合はスキップ（リソースオーナーなし）
    return false if self.resource_owner_id.nil?

    Users::LinkedApplications::UpdateService.new.execute(
      tenant_id: self.tenant_id,
      resource_owner_id: self.resource_owner_id,
      oauth_application_id: self.application_id,
      scopes: self.scopes
    )
  end
end
```

### 更新サービスのロジック

更新サービスは `find_or_initialize_by` を使用してレコードを作成または更新します：

```ruby
# app/services/users/linked_applications/update_service.rb
def execute(tenant_id:, resource_owner_id:, oauth_application_id:, scopes:)
  return false if User.active.find(resource_owner_id).blank?
  return false unless OauthApplication.find_by(id: oauth_application_id)
  return false if tenant_id.blank?

  linked_application = Users::LinkedApplication.find_or_initialize_by(
    tenant_id:,
    user_id: resource_owner_id,
    oauth_application_id:
  )

  # スコープは累積される（新旧の和集合）
  old_scopes = linked_application.scopes.present? ? linked_application.scopes.split : []
  new_scopes = scopes.present? ? scopes.to_s.split : []
  linked_application.scopes = (old_scopes | new_scopes).join(' ')
  linked_application.last_linked_at = Time.zone.now
  linked_application.save
end
```

### 主な挙動

1. **自動作成**: アクセストークン発行時にレコードが自動作成される
2. **スコープの累積**: スコープは置き換えではなく累積される（和集合）
3. **タイムスタンプ追跡**: トークン発行のたびに `last_linked_at` が更新される
4. **マルチテナンシー**: レコードは `tenant_id` でスコープされる

## モデル定義

```ruby
# app/models/users/linked_application.rb
module Users
  class LinkedApplication < ApplicationRecord
    include Multitenancy

    belongs_to :user
    belongs_to :oauth_application,
      class_name: 'OauthApplication',
      inverse_of: :linked_applications
  end
end
```

```ruby
# app/models/oauth_application.rb
class OauthApplication < ApplicationRecord
  include Doorkeeper::Orm::ActiveRecord::Mixins::Application
  include Multitenancy

  has_many :linked_applications,
    class_name: 'Users::LinkedApplication',
    inverse_of: :oauth_application
  has_many :users,
    through: :linked_applications,
    inverse_of: :oauth_applications
end
```

## ユースケース

1. **ユーザー・サービス関係の追跡**: どのユーザーがどのサービスを認可しているか把握
2. **スコープ管理**: 各ユーザーが各サービスに許可したスコープを追跡
3. **アクティビティ追跡**: `last_linked_at` でユーザーが最後にそのサービスのトークンを取得した日時がわかる

## 関連ファイル

- `app/models/users/linked_application.rb` - 連携アプリケーションモデル
- `app/models/oauth_application.rb` - OAuthアプリケーションモデル
- `app/models/oauth_access_token.rb` - コールバック付きアクセストークンモデル
- `app/services/users/linked_applications/update_service.rb` - 更新サービス
- `app/services/users/linked_applications/base_service.rb` - ベースサービス
