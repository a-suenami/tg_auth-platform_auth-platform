# User Info API

## Overview

This platform provides two types of APIs for retrieving user information, each serving different purposes and audiences.

## API Endpoints

### 1. Private Userinfo API (OIDC-style)

**Endpoint**: `GET /api/v1/private/userinfo`

**Purpose**: Retrieve the authenticated user's own information (similar to OIDC userinfo endpoint)

**Required Scopes**: At least one of `uid`, `email`, `name`, `profile`, `contact`, `delivery_address`

**Target**: The user themselves (via access token)

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

### 2. Admin Users API (SP Management API)

**Endpoints**:
- `GET /api/v1/admin/users` - List users linked to the SP
- `GET /api/v1/admin/users/:id` - Get specific user details

**Purpose**: Allow Service Providers (SP) to retrieve information about users who have linked to their service

**Required Scopes**: `admin_users`

**Target**: Users who are linked to the SP (via `users__linked_applications`)

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

## Scope-Based Field Control

Both APIs control which fields are returned based on the access token's scopes:

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

## Scope to Field Mapping

| Scope | Fields |
|-------|--------|
| `uid` | `id` |
| `email` | `email` |
| `phone_number` | `phone_number` |
| `name` | `first_name`, `last_name`, `first_name_kana`, `last_name_kana` |
| `profile` | `birth_date`, `gender`, `prefecture_code`, `prefecture` |
| `contact` | `zip_code`, `prefecture_code`, `prefecture`, `city`, `street`, `building`, `phone_number`, `country_code` |
| `delivery_address` | `delivery_addresses` (array) |

## Comparison

| Aspect | Private Userinfo | Admin Users API |
|--------|------------------|-----------------|
| Endpoint | `/api/v1/private/userinfo` | `/api/v1/admin/users` |
| Purpose | Get own info | Get linked users' info |
| Scope | `uid`, `email`, etc. | `admin_users` |
| Target users | Self only | All linked users |
| Pagination | N/A | Supported |
| Use case | User-facing apps | SP backend systems |

## OIDC Standard Endpoints

In addition to the custom APIs above, the platform also provides standard OIDC endpoints via `doorkeeper-openid_connect`:

```ruby
# config/routes.rb
use_doorkeeper_openid_connect
```

This provides the standard `/oauth/userinfo` endpoint as defined by the OpenID Connect specification.

## Related Files

- `app/controllers/api/v1/private/userinfo_controller.rb` - Private userinfo controller
- `app/controllers/api/v1/admin/users_controller.rb` - Admin users controller
- `app/views/api/v1/admin/users/_user.json.jb` - User JSON template
- `config/routes/api/v1/private_routes.rb` - Private API routes
- `config/routes/api/v1/admin_routes.rb` - Admin API routes
