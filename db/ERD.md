# ER図

このドキュメントは、auth-platformのデータベーススキーマをMermaidのER図で表現しています。

## ER図

```mermaid
erDiagram
    tenants ||--o{ users : has
    tenants ||--o{ admins : has
    tenants ||--o{ oauth_applications : has
    tenants ||--o{ login_spa_applications : has
    tenants ||--o{ memberships : has
    tenants ||--o{ membership_groups : has
    tenants ||--o{ membership_plans : has
    tenants ||--|| tenant_settings : has
    tenants ||--|| tenant_stripe_accounts : has
    tenants ||--o{ email_templates : has
    tenants ||--o{ account_locks : has

    users ||--o| user_profiles : has
    users ||--o{ contact_addresses : has
    users ||--o{ delivery_addresses : has
    users ||--o{ oauth_access_grants : has
    users ||--o{ oauth_access_tokens : has
    users ||--o{ users__email_verifiers : has
    users ||--o{ users__sms_verifiers : has
    users ||--o{ users__password_resets : has
    users ||--o{ users__linked_applications : has
    users ||--o{ membership_users : has
    users ||--o{ membership_contracts : has
    users ||--o{ membership_user_achievements : has
    users ||--o{ payment_subscriptions : has
    users ||--o{ payment_transactions : has
    users ||--o{ shopify_record__customers : has
    users ||--o{ stripe_record_charges : has
    users ||--o{ stripe_record_invoices : has
    users ||--o{ stripe_record_payment_intents : has
    users ||--o{ stripe_record_payment_methods : has
    users ||--o{ stripe_record_refunds : has
    users ||--o{ stripe_record_setup_intents : has
    users ||--o{ stripe_record_subscriptions : has
    users ||--o{ stripe_record_subscription_schedules : has
    users ||--o{ stripe_record_trial_histories : has

    oauth_applications ||--o{ oauth_access_grants : has
    oauth_applications ||--o{ oauth_access_tokens : has
    oauth_applications ||--o{ users__linked_applications : has

    oauth_access_grants ||--o| oauth_openid_requests : has

    memberships ||--o{ membership_users : has
    memberships ||--o{ membership_plan_components : has
    memberships ||--o{ membership_user_achievements : has
    memberships ||--o{ stripe_record_trial_histories : has
    memberships }o--|| membership_groups : belongs_to

    membership_groups ||--o{ memberships : has
    membership_groups ||--o{ membership_users : has

    membership_plans ||--o{ membership_plan_payment_methods : has
    membership_plans ||--o{ membership_plan_payment_method_mappings : has
    membership_plans ||--o{ membership_plan_components : has
    membership_plans ||--o{ membership_contract_terms : has
    membership_plans ||--o{ membership_user_achievements : has
    membership_plans ||--o{ stripe_record_trial_histories : has

    membership_plan_payment_methods ||--o{ membership_plan_payment_method_mappings : has

    membership_contracts ||--o{ membership_contract_terms : has
    membership_contracts ||--o{ membership_users : has
    membership_contracts ||--o{ payment_subscriptions : has
    membership_contracts ||--o{ payment_transactions : has

    payment_transactions }o--|| membership_contracts : belongs_to
    payment_subscriptions }o--|| membership_contracts : belongs_to

    stripe_record_api_keys ||--o{ stripe_record_accounts : has

    stripe_record_accounts ||--o{ stripe_record_accounts : controls
    stripe_record_accounts ||--o{ tenant_stripe_accounts : has
    stripe_record_accounts ||--o{ stripe_record_charges : api_key_account
    stripe_record_accounts ||--o{ stripe_record_charges : connect_account
    stripe_record_accounts ||--o{ stripe_record_payment_intents : api_key_account
    stripe_record_accounts ||--o{ stripe_record_payment_intents : connect_account
    stripe_record_accounts ||--o{ stripe_record_payment_methods : api_key_account
    stripe_record_accounts ||--o{ stripe_record_payment_methods : connect_account
    stripe_record_accounts ||--o{ stripe_record_refunds : api_key_account
    stripe_record_accounts ||--o{ stripe_record_refunds : connect_account
    stripe_record_accounts ||--o{ stripe_record_setup_intents : api_key_account
    stripe_record_accounts ||--o{ stripe_record_setup_intents : connect_account

    stripe_record_payment_intents ||--o{ stripe_record_charges : has
    stripe_record_payment_intents ||--o{ stripe_record_refunds : has
    stripe_record_payment_intents }o--|| stripe_record_invoices : belongs_to

    stripe_record_setup_intents ||--o{ stripe_record_payment_methods : has
    stripe_record_setup_intents ||--o{ stripe_record_subscriptions : pending

    stripe_record_products ||--o{ stripe_record_prices : has
    stripe_record_products ||--o{ stripe_record_subscriptions : has

    stripe_record_prices ||--o{ stripe_record_subscriptions : has
    stripe_record_prices ||--o{ stripe_record_subscription_items : has

    stripe_record_subscriptions ||--o{ stripe_record_subscription_items : has
    stripe_record_subscriptions ||--o{ stripe_record_subscription_schedules : has
    stripe_record_subscriptions ||--o{ stripe_record_trial_histories : has

    shopify_record__multipass_stores ||--o{ shopify_record__customers : has

    tenants {
        citext id PK
        string name
        string domain
        boolean sms_verification_required
        string card_payment_gateway
        datetime created_at
        datetime updated_at
    }

    users {
        uuid id PK
        citext tenant_id FK
        string email
        string password_digest
        boolean enabled
        string phone_number
        boolean sms_verified
        boolean email_verified
        boolean suppress_sms_verification
        boolean deleted
        datetime deleted_at
        string password_reset_code
        float captcha_score
        string payment_provider
        string payment_customer_id
        string default_payment_method
        datetime created_at
        datetime updated_at
    }

    user_profiles {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        string first_name
        string last_name
        string first_name_kana
        string last_name_kana
        date birth_date
        string gender
        datetime created_at
        datetime updated_at
    }

    admins {
        uuid id PK
        citext tenant_id FK
        string name
        string email
        string uid
        datetime created_at
        datetime updated_at
    }

    rulers {
        uuid id PK
        string name
        string email
        string uid
        datetime created_at
        datetime updated_at
    }

    oauth_applications {
        uuid id PK
        citext tenant_id FK
        string name
        string uid
        string secret
        text redirect_uri
        string scopes
        boolean confidential
        boolean enable_client_credential_flow
        boolean enable_push_event
        boolean require_sms_mfa
        text allowed_logout_urls
        datetime created_at
        datetime updated_at
    }

    oauth_access_grants {
        uuid id PK
        citext tenant_id FK
        uuid resource_owner_id FK
        uuid application_id FK
        string token
        integer expires_in
        text redirect_uri
        datetime created_at
        datetime revoked_at
        string scopes
        string code_challenge
        string code_challenge_method
    }

    oauth_access_tokens {
        uuid id PK
        citext tenant_id FK
        uuid resource_owner_id FK
        uuid application_id FK
        string token
        string refresh_token
        integer expires_in
        datetime revoked_at
        datetime created_at
        string scopes
        string previous_refresh_token
    }

    oauth_openid_requests {
        uuid id PK
        uuid access_grant_id FK
        string nonce
    }

    login_spa_applications {
        uuid id PK
        citext tenant_id FK
        string name
        string uid
        string scopes
        boolean confidential
        string login_url
        string sign_up_url
        string redirect_url_on_password_reset
        datetime created_at
        datetime updated_at
    }

    memberships {
        uuid id PK
        citext tenant_id FK
        uuid membership_group_id FK
        string name
        string display_name
        integer position
        integer tier
        datetime created_at
        datetime updated_at
    }

    membership_groups {
        uuid id PK
        citext tenant_id FK
        string name
        string display_name
        integer position
        datetime created_at
        datetime updated_at
    }

    membership_plans {
        uuid id PK
        citext tenant_id FK
        string name
        boolean recurrence
        integer recurring_interval_count
        string recurring_interval_unit
        integer amount
        boolean is_active
        datetime enabled_at
        datetime disabled_at
        integer trial_period_days
        string billing_anchor
        integer anchor_day_of_month
        integer position
        datetime created_at
        datetime updated_at
    }

    membership_plan_payment_methods {
        uuid id PK
        citext tenant_id FK
        uuid membership_plan_id FK
        string payment_type
        boolean is_active
        datetime created_at
        datetime updated_at
    }

    membership_plan_payment_method_mappings {
        uuid id PK
        citext tenant_id FK
        uuid membership_plan_id FK
        uuid membership_plan_payment_method_id FK
        uuid priceable_id
        string priceable_type
        integer amount
        string currency
        boolean is_active
        datetime created_at
        datetime updated_at
    }

    membership_plan_components {
        uuid id PK
        citext tenant_id FK
        uuid membership_plan_id FK
        uuid membership_id FK
        datetime created_at
        datetime updated_at
    }

    membership_contracts {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        datetime expires_at
        boolean cancel_at_period_end
        string status
        datetime created_at
        datetime updated_at
    }

    membership_contract_terms {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        uuid membership_contract_id FK
        uuid membership_plan_id FK
        string status
        datetime start_at
        datetime end_at
        datetime created_at
        datetime updated_at
    }

    membership_users {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        uuid membership_id FK
        uuid membership_group_id FK
        uuid membership_contract_id FK
        datetime expires_at
        string status
        datetime created_at
        datetime updated_at
    }

    membership_user_achievements {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        uuid membership_id FK
        uuid membership_plan_id FK
        date date
        string achievement_type
        jsonb achievement_data
        datetime created_at
        datetime updated_at
    }

    payment_subscriptions {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        uuid membership_contract_id FK
        uuid subscribable_id
        string subscribable_type
        datetime created_at
        datetime updated_at
    }

    payment_transactions {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        uuid membership_contract_id FK
        string payment_type
        string payment_provider
        string external_id
        string phase
        datetime activated_at
        datetime expires_at
        string status
        boolean recurrence
        integer revision
        integer paid_amount
        uuid chargeable_id
        string chargeable_type
        datetime created_at
        datetime updated_at
    }

    contact_addresses {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        string zip_code
        integer prefecture_code
        string city
        string street
        string building
        string phone_number
        string country_code
        datetime created_at
        datetime updated_at
    }

    delivery_addresses {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        boolean is_default
        string zip_code
        integer prefecture_code
        string city
        string street
        string building
        string phone_number
        string country_code
        datetime created_at
        datetime updated_at
    }

    email_templates {
        uuid id PK
        citext tenant_id FK
        string name
        string template_type
        string subject
        text body
        datetime created_at
        datetime updated_at
    }

    account_locks {
        uuid id PK
        citext tenant_id FK
        string email
        integer failed_attempts
        string unlock_token
        datetime lock_expired_at
        datetime last_failed_at
        datetime created_at
        datetime updated_at
    }

    tenant_settings {
        uuid id PK
        citext tenant_id FK
        string google_cloud_service_account
        string google_cloud_project_id
        string recaptcha_enterprise_checkbox_site_key
        string recaptcha_enterprise_score_based_site_key
        string twilio_verify_service_sid
        jsonb profile_field_rules
        string sender_email
        datetime created_at
        datetime updated_at
    }

    tenant_stripe_accounts {
        uuid id PK
        citext tenant_id FK
        uuid stripe_account_id FK
        string charge_type
        decimal fee_rate
        string tax_rate_id
        string webhook_secret
        datetime created_at
        datetime updated_at
    }

    users__email_verifiers {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        string code
        datetime expired_at
        integer remaining_attempts
        string verifier_type
        string email
        datetime used_at
        datetime created_at
        datetime updated_at
    }

    users__sms_verifiers {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        string code
        datetime expired_at
        integer remaining_attempts
        string verifier_type
        string phone_number
        datetime used_at
        string sms_sender
        string sms_sid
        string ip_address
        string delivery_type
        boolean ignore_in_rate_limit
        datetime created_at
        datetime updated_at
    }

    users__password_resets {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        string code
        datetime expired_at
        datetime used_at
        datetime created_at
        datetime updated_at
    }

    users__linked_applications {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        uuid oauth_application_id FK
        string scopes
        datetime last_linked_at
        datetime created_at
        datetime updated_at
    }

    shopify_record__multipass_stores {
        uuid id PK
        citext tenant_id FK
        string store_url
        citext store_name
        string api_key
        string oauth_client_id
        string scopes
        string multipass_secret
        string webhook_token
        datetime created_at
        datetime updated_at
    }

    shopify_record__customers {
        uuid id PK
        citext tenant_id FK
        uuid multipass_store_id FK
        citext store_name
        uuid user_id FK
        string remote_id
        citext email
        string tags
        datetime created_at
        datetime updated_at
    }

    stripe_record_api_keys {
        uuid id PK
        citext tenant_id FK
        string remote_id
        string display_name
        string publishable_key
        string secret_key_encrypted
        datetime created_at
        datetime updated_at
    }

    stripe_record_accounts {
        uuid id PK
        citext tenant_id FK
        string remote_id
        uuid api_key_id FK
        uuid controlling_platform_id FK
        string type
        string business_profile_name
        string payments_statement_descriptor
        string payments_statement_descriptor_kana
        string payments_statement_descriptor_kanji
        string display_name
        datetime created_at
        datetime updated_at
    }

    stripe_record_products {
        uuid id PK
        citext tenant_id FK
        string remote_id
        string name
        boolean deleted
        datetime created_at
        datetime updated_at
    }

    stripe_record_prices {
        uuid id PK
        citext tenant_id FK
        uuid product_id FK
        string remote_id
        string name
        integer amount
        string interval
        integer interval_count
        integer trial_period_days
        boolean deleted
        integer position
        boolean displayed
        datetime created_at
        datetime updated_at
    }

    stripe_record_subscriptions {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        uuid product_id FK
        uuid price_id FK
        uuid pending_setup_intent_id FK
        integer amount
        integer tax
        string currency
        boolean refunded
        string refund_reason
        datetime current_period_start
        datetime current_period_end
        integer trial_period_days
        datetime trial_end
        datetime trial_start
        string remote_id
        string status
        datetime created_at
        datetime updated_at
    }

    stripe_record_subscription_items {
        uuid id PK
        citext tenant_id FK
        uuid subscription_id FK
        uuid price_id FK
        string remote_id
        integer quantity
        jsonb billing_thresholds
        integer current_period_start
        integer current_period_end
        jsonb discounts
        jsonb metadata
        jsonb tax_rates
        datetime created_at
        datetime updated_at
    }

    stripe_record_subscription_schedules {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        uuid subscription_id FK
        string remote_id
        string remote_customer
        string status
        jsonb phases
        datetime created_at
        datetime updated_at
    }

    stripe_record_setup_intents {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        string remote_id
        string client_secret
        string customer_id
        string on_behalf_of_id
        string payment_method_id
        string status
        string usage
        datetime activated_at
        uuid api_key_account_id FK
        uuid connect_account_id FK
        string charge_type
        datetime created_at
        datetime updated_at
    }

    stripe_record_payment_methods {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        uuid setup_intent_id FK
        string remote_id
        string type
        jsonb billing_details
        jsonb card
        string customer_id
        datetime detached_at
        uuid api_key_account_id FK
        uuid connect_account_id FK
        string charge_type
        datetime created_at
        datetime updated_at
    }

    stripe_record_invoices {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        uuid payment_source_id
        string payment_source_type
        string remote_id
        string status
        string confirmation_secret
        string confirmation_secret_type
        datetime created_at
        datetime updated_at
    }

    stripe_record_payment_intents {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        uuid invoice_id FK
        uuid chargeable_id
        string chargeable_type
        uuid latest_charge_id FK
        string remote_id
        string currency
        integer amount
        string status
        string customer_id
        string client_secret
        string confirmation_method
        string capture_method
        string payment_method_id
        jsonb payment_method_configuration_details
        jsonb payment_method_options
        string cancellation_reason
        string description
        jsonb metadata
        jsonb next_action
        string on_behalf_of_id
        integer application_fee_amount
        jsonb transfer_data
        string transfer_group
        integer created
        datetime canceled_at
        uuid api_key_account_id FK
        uuid connect_account_id FK
        string charge_type
        datetime created_at
        datetime updated_at
    }

    stripe_record_charges {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        uuid payment_intent_id FK
        string remote_id
        integer amount
        integer amount_captured
        integer amount_refunded
        string application_id
        string application_fee_id
        integer application_fee_amount
        string balance_transaction_id
        jsonb billing_details
        string calculated_statement_descriptor
        boolean captured
        string currency
        string customer_id
        string description
        string destination
        jsonb dispute
        boolean disputed
        string failure_balance_transaction_id
        string failure_code
        string failure_message
        jsonb fraud_details
        string invoice_id
        boolean livemode
        jsonb metadata
        string on_behalf_of_id
        string order
        jsonb outcome
        boolean paid
        string payment_method
        jsonb payment_method_details
        jsonb radar_options
        string receipt_email
        string receipt_number
        string receipt_url
        boolean refunded
        string review_id
        jsonb shipping
        string source
        string source_transfer_id
        string statement_descriptor
        string statement_descriptor_suffix
        string status
        string transfer_id
        jsonb transfer_data
        string transfer_group
        integer created
        uuid api_key_account_id FK
        uuid connect_account_id FK
        string charge_type
        datetime created_at
        datetime updated_at
    }

    stripe_record_refunds {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        uuid payment_intent_id FK
        string remote_id
        integer amount
        string balance_transaction_id
        string currency
        jsonb destination_details
        jsonb metadata
        string reason
        string receipt_number
        string source_transfer_reversal_id
        string status
        string transfer_reversal_id
        integer created
        uuid api_key_account_id FK
        uuid connect_account_id FK
        string charge_type
        datetime created_at
        datetime updated_at
    }

    stripe_record_trial_histories {
        uuid id PK
        citext tenant_id FK
        uuid user_id FK
        uuid membership_id FK
        uuid membership_plan_id FK
        uuid stripe_record_subscription_id FK
        string fingerprint
        datetime trial_start
        datetime trial_end
        integer trial_period_days
        datetime created_at
        datetime updated_at
    }
```

## 主要なドメイン

### 1. テナント管理
- `tenants`: マルチテナントの基本テーブル
- `tenant_settings`: テナントごとの設定
- `tenant_stripe_accounts`: テナントのStripeアカウント情報

### 2. ユーザー管理
- `users`: ユーザーの基本情報
- `user_profiles`: ユーザープロフィール
- `admins`: 管理者
- `rulers`: 最高権限管理者

### 3. OAuth認証
- `oauth_applications`: OAuth2.0クライアントアプリケーション
- `oauth_access_tokens`: アクセストークン
- `oauth_access_grants`: 認可コード
- `oauth_openid_requests`: OpenID Connectリクエスト
- `login_spa_applications`: SPAログインアプリケーション

### 4. メンバーシップ
- `memberships`: メンバーシップ定義
- `membership_groups`: メンバーシップグループ（段階的プラン用）
- `membership_plans`: メンバーシップ契約プラン
- `membership_contracts`: ユーザーのメンバーシップ契約
- `membership_contract_terms`: 契約の詳細・変更履歴
- `membership_users`: メンバーシップとユーザーの中間テーブル
- `membership_plan_payment_methods`: プランの支払い方法
- `membership_plan_payment_method_mappings`: 支払い方法のマッピング
- `membership_plan_components`: バンドルプランの構成要素
- `membership_user_achievements`: ユーザーのアチーブメント

### 5. 決済
- `payment_transactions`: 支払い取引情報
- `payment_subscriptions`: サブスクリプション情報

### 6. Stripe連携
- `stripe_record_api_keys`: Stripe APIキー
- `stripe_record_accounts`: Stripeアカウント（Connect対応）
- `stripe_record_products`: 商品
- `stripe_record_prices`: 価格
- `stripe_record_subscriptions`: サブスクリプション
- `stripe_record_subscription_items`: サブスクリプションアイテム
- `stripe_record_subscription_schedules`: サブスクリプションスケジュール
- `stripe_record_setup_intents`: セットアップインテント
- `stripe_record_payment_methods`: 支払い方法
- `stripe_record_payment_intents`: 決済インテント
- `stripe_record_charges`: 決済
- `stripe_record_refunds`: 返金
- `stripe_record_invoices`: 請求書
- `stripe_record_trial_histories`: トライアル履歴

### 7. Shopify連携
- `shopify_record__multipass_stores`: Shopifyストア情報
- `shopify_record__customers`: Shopify顧客情報

### 8. アカウントセキュリティ
- `account_locks`: アカウントロック
- `users__email_verifiers`: メール認証
- `users__sms_verifiers`: SMS認証
- `users__password_resets`: パスワードリセット
- `users__linked_applications`: 連携アプリケーション

### 9. その他
- `contact_addresses`: 連絡先住所
- `delivery_addresses`: 配送先住所
- `email_templates`: メールテンプレート

## 特徴

- **マルチテナント対応**: ほぼ全てのテーブルに`tenant_id`が含まれる
- **UUID使用**: 主キーはUUIDを使用（`tenants`テーブルのみcitext）
- **Stripe Connect対応**: `api_key_account_id`, `connect_account_id`, `charge_type`でプラットフォーム決済に対応
- **ポリモーフィック関連**: `chargeable`, `priceable`, `subscribable`などのポリモーフィック関連を使用
- **論理削除**: `users`テーブルに`deleted`, `deleted_at`カラムあり
