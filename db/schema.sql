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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: pending_user_tenant_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pending_user_tenant_roles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email_address character varying(255) NOT NULL,
    tenant_id uuid NOT NULL,
    role_desc text NOT NULL
);


--
-- Name: pending_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pending_users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email_address character varying(255) NOT NULL,
    invite_token_hash text NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    invited_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(128) NOT NULL
);


--
-- Name: tenant_user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_user_roles (
    user_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    role_desc text NOT NULL
);


--
-- Name: tenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    full_name character varying(255) NOT NULL
);


--
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_sessions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    session_hash bytea NOT NULL,
    user_id uuid NOT NULL,
    created_at text NOT NULL,
    expires_at text NOT NULL,
    invited_at text NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email_address character varying(255) NOT NULL,
    password_hash text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: pending_user_tenant_roles pending_user_tenant_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_user_tenant_roles
    ADD CONSTRAINT pending_user_tenant_roles_pkey PRIMARY KEY (id);


--
-- Name: pending_users pending_users_email_address_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_users
    ADD CONSTRAINT pending_users_email_address_key UNIQUE (email_address);


--
-- Name: pending_users pending_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_users
    ADD CONSTRAINT pending_users_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: tenant_user_roles tenant_user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_user_roles
    ADD CONSTRAINT tenant_user_roles_pkey PRIMARY KEY (user_id, tenant_id);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_pending_user_tenant_role_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_pending_user_tenant_role_tenant ON public.pending_user_tenant_roles USING btree (tenant_id);


--
-- Name: ux_pending_user_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_pending_user_email ON public.pending_users USING btree (email_address);


--
-- Name: ux_pending_user_tenant_role_email_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_pending_user_tenant_role_email_tenant ON public.pending_user_tenant_roles USING btree (email_address, tenant_id);


--
-- Name: ux_pending_user_token_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_pending_user_token_hash ON public.pending_users USING btree (invite_token_hash);


--
-- Name: ux_user_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_user_email ON public.users USING btree (email_address);


--
-- Name: pending_user_tenant_roles pending_user_tenant_roles_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_user_tenant_roles
    ADD CONSTRAINT pending_user_tenant_roles_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: tenant_user_roles tenant_user_roles_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_user_roles
    ADD CONSTRAINT tenant_user_roles_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: tenant_user_roles tenant_user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_user_roles
    ADD CONSTRAINT tenant_user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20250420000001'),
    ('20250420122754'),
    ('20250420123216'),
    ('20250420124345'),
    ('20250420124936'),
    ('20250421125641'),
    ('20250421130823');
