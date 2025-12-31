# Service Linking (Linked Applications)

## Overview

Service Linking is a mechanism to track which users are linked to which OAuth applications (services). When a user authorizes an OAuth application and an access token is issued, a record is automatically created in `users__linked_applications`.

## Data Model

### Table: `users__linked_applications`

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `tenant_id` | CITEXT | Tenant ID |
| `user_id` | UUID | User ID |
| `oauth_application_id` | UUID | OAuth application (service) ID |
| `scopes` | STRING | Granted scopes (space-separated) |
| `last_linked_at` | DATETIME | Last linked timestamp |
| `created_at` | DATETIME | Created timestamp |
| `updated_at` | DATETIME | Updated timestamp |

**Unique constraint**: `(tenant_id, user_id, oauth_application_id)`

### Relationships

```
oauth_applications (Service/SP)
    ↓ has_many
users__linked_applications (Link relationship)
    ↓ belongs_to
users (User)
```

## How It Works

### Automatic Creation on Token Issuance

When an OAuth access token is issued, the `after_create` callback automatically creates or updates the linked application record:

```ruby
# app/models/oauth_access_token.rb
class OauthAccessToken < ApplicationRecord
  after_create :update_linked_application

  def update_linked_application
    # Skip for password credentials grant (no resource owner)
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

### Update Service Logic

The update service uses `find_or_initialize_by` to create or update the record:

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

  # Scopes are accumulated (union of old and new)
  old_scopes = linked_application.scopes.present? ? linked_application.scopes.split : []
  new_scopes = scopes.present? ? scopes.to_s.split : []
  linked_application.scopes = (old_scopes | new_scopes).join(' ')
  linked_application.last_linked_at = Time.zone.now
  linked_application.save
end
```

### Key Behaviors

1. **Automatic creation**: Records are created automatically when access tokens are issued
2. **Scope accumulation**: Scopes are accumulated over time (union), not replaced
3. **Timestamp tracking**: `last_linked_at` is updated on each token issuance
4. **Multitenancy**: Records are scoped by `tenant_id`

## Model Definition

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

## Use Cases

1. **Track user-service relationships**: Know which users have authorized which services
2. **Scope management**: Track which scopes each user has granted to each service
3. **Activity tracking**: `last_linked_at` shows when the user last obtained a token for the service

## Related Files

- `app/models/users/linked_application.rb` - Linked application model
- `app/models/oauth_application.rb` - OAuth application model
- `app/models/oauth_access_token.rb` - Access token model with callback
- `app/services/users/linked_applications/update_service.rb` - Update service
- `app/services/users/linked_applications/base_service.rb` - Base service
