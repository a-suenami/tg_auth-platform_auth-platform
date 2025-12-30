# Admin API Scopes

## Overview

This document describes the current implementation of OAuth scopes for the Admin API in auth-platform, and identifies areas for future improvement.

## OAuth Scope Standards

### What Standards Define

| Specification | Defined Scopes |
|---------------|----------------|
| **OAuth 2.0 (RFC 6749)** | None - intentionally implementation-defined |
| **OIDC** | `openid`, `profile`, `email`, `phone`, `address`, `offline_access` |
| **SCIM** | API schema only, no scopes defined |

> "scope" values are implementation defined; there is no centralized registry for them; allowed values are defined by the authorization server.
> — RFC 6749

**There is no standard specification for admin/management API scopes.** Each IdP defines their own.

### How Other IdPs Handle This

| IdP | Admin Scopes |
|-----|--------------|
| **Okta** | `okta.users.read`, `okta.users.manage`, `okta.apps.read`, etc. (fine-grained) |
| **Auth0** | `read:users`, `update:users`, `delete:users`, etc. (action-based) |
| **Slack** | `admin`, `scim:enterprise` |
| **GitHub** | `admin:org`, `scim:enterprise` |

## Current auth-platform Implementation

### Defined Scopes

```ruby
# config/initializers/doorkeeper.rb
default_scopes  :public
optional_scopes :uid, :email, :name, :profile, :phone_number, :contact,
                :delivery_address, :openid, :sms_mfa, :admin_users
```

### Scope Categories

| Scope | Type | Purpose |
|-------|------|---------|
| `openid` | OIDC Standard | Enable OIDC |
| `email` | OIDC Standard | Access email |
| `profile` | Custom (similar to OIDC) | Birth date, gender, prefecture |
| `phone_number` | Custom (similar to OIDC `phone`) | Phone number |
| `uid` | Custom | User ID |
| `name` | Custom | First/last name |
| `contact` | Custom | Full address |
| `delivery_address` | Custom | Delivery addresses |
| `sms_mfa` | Custom | SMS MFA requirement |
| `admin_users` | Custom | **Admin API access** |

### How Admin API Uses Scopes

```ruby
# app/controllers/api/v1/admin/users_controller.rb
before_action -> { doorkeeper_authorize! :admin_users }
```

```ruby
# app/views/api/v1/admin/users/_user.json.jb
json[:email] = user.email if @doorkeeper_token.acceptable?(:email)
json[:phone_number] = user.phone_number if @doorkeeper_token.acceptable?(:phone_number)
# ... field-level control using same scopes as user-facing API
```

### Current Structure

```
admin_users  →  Grants access to Admin API endpoints
     +
uid, email, profile, ...  →  Controls which fields are returned
```

## Known Issues

### Same Scopes Control Both User-Facing and Admin APIs

| Scope | Private Userinfo API | Admin Users API |
|-------|---------------------|-----------------|
| `email` | Own email | **All users'** emails |
| `profile` | Own profile | **All users'** profiles |

**Problem**: A SP with `admin_users` + `email` can access all users' emails, even if they only intended to access the current user's email.

### No Standard for Admin Scopes

Unlike OIDC standard scopes, there is no industry standard for admin/management API scopes.

## Future Consideration: Scope Separation

### Proposed Structure

Separate user-facing scopes from admin scopes:

```ruby
# User-facing (access own data)
:uid, :email, :profile, :phone, :address

# Admin API (access all users' data)
:'admin:uid', :'admin:email', :'admin:profile', :'admin:phone', :'admin:address'

# Or alternatively
:'admin_users:uid', :'admin_users:email', :'admin_users:profile', ...
```

### Benefits

1. **Explicit separation**: Clear distinction between own data and all users' data
2. **Least privilege**: SP can request only what they need for each API
3. **Clearer consent**: Users understand what they're authorizing

### Example Usage

```ruby
# SP that only needs user's own email for login
scopes: 'openid email'

# SP that needs to sync all users' emails to their system
scopes: 'admin:email'

# SP that needs both
scopes: 'openid email admin:email admin:profile'
```

### Implementation Considerations

- Requires migration of existing applications
- Need to update Admin API to check new scope names
- Consider backward compatibility period

## Comparison with OIDC Scopes

| OIDC Scope | Current auth-platform | Proposed Admin Equivalent |
|------------|----------------------|---------------------------|
| `openid` | `uid` (custom) | `admin:uid` |
| `email` | `email` | `admin:email` |
| `profile` | `name` + `profile` | `admin:name` + `admin:profile` |
| `phone` | `phone_number` | `admin:phone` |
| `address` | `contact` | `admin:contact` |

## Related Files

- `config/initializers/doorkeeper.rb` - Scope definitions
- `app/controllers/api/v1/admin/users_controller.rb` - Admin API controller
- `app/views/api/v1/admin/users/_user.json.jb` - Scope-based field control
- `app/controllers/api/v1/private/userinfo_controller.rb` - User-facing API controller

## References

- [RFC 6749 - OAuth 2.0 Scope](https://datatracker.ietf.org/doc/html/rfc6749#section-3.3)
- [OpenID Connect Core - Scope Values](https://openid.net/specs/openid-connect-core-1_0.html#ScopeClaims)
- [Okta OAuth 2.0 Scopes](https://developer.okta.com/docs/api/oauth2/)
