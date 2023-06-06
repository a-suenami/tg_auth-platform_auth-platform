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
    address_1 character varying,
    address_2 character varying,
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
    address_1 character varying,
    address_2 character varying,
    contact_tel character varying,
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
    login_url character varying,
    redirect_url_on_password_reset character varying
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
    enable_client_credential_flow boolean DEFAULT false
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
-- Name: tenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants (
    id public.citext NOT NULL,
    name character varying,
    domain character varying,
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
    tel character varying,
    tel_verified boolean DEFAULT false,
    email_verification_code character varying,
    email_verification_code_expired_at timestamp(6) without time zone,
    email_verification_code_remaining_attempts integer DEFAULT 0,
    email_verified boolean DEFAULT false,
    password_reset_code character varying,
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
-- Name: users__password_resets users__password_resets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users__password_resets
    ADD CONSTRAINT users__password_resets_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


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
-- Name: index_user_profiles_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_profiles_on_tenant_id ON public.user_profiles USING btree (tenant_id);


--
-- Name: index_user_profiles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_profiles_on_user_id ON public.user_profiles USING btree (user_id);


--
-- Name: index_users__password_resets_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users__password_resets_on_tenant_id ON public.users__password_resets USING btree (tenant_id);


--
-- Name: index_users__password_resets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users__password_resets_on_user_id ON public.users__password_resets USING btree (user_id);


--
-- Name: index_users_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_tenant_id ON public.users USING btree (tenant_id);


--
-- Name: index_users_on_tenant_id_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_tenant_id_email ON public.users USING btree (tenant_id, email);


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
-- Name: users fk_users_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

