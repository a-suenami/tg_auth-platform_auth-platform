# Task: Grant Types Per Application

## Overview

Implement per-application grant type control using a separate table instead of the `enable_client_credential_flow` boolean column on `oauth_applications`.

## Background

Currently, grant types are controlled at two levels:
1. **Server level**: `grant_flows` in `config/initializers/doorkeeper.rb` (static)
2. **Application level**: Only `enable_client_credential_flow` flag (partial control)

This means `authorization_code` and `implicit_oidc` are always allowed for all applications, with no way to disable them per-application.

## Proposed Design

### New Table: `oauth_application_grant_types`

```ruby
create_table :oauth_application_grant_types do |t|
  t.citext :tenant_id, null: false
  t.uuid   :oauth_application_id, null: false
  t.string :grant_type, null: false  # 'authorization_code', 'client_credentials', 'implicit', 'refresh_token'
  t.timestamps
end

add_index :oauth_application_grant_types,
          [:tenant_id, :oauth_application_id, :grant_type],
          unique: true,
          name: 'idx_oauth_app_grant_types_unique'

add_foreign_key :oauth_application_grant_types, :oauth_applications
add_foreign_key :oauth_application_grant_types, :tenants
```

### Model

```ruby
# app/models/oauth_application_grant_type.rb
class OauthApplicationGrantType < ApplicationRecord
  include Multitenancy

  belongs_to :oauth_application

  VALID_GRANT_TYPES = %w[
    authorization_code
    client_credentials
    implicit
    refresh_token
  ].freeze

  validates :grant_type, presence: true, inclusion: { in: VALID_GRANT_TYPES }
  validates :grant_type, uniqueness: { scope: [:tenant_id, :oauth_application_id] }
end
```

```ruby
# app/models/oauth_application.rb
class OauthApplication < ApplicationRecord
  has_many :oauth_application_grant_types, dependent: :destroy

  def grant_types
    oauth_application_grant_types.pluck(:grant_type)
  end

  def supports_grant_type?(grant_type)
    oauth_application_grant_types.exists?(grant_type: grant_type)
  end
end
```

### Doorkeeper Configuration Update

```ruby
# config/initializers/doorkeeper.rb
allow_grant_flow_for_client do |grant_flow, client|
  client.supports_grant_type?(grant_flow)
end
```

### Validation Rules

```ruby
class OauthApplicationGrantType < ApplicationRecord
  validate :client_credentials_requires_confidential

  private

  def client_credentials_requires_confidential
    if grant_type == 'client_credentials' && !oauth_application.confidential?
      errors.add(:grant_type, "client_credentials requires confidential client")
    end
  end
end
```

## Migration Strategy

### Phase 1: Add New Table (Non-breaking)

1. Create `oauth_application_grant_types` table
2. Add model and associations
3. Keep `enable_client_credential_flow` column (backward compatibility)

### Phase 2: Data Migration

```ruby
# Migrate existing data
OauthApplication.find_each do |app|
  # All apps currently support authorization_code (implicit in current design)
  app.oauth_application_grant_types.find_or_create_by!(
    tenant_id: app.tenant_id,
    grant_type: 'authorization_code'
  )

  # Migrate client_credentials flag
  if app.enable_client_credential_flow
    app.oauth_application_grant_types.find_or_create_by!(
      tenant_id: app.tenant_id,
      grant_type: 'client_credentials'
    )
  end
end
```

### Phase 3: Switch Doorkeeper Config

Update `allow_grant_flow_for_client` to use new table.

### Phase 4: Remove Old Column

Remove `enable_client_credential_flow` column after confirming everything works.

## Benefits

1. **Explicit control**: Each grant type is explicitly enabled, no implicit defaults
2. **Extensibility**: Easy to add new grant types without schema changes
3. **Queryable**: Can query applications by grant type using SQL
4. **Consistent pattern**: Matches the proposed `oauth_application_field_rules` table design

## Related Tasks

- [ ] Create migration for `oauth_application_grant_types` table
- [ ] Create model with validations
- [ ] Update `OauthApplication` model
- [ ] Update Doorkeeper configuration
- [ ] Create data migration
- [ ] Update admin UI
- [ ] Remove `enable_client_credential_flow` column

## Related Documents

- `docs/spec/oauth_application_types.md` - OAuth application type specifications
