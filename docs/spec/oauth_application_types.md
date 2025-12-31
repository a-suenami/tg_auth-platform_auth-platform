# OAuth Application Types

## Overview

This document describes the current implementation of OAuth applications in auth-platform, compares it with industry standards (Auth0, Okta, etc.), and identifies areas for future improvement.

## Industry Standard: Auth0 Application Types

Auth0 requires selecting an application type upon creation:

| Type | Description | Client Type | Default Grant Types |
|------|-------------|-------------|---------------------|
| Native | Mobile/desktop apps (iOS, Android) | Public | authorization_code, refresh_token, device_code |
| SPA | Browser-based JS apps (React, Vue) | Public | authorization_code, refresh_token, implicit |
| Regular Web | Server-side apps (Rails, Express) | Confidential | authorization_code, refresh_token, implicit |
| Machine to Machine | Backend services, daemons, CLIs | Confidential | client_credentials |

### Confidential vs Public Clients

| Client Type | `token_endpoint_auth_method` | Client Secret |
|-------------|------------------------------|---------------|
| Public | `none` | Cannot be stored securely (source code visible) |
| Confidential | `client_secret_post`, `client_secret_basic`, `private_key_jwt` | Stored securely on server |

**Key constraint**: `client_credentials` grant MUST only be used by Confidential clients.

## Current auth-platform Implementation

### oauth_applications Table Schema

```ruby
t.string  "name", null: false
t.string  "uid", null: false                    # client_id
t.string  "secret", null: false                 # client_secret
t.text    "redirect_uri", null: false
t.string  "scopes", default: "", null: false
t.boolean "confidential", default: true         # Doorkeeper standard
t.boolean "enable_client_credential_flow"       # Custom extension
t.boolean "enable_push_event"                   # Custom extension
t.boolean "require_sms_mfa"                     # Custom extension
t.text    "allowed_logout_urls"                 # Custom extension
```

### Doorkeeper Required Columns

Doorkeeper requires only these columns:
- `name`, `uid`, `secret`, `redirect_uri`, `scopes`, `confidential`, `timestamps`

Additional columns can be added freely without affecting Doorkeeper functionality.

### Current Grant Flow Control

```ruby
# config/initializers/doorkeeper.rb
allow_grant_flow_for_client do |grant_flow, client|
  if grant_flow == 'client_credentials'
    client.enable_client_credential_flow  # Custom flag controls M2M access
  else
    true  # All other flows are always allowed
  end
end
```

## Comparison: auth-platform vs Auth0

| Aspect | Auth0 | auth-platform | Gap |
|--------|-------|---------------|-----|
| Application type | `app_type` (4 types) | **None** | ❌ No distinction |
| Client type | `token_endpoint_auth_method` | `confidential` (boolean) | △ Simplified |
| M2M permission | Determined by type | `enable_client_credential_flow` | △ Manual flag |
| Grant types | Defaults per type | **Implicitly all allowed** | ❌ Insufficient control |

## The `confidential` Column

### Doorkeeper Behavior by `confidential` Value

| confidential | Token Endpoint Auth | Authorization Skip | Token Revocation |
|:------------:|---------------------|-------------------|------------------|
| `true` | `client_secret` **required** | Can skip with existing token | `client_secret` required |
| `false` | `client_secret` **not required** | Should always prompt | `client_secret` not required |

### Important Notes

- Secret is **always generated** regardless of `confidential` value
- For Public clients (`confidential: false`), secret exists but is not validated
- Public clients should use PKCE for Authorization Code flow

## Known Issues

### No Validation for Dangerous Combinations

The current implementation does not prevent:

```ruby
OauthApplication.create!(
  confidential: false,                    # Public Client
  enable_client_credential_flow: true     # But allows Client Credentials
)
```

This is a **security risk** - Public clients cannot securely store credentials, so Client Credentials grant should be forbidden.

### No Application Type Distinction

Without `app_type`, it's impossible to:
- Distinguish between SPA and Native apps
- Apply type-specific defaults automatically
- Prevent M2M apps from having user-facing settings (like `required_user_fields`)

## Future Considerations

### Option A: Add `app_type` Column

```ruby
t.string :app_type  # 'native', 'spa', 'regular_web', 'machine_to_machine'

# Automatically set defaults based on type
# Validate combinations (e.g., M2M must be confidential)
```

### Option B: Use Only `confidential` + `grant_types`

```ruby
t.boolean :confidential
t.string  :grant_types, array: true  # ['authorization_code', 'client_credentials', ...]

# app_type is just a shortcut for these settings
```

### Validation to Add

```ruby
validates :enable_client_credential_flow, inclusion: { in: [false] },
          unless: :confidential?,
          message: "Client Credentials not allowed for Public clients"
```

## Other IdP Approaches

| IdP | Approach |
|-----|----------|
| **Auth0** | Single table + `app_type` |
| **Okta** | "API Services" as separate type |
| **Azure AD** | Same App Registration UI, different settings |
| **Google Cloud** | **Separate entities**: OAuth Client ID vs Service Account |

## Related Files

- `app/models/oauth_application.rb` - OAuth application model
- `config/initializers/doorkeeper.rb` - Doorkeeper configuration
- `app/views/ruler_area/tenants/oauth_applications/_form.html.slim` - Admin UI form
- `db/schema.rb` - Database schema

## References

- [RFC 6749 - OAuth 2.0 Authorization Framework](https://datatracker.ietf.org/doc/html/rfc6749)
- [Auth0 Application Types](https://auth0.com/docs/get-started/applications)
- [Doorkeeper Custom Models](https://doorkeeper.gitbook.io/guides/configuration/models)
