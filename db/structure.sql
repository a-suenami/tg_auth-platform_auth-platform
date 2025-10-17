\restrict 1EgMBrAZZaQHd6CgyfObOxx9cduScHz8RX9gNoq0bZStynd6dmny2ztsGhCbVDt

-- Dumped from database version 15.5
-- Dumped by pg_dump version 15.14 (Debian 15.14-1.pgdg12+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_locks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_locks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    email character varying NOT NULL,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    lock_expired_at timestamp(6) without time zone,
    last_failed_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admins (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    name character varying,
    email character varying,
    uid character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: contact_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contact_addresses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    zip_code character varying,
    prefecture_code integer,
    city character varying,
    street character varying,
    building character varying,
    phone_number character varying,
    country_code character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: delivery_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_addresses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    is_default boolean,
    zip_code character varying,
    prefecture_code integer,
    city character varying,
    street character varying,
    building character varying,
    phone_number character varying,
    country_code character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: email_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_templates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    name character varying NOT NULL,
    template_type character varying NOT NULL,
    subject character varying NOT NULL,
    body text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: login_spa_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.login_spa_applications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    confidential boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    login_url character varying NOT NULL,
    sign_up_url character varying,
    redirect_url_on_password_reset character varying NOT NULL
);


--
-- Name: membership_contract_terms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_contract_terms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    membership_contract_id uuid NOT NULL,
    membership_plan_id uuid NOT NULL,
    status character varying NOT NULL,
    start_at timestamp(6) without time zone,
    end_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE membership_contract_terms; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.membership_contract_terms IS 'ユーザーのメンバーシップ契約の詳細,変更履歴';


--
-- Name: COLUMN membership_contract_terms.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_contract_terms.status IS 'ステータス';


--
-- Name: COLUMN membership_contract_terms.start_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_contract_terms.start_at IS '開始日時';


--
-- Name: COLUMN membership_contract_terms.end_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_contract_terms.end_at IS '終了日時';


--
-- Name: membership_contracts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_contracts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    expires_at timestamp(6) without time zone,
    cancel_at_period_end boolean DEFAULT false,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE membership_contracts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.membership_contracts IS 'ユーザーのメンバーシップ契約';


--
-- Name: COLUMN membership_contracts.expires_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_contracts.expires_at IS '有効期限';


--
-- Name: COLUMN membership_contracts.cancel_at_period_end; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_contracts.cancel_at_period_end IS '次回更新時に解約フラグ';


--
-- Name: COLUMN membership_contracts.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_contracts.status IS 'ステータス';


--
-- Name: membership_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_groups (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    name character varying NOT NULL,
    display_name character varying NOT NULL,
    "position" integer DEFAULT 0,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE membership_groups; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.membership_groups IS 'メンバーシップグループ（段階的プラン用）';


--
-- Name: COLUMN membership_groups.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_groups.name IS 'グループ名（英数字のみ）';


--
-- Name: COLUMN membership_groups.display_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_groups.display_name IS '表示名';


--
-- Name: COLUMN membership_groups."position"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_groups."position" IS '表示順序（段階の順番）';


--
-- Name: membership_plan_components; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_plan_components (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    membership_plan_id uuid NOT NULL,
    membership_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE membership_plan_components; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.membership_plan_components IS 'メンバーシッププランの構成要素（バンドルプラン用）';


--
-- Name: membership_plan_payment_method_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_plan_payment_method_mappings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    membership_plan_id uuid NOT NULL,
    membership_plan_payment_method_id uuid NOT NULL,
    priceable_id uuid,
    priceable_type character varying,
    amount integer NOT NULL,
    currency character varying NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE membership_plan_payment_method_mappings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.membership_plan_payment_method_mappings IS 'メンバーシッププランの支払い方法のマッピング';


--
-- Name: COLUMN membership_plan_payment_method_mappings.priceable_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plan_payment_method_mappings.priceable_id IS 'Priceオブジェクト';


--
-- Name: COLUMN membership_plan_payment_method_mappings.amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plan_payment_method_mappings.amount IS '金額';


--
-- Name: COLUMN membership_plan_payment_method_mappings.currency; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plan_payment_method_mappings.currency IS '通貨';


--
-- Name: COLUMN membership_plan_payment_method_mappings.is_active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plan_payment_method_mappings.is_active IS '有効フラグ';


--
-- Name: membership_plan_payment_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_plan_payment_methods (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    membership_plan_id uuid NOT NULL,
    payment_type character varying NOT NULL,
    stripe_record_price_id uuid,
    is_active boolean DEFAULT true,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE membership_plan_payment_methods; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.membership_plan_payment_methods IS 'メンバーシッププランの支払い方法';


--
-- Name: COLUMN membership_plan_payment_methods.payment_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plan_payment_methods.payment_type IS '支払い方法: credit_card, convenience, campaign_code, external_linkage';


--
-- Name: COLUMN membership_plan_payment_methods.stripe_record_price_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plan_payment_methods.stripe_record_price_id IS 'Stripe価格ID';


--
-- Name: COLUMN membership_plan_payment_methods.is_active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plan_payment_methods.is_active IS '有効フラグ';


--
-- Name: membership_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_plans (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    name character varying NOT NULL,
    recurrence boolean DEFAULT false NOT NULL,
    recurring_interval_count integer DEFAULT 1 NOT NULL,
    recurring_interval_unit character varying DEFAULT 'month'::character varying NOT NULL,
    amount integer NOT NULL,
    is_active boolean DEFAULT true,
    enabled_at timestamp(6) without time zone,
    disabled_at timestamp(6) without time zone,
    trial_period_days integer DEFAULT 0 NOT NULL,
    billing_anchor character varying DEFAULT 'by_start_day'::character varying NOT NULL,
    anchor_day_of_month integer,
    "position" integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE membership_plans; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.membership_plans IS 'メンバーシップの契約プラン';


--
-- Name: COLUMN membership_plans.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plans.name IS 'プラン名';


--
-- Name: COLUMN membership_plans.recurrence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plans.recurrence IS '定期課金フラグ: true=サブスクリプション, false=買い切り';


--
-- Name: COLUMN membership_plans.recurring_interval_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plans.recurring_interval_count IS '更新サイクルの数(1=1日/週/月/年, 2=2日/週/月/年)';


--
-- Name: COLUMN membership_plans.recurring_interval_unit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plans.recurring_interval_unit IS '更新サイクルの単位 (day/week/month/year)';


--
-- Name: COLUMN membership_plans.amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plans.amount IS '請求金額';


--
-- Name: COLUMN membership_plans.is_active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plans.is_active IS '有効フラグ';


--
-- Name: COLUMN membership_plans.enabled_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plans.enabled_at IS '有効化日時';


--
-- Name: COLUMN membership_plans.disabled_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plans.disabled_at IS '無効化日時';


--
-- Name: COLUMN membership_plans.trial_period_days; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plans.trial_period_days IS 'トライアル期間';


--
-- Name: COLUMN membership_plans.billing_anchor; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plans.billing_anchor IS '締めの基準: by_start_day(登録日基準), by_fixed_month_day(毎月の特定日)';


--
-- Name: COLUMN membership_plans.anchor_day_of_month; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plans.anchor_day_of_month IS 'fixed_month_day時の締め日(1-31 月末指定時は31)。by_fixed_month_day時のみ使用';


--
-- Name: COLUMN membership_plans."position"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_plans."position" IS '表示順序';


--
-- Name: membership_user_achievements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_user_achievements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    membership_id uuid NOT NULL,
    membership_plan_id uuid NOT NULL,
    date date NOT NULL,
    achievement_type character varying NOT NULL,
    achievement_data jsonb DEFAULT '{}'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE membership_user_achievements; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.membership_user_achievements IS 'ユーザーのメンバーシップアチーブメント';


--
-- Name: COLUMN membership_user_achievements.date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_user_achievements.date IS '達成日';


--
-- Name: COLUMN membership_user_achievements.achievement_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_user_achievements.achievement_type IS 'アチーブメントタイプ';


--
-- Name: COLUMN membership_user_achievements.achievement_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_user_achievements.achievement_data IS 'アチーブメント詳細データ';


--
-- Name: membership_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    membership_id uuid NOT NULL,
    membership_group_id uuid,
    membership_contract_id uuid,
    expires_at timestamp(6) without time zone,
    status character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE membership_users; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.membership_users IS 'メンバーシップとUserの中間テーブル';


--
-- Name: COLUMN membership_users.membership_group_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_users.membership_group_id IS '段階的プランの場合のグループ';


--
-- Name: COLUMN membership_users.membership_contract_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_users.membership_contract_id IS 'メンバーシップ契約';


--
-- Name: COLUMN membership_users.expires_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_users.expires_at IS 'メンバーシップの有効期限';


--
-- Name: COLUMN membership_users.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_users.status IS 'メンバーシップのステータス';


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.memberships (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    membership_group_id uuid,
    name character varying,
    display_name character varying,
    "position" integer,
    tier integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE memberships; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.memberships IS 'メンバーシップ';


--
-- Name: COLUMN memberships.membership_group_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.memberships.membership_group_id IS 'メンバーシップグループ';


--
-- Name: COLUMN memberships.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.memberships.name IS 'メンバーシップ識別子';


--
-- Name: COLUMN memberships.display_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.memberships.display_name IS 'メンバーシップ名称';


--
-- Name: COLUMN memberships."position"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.memberships."position" IS '表示順序';


--
-- Name: COLUMN memberships.tier; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.memberships.tier IS '階級';


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_grants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    resource_owner_id uuid NOT NULL,
    application_id uuid NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    revoked_at timestamp(6) without time zone,
    scopes character varying,
    code_challenge character varying,
    code_challenge_method character varying
);


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    resource_owner_id uuid,
    application_id uuid NOT NULL,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    scopes character varying,
    previous_refresh_token character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_applications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    confidential boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    enable_client_credential_flow boolean DEFAULT false,
    enable_push_event boolean DEFAULT false,
    require_sms_mfa boolean DEFAULT false,
    allowed_logout_urls text
);


--
-- Name: oauth_openid_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_openid_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    access_grant_id uuid NOT NULL,
    nonce character varying NOT NULL
);


--
-- Name: payment__subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment__subscriptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    membership_contract_id uuid NOT NULL,
    subscribable_id uuid,
    subscribable_type character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE payment__subscriptions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.payment__subscriptions IS '支払い取引情報';


--
-- Name: COLUMN payment__subscriptions.membership_contract_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment__subscriptions.membership_contract_id IS 'メンバーシップ契約ID';


--
-- Name: COLUMN payment__subscriptions.subscribable_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment__subscriptions.subscribable_id IS 'サブスクリプションオブジェクト';


--
-- Name: payment__transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment__transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    membership_contract_id uuid NOT NULL,
    payment_type character varying NOT NULL,
    payment_provider character varying,
    external_id character varying,
    phase character varying DEFAULT 'current'::character varying NOT NULL,
    activated_at timestamp(6) without time zone,
    expires_at timestamp(6) without time zone,
    status character varying NOT NULL,
    recurrence boolean DEFAULT false NOT NULL,
    revision integer DEFAULT 1 NOT NULL,
    paid_amount integer DEFAULT 0 NOT NULL,
    chargeable_id uuid,
    chargeable_type character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE payment__transactions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.payment__transactions IS '支払い取引情報';


--
-- Name: COLUMN payment__transactions.membership_contract_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment__transactions.membership_contract_id IS 'メンバーシップ契約ID';


--
-- Name: COLUMN payment__transactions.payment_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment__transactions.payment_type IS '支払い方法: credit_card, convenience, campaign_code, external_linkage';


--
-- Name: COLUMN payment__transactions.payment_provider; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment__transactions.payment_provider IS '決済プロバイダ: stripe, komojuなど';


--
-- Name: COLUMN payment__transactions.external_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment__transactions.external_id IS '外部システムのID';


--
-- Name: COLUMN payment__transactions.phase; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment__transactions.phase IS 'phase: transactionの利用状態。プラン変更予定時はupcoming。current, upcoming, closed';


--
-- Name: COLUMN payment__transactions.activated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment__transactions.activated_at IS '有効化日時';


--
-- Name: COLUMN payment__transactions.expires_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment__transactions.expires_at IS '有効期限';


--
-- Name: COLUMN payment__transactions.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment__transactions.status IS 'ステータス';


--
-- Name: COLUMN payment__transactions.recurrence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment__transactions.recurrence IS '定期課金フラグ: true=サブスクリプション, false=買い切り';


--
-- Name: COLUMN payment__transactions.revision; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment__transactions.revision IS 'バージョン管理用';


--
-- Name: COLUMN payment__transactions.paid_amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment__transactions.paid_amount IS '支払い済み金額';


--
-- Name: COLUMN payment__transactions.chargeable_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment__transactions.chargeable_id IS '決済情報';


--
-- Name: rulers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rulers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying,
    email character varying,
    uid character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: shopify_record__customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shopify_record__customers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    multipass_store_id uuid,
    store_name public.citext,
    user_id uuid NOT NULL,
    remote_id character varying NOT NULL,
    email public.citext NOT NULL,
    tags character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: shopify_record__multipass_stores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shopify_record__multipass_stores (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    store_url character varying,
    store_name public.citext,
    api_key character varying,
    oauth_client_id character varying,
    scopes character varying,
    multipass_secret character varying,
    webhook_token character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: stripe_record__accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record__accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    remote_id character varying NOT NULL,
    tenant_id public.citext NOT NULL,
    api_key_id uuid,
    controlling_platform_id uuid,
    type character varying,
    business_profile_name character varying,
    payments_statement_descriptor character varying,
    payments_statement_descriptor_kana character varying,
    payments_statement_descriptor_kanji character varying,
    display_name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN stripe_record__accounts.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__accounts.remote_id IS 'Stripe のアカウント ID';


--
-- Name: COLUMN stripe_record__accounts.display_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__accounts.display_name IS 'API キーがどのアカウントのものかを識別するための名前';


--
-- Name: stripe_record__api_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record__api_keys (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    remote_id character varying NOT NULL,
    display_name character varying NOT NULL,
    publishable_key character varying NOT NULL,
    secret_key_encrypted character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN stripe_record__api_keys.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__api_keys.remote_id IS 'Stripe の API キー ID';


--
-- Name: COLUMN stripe_record__api_keys.display_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__api_keys.display_name IS 'API キーがどのアカウントのものかを識別するための名前';


--
-- Name: stripe_record__charges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record__charges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    remote_id character varying NOT NULL,
    payment_intent_id uuid NOT NULL,
    user_id uuid NOT NULL,
    amount integer,
    amount_captured integer,
    amount_refunded integer,
    application_id character varying,
    application_fee_id character varying,
    application_fee_amount integer,
    balance_transaction_id character varying,
    billing_details jsonb,
    calculated_statement_descriptor character varying,
    captured boolean,
    currency character varying,
    customer_id character varying,
    description character varying,
    destination character varying,
    dispute jsonb,
    disputed boolean,
    failure_balance_transaction_id character varying,
    failure_code character varying,
    failure_message character varying,
    fraud_details jsonb,
    invoice_id character varying,
    livemode boolean,
    metadata jsonb,
    on_behalf_of_id character varying,
    "order" character varying,
    outcome jsonb,
    paid boolean,
    payment_method character varying,
    payment_method_details jsonb,
    radar_options jsonb,
    receipt_email character varying,
    receipt_number character varying,
    receipt_url character varying,
    refunded boolean,
    review_id character varying,
    shipping jsonb,
    source character varying,
    source_transfer_id character varying,
    statement_descriptor character varying,
    statement_descriptor_suffix character varying,
    status character varying,
    transfer_id character varying,
    transfer_data jsonb,
    transfer_group character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    created integer,
    api_key_account_id uuid NOT NULL,
    connect_account_id uuid,
    charge_type character varying
);


--
-- Name: COLUMN stripe_record__charges.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__charges.remote_id IS 'Stripe の charge ID';


--
-- Name: COLUMN stripe_record__charges.api_key_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__charges.api_key_account_id IS 'API Key を持っているアカウント。通常の決済であればその決済のアカウントとなる。Connect の場合はプラットフォームアカウントになる。';


--
-- Name: COLUMN stripe_record__charges.connect_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__charges.connect_account_id IS 'Connect のときだけ使用する。この決済がどの Connected アカウントに対する支払いなのかを表す。';


--
-- Name: COLUMN stripe_record__charges.charge_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__charges.charge_type IS 'Connect のときだけ使用する。どの支払いタイプなのかを表す';


--
-- Name: stripe_record__invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record__invoices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    remote_id character varying NOT NULL,
    user_id uuid NOT NULL,
    payment_source_id uuid,
    payment_source_type character varying,
    status character varying DEFAULT 'draft'::character varying NOT NULL,
    confirmation_secret character varying,
    confirmation_secret_type character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN stripe_record__invoices.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__invoices.remote_id IS 'Stripe の invoices ID';


--
-- Name: COLUMN stripe_record__invoices.payment_source_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__invoices.payment_source_id IS 'subscription or charge';


--
-- Name: COLUMN stripe_record__invoices.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__invoices.status IS 'draft, open, paid, uncollectible, or void';


--
-- Name: COLUMN stripe_record__invoices.confirmation_secret; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__invoices.confirmation_secret IS 'confirmation_secret payment_intent.secret';


--
-- Name: COLUMN stripe_record__invoices.confirmation_secret_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__invoices.confirmation_secret_type IS '基本的にはpayment_intentのみ';


--
-- Name: stripe_record__payment_intents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record__payment_intents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    remote_id character varying NOT NULL,
    user_id uuid NOT NULL,
    invoice_id uuid,
    chargeable_id uuid,
    chargeable_type character varying,
    latest_charge_id uuid,
    currency character varying,
    amount integer,
    status character varying,
    customer_id character varying,
    client_secret character varying,
    confirmation_method character varying,
    capture_method character varying,
    payment_method_id character varying,
    payment_method_configuration_details jsonb,
    payment_method_options jsonb,
    cancellation_reason character varying,
    description character varying,
    metadata jsonb,
    next_action jsonb,
    on_behalf_of_id character varying,
    application_fee_amount integer,
    transfer_data jsonb,
    transfer_group character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    created integer,
    canceled_at timestamp(6) without time zone,
    api_key_account_id uuid NOT NULL,
    connect_account_id uuid,
    charge_type character varying
);


--
-- Name: COLUMN stripe_record__payment_intents.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__payment_intents.remote_id IS 'Stripe の payment intent ID';


--
-- Name: COLUMN stripe_record__payment_intents.chargeable_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__payment_intents.chargeable_id IS 'subscription or charge';


--
-- Name: COLUMN stripe_record__payment_intents.latest_charge_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__payment_intents.latest_charge_id IS 'latest charge';


--
-- Name: COLUMN stripe_record__payment_intents.api_key_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__payment_intents.api_key_account_id IS 'API Key を持っているアカウント。通常の決済であればその決済のアカウントとなる。Connect の場合はプラットフォームアカウントになる。';


--
-- Name: COLUMN stripe_record__payment_intents.connect_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__payment_intents.connect_account_id IS 'Connect のときだけ使用する。この決済がどの Connected アカウントに対する支払いなのかを表す。';


--
-- Name: COLUMN stripe_record__payment_intents.charge_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__payment_intents.charge_type IS 'Connect のときだけ使用する。どの支払いタイプなのかを表す';


--
-- Name: stripe_record__payment_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record__payment_methods (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    remote_id character varying NOT NULL,
    user_id uuid NOT NULL,
    setup_intent_id uuid,
    type character varying NOT NULL,
    billing_details jsonb DEFAULT '{}'::jsonb,
    card jsonb DEFAULT '{}'::jsonb,
    customer_id character varying NOT NULL,
    detached_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    api_key_account_id uuid NOT NULL,
    connect_account_id uuid,
    charge_type character varying
);


--
-- Name: COLUMN stripe_record__payment_methods.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__payment_methods.remote_id IS 'Stripe の payment method ID';


--
-- Name: COLUMN stripe_record__payment_methods.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__payment_methods.type IS 'payment method の種類。card など';


--
-- Name: COLUMN stripe_record__payment_methods.billing_details; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__payment_methods.billing_details IS '請求先情報';


--
-- Name: COLUMN stripe_record__payment_methods.card; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__payment_methods.card IS 'card の詳細情報';


--
-- Name: COLUMN stripe_record__payment_methods.customer_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__payment_methods.customer_id IS 'この PaymentMethod の持ち主の customer ID';


--
-- Name: COLUMN stripe_record__payment_methods.detached_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__payment_methods.detached_at IS 'detach された日時';


--
-- Name: COLUMN stripe_record__payment_methods.api_key_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__payment_methods.api_key_account_id IS 'API Key を持っているアカウント。通常の決済であればその決済のアカウントとなる。Connect の場合はプラットフォームアカウントになる。';


--
-- Name: COLUMN stripe_record__payment_methods.connect_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__payment_methods.connect_account_id IS 'Connect のときだけ使用する。この決済がどの Connected アカウントに対する支払いなのかを表す。';


--
-- Name: COLUMN stripe_record__payment_methods.charge_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__payment_methods.charge_type IS 'Connect のときだけ使用する。どの支払いタイプなのかを表す';


--
-- Name: stripe_record__prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record__prices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    product_id uuid NOT NULL,
    remote_id character varying,
    name character varying,
    amount integer,
    "interval" character varying,
    interval_count integer,
    trial_period_days integer,
    deleted boolean DEFAULT false NOT NULL,
    "position" integer DEFAULT 1000,
    displayed boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: stripe_record__products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record__products (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    remote_id character varying,
    name character varying,
    deleted boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: stripe_record__refunds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record__refunds (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    remote_id character varying NOT NULL,
    user_id uuid NOT NULL,
    payment_intent_id uuid NOT NULL,
    amount integer,
    balance_transaction_id character varying,
    currency character varying,
    destination_details jsonb,
    metadata jsonb,
    reason character varying,
    receipt_number character varying,
    source_transfer_reversal_id character varying,
    status character varying,
    transfer_reversal_id character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    created integer,
    api_key_account_id uuid NOT NULL,
    connect_account_id uuid,
    charge_type character varying
);


--
-- Name: COLUMN stripe_record__refunds.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__refunds.remote_id IS 'Stripe の refund ID';


--
-- Name: COLUMN stripe_record__refunds.api_key_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__refunds.api_key_account_id IS 'API Key を持っているアカウント。通常の決済であればその決済のアカウントとなる。Connect の場合はプラットフォームアカウントになる。';


--
-- Name: COLUMN stripe_record__refunds.connect_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__refunds.connect_account_id IS 'Connect のときだけ使用する。この決済がどの Connected アカウントに対する支払いなのかを表す。';


--
-- Name: COLUMN stripe_record__refunds.charge_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__refunds.charge_type IS 'Connect のときだけ使用する。どの支払いタイプなのかを表す';


--
-- Name: stripe_record__setup_intents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record__setup_intents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    remote_id character varying NOT NULL,
    user_id uuid NOT NULL,
    client_secret character varying NOT NULL,
    customer_id character varying,
    on_behalf_of_id character varying,
    payment_method_id character varying,
    status character varying,
    usage character varying,
    activated_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    api_key_account_id uuid NOT NULL,
    connect_account_id uuid,
    charge_type character varying
);


--
-- Name: COLUMN stripe_record__setup_intents.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__setup_intents.remote_id IS 'Stripe の setup intent ID';


--
-- Name: COLUMN stripe_record__setup_intents.activated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__setup_intents.activated_at IS 'このカードが有効になった日時。NULL だがカードの登録自体には成功している場合、この SetupIntent で登録されたカードは定期的に削除する。';


--
-- Name: COLUMN stripe_record__setup_intents.api_key_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__setup_intents.api_key_account_id IS 'API Key を持っているアカウント。通常の決済であればその決済のアカウントとなる。Connect の場合はプラットフォームアカウントになる。';


--
-- Name: COLUMN stripe_record__setup_intents.connect_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__setup_intents.connect_account_id IS 'Connect のときだけ使用する。この決済がどの Connected アカウントに対する支払いなのかを表す。';


--
-- Name: COLUMN stripe_record__setup_intents.charge_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__setup_intents.charge_type IS 'Connect のときだけ使用する。どの支払いタイプなのかを表す';


--
-- Name: stripe_record__subscription_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record__subscription_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    subscription_id uuid NOT NULL,
    price_id uuid NOT NULL,
    remote_id character varying NOT NULL,
    quantity integer DEFAULT 1,
    billing_thresholds jsonb,
    current_period_start integer,
    current_period_end integer,
    discounts jsonb DEFAULT '[]'::jsonb,
    metadata jsonb DEFAULT '{}'::jsonb,
    tax_rates jsonb DEFAULT '[]'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: stripe_record__subscription_schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record__subscription_schedules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    subscription_id uuid NOT NULL,
    remote_id character varying NOT NULL,
    remote_customer character varying,
    status character varying,
    phases jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: stripe_record__subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record__subscriptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    product_id uuid NOT NULL,
    price_id uuid NOT NULL,
    pending_setup_intent_id uuid,
    amount integer DEFAULT 0,
    tax integer DEFAULT 0,
    currency character varying DEFAULT 'JPY'::character varying,
    refunded boolean DEFAULT false,
    refund_reason character varying,
    current_period_start timestamp(6) without time zone,
    current_period_end timestamp(6) without time zone,
    trial_period_days integer,
    trial_end timestamp(6) without time zone,
    trial_start timestamp(6) without time zone,
    remote_id character varying,
    status character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN stripe_record__subscriptions.current_period_start; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__subscriptions.current_period_start IS '現在の請求期間の開始日時';


--
-- Name: COLUMN stripe_record__subscriptions.current_period_end; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__subscriptions.current_period_end IS '現在の請求期間の終了日時';


--
-- Name: COLUMN stripe_record__subscriptions.trial_period_days; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__subscriptions.trial_period_days IS 'トライアル日数';


--
-- Name: COLUMN stripe_record__subscriptions.trial_end; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__subscriptions.trial_end IS 'トライアル終了日時';


--
-- Name: COLUMN stripe_record__subscriptions.trial_start; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__subscriptions.trial_start IS 'トライアル開始日時';


--
-- Name: stripe_record__trial_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record__trial_histories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    membership_id uuid NOT NULL,
    membership_plan_id uuid NOT NULL,
    stripe_record_subscription_id uuid,
    fingerprint character varying NOT NULL,
    trial_start timestamp(6) without time zone NOT NULL,
    trial_end timestamp(6) without time zone,
    trial_period_days integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE stripe_record__trial_histories; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.stripe_record__trial_histories IS 'Stripeのトライアル履歴';


--
-- Name: COLUMN stripe_record__trial_histories.fingerprint; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__trial_histories.fingerprint IS '決済手段のユニークな識別子(ex: クレジットカードのfingerprint)';


--
-- Name: COLUMN stripe_record__trial_histories.trial_start; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__trial_histories.trial_start IS 'トライアル開始日時';


--
-- Name: COLUMN stripe_record__trial_histories.trial_end; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__trial_histories.trial_end IS 'トライアル終了日時';


--
-- Name: COLUMN stripe_record__trial_histories.trial_period_days; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record__trial_histories.trial_period_days IS 'トライアル日数';


--
-- Name: tenant_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_settings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    google_cloud_service_account character varying,
    google_cloud_project_id character varying,
    recaptcha_enterprise_checkbox_site_key character varying,
    recaptcha_enterprise_score_based_site_key character varying,
    twilio_verify_service_sid character varying,
    profile_field_rules jsonb DEFAULT '{}'::jsonb,
    sender_email character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: tenant_stripe_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_stripe_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    stripe_account_id uuid NOT NULL,
    charge_type character varying,
    fee_rate numeric(6,5),
    tax_rate_id character varying,
    webhook_secret character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN tenant_stripe_accounts.charge_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant_stripe_accounts.charge_type IS 'Connect の場合にどの支払いタイプを利用するか';


--
-- Name: COLUMN tenant_stripe_accounts.fee_rate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant_stripe_accounts.fee_rate IS '手数料率（100% ~ 0.001%）。stripe_account.controlling_platform がいる場合のみ（Connect）利用する。';


--
-- Name: COLUMN tenant_stripe_accounts.tax_rate_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant_stripe_accounts.tax_rate_id IS 'stripe の税率ID';


--
-- Name: COLUMN tenant_stripe_accounts.webhook_secret; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant_stripe_accounts.webhook_secret IS 'Stripe webhookの署名検証用シークレット';


--
-- Name: tenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants (
    id public.citext NOT NULL,
    name character varying,
    domain character varying,
    sms_verification_required boolean DEFAULT false,
    card_payment_gateway character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN tenants.card_payment_gateway; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenants.card_payment_gateway IS 'カード決済で使用するペイメントゲートウェイ';


--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    first_name character varying,
    last_name character varying,
    first_name_kana character varying,
    last_name_kana character varying,
    birth_date date,
    gender character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    email character varying,
    password_digest character varying,
    enabled boolean DEFAULT false,
    phone_number character varying,
    sms_verified boolean DEFAULT false,
    email_verified boolean DEFAULT false,
    suppress_sms_verification boolean DEFAULT false,
    deleted boolean DEFAULT false,
    deleted_at timestamp(6) without time zone DEFAULT NULL::timestamp without time zone,
    password_reset_code character varying,
    captcha_score double precision,
    payment_provider character varying,
    payment_customer_id character varying,
    default_payment_method character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users__email_verifiers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users__email_verifiers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    code character varying NOT NULL,
    expired_at timestamp(6) without time zone NOT NULL,
    remaining_attempts integer DEFAULT 0,
    verifier_type character varying DEFAULT 'registration'::character varying NOT NULL,
    email character varying,
    used_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users__linked_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users__linked_applications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    oauth_application_id uuid NOT NULL,
    scopes character varying NOT NULL,
    last_linked_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users__password_resets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users__password_resets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    code character varying NOT NULL,
    expired_at timestamp(6) without time zone NOT NULL,
    used_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users__sms_verifiers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users__sms_verifiers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    code character varying NOT NULL,
    expired_at timestamp(6) without time zone NOT NULL,
    remaining_attempts integer DEFAULT 0,
    verifier_type character varying NOT NULL,
    phone_number character varying,
    used_at timestamp(6) without time zone,
    sms_sender character varying,
    sms_sid character varying,
    ip_address character varying,
    delivery_type character varying,
    ignore_in_rate_limit boolean DEFAULT false,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN users__sms_verifiers.ignore_in_rate_limit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users__sms_verifiers.ignore_in_rate_limit IS 'SMS送信のレートリミットのカウントから除外する';


--
-- Name: account_locks account_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_locks
    ADD CONSTRAINT account_locks_pkey PRIMARY KEY (id);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: contact_addresses contact_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contact_addresses
    ADD CONSTRAINT contact_addresses_pkey PRIMARY KEY (id);


--
-- Name: delivery_addresses delivery_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_addresses
    ADD CONSTRAINT delivery_addresses_pkey PRIMARY KEY (id);


--
-- Name: email_templates email_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_templates
    ADD CONSTRAINT email_templates_pkey PRIMARY KEY (id);


--
-- Name: login_spa_applications login_spa_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_spa_applications
    ADD CONSTRAINT login_spa_applications_pkey PRIMARY KEY (id);


--
-- Name: membership_contract_terms membership_contract_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_contract_terms
    ADD CONSTRAINT membership_contract_terms_pkey PRIMARY KEY (id);


--
-- Name: membership_contracts membership_contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_contracts
    ADD CONSTRAINT membership_contracts_pkey PRIMARY KEY (id);


--
-- Name: membership_groups membership_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_groups
    ADD CONSTRAINT membership_groups_pkey PRIMARY KEY (id);


--
-- Name: membership_plan_components membership_plan_components_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_plan_components
    ADD CONSTRAINT membership_plan_components_pkey PRIMARY KEY (id);


--
-- Name: membership_plan_payment_method_mappings membership_plan_payment_method_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_plan_payment_method_mappings
    ADD CONSTRAINT membership_plan_payment_method_mappings_pkey PRIMARY KEY (id);


--
-- Name: membership_plan_payment_methods membership_plan_payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_plan_payment_methods
    ADD CONSTRAINT membership_plan_payment_methods_pkey PRIMARY KEY (id);


--
-- Name: membership_plans membership_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_plans
    ADD CONSTRAINT membership_plans_pkey PRIMARY KEY (id);


--
-- Name: membership_user_achievements membership_user_achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_user_achievements
    ADD CONSTRAINT membership_user_achievements_pkey PRIMARY KEY (id);


--
-- Name: membership_users membership_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_users
    ADD CONSTRAINT membership_users_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: oauth_openid_requests oauth_openid_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_openid_requests
    ADD CONSTRAINT oauth_openid_requests_pkey PRIMARY KEY (id);


--
-- Name: payment__subscriptions payment__subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment__subscriptions
    ADD CONSTRAINT payment__subscriptions_pkey PRIMARY KEY (id);


--
-- Name: payment__transactions payment__transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment__transactions
    ADD CONSTRAINT payment__transactions_pkey PRIMARY KEY (id);


--
-- Name: rulers rulers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rulers
    ADD CONSTRAINT rulers_pkey PRIMARY KEY (id);


--
-- Name: shopify_record__customers shopify_record__customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_record__customers
    ADD CONSTRAINT shopify_record__customers_pkey PRIMARY KEY (id);


--
-- Name: shopify_record__multipass_stores shopify_record__multipass_stores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_record__multipass_stores
    ADD CONSTRAINT shopify_record__multipass_stores_pkey PRIMARY KEY (id);


--
-- Name: stripe_record__accounts stripe_record__accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__accounts
    ADD CONSTRAINT stripe_record__accounts_pkey PRIMARY KEY (id);


--
-- Name: stripe_record__api_keys stripe_record__api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__api_keys
    ADD CONSTRAINT stripe_record__api_keys_pkey PRIMARY KEY (id);


--
-- Name: stripe_record__charges stripe_record__charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__charges
    ADD CONSTRAINT stripe_record__charges_pkey PRIMARY KEY (id);


--
-- Name: stripe_record__invoices stripe_record__invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__invoices
    ADD CONSTRAINT stripe_record__invoices_pkey PRIMARY KEY (id);


--
-- Name: stripe_record__payment_intents stripe_record__payment_intents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__payment_intents
    ADD CONSTRAINT stripe_record__payment_intents_pkey PRIMARY KEY (id);


--
-- Name: stripe_record__payment_methods stripe_record__payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__payment_methods
    ADD CONSTRAINT stripe_record__payment_methods_pkey PRIMARY KEY (id);


--
-- Name: stripe_record__prices stripe_record__prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__prices
    ADD CONSTRAINT stripe_record__prices_pkey PRIMARY KEY (id);


--
-- Name: stripe_record__products stripe_record__products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__products
    ADD CONSTRAINT stripe_record__products_pkey PRIMARY KEY (id);


--
-- Name: stripe_record__refunds stripe_record__refunds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__refunds
    ADD CONSTRAINT stripe_record__refunds_pkey PRIMARY KEY (id);


--
-- Name: stripe_record__setup_intents stripe_record__setup_intents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__setup_intents
    ADD CONSTRAINT stripe_record__setup_intents_pkey PRIMARY KEY (id);


--
-- Name: stripe_record__subscription_items stripe_record__subscription_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__subscription_items
    ADD CONSTRAINT stripe_record__subscription_items_pkey PRIMARY KEY (id);


--
-- Name: stripe_record__subscription_schedules stripe_record__subscription_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__subscription_schedules
    ADD CONSTRAINT stripe_record__subscription_schedules_pkey PRIMARY KEY (id);


--
-- Name: stripe_record__subscriptions stripe_record__subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__subscriptions
    ADD CONSTRAINT stripe_record__subscriptions_pkey PRIMARY KEY (id);


--
-- Name: stripe_record__trial_histories stripe_record__trial_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__trial_histories
    ADD CONSTRAINT stripe_record__trial_histories_pkey PRIMARY KEY (id);


--
-- Name: tenant_settings tenant_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_settings
    ADD CONSTRAINT tenant_settings_pkey PRIMARY KEY (id);


--
-- Name: tenant_stripe_accounts tenant_stripe_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_stripe_accounts
    ADD CONSTRAINT tenant_stripe_accounts_pkey PRIMARY KEY (id);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);


--
-- Name: users__email_verifiers users__email_verifiers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users__email_verifiers
    ADD CONSTRAINT users__email_verifiers_pkey PRIMARY KEY (id);


--
-- Name: users__linked_applications users__linked_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users__linked_applications
    ADD CONSTRAINT users__linked_applications_pkey PRIMARY KEY (id);


--
-- Name: users__password_resets users__password_resets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users__password_resets
    ADD CONSTRAINT users__password_resets_pkey PRIMARY KEY (id);


--
-- Name: users__sms_verifiers users__sms_verifiers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users__sms_verifiers
    ADD CONSTRAINT users__sms_verifiers_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_account_locks_tenant_id_email_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_account_locks_tenant_id_email_uniq ON public.account_locks USING btree (tenant_id, email);


--
-- Name: idx_account_locks_tenant_id_unlock_token_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_account_locks_tenant_id_unlock_token_uniq ON public.account_locks USING btree (tenant_id, unlock_token);


--
-- Name: idx_admins_tenant_id_uid_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_admins_tenant_id_uid_uniq ON public.admins USING btree (tenant_id, uid);


--
-- Name: idx_contact_addresses_tenant_id_user_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_contact_addresses_tenant_id_user_id_uniq ON public.contact_addresses USING btree (tenant_id, user_id);


--
-- Name: idx_linked_applications_tenant_user_oauth_application_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_linked_applications_tenant_user_oauth_application_uniq ON public.users__linked_applications USING btree (tenant_id, user_id, oauth_application_id);


--
-- Name: idx_membership_contracts_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_membership_contracts_expires_at ON public.membership_contracts USING btree (expires_at);


--
-- Name: idx_membership_groups_tenant_id_name_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_membership_groups_tenant_id_name_uniq ON public.membership_groups USING btree (tenant_id, name);


--
-- Name: idx_membership_groups_tenant_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_membership_groups_tenant_position ON public.membership_groups USING btree (tenant_id, "position");


--
-- Name: idx_membership_plan_components_plan_membership_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_membership_plan_components_plan_membership_uniq ON public.membership_plan_components USING btree (membership_plan_id, membership_id);


--
-- Name: idx_membership_plan_payment_methods_plan_type_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_membership_plan_payment_methods_plan_type_uniq ON public.membership_plan_payment_methods USING btree (membership_plan_id, payment_type);


--
-- Name: idx_membership_user_achievements_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_membership_user_achievements_date ON public.membership_user_achievements USING btree (date);


--
-- Name: idx_membership_user_achievements_tenant_user_membership_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_membership_user_achievements_tenant_user_membership_date ON public.membership_user_achievements USING btree (tenant_id, user_id, membership_id, date);


--
-- Name: idx_membership_users_tenant_user_membership_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_membership_users_tenant_user_membership_uniq ON public.membership_users USING btree (tenant_id, user_id, membership_id);


--
-- Name: idx_on_chargeable_type_chargeable_id_31503b9e8f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_chargeable_type_chargeable_id_31503b9e8f ON public.stripe_record__payment_intents USING btree (chargeable_type, chargeable_id);


--
-- Name: idx_on_chargeable_type_chargeable_id_8534730e7a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_chargeable_type_chargeable_id_8534730e7a ON public.payment__transactions USING btree (chargeable_type, chargeable_id);


--
-- Name: idx_on_membership_plan_id_abf7e120d7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_membership_plan_id_abf7e120d7 ON public.membership_plan_payment_method_mappings USING btree (membership_plan_id);


--
-- Name: idx_on_membership_plan_payment_method_id_45519b8566; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_membership_plan_payment_method_id_45519b8566 ON public.membership_plan_payment_method_mappings USING btree (membership_plan_payment_method_id);


--
-- Name: idx_on_payment_source_type_payment_source_id_0313cc1522; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_payment_source_type_payment_source_id_0313cc1522 ON public.stripe_record__invoices USING btree (payment_source_type, payment_source_id);


--
-- Name: idx_on_priceable_type_priceable_id_bc1644aaac; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_priceable_type_priceable_id_bc1644aaac ON public.membership_plan_payment_method_mappings USING btree (priceable_type, priceable_id);


--
-- Name: idx_on_stripe_record_price_id_ccd90274f4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_stripe_record_price_id_ccd90274f4 ON public.membership_plan_payment_methods USING btree (stripe_record_price_id);


--
-- Name: idx_on_stripe_record_subscription_id_9e35bed4eb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_stripe_record_subscription_id_9e35bed4eb ON public.stripe_record__trial_histories USING btree (stripe_record_subscription_id);


--
-- Name: idx_on_subscribable_type_subscribable_id_36fbd91894; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_subscribable_type_subscribable_id_36fbd91894 ON public.payment__subscriptions USING btree (subscribable_type, subscribable_id);


--
-- Name: idx_payment__subscriptions_tenant_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment__subscriptions_tenant_user ON public.payment__subscriptions USING btree (tenant_id, user_id);


--
-- Name: idx_payment__transactions_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment__transactions_expires_at ON public.payment__transactions USING btree (expires_at);


--
-- Name: idx_payment__transactions_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment__transactions_external_id ON public.payment__transactions USING btree (external_id);


--
-- Name: idx_payment__transactions_tenant_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment__transactions_tenant_user ON public.payment__transactions USING btree (tenant_id, user_id);


--
-- Name: idx_rulers_uid_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_rulers_uid_uniq ON public.rulers USING btree (uid);


--
-- Name: idx_shopify_record__customers_store_name_email_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_shopify_record__customers_store_name_email_uniq ON public.shopify_record__customers USING btree (store_name, email);


--
-- Name: idx_stripe_record__trial_histories_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_stripe_record__trial_histories_unique ON public.stripe_record__trial_histories USING btree (tenant_id, membership_id, fingerprint);


--
-- Name: idx_stripe_record_api_keys_remote_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_stripe_record_api_keys_remote_id_uniq ON public.stripe_record__api_keys USING btree (remote_id);


--
-- Name: idx_stripe_record_charge_remote_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_stripe_record_charge_remote_id_uniq ON public.stripe_record__charges USING btree (remote_id);


--
-- Name: idx_stripe_record_invoices_remote_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_stripe_record_invoices_remote_id_uniq ON public.stripe_record__invoices USING btree (remote_id);


--
-- Name: idx_stripe_record_payment_intent_remote_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_stripe_record_payment_intent_remote_id_uniq ON public.stripe_record__payment_intents USING btree (remote_id);


--
-- Name: idx_stripe_record_payment_methods_remote_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_stripe_record_payment_methods_remote_id_uniq ON public.stripe_record__payment_methods USING btree (remote_id);


--
-- Name: idx_stripe_record_refund_remote_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_stripe_record_refund_remote_id_uniq ON public.stripe_record__refunds USING btree (remote_id);


--
-- Name: idx_stripe_record_setup_intents_remote_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_stripe_record_setup_intents_remote_id_uniq ON public.stripe_record__setup_intents USING btree (remote_id);


--
-- Name: idx_tenant_settings_tenant_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_tenant_settings_tenant_id_uniq ON public.tenant_settings USING btree (tenant_id);


--
-- Name: idx_user_profiles_tenant_id_user_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_user_profiles_tenant_id_user_id_uniq ON public.user_profiles USING btree (tenant_id, user_id);


--
-- Name: idx_users_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_created_at ON public.users__sms_verifiers USING btree (created_at);


--
-- Name: idx_users_ip_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_ip_address ON public.users__sms_verifiers USING btree (ip_address);


--
-- Name: idx_users_phone_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_phone_number ON public.users__sms_verifiers USING btree (phone_number);


--
-- Name: index_account_locks_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_locks_on_tenant_id ON public.account_locks USING btree (tenant_id);


--
-- Name: index_admins_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admins_on_tenant_id ON public.admins USING btree (tenant_id);


--
-- Name: index_contact_addresses_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contact_addresses_on_tenant_id ON public.contact_addresses USING btree (tenant_id);


--
-- Name: index_contact_addresses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contact_addresses_on_user_id ON public.contact_addresses USING btree (user_id);


--
-- Name: index_delivery_addresses_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_addresses_on_tenant_id ON public.delivery_addresses USING btree (tenant_id);


--
-- Name: index_delivery_addresses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_addresses_on_user_id ON public.delivery_addresses USING btree (user_id);


--
-- Name: index_email_templates_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_templates_on_tenant_id ON public.email_templates USING btree (tenant_id);


--
-- Name: index_email_templates_on_tenant_id_template_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_email_templates_on_tenant_id_template_type ON public.email_templates USING btree (tenant_id, template_type);


--
-- Name: index_login_spa_applications_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_login_spa_applications_on_tenant_id ON public.login_spa_applications USING btree (tenant_id);


--
-- Name: index_login_spa_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_login_spa_applications_on_uid ON public.login_spa_applications USING btree (uid);


--
-- Name: index_membership_contract_terms_on_membership_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_contract_terms_on_membership_contract_id ON public.membership_contract_terms USING btree (membership_contract_id);


--
-- Name: index_membership_contract_terms_on_membership_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_contract_terms_on_membership_plan_id ON public.membership_contract_terms USING btree (membership_plan_id);


--
-- Name: index_membership_contract_terms_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_contract_terms_on_tenant_id ON public.membership_contract_terms USING btree (tenant_id);


--
-- Name: index_membership_contract_terms_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_contract_terms_on_user_id ON public.membership_contract_terms USING btree (user_id);


--
-- Name: index_membership_contracts_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_contracts_on_tenant_id ON public.membership_contracts USING btree (tenant_id);


--
-- Name: index_membership_contracts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_contracts_on_user_id ON public.membership_contracts USING btree (user_id);


--
-- Name: index_membership_groups_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_groups_on_tenant_id ON public.membership_groups USING btree (tenant_id);


--
-- Name: index_membership_plan_components_on_membership_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_plan_components_on_membership_id ON public.membership_plan_components USING btree (membership_id);


--
-- Name: index_membership_plan_components_on_membership_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_plan_components_on_membership_plan_id ON public.membership_plan_components USING btree (membership_plan_id);


--
-- Name: index_membership_plan_components_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_plan_components_on_tenant_id ON public.membership_plan_components USING btree (tenant_id);


--
-- Name: index_membership_plan_payment_method_mappings_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_plan_payment_method_mappings_on_tenant_id ON public.membership_plan_payment_method_mappings USING btree (tenant_id);


--
-- Name: index_membership_plan_payment_methods_on_membership_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_plan_payment_methods_on_membership_plan_id ON public.membership_plan_payment_methods USING btree (membership_plan_id);


--
-- Name: index_membership_plan_payment_methods_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_plan_payment_methods_on_tenant_id ON public.membership_plan_payment_methods USING btree (tenant_id);


--
-- Name: index_membership_plans_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_plans_on_tenant_id ON public.membership_plans USING btree (tenant_id);


--
-- Name: index_membership_user_achievements_on_membership_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_user_achievements_on_membership_id ON public.membership_user_achievements USING btree (membership_id);


--
-- Name: index_membership_user_achievements_on_membership_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_user_achievements_on_membership_plan_id ON public.membership_user_achievements USING btree (membership_plan_id);


--
-- Name: index_membership_user_achievements_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_user_achievements_on_tenant_id ON public.membership_user_achievements USING btree (tenant_id);


--
-- Name: index_membership_user_achievements_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_user_achievements_on_user_id ON public.membership_user_achievements USING btree (user_id);


--
-- Name: index_membership_users_on_membership_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_users_on_membership_contract_id ON public.membership_users USING btree (membership_contract_id);


--
-- Name: index_membership_users_on_membership_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_users_on_membership_group_id ON public.membership_users USING btree (membership_group_id);


--
-- Name: index_membership_users_on_membership_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_users_on_membership_id ON public.membership_users USING btree (membership_id);


--
-- Name: index_membership_users_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_users_on_tenant_id ON public.membership_users USING btree (tenant_id);


--
-- Name: index_membership_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_users_on_user_id ON public.membership_users USING btree (user_id);


--
-- Name: index_memberships_on_membership_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_membership_group_id ON public.memberships USING btree (membership_group_id);


--
-- Name: index_memberships_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_tenant_id ON public.memberships USING btree (tenant_id);


--
-- Name: index_oauth_access_grants_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_application_id ON public.oauth_access_grants USING btree (application_id);


--
-- Name: index_oauth_access_grants_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_resource_owner_id ON public.oauth_access_grants USING btree (resource_owner_id);


--
-- Name: index_oauth_access_grants_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_tenant_id ON public.oauth_access_grants USING btree (tenant_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON public.oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_application_id ON public.oauth_access_tokens USING btree (application_id);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON public.oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON public.oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_tenant_id ON public.oauth_access_tokens USING btree (tenant_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON public.oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_applications_on_tenant_id ON public.oauth_applications USING btree (tenant_id);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON public.oauth_applications USING btree (uid);


--
-- Name: index_oauth_openid_requests_on_access_grant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_openid_requests_on_access_grant_id ON public.oauth_openid_requests USING btree (access_grant_id);


--
-- Name: index_payment__subscriptions_on_membership_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment__subscriptions_on_membership_contract_id ON public.payment__subscriptions USING btree (membership_contract_id);


--
-- Name: index_payment__subscriptions_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment__subscriptions_on_tenant_id ON public.payment__subscriptions USING btree (tenant_id);


--
-- Name: index_payment__subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment__subscriptions_on_user_id ON public.payment__subscriptions USING btree (user_id);


--
-- Name: index_payment__transactions_on_membership_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment__transactions_on_membership_contract_id ON public.payment__transactions USING btree (membership_contract_id);


--
-- Name: index_payment__transactions_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment__transactions_on_tenant_id ON public.payment__transactions USING btree (tenant_id);


--
-- Name: index_payment__transactions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment__transactions_on_user_id ON public.payment__transactions USING btree (user_id);


--
-- Name: index_shopify_record__customers_on_multipass_store_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shopify_record__customers_on_multipass_store_id ON public.shopify_record__customers USING btree (multipass_store_id);


--
-- Name: index_shopify_record__customers_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shopify_record__customers_on_tenant_id ON public.shopify_record__customers USING btree (tenant_id);


--
-- Name: index_shopify_record__customers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shopify_record__customers_on_user_id ON public.shopify_record__customers USING btree (user_id);


--
-- Name: index_shopify_record__multipass_stores_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shopify_record__multipass_stores_on_tenant_id ON public.shopify_record__multipass_stores USING btree (tenant_id);


--
-- Name: index_stripe_account_per_tenant_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stripe_account_per_tenant_unique ON public.tenant_stripe_accounts USING btree (tenant_id, stripe_account_id);


--
-- Name: index_stripe_record__accounts_on_api_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__accounts_on_api_key_id ON public.stripe_record__accounts USING btree (api_key_id);


--
-- Name: index_stripe_record__accounts_on_controlling_platform_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__accounts_on_controlling_platform_id ON public.stripe_record__accounts USING btree (controlling_platform_id);


--
-- Name: index_stripe_record__accounts_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__accounts_on_tenant_id ON public.stripe_record__accounts USING btree (tenant_id);


--
-- Name: index_stripe_record__api_keys_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__api_keys_on_tenant_id ON public.stripe_record__api_keys USING btree (tenant_id);


--
-- Name: index_stripe_record__charges_on_api_key_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__charges_on_api_key_account_id ON public.stripe_record__charges USING btree (api_key_account_id);


--
-- Name: index_stripe_record__charges_on_connect_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__charges_on_connect_account_id ON public.stripe_record__charges USING btree (connect_account_id);


--
-- Name: index_stripe_record__charges_on_payment_intent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__charges_on_payment_intent_id ON public.stripe_record__charges USING btree (payment_intent_id);


--
-- Name: index_stripe_record__charges_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__charges_on_tenant_id ON public.stripe_record__charges USING btree (tenant_id);


--
-- Name: index_stripe_record__charges_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__charges_on_user_id ON public.stripe_record__charges USING btree (user_id);


--
-- Name: index_stripe_record__invoices_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__invoices_on_tenant_id ON public.stripe_record__invoices USING btree (tenant_id);


--
-- Name: index_stripe_record__invoices_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__invoices_on_user_id ON public.stripe_record__invoices USING btree (user_id);


--
-- Name: index_stripe_record__payment_intents_on_api_key_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__payment_intents_on_api_key_account_id ON public.stripe_record__payment_intents USING btree (api_key_account_id);


--
-- Name: index_stripe_record__payment_intents_on_connect_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__payment_intents_on_connect_account_id ON public.stripe_record__payment_intents USING btree (connect_account_id);


--
-- Name: index_stripe_record__payment_intents_on_invoice_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__payment_intents_on_invoice_id ON public.stripe_record__payment_intents USING btree (invoice_id);


--
-- Name: index_stripe_record__payment_intents_on_latest_charge_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__payment_intents_on_latest_charge_id ON public.stripe_record__payment_intents USING btree (latest_charge_id);


--
-- Name: index_stripe_record__payment_intents_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__payment_intents_on_tenant_id ON public.stripe_record__payment_intents USING btree (tenant_id);


--
-- Name: index_stripe_record__payment_intents_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__payment_intents_on_user_id ON public.stripe_record__payment_intents USING btree (user_id);


--
-- Name: index_stripe_record__payment_methods_on_api_key_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__payment_methods_on_api_key_account_id ON public.stripe_record__payment_methods USING btree (api_key_account_id);


--
-- Name: index_stripe_record__payment_methods_on_connect_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__payment_methods_on_connect_account_id ON public.stripe_record__payment_methods USING btree (connect_account_id);


--
-- Name: index_stripe_record__payment_methods_on_setup_intent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__payment_methods_on_setup_intent_id ON public.stripe_record__payment_methods USING btree (setup_intent_id);


--
-- Name: index_stripe_record__payment_methods_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__payment_methods_on_tenant_id ON public.stripe_record__payment_methods USING btree (tenant_id);


--
-- Name: index_stripe_record__payment_methods_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__payment_methods_on_user_id ON public.stripe_record__payment_methods USING btree (user_id);


--
-- Name: index_stripe_record__prices_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__prices_on_product_id ON public.stripe_record__prices USING btree (product_id);


--
-- Name: index_stripe_record__prices_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__prices_on_tenant_id ON public.stripe_record__prices USING btree (tenant_id);


--
-- Name: index_stripe_record__products_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__products_on_tenant_id ON public.stripe_record__products USING btree (tenant_id);


--
-- Name: index_stripe_record__refunds_on_api_key_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__refunds_on_api_key_account_id ON public.stripe_record__refunds USING btree (api_key_account_id);


--
-- Name: index_stripe_record__refunds_on_connect_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__refunds_on_connect_account_id ON public.stripe_record__refunds USING btree (connect_account_id);


--
-- Name: index_stripe_record__refunds_on_payment_intent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__refunds_on_payment_intent_id ON public.stripe_record__refunds USING btree (payment_intent_id);


--
-- Name: index_stripe_record__refunds_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__refunds_on_tenant_id ON public.stripe_record__refunds USING btree (tenant_id);


--
-- Name: index_stripe_record__refunds_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__refunds_on_user_id ON public.stripe_record__refunds USING btree (user_id);


--
-- Name: index_stripe_record__setup_intents_on_api_key_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__setup_intents_on_api_key_account_id ON public.stripe_record__setup_intents USING btree (api_key_account_id);


--
-- Name: index_stripe_record__setup_intents_on_connect_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__setup_intents_on_connect_account_id ON public.stripe_record__setup_intents USING btree (connect_account_id);


--
-- Name: index_stripe_record__setup_intents_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__setup_intents_on_tenant_id ON public.stripe_record__setup_intents USING btree (tenant_id);


--
-- Name: index_stripe_record__setup_intents_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__setup_intents_on_user_id ON public.stripe_record__setup_intents USING btree (user_id);


--
-- Name: index_stripe_record__subscription_items_on_price_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__subscription_items_on_price_id ON public.stripe_record__subscription_items USING btree (price_id);


--
-- Name: index_stripe_record__subscription_items_on_remote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stripe_record__subscription_items_on_remote_id ON public.stripe_record__subscription_items USING btree (remote_id);


--
-- Name: index_stripe_record__subscription_items_on_subscription_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__subscription_items_on_subscription_id ON public.stripe_record__subscription_items USING btree (subscription_id);


--
-- Name: index_stripe_record__subscription_items_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__subscription_items_on_tenant_id ON public.stripe_record__subscription_items USING btree (tenant_id);


--
-- Name: index_stripe_record__subscription_schedules_on_subscription_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__subscription_schedules_on_subscription_id ON public.stripe_record__subscription_schedules USING btree (subscription_id);


--
-- Name: index_stripe_record__subscription_schedules_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__subscription_schedules_on_tenant_id ON public.stripe_record__subscription_schedules USING btree (tenant_id);


--
-- Name: index_stripe_record__subscription_schedules_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__subscription_schedules_on_user_id ON public.stripe_record__subscription_schedules USING btree (user_id);


--
-- Name: index_stripe_record__subscriptions_on_pending_setup_intent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__subscriptions_on_pending_setup_intent_id ON public.stripe_record__subscriptions USING btree (pending_setup_intent_id);


--
-- Name: index_stripe_record__subscriptions_on_price_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__subscriptions_on_price_id ON public.stripe_record__subscriptions USING btree (price_id);


--
-- Name: index_stripe_record__subscriptions_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__subscriptions_on_product_id ON public.stripe_record__subscriptions USING btree (product_id);


--
-- Name: index_stripe_record__subscriptions_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__subscriptions_on_tenant_id ON public.stripe_record__subscriptions USING btree (tenant_id);


--
-- Name: index_stripe_record__subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__subscriptions_on_user_id ON public.stripe_record__subscriptions USING btree (user_id);


--
-- Name: index_stripe_record__trial_histories_on_membership_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__trial_histories_on_membership_id ON public.stripe_record__trial_histories USING btree (membership_id);


--
-- Name: index_stripe_record__trial_histories_on_membership_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__trial_histories_on_membership_plan_id ON public.stripe_record__trial_histories USING btree (membership_plan_id);


--
-- Name: index_stripe_record__trial_histories_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__trial_histories_on_tenant_id ON public.stripe_record__trial_histories USING btree (tenant_id);


--
-- Name: index_stripe_record__trial_histories_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record__trial_histories_on_user_id ON public.stripe_record__trial_histories USING btree (user_id);


--
-- Name: index_stripe_record_accounts_remote_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stripe_record_accounts_remote_id_unique ON public.stripe_record__accounts USING btree (remote_id, controlling_platform_id) NULLS NOT DISTINCT;


--
-- Name: index_stripe_record_invoices_on_tenant_and_remote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stripe_record_invoices_on_tenant_and_remote_id ON public.stripe_record__invoices USING btree (tenant_id, remote_id);


--
-- Name: index_stripe_record_payment_intents_on_tenant_and_remote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stripe_record_payment_intents_on_tenant_and_remote_id ON public.stripe_record__payment_intents USING btree (tenant_id, remote_id);


--
-- Name: index_stripe_record_si_on_subscription_and_price; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stripe_record_si_on_subscription_and_price ON public.stripe_record__subscription_items USING btree (subscription_id, price_id);


--
-- Name: index_tenant_settings_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_settings_on_tenant_id ON public.tenant_settings USING btree (tenant_id);


--
-- Name: index_tenant_stripe_accounts_on_stripe_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_stripe_accounts_on_stripe_account_id ON public.tenant_stripe_accounts USING btree (stripe_account_id);


--
-- Name: index_tenant_stripe_accounts_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tenant_stripe_accounts_on_tenant_id ON public.tenant_stripe_accounts USING btree (tenant_id);


--
-- Name: index_user_profiles_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_profiles_on_tenant_id ON public.user_profiles USING btree (tenant_id);


--
-- Name: index_user_profiles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_profiles_on_user_id ON public.user_profiles USING btree (user_id);


--
-- Name: index_users__email_verifiers_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users__email_verifiers_on_tenant_id ON public.users__email_verifiers USING btree (tenant_id);


--
-- Name: index_users__email_verifiers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users__email_verifiers_on_user_id ON public.users__email_verifiers USING btree (user_id);


--
-- Name: index_users__linked_applications_on_oauth_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users__linked_applications_on_oauth_application_id ON public.users__linked_applications USING btree (oauth_application_id);


--
-- Name: index_users__linked_applications_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users__linked_applications_on_tenant_id ON public.users__linked_applications USING btree (tenant_id);


--
-- Name: index_users__linked_applications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users__linked_applications_on_user_id ON public.users__linked_applications USING btree (user_id);


--
-- Name: index_users__password_resets_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users__password_resets_on_tenant_id ON public.users__password_resets USING btree (tenant_id);


--
-- Name: index_users__password_resets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users__password_resets_on_user_id ON public.users__password_resets USING btree (user_id);


--
-- Name: index_users__sms_verifiers_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users__sms_verifiers_on_tenant_id ON public.users__sms_verifiers USING btree (tenant_id);


--
-- Name: index_users__sms_verifiers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users__sms_verifiers_on_user_id ON public.users__sms_verifiers USING btree (user_id);


--
-- Name: index_users_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_tenant_id ON public.users USING btree (tenant_id);


--
-- Name: index_users_on_tenant_id_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_tenant_id_email ON public.users USING btree (tenant_id, email) WHERE (deleted_at IS NULL);


--
-- Name: index_users_on_tenant_id_phone_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_tenant_id_phone_number ON public.users USING btree (tenant_id, phone_number) WHERE (deleted_at IS NULL);


--
-- Name: account_locks fk_account_locks_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_locks
    ADD CONSTRAINT fk_account_locks_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: admins fk_admins_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT fk_admins_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: contact_addresses fk_contact_addresses_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contact_addresses
    ADD CONSTRAINT fk_contact_addresses_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: contact_addresses fk_contact_addresses_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contact_addresses
    ADD CONSTRAINT fk_contact_addresses_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: delivery_addresses fk_delivery_addresses_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_addresses
    ADD CONSTRAINT fk_delivery_addresses_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: delivery_addresses fk_delivery_addresses_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_addresses
    ADD CONSTRAINT fk_delivery_addresses_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: email_templates fk_email_templates_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_templates
    ADD CONSTRAINT fk_email_templates_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: login_spa_applications fk_login_spa_applications_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_spa_applications
    ADD CONSTRAINT fk_login_spa_applications_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: membership_contract_terms fk_membership_contract_terms_contracts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_contract_terms
    ADD CONSTRAINT fk_membership_contract_terms_contracts FOREIGN KEY (membership_contract_id) REFERENCES public.membership_contracts(id);


--
-- Name: membership_contract_terms fk_membership_contract_terms_plans; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_contract_terms
    ADD CONSTRAINT fk_membership_contract_terms_plans FOREIGN KEY (membership_plan_id) REFERENCES public.membership_plans(id);


--
-- Name: membership_contract_terms fk_membership_contract_terms_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_contract_terms
    ADD CONSTRAINT fk_membership_contract_terms_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: membership_contract_terms fk_membership_contract_terms_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_contract_terms
    ADD CONSTRAINT fk_membership_contract_terms_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: membership_contracts fk_membership_contracts_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_contracts
    ADD CONSTRAINT fk_membership_contracts_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: membership_contracts fk_membership_contracts_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_contracts
    ADD CONSTRAINT fk_membership_contracts_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: memberships fk_membership_groups; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT fk_membership_groups FOREIGN KEY (membership_group_id) REFERENCES public.membership_groups(id);


--
-- Name: membership_groups fk_membership_groups_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_groups
    ADD CONSTRAINT fk_membership_groups_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: membership_plan_components fk_membership_plan_components_memberships; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_plan_components
    ADD CONSTRAINT fk_membership_plan_components_memberships FOREIGN KEY (membership_id) REFERENCES public.memberships(id);


--
-- Name: membership_plan_components fk_membership_plan_components_plans; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_plan_components
    ADD CONSTRAINT fk_membership_plan_components_plans FOREIGN KEY (membership_plan_id) REFERENCES public.membership_plans(id);


--
-- Name: membership_plan_components fk_membership_plan_components_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_plan_components
    ADD CONSTRAINT fk_membership_plan_components_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: membership_plan_payment_method_mappings fk_membership_plan_payment_method_mappings_plans; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_plan_payment_method_mappings
    ADD CONSTRAINT fk_membership_plan_payment_method_mappings_plans FOREIGN KEY (membership_plan_id) REFERENCES public.membership_plans(id);


--
-- Name: membership_plan_payment_method_mappings fk_membership_plan_payment_method_mappings_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_plan_payment_method_mappings
    ADD CONSTRAINT fk_membership_plan_payment_method_mappings_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: membership_plan_payment_methods fk_membership_plan_payment_methods_plans; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_plan_payment_methods
    ADD CONSTRAINT fk_membership_plan_payment_methods_plans FOREIGN KEY (membership_plan_id) REFERENCES public.membership_plans(id);


--
-- Name: membership_plan_payment_methods fk_membership_plan_payment_methods_stripe_prices; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_plan_payment_methods
    ADD CONSTRAINT fk_membership_plan_payment_methods_stripe_prices FOREIGN KEY (stripe_record_price_id) REFERENCES public.stripe_record__prices(id);


--
-- Name: membership_plan_payment_methods fk_membership_plan_payment_methods_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_plan_payment_methods
    ADD CONSTRAINT fk_membership_plan_payment_methods_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: membership_plans fk_membership_plans_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_plans
    ADD CONSTRAINT fk_membership_plans_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: membership_user_achievements fk_membership_user_achievements_memberships; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_user_achievements
    ADD CONSTRAINT fk_membership_user_achievements_memberships FOREIGN KEY (membership_id) REFERENCES public.memberships(id);


--
-- Name: membership_user_achievements fk_membership_user_achievements_plans; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_user_achievements
    ADD CONSTRAINT fk_membership_user_achievements_plans FOREIGN KEY (membership_plan_id) REFERENCES public.membership_plans(id);


--
-- Name: membership_user_achievements fk_membership_user_achievements_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_user_achievements
    ADD CONSTRAINT fk_membership_user_achievements_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: membership_user_achievements fk_membership_user_achievements_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_user_achievements
    ADD CONSTRAINT fk_membership_user_achievements_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: membership_users fk_membership_users_contracts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_users
    ADD CONSTRAINT fk_membership_users_contracts FOREIGN KEY (membership_contract_id) REFERENCES public.membership_contracts(id);


--
-- Name: membership_users fk_membership_users_groups; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_users
    ADD CONSTRAINT fk_membership_users_groups FOREIGN KEY (membership_group_id) REFERENCES public.membership_groups(id);


--
-- Name: membership_users fk_membership_users_memberships; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_users
    ADD CONSTRAINT fk_membership_users_memberships FOREIGN KEY (membership_id) REFERENCES public.memberships(id);


--
-- Name: membership_users fk_membership_users_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_users
    ADD CONSTRAINT fk_membership_users_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: membership_users fk_membership_users_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_users
    ADD CONSTRAINT fk_membership_users_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: memberships fk_memberships_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT fk_memberships_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: oauth_access_grants fk_oauth_access_grants_oauth_applications; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_oauth_access_grants_oauth_applications FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: oauth_access_grants fk_oauth_access_grants_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_oauth_access_grants_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: oauth_access_tokens fk_oauth_access_tokens_oauth_applications; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_oauth_access_tokens_oauth_applications FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: oauth_access_tokens fk_oauth_access_tokens_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_oauth_access_tokens_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: oauth_applications fk_oauth_applications_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT fk_oauth_applications_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: oauth_openid_requests fk_oauth_openid_requests_oauth_access_grants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_openid_requests
    ADD CONSTRAINT fk_oauth_openid_requests_oauth_access_grants FOREIGN KEY (access_grant_id) REFERENCES public.oauth_access_grants(id);


--
-- Name: payment__subscriptions fk_payment__subscriptions_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment__subscriptions
    ADD CONSTRAINT fk_payment__subscriptions_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: payment__subscriptions fk_payment__transactions_contracts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment__subscriptions
    ADD CONSTRAINT fk_payment__transactions_contracts FOREIGN KEY (membership_contract_id) REFERENCES public.membership_contracts(id);


--
-- Name: payment__transactions fk_payment__transactions_contracts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment__transactions
    ADD CONSTRAINT fk_payment__transactions_contracts FOREIGN KEY (membership_contract_id) REFERENCES public.membership_contracts(id);


--
-- Name: payment__transactions fk_payment__transactions_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment__transactions
    ADD CONSTRAINT fk_payment__transactions_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: payment__subscriptions fk_payment__transactions_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment__subscriptions
    ADD CONSTRAINT fk_payment__transactions_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: payment__transactions fk_payment__transactions_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment__transactions
    ADD CONSTRAINT fk_payment__transactions_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: oauth_access_grants fk_rails_330c32d8d9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_rails_330c32d8d9 FOREIGN KEY (resource_owner_id) REFERENCES public.users(id);


--
-- Name: oauth_access_tokens fk_rails_ee63f25419; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_rails_ee63f25419 FOREIGN KEY (resource_owner_id) REFERENCES public.users(id);


--
-- Name: stripe_record__accounts fk_stripe_record_accounts__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__accounts
    ADD CONSTRAINT fk_stripe_record_accounts__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record__accounts fk_stripe_record_accounts_api_key_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__accounts
    ADD CONSTRAINT fk_stripe_record_accounts_api_key_id FOREIGN KEY (api_key_id) REFERENCES public.stripe_record__api_keys(id);


--
-- Name: stripe_record__accounts fk_stripe_record_accounts_controlling_platform_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__accounts
    ADD CONSTRAINT fk_stripe_record_accounts_controlling_platform_id FOREIGN KEY (controlling_platform_id) REFERENCES public.stripe_record__accounts(id);


--
-- Name: stripe_record__api_keys fk_stripe_record_api_keys__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__api_keys
    ADD CONSTRAINT fk_stripe_record_api_keys__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record__charges fk_stripe_record_charges__payment_intents; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__charges
    ADD CONSTRAINT fk_stripe_record_charges__payment_intents FOREIGN KEY (payment_intent_id) REFERENCES public.stripe_record__payment_intents(id);


--
-- Name: stripe_record__charges fk_stripe_record_charges__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__charges
    ADD CONSTRAINT fk_stripe_record_charges__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record__charges fk_stripe_record_charges__users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__charges
    ADD CONSTRAINT fk_stripe_record_charges__users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: stripe_record__charges fk_stripe_record_charges_api_key_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__charges
    ADD CONSTRAINT fk_stripe_record_charges_api_key_account_id FOREIGN KEY (api_key_account_id) REFERENCES public.stripe_record__accounts(id);


--
-- Name: stripe_record__charges fk_stripe_record_charges_connect_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__charges
    ADD CONSTRAINT fk_stripe_record_charges_connect_account_id FOREIGN KEY (connect_account_id) REFERENCES public.stripe_record__accounts(id);


--
-- Name: stripe_record__invoices fk_stripe_record_invoices__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__invoices
    ADD CONSTRAINT fk_stripe_record_invoices__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record__payment_intents fk_stripe_record_payment_intents__invoices; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__payment_intents
    ADD CONSTRAINT fk_stripe_record_payment_intents__invoices FOREIGN KEY (invoice_id) REFERENCES public.stripe_record__invoices(id);


--
-- Name: stripe_record__payment_intents fk_stripe_record_payment_intents__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__payment_intents
    ADD CONSTRAINT fk_stripe_record_payment_intents__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record__refunds fk_stripe_record_payment_intents__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__refunds
    ADD CONSTRAINT fk_stripe_record_payment_intents__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record__payment_intents fk_stripe_record_payment_intents__users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__payment_intents
    ADD CONSTRAINT fk_stripe_record_payment_intents__users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: stripe_record__invoices fk_stripe_record_payment_intents__users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__invoices
    ADD CONSTRAINT fk_stripe_record_payment_intents__users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: stripe_record__payment_intents fk_stripe_record_payment_intents_api_key_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__payment_intents
    ADD CONSTRAINT fk_stripe_record_payment_intents_api_key_account_id FOREIGN KEY (api_key_account_id) REFERENCES public.stripe_record__accounts(id);


--
-- Name: stripe_record__payment_intents fk_stripe_record_payment_intents_connect_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__payment_intents
    ADD CONSTRAINT fk_stripe_record_payment_intents_connect_account_id FOREIGN KEY (connect_account_id) REFERENCES public.stripe_record__accounts(id);


--
-- Name: stripe_record__payment_methods fk_stripe_record_payment_methods__setup_intents; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__payment_methods
    ADD CONSTRAINT fk_stripe_record_payment_methods__setup_intents FOREIGN KEY (setup_intent_id) REFERENCES public.stripe_record__setup_intents(id);


--
-- Name: stripe_record__payment_methods fk_stripe_record_payment_methods__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__payment_methods
    ADD CONSTRAINT fk_stripe_record_payment_methods__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record__payment_methods fk_stripe_record_payment_methods__users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__payment_methods
    ADD CONSTRAINT fk_stripe_record_payment_methods__users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: stripe_record__payment_methods fk_stripe_record_payment_methods_api_key_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__payment_methods
    ADD CONSTRAINT fk_stripe_record_payment_methods_api_key_account_id FOREIGN KEY (api_key_account_id) REFERENCES public.stripe_record__accounts(id);


--
-- Name: stripe_record__payment_methods fk_stripe_record_payment_methods_connect_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__payment_methods
    ADD CONSTRAINT fk_stripe_record_payment_methods_connect_account_id FOREIGN KEY (connect_account_id) REFERENCES public.stripe_record__accounts(id);


--
-- Name: stripe_record__prices fk_stripe_record_prices__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__prices
    ADD CONSTRAINT fk_stripe_record_prices__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record__products fk_stripe_record_products__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__products
    ADD CONSTRAINT fk_stripe_record_products__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record__refunds fk_stripe_record_refunds__users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__refunds
    ADD CONSTRAINT fk_stripe_record_refunds__users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: stripe_record__refunds fk_stripe_record_refunds_api_key_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__refunds
    ADD CONSTRAINT fk_stripe_record_refunds_api_key_account_id FOREIGN KEY (api_key_account_id) REFERENCES public.stripe_record__accounts(id);


--
-- Name: stripe_record__refunds fk_stripe_record_refunds_connect_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__refunds
    ADD CONSTRAINT fk_stripe_record_refunds_connect_account_id FOREIGN KEY (connect_account_id) REFERENCES public.stripe_record__accounts(id);


--
-- Name: stripe_record__refunds fk_stripe_record_refunds_payment_intent_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__refunds
    ADD CONSTRAINT fk_stripe_record_refunds_payment_intent_id FOREIGN KEY (payment_intent_id) REFERENCES public.stripe_record__payment_intents(id);


--
-- Name: stripe_record__setup_intents fk_stripe_record_setup_intents__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__setup_intents
    ADD CONSTRAINT fk_stripe_record_setup_intents__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record__setup_intents fk_stripe_record_setup_intents__users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__setup_intents
    ADD CONSTRAINT fk_stripe_record_setup_intents__users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: stripe_record__setup_intents fk_stripe_record_setup_intents_api_key_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__setup_intents
    ADD CONSTRAINT fk_stripe_record_setup_intents_api_key_account_id FOREIGN KEY (api_key_account_id) REFERENCES public.stripe_record__accounts(id);


--
-- Name: stripe_record__setup_intents fk_stripe_record_setup_intents_connect_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__setup_intents
    ADD CONSTRAINT fk_stripe_record_setup_intents_connect_account_id FOREIGN KEY (connect_account_id) REFERENCES public.stripe_record__accounts(id);


--
-- Name: stripe_record__subscription_items fk_stripe_record_subscription_items__prices; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__subscription_items
    ADD CONSTRAINT fk_stripe_record_subscription_items__prices FOREIGN KEY (price_id) REFERENCES public.stripe_record__prices(id);


--
-- Name: stripe_record__subscription_items fk_stripe_record_subscription_items__subscriptions; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__subscription_items
    ADD CONSTRAINT fk_stripe_record_subscription_items__subscriptions FOREIGN KEY (subscription_id) REFERENCES public.stripe_record__subscriptions(id);


--
-- Name: stripe_record__subscription_items fk_stripe_record_subscription_items__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__subscription_items
    ADD CONSTRAINT fk_stripe_record_subscription_items__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record__subscription_schedules fk_stripe_record_subscription_schedules__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__subscription_schedules
    ADD CONSTRAINT fk_stripe_record_subscription_schedules__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record__subscriptions fk_stripe_record_subscriptions__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record__subscriptions
    ADD CONSTRAINT fk_stripe_record_subscriptions__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: tenant_stripe_accounts fk_tenant_stripe_accounts__stripe_accounts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_stripe_accounts
    ADD CONSTRAINT fk_tenant_stripe_accounts__stripe_accounts FOREIGN KEY (stripe_account_id) REFERENCES public.stripe_record__accounts(id);


--
-- Name: tenant_stripe_accounts fk_tenant_stripe_accounts__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_stripe_accounts
    ADD CONSTRAINT fk_tenant_stripe_accounts__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_profiles fk_user_profiles_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT fk_user_profiles_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_profiles fk_user_profiles_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT fk_user_profiles_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users__email_verifiers fk_users__email_verifiers_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users__email_verifiers
    ADD CONSTRAINT fk_users__email_verifiers_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: users__email_verifiers fk_users__email_verifiers_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users__email_verifiers
    ADD CONSTRAINT fk_users__email_verifiers_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users__linked_applications fk_users__linked_applications_oauth_applications; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users__linked_applications
    ADD CONSTRAINT fk_users__linked_applications_oauth_applications FOREIGN KEY (oauth_application_id) REFERENCES public.oauth_applications(id);


--
-- Name: users__linked_applications fk_users__linked_applications_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users__linked_applications
    ADD CONSTRAINT fk_users__linked_applications_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: users__linked_applications fk_users__linked_applications_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users__linked_applications
    ADD CONSTRAINT fk_users__linked_applications_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users__password_resets fk_users__password_resets_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users__password_resets
    ADD CONSTRAINT fk_users__password_resets_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: users__password_resets fk_users__password_resets_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users__password_resets
    ADD CONSTRAINT fk_users__password_resets_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users__sms_verifiers fk_users__sms_verifiers_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users__sms_verifiers
    ADD CONSTRAINT fk_users__sms_verifiers_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: users__sms_verifiers fk_users__sms_verifiers_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users__sms_verifiers
    ADD CONSTRAINT fk_users__sms_verifiers_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users fk_users_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 1EgMBrAZZaQHd6CgyfObOxx9cduScHz8RX9gNoq0bZStynd6dmny2ztsGhCbVDt

SET search_path TO "$user", public;

