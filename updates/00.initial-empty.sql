--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: maplin; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE maplin WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


ALTER DATABASE maplin OWNER TO postgres;

\connect maplin

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: update_ts(); Type: FUNCTION; Schema: public; Owner: mapapp
--

CREATE FUNCTION update_ts() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
   BEGIN
     NEW.ts = NOW();
     RETURN NEW;
   END;
$$;


ALTER FUNCTION public.update_ts() OWNER TO mapapp;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: authgroups; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE authgroups (
    gid integer NOT NULL,
    authorization_group character varying(20)
);


ALTER TABLE public.authgroups OWNER TO mapapp;

--
-- Name: authgroups_gid_seq; Type: SEQUENCE; Schema: public; Owner: mapapp
--

CREATE SEQUENCE authgroups_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.authgroups_gid_seq OWNER TO mapapp;

--
-- Name: authgroups_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mapapp
--

ALTER SEQUENCE authgroups_gid_seq OWNED BY authgroups.gid;


--
-- Name: users; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE users (
    uid integer NOT NULL,
    name character varying(30),
    password character varying(30),
    active smallint,
    email_address character varying(200),
    admin smallint,
    library character varying(200),
    mailing_address_line1 character varying(200),
    mailing_address_line2 character varying(200),
    mailing_address_line3 character varying(200),
    ill_sent smallint,
    home_zserver_id smallint,
    home_zserver_location character varying(30),
    last_login timestamp without time zone
);


ALTER TABLE public.users OWNER TO mapapp;

--
-- Name: libraries_lid_seq; Type: SEQUENCE; Schema: public; Owner: mapapp
--

CREATE SEQUENCE libraries_lid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.libraries_lid_seq OWNER TO mapapp;

--
-- Name: libraries_lid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mapapp
--

ALTER SEQUENCE libraries_lid_seq OWNED BY users.uid;


--
-- Name: libraries; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE libraries (
    lid integer DEFAULT nextval('libraries_lid_seq'::regclass) NOT NULL,
    name character varying(30),
    password character varying(30),
    active smallint,
    email_address character varying(200),
    admin smallint,
    library character varying(200),
    mailing_address_line1 character varying(200),
    mailing_address_line2 character varying(200),
    mailing_address_line3 character varying(200),
    ill_sent smallint,
    home_zserver_id smallint,
    home_zserver_location character varying(30),
    last_login timestamp without time zone,
    unverified_patron_request_limit integer DEFAULT 2,
    town character varying(50),
    region character varying(15),
    ebsco_user character varying(40),
    ebsco_pass character varying(40),
    use_standardresource boolean DEFAULT true,
    use_databaseresource boolean DEFAULT true,
    use_electronicresource boolean DEFAULT true,
    use_webresource boolean DEFAULT false,
    wpl_institution_card character varying(40)
);


ALTER TABLE public.libraries OWNER TO mapapp;

--
-- Name: library_barcodes; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE library_barcodes (
    lid integer NOT NULL,
    borrower integer,
    barcode character varying(15)
);


ALTER TABLE public.library_barcodes OWNER TO mapapp;

--
-- Name: request_seq; Type: SEQUENCE; Schema: public; Owner: mapapp
--

CREATE SEQUENCE request_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.request_seq OWNER TO mapapp;

--
-- Name: request; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE request (
    id integer DEFAULT nextval('request_seq'::regclass) NOT NULL,
    title character varying(1024),
    author character varying(256),
    requester integer NOT NULL,
    patron_barcode character(14),
    current_target integer DEFAULT 1
);


ALTER TABLE public.request OWNER TO mapapp;

--
-- Name: request_closed; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE request_closed (
    id integer NOT NULL,
    title character varying(1024),
    author character varying(256),
    requester integer NOT NULL,
    patron_barcode character(14),
    filled_by integer,
    attempts integer
);


ALTER TABLE public.request_closed OWNER TO mapapp;

--
-- Name: requests_active; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE requests_active (
    request_id integer,
    ts timestamp without time zone DEFAULT now(),
    msg_from integer,
    msg_to integer,
    status character varying(100),
    message character varying(100)
);


ALTER TABLE public.requests_active OWNER TO mapapp;

--
-- Name: requests_history; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE requests_history (
    request_id integer,
    ts timestamp without time zone,
    msg_from integer,
    msg_to integer,
    status character varying(100),
    message character varying(100)
);


ALTER TABLE public.requests_history OWNER TO mapapp;

--
-- Name: search_statistics; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE search_statistics (
    sessionid character varying(50) NOT NULL,
    ts timestamp without time zone DEFAULT now() NOT NULL,
    pqf character varying(1024),
    duration integer DEFAULT 0,
    records integer DEFAULT 0
);


ALTER TABLE public.search_statistics OWNER TO mapapp;

--
-- Name: sources; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE sources (
    request_id integer,
    sequence_number integer DEFAULT 1 NOT NULL,
    library integer,
    call_number character varying(100)
);


ALTER TABLE public.sources OWNER TO mapapp;

--
-- Name: gid; Type: DEFAULT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY authgroups ALTER COLUMN gid SET DEFAULT nextval('authgroups_gid_seq'::regclass);


--
-- Name: uid; Type: DEFAULT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY users ALTER COLUMN uid SET DEFAULT nextval('libraries_lid_seq'::regclass);


--
-- Name: authgroups_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY authgroups
    ADD CONSTRAINT authgroups_pkey PRIMARY KEY (gid);


--
-- Name: request_closed_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY request_closed
    ADD CONSTRAINT request_closed_pkey PRIMARY KEY (id);


--
-- Name: request_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY request
    ADD CONSTRAINT request_pkey PRIMARY KEY (id);


--
-- Name: search_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY search_statistics
    ADD CONSTRAINT search_statistics_pkey PRIMARY KEY (sessionid);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY libraries
    ADD CONSTRAINT users_pkey PRIMARY KEY (lid);


--
-- Name: library_barcodes_borrower_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY library_barcodes
    ADD CONSTRAINT library_barcodes_borrower_fkey FOREIGN KEY (borrower) REFERENCES libraries(lid);


--
-- Name: request_closed_filled_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY request_closed
    ADD CONSTRAINT request_closed_filled_by_fkey FOREIGN KEY (filled_by) REFERENCES libraries(lid);


--
-- Name: requests_active_msg_from_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_active
    ADD CONSTRAINT requests_active_msg_from_fkey FOREIGN KEY (msg_from) REFERENCES libraries(lid);


--
-- Name: requests_active_msg_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_active
    ADD CONSTRAINT requests_active_msg_to_fkey FOREIGN KEY (msg_to) REFERENCES libraries(lid);


--
-- Name: requests_active_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_active
    ADD CONSTRAINT requests_active_request_id_fkey FOREIGN KEY (request_id) REFERENCES request(id);


--
-- Name: requests_history_msg_from_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_history
    ADD CONSTRAINT requests_history_msg_from_fkey FOREIGN KEY (msg_from) REFERENCES libraries(lid);


--
-- Name: requests_history_msg_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_history
    ADD CONSTRAINT requests_history_msg_to_fkey FOREIGN KEY (msg_to) REFERENCES libraries(lid);


--
-- Name: requests_history_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_history
    ADD CONSTRAINT requests_history_request_id_fkey FOREIGN KEY (request_id) REFERENCES request_closed(id);


--
-- Name: sources_library_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY sources
    ADD CONSTRAINT sources_library_fkey FOREIGN KEY (library) REFERENCES libraries(lid);


--
-- Name: sources_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY sources
    ADD CONSTRAINT sources_request_id_fkey FOREIGN KEY (request_id) REFERENCES request(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

