\restrict dq2TbLJuuYcNnMGUC0rvLYYfABPluEBaTzBOETbLtGVgTgoG4iGhwT7wJE7cBqh

-- Dumped from database version 15.14
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
-- Name: auto_tagging_schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auto_tagging_schedules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_auto_tagging_id uuid NOT NULL,
    start_at timestamp(6) without time zone,
    end_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE auto_tagging_schedules; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.auto_tagging_schedules IS 'Time-based schedules for auto-tagging rules';


--
-- Name: COLUMN auto_tagging_schedules.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.auto_tagging_schedules.tenant_id IS 'Tenant reference';


--
-- Name: COLUMN auto_tagging_schedules.user_auto_tagging_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.auto_tagging_schedules.user_auto_tagging_id IS 'Auto-tagging rule reference (1:1)';


--
-- Name: COLUMN auto_tagging_schedules.start_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.auto_tagging_schedules.start_at IS 'Schedule start time (both null or both not null)';


--
-- Name: COLUMN auto_tagging_schedules.end_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.auto_tagging_schedules.end_at IS 'Schedule end time (both null or both not null)';


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
-- Name: deliveries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deliveries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    name character varying NOT NULL,
    template_id uuid NOT NULL,
    created_by_id uuid,
    updated_by_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE deliveries; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.deliveries IS 'Email delivery campaigns';


--
-- Name: COLUMN deliveries.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.deliveries.tenant_id IS 'Tenant reference';


--
-- Name: COLUMN deliveries.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.deliveries.name IS 'Delivery event name';


--
-- Name: COLUMN deliveries.template_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.deliveries.template_id IS 'Email template reference';


--
-- Name: COLUMN deliveries.created_by_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.deliveries.created_by_id IS 'Admin who created';


--
-- Name: COLUMN deliveries.updated_by_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.deliveries.updated_by_id IS 'Admin who last updated';


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
-- Name: delivery_birthdays; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_birthdays (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    delivery_id uuid NOT NULL,
    status character varying DEFAULT 'draft'::character varying NOT NULL,
    offset_days integer DEFAULT 0 NOT NULL,
    delivery_time character varying DEFAULT '09:00'::character varying NOT NULL,
    published_at timestamp(6) without time zone,
    published_by_id uuid,
    blastengine_delivery_id bigint,
    blastengine_job_id character varying,
    last_setup_date date,
    setup_completed_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE delivery_birthdays; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.delivery_birthdays IS 'Birthday-based delivery schedules';


--
-- Name: COLUMN delivery_birthdays.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_birthdays.tenant_id IS 'Tenant reference';


--
-- Name: COLUMN delivery_birthdays.delivery_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_birthdays.delivery_id IS 'Parent delivery';


--
-- Name: COLUMN delivery_birthdays.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_birthdays.status IS 'Birthday delivery status';


--
-- Name: COLUMN delivery_birthdays.offset_days; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_birthdays.offset_days IS 'Days offset from birthday (negative = before)';


--
-- Name: COLUMN delivery_birthdays.delivery_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_birthdays.delivery_time IS 'Delivery time HH:MM';


--
-- Name: COLUMN delivery_birthdays.published_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_birthdays.published_at IS 'When birthday delivery was activated';


--
-- Name: COLUMN delivery_birthdays.published_by_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_birthdays.published_by_id IS 'Admin who activated';


--
-- Name: COLUMN delivery_birthdays.blastengine_delivery_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_birthdays.blastengine_delivery_id IS 'Current day Blastengine bulk delivery ID';


--
-- Name: COLUMN delivery_birthdays.blastengine_job_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_birthdays.blastengine_job_id IS 'Current day CSV import job ID';


--
-- Name: COLUMN delivery_birthdays.last_setup_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_birthdays.last_setup_date IS 'Which date setup was done for';


--
-- Name: COLUMN delivery_birthdays.setup_completed_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_birthdays.setup_completed_at IS 'When bulk setup completed for current day';


--
-- Name: delivery_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    delivery_id uuid NOT NULL,
    admin_id uuid,
    transaction_time timestamp(6) without time zone NOT NULL,
    event_type character varying NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE delivery_events; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.delivery_events IS 'Delivery event log (for audit and inter-system communication)';


--
-- Name: COLUMN delivery_events.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_events.tenant_id IS 'Tenant reference';


--
-- Name: COLUMN delivery_events.delivery_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_events.delivery_id IS 'Delivery reference';


--
-- Name: COLUMN delivery_events.admin_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_events.admin_id IS 'Admin who triggered event (if applicable)';


--
-- Name: COLUMN delivery_events.transaction_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_events.transaction_time IS 'Event occurrence time';


--
-- Name: COLUMN delivery_events.event_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_events.event_type IS 'Event type: created, updated, published, cancelled, paused, resumed, sent, failed';


--
-- Name: COLUMN delivery_events.payload; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_events.payload IS 'Event details (metadata, changes, etc.)';


--
-- Name: delivery_recipients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_recipients (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    delivery_id uuid NOT NULL,
    user_id uuid NOT NULL,
    delivery_date date NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    scheduled_for timestamp(6) without time zone,
    sent_at timestamp(6) without time zone,
    error_message text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE delivery_recipients; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.delivery_recipients IS 'Recipients for each delivery (fixed at setup time)';


--
-- Name: COLUMN delivery_recipients.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_recipients.tenant_id IS 'Tenant reference';


--
-- Name: COLUMN delivery_recipients.delivery_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_recipients.delivery_id IS 'Delivery reference';


--
-- Name: COLUMN delivery_recipients.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_recipients.user_id IS 'Target user';


--
-- Name: COLUMN delivery_recipients.delivery_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_recipients.delivery_date IS 'Date of delivery batch (enables yearly birthday emails)';


--
-- Name: COLUMN delivery_recipients.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_recipients.status IS 'Delivery status from Blastengine';


--
-- Name: COLUMN delivery_recipients.scheduled_for; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_recipients.scheduled_for IS 'When this should be sent';


--
-- Name: COLUMN delivery_recipients.sent_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_recipients.sent_at IS 'When email was actually sent (from Blastengine)';


--
-- Name: COLUMN delivery_recipients.error_message; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_recipients.error_message IS 'Error message if failed';


--
-- Name: delivery_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_results (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    delivery_id uuid NOT NULL,
    delivery_schedule_id uuid,
    delivery_birthday_id uuid,
    blastengine_delivery_id bigint NOT NULL,
    delivery_date date,
    total_count integer DEFAULT 0 NOT NULL,
    sent_count integer DEFAULT 0 NOT NULL,
    drop_count integer DEFAULT 0 NOT NULL,
    soft_error_count integer DEFAULT 0 NOT NULL,
    hard_error_count integer DEFAULT 0 NOT NULL,
    open_count integer DEFAULT 0 NOT NULL,
    synced_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE delivery_results; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.delivery_results IS 'Aggregated delivery results from Blastengine';


--
-- Name: COLUMN delivery_results.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_results.tenant_id IS 'Tenant reference';


--
-- Name: COLUMN delivery_results.delivery_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_results.delivery_id IS 'Delivery reference';


--
-- Name: COLUMN delivery_results.delivery_schedule_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_results.delivery_schedule_id IS 'Schedule reference (for fixed-time deliveries)';


--
-- Name: COLUMN delivery_results.delivery_birthday_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_results.delivery_birthday_id IS 'Birthday reference (for birthday deliveries)';


--
-- Name: COLUMN delivery_results.blastengine_delivery_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_results.blastengine_delivery_id IS 'Blastengine bulk delivery ID';


--
-- Name: COLUMN delivery_results.delivery_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_results.delivery_date IS 'Date of delivery (for birthday daily results)';


--
-- Name: COLUMN delivery_results.total_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_results.total_count IS 'Total recipients';


--
-- Name: COLUMN delivery_results.sent_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_results.sent_count IS 'Successfully sent';


--
-- Name: COLUMN delivery_results.drop_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_results.drop_count IS 'Dropped (invalid email, etc.)';


--
-- Name: COLUMN delivery_results.soft_error_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_results.soft_error_count IS 'Soft bounce (temporary failure)';


--
-- Name: COLUMN delivery_results.hard_error_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_results.hard_error_count IS 'Hard bounce (permanent failure)';


--
-- Name: COLUMN delivery_results.open_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_results.open_count IS 'Opened emails';


--
-- Name: COLUMN delivery_results.synced_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_results.synced_at IS 'When results were last synced from Blastengine';


--
-- Name: delivery_schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_schedules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    delivery_id uuid NOT NULL,
    status character varying DEFAULT 'draft'::character varying NOT NULL,
    scheduled_at timestamp(6) without time zone,
    published_at timestamp(6) without time zone,
    published_by_id uuid,
    blastengine_delivery_id bigint,
    blastengine_job_id character varying,
    setup_completed_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE delivery_schedules; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.delivery_schedules IS 'Datetime-based delivery schedules';


--
-- Name: COLUMN delivery_schedules.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_schedules.tenant_id IS 'Tenant reference';


--
-- Name: COLUMN delivery_schedules.delivery_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_schedules.delivery_id IS 'Parent delivery';


--
-- Name: COLUMN delivery_schedules.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_schedules.status IS 'Schedule status';


--
-- Name: COLUMN delivery_schedules.scheduled_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_schedules.scheduled_at IS 'Scheduled delivery datetime';


--
-- Name: COLUMN delivery_schedules.published_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_schedules.published_at IS 'When schedule was published';


--
-- Name: COLUMN delivery_schedules.published_by_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_schedules.published_by_id IS 'Admin who published';


--
-- Name: COLUMN delivery_schedules.blastengine_delivery_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_schedules.blastengine_delivery_id IS 'Blastengine bulk delivery ID';


--
-- Name: COLUMN delivery_schedules.blastengine_job_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_schedules.blastengine_job_id IS 'Blastengine CSV import job ID';


--
-- Name: COLUMN delivery_schedules.setup_completed_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_schedules.setup_completed_at IS 'When bulk setup completed';


--
-- Name: delivery_user_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_user_tags (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    delivery_id uuid NOT NULL,
    user_tag_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE delivery_user_tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.delivery_user_tags IS 'Many-to-many: deliveries to user_tags';


--
-- Name: COLUMN delivery_user_tags.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_user_tags.tenant_id IS 'Tenant reference';


--
-- Name: COLUMN delivery_user_tags.delivery_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_user_tags.delivery_id IS 'Delivery reference';


--
-- Name: COLUMN delivery_user_tags.user_tag_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_user_tags.user_tag_id IS 'User tag reference';


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
-- Name: komoju_record_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.komoju_record_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    remote_id character varying NOT NULL,
    display_name character varying NOT NULL,
    secret_key_encrypted character varying NOT NULL,
    webhook_secret_encrypted character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN komoju_record_accounts.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.komoju_record_accounts.remote_id IS 'Komoju merchant ID';


--
-- Name: COLUMN komoju_record_accounts.display_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.komoju_record_accounts.display_name IS 'Account identification name for admin';


--
-- Name: COLUMN komoju_record_accounts.secret_key_encrypted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.komoju_record_accounts.secret_key_encrypted IS 'Encrypted Komoju secret key';


--
-- Name: COLUMN komoju_record_accounts.webhook_secret_encrypted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.komoju_record_accounts.webhook_secret_encrypted IS 'Encrypted webhook signature secret';


--
-- Name: komoju_record_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.komoju_record_payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    remote_id character varying NOT NULL,
    status character varying NOT NULL,
    amount integer NOT NULL,
    confirmation_code character varying,
    payment_deadline timestamp(6) without time zone,
    authorized_at timestamp(6) without time zone,
    captured_at timestamp(6) without time zone,
    expired_at timestamp(6) without time zone,
    komoju_data jsonb DEFAULT '{}'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN komoju_record_payments.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.komoju_record_payments.remote_id IS 'Komoju payment ID';


--
-- Name: COLUMN komoju_record_payments.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.komoju_record_payments.status IS 'authorized/captured/expired/cancelled';


--
-- Name: COLUMN komoju_record_payments.amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.komoju_record_payments.amount IS 'Amount in JPY';


--
-- Name: COLUMN komoju_record_payments.confirmation_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.komoju_record_payments.confirmation_code IS 'Payment code for user lookup';


--
-- Name: COLUMN komoju_record_payments.payment_deadline; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.komoju_record_payments.payment_deadline IS 'Payment expiration (for background jobs)';


--
-- Name: COLUMN komoju_record_payments.authorized_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.komoju_record_payments.authorized_at IS 'When payment created';


--
-- Name: COLUMN komoju_record_payments.captured_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.komoju_record_payments.captured_at IS 'When payment completed';


--
-- Name: COLUMN komoju_record_payments.expired_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.komoju_record_payments.expired_at IS 'When payment expired';


--
-- Name: COLUMN komoju_record_payments.komoju_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.komoju_record_payments.komoju_data IS 'Full API response';


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
    payment_type character varying NOT NULL,
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
-- Name: COLUMN membership_contract_terms.payment_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_contract_terms.payment_type IS '支払い方法: credit_card, convenience, campaign_code, external_linkageなど';


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
    expired_at timestamp(6) without time zone,
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
-- Name: COLUMN membership_contracts.expired_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_contracts.expired_at IS '失効日時';


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
-- Name: membership_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    membership_id uuid NOT NULL,
    membership_group_id uuid,
    membership_contract_id uuid,
    activated_at timestamp(6) without time zone,
    expired_at timestamp(6) without time zone,
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
-- Name: COLUMN membership_users.activated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_users.activated_at IS 'メンバーシップ有効化日時';


--
-- Name: COLUMN membership_users.expired_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_users.expired_at IS 'メンバーシップの失効日時';


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
-- Name: payment_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_subscriptions (
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
-- Name: TABLE payment_subscriptions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.payment_subscriptions IS '支払い取引情報';


--
-- Name: COLUMN payment_subscriptions.membership_contract_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment_subscriptions.membership_contract_id IS 'メンバーシップ契約ID';


--
-- Name: COLUMN payment_subscriptions.subscribable_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment_subscriptions.subscribable_id IS 'サブスクリプションオブジェクト';


--
-- Name: payment_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    membership_contract_id uuid NOT NULL,
    payment_type character varying NOT NULL,
    payment_provider character varying,
    activated_at timestamp(6) without time zone,
    expired_at timestamp(6) without time zone,
    status character varying NOT NULL,
    recurrence boolean DEFAULT false NOT NULL,
    paid_amount integer DEFAULT 0 NOT NULL,
    chargeable_id uuid,
    chargeable_type character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE payment_transactions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.payment_transactions IS '支払い取引情報';


--
-- Name: COLUMN payment_transactions.membership_contract_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment_transactions.membership_contract_id IS 'メンバーシップ契約ID';


--
-- Name: COLUMN payment_transactions.payment_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment_transactions.payment_type IS '支払い方法: credit_card, convenience, campaign_code, external_linkage';


--
-- Name: COLUMN payment_transactions.payment_provider; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment_transactions.payment_provider IS '決済プロバイダ: stripe, komojuなど';


--
-- Name: COLUMN payment_transactions.activated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment_transactions.activated_at IS '有効化日時';


--
-- Name: COLUMN payment_transactions.expired_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment_transactions.expired_at IS '失効日時';


--
-- Name: COLUMN payment_transactions.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment_transactions.status IS 'ステータス';


--
-- Name: COLUMN payment_transactions.recurrence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment_transactions.recurrence IS '定期課金フラグ: true=サブスクリプション, false=買い切り';


--
-- Name: COLUMN payment_transactions.paid_amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment_transactions.paid_amount IS '支払い済み金額';


--
-- Name: COLUMN payment_transactions.chargeable_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment_transactions.chargeable_id IS '決済情報';


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
-- Name: stripe_record_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record_accounts (
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
-- Name: COLUMN stripe_record_accounts.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_accounts.remote_id IS 'Stripe のアカウント ID';


--
-- Name: COLUMN stripe_record_accounts.display_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_accounts.display_name IS 'API キーがどのアカウントのものかを識別するための名前';


--
-- Name: stripe_record_api_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record_api_keys (
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
-- Name: COLUMN stripe_record_api_keys.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_api_keys.remote_id IS 'Stripe の API キー ID';


--
-- Name: COLUMN stripe_record_api_keys.display_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_api_keys.display_name IS 'API キーがどのアカウントのものかを識別するための名前';


--
-- Name: stripe_record_charges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record_charges (
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
-- Name: COLUMN stripe_record_charges.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_charges.remote_id IS 'Stripe の charge ID';


--
-- Name: COLUMN stripe_record_charges.api_key_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_charges.api_key_account_id IS 'API Key を持っているアカウント。通常の決済であればその決済のアカウントとなる。Connect の場合はプラットフォームアカウントになる。';


--
-- Name: COLUMN stripe_record_charges.connect_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_charges.connect_account_id IS 'Connect のときだけ使用する。この決済がどの Connected アカウントに対する支払いなのかを表す。';


--
-- Name: COLUMN stripe_record_charges.charge_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_charges.charge_type IS 'Connect のときだけ使用する。どの支払いタイプなのかを表す';


--
-- Name: stripe_record_invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record_invoices (
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
-- Name: COLUMN stripe_record_invoices.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_invoices.remote_id IS 'Stripe の invoices ID';


--
-- Name: COLUMN stripe_record_invoices.payment_source_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_invoices.payment_source_id IS 'subscription or charge';


--
-- Name: COLUMN stripe_record_invoices.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_invoices.status IS 'draft, open, paid, uncollectible, or void';


--
-- Name: COLUMN stripe_record_invoices.confirmation_secret; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_invoices.confirmation_secret IS 'confirmation_secret payment_intent.secret';


--
-- Name: COLUMN stripe_record_invoices.confirmation_secret_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_invoices.confirmation_secret_type IS '基本的にはpayment_intentのみ';


--
-- Name: stripe_record_payment_intents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record_payment_intents (
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
-- Name: COLUMN stripe_record_payment_intents.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_payment_intents.remote_id IS 'Stripe の payment intent ID';


--
-- Name: COLUMN stripe_record_payment_intents.chargeable_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_payment_intents.chargeable_id IS 'subscription or charge';


--
-- Name: COLUMN stripe_record_payment_intents.latest_charge_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_payment_intents.latest_charge_id IS 'latest charge';


--
-- Name: COLUMN stripe_record_payment_intents.api_key_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_payment_intents.api_key_account_id IS 'API Key を持っているアカウント。通常の決済であればその決済のアカウントとなる。Connect の場合はプラットフォームアカウントになる。';


--
-- Name: COLUMN stripe_record_payment_intents.connect_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_payment_intents.connect_account_id IS 'Connect のときだけ使用する。この決済がどの Connected アカウントに対する支払いなのかを表す。';


--
-- Name: COLUMN stripe_record_payment_intents.charge_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_payment_intents.charge_type IS 'Connect のときだけ使用する。どの支払いタイプなのかを表す';


--
-- Name: stripe_record_payment_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record_payment_methods (
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
-- Name: COLUMN stripe_record_payment_methods.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_payment_methods.remote_id IS 'Stripe の payment method ID';


--
-- Name: COLUMN stripe_record_payment_methods.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_payment_methods.type IS 'payment method の種類。card など';


--
-- Name: COLUMN stripe_record_payment_methods.billing_details; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_payment_methods.billing_details IS '請求先情報';


--
-- Name: COLUMN stripe_record_payment_methods.card; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_payment_methods.card IS 'card の詳細情報';


--
-- Name: COLUMN stripe_record_payment_methods.customer_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_payment_methods.customer_id IS 'この PaymentMethod の持ち主の customer ID';


--
-- Name: COLUMN stripe_record_payment_methods.detached_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_payment_methods.detached_at IS 'detach された日時';


--
-- Name: COLUMN stripe_record_payment_methods.api_key_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_payment_methods.api_key_account_id IS 'API Key を持っているアカウント。通常の決済であればその決済のアカウントとなる。Connect の場合はプラットフォームアカウントになる。';


--
-- Name: COLUMN stripe_record_payment_methods.connect_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_payment_methods.connect_account_id IS 'Connect のときだけ使用する。この決済がどの Connected アカウントに対する支払いなのかを表す。';


--
-- Name: COLUMN stripe_record_payment_methods.charge_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_payment_methods.charge_type IS 'Connect のときだけ使用する。どの支払いタイプなのかを表す';


--
-- Name: stripe_record_prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record_prices (
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
-- Name: stripe_record_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record_products (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    remote_id character varying,
    name character varying,
    deleted boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: stripe_record_refunds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record_refunds (
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
-- Name: COLUMN stripe_record_refunds.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_refunds.remote_id IS 'Stripe の refund ID';


--
-- Name: COLUMN stripe_record_refunds.api_key_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_refunds.api_key_account_id IS 'API Key を持っているアカウント。通常の決済であればその決済のアカウントとなる。Connect の場合はプラットフォームアカウントになる。';


--
-- Name: COLUMN stripe_record_refunds.connect_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_refunds.connect_account_id IS 'Connect のときだけ使用する。この決済がどの Connected アカウントに対する支払いなのかを表す。';


--
-- Name: COLUMN stripe_record_refunds.charge_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_refunds.charge_type IS 'Connect のときだけ使用する。どの支払いタイプなのかを表す';


--
-- Name: stripe_record_setup_intents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record_setup_intents (
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
-- Name: COLUMN stripe_record_setup_intents.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_setup_intents.remote_id IS 'Stripe の setup intent ID';


--
-- Name: COLUMN stripe_record_setup_intents.activated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_setup_intents.activated_at IS 'このカードが有効になった日時。NULL だがカードの登録自体には成功している場合、この SetupIntent で登録されたカードは定期的に削除する。';


--
-- Name: COLUMN stripe_record_setup_intents.api_key_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_setup_intents.api_key_account_id IS 'API Key を持っているアカウント。通常の決済であればその決済のアカウントとなる。Connect の場合はプラットフォームアカウントになる。';


--
-- Name: COLUMN stripe_record_setup_intents.connect_account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_setup_intents.connect_account_id IS 'Connect のときだけ使用する。この決済がどの Connected アカウントに対する支払いなのかを表す。';


--
-- Name: COLUMN stripe_record_setup_intents.charge_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_setup_intents.charge_type IS 'Connect のときだけ使用する。どの支払いタイプなのかを表す';


--
-- Name: stripe_record_subscription_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record_subscription_items (
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
-- Name: stripe_record_subscription_schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record_subscription_schedules (
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
-- Name: stripe_record_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record_subscriptions (
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
-- Name: COLUMN stripe_record_subscriptions.current_period_start; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_subscriptions.current_period_start IS '現在の請求期間の開始日時';


--
-- Name: COLUMN stripe_record_subscriptions.current_period_end; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_subscriptions.current_period_end IS '現在の請求期間の終了日時';


--
-- Name: COLUMN stripe_record_subscriptions.trial_period_days; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_subscriptions.trial_period_days IS 'トライアル日数';


--
-- Name: COLUMN stripe_record_subscriptions.trial_end; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_subscriptions.trial_end IS 'トライアル終了日時';


--
-- Name: COLUMN stripe_record_subscriptions.trial_start; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_subscriptions.trial_start IS 'トライアル開始日時';


--
-- Name: stripe_record_trial_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_record_trial_histories (
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
-- Name: TABLE stripe_record_trial_histories; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.stripe_record_trial_histories IS 'Stripeのトライアル履歴';


--
-- Name: COLUMN stripe_record_trial_histories.fingerprint; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_trial_histories.fingerprint IS '決済手段のユニークな識別子(ex: クレジットカードのfingerprint)';


--
-- Name: COLUMN stripe_record_trial_histories.trial_start; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_trial_histories.trial_start IS 'トライアル開始日時';


--
-- Name: COLUMN stripe_record_trial_histories.trial_end; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_trial_histories.trial_end IS 'トライアル終了日時';


--
-- Name: COLUMN stripe_record_trial_histories.trial_period_days; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stripe_record_trial_histories.trial_period_days IS 'トライアル日数';


--
-- Name: template_mail_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.template_mail_histories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    template_id uuid NOT NULL,
    version_id uuid,
    event_type character varying NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    actor_id uuid,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN template_mail_histories.template_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.template_mail_histories.template_id IS 'Parent template';


--
-- Name: COLUMN template_mail_histories.version_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.template_mail_histories.version_id IS 'Mail template version (nullable)';


--
-- Name: COLUMN template_mail_histories.event_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.template_mail_histories.event_type IS 'Event type: published, scheduled, rescheduled, draft_created, draft_updated';


--
-- Name: COLUMN template_mail_histories.payload; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.template_mail_histories.payload IS 'Event metadata';


--
-- Name: COLUMN template_mail_histories.actor_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.template_mail_histories.actor_id IS 'Admin who performed action';


--
-- Name: template_mail_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.template_mail_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    template_id uuid NOT NULL,
    version integer NOT NULL,
    title character varying NOT NULL,
    body text NOT NULL,
    public_started_at timestamp(6) without time zone NOT NULL,
    published_by_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN template_mail_versions.template_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.template_mail_versions.template_id IS 'Parent template';


--
-- Name: COLUMN template_mail_versions.version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.template_mail_versions.version IS 'バージョン番号';


--
-- Name: COLUMN template_mail_versions.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.template_mail_versions.title IS 'メールタイトル（スナップショット）';


--
-- Name: COLUMN template_mail_versions.body; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.template_mail_versions.body IS 'メール本文（スナップショット）';


--
-- Name: COLUMN template_mail_versions.public_started_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.template_mail_versions.public_started_at IS '公開開始日時';


--
-- Name: COLUMN template_mail_versions.published_by_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.template_mail_versions.published_by_id IS '公開者（Admin）';


--
-- Name: template_mails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.template_mails (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    template_id uuid NOT NULL,
    title character varying,
    body text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN template_mails.template_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.template_mails.template_id IS 'Parent template';


--
-- Name: COLUMN template_mails.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.template_mails.title IS 'メールタイトル（現在の下書き）';


--
-- Name: COLUMN template_mails.body; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.template_mails.body IS 'メール本文（現在の下書き）';


--
-- Name: templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN templates.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.templates.name IS 'テンプレート名';


--
-- Name: tenant_komoju_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_komoju_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    komoju_account_id uuid NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    default_expiry_days integer DEFAULT 7 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN tenant_komoju_accounts.enabled; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant_komoju_accounts.enabled IS 'Whether Komoju payment is enabled for this tenant';


--
-- Name: COLUMN tenant_komoju_accounts.default_expiry_days; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant_komoju_accounts.default_expiry_days IS 'Default payment expiration in days for konbini';


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
    membership_grace_period_minutes integer DEFAULT 60 NOT NULL,
    send_subscription_update_succeeded_email_for_all_intervals boolean DEFAULT false NOT NULL,
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
-- Name: COLUMN tenant_stripe_accounts.membership_grace_period_minutes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant_stripe_accounts.membership_grace_period_minutes IS 'メンバーシップの有効期限の猶予期間（分）';


--
-- Name: COLUMN tenant_stripe_accounts.send_subscription_update_succeeded_email_for_all_intervals; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant_stripe_accounts.send_subscription_update_succeeded_email_for_all_intervals IS 'すべてのインターバルでサブスクリプション更新成功メールを送信するかどうか';


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
-- Name: user_auto_tagging_rule_blocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_auto_tagging_rule_blocks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_auto_tagging_id uuid NOT NULL,
    "position" integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE user_auto_tagging_rule_blocks; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_auto_tagging_rule_blocks IS 'Rule blocks (OR logic between blocks)';


--
-- Name: COLUMN user_auto_tagging_rule_blocks.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_tagging_rule_blocks.tenant_id IS 'Tenant reference';


--
-- Name: COLUMN user_auto_tagging_rule_blocks.user_auto_tagging_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_tagging_rule_blocks.user_auto_tagging_id IS 'Auto-tagging rule reference';


--
-- Name: COLUMN user_auto_tagging_rule_blocks."position"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_tagging_rule_blocks."position" IS 'Display order';


--
-- Name: user_auto_tagging_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_auto_tagging_rules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    rule_block_id uuid NOT NULL,
    condition_type character varying NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    "position" integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE user_auto_tagging_rules; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_auto_tagging_rules IS 'Individual rules within blocks (AND logic within block)';


--
-- Name: COLUMN user_auto_tagging_rules.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_tagging_rules.tenant_id IS 'Tenant reference';


--
-- Name: COLUMN user_auto_tagging_rules.rule_block_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_tagging_rules.rule_block_id IS 'Rule block reference';


--
-- Name: COLUMN user_auto_tagging_rules.condition_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_tagging_rules.condition_type IS 'Type: membership, plan, prefecture, gender, age, account_link';


--
-- Name: COLUMN user_auto_tagging_rules.config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_tagging_rules.config IS 'Condition configuration (varies by type)';


--
-- Name: COLUMN user_auto_tagging_rules."position"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_tagging_rules."position" IS 'Display order within block';


--
-- Name: user_auto_tagging_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_auto_tagging_tags (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_auto_tagging_id uuid NOT NULL,
    user_tag_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE user_auto_tagging_tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_auto_tagging_tags IS 'Tags assigned by auto-tagging rules';


--
-- Name: COLUMN user_auto_tagging_tags.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_tagging_tags.tenant_id IS 'Tenant reference';


--
-- Name: COLUMN user_auto_tagging_tags.user_auto_tagging_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_tagging_tags.user_auto_tagging_id IS 'Auto-tagging rule reference';


--
-- Name: COLUMN user_auto_tagging_tags.user_tag_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_tagging_tags.user_tag_id IS 'Tag to assign';


--
-- Name: user_auto_taggings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_auto_taggings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    name character varying NOT NULL,
    description text,
    enabled boolean DEFAULT true NOT NULL,
    shareable boolean DEFAULT false NOT NULL,
    created_by_id uuid,
    updated_by_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE user_auto_taggings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_auto_taggings IS 'Auto-tagging rules for users';


--
-- Name: COLUMN user_auto_taggings.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_taggings.tenant_id IS 'Tenant reference';


--
-- Name: COLUMN user_auto_taggings.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_taggings.name IS 'Rule name (CMS display)';


--
-- Name: COLUMN user_auto_taggings.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_taggings.description IS 'Rule description';


--
-- Name: COLUMN user_auto_taggings.enabled; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_taggings.enabled IS 'Whether rule is active';


--
-- Name: COLUMN user_auto_taggings.shareable; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_taggings.shareable IS 'Tag shareable with linked apps (連携タグ設定)';


--
-- Name: COLUMN user_auto_taggings.created_by_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_taggings.created_by_id IS 'Admin who created this rule';


--
-- Name: COLUMN user_auto_taggings.updated_by_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_auto_taggings.updated_by_id IS 'Admin who last updated this rule';


--
-- Name: user_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    transaction_time timestamp(6) without time zone NOT NULL,
    event_type character varying NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE user_events; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_events IS 'ユーザーイベント履歴';


--
-- Name: COLUMN user_events.transaction_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_events.transaction_time IS 'イベント発生日時';


--
-- Name: COLUMN user_events.event_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_events.event_type IS 'イベント種別: created, manually_tagged, auto_tagged など';


--
-- Name: COLUMN user_events.payload; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_events.payload IS 'イベント詳細データ';


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
-- Name: user_tag_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_tag_assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    user_tag_id uuid NOT NULL,
    assignment_type character varying NOT NULL,
    assigned_by_id uuid,
    user_auto_tagging_id uuid,
    assigned_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE user_tag_assignments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_tag_assignments IS 'User tag assignments (manual and auto)';


--
-- Name: COLUMN user_tag_assignments.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_tag_assignments.tenant_id IS 'Tenant reference';


--
-- Name: COLUMN user_tag_assignments.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_tag_assignments.user_id IS 'User being tagged';


--
-- Name: COLUMN user_tag_assignments.user_tag_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_tag_assignments.user_tag_id IS 'Tag being assigned';


--
-- Name: COLUMN user_tag_assignments.assignment_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_tag_assignments.assignment_type IS 'Type: manual or auto';


--
-- Name: COLUMN user_tag_assignments.assigned_by_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_tag_assignments.assigned_by_id IS 'Admin who manually assigned (for manual only)';


--
-- Name: COLUMN user_tag_assignments.user_auto_tagging_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_tag_assignments.user_auto_tagging_id IS 'Auto-tagging rule that assigned (for auto only)';


--
-- Name: COLUMN user_tag_assignments.assigned_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_tag_assignments.assigned_at IS 'When tag was assigned';


--
-- Name: user_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_tags (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    name character varying NOT NULL,
    description text,
    created_by_id uuid,
    updated_by_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: TABLE user_tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_tags IS 'User tags for manual tagging';


--
-- Name: COLUMN user_tags.tenant_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_tags.tenant_id IS 'Tenant reference';


--
-- Name: COLUMN user_tags.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_tags.name IS 'Tag name';


--
-- Name: COLUMN user_tags.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_tags.description IS 'Tag description';


--
-- Name: COLUMN user_tags.created_by_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_tags.created_by_id IS 'Admin who created this tag';


--
-- Name: COLUMN user_tags.updated_by_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_tags.updated_by_id IS 'Admin who last updated this tag';


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
-- Name: auto_tagging_schedules auto_tagging_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auto_tagging_schedules
    ADD CONSTRAINT auto_tagging_schedules_pkey PRIMARY KEY (id);


--
-- Name: contact_addresses contact_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contact_addresses
    ADD CONSTRAINT contact_addresses_pkey PRIMARY KEY (id);


--
-- Name: deliveries deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_pkey PRIMARY KEY (id);


--
-- Name: delivery_addresses delivery_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_addresses
    ADD CONSTRAINT delivery_addresses_pkey PRIMARY KEY (id);


--
-- Name: delivery_birthdays delivery_birthdays_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_birthdays
    ADD CONSTRAINT delivery_birthdays_pkey PRIMARY KEY (id);


--
-- Name: delivery_events delivery_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_events
    ADD CONSTRAINT delivery_events_pkey PRIMARY KEY (id);


--
-- Name: delivery_recipients delivery_recipients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_recipients
    ADD CONSTRAINT delivery_recipients_pkey PRIMARY KEY (id);


--
-- Name: delivery_results delivery_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_results
    ADD CONSTRAINT delivery_results_pkey PRIMARY KEY (id);


--
-- Name: delivery_schedules delivery_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_schedules
    ADD CONSTRAINT delivery_schedules_pkey PRIMARY KEY (id);


--
-- Name: delivery_user_tags delivery_user_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_user_tags
    ADD CONSTRAINT delivery_user_tags_pkey PRIMARY KEY (id);


--
-- Name: email_templates email_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_templates
    ADD CONSTRAINT email_templates_pkey PRIMARY KEY (id);


--
-- Name: komoju_record_accounts komoju_record_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.komoju_record_accounts
    ADD CONSTRAINT komoju_record_accounts_pkey PRIMARY KEY (id);


--
-- Name: komoju_record_payments komoju_record_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.komoju_record_payments
    ADD CONSTRAINT komoju_record_payments_pkey PRIMARY KEY (id);


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
-- Name: payment_subscriptions payment_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_subscriptions
    ADD CONSTRAINT payment_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: payment_transactions payment_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_transactions
    ADD CONSTRAINT payment_transactions_pkey PRIMARY KEY (id);


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
-- Name: stripe_record_accounts stripe_record_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_accounts
    ADD CONSTRAINT stripe_record_accounts_pkey PRIMARY KEY (id);


--
-- Name: stripe_record_api_keys stripe_record_api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_api_keys
    ADD CONSTRAINT stripe_record_api_keys_pkey PRIMARY KEY (id);


--
-- Name: stripe_record_charges stripe_record_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_charges
    ADD CONSTRAINT stripe_record_charges_pkey PRIMARY KEY (id);


--
-- Name: stripe_record_invoices stripe_record_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_invoices
    ADD CONSTRAINT stripe_record_invoices_pkey PRIMARY KEY (id);


--
-- Name: stripe_record_payment_intents stripe_record_payment_intents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_payment_intents
    ADD CONSTRAINT stripe_record_payment_intents_pkey PRIMARY KEY (id);


--
-- Name: stripe_record_payment_methods stripe_record_payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_payment_methods
    ADD CONSTRAINT stripe_record_payment_methods_pkey PRIMARY KEY (id);


--
-- Name: stripe_record_prices stripe_record_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_prices
    ADD CONSTRAINT stripe_record_prices_pkey PRIMARY KEY (id);


--
-- Name: stripe_record_products stripe_record_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_products
    ADD CONSTRAINT stripe_record_products_pkey PRIMARY KEY (id);


--
-- Name: stripe_record_refunds stripe_record_refunds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_refunds
    ADD CONSTRAINT stripe_record_refunds_pkey PRIMARY KEY (id);


--
-- Name: stripe_record_setup_intents stripe_record_setup_intents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_setup_intents
    ADD CONSTRAINT stripe_record_setup_intents_pkey PRIMARY KEY (id);


--
-- Name: stripe_record_subscription_items stripe_record_subscription_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_subscription_items
    ADD CONSTRAINT stripe_record_subscription_items_pkey PRIMARY KEY (id);


--
-- Name: stripe_record_subscription_schedules stripe_record_subscription_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_subscription_schedules
    ADD CONSTRAINT stripe_record_subscription_schedules_pkey PRIMARY KEY (id);


--
-- Name: stripe_record_subscriptions stripe_record_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_subscriptions
    ADD CONSTRAINT stripe_record_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: stripe_record_trial_histories stripe_record_trial_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_trial_histories
    ADD CONSTRAINT stripe_record_trial_histories_pkey PRIMARY KEY (id);


--
-- Name: template_mail_histories template_mail_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_mail_histories
    ADD CONSTRAINT template_mail_histories_pkey PRIMARY KEY (id);


--
-- Name: template_mail_versions template_mail_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_mail_versions
    ADD CONSTRAINT template_mail_versions_pkey PRIMARY KEY (id);


--
-- Name: template_mails template_mails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_mails
    ADD CONSTRAINT template_mails_pkey PRIMARY KEY (id);


--
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);


--
-- Name: tenant_komoju_accounts tenant_komoju_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_komoju_accounts
    ADD CONSTRAINT tenant_komoju_accounts_pkey PRIMARY KEY (id);


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
-- Name: user_auto_tagging_rule_blocks user_auto_tagging_rule_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auto_tagging_rule_blocks
    ADD CONSTRAINT user_auto_tagging_rule_blocks_pkey PRIMARY KEY (id);


--
-- Name: user_auto_tagging_rules user_auto_tagging_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auto_tagging_rules
    ADD CONSTRAINT user_auto_tagging_rules_pkey PRIMARY KEY (id);


--
-- Name: user_auto_tagging_tags user_auto_tagging_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auto_tagging_tags
    ADD CONSTRAINT user_auto_tagging_tags_pkey PRIMARY KEY (id);


--
-- Name: user_auto_taggings user_auto_taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auto_taggings
    ADD CONSTRAINT user_auto_taggings_pkey PRIMARY KEY (id);


--
-- Name: user_events user_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_events
    ADD CONSTRAINT user_events_pkey PRIMARY KEY (id);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);


--
-- Name: user_tag_assignments user_tag_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tag_assignments
    ADD CONSTRAINT user_tag_assignments_pkey PRIMARY KEY (id);


--
-- Name: user_tags user_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tags
    ADD CONSTRAINT user_tags_pkey PRIMARY KEY (id);


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
-- Name: idx_auto_tagging_tags_tenant_tag_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_auto_tagging_tags_tenant_tag_unique ON public.user_auto_tagging_tags USING btree (tenant_id, user_tag_id);


--
-- Name: idx_contact_addresses_tenant_id_user_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_contact_addresses_tenant_id_user_id_uniq ON public.contact_addresses USING btree (tenant_id, user_id);


--
-- Name: idx_delivery_birthdays_blastengine; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_delivery_birthdays_blastengine ON public.delivery_birthdays USING btree (blastengine_delivery_id);


--
-- Name: idx_delivery_birthdays_delivery_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_delivery_birthdays_delivery_unique ON public.delivery_birthdays USING btree (delivery_id);


--
-- Name: idx_delivery_events_tenant_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_delivery_events_tenant_time ON public.delivery_events USING btree (tenant_id, transaction_time);


--
-- Name: idx_delivery_events_timeline; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_delivery_events_timeline ON public.delivery_events USING btree (delivery_id, transaction_time);


--
-- Name: idx_delivery_recipients_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_delivery_recipients_date ON public.delivery_recipients USING btree (delivery_id, delivery_date);


--
-- Name: idx_delivery_recipients_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_delivery_recipients_status ON public.delivery_recipients USING btree (delivery_id, status);


--
-- Name: idx_delivery_recipients_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_delivery_recipients_unique ON public.delivery_recipients USING btree (delivery_id, user_id, delivery_date);


--
-- Name: idx_delivery_results_blastengine_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_delivery_results_blastengine_unique ON public.delivery_results USING btree (blastengine_delivery_id);


--
-- Name: idx_delivery_results_delivery_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_delivery_results_delivery_date ON public.delivery_results USING btree (delivery_id, delivery_date);


--
-- Name: idx_delivery_schedules_blastengine; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_delivery_schedules_blastengine ON public.delivery_schedules USING btree (blastengine_delivery_id);


--
-- Name: idx_delivery_schedules_delivery_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_delivery_schedules_delivery_unique ON public.delivery_schedules USING btree (delivery_id);


--
-- Name: idx_delivery_schedules_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_delivery_schedules_pending ON public.delivery_schedules USING btree (status, scheduled_at);


--
-- Name: idx_delivery_user_tags_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_delivery_user_tags_unique ON public.delivery_user_tags USING btree (delivery_id, user_tag_id);


--
-- Name: idx_komoju_payments_payment_deadline; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_komoju_payments_payment_deadline ON public.komoju_record_payments USING btree (payment_deadline);


--
-- Name: idx_komoju_payments_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_komoju_payments_status ON public.komoju_record_payments USING btree (status);


--
-- Name: idx_komoju_payments_tenant_remote_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_komoju_payments_tenant_remote_id_uniq ON public.komoju_record_payments USING btree (tenant_id, remote_id);


--
-- Name: idx_komoju_record_accounts_remote_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_komoju_record_accounts_remote_id_uniq ON public.komoju_record_accounts USING btree (remote_id);


--
-- Name: idx_linked_applications_tenant_user_oauth_application_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_linked_applications_tenant_user_oauth_application_uniq ON public.users__linked_applications USING btree (tenant_id, user_id, oauth_application_id);


--
-- Name: idx_membership_contracts_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_membership_contracts_expired_at ON public.membership_contracts USING btree (expired_at);


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
-- Name: idx_membership_users_tenant_user_membership_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_membership_users_tenant_user_membership_uniq ON public.membership_users USING btree (tenant_id, user_id, membership_id);


--
-- Name: idx_on_chargeable_type_chargeable_id_b73c319e28; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_chargeable_type_chargeable_id_b73c319e28 ON public.stripe_record_payment_intents USING btree (chargeable_type, chargeable_id);


--
-- Name: idx_on_chargeable_type_chargeable_id_c87a4bad66; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_chargeable_type_chargeable_id_c87a4bad66 ON public.payment_transactions USING btree (chargeable_type, chargeable_id);


--
-- Name: idx_on_membership_plan_id_abf7e120d7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_membership_plan_id_abf7e120d7 ON public.membership_plan_payment_method_mappings USING btree (membership_plan_id);


--
-- Name: idx_on_membership_plan_payment_method_id_45519b8566; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_membership_plan_payment_method_id_45519b8566 ON public.membership_plan_payment_method_mappings USING btree (membership_plan_payment_method_id);


--
-- Name: idx_on_payment_source_type_payment_source_id_3bc82c7377; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_payment_source_type_payment_source_id_3bc82c7377 ON public.stripe_record_invoices USING btree (payment_source_type, payment_source_id);


--
-- Name: idx_on_priceable_type_priceable_id_bc1644aaac; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_priceable_type_priceable_id_bc1644aaac ON public.membership_plan_payment_method_mappings USING btree (priceable_type, priceable_id);


--
-- Name: idx_on_stripe_record_subscription_id_95f8fd9518; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_stripe_record_subscription_id_95f8fd9518 ON public.stripe_record_trial_histories USING btree (stripe_record_subscription_id);


--
-- Name: idx_on_subscribable_type_subscribable_id_023c9144d9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_subscribable_type_subscribable_id_023c9144d9 ON public.payment_subscriptions USING btree (subscribable_type, subscribable_id);


--
-- Name: idx_on_user_auto_tagging_id_position_b71f663284; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_user_auto_tagging_id_position_b71f663284 ON public.user_auto_tagging_rule_blocks USING btree (user_auto_tagging_id, "position");


--
-- Name: idx_payment_subscriptions_tenant_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_subscriptions_tenant_user ON public.payment_subscriptions USING btree (tenant_id, user_id);


--
-- Name: idx_payment_transactions_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_transactions_expired_at ON public.payment_transactions USING btree (expired_at);


--
-- Name: idx_payment_transactions_tenant_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_transactions_tenant_user ON public.payment_transactions USING btree (tenant_id, user_id);


--
-- Name: idx_rulers_uid_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_rulers_uid_uniq ON public.rulers USING btree (uid);


--
-- Name: idx_shopify_record__customers_store_name_email_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_shopify_record__customers_store_name_email_uniq ON public.shopify_record__customers USING btree (store_name, email);


--
-- Name: idx_stripe_record_api_keys_remote_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_stripe_record_api_keys_remote_id_uniq ON public.stripe_record_api_keys USING btree (remote_id);


--
-- Name: idx_stripe_record_charge_remote_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_stripe_record_charge_remote_id_uniq ON public.stripe_record_charges USING btree (remote_id);


--
-- Name: idx_stripe_record_invoices_remote_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_stripe_record_invoices_remote_id_uniq ON public.stripe_record_invoices USING btree (remote_id);


--
-- Name: idx_stripe_record_payment_intent_remote_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_stripe_record_payment_intent_remote_id_uniq ON public.stripe_record_payment_intents USING btree (remote_id);


--
-- Name: idx_stripe_record_payment_methods_remote_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_stripe_record_payment_methods_remote_id_uniq ON public.stripe_record_payment_methods USING btree (remote_id);


--
-- Name: idx_stripe_record_refund_remote_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_stripe_record_refund_remote_id_uniq ON public.stripe_record_refunds USING btree (remote_id);


--
-- Name: idx_stripe_record_setup_intents_remote_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_stripe_record_setup_intents_remote_id_uniq ON public.stripe_record_setup_intents USING btree (remote_id);


--
-- Name: idx_stripe_record_trial_histories_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_stripe_record_trial_histories_unique ON public.stripe_record_trial_histories USING btree (tenant_id, membership_id, fingerprint);


--
-- Name: idx_template_mail_histories_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_template_mail_histories_created_at ON public.template_mail_histories USING btree (created_at);


--
-- Name: idx_template_mail_histories_event_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_template_mail_histories_event_type ON public.template_mail_histories USING btree (event_type);


--
-- Name: idx_template_mail_histories_template_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_template_mail_histories_template_created ON public.template_mail_histories USING btree (template_id, created_at);


--
-- Name: idx_template_mail_versions_public_started_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_template_mail_versions_public_started_at ON public.template_mail_versions USING btree (public_started_at);


--
-- Name: idx_template_mail_versions_template_version; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_template_mail_versions_template_version ON public.template_mail_versions USING btree (template_id, version);


--
-- Name: idx_template_mails_template_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_template_mails_template_id ON public.template_mails USING btree (template_id);


--
-- Name: idx_templates_tenant_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_tenant_name ON public.templates USING btree (tenant_id, name);


--
-- Name: idx_tenant_settings_tenant_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_tenant_settings_tenant_id_uniq ON public.tenant_settings USING btree (tenant_id);


--
-- Name: idx_user_events_tenant_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_events_tenant_time ON public.user_events USING btree (tenant_id, transaction_time);


--
-- Name: idx_user_events_tenant_user_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_events_tenant_user_time ON public.user_events USING btree (tenant_id, user_id, transaction_time);


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
-- Name: index_auto_tagging_schedules_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_auto_tagging_schedules_on_tenant_id ON public.auto_tagging_schedules USING btree (tenant_id);


--
-- Name: index_auto_tagging_schedules_on_user_auto_tagging_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_auto_tagging_schedules_on_user_auto_tagging_id ON public.auto_tagging_schedules USING btree (user_auto_tagging_id);


--
-- Name: index_contact_addresses_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contact_addresses_on_tenant_id ON public.contact_addresses USING btree (tenant_id);


--
-- Name: index_contact_addresses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contact_addresses_on_user_id ON public.contact_addresses USING btree (user_id);


--
-- Name: index_deliveries_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deliveries_on_created_by_id ON public.deliveries USING btree (created_by_id);


--
-- Name: index_deliveries_on_template_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deliveries_on_template_id ON public.deliveries USING btree (template_id);


--
-- Name: index_deliveries_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deliveries_on_tenant_id ON public.deliveries USING btree (tenant_id);


--
-- Name: index_deliveries_on_tenant_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deliveries_on_tenant_id_and_created_at ON public.deliveries USING btree (tenant_id, created_at);


--
-- Name: index_deliveries_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deliveries_on_updated_by_id ON public.deliveries USING btree (updated_by_id);


--
-- Name: index_delivery_addresses_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_addresses_on_tenant_id ON public.delivery_addresses USING btree (tenant_id);


--
-- Name: index_delivery_addresses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_addresses_on_user_id ON public.delivery_addresses USING btree (user_id);


--
-- Name: index_delivery_birthdays_on_delivery_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_birthdays_on_delivery_id ON public.delivery_birthdays USING btree (delivery_id);


--
-- Name: index_delivery_birthdays_on_published_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_birthdays_on_published_by_id ON public.delivery_birthdays USING btree (published_by_id);


--
-- Name: index_delivery_birthdays_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_birthdays_on_tenant_id ON public.delivery_birthdays USING btree (tenant_id);


--
-- Name: index_delivery_birthdays_on_tenant_id_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_birthdays_on_tenant_id_and_status ON public.delivery_birthdays USING btree (tenant_id, status);


--
-- Name: index_delivery_events_on_admin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_events_on_admin_id ON public.delivery_events USING btree (admin_id);


--
-- Name: index_delivery_events_on_delivery_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_events_on_delivery_id ON public.delivery_events USING btree (delivery_id);


--
-- Name: index_delivery_events_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_events_on_tenant_id ON public.delivery_events USING btree (tenant_id);


--
-- Name: index_delivery_events_on_tenant_id_and_delivery_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_events_on_tenant_id_and_delivery_id ON public.delivery_events USING btree (tenant_id, delivery_id);


--
-- Name: index_delivery_recipients_on_delivery_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_recipients_on_delivery_id ON public.delivery_recipients USING btree (delivery_id);


--
-- Name: index_delivery_recipients_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_recipients_on_tenant_id ON public.delivery_recipients USING btree (tenant_id);


--
-- Name: index_delivery_recipients_on_tenant_id_and_delivery_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_recipients_on_tenant_id_and_delivery_id ON public.delivery_recipients USING btree (tenant_id, delivery_id);


--
-- Name: index_delivery_recipients_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_recipients_on_user_id ON public.delivery_recipients USING btree (user_id);


--
-- Name: index_delivery_results_on_delivery_birthday_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_results_on_delivery_birthday_id ON public.delivery_results USING btree (delivery_birthday_id);


--
-- Name: index_delivery_results_on_delivery_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_results_on_delivery_id ON public.delivery_results USING btree (delivery_id);


--
-- Name: index_delivery_results_on_delivery_schedule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_results_on_delivery_schedule_id ON public.delivery_results USING btree (delivery_schedule_id);


--
-- Name: index_delivery_results_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_results_on_tenant_id ON public.delivery_results USING btree (tenant_id);


--
-- Name: index_delivery_schedules_on_delivery_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_schedules_on_delivery_id ON public.delivery_schedules USING btree (delivery_id);


--
-- Name: index_delivery_schedules_on_published_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_schedules_on_published_by_id ON public.delivery_schedules USING btree (published_by_id);


--
-- Name: index_delivery_schedules_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_schedules_on_tenant_id ON public.delivery_schedules USING btree (tenant_id);


--
-- Name: index_delivery_schedules_on_tenant_id_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_schedules_on_tenant_id_and_status ON public.delivery_schedules USING btree (tenant_id, status);


--
-- Name: index_delivery_user_tags_on_delivery_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_user_tags_on_delivery_id ON public.delivery_user_tags USING btree (delivery_id);


--
-- Name: index_delivery_user_tags_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_user_tags_on_tenant_id ON public.delivery_user_tags USING btree (tenant_id);


--
-- Name: index_delivery_user_tags_on_tenant_id_and_delivery_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_user_tags_on_tenant_id_and_delivery_id ON public.delivery_user_tags USING btree (tenant_id, delivery_id);


--
-- Name: index_delivery_user_tags_on_user_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delivery_user_tags_on_user_tag_id ON public.delivery_user_tags USING btree (user_tag_id);


--
-- Name: index_email_templates_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_templates_on_tenant_id ON public.email_templates USING btree (tenant_id);


--
-- Name: index_email_templates_on_tenant_id_template_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_email_templates_on_tenant_id_template_type ON public.email_templates USING btree (tenant_id, template_type);


--
-- Name: index_komoju_account_per_tenant_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_komoju_account_per_tenant_unique ON public.tenant_komoju_accounts USING btree (tenant_id, komoju_account_id);


--
-- Name: index_komoju_record_accounts_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_komoju_record_accounts_on_tenant_id ON public.komoju_record_accounts USING btree (tenant_id);


--
-- Name: index_komoju_record_payments_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_komoju_record_payments_on_tenant_id ON public.komoju_record_payments USING btree (tenant_id);


--
-- Name: index_komoju_record_payments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_komoju_record_payments_on_user_id ON public.komoju_record_payments USING btree (user_id);


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
-- Name: index_payment_subscriptions_on_membership_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_subscriptions_on_membership_contract_id ON public.payment_subscriptions USING btree (membership_contract_id);


--
-- Name: index_payment_subscriptions_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_subscriptions_on_tenant_id ON public.payment_subscriptions USING btree (tenant_id);


--
-- Name: index_payment_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_subscriptions_on_user_id ON public.payment_subscriptions USING btree (user_id);


--
-- Name: index_payment_transactions_on_membership_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_transactions_on_membership_contract_id ON public.payment_transactions USING btree (membership_contract_id);


--
-- Name: index_payment_transactions_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_transactions_on_tenant_id ON public.payment_transactions USING btree (tenant_id);


--
-- Name: index_payment_transactions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_transactions_on_user_id ON public.payment_transactions USING btree (user_id);


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
-- Name: index_stripe_record_accounts_on_api_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_accounts_on_api_key_id ON public.stripe_record_accounts USING btree (api_key_id);


--
-- Name: index_stripe_record_accounts_on_controlling_platform_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_accounts_on_controlling_platform_id ON public.stripe_record_accounts USING btree (controlling_platform_id);


--
-- Name: index_stripe_record_accounts_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_accounts_on_tenant_id ON public.stripe_record_accounts USING btree (tenant_id);


--
-- Name: index_stripe_record_accounts_remote_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stripe_record_accounts_remote_id_unique ON public.stripe_record_accounts USING btree (remote_id, controlling_platform_id) NULLS NOT DISTINCT;


--
-- Name: index_stripe_record_api_keys_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_api_keys_on_tenant_id ON public.stripe_record_api_keys USING btree (tenant_id);


--
-- Name: index_stripe_record_charges_on_api_key_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_charges_on_api_key_account_id ON public.stripe_record_charges USING btree (api_key_account_id);


--
-- Name: index_stripe_record_charges_on_connect_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_charges_on_connect_account_id ON public.stripe_record_charges USING btree (connect_account_id);


--
-- Name: index_stripe_record_charges_on_payment_intent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_charges_on_payment_intent_id ON public.stripe_record_charges USING btree (payment_intent_id);


--
-- Name: index_stripe_record_charges_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_charges_on_tenant_id ON public.stripe_record_charges USING btree (tenant_id);


--
-- Name: index_stripe_record_charges_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_charges_on_user_id ON public.stripe_record_charges USING btree (user_id);


--
-- Name: index_stripe_record_invoices_on_tenant_and_remote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stripe_record_invoices_on_tenant_and_remote_id ON public.stripe_record_invoices USING btree (tenant_id, remote_id);


--
-- Name: index_stripe_record_invoices_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_invoices_on_tenant_id ON public.stripe_record_invoices USING btree (tenant_id);


--
-- Name: index_stripe_record_invoices_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_invoices_on_user_id ON public.stripe_record_invoices USING btree (user_id);


--
-- Name: index_stripe_record_payment_intents_on_api_key_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_payment_intents_on_api_key_account_id ON public.stripe_record_payment_intents USING btree (api_key_account_id);


--
-- Name: index_stripe_record_payment_intents_on_connect_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_payment_intents_on_connect_account_id ON public.stripe_record_payment_intents USING btree (connect_account_id);


--
-- Name: index_stripe_record_payment_intents_on_invoice_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_payment_intents_on_invoice_id ON public.stripe_record_payment_intents USING btree (invoice_id);


--
-- Name: index_stripe_record_payment_intents_on_latest_charge_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_payment_intents_on_latest_charge_id ON public.stripe_record_payment_intents USING btree (latest_charge_id);


--
-- Name: index_stripe_record_payment_intents_on_tenant_and_remote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stripe_record_payment_intents_on_tenant_and_remote_id ON public.stripe_record_payment_intents USING btree (tenant_id, remote_id);


--
-- Name: index_stripe_record_payment_intents_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_payment_intents_on_tenant_id ON public.stripe_record_payment_intents USING btree (tenant_id);


--
-- Name: index_stripe_record_payment_intents_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_payment_intents_on_user_id ON public.stripe_record_payment_intents USING btree (user_id);


--
-- Name: index_stripe_record_payment_methods_on_api_key_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_payment_methods_on_api_key_account_id ON public.stripe_record_payment_methods USING btree (api_key_account_id);


--
-- Name: index_stripe_record_payment_methods_on_connect_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_payment_methods_on_connect_account_id ON public.stripe_record_payment_methods USING btree (connect_account_id);


--
-- Name: index_stripe_record_payment_methods_on_setup_intent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_payment_methods_on_setup_intent_id ON public.stripe_record_payment_methods USING btree (setup_intent_id);


--
-- Name: index_stripe_record_payment_methods_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_payment_methods_on_tenant_id ON public.stripe_record_payment_methods USING btree (tenant_id);


--
-- Name: index_stripe_record_payment_methods_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_payment_methods_on_user_id ON public.stripe_record_payment_methods USING btree (user_id);


--
-- Name: index_stripe_record_prices_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_prices_on_product_id ON public.stripe_record_prices USING btree (product_id);


--
-- Name: index_stripe_record_prices_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_prices_on_tenant_id ON public.stripe_record_prices USING btree (tenant_id);


--
-- Name: index_stripe_record_products_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_products_on_tenant_id ON public.stripe_record_products USING btree (tenant_id);


--
-- Name: index_stripe_record_refunds_on_api_key_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_refunds_on_api_key_account_id ON public.stripe_record_refunds USING btree (api_key_account_id);


--
-- Name: index_stripe_record_refunds_on_connect_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_refunds_on_connect_account_id ON public.stripe_record_refunds USING btree (connect_account_id);


--
-- Name: index_stripe_record_refunds_on_payment_intent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_refunds_on_payment_intent_id ON public.stripe_record_refunds USING btree (payment_intent_id);


--
-- Name: index_stripe_record_refunds_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_refunds_on_tenant_id ON public.stripe_record_refunds USING btree (tenant_id);


--
-- Name: index_stripe_record_refunds_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_refunds_on_user_id ON public.stripe_record_refunds USING btree (user_id);


--
-- Name: index_stripe_record_setup_intents_on_api_key_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_setup_intents_on_api_key_account_id ON public.stripe_record_setup_intents USING btree (api_key_account_id);


--
-- Name: index_stripe_record_setup_intents_on_connect_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_setup_intents_on_connect_account_id ON public.stripe_record_setup_intents USING btree (connect_account_id);


--
-- Name: index_stripe_record_setup_intents_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_setup_intents_on_tenant_id ON public.stripe_record_setup_intents USING btree (tenant_id);


--
-- Name: index_stripe_record_setup_intents_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_setup_intents_on_user_id ON public.stripe_record_setup_intents USING btree (user_id);


--
-- Name: index_stripe_record_si_on_subscription_and_price; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stripe_record_si_on_subscription_and_price ON public.stripe_record_subscription_items USING btree (subscription_id, price_id);


--
-- Name: index_stripe_record_subscription_items_on_price_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_subscription_items_on_price_id ON public.stripe_record_subscription_items USING btree (price_id);


--
-- Name: index_stripe_record_subscription_items_on_remote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stripe_record_subscription_items_on_remote_id ON public.stripe_record_subscription_items USING btree (remote_id);


--
-- Name: index_stripe_record_subscription_items_on_subscription_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_subscription_items_on_subscription_id ON public.stripe_record_subscription_items USING btree (subscription_id);


--
-- Name: index_stripe_record_subscription_items_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_subscription_items_on_tenant_id ON public.stripe_record_subscription_items USING btree (tenant_id);


--
-- Name: index_stripe_record_subscription_schedules_on_subscription_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_subscription_schedules_on_subscription_id ON public.stripe_record_subscription_schedules USING btree (subscription_id);


--
-- Name: index_stripe_record_subscription_schedules_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_subscription_schedules_on_tenant_id ON public.stripe_record_subscription_schedules USING btree (tenant_id);


--
-- Name: index_stripe_record_subscription_schedules_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_subscription_schedules_on_user_id ON public.stripe_record_subscription_schedules USING btree (user_id);


--
-- Name: index_stripe_record_subscriptions_on_pending_setup_intent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_subscriptions_on_pending_setup_intent_id ON public.stripe_record_subscriptions USING btree (pending_setup_intent_id);


--
-- Name: index_stripe_record_subscriptions_on_price_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_subscriptions_on_price_id ON public.stripe_record_subscriptions USING btree (price_id);


--
-- Name: index_stripe_record_subscriptions_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_subscriptions_on_product_id ON public.stripe_record_subscriptions USING btree (product_id);


--
-- Name: index_stripe_record_subscriptions_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_subscriptions_on_tenant_id ON public.stripe_record_subscriptions USING btree (tenant_id);


--
-- Name: index_stripe_record_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_subscriptions_on_user_id ON public.stripe_record_subscriptions USING btree (user_id);


--
-- Name: index_stripe_record_trial_histories_on_membership_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_trial_histories_on_membership_id ON public.stripe_record_trial_histories USING btree (membership_id);


--
-- Name: index_stripe_record_trial_histories_on_membership_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_trial_histories_on_membership_plan_id ON public.stripe_record_trial_histories USING btree (membership_plan_id);


--
-- Name: index_stripe_record_trial_histories_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_trial_histories_on_tenant_id ON public.stripe_record_trial_histories USING btree (tenant_id);


--
-- Name: index_stripe_record_trial_histories_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_record_trial_histories_on_user_id ON public.stripe_record_trial_histories USING btree (user_id);


--
-- Name: index_template_mail_histories_on_actor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_template_mail_histories_on_actor_id ON public.template_mail_histories USING btree (actor_id);


--
-- Name: index_template_mail_histories_on_template_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_template_mail_histories_on_template_id ON public.template_mail_histories USING btree (template_id);


--
-- Name: index_template_mail_histories_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_template_mail_histories_on_tenant_id ON public.template_mail_histories USING btree (tenant_id);


--
-- Name: index_template_mail_histories_on_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_template_mail_histories_on_version_id ON public.template_mail_histories USING btree (version_id);


--
-- Name: index_template_mail_versions_on_published_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_template_mail_versions_on_published_by_id ON public.template_mail_versions USING btree (published_by_id);


--
-- Name: index_template_mail_versions_on_template_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_template_mail_versions_on_template_id ON public.template_mail_versions USING btree (template_id);


--
-- Name: index_template_mail_versions_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_template_mail_versions_on_tenant_id ON public.template_mail_versions USING btree (tenant_id);


--
-- Name: index_template_mails_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_template_mails_on_tenant_id ON public.template_mails USING btree (tenant_id);


--
-- Name: index_templates_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_on_tenant_id ON public.templates USING btree (tenant_id);


--
-- Name: index_tenant_komoju_accounts_on_komoju_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_komoju_accounts_on_komoju_account_id ON public.tenant_komoju_accounts USING btree (komoju_account_id);


--
-- Name: index_tenant_komoju_accounts_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tenant_komoju_accounts_on_tenant_id ON public.tenant_komoju_accounts USING btree (tenant_id);


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
-- Name: index_user_auto_tagging_rule_blocks_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_auto_tagging_rule_blocks_on_tenant_id ON public.user_auto_tagging_rule_blocks USING btree (tenant_id);


--
-- Name: index_user_auto_tagging_rule_blocks_on_user_auto_tagging_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_auto_tagging_rule_blocks_on_user_auto_tagging_id ON public.user_auto_tagging_rule_blocks USING btree (user_auto_tagging_id);


--
-- Name: index_user_auto_tagging_rules_on_condition_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_auto_tagging_rules_on_condition_type ON public.user_auto_tagging_rules USING btree (condition_type);


--
-- Name: index_user_auto_tagging_rules_on_rule_block_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_auto_tagging_rules_on_rule_block_id ON public.user_auto_tagging_rules USING btree (rule_block_id);


--
-- Name: index_user_auto_tagging_rules_on_rule_block_id_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_auto_tagging_rules_on_rule_block_id_and_position ON public.user_auto_tagging_rules USING btree (rule_block_id, "position");


--
-- Name: index_user_auto_tagging_rules_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_auto_tagging_rules_on_tenant_id ON public.user_auto_tagging_rules USING btree (tenant_id);


--
-- Name: index_user_auto_tagging_tags_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_auto_tagging_tags_on_tenant_id ON public.user_auto_tagging_tags USING btree (tenant_id);


--
-- Name: index_user_auto_tagging_tags_on_user_auto_tagging_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_auto_tagging_tags_on_user_auto_tagging_id ON public.user_auto_tagging_tags USING btree (user_auto_tagging_id);


--
-- Name: index_user_auto_tagging_tags_on_user_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_auto_tagging_tags_on_user_tag_id ON public.user_auto_tagging_tags USING btree (user_tag_id);


--
-- Name: index_user_auto_taggings_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_auto_taggings_on_created_by_id ON public.user_auto_taggings USING btree (created_by_id);


--
-- Name: index_user_auto_taggings_on_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_auto_taggings_on_enabled ON public.user_auto_taggings USING btree (enabled);


--
-- Name: index_user_auto_taggings_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_auto_taggings_on_tenant_id ON public.user_auto_taggings USING btree (tenant_id);


--
-- Name: index_user_auto_taggings_on_tenant_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_auto_taggings_on_tenant_id_and_name ON public.user_auto_taggings USING btree (tenant_id, name);


--
-- Name: index_user_auto_taggings_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_auto_taggings_on_updated_by_id ON public.user_auto_taggings USING btree (updated_by_id);


--
-- Name: index_user_events_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_events_on_tenant_id ON public.user_events USING btree (tenant_id);


--
-- Name: index_user_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_events_on_user_id ON public.user_events USING btree (user_id);


--
-- Name: index_user_profiles_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_profiles_on_tenant_id ON public.user_profiles USING btree (tenant_id);


--
-- Name: index_user_profiles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_profiles_on_user_id ON public.user_profiles USING btree (user_id);


--
-- Name: index_user_tag_assignments_on_assigned_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_tag_assignments_on_assigned_by_id ON public.user_tag_assignments USING btree (assigned_by_id);


--
-- Name: index_user_tag_assignments_on_assignment_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_tag_assignments_on_assignment_type ON public.user_tag_assignments USING btree (assignment_type);


--
-- Name: index_user_tag_assignments_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_tag_assignments_on_tenant_id ON public.user_tag_assignments USING btree (tenant_id);


--
-- Name: index_user_tag_assignments_on_user_auto_tagging_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_tag_assignments_on_user_auto_tagging_id ON public.user_tag_assignments USING btree (user_auto_tagging_id);


--
-- Name: index_user_tag_assignments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_tag_assignments_on_user_id ON public.user_tag_assignments USING btree (user_id);


--
-- Name: index_user_tag_assignments_on_user_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_tag_assignments_on_user_tag_id ON public.user_tag_assignments USING btree (user_tag_id);


--
-- Name: index_user_tag_assignments_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_tag_assignments_unique ON public.user_tag_assignments USING btree (tenant_id, user_id, user_tag_id);


--
-- Name: index_user_tags_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_tags_on_created_by_id ON public.user_tags USING btree (created_by_id);


--
-- Name: index_user_tags_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_tags_on_tenant_id ON public.user_tags USING btree (tenant_id);


--
-- Name: index_user_tags_on_tenant_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_tags_on_tenant_id_and_name ON public.user_tags USING btree (tenant_id, name);


--
-- Name: index_user_tags_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_tags_on_updated_by_id ON public.user_tags USING btree (updated_by_id);


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
-- Name: index_users_on_tenant_id_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_tenant_id_and_id ON public.users USING btree (tenant_id, id);


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
-- Name: komoju_record_payments fk_komoju_payments_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.komoju_record_payments
    ADD CONSTRAINT fk_komoju_payments_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: komoju_record_payments fk_komoju_payments_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.komoju_record_payments
    ADD CONSTRAINT fk_komoju_payments_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: komoju_record_accounts fk_komoju_record_accounts_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.komoju_record_accounts
    ADD CONSTRAINT fk_komoju_record_accounts_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


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
-- Name: membership_plan_payment_method_mappings fk_membership_plan_payment_method_mappings_payment_methods; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_plan_payment_method_mappings
    ADD CONSTRAINT fk_membership_plan_payment_method_mappings_payment_methods FOREIGN KEY (membership_plan_payment_method_id) REFERENCES public.membership_plan_payment_methods(id);


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
-- Name: payment_subscriptions fk_payment_subscriptions_contracts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_subscriptions
    ADD CONSTRAINT fk_payment_subscriptions_contracts FOREIGN KEY (membership_contract_id) REFERENCES public.membership_contracts(id);


--
-- Name: payment_subscriptions fk_payment_subscriptions_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_subscriptions
    ADD CONSTRAINT fk_payment_subscriptions_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: payment_subscriptions fk_payment_subscriptions_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_subscriptions
    ADD CONSTRAINT fk_payment_subscriptions_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: payment_transactions fk_payment_transactions_contracts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_transactions
    ADD CONSTRAINT fk_payment_transactions_contracts FOREIGN KEY (membership_contract_id) REFERENCES public.membership_contracts(id);


--
-- Name: payment_transactions fk_payment_transactions_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_transactions
    ADD CONSTRAINT fk_payment_transactions_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: payment_transactions fk_payment_transactions_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_transactions
    ADD CONSTRAINT fk_payment_transactions_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: delivery_results fk_rails_0173972a71; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_results
    ADD CONSTRAINT fk_rails_0173972a71 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_tag_assignments fk_rails_0b4d28da8d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tag_assignments
    ADD CONSTRAINT fk_rails_0b4d28da8d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: deliveries fk_rails_124bc6bba9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT fk_rails_124bc6bba9 FOREIGN KEY (created_by_id) REFERENCES public.admins(id);


--
-- Name: delivery_recipients fk_rails_137e61fc54; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_recipients
    ADD CONSTRAINT fk_rails_137e61fc54 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_tag_assignments fk_rails_15a1e63aba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tag_assignments
    ADD CONSTRAINT fk_rails_15a1e63aba FOREIGN KEY (assigned_by_id) REFERENCES public.admins(id);


--
-- Name: user_auto_tagging_tags fk_rails_22ed4e6a2e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auto_tagging_tags
    ADD CONSTRAINT fk_rails_22ed4e6a2e FOREIGN KEY (user_tag_id) REFERENCES public.user_tags(id);


--
-- Name: user_auto_tagging_rule_blocks fk_rails_2cdd36d912; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auto_tagging_rule_blocks
    ADD CONSTRAINT fk_rails_2cdd36d912 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_auto_tagging_tags fk_rails_2dad976901; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auto_tagging_tags
    ADD CONSTRAINT fk_rails_2dad976901 FOREIGN KEY (user_auto_tagging_id) REFERENCES public.user_auto_taggings(id);


--
-- Name: user_tags fk_rails_2f428c3efb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tags
    ADD CONSTRAINT fk_rails_2f428c3efb FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_auto_taggings fk_rails_30074fd50a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auto_taggings
    ADD CONSTRAINT fk_rails_30074fd50a FOREIGN KEY (updated_by_id) REFERENCES public.admins(id);


--
-- Name: deliveries fk_rails_30ece0c09d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT fk_rails_30ece0c09d FOREIGN KEY (updated_by_id) REFERENCES public.admins(id);


--
-- Name: user_tag_assignments fk_rails_32a895efba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tag_assignments
    ADD CONSTRAINT fk_rails_32a895efba FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: oauth_access_grants fk_rails_330c32d8d9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_rails_330c32d8d9 FOREIGN KEY (resource_owner_id) REFERENCES public.users(id);


--
-- Name: delivery_birthdays fk_rails_3a723aa957; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_birthdays
    ADD CONSTRAINT fk_rails_3a723aa957 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_events fk_rails_405c96056c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_events
    ADD CONSTRAINT fk_rails_405c96056c FOREIGN KEY (tenant_id, user_id) REFERENCES public.users(tenant_id, id);


--
-- Name: auto_tagging_schedules fk_rails_489a995725; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auto_tagging_schedules
    ADD CONSTRAINT fk_rails_489a995725 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: delivery_birthdays fk_rails_4a78653e02; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_birthdays
    ADD CONSTRAINT fk_rails_4a78653e02 FOREIGN KEY (published_by_id) REFERENCES public.admins(id);


--
-- Name: user_tags fk_rails_512adfb444; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tags
    ADD CONSTRAINT fk_rails_512adfb444 FOREIGN KEY (updated_by_id) REFERENCES public.admins(id);


--
-- Name: delivery_events fk_rails_54c1eb2330; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_events
    ADD CONSTRAINT fk_rails_54c1eb2330 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_tag_assignments fk_rails_5b06d62c98; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tag_assignments
    ADD CONSTRAINT fk_rails_5b06d62c98 FOREIGN KEY (user_tag_id) REFERENCES public.user_tags(id);


--
-- Name: deliveries fk_rails_5d26a31ef1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT fk_rails_5d26a31ef1 FOREIGN KEY (template_id) REFERENCES public.templates(id);


--
-- Name: delivery_results fk_rails_5eb9c7a71d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_results
    ADD CONSTRAINT fk_rails_5eb9c7a71d FOREIGN KEY (delivery_id) REFERENCES public.deliveries(id);


--
-- Name: delivery_schedules fk_rails_6ac3a748a8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_schedules
    ADD CONSTRAINT fk_rails_6ac3a748a8 FOREIGN KEY (published_by_id) REFERENCES public.admins(id);


--
-- Name: deliveries fk_rails_718677f735; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT fk_rails_718677f735 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_auto_tagging_tags fk_rails_71a8d9f90b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auto_tagging_tags
    ADD CONSTRAINT fk_rails_71a8d9f90b FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: delivery_events fk_rails_778e501c1a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_events
    ADD CONSTRAINT fk_rails_778e501c1a FOREIGN KEY (delivery_id) REFERENCES public.deliveries(id);


--
-- Name: delivery_events fk_rails_80304f78d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_events
    ADD CONSTRAINT fk_rails_80304f78d7 FOREIGN KEY (admin_id) REFERENCES public.admins(id);


--
-- Name: delivery_schedules fk_rails_8d2faf2760; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_schedules
    ADD CONSTRAINT fk_rails_8d2faf2760 FOREIGN KEY (delivery_id) REFERENCES public.deliveries(id);


--
-- Name: user_auto_tagging_rule_blocks fk_rails_8d695c0558; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auto_tagging_rule_blocks
    ADD CONSTRAINT fk_rails_8d695c0558 FOREIGN KEY (user_auto_tagging_id) REFERENCES public.user_auto_taggings(id);


--
-- Name: user_tags fk_rails_8f244f8e18; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tags
    ADD CONSTRAINT fk_rails_8f244f8e18 FOREIGN KEY (created_by_id) REFERENCES public.admins(id);


--
-- Name: user_auto_taggings fk_rails_8f64c0265a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auto_taggings
    ADD CONSTRAINT fk_rails_8f64c0265a FOREIGN KEY (created_by_id) REFERENCES public.admins(id);


--
-- Name: user_auto_taggings fk_rails_9a3d6ddc76; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auto_taggings
    ADD CONSTRAINT fk_rails_9a3d6ddc76 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_auto_tagging_rules fk_rails_a323828ab8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auto_tagging_rules
    ADD CONSTRAINT fk_rails_a323828ab8 FOREIGN KEY (rule_block_id) REFERENCES public.user_auto_tagging_rule_blocks(id);


--
-- Name: auto_tagging_schedules fk_rails_a9d46bdb5d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auto_tagging_schedules
    ADD CONSTRAINT fk_rails_a9d46bdb5d FOREIGN KEY (user_auto_tagging_id) REFERENCES public.user_auto_taggings(id);


--
-- Name: delivery_schedules fk_rails_b30388b150; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_schedules
    ADD CONSTRAINT fk_rails_b30388b150 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: delivery_user_tags fk_rails_b4a750d7f4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_user_tags
    ADD CONSTRAINT fk_rails_b4a750d7f4 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: delivery_birthdays fk_rails_c56966b935; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_birthdays
    ADD CONSTRAINT fk_rails_c56966b935 FOREIGN KEY (delivery_id) REFERENCES public.deliveries(id);


--
-- Name: delivery_recipients fk_rails_d59b64634b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_recipients
    ADD CONSTRAINT fk_rails_d59b64634b FOREIGN KEY (delivery_id) REFERENCES public.deliveries(id);


--
-- Name: delivery_results fk_rails_d6f0554146; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_results
    ADD CONSTRAINT fk_rails_d6f0554146 FOREIGN KEY (delivery_schedule_id) REFERENCES public.delivery_schedules(id);


--
-- Name: delivery_user_tags fk_rails_df4dc05abd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_user_tags
    ADD CONSTRAINT fk_rails_df4dc05abd FOREIGN KEY (user_tag_id) REFERENCES public.user_tags(id);


--
-- Name: user_auto_tagging_rules fk_rails_e2fdd588cf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auto_tagging_rules
    ADD CONSTRAINT fk_rails_e2fdd588cf FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: delivery_recipients fk_rails_edeeb3ba6e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_recipients
    ADD CONSTRAINT fk_rails_edeeb3ba6e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: oauth_access_tokens fk_rails_ee63f25419; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_rails_ee63f25419 FOREIGN KEY (resource_owner_id) REFERENCES public.users(id);


--
-- Name: delivery_results fk_rails_f1a10afb70; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_results
    ADD CONSTRAINT fk_rails_f1a10afb70 FOREIGN KEY (delivery_birthday_id) REFERENCES public.delivery_birthdays(id);


--
-- Name: delivery_user_tags fk_rails_f777e1f716; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_user_tags
    ADD CONSTRAINT fk_rails_f777e1f716 FOREIGN KEY (delivery_id) REFERENCES public.deliveries(id);


--
-- Name: user_tag_assignments fk_rails_fa16674ff6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tag_assignments
    ADD CONSTRAINT fk_rails_fa16674ff6 FOREIGN KEY (user_auto_tagging_id) REFERENCES public.user_auto_taggings(id);


--
-- Name: stripe_record_accounts fk_stripe_record_accounts_api_key_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_accounts
    ADD CONSTRAINT fk_stripe_record_accounts_api_key_id FOREIGN KEY (api_key_id) REFERENCES public.stripe_record_api_keys(id);


--
-- Name: stripe_record_accounts fk_stripe_record_accounts_controlling_platform_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_accounts
    ADD CONSTRAINT fk_stripe_record_accounts_controlling_platform_id FOREIGN KEY (controlling_platform_id) REFERENCES public.stripe_record_accounts(id);


--
-- Name: stripe_record_accounts fk_stripe_record_accounts_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_accounts
    ADD CONSTRAINT fk_stripe_record_accounts_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record_api_keys fk_stripe_record_api_keys_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_api_keys
    ADD CONSTRAINT fk_stripe_record_api_keys_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record_charges fk_stripe_record_charges_api_key_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_charges
    ADD CONSTRAINT fk_stripe_record_charges_api_key_account_id FOREIGN KEY (api_key_account_id) REFERENCES public.stripe_record_accounts(id);


--
-- Name: stripe_record_charges fk_stripe_record_charges_connect_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_charges
    ADD CONSTRAINT fk_stripe_record_charges_connect_account_id FOREIGN KEY (connect_account_id) REFERENCES public.stripe_record_accounts(id);


--
-- Name: stripe_record_charges fk_stripe_record_charges_payment_intents; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_charges
    ADD CONSTRAINT fk_stripe_record_charges_payment_intents FOREIGN KEY (payment_intent_id) REFERENCES public.stripe_record_payment_intents(id);


--
-- Name: stripe_record_charges fk_stripe_record_charges_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_charges
    ADD CONSTRAINT fk_stripe_record_charges_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record_charges fk_stripe_record_charges_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_charges
    ADD CONSTRAINT fk_stripe_record_charges_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: stripe_record_invoices fk_stripe_record_invoices__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_invoices
    ADD CONSTRAINT fk_stripe_record_invoices__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record_payment_intents fk_stripe_record_payment_intents__invoices; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_payment_intents
    ADD CONSTRAINT fk_stripe_record_payment_intents__invoices FOREIGN KEY (invoice_id) REFERENCES public.stripe_record_invoices(id);


--
-- Name: stripe_record_payment_intents fk_stripe_record_payment_intents__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_payment_intents
    ADD CONSTRAINT fk_stripe_record_payment_intents__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record_refunds fk_stripe_record_payment_intents__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_refunds
    ADD CONSTRAINT fk_stripe_record_payment_intents__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record_payment_intents fk_stripe_record_payment_intents__users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_payment_intents
    ADD CONSTRAINT fk_stripe_record_payment_intents__users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: stripe_record_invoices fk_stripe_record_payment_intents__users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_invoices
    ADD CONSTRAINT fk_stripe_record_payment_intents__users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: stripe_record_payment_intents fk_stripe_record_payment_intents_api_key_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_payment_intents
    ADD CONSTRAINT fk_stripe_record_payment_intents_api_key_account_id FOREIGN KEY (api_key_account_id) REFERENCES public.stripe_record_accounts(id);


--
-- Name: stripe_record_payment_intents fk_stripe_record_payment_intents_connect_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_payment_intents
    ADD CONSTRAINT fk_stripe_record_payment_intents_connect_account_id FOREIGN KEY (connect_account_id) REFERENCES public.stripe_record_accounts(id);


--
-- Name: stripe_record_payment_methods fk_stripe_record_payment_methods__setup_intents; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_payment_methods
    ADD CONSTRAINT fk_stripe_record_payment_methods__setup_intents FOREIGN KEY (setup_intent_id) REFERENCES public.stripe_record_setup_intents(id);


--
-- Name: stripe_record_payment_methods fk_stripe_record_payment_methods__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_payment_methods
    ADD CONSTRAINT fk_stripe_record_payment_methods__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record_payment_methods fk_stripe_record_payment_methods__users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_payment_methods
    ADD CONSTRAINT fk_stripe_record_payment_methods__users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: stripe_record_payment_methods fk_stripe_record_payment_methods_api_key_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_payment_methods
    ADD CONSTRAINT fk_stripe_record_payment_methods_api_key_account_id FOREIGN KEY (api_key_account_id) REFERENCES public.stripe_record_accounts(id);


--
-- Name: stripe_record_payment_methods fk_stripe_record_payment_methods_connect_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_payment_methods
    ADD CONSTRAINT fk_stripe_record_payment_methods_connect_account_id FOREIGN KEY (connect_account_id) REFERENCES public.stripe_record_accounts(id);


--
-- Name: stripe_record_prices fk_stripe_record_prices__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_prices
    ADD CONSTRAINT fk_stripe_record_prices__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record_products fk_stripe_record_products__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_products
    ADD CONSTRAINT fk_stripe_record_products__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record_refunds fk_stripe_record_refunds__users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_refunds
    ADD CONSTRAINT fk_stripe_record_refunds__users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: stripe_record_refunds fk_stripe_record_refunds_api_key_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_refunds
    ADD CONSTRAINT fk_stripe_record_refunds_api_key_account_id FOREIGN KEY (api_key_account_id) REFERENCES public.stripe_record_accounts(id);


--
-- Name: stripe_record_refunds fk_stripe_record_refunds_connect_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_refunds
    ADD CONSTRAINT fk_stripe_record_refunds_connect_account_id FOREIGN KEY (connect_account_id) REFERENCES public.stripe_record_accounts(id);


--
-- Name: stripe_record_refunds fk_stripe_record_refunds_payment_intent_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_refunds
    ADD CONSTRAINT fk_stripe_record_refunds_payment_intent_id FOREIGN KEY (payment_intent_id) REFERENCES public.stripe_record_payment_intents(id);


--
-- Name: stripe_record_setup_intents fk_stripe_record_setup_intents__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_setup_intents
    ADD CONSTRAINT fk_stripe_record_setup_intents__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record_setup_intents fk_stripe_record_setup_intents__users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_setup_intents
    ADD CONSTRAINT fk_stripe_record_setup_intents__users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: stripe_record_setup_intents fk_stripe_record_setup_intents_api_key_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_setup_intents
    ADD CONSTRAINT fk_stripe_record_setup_intents_api_key_account_id FOREIGN KEY (api_key_account_id) REFERENCES public.stripe_record_accounts(id);


--
-- Name: stripe_record_setup_intents fk_stripe_record_setup_intents_connect_account_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_setup_intents
    ADD CONSTRAINT fk_stripe_record_setup_intents_connect_account_id FOREIGN KEY (connect_account_id) REFERENCES public.stripe_record_accounts(id);


--
-- Name: stripe_record_subscription_items fk_stripe_record_subscription_items__prices; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_subscription_items
    ADD CONSTRAINT fk_stripe_record_subscription_items__prices FOREIGN KEY (price_id) REFERENCES public.stripe_record_prices(id);


--
-- Name: stripe_record_subscription_items fk_stripe_record_subscription_items__subscriptions; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_subscription_items
    ADD CONSTRAINT fk_stripe_record_subscription_items__subscriptions FOREIGN KEY (subscription_id) REFERENCES public.stripe_record_subscriptions(id);


--
-- Name: stripe_record_subscription_items fk_stripe_record_subscription_items__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_subscription_items
    ADD CONSTRAINT fk_stripe_record_subscription_items__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record_subscription_schedules fk_stripe_record_subscription_schedules__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_subscription_schedules
    ADD CONSTRAINT fk_stripe_record_subscription_schedules__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: stripe_record_subscriptions fk_stripe_record_subscriptions__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_record_subscriptions
    ADD CONSTRAINT fk_stripe_record_subscriptions__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: template_mail_histories fk_template_mail_histories_actors; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_mail_histories
    ADD CONSTRAINT fk_template_mail_histories_actors FOREIGN KEY (actor_id) REFERENCES public.admins(id);


--
-- Name: template_mail_histories fk_template_mail_histories_templates; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_mail_histories
    ADD CONSTRAINT fk_template_mail_histories_templates FOREIGN KEY (template_id) REFERENCES public.templates(id);


--
-- Name: template_mail_histories fk_template_mail_histories_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_mail_histories
    ADD CONSTRAINT fk_template_mail_histories_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: template_mail_histories fk_template_mail_histories_versions; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_mail_histories
    ADD CONSTRAINT fk_template_mail_histories_versions FOREIGN KEY (version_id) REFERENCES public.template_mail_versions(id);


--
-- Name: template_mail_versions fk_template_mail_versions_published_by; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_mail_versions
    ADD CONSTRAINT fk_template_mail_versions_published_by FOREIGN KEY (published_by_id) REFERENCES public.admins(id);


--
-- Name: template_mail_versions fk_template_mail_versions_templates; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_mail_versions
    ADD CONSTRAINT fk_template_mail_versions_templates FOREIGN KEY (template_id) REFERENCES public.templates(id);


--
-- Name: template_mail_versions fk_template_mail_versions_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_mail_versions
    ADD CONSTRAINT fk_template_mail_versions_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: template_mails fk_template_mails_templates; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_mails
    ADD CONSTRAINT fk_template_mails_templates FOREIGN KEY (template_id) REFERENCES public.templates(id);


--
-- Name: template_mails fk_template_mails_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_mails
    ADD CONSTRAINT fk_template_mails_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: templates fk_templates_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT fk_templates_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: tenant_komoju_accounts fk_tenant_komoju_accounts__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_komoju_accounts
    ADD CONSTRAINT fk_tenant_komoju_accounts__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: tenant_komoju_accounts fk_tenant_komoju_accounts_komoju_accounts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_komoju_accounts
    ADD CONSTRAINT fk_tenant_komoju_accounts_komoju_accounts FOREIGN KEY (komoju_account_id) REFERENCES public.komoju_record_accounts(id);


--
-- Name: tenant_stripe_accounts fk_tenant_stripe_accounts__tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_stripe_accounts
    ADD CONSTRAINT fk_tenant_stripe_accounts__tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: tenant_stripe_accounts fk_tenant_stripe_accounts_stripe_accounts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_stripe_accounts
    ADD CONSTRAINT fk_tenant_stripe_accounts_stripe_accounts FOREIGN KEY (stripe_account_id) REFERENCES public.stripe_record_accounts(id);


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

\unrestrict dq2TbLJuuYcNnMGUC0rvLYYfABPluEBaTzBOETbLtGVgTgoG4iGhwT7wJE7cBqh

SET search_path TO "$user", public;

