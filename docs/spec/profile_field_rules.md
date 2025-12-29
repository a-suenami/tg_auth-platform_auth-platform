# Profile Field Rules

## Overview

Profile Field Rules is a mechanism to control the behavior of user profile fields on a per-tenant basis. It is stored in `tenant_setting.profile_field_rules` as JSONB.

## Storage Location

- Table: `tenant_settings`
- Column: `profile_field_rules` (JSONB)
- Scope: Per tenant

## Data Structure

```json
{
  "user_profiles": {
    "first_name": { "required": true, "hidden": false, "editable": false },
    "last_name": { "required": true, "hidden": false, "editable": true },
    "first_name_kana": { "required": true, "hidden": false, "editable": false },
    "last_name_kana": { "required": true, "hidden": false, "editable": true },
    "birth_date": { "required": true, "hidden": false, "editable": false },
    "gender": { "required": true, "hidden": false, "editable": false }
  },
  "contact_address": {
    "zip_code": { "required": true, "hidden": false, "editable": true },
    "prefecture_code": { "required": true, "hidden": false, "editable": true },
    "city": { "required": true, "hidden": false, "editable": true },
    "street": { "required": true, "hidden": false, "editable": true },
    "building": { "required": false, "hidden": false, "editable": true },
    "phone_number": { "required": false, "hidden": false, "editable": true },
    "country_code": { "required": false, "hidden": false, "editable": true }
  }
}
```

## Field Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `required` | boolean | Whether the field is mandatory for enabling the user account |
| `hidden` | boolean | Whether the field is hidden from the user profile edit screen |
| `editable` | boolean | Whether the field can be edited after initial input |

## Affected Screens

| Screen | Affected |
|--------|----------|
| User Profile Edit (`UserArea::ProfilesController`) | Yes |
| Admin API (`API::V1::Admin::UsersController`) | No |
| Ruler Area (Tenant Settings) | No |

## How It Works

### 1. Rule Merging

Tenant-specific rules are merged with default rules using `deep_merge`:

```ruby
# app/forms/user_form.rb
merged_rules = if tenant&.tenant_setting&.profile_field_rules.present?
  persed_rules = safe_parse_json(tenant&.tenant_setting&.profile_field_rules)
  deep_merge(DEFAULT_PROFILE_FIELD_RULES, persed_rules)
else
  DEFAULT_PROFILE_FIELD_RULES
end
```

### 2. User Account Enabling

When a user completes their profile, the system checks if all required fields are filled:

```ruby
# app/forms/user_form.rb
def check_and_enable_user
  return true if user.enabled

  # 1. Password must be set
  return false if user.password_digest.blank?
  # 2. SMS verification (if required by tenant)
  return false if user.tenant&.sms_verification_required && !user.sms_verified
  # 3. All required fields must be filled
  return false unless check_required_fields_filled?

  user.enabled = true
  user.save!
end
```

### 3. Editable Field Logic

Fields with `editable: false` can still be edited if the value is not yet set:

```ruby
# app/controllers/user_area/profiles_controller.rb
def field_editable?(table_name, field)
  rules = @profile_field_rules[table_name][field]
  return true if rules[:editable]

  # Even if editable: false, allow editing if value is not yet set
  case table_name
  when :user_profiles
    current_user.user_profile&.public_send(field).blank?
  when :contact_address
    current_user.contact_address&.public_send(field).blank?
  else
    true
  end
end
```

## Attribute Combinations

The three attributes (`required`, `hidden`, `editable`) are implemented as independent flags, but some combinations are logically invalid.

### Valid Combinations

| required | hidden | editable | Description |
|----------|--------|----------|-------------|
| `true` | `false` | `true` | Displayed, required, always editable |
| `true` | `false` | `false` | Displayed, required, locked after first input |
| `false` | `false` | `true` | Displayed, optional, always editable |
| `false` | `false` | `false` | Displayed, optional, locked after first input |
| `false` | `true` | `*` | Hidden (not collected from user) |

### Invalid Combinations

| required | hidden | editable | Problem |
|----------|--------|----------|---------|
| `true` | `true` | `*` | Field is hidden from form but validation requires it - user cannot input but gets validation error |

## Known Issues

### No Validation for Invalid Attribute Combinations

The current implementation does not validate the logical consistency of attribute combinations. If an administrator configures `required: true` with `hidden: true`, the system will:

1. Hide the field from the profile edit form (due to `hidden: true`)
2. Fail validation when the user submits (due to `required: true`)
3. Result in an uncompletable profile, blocking the user from enabling their account

**Workaround**: Administrators must manually ensure they do not set `required: true` and `hidden: true` together.

## Related Files

- `app/forms/user_form.rb` - Main form handling profile field rules
- `app/forms/user_profile_form.rb` - User profile form
- `app/forms/contact_address_form.rb` - Contact address form
- `app/controllers/user_area/profiles_controller.rb` - Profile edit controller
- `app/models/tenant_setting.rb` - Tenant setting model
