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
        citext id PK "テナントID"
        string name "テナント名"
        string domain "ドメイン"
        boolean sms_verification_required "SMS認証必須フラグ"
        string card_payment_gateway "カード決済ゲートウェイ"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    users {
        uuid id PK "ユーザーID"
        citext tenant_id FK "テナントID"
        string email "メールアドレス"
        string password_digest "パスワードハッシュ"
        boolean enabled "有効フラグ"
        string phone_number "電話番号"
        boolean sms_verified "SMS認証済みフラグ"
        boolean email_verified "メール認証済みフラグ"
        boolean suppress_sms_verification "SMS認証スキップフラグ"
        boolean deleted "削除フラグ"
        datetime deleted_at "削除日時"
        string password_reset_code "パスワードリセットコード"
        float captcha_score "Captchaスコア"
        string payment_provider "決済プロバイダ"
        string payment_customer_id "決済顧客ID"
        string default_payment_method "デフォルト支払い方法"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    user_profiles {
        uuid id PK "プロフィールID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        string first_name "名"
        string last_name "姓"
        string first_name_kana "名（カナ）"
        string last_name_kana "姓（カナ）"
        date birth_date "生年月日"
        string gender "性別"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    admins {
        uuid id PK "管理者ID"
        citext tenant_id FK "テナントID"
        string name "管理者名"
        string email "メールアドレス"
        string uid "ユーザー識別子"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    rulers {
        uuid id PK "統括管理者ID"
        string name "管理者名"
        string email "メールアドレス"
        string uid "ユーザー識別子"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    oauth_applications {
        uuid id PK "アプリケーションID"
        citext tenant_id FK "テナントID"
        string name "アプリケーション名"
        string uid "クライアントID"
        string secret "クライアントシークレット"
        text redirect_uri "リダイレクトURI"
        string scopes "スコープ"
        boolean confidential "機密クライアントフラグ"
        boolean enable_client_credential_flow "クライアントクレデンシャルフロー有効化"
        boolean enable_push_event "プッシュイベント有効化"
        boolean require_sms_mfa "SMS多要素認証必須"
        text allowed_logout_urls "許可されたログアウトURL"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    oauth_access_grants {
        uuid id PK "認可コードID"
        citext tenant_id FK "テナントID"
        uuid resource_owner_id FK "リソースオーナーID（ユーザーID）"
        uuid application_id FK "アプリケーションID"
        string token "認可コード"
        integer expires_in "有効期限（秒）"
        text redirect_uri "リダイレクトURI"
        datetime created_at "作成日時"
        datetime revoked_at "無効化日時"
        string scopes "スコープ"
        string code_challenge "PKCEコードチャレンジ"
        string code_challenge_method "PKCEチャレンジメソッド"
    }

    oauth_access_tokens {
        uuid id PK "アクセストークンID"
        citext tenant_id FK "テナントID"
        uuid resource_owner_id FK "リソースオーナーID（ユーザーID）"
        uuid application_id FK "アプリケーションID"
        string token "アクセストークン"
        string refresh_token "リフレッシュトークン"
        integer expires_in "有効期限（秒）"
        datetime revoked_at "無効化日時"
        datetime created_at "作成日時"
        string scopes "スコープ"
        string previous_refresh_token "前回のリフレッシュトークン"
    }

    oauth_openid_requests {
        uuid id PK "OpenIDリクエストID"
        uuid access_grant_id FK "認可コードID"
        string nonce "Nonce"
    }

    login_spa_applications {
        uuid id PK "ログインSPAアプリケーションID"
        citext tenant_id FK "テナントID"
        string name "アプリケーション名"
        string uid "クライアントID"
        string scopes "スコープ"
        boolean confidential "機密クライアントフラグ"
        string login_url "ログインURL"
        string sign_up_url "サインアップURL"
        string redirect_url_on_password_reset "パスワードリセット時のリダイレクトURL"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    memberships {
        uuid id PK "メンバーシップID"
        citext tenant_id FK "テナントID"
        uuid membership_group_id FK "メンバーシップグループID"
        string name "メンバーシップ識別子"
        string display_name "メンバーシップ名称"
        integer position "表示順序"
        integer tier "階級"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    membership_groups {
        uuid id PK "メンバーシップグループID"
        citext tenant_id FK "テナントID"
        string name "グループ名（英数字のみ）"
        string display_name "表示名"
        integer position "表示順序（段階の順番）"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    membership_plans {
        uuid id PK "プランID"
        citext tenant_id FK "テナントID"
        string name "プラン名"
        boolean recurrence "定期課金フラグ（true=サブスク/false=買い切り）"
        integer recurring_interval_count "更新サイクル数"
        string recurring_interval_unit "更新サイクル単位（day/week/month/year）"
        integer amount "請求金額"
        boolean is_active "有効フラグ"
        datetime enabled_at "有効化日時"
        datetime disabled_at "無効化日時"
        integer trial_period_days "トライアル期間（日）"
        string billing_anchor "締め基準（by_start_day/by_fixed_month_day）"
        integer anchor_day_of_month "締め日（1-31、月末=31）"
        integer position "表示順序"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    membership_plan_payment_methods {
        uuid id PK "支払い方法ID"
        citext tenant_id FK "テナントID"
        uuid membership_plan_id FK "プランID"
        string payment_type "支払い方法タイプ（credit_card/convenience/campaign_code/external_linkage）"
        boolean is_active "有効フラグ"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    membership_plan_payment_method_mappings {
        uuid id PK "支払い方法マッピングID"
        citext tenant_id FK "テナントID"
        uuid membership_plan_id FK "プランID"
        uuid membership_plan_payment_method_id FK "支払い方法ID"
        uuid priceable_id "価格オブジェクトID"
        string priceable_type "価格オブジェクトタイプ"
        integer amount "金額"
        string currency "通貨"
        boolean is_active "有効フラグ"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    membership_plan_components {
        uuid id PK "プラン構成要素ID"
        citext tenant_id FK "テナントID"
        uuid membership_plan_id FK "プランID"
        uuid membership_id FK "メンバーシップID"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    membership_contracts {
        uuid id PK "契約ID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        datetime expires_at "有効期限"
        boolean cancel_at_period_end "次回更新時に解約フラグ"
        string status "ステータス"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    membership_contract_terms {
        uuid id PK "契約条件ID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        uuid membership_contract_id FK "契約ID"
        uuid membership_plan_id FK "プランID"
        string status "ステータス"
        datetime start_at "開始日時"
        datetime end_at "終了日時"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    membership_users {
        uuid id PK "メンバーシップユーザーID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        uuid membership_id FK "メンバーシップID"
        uuid membership_group_id FK "メンバーシップグループID"
        uuid membership_contract_id FK "契約ID"
        datetime expires_at "メンバーシップの有効期限"
        string status "メンバーシップのステータス"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    membership_user_achievements {
        uuid id PK "アチーブメントID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        uuid membership_id FK "メンバーシップID"
        uuid membership_plan_id FK "プランID"
        date date "達成日"
        string achievement_type "アチーブメントタイプ"
        jsonb achievement_data "アチーブメント詳細データ"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    payment_subscriptions {
        uuid id PK "サブスクリプションID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        uuid membership_contract_id FK "契約ID"
        uuid subscribable_id "サブスクリプションオブジェクトID"
        string subscribable_type "サブスクリプションオブジェクトタイプ"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    payment_transactions {
        uuid id PK "取引ID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        uuid membership_contract_id FK "契約ID"
        string payment_type "支払い方法（credit_card/convenience/campaign_code/external_linkage）"
        string payment_provider "決済プロバイダ（stripe/komojuなど）"
        string external_id "外部システムのID"
        string phase "フェーズ（current/upcoming/closed）"
        datetime activated_at "有効化日時"
        datetime expires_at "有効期限"
        string status "ステータス"
        boolean recurrence "定期課金フラグ（true=サブスク/false=買い切り）"
        integer revision "リビジョン番号"
        integer paid_amount "支払い済み金額"
        uuid chargeable_id "決済情報ID"
        string chargeable_type "決済情報タイプ"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    contact_addresses {
        uuid id PK "連絡先住所ID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        string zip_code "郵便番号"
        integer prefecture_code "都道府県コード"
        string city "市区町村"
        string street "番地"
        string building "建物名"
        string phone_number "電話番号"
        string country_code "国コード"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    delivery_addresses {
        uuid id PK "配送先住所ID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        boolean is_default "デフォルト住所フラグ"
        string zip_code "郵便番号"
        integer prefecture_code "都道府県コード"
        string city "市区町村"
        string street "番地"
        string building "建物名"
        string phone_number "電話番号"
        string country_code "国コード"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    email_templates {
        uuid id PK "メールテンプレートID"
        citext tenant_id FK "テナントID"
        string name "テンプレート名"
        string template_type "テンプレートタイプ"
        string subject "件名"
        text body "本文"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    account_locks {
        uuid id PK "アカウントロックID"
        citext tenant_id FK "テナントID"
        string email "メールアドレス"
        integer failed_attempts "失敗回数"
        string unlock_token "ロック解除トークン"
        datetime lock_expired_at "ロック期限"
        datetime last_failed_at "最終失敗日時"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    tenant_settings {
        uuid id PK "テナント設定ID"
        citext tenant_id FK "テナントID"
        string google_cloud_service_account "GCPサービスアカウント"
        string google_cloud_project_id "GCPプロジェクトID"
        string recaptcha_enterprise_checkbox_site_key "reCAPTCHA Enterpriseチェックボックスサイトキー"
        string recaptcha_enterprise_score_based_site_key "reCAPTCHA Enterpriseスコアベースサイトキー"
        string twilio_verify_service_sid "Twilio Verify サービスSID"
        jsonb profile_field_rules "プロフィールフィールドルール"
        string sender_email "送信元メールアドレス"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    tenant_stripe_accounts {
        uuid id PK "テナントStripeアカウントID"
        citext tenant_id FK "テナントID"
        uuid stripe_account_id FK "StripeアカウントID"
        string charge_type "決済タイプ（Connect用）"
        decimal fee_rate "手数料率（Connect用）"
        string tax_rate_id "税率ID"
        string webhook_secret "Webhook署名検証用シークレット"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    users__email_verifiers {
        uuid id PK "メール検証ID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        string code "検証コード"
        datetime expired_at "有効期限"
        integer remaining_attempts "残り試行回数"
        string verifier_type "検証タイプ（registration/change_emailなど）"
        string email "検証対象メールアドレス"
        datetime used_at "使用日時"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    users__sms_verifiers {
        uuid id PK "SMS検証ID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        string code "検証コード"
        datetime expired_at "有効期限"
        integer remaining_attempts "残り試行回数"
        string verifier_type "検証タイプ"
        string phone_number "検証対象電話番号"
        datetime used_at "使用日時"
        string sms_sender "SMS送信者"
        string sms_sid "SMS SID"
        string ip_address "IPアドレス"
        string delivery_type "配信タイプ"
        boolean ignore_in_rate_limit "レートリミットカウント除外フラグ"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    users__password_resets {
        uuid id PK "パスワードリセットID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        string code "リセットコード"
        datetime expired_at "有効期限"
        datetime used_at "使用日時"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    users__linked_applications {
        uuid id PK "連携アプリケーションID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        uuid oauth_application_id FK "OAuthアプリケーションID"
        string scopes "スコープ"
        datetime last_linked_at "最終連携日時"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    shopify_record__multipass_stores {
        uuid id PK "ShopifyストアID"
        citext tenant_id FK "テナントID"
        string store_url "ストアURL"
        citext store_name "ストア名"
        string api_key "APIキー"
        string oauth_client_id "OAuthクライアントID"
        string scopes "スコープ"
        string multipass_secret "Multipassシークレット"
        string webhook_token "Webhookトークン"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    shopify_record__customers {
        uuid id PK "Shopify顧客ID"
        citext tenant_id FK "テナントID"
        uuid multipass_store_id FK "ShopifyストアID"
        citext store_name "ストア名"
        uuid user_id FK "ユーザーID"
        string remote_id "Shopify顧客ID（リモート）"
        citext email "メールアドレス"
        string tags "タグ"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    stripe_record_api_keys {
        uuid id PK "Stripe APIキーID"
        citext tenant_id FK "テナントID"
        string remote_id "Stripe APIキーID（リモート）"
        string display_name "表示名"
        string publishable_key "公開可能キー"
        string secret_key_encrypted "シークレットキー（暗号化）"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    stripe_record_accounts {
        uuid id PK "StripeアカウントID"
        citext tenant_id FK "テナントID"
        string remote_id "StripeアカウントID（リモート）"
        uuid api_key_id FK "APIキーID"
        uuid controlling_platform_id FK "制御プラットフォームID（Connect用）"
        string type "アカウントタイプ"
        string business_profile_name "ビジネスプロフィール名"
        string payments_statement_descriptor "明細書表記"
        string payments_statement_descriptor_kana "明細書表記（カナ）"
        string payments_statement_descriptor_kanji "明細書表記（漢字）"
        string display_name "表示名"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    stripe_record_products {
        uuid id PK "Stripe商品ID"
        citext tenant_id FK "テナントID"
        string remote_id "Stripe商品ID（リモート）"
        string name "商品名"
        boolean deleted "削除フラグ"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    stripe_record_prices {
        uuid id PK "Stripe価格ID"
        citext tenant_id FK "テナントID"
        uuid product_id FK "商品ID"
        string remote_id "Stripe価格ID（リモート）"
        string name "価格名"
        integer amount "金額"
        string interval "請求間隔"
        integer interval_count "請求間隔数"
        integer trial_period_days "トライアル期間（日）"
        boolean deleted "削除フラグ"
        integer position "表示順序"
        boolean displayed "表示フラグ"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    stripe_record_subscriptions {
        uuid id PK "StripeサブスクリプションID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        uuid product_id FK "商品ID"
        uuid price_id FK "価格ID"
        uuid pending_setup_intent_id FK "保留中のセットアップインテントID"
        integer amount "金額"
        integer tax "税額"
        string currency "通貨"
        boolean refunded "返金済みフラグ"
        string refund_reason "返金理由"
        datetime current_period_start "現在の請求期間開始日時"
        datetime current_period_end "現在の請求期間終了日時"
        integer trial_period_days "トライアル期間（日）"
        datetime trial_end "トライアル終了日時"
        datetime trial_start "トライアル開始日時"
        string remote_id "StripeサブスクリプションID（リモート）"
        string status "ステータス"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    stripe_record_subscription_items {
        uuid id PK "StripeサブスクリプションアイテムID"
        citext tenant_id FK "テナントID"
        uuid subscription_id FK "サブスクリプションID"
        uuid price_id FK "価格ID"
        string remote_id "StripeサブスクリプションアイテムID（リモート）"
        integer quantity "数量"
        jsonb billing_thresholds "請求しきい値"
        integer current_period_start "現在の期間開始（Unix時間）"
        integer current_period_end "現在の期間終了（Unix時間）"
        jsonb discounts "割引"
        jsonb metadata "メタデータ"
        jsonb tax_rates "税率"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    stripe_record_subscription_schedules {
        uuid id PK "StripeサブスクリプションスケジュールID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        uuid subscription_id FK "サブスクリプションID"
        string remote_id "StripeサブスクリプションスケジュールID（リモート）"
        string remote_customer "Stripe顧客ID（リモート）"
        string status "ステータス"
        jsonb phases "フェーズ"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    stripe_record_setup_intents {
        uuid id PK "Stripeセットアップインテント"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        string remote_id "StripeセットアップインテントID（リモート）"
        string client_secret "クライアントシークレット"
        string customer_id "Stripe顧客ID"
        string on_behalf_of_id "代理アカウントID"
        string payment_method_id "支払い方法ID"
        string status "ステータス"
        string usage "用途"
        datetime activated_at "有効化日時"
        uuid api_key_account_id FK "APIキーアカウントID"
        uuid connect_account_id FK "ConnectアカウントID"
        string charge_type "決済タイプ（Connect用）"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    stripe_record_payment_methods {
        uuid id PK "Stripe支払い方法ID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        uuid setup_intent_id FK "セットアップインテントID"
        string remote_id "Stripe支払い方法ID（リモート）"
        string type "支払い方法タイプ（cardなど）"
        jsonb billing_details "請求先情報"
        jsonb card "カード詳細情報"
        string customer_id "Stripe顧客ID"
        datetime detached_at "解除日時"
        uuid api_key_account_id FK "APIキーアカウントID"
        uuid connect_account_id FK "ConnectアカウントID"
        string charge_type "決済タイプ（Connect用）"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    stripe_record_invoices {
        uuid id PK "Stripe請求書ID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        uuid payment_source_id "支払い元ID"
        string payment_source_type "支払い元タイプ"
        string remote_id "Stripe請求書ID（リモート）"
        string status "ステータス（draft/open/paid/uncollectible/void）"
        string confirmation_secret "確認シークレット"
        string confirmation_secret_type "確認シークレットタイプ"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    stripe_record_payment_intents {
        uuid id PK "Stripe決済インテントID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        uuid invoice_id FK "請求書ID"
        uuid chargeable_id "課金対象ID"
        string chargeable_type "課金対象タイプ"
        uuid latest_charge_id FK "最新決済ID"
        string remote_id "Stripe決済インテントID（リモート）"
        string currency "通貨"
        integer amount "金額"
        string status "ステータス"
        string customer_id "Stripe顧客ID"
        string client_secret "クライアントシークレット"
        string confirmation_method "確認方法"
        string capture_method "キャプチャ方法"
        string payment_method_id "支払い方法ID"
        jsonb payment_method_configuration_details "支払い方法設定詳細"
        jsonb payment_method_options "支払い方法オプション"
        string cancellation_reason "キャンセル理由"
        string description "説明"
        jsonb metadata "メタデータ"
        jsonb next_action "次のアクション"
        string on_behalf_of_id "代理アカウントID"
        integer application_fee_amount "アプリケーション手数料"
        jsonb transfer_data "転送データ"
        string transfer_group "転送グループ"
        integer created "作成日時（Unix時間）"
        datetime canceled_at "キャンセル日時"
        uuid api_key_account_id FK "APIキーアカウントID"
        uuid connect_account_id FK "ConnectアカウントID"
        string charge_type "決済タイプ（Connect用）"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    stripe_record_charges {
        uuid id PK "Stripe決済ID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        uuid payment_intent_id FK "決済インテントID"
        string remote_id "Stripe決済ID（リモート）"
        integer amount "金額"
        integer amount_captured "キャプチャ済み金額"
        integer amount_refunded "返金済み金額"
        string application_id "アプリケーションID"
        string application_fee_id "アプリケーション手数料ID"
        integer application_fee_amount "アプリケーション手数料額"
        string balance_transaction_id "残高取引ID"
        jsonb billing_details "請求先情報"
        string calculated_statement_descriptor "計算された明細書表記"
        boolean captured "キャプチャ済みフラグ"
        string currency "通貨"
        string customer_id "Stripe顧客ID"
        string description "説明"
        string destination "送金先"
        jsonb dispute "紛争情報"
        boolean disputed "紛争中フラグ"
        string failure_balance_transaction_id "失敗時残高取引ID"
        string failure_code "失敗コード"
        string failure_message "失敗メッセージ"
        jsonb fraud_details "不正利用詳細"
        string invoice_id "請求書ID"
        boolean livemode "本番モードフラグ"
        jsonb metadata "メタデータ"
        string on_behalf_of_id "代理アカウントID"
        string order "注文ID"
        jsonb outcome "結果"
        boolean paid "支払い済みフラグ"
        string payment_method "支払い方法"
        jsonb payment_method_details "支払い方法詳細"
        jsonb radar_options "Radarオプション"
        string receipt_email "領収書メールアドレス"
        string receipt_number "領収書番号"
        string receipt_url "領収書URL"
        boolean refunded "返金済みフラグ"
        string review_id "レビューID"
        jsonb shipping "配送情報"
        string source "決済元"
        string source_transfer_id "元転送ID"
        string statement_descriptor "明細書表記"
        string statement_descriptor_suffix "明細書表記サフィックス"
        string status "ステータス"
        string transfer_id "転送ID"
        jsonb transfer_data "転送データ"
        string transfer_group "転送グループ"
        integer created "作成日時（Unix時間）"
        uuid api_key_account_id FK "APIキーアカウントID"
        uuid connect_account_id FK "ConnectアカウントID"
        string charge_type "決済タイプ（Connect用）"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    stripe_record_refunds {
        uuid id PK "Stripe返金ID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        uuid payment_intent_id FK "決済インテントID"
        string remote_id "Stripe返金ID（リモート）"
        integer amount "返金金額"
        string balance_transaction_id "残高取引ID"
        string currency "通貨"
        jsonb destination_details "返金先詳細"
        jsonb metadata "メタデータ"
        string reason "返金理由"
        string receipt_number "領収書番号"
        string source_transfer_reversal_id "元転送取消ID"
        string status "ステータス"
        string transfer_reversal_id "転送取消ID"
        integer created "作成日時（Unix時間）"
        uuid api_key_account_id FK "APIキーアカウントID"
        uuid connect_account_id FK "ConnectアカウントID"
        string charge_type "決済タイプ（Connect用）"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }

    stripe_record_trial_histories {
        uuid id PK "Stripeトライアル履歴ID"
        citext tenant_id FK "テナントID"
        uuid user_id FK "ユーザーID"
        uuid membership_id FK "メンバーシップID"
        uuid membership_plan_id FK "プランID"
        uuid stripe_record_subscription_id FK "StripeサブスクリプションID"
        string fingerprint "決済手段フィンガープリント"
        datetime trial_start "トライアル開始日時"
        datetime trial_end "トライアル終了日時"
        integer trial_period_days "トライアル期間（日）"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
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
