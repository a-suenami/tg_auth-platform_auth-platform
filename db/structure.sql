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
-- Name: oauth_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    provider character varying NOT NULL,
    client_id character varying NOT NULL,
    client_secret character varying NOT NULL,
    auth_url character varying NOT NULL,
    token_url character varying NOT NULL,
    user_info_url character varying,
    scopes character varying DEFAULT ''::character varying NOT NULL
);


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
-- Name: tenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants (
    id public.citext NOT NULL,
    name character varying,
    domain character varying,
    sms_verification_required boolean DEFAULT false,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


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
-- Name: oauth_providers oauth_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_providers
    ADD CONSTRAINT oauth_providers_pkey PRIMARY KEY (id);


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
-- Name: tenant_settings tenant_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_settings
    ADD CONSTRAINT tenant_settings_pkey PRIMARY KEY (id);


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
-- Name: idx_rulers_uid_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_rulers_uid_uniq ON public.rulers USING btree (uid);


--
-- Name: idx_shopify_record__customers_store_name_email_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_shopify_record__customers_store_name_email_uniq ON public.shopify_record__customers USING btree (store_name, email);


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
-- Name: index_oauth_providers_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_providers_on_tenant_id ON public.oauth_providers USING btree (tenant_id);


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
-- Name: index_tenant_settings_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_settings_on_tenant_id ON public.tenant_settings USING btree (tenant_id);


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

SET search_path TO "$user", public;

