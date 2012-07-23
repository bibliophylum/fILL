--
-- PostgreSQL database dump
--

-- Started on 2012-07-21 16:11:05 CDT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 1899 (class 1262 OID 17174)
-- Name: maplin; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE maplin WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


ALTER DATABASE maplin OWNER TO postgres;

\connect maplin

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

--
-- TOC entry 201 (class 1255 OID 17342)
-- Dependencies: 6
-- Name: armor(bytea); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION armor(bytea) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_armor';


ALTER FUNCTION public.armor(bytea) OWNER TO david;

--
-- TOC entry 174 (class 1255 OID 17315)
-- Dependencies: 6
-- Name: crypt(text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION crypt(text, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_crypt';


ALTER FUNCTION public.crypt(text, text) OWNER TO david;

--
-- TOC entry 202 (class 1255 OID 17343)
-- Dependencies: 6
-- Name: dearmor(text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION dearmor(text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_dearmor';


ALTER FUNCTION public.dearmor(text) OWNER TO david;

--
-- TOC entry 178 (class 1255 OID 17319)
-- Dependencies: 6
-- Name: decrypt(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION decrypt(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_decrypt';


ALTER FUNCTION public.decrypt(bytea, bytea, text) OWNER TO david;

--
-- TOC entry 180 (class 1255 OID 17321)
-- Dependencies: 6
-- Name: decrypt_iv(bytea, bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION decrypt_iv(bytea, bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_decrypt_iv';


ALTER FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) OWNER TO david;

--
-- TOC entry 170 (class 1255 OID 17311)
-- Dependencies: 6
-- Name: digest(text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION digest(text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_digest';


ALTER FUNCTION public.digest(text, text) OWNER TO david;

--
-- TOC entry 171 (class 1255 OID 17312)
-- Dependencies: 6
-- Name: digest(bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION digest(bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_digest';


ALTER FUNCTION public.digest(bytea, text) OWNER TO david;

--
-- TOC entry 177 (class 1255 OID 17318)
-- Dependencies: 6
-- Name: encrypt(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION encrypt(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_encrypt';


ALTER FUNCTION public.encrypt(bytea, bytea, text) OWNER TO david;

--
-- TOC entry 179 (class 1255 OID 17320)
-- Dependencies: 6
-- Name: encrypt_iv(bytea, bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION encrypt_iv(bytea, bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_encrypt_iv';


ALTER FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) OWNER TO david;

--
-- TOC entry 181 (class 1255 OID 17322)
-- Dependencies: 6
-- Name: gen_random_bytes(integer); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION gen_random_bytes(integer) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pg_random_bytes';


ALTER FUNCTION public.gen_random_bytes(integer) OWNER TO david;

--
-- TOC entry 175 (class 1255 OID 17316)
-- Dependencies: 6
-- Name: gen_salt(text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION gen_salt(text) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pg_gen_salt';


ALTER FUNCTION public.gen_salt(text) OWNER TO david;

--
-- TOC entry 176 (class 1255 OID 17317)
-- Dependencies: 6
-- Name: gen_salt(text, integer); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION gen_salt(text, integer) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pg_gen_salt_rounds';


ALTER FUNCTION public.gen_salt(text, integer) OWNER TO david;

--
-- TOC entry 172 (class 1255 OID 17313)
-- Dependencies: 6
-- Name: hmac(text, text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION hmac(text, text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_hmac';


ALTER FUNCTION public.hmac(text, text, text) OWNER TO david;

--
-- TOC entry 173 (class 1255 OID 17314)
-- Dependencies: 6
-- Name: hmac(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION hmac(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_hmac';


ALTER FUNCTION public.hmac(bytea, bytea, text) OWNER TO david;

--
-- TOC entry 169 (class 1255 OID 17304)
-- Dependencies: 6
-- Name: idx(anyarray, anyelement); Type: FUNCTION; Schema: public; Owner: mapapp
--

CREATE FUNCTION idx(anyarray, anyelement) RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $_$
  SELECT i FROM (
     SELECT generate_series(array_lower($1,1),array_upper($1,1))
  ) g(i)
  WHERE $1[i] = $2
  LIMIT 1;
$_$;


ALTER FUNCTION public.idx(anyarray, anyelement) OWNER TO mapapp;

--
-- TOC entry 200 (class 1255 OID 17341)
-- Dependencies: 6
-- Name: pgp_key_id(bytea); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_key_id(bytea) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_key_id_w';


ALTER FUNCTION public.pgp_key_id(bytea) OWNER TO david;

--
-- TOC entry 194 (class 1255 OID 17335)
-- Dependencies: 6
-- Name: pgp_pub_decrypt(bytea, bytea); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_decrypt(bytea, bytea) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text';


ALTER FUNCTION public.pgp_pub_decrypt(bytea, bytea) OWNER TO david;

--
-- TOC entry 196 (class 1255 OID 17337)
-- Dependencies: 6
-- Name: pgp_pub_decrypt(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_decrypt(bytea, bytea, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text';


ALTER FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) OWNER TO david;

--
-- TOC entry 198 (class 1255 OID 17339)
-- Dependencies: 6
-- Name: pgp_pub_decrypt(bytea, bytea, text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_decrypt(bytea, bytea, text, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text';


ALTER FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) OWNER TO david;

--
-- TOC entry 195 (class 1255 OID 17336)
-- Dependencies: 6
-- Name: pgp_pub_decrypt_bytea(bytea, bytea); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_decrypt_bytea(bytea, bytea) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea';


ALTER FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) OWNER TO david;

--
-- TOC entry 197 (class 1255 OID 17338)
-- Dependencies: 6
-- Name: pgp_pub_decrypt_bytea(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea';


ALTER FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) OWNER TO david;

--
-- TOC entry 199 (class 1255 OID 17340)
-- Dependencies: 6
-- Name: pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea';


ALTER FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) OWNER TO david;

--
-- TOC entry 190 (class 1255 OID 17331)
-- Dependencies: 6
-- Name: pgp_pub_encrypt(text, bytea); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_encrypt(text, bytea) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_text';


ALTER FUNCTION public.pgp_pub_encrypt(text, bytea) OWNER TO david;

--
-- TOC entry 192 (class 1255 OID 17333)
-- Dependencies: 6
-- Name: pgp_pub_encrypt(text, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_encrypt(text, bytea, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_text';


ALTER FUNCTION public.pgp_pub_encrypt(text, bytea, text) OWNER TO david;

--
-- TOC entry 191 (class 1255 OID 17332)
-- Dependencies: 6
-- Name: pgp_pub_encrypt_bytea(bytea, bytea); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_encrypt_bytea(bytea, bytea) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_bytea';


ALTER FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) OWNER TO david;

--
-- TOC entry 193 (class 1255 OID 17334)
-- Dependencies: 6
-- Name: pgp_pub_encrypt_bytea(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_bytea';


ALTER FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) OWNER TO david;

--
-- TOC entry 186 (class 1255 OID 17327)
-- Dependencies: 6
-- Name: pgp_sym_decrypt(bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_sym_decrypt(bytea, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_text';


ALTER FUNCTION public.pgp_sym_decrypt(bytea, text) OWNER TO david;

--
-- TOC entry 188 (class 1255 OID 17329)
-- Dependencies: 6
-- Name: pgp_sym_decrypt(bytea, text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_sym_decrypt(bytea, text, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_text';


ALTER FUNCTION public.pgp_sym_decrypt(bytea, text, text) OWNER TO david;

--
-- TOC entry 187 (class 1255 OID 17328)
-- Dependencies: 6
-- Name: pgp_sym_decrypt_bytea(bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_sym_decrypt_bytea(bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_bytea';


ALTER FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) OWNER TO david;

--
-- TOC entry 189 (class 1255 OID 17330)
-- Dependencies: 6
-- Name: pgp_sym_decrypt_bytea(bytea, text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_sym_decrypt_bytea(bytea, text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_bytea';


ALTER FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) OWNER TO david;

--
-- TOC entry 182 (class 1255 OID 17323)
-- Dependencies: 6
-- Name: pgp_sym_encrypt(text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_sym_encrypt(text, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_text';


ALTER FUNCTION public.pgp_sym_encrypt(text, text) OWNER TO david;

--
-- TOC entry 184 (class 1255 OID 17325)
-- Dependencies: 6
-- Name: pgp_sym_encrypt(text, text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_sym_encrypt(text, text, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_text';


ALTER FUNCTION public.pgp_sym_encrypt(text, text, text) OWNER TO david;

--
-- TOC entry 183 (class 1255 OID 17324)
-- Dependencies: 6
-- Name: pgp_sym_encrypt_bytea(bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_sym_encrypt_bytea(bytea, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_bytea';


ALTER FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) OWNER TO david;

--
-- TOC entry 185 (class 1255 OID 17326)
-- Dependencies: 6
-- Name: pgp_sym_encrypt_bytea(bytea, text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_sym_encrypt_bytea(bytea, text, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_bytea';


ALTER FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) OWNER TO david;

--
-- TOC entry 140 (class 1259 OID 17175)
-- Dependencies: 6
-- Name: libraries_lid_seq; Type: SEQUENCE; Schema: public; Owner: mapapp
--

CREATE SEQUENCE libraries_lid_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.libraries_lid_seq OWNER TO mapapp;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 141 (class 1259 OID 17177)
-- Dependencies: 1862 1863 6
-- Name: libraries; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE libraries (
    lid integer DEFAULT nextval('libraries_lid_seq'::regclass) NOT NULL,
    name character varying(30),
    password character varying(30),
    active smallint,
    email_address character varying(200),
    library character varying(200),
    mailing_address_line1 character varying(200),
    mailing_address_line2 character varying(200),
    mailing_address_line3 character varying(200),
    last_login timestamp without time zone,
    town character varying(50),
    region character varying(15),
    request_email_notification boolean DEFAULT false,
    city character varying(40),
    province character varying(5),
    post_code character(6),
    phone character(10),
    canada_post_customer_number character(10)
);


ALTER TABLE public.libraries OWNER TO mapapp;

--
-- TOC entry 142 (class 1259 OID 17185)
-- Dependencies: 6
-- Name: library_barcodes; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE library_barcodes (
    lid integer NOT NULL,
    borrower integer,
    barcode character varying(14)
);


ALTER TABLE public.library_barcodes OWNER TO mapapp;

--
-- TOC entry 143 (class 1259 OID 17188)
-- Dependencies: 6
-- Name: reports_rid_seq; Type: SEQUENCE; Schema: public; Owner: mapapp
--

CREATE SEQUENCE reports_rid_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.reports_rid_seq OWNER TO mapapp;

--
-- TOC entry 144 (class 1259 OID 17190)
-- Dependencies: 1864 6
-- Name: reports; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE reports (
    rid integer DEFAULT nextval('reports_rid_seq'::regclass) NOT NULL,
    rtype character varying(15),
    name character varying(40),
    description character varying(1000),
    generator character varying(40)
);


ALTER TABLE public.reports OWNER TO mapapp;

--
-- TOC entry 153 (class 1259 OID 17305)
-- Dependencies: 6
-- Name: reports_complete_seq; Type: SEQUENCE; Schema: public; Owner: mapapp
--

CREATE SEQUENCE reports_complete_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.reports_complete_seq OWNER TO mapapp;

--
-- TOC entry 154 (class 1259 OID 17307)
-- Dependencies: 1873 6
-- Name: reports_complete; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE reports_complete (
    rcid integer DEFAULT nextval('reports_complete_seq'::regclass) NOT NULL,
    lid integer NOT NULL,
    rid integer NOT NULL,
    range_start character(10),
    range_end character(10),
    report_file character varying(100)
);


ALTER TABLE public.reports_complete OWNER TO mapapp;

--
-- TOC entry 145 (class 1259 OID 17200)
-- Dependencies: 1865 6
-- Name: reports_queue; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE reports_queue (
    ts timestamp without time zone DEFAULT now(),
    rid integer NOT NULL,
    lid integer NOT NULL,
    range_start character(10),
    range_end character(10)
);


ALTER TABLE public.reports_queue OWNER TO mapapp;

--
-- TOC entry 146 (class 1259 OID 17204)
-- Dependencies: 6
-- Name: request_seq; Type: SEQUENCE; Schema: public; Owner: mapapp
--

CREATE SEQUENCE request_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.request_seq OWNER TO mapapp;

--
-- TOC entry 147 (class 1259 OID 17206)
-- Dependencies: 1866 1867 6
-- Name: request; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE request (
    id integer DEFAULT nextval('request_seq'::regclass) NOT NULL,
    title character varying(1024),
    author character varying(256),
    requester integer NOT NULL,
    patron_barcode character(14),
    current_target integer DEFAULT 1,
    note character varying(80),
    canada_post_endpoint character varying(1024),
    canada_post_tracking_number character varying(40)
);


ALTER TABLE public.request OWNER TO mapapp;

--
-- TOC entry 148 (class 1259 OID 17214)
-- Dependencies: 6
-- Name: request_closed; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE request_closed (
    id integer NOT NULL,
    title character varying(1024),
    author character varying(256),
    requester integer NOT NULL,
    patron_barcode character(14),
    filled_by integer,
    attempts integer,
    note character varying(80)
);


ALTER TABLE public.request_closed OWNER TO mapapp;

--
-- TOC entry 149 (class 1259 OID 17220)
-- Dependencies: 1868 6
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
-- TOC entry 150 (class 1259 OID 17224)
-- Dependencies: 6
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
-- TOC entry 151 (class 1259 OID 17227)
-- Dependencies: 1869 1870 1871 6
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
-- TOC entry 152 (class 1259 OID 17236)
-- Dependencies: 1872 6
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
-- TOC entry 155 (class 1259 OID 17344)
-- Dependencies: 6
-- Name: uid_sequence; Type: SEQUENCE; Schema: public; Owner: mapapp
--

CREATE SEQUENCE uid_sequence
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.uid_sequence OWNER TO mapapp;

--
-- TOC entry 156 (class 1259 OID 17346)
-- Dependencies: 1874 6
-- Name: users; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE users (
    uid integer DEFAULT nextval('uid_sequence'::regclass),
    username character varying(40) NOT NULL,
    password character varying(100) NOT NULL,
    lid integer NOT NULL
);


ALTER TABLE public.users OWNER TO mapapp;

--
-- TOC entry 1882 (class 2606 OID 17241)
-- Dependencies: 148 148
-- Name: request_closed_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY request_closed
    ADD CONSTRAINT request_closed_pkey PRIMARY KEY (id);


--
-- TOC entry 1880 (class 2606 OID 17243)
-- Dependencies: 147 147
-- Name: request_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY request
    ADD CONSTRAINT request_pkey PRIMARY KEY (id);


--
-- TOC entry 1884 (class 2606 OID 17245)
-- Dependencies: 151 151
-- Name: search_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY search_statistics
    ADD CONSTRAINT search_statistics_pkey PRIMARY KEY (sessionid);


--
-- TOC entry 1876 (class 2606 OID 17247)
-- Dependencies: 141 141
-- Name: unique_name; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY libraries
    ADD CONSTRAINT unique_name UNIQUE (name);


--
-- TOC entry 1878 (class 2606 OID 17249)
-- Dependencies: 141 141
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY libraries
    ADD CONSTRAINT users_pkey PRIMARY KEY (lid);


--
-- TOC entry 1886 (class 2606 OID 17351)
-- Dependencies: 156 156
-- Name: users_username_key; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 1887 (class 2606 OID 17250)
-- Dependencies: 142 141 1877
-- Name: library_barcodes_borrower_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY library_barcodes
    ADD CONSTRAINT library_barcodes_borrower_fkey FOREIGN KEY (borrower) REFERENCES libraries(lid);


--
-- TOC entry 1888 (class 2606 OID 17255)
-- Dependencies: 148 1877 141
-- Name: request_closed_filled_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY request_closed
    ADD CONSTRAINT request_closed_filled_by_fkey FOREIGN KEY (filled_by) REFERENCES libraries(lid);


--
-- TOC entry 1889 (class 2606 OID 17260)
-- Dependencies: 1877 141 149
-- Name: requests_active_msg_from_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_active
    ADD CONSTRAINT requests_active_msg_from_fkey FOREIGN KEY (msg_from) REFERENCES libraries(lid);


--
-- TOC entry 1890 (class 2606 OID 17265)
-- Dependencies: 149 1877 141
-- Name: requests_active_msg_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_active
    ADD CONSTRAINT requests_active_msg_to_fkey FOREIGN KEY (msg_to) REFERENCES libraries(lid);


--
-- TOC entry 1891 (class 2606 OID 17270)
-- Dependencies: 149 1879 147
-- Name: requests_active_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_active
    ADD CONSTRAINT requests_active_request_id_fkey FOREIGN KEY (request_id) REFERENCES request(id);


--
-- TOC entry 1892 (class 2606 OID 17275)
-- Dependencies: 150 1877 141
-- Name: requests_history_msg_from_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_history
    ADD CONSTRAINT requests_history_msg_from_fkey FOREIGN KEY (msg_from) REFERENCES libraries(lid);


--
-- TOC entry 1893 (class 2606 OID 17280)
-- Dependencies: 1877 150 141
-- Name: requests_history_msg_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_history
    ADD CONSTRAINT requests_history_msg_to_fkey FOREIGN KEY (msg_to) REFERENCES libraries(lid);


--
-- TOC entry 1894 (class 2606 OID 17285)
-- Dependencies: 150 148 1881
-- Name: requests_history_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_history
    ADD CONSTRAINT requests_history_request_id_fkey FOREIGN KEY (request_id) REFERENCES request_closed(id);


--
-- TOC entry 1895 (class 2606 OID 17290)
-- Dependencies: 141 1877 152
-- Name: sources_library_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY sources
    ADD CONSTRAINT sources_library_fkey FOREIGN KEY (library) REFERENCES libraries(lid);


--
-- TOC entry 1896 (class 2606 OID 17295)
-- Dependencies: 1879 147 152
-- Name: sources_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY sources
    ADD CONSTRAINT sources_request_id_fkey FOREIGN KEY (request_id) REFERENCES request(id);


--
-- TOC entry 1901 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2012-07-21 16:11:11 CDT

--
-- PostgreSQL database dump complete
--

