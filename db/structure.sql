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
-- Name: contact_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contact_addresses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    is_default boolean,
    zip_code character varying,
    prefecture_code integer,
    city character varying,
    address1 character varying,
    address2 character varying,
    contact_tel character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: delivary_address; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivary_address (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    is_default boolean,
    zip_code character varying,
    prefecture_code integer,
    city character varying,
    address1 character varying,
    address2 character varying,
    contact_tel character varying,
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
    last_name_kane character varying,
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
    uid character varying NOT NULL,
    email character varying,
    encrypted_password character varying,
    tel character varying,
    tel_verified boolean DEFAULT false,
    email_confirm_code character varying,
    email_verified boolean DEFAULT false,
    password_reset_code character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: contact_addresses contact_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contact_addresses
    ADD CONSTRAINT contact_addresses_pkey PRIMARY KEY (id);


--
-- Name: delivary_address delivary_address_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivary_address
    ADD CONSTRAINT delivary_address_pkey PRIMARY KEY (id);


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
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_contact_addresses_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contact_addresses_on_tenant_id ON public.contact_addresses USING btree (tenant_id);


--
-- Name: index_contact_addresses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contact_addresses_on_user_id ON public.contact_addresses USING btree (user_id);


--
-- Name: index_delivary_address_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivary_address_on_tenant_id ON public.delivary_address USING btree (tenant_id);


--
-- Name: index_delivary_address_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivary_address_on_user_id ON public.delivary_address USING btree (user_id);


--
-- Name: index_user_profiles_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_profiles_on_tenant_id ON public.user_profiles USING btree (tenant_id);


--
-- Name: index_user_profiles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_profiles_on_user_id ON public.user_profiles USING btree (user_id);


--
-- Name: index_users_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_tenant_id ON public.users USING btree (tenant_id);


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
-- Name: delivary_address fk_delivary_address_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivary_address
    ADD CONSTRAINT fk_delivary_address_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: delivary_address fk_delivary_address_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivary_address
    ADD CONSTRAINT fk_delivary_address_users FOREIGN KEY (user_id) REFERENCES public.users(id);


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
-- Name: users fk_users_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

