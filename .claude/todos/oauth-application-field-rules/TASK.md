# OAuth Application Field Rules UI Design

## Overview

UI design for configuring per-application field rules during OAuth Application registration.

## Design Principles

1. **Minimize diff from existing UI** - Don't change existing forms
2. **Two-step flow** - Navigate to field rules screen after basic info registration
3. **Default to required** - Ensure safe state even if user abandons mid-flow

## Current Flow

```
[New] → [Form Input] → [Save] → [Detail Screen]
```

## Proposed Flow

```
[New] → [Form Input] → [Save] → [Field Rules Config] → [Detail Screen]
                                        ↓
                                  (OK to abandon:
                                   defaults all to required)
```

## Screen Specifications

### 1. OAuth Application Create Screen (Existing: No Changes)

`app/views/ruler_area/tenants/oauth_applications/new.html.slim`

Keep current form as-is:
- name
- redirect_uri
- scopes
- allowed_logout_urls
- enable_client_credential_flow
- enable_push_event
- require_sms_mfa
- confidential

### 2. Field Rules Configuration Screen (New)

`app/views/ruler_area/tenants/oauth_applications/field_rules.html.slim`

#### Screen Layout

```slim
.uk-margin-top.uk-container
  h2 Field Rules Configuration

  .uk-alert.uk-alert-primary
    | Configure which fields are required for users of this application.

  .uk-margin-top.uk-card.uk-card-default.uk-card-body
    h3 #{@oauth_application.name}

    = form_with model: @oauth_application,
                url: update_field_rules_ruler_area_tenant_oauth_application_path,
                method: :patch do |f|

      table.uk-table.uk-table-divider
        thead
          tr
            th Field
            th Tenant Setting
            th Required
        tbody
          - @field_rules.each do |field|
            tr
              td
                = field[:label]
                .uk-text-meta= field[:key]
              td
                - case field[:tenant_status]
                - when :required
                  span.uk-label.uk-label-warning Required
                - when :hidden
                  span.uk-label.uk-label-danger Hidden
                - when :editable
                  span.uk-label Editable
              td
                - if field[:tenant_status] == :required
                  = check_box_tag "field_rules[#{field[:key]}]", true, true,
                                  disabled: true, class: "uk-checkbox"
                  .uk-text-meta Required by tenant
                - elsif field[:tenant_status] == :hidden
                  | −
                - else
                  = check_box_tag "field_rules[#{field[:key]}]", true,
                                  field[:required], class: "uk-checkbox"

      .uk-alert.uk-alert-warning
        | ⚠️ All editable fields default to "required".
        | Uncheck fields that are not needed.

      .uk-margin-top
        = f.submit "Save Settings", class: "uk-button uk-button-primary"
        = link_to "Skip (keep all required)",
                  ruler_area_tenant_oauth_application_path(@oauth_application.tenant_id, @oauth_application),
                  class: "uk-button uk-button-default uk-margin-left"
```

#### Available Fields

| Key | Label |
|-----|-------|
| `first_name` | First Name |
| `last_name` | Last Name |
| `first_name_kana` | First Name (Kana) |
| `last_name_kana` | Last Name (Kana) |
| `birth_date` | Birth Date |
| `gender` | Gender |
| `phone_number` | Phone Number |
| `postal_code` | Postal Code |
| `prefecture` | Prefecture |
| `city` | City |
| `address1` | Address 1 |
| `address2` | Address 2 |

### 3. Detail Screen Extension

`app/views/ruler_area/tenants/oauth_applications/show.html.slim`

Add Field Rules section:

```slim
/ Add after existing table
h3.uk-margin-top Field Rules

- if @oauth_application.user_facing?
  table.uk-table.uk-table-divider
    thead
      tr
        th Field
        th Required
    tbody
      - @oauth_application.field_rules_summary.each do |field|
        tr
          td= field[:label]
          td
            - if field[:required]
              span.uk-label.uk-label-success ✓
            - else
              | −

  = link_to "Edit Field Rules",
            field_rules_ruler_area_tenant_oauth_application_path(@oauth_application.tenant_id, @oauth_application),
            class: "uk-button uk-button-default uk-button-small"
- else
  p.uk-text-muted Field rules cannot be configured for M2M-only applications.
```

## Controller Changes

### `oauth_applications_controller.rb`

```ruby
def create
  @oauth_application = OauthApplication.create(oauth_application_params)
  if @oauth_application.persisted?
    # Create field rules with defaults (all required)
    create_default_field_rules(@oauth_application)

    if @oauth_application.user_facing?
      # User-facing app: redirect to field rules config
      redirect_to field_rules_ruler_area_tenant_oauth_application_path(
        @oauth_application.tenant_id,
        @oauth_application
      ), notice: t('helpers.messages.created_configure_field_rules')
    else
      # M2M app: redirect to detail screen
      redirect_to ruler_area_tenant_oauth_application_path(
        @oauth_application.tenant_id,
        @oauth_application
      ), notice: t('helpers.messages.created')
    end
  else
    render :new, status: :unprocessable_entity
  end
end

def field_rules
  @oauth_application = OauthApplication.find(params[:id])
  @field_rules = build_field_rules_for_form(@oauth_application)
end

def update_field_rules
  @oauth_application = OauthApplication.find(params[:id])

  if @oauth_application.update_field_rules(field_rules_params)
    redirect_to ruler_area_tenant_oauth_application_path(
      @oauth_application.tenant_id,
      @oauth_application
    ), notice: t('helpers.messages.field_rules_updated')
  else
    @field_rules = build_field_rules_for_form(@oauth_application)
    render :field_rules, status: :unprocessable_entity
  end
end

private

def create_default_field_rules(oauth_application)
  # Get tenant settings
  tenant_setting = TenantSetting.find_by(tenant_id: oauth_application.tenant_id)
  tenant_rules = JSON.parse(tenant_setting&.profile_field_rules || '{}')

  # Create rules for all fields
  CONFIGURABLE_FIELDS.each do |field|
    tenant_rule = tenant_rules.dig(field.to_s) || {}

    # Hidden if tenant marks it hidden, otherwise required
    rule = tenant_rule['hidden'] ? 'hidden' : 'required'

    OauthApplicationFieldRule.create!(
      tenant_id: oauth_application.tenant_id,
      oauth_application_id: oauth_application.id,
      field_name: field.to_s,
      rule: rule
    )
  end
end
```

## Routes

```ruby
resources :oauth_applications do
  member do
    get :field_rules
    patch :update_field_rules
  end
end
```

## Database

Schema file: `db/schemas/oauth_application_field_rules.schema`

```ruby
create_table :oauth_application_field_rules, force: :cascade, id: :uuid, default: -> { 'gen_random_uuid()' } do |t|
  t.references :tenant, type: :citext, null: false
  t.references :oauth_application, type: :uuid, null: false
  t.string :field_name, null: false   # 'first_name', 'phone_number', etc.
  t.string :rule, null: false         # 'required', 'editable', 'hidden'

  t.timestamps null: false

  t.index [:oauth_application_id, :field_name],
          name: :idx_oauth_app_field_rules_unique,
          unique: true
end

add_foreign_key :oauth_application_field_rules, :oauth_applications,
                column: [:tenant_id, :oauth_application_id],
                primary_key: [:tenant_id, :id],
                name: :fk_oauth_application_field_rules_oauth_applications
```

### Rule Values

| Value | Description |
|-------|-------------|
| `required` | User must fill this field to complete authorization |
| `editable` | User can optionally fill this field |
| `hidden` | Field is not shown to user for this application |

## Edit Flow

When editing existing applications:

1. Click "Edit Field Rules" from detail screen
2. Edit on field_rules screen
3. Save → return to detail screen

## M2M App Handling

When `user_facing?` is `false` (after grant_types table implementation):

- On create: skip field rules config screen
- On detail screen: show "Cannot configure for M2M-only applications"
- Don't create field_rules records

Currently (before grant_types table implementation), `user_facing?` always returns `true`.

---

# User-Side: Authorization Flow with Field Collection

## Overview

During OAuth authorization flow, if required fields are not filled, display an input form to collect them from the user.

## Authorization Flow

```
[SP] → [Auth Request] → [Login/Sign Up]
                              ↓
                    [Check Required Fields]
                              ↓
              ┌───────────────┴───────────────┐
              ↓                               ↓
        [Missing Fields]              [All Fields Filled]
              ↓                               ↓
        [Show Input Form]                     │
              ↓                               │
        [Submit Form]                         │
              ↓                               ↓
              └───────────────┬───────────────┘
                              ↓
                    [Authorization Complete → Callback]
```

## Implementation Options

### Option A: Show form only when fields are missing (Recommended)

```ruby
# app/controllers/oauth/authorizations_controller.rb
class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
  before_action :ensure_required_fields_filled, only: [:create]

  private

  def ensure_required_fields_filled
    return unless user_signed_in?

    missing_fields = calculate_missing_fields(current_user, oauth_application)

    if missing_fields.any?
      # Store authorization params in session
      session[:pending_authorization] = authorization_params

      redirect_to oauth_profile_completion_path(
        oauth_application_id: oauth_application.id,
        missing_fields: missing_fields.map(&:field_name)
      )
    end
  end

  def calculate_missing_fields(user, application)
    application.field_rules.where(rule: 'required').select do |field_rule|
      value = get_field_value(user, field_rule.field_name)
      value.blank?
    end
  end
end
```

**Pros:**
- Better UX for returning users (no extra step if already filled)
- Faster flow for users with complete profiles

**Cons:**
- Need conditional logic to check field completion

### Option B: Always show form (pre-filled)

```ruby
# Always redirect to profile completion, pre-fill with existing values
def ensure_required_fields_filled
  return unless user_signed_in?

  session[:pending_authorization] = authorization_params

  redirect_to oauth_profile_completion_path(
    oauth_application_id: oauth_application.id
  )
end
```

**Pros:**
- Simpler implementation (no conditional branching)
- User always confirms their information

**Cons:**
- Extra step for every authorization (annoying UX)
- Users may wonder why they need to confirm every time

### Recommendation: Option A with shared controller

Adopt Option A while consolidating form display/skip logic in a shared controller.

## Profile Completion Screen

`app/views/oauth/profile_completions/show.html.slim`

```slim
.uk-margin-top.uk-container
  h2 Additional Information Required

  .uk-alert.uk-alert-primary
    | To use "#{@oauth_application.name}", the following information is required.

  .uk-margin-top.uk-card.uk-card-default.uk-card-body
    = form_with model: @profile_form,
                url: oauth_profile_completion_path,
                method: :patch do |f|

      - @required_fields.each do |field|
        .uk-margin
          = f.label field.field_name
          - if field.already_filled?
            = f.text_field field.field_name, class: "uk-input",
                           value: field.current_value, readonly: true
            .uk-text-meta.uk-text-success ✓ Already filled
          - else
            = f.text_field field.field_name, class: "uk-input"
            - if field.required?
              span.uk-text-danger *

      .uk-margin-top
        = f.submit "Confirm and Continue", class: "uk-button uk-button-primary"
```

## Controller: ProfileCompletionsController

```ruby
# app/controllers/oauth/profile_completions_controller.rb
module Oauth
  class ProfileCompletionsController < ApplicationController
    before_action :authenticate_user!
    before_action :load_oauth_application
    before_action :ensure_pending_authorization

    def show
      @required_fields = build_required_fields
      @profile_form = ProfileCompletionForm.new(current_user, @required_fields)
    end

    def update
      @profile_form = ProfileCompletionForm.new(current_user, @required_fields)

      if @profile_form.update(profile_params)
        # Resume authorization flow
        redirect_to oauth_authorization_path(session[:pending_authorization])
      else
        @required_fields = build_required_fields
        render :show, status: :unprocessable_entity
      end
    end

    private

    def load_oauth_application
      @oauth_application = OauthApplication.find(params[:oauth_application_id])
    end

    def ensure_pending_authorization
      unless session[:pending_authorization]
        redirect_to root_path, alert: "Authorization request not found"
      end
    end

    def build_required_fields
      @oauth_application.field_rules.where(rule: 'required').map do |field_rule|
        FieldPresenter.new(
          field_rule: field_rule,
          current_value: get_current_value(current_user, field_rule)
        )
      end
    end
  end
end
```

## Routes

```ruby
namespace :oauth do
  resource :profile_completion, only: [:show, :update]
end
```

## Doorkeeper Integration

Customize by inheriting from `Doorkeeper::AuthorizationsController` to hook into the authorization flow.

```ruby
# config/initializers/doorkeeper.rb
Doorkeeper.configure do
  # ...

  # Use custom authorization controller
  controllers authorizations: 'oauth/authorizations'
end
```

## Session Management

Store authorization params in session and restore after profile completion.

```ruby
# Store
session[:pending_authorization] = {
  client_id: params[:client_id],
  redirect_uri: params[:redirect_uri],
  response_type: params[:response_type],
  scope: params[:scope],
  state: params[:state],
  code_challenge: params[:code_challenge],
  code_challenge_method: params[:code_challenge_method]
}

# Resume
redirect_to oauth_authorization_path(session.delete(:pending_authorization))
```

## Validation

Dynamically apply validations based on field rules.

```ruby
class ProfileCompletionForm
  include ActiveModel::Model

  def initialize(user, required_fields)
    @user = user
    @required_fields = required_fields

    # Dynamically add validations
    required_fields.each do |field|
      if field.required? && !field.already_filled?
        validates field.field_name, presence: true
      end
    end
  end
end
```

## Edge Cases

### 1. User cancels profile completion

Allow returning to SP via "Cancel" button (treated as authorization denial).

```slim
= link_to "Cancel",
          oauth_authorization_path(session[:pending_authorization].merge(error: 'access_denied')),
          class: "uk-button uk-button-default"
```

### 2. Field becomes hidden after user filled it

Fields marked hidden later by tenant settings retain existing values but don't require new input.

### 3. Multiple applications with different requirements

When field_rules differ between applications, only check the rules for the current application during authorization.

## Related Documents

- `docs/spec/profile_field_rules.md` - Tenant-level field rules specification
- `.claude/todos/grant-types-per-application/TASK.md` - Grant Types implementation task
