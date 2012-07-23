--
-- PostgreSQL database dump
--

-- Started on 2012-07-22 22:19:44 CDT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 1911 (class 1262 OID 17393)
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
-- TOC entry 169 (class 1255 OID 17394)
-- Dependencies: 6
-- Name: armor(bytea); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION armor(bytea) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_armor';


ALTER FUNCTION public.armor(bytea) OWNER TO david;

--
-- TOC entry 170 (class 1255 OID 17395)
-- Dependencies: 6
-- Name: crypt(text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION crypt(text, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_crypt';


ALTER FUNCTION public.crypt(text, text) OWNER TO david;

--
-- TOC entry 171 (class 1255 OID 17396)
-- Dependencies: 6
-- Name: dearmor(text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION dearmor(text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_dearmor';


ALTER FUNCTION public.dearmor(text) OWNER TO david;

--
-- TOC entry 172 (class 1255 OID 17397)
-- Dependencies: 6
-- Name: decrypt(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION decrypt(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_decrypt';


ALTER FUNCTION public.decrypt(bytea, bytea, text) OWNER TO david;

--
-- TOC entry 173 (class 1255 OID 17398)
-- Dependencies: 6
-- Name: decrypt_iv(bytea, bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION decrypt_iv(bytea, bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_decrypt_iv';


ALTER FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) OWNER TO david;

--
-- TOC entry 174 (class 1255 OID 17399)
-- Dependencies: 6
-- Name: digest(text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION digest(text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_digest';


ALTER FUNCTION public.digest(text, text) OWNER TO david;

--
-- TOC entry 175 (class 1255 OID 17400)
-- Dependencies: 6
-- Name: digest(bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION digest(bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_digest';


ALTER FUNCTION public.digest(bytea, text) OWNER TO david;

--
-- TOC entry 176 (class 1255 OID 17401)
-- Dependencies: 6
-- Name: encrypt(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION encrypt(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_encrypt';


ALTER FUNCTION public.encrypt(bytea, bytea, text) OWNER TO david;

--
-- TOC entry 177 (class 1255 OID 17402)
-- Dependencies: 6
-- Name: encrypt_iv(bytea, bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION encrypt_iv(bytea, bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_encrypt_iv';


ALTER FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) OWNER TO david;

--
-- TOC entry 178 (class 1255 OID 17403)
-- Dependencies: 6
-- Name: gen_random_bytes(integer); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION gen_random_bytes(integer) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pg_random_bytes';


ALTER FUNCTION public.gen_random_bytes(integer) OWNER TO david;

--
-- TOC entry 179 (class 1255 OID 17404)
-- Dependencies: 6
-- Name: gen_salt(text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION gen_salt(text) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pg_gen_salt';


ALTER FUNCTION public.gen_salt(text) OWNER TO david;

--
-- TOC entry 180 (class 1255 OID 17405)
-- Dependencies: 6
-- Name: gen_salt(text, integer); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION gen_salt(text, integer) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pg_gen_salt_rounds';


ALTER FUNCTION public.gen_salt(text, integer) OWNER TO david;

--
-- TOC entry 181 (class 1255 OID 17406)
-- Dependencies: 6
-- Name: hmac(text, text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION hmac(text, text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_hmac';


ALTER FUNCTION public.hmac(text, text, text) OWNER TO david;

--
-- TOC entry 182 (class 1255 OID 17407)
-- Dependencies: 6
-- Name: hmac(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION hmac(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_hmac';


ALTER FUNCTION public.hmac(bytea, bytea, text) OWNER TO david;

--
-- TOC entry 183 (class 1255 OID 17408)
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
-- TOC entry 184 (class 1255 OID 17409)
-- Dependencies: 6
-- Name: pgp_key_id(bytea); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_key_id(bytea) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_key_id_w';


ALTER FUNCTION public.pgp_key_id(bytea) OWNER TO david;

--
-- TOC entry 185 (class 1255 OID 17410)
-- Dependencies: 6
-- Name: pgp_pub_decrypt(bytea, bytea); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_decrypt(bytea, bytea) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text';


ALTER FUNCTION public.pgp_pub_decrypt(bytea, bytea) OWNER TO david;

--
-- TOC entry 186 (class 1255 OID 17411)
-- Dependencies: 6
-- Name: pgp_pub_decrypt(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_decrypt(bytea, bytea, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text';


ALTER FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) OWNER TO david;

--
-- TOC entry 187 (class 1255 OID 17412)
-- Dependencies: 6
-- Name: pgp_pub_decrypt(bytea, bytea, text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_decrypt(bytea, bytea, text, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text';


ALTER FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) OWNER TO david;

--
-- TOC entry 188 (class 1255 OID 17413)
-- Dependencies: 6
-- Name: pgp_pub_decrypt_bytea(bytea, bytea); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_decrypt_bytea(bytea, bytea) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea';


ALTER FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) OWNER TO david;

--
-- TOC entry 189 (class 1255 OID 17414)
-- Dependencies: 6
-- Name: pgp_pub_decrypt_bytea(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea';


ALTER FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) OWNER TO david;

--
-- TOC entry 190 (class 1255 OID 17415)
-- Dependencies: 6
-- Name: pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea';


ALTER FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) OWNER TO david;

--
-- TOC entry 191 (class 1255 OID 17416)
-- Dependencies: 6
-- Name: pgp_pub_encrypt(text, bytea); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_encrypt(text, bytea) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_text';


ALTER FUNCTION public.pgp_pub_encrypt(text, bytea) OWNER TO david;

--
-- TOC entry 192 (class 1255 OID 17417)
-- Dependencies: 6
-- Name: pgp_pub_encrypt(text, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_encrypt(text, bytea, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_text';


ALTER FUNCTION public.pgp_pub_encrypt(text, bytea, text) OWNER TO david;

--
-- TOC entry 193 (class 1255 OID 17418)
-- Dependencies: 6
-- Name: pgp_pub_encrypt_bytea(bytea, bytea); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_encrypt_bytea(bytea, bytea) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_bytea';


ALTER FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) OWNER TO david;

--
-- TOC entry 194 (class 1255 OID 17419)
-- Dependencies: 6
-- Name: pgp_pub_encrypt_bytea(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_bytea';


ALTER FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) OWNER TO david;

--
-- TOC entry 195 (class 1255 OID 17420)
-- Dependencies: 6
-- Name: pgp_sym_decrypt(bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_sym_decrypt(bytea, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_text';


ALTER FUNCTION public.pgp_sym_decrypt(bytea, text) OWNER TO david;

--
-- TOC entry 196 (class 1255 OID 17421)
-- Dependencies: 6
-- Name: pgp_sym_decrypt(bytea, text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_sym_decrypt(bytea, text, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_text';


ALTER FUNCTION public.pgp_sym_decrypt(bytea, text, text) OWNER TO david;

--
-- TOC entry 197 (class 1255 OID 17422)
-- Dependencies: 6
-- Name: pgp_sym_decrypt_bytea(bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_sym_decrypt_bytea(bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_bytea';


ALTER FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) OWNER TO david;

--
-- TOC entry 198 (class 1255 OID 17423)
-- Dependencies: 6
-- Name: pgp_sym_decrypt_bytea(bytea, text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_sym_decrypt_bytea(bytea, text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_bytea';


ALTER FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) OWNER TO david;

--
-- TOC entry 199 (class 1255 OID 17424)
-- Dependencies: 6
-- Name: pgp_sym_encrypt(text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_sym_encrypt(text, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_text';


ALTER FUNCTION public.pgp_sym_encrypt(text, text) OWNER TO david;

--
-- TOC entry 200 (class 1255 OID 17425)
-- Dependencies: 6
-- Name: pgp_sym_encrypt(text, text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_sym_encrypt(text, text, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_text';


ALTER FUNCTION public.pgp_sym_encrypt(text, text, text) OWNER TO david;

--
-- TOC entry 201 (class 1255 OID 17426)
-- Dependencies: 6
-- Name: pgp_sym_encrypt_bytea(bytea, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_sym_encrypt_bytea(bytea, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_bytea';


ALTER FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) OWNER TO david;

--
-- TOC entry 202 (class 1255 OID 17427)
-- Dependencies: 6
-- Name: pgp_sym_encrypt_bytea(bytea, text, text); Type: FUNCTION; Schema: public; Owner: david
--

CREATE FUNCTION pgp_sym_encrypt_bytea(bytea, text, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_bytea';


ALTER FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) OWNER TO david;

--
-- TOC entry 140 (class 1259 OID 17428)
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

--
-- TOC entry 1914 (class 0 OID 0)
-- Dependencies: 140
-- Name: libraries_lid_seq; Type: SEQUENCE SET; Schema: public; Owner: mapapp
--

SELECT pg_catalog.setval('libraries_lid_seq', 140, false);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 141 (class 1259 OID 17430)
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
-- TOC entry 142 (class 1259 OID 17438)
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
-- TOC entry 143 (class 1259 OID 17441)
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
-- TOC entry 1915 (class 0 OID 0)
-- Dependencies: 143
-- Name: reports_rid_seq; Type: SEQUENCE SET; Schema: public; Owner: mapapp
--

SELECT pg_catalog.setval('reports_rid_seq', 8, true);


--
-- TOC entry 144 (class 1259 OID 17443)
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
-- TOC entry 145 (class 1259 OID 17450)
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
-- TOC entry 1916 (class 0 OID 0)
-- Dependencies: 145
-- Name: reports_complete_seq; Type: SEQUENCE SET; Schema: public; Owner: mapapp
--

SELECT pg_catalog.setval('reports_complete_seq', 1, false);


--
-- TOC entry 146 (class 1259 OID 17452)
-- Dependencies: 1865 6
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
-- TOC entry 147 (class 1259 OID 17456)
-- Dependencies: 1866 6
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
-- TOC entry 148 (class 1259 OID 17460)
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
-- TOC entry 1917 (class 0 OID 0)
-- Dependencies: 148
-- Name: request_seq; Type: SEQUENCE SET; Schema: public; Owner: mapapp
--

SELECT pg_catalog.setval('request_seq', 960, true);


--
-- TOC entry 149 (class 1259 OID 17462)
-- Dependencies: 1867 1868 6
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
-- TOC entry 150 (class 1259 OID 17470)
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
-- TOC entry 151 (class 1259 OID 17476)
-- Dependencies: 1869 6
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
-- TOC entry 152 (class 1259 OID 17480)
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
-- TOC entry 153 (class 1259 OID 17483)
-- Dependencies: 1870 1871 1872 6
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
-- TOC entry 154 (class 1259 OID 17492)
-- Dependencies: 1873 6
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
-- TOC entry 155 (class 1259 OID 17496)
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
-- TOC entry 1918 (class 0 OID 0)
-- Dependencies: 155
-- Name: uid_sequence; Type: SEQUENCE SET; Schema: public; Owner: mapapp
--

SELECT pg_catalog.setval('uid_sequence', 123, true);


--
-- TOC entry 156 (class 1259 OID 17498)
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
-- TOC entry 1897 (class 0 OID 17430)
-- Dependencies: 141
-- Data for Name: libraries; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY libraries (lid, name, password, active, email_address, library, mailing_address_line1, mailing_address_line2, mailing_address_line3, last_login, town, region, request_email_notification, city, province, post_code, phone, canada_post_customer_number) FROM stdin;
127	Caitlyn	Caitlyn	0		PLS - clerk				\N	\N	\N	f	\N	\N	\N	\N	\N
2	test	test	1	David_A_Christensen@hotmail.com	A Test Library	456 Someother St.	Mycity, MB  R7A 0X0	\N	\N	\N	\N	f	\N	\N	\N	\N	\N
136	MVBB	MVBB	1	victoriabeachbranch@hotmail.com	Bibliotheque Allard - Victoria Beach	Box 279	Victoria Beach, MB  R0E 2C0		2010-12-15 14:34:37.863963	\N	\N	f	\N	\N	\N	\N	\N
131	UCN	UCN	1		University Colleges North pilot project				2010-12-16 14:12:00.413037	\N	\N	f	\N	\N	\N	\N	\N
130	UNC	UNC	1		Delete me!				2008-07-28 15:22:43	\N	\N	f	\N	\N	\N	\N	\N
132	Headingley Municipal Library	Headingley Municipal Library	0	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N
128	Margo	Margo	1		PLS - staff				2008-09-15 15:49:51	\N	\N	f	\N	\N	\N	\N	\N
137	TEST	TEST	1	nowhere@just.testing	A test library				2011-02-02 18:50:18.609395	\N	\N	f	\N	\N	\N	\N	\N
72	MRA	MRA	1	rcreglib@mts.net	Rapid City Regional Library	425 3rd Ave.	Box 8	Rapid City, MB  R0K 1W0	2011-01-27 14:59:47.699491	Rapid City	WESTMAN	f	Rapid City	MB	R0K1W0	\N	\N
9	MNHA	MNHA	1	tansi23@hotmail.com	Ayamiscikewikamik		Box 250	Norway House, MB  ROB 1BO	2010-07-27 11:50:28.606789	\N	\N	f	Norway House	MB	ROB1BO	\N	\N
105	MWRR	MWRR	0	lgirardi@rrcc.mb.ca	Red River College	2055 Notre Dame Ave		Winnipeg, MB  R3H 0J9	\N	\N	\N	f	Winnipeg	MB	R3H0J9	\N	\N
108	MSERC	MSERC	0	serc2mb@mb.sympatico.ca	Brandon SERC	731B Princess Ave		Brandon, MB  R7A 0P4	\N	\N	\N	f	Brandon	MB	R7A0P4	\N	\N
109	MWMRC	MWMRC	0	bdearth@itc.mb.ca	Industrial Technology Centre	200-78 Innovation Drive		Winnipeg, MB  R3T 6C2	\N	\N	\N	f	Winnipeg	MB	R3T6C2	\N	\N
95	MCNC	MCNC	1	carberry@wmrlibrary.mb.ca	Western Manitoba Regional Library - Carberry/North Cypress	115 Main Street	Box 382	Carberry, MB  R0K 0H0	2011-02-01 16:29:41.937069	Carberry	WESTMAN	f	Carberry	MB	R0K0H0	\N	\N
13	MIBR	MIBR	1	ritchotlib@hotmail.com	Bibliothèque Ritchot - Main	310 Lamoureux Rd.	Box 340	Ile des Chenes, MB  R0A 0T0	2011-02-01 16:34:41.862614	Ile des Chenes	EASTMAN	f	Ile des Chenes	MB	R0A0T0	\N	\N
80	MSL	MSL	1	dslibrary@hotmail.com	Snow Lake Community Library	101 Cherry St.	Box 760	Snow Lake, MB  R0B 1M0	2011-02-03 12:37:04.304046	Snow Lake	NORMAN	f	Snow Lake	MB	R0B1M0	\N	\N
58	MDPGV	MDPGV	1	grandvw@mts.net	Parkland Regional Library - Grandview	433 Main St.	Box Box 700	Grandview, MB  R0L 0Y0	2011-02-01 15:07:26.727646	Grandview	PARKLAND	f	Grandview	MB	R0L0Y0	\N	\N
107	MDPST	MDPST	1	stratlibrary@mts.net	Parkland Regional Library - Strathclair	50 Main St.	Box 303	Strathclair, MB  R0J 2C0	2011-01-31 09:12:18.896689	Strathclair	WESTMAN	f	Strathclair	MB	R0J2C0	\N	\N
134	MDS	MDS	1	staff@springfieldlibrary.ca	Springfield Public Library	Box 340		Dugald, MB  R0E 0K0	2011-02-02 12:28:41.043479	Oakbank	EASTMAN	f	Dugald	MB	R0E0K0	\N	\N
81	MWOWH	MWOWH	1	headlib@scrlibrary.mb.ca	South Central Regional Library - Office	160 Main Street   (325-5864)	Box 1540	Winkler, MB  R6W 4B4	2010-09-30 14:30:24.845846	\N	\N	f	Winkler	MB	R6W4B4	\N	\N
63	MDPOR	MDPOR	1	orlibrary@inetlink.ca	Parkland Regional Library - Ochre River	203 Main St.	Box 219	Ochre River, MB  R0L 1K0	2011-02-02 17:58:17.64862	Ochre River	PARKLAND	f	Ochre River	MB	R0L1K0	\N	\N
121	TWAS	TWAS	1		Bren Del Win Centennial Library - Waskada	30 Souris Ave.		Waskada, MB  R0M 2E0	\N	Waskada	WESTMAN	f	Waskada	MB	R0M2E0	\N	\N
122	MPFN	MPFN	1	peguislibrary@yahoo.ca	Peguis Community	Lot 30 Peguis Indian Reserve	Box Box 190	Peguis, MB  R0J 3J0	2009-03-04 17:23:42	Peguis	INTERLAKE	f	Peguis	MB	R0J3J0	\N	\N
125	MNCN	MNCN	1	NCNBranch@Thompsonlibrary.com	Thompson Public Library - Nelson House	1 ATEC Drive	Box 454	Nelson House, MB  R0B 1A0	\N	Nelson House	NORMAN	f	Nelson House	MB	R0B1A0	\N	\N
35	MHH	MHH	1	hml@mts.net	Headingley Municipal Library	49 Alboro Street		Headingley, MB  R4J 1A3	2011-02-03 10:21:31.672572	Headingly	CENTRAL	f	Headingley	MB	R4J1A3	\N	\N
78	MSTR	MSTR	1	sroselib@mts.net	Ste. Rose Regional Library	580 Central Avenue	General Delivery	Ste. Rose du Lac, MB  R0L 1S0	2011-02-03 12:41:49.075946	Ste. Rose du Lac	PARKLAND	f	Ste. Rose du Lac	MB	R0L1S0	\N	\N
124	MDPSLA	MDPSLA	1	lazarelib@mts.net	Parkland Regional Library - St. Lazare		Box 201	St. Lazare, MB  R0M 1Y0	2010-11-25 17:06:24.004507	St. Lazare	WESTMAN	f	St. Lazare	MB	R0M1Y0	\N	\N
103	MEPL	MEPL	1	library@townofemerson.com	Emerson Library	104 Church Street	Box 340	Emerson, MB  R0A 0L0	2011-01-24 18:56:43.490848	Emerson	CENTRAL	f	Emerson	MB	R0A0L0	\N	\N
28	MCH	MCH	1	mchlibrary@yahoo.ca	Churchill Public Library	180 Laverendrye	Box 730	Churchill, MB  R0B 0E0	2011-02-03 10:04:52.805515	Churchill	NORMAN	f	Churchill	MB	R0B0E0	\N	\N
27	MEL	MEL	1	epl1@mts.net	Eriksdale Public Library	PTH 68  (9 Main St.)	Box 219	Eriksdale, MB  R0C 0W0	2011-02-03 12:27:27.45312	Eriksdale	INTERLAKE	f	Eriksdale	MB	R0C0W0	\N	\N
61	MDPMC	MDPMC	1	mccrea16@mts.net	Parkland Regional Library - McCreary	615 Burrows Rd.	Box 297	McCreary, MB  R0J 1B0	2011-01-18 15:43:28.57626	McCreary	PARKLAND	f	McCreary	MB	R0J1B0	\N	\N
42	MLR	MLR	1	lrlib@mts.net	Leaf Rapids Public Library	20 Town Centre	Box 190	Leaf Rapids, MB  R0B 1W0	2009-05-25 18:16:48	Leaf Rapids	NORMAN	f	Leaf Rapids	MB	R0B1W0	\N	\N
67	MDPWP	MDPWP	1	wpgosis@mts.net	Parkland Regional Library - Winnipegosis	130 2nd St.	Box Box 10	Winnipegosis, MB  R0L 2G0	2011-02-02 14:18:10.749017	Winnipegosis	PARKLAND	f	Winnipegosis	MB	R0L2G0	\N	\N
43	MLLC	MLLC	1	lynnlib@mts.net	Lynn Lake Centennial Library	503 Sherritt Ave.	Box 1127	Lynn Lake, MB  R0B 0W0	\N	Lynn Lake	NORMAN	f	Lynn Lake	MB	R0B0W0	\N	\N
50	MDPBR	MDPBR	1	briver@mts.net	Parkland Regional Library - Birch River	116 3rd St. East	Box 245	Birch River, MB  R0L 0E0	2008-12-18 20:36:09	Birch River	PARKLAND	f	Birch River	MB	R0L0E0	\N	\N
60	MDPLA	MDPLA	1	langlib@mts.net	Parkland Regional Library - Langruth	402 Main St.	Box 154	Langruth, MB  R0H 0N0	2010-07-30 09:16:07.67375	Langruth	CENTRAL	f	Langruth	MB	R0H0N0	\N	\N
77	MBI	MBI	1	binslb@mts.net	Russell & District Library - Binscarth	106 Russell St.	Box  379	Binscarth, MB  R0J 0G0	2012-07-13 14:34:08.39894	Binscarth	PARKLAND	f	Binscarth	MB	R0J0G0	\N	\N
1	DTL	DTL	1	David_A_Christensen@hotmail.com	The Great Library of Davidland	123 Some Street South	Brandon, MB  R7A 7A1		2009-12-09 15:11:39.580858	\N	\N	f	Brandon	MB	R7A0L5	\N	\N
89	MESP	MESP	1	pcilibrary@goinet.ca	Southwestern Manitoba Regional Library - Pierson	58 Railway Avenue	Box 39	Pierson, MB  R0M 1S0	2011-01-28 09:45:37.364496	Pierson	WESTMAN	f	Pierson	MB	R0M1S0	\N	\N
54	MDPER	MDPER	1	erick11@mts.net	Parkland Regional Library - Erickson	20 Main St. W	Box 385	Erickson, MB  R0J 0P0	2011-02-01 11:11:13.915092	Erickson	WESTMAN	f	Erickson	MB	R0J0P0	\N	\N
49	MDP	MDP	1	prlhq@parklandlib.mb.ca	Parkland Regional Library - Main	504 Main St. N.		Dauphin, MB  R7N 1C9	2011-01-25 13:15:46.362271	\N	\N	f	Dauphin	MB	R7N1C9	\N	\N
17	MLB	MLB	1	bsjl@bsjl.ca	Bibliothèque Saint-Joachim Library	29, baie Normandeau Bay	Box 39	La Broquerie, MB  R0A 0W0	2011-02-02 08:08:42.558263	La Broquerie	EASTMAN	f	La Broquerie	MB	R0A0W0	\N	\N
52	MDPBO	MDPBO	1	bows18@mts.net	Parkland Regional Library - Bowsman	105 2nd St.	Box 209	Bowsman, MB  R0L 0H0	2011-01-04 11:20:46.044179	Bowsman	PARKLAND	f	Bowsman	MB	R0L0H0	\N	\N
55	MDPFO	MDPFO	1	foxlib@mts.net	Parkland Regional Library - Foxwarren	312 Webster Ave.	Box 204	Foxwarren, MB  R0J 0P0	2011-02-01 10:41:17.93653	Foxwarren	WESTMAN	f	Foxwarren	MB	R0J0P0	\N	\N
86	MTSIR	MTSIR	1	teulonbranchlibrary@yahoo.com	South Interlake Regional Library - Teulon	19 Beach Road	Box 68	Teulon, MB  R0C 3B0	2011-02-02 10:47:07.748734	Teulon	INTERLAKE	f	Teulon	MB	R0C3B0	\N	\N
68	MP	MP	1	email@pinawapubliclibrary.com	Pinawa Public Library	Vanier Road	General Delivery	Pinawa, MB  R0E 1L0	2012-07-13 14:32:52.893502	Pinawa	EASTMAN	f	Pinawa	MB	R0E1L0	\N	\N
11	MSJB	MSJB	1	biblio@atrium.ca	Bibliothèque Montcalm	113B 2nd	Box 345	Saint-Jean-Baptiste, MB  R0G 2B0	2011-02-02 09:30:53.111402	Saint-Jean-Baptiste	CENTRAL	f	Saint-Jean-Baptiste	MB	R0G2B0	\N	\N
22	ME	ME	1	elkhornbrl@rfnow.com	Border Regional Library - Elkhorn	211 Richhill Ave.	Box 370	Elkhorn, MB  R0M 0N0	2011-02-03 09:59:18.485715	Elkhorn	WESTMAN	f	Elkhorn	MB	R0M0N0	\N	\N
41	MPM	MPM	1	pmlibrary@mts.net	Pilot Mound Public Library - Pilot Mound	219 Broadway Ave. W.	Box 126	Pilot Mound, MB  R0G 1P0	2011-02-03 10:55:31.63491	Pilot Mound	CENTRAL	f	Pilot Mound	MB	R0G1P0	\N	\N
45	MMNN	MMNN	1	maclib@mts.net	North Norfolk-MacGregor Library	35 Hampton St. E.	Box 760	MacGregor, MB  R0H 0R0	2011-02-02 15:10:26.856663	MacGregor	CENTRAL	f	MacGregor	MB	R0H0R0	\N	\N
14	MSAD	MSAD	1	stadbranch@hotmail.com	Bibliothèque Ritchot - St. Adolphe	444 rue La Seine		St. Adolphe, MB  R5A 1C2	2011-02-02 15:52:05.639717	St. Adolphe	EASTMAN	f	St. Adolphe	MB	R5A1C2	\N	\N
73	MRP	MRP	1	restonlb@yahoo.ca	Reston District Library	220 - 4th St.	Box 340	Reston, MB  R0M 1X0	2011-02-03 11:23:53.280404	Reston	WESTMAN	f	Reston	MB	R0M1X0	\N	\N
66	MDPSI	MDPSI	1	siglun15@mts.net	Parkland Regional Library - Siglunes	5 - 61 Main St.	Box 368	Ashern, MB  R0C 0E0	2011-02-02 15:17:39.520904	Ashern	INTERLAKE	f	Ashern	MB	R0C0E0	\N	\N
98	MMR	MMR	1	mmr@mts.net	Minnedosa Regional Library	45 1st  Ave. SE	Box 1226	Minnedosa, MB  R0J 1E0	2011-02-03 12:20:34.182761	Minnedosa	WESTMAN	f	Minnedosa	MB	R0J1E0	\N	\N
23	MMCA	MMCA	1	library@mcauley-mb.com	Border Regional Library - McAuley	207 Qu'Appelle Street	Box 234	McAuley, MB  R0M 1H0	2011-01-25 14:27:40.737841	McAuley	WESTMAN	f	McAuley	MB	R0M1H0	\N	\N
76	MRD	MRD	1	ruslib@mts.net	Russell & District Regional Library - Main	339 Main St.	Box 340	Russell, MB  R0J 1W0	2011-02-01 13:17:19.029251	Russell	PARKLAND	f	Russell	MB	R0J1W0	\N	\N
62	MDPMI	MDPMI	1	minitons@mts.net	Parkland Regional Library - Minitonas	300 Main St.	Box 496	Minitonas, MB  R0L 1G0	2011-02-02 15:14:04.465687	Minitonas	PARKLAND	f	Minitonas	MB	R0L1G0	\N	\N
74	MRO	MRO	1	rrl@mts.net	Rossburn Regional Library	53 Main St. North	Box 87	Rossburn, MB  R0J 1V0	2011-01-28 15:18:05.156408	Rossburn	PARKLAND	f	Rossburn	MB	R0J1V0	\N	\N
25	MDB	MDB	1	bdwlib@mts.net	Bren Del Win Centennial Library	211 North Railway W.	Box 584	Deloraine, MB  R0M 0M0	2011-02-02 10:56:11.631378	Deloriane	WESTMAN	f	Deloraine	MB	R0M0M0	\N	\N
19	MS	MS	1	somlib@mts.net	Bibliotheque Somerset Library	Box 279	289 Carlton Avenue 	Somerset, MB  R0G 2L0	2011-02-01 15:51:52.043388	Somerset	CENTRAL	f	Somerset	MB	R0G2L0	\N	\N
79	MSEL	MSEL	1	ill@ssarl.org	Red River North Regional Library	303 Main Street		Selkirk, MB  R1A 1S7	2011-11-03 15:59:47.492864	Selkirk	INTERLAKE	f	Selkirk	MB	R1A1S7	\N	\N
18	MSA	MSA	1	steannelib@steannemb.ca	Bibliothèque Ste. Anne	16 rue de l'Eglise		Ste. Anne, MB  R5H 1H8	2011-02-03 11:16:24.882061	Ste. Anne	EASTMAN	f	Ste. Anne	MB	R5H1H8	\N	\N
31	MRB	MRB	1	rlibrary@mts.net	Evergreen Regional Library - Riverton	56 Laura Ave.	Box 310	Riverton, MB  R0C 2R0	2012-02-29 14:00:18.263003	Riverton	INTERLAKE	f	Riverton	MB	R0C2R0	\N	\N
91	MTP	MTP	1	illthepas@mts.net	The Pas Regional Library	53 Edwards Avenue	Box 4100	The Pas, MB  R9A 1R2	2011-02-02 15:54:58.568087	The Pas	NORMAN	f	The Pas	MB	R9A1R2	\N	\N
38	MLDB	MLDB	1	mldb@mts.net	Lac du Bonnet Regional Library	84-3rd Street	Box 216	Lac du Bonnet, MB  R0E 1A0	2011-02-03 10:17:25.172551	Lac du Bonnet	EASTMAN	f	Lac du Bonnet	MB	R0E1A0	\N	\N
100	MWP	MWP	1	legislative_library@gov.mb.ca	Manitoba Legislative Library	100 - 200 Vaughan		Winnipeg, MB  R3C 1T5	2012-03-28 13:56:42.767746	\N	\N	f	Winnipeg	MB	R3C1T5	\N	\N
34	MSOG	MSOG	1	ill@sourislibrary.mb.ca	Glenwood & Souris Regional Library	18 - 114 2nd St. S.	Box 760	Souris, MB  R0K 2C0	2011-02-01 21:41:47.575609	Souris	WESTMAN	f	Souris	MB	R0K2C0	\N	\N
71	MRIP	MRIP	1	pcrl@mts.net	Prairie Crocus Regional Library	137 Main Street	Box 609	Rivers, MB  R0K 1X0	2012-04-30 09:06:07.229841	Rivers	WESTMAN	f	Rivers	MB	R0K1X0	\N	\N
84	MWOW	MWOW	1	will@scrlibrary.mb.ca	South Central Regional Library - Winkler	160 Main Street (325-7174)	Box 1540	Winkler, MB  R6W 4B4	2012-05-28 11:17:02.575702	Winkler	CENTRAL	f	Winkler	MB	R6W4B4	\N	\N
40	MCCB	MCCB	1	cartlib@mts.net	Lakeland Regional Library - Cartwright	483 Veteran Drive	Box 235	Cartwright, MB  R0K 0L0	2011-02-02 16:34:12.994159	Cartwright	CENTRAL	f	Cartwright	MB	R0K0L0	\N	\N
53	MDA	MDA	1	DauphinLibrary@parklandlib.mb.ca	Parkland Regional Library - Dauphin	504 Main Street North		Dauphin, MB  R7N 1C9	2011-02-02 19:42:49.630926	Dauphin	PARKLAND	f	Dauphin	MB	R7N1C9	\N	\N
65	MDPSL	MDPSL	1	sllibrary@mts.net	Parkland Regional Library - Shoal Lake	418 Station Road S.	Box 428	Shoal Lake, MB  R0J 1Z0	2011-02-01 14:06:09.972297	Shoal Lake	WESTMAN	f	Shoal Lake	MB	R0J1Z0	\N	\N
51	MDPBI	MDPBI	1	birtlib@mts.net	Parkland Regional Library - Birtle	907 Main Street	Box 207	Birtle, MB  R0M 0C0	2011-02-03 11:31:03.715139	Birtle	WESTMAN	f	Birtle	MB	R0M0C0	\N	\N
16	MSCL	MSCL	1	stclib@mts.net	Bibliothèque Saint-Claude	50 1st Street	Box 203	St. Claude, MB  R0G 1Z0	2011-01-20 11:20:23.16518	St. Claude	CENTRAL	f	St. Claude	MB	R0G1Z0	\N	\N
12	MNDP	MNDP	1	ndbiblio@yahoo.ca	Bibliothèque Pere Champagne	44 Rue Rogers	Box 399	Notre Dame de Lourdes, MB  R0G 1M0	2011-02-01 09:47:15.311152	Notre Dame de Lourdes	CENTRAL	f	Notre Dame de Lourdes	MB	R0G1M0	\N	\N
26	MBBR	MBBR	1	brrlibr2@mts.net	Brokenhead River Regional Library	427 Park  Ave.	Box 1087	Beausejour, MB  R0E 0C0	2011-02-02 17:21:32.430374	Beausejour	EASTMAN	f	Beausejour	MB	R0E0C0	\N	\N
120	MHW	MHW	1	hartney@wmrlibrary.mb.ca	Western Manitoba Regional - Hartney Cameron Branch	209 Airdrie St.	Box 121	Hartney, MB  R0M 0X0	2011-01-29 11:28:09.80128	Hartney	WESTMAN	f	Hartney	MB	R0M0X0	\N	\N
93	MMVR	MMVR	1	valleylib@mts.net	Valley Regional Library	141Main Street South	Box 397	Morris, MB  R0G 1K0	2011-02-03 12:17:58.225938	Morris	CENTRAL	f	Morris	MB	R0G1K0	\N	\N
10	MSTG	MSTG	1	ill@allardlibrary.com	Bibliotheque Allard	104086 PTH 11	Box 157	St Georges, MB  R0E 1V0	2011-02-03 12:15:00.441084	St Georges	EASTMAN	f	St Georges	MB	R0E1V0	\N	\N
112	ASGY	ASGY	0	lfrolek@yrl.ab.ca	Yellowhead Regional		Box 400	Spruce Grove, AB, MB  T7X 2Y1	\N	\N	\N	f	Spruce Grove, AB	MB	T7X2Y1	\N	\N
104	MBAC	MBAC	1	library@assiniboinec.mb.ca	Assiniboine Community College	1430 Victoria Avenue East		Brandon, MB  R7A 2A9	2011-01-25 14:07:16.067536	\N	\N	f	Brandon	MB	R7A2A9	\N	\N
64	MDPRO	MDPRO	1	roblinli@mts.net	Parkland Regional Library - Roblin	123 lst Ave. N.	Box 1342	Roblin, MB  R0L 1P0	2011-01-25 15:18:33.838446	Roblin	PARKLAND	f	Roblin	MB	R0L1P0	\N	\N
96	MGW	MGW	1	jackie@wmrl.ca	Western Manitoba Regional  Library - Glenboro/South Cypress	105 Broadway St.	Box 429	Glenboro, MB  R0K 0X0	2011-02-01 16:29:58.638328	Glenboro	WESTMAN	f	Glenboro	MB	R0K0X0	\N	\N
33	MGI	MGI	1	bwinner@gillamnet.com	Bette Winner Public Library	235 Mattonnabee Ave.	Box 400	Gillam, MB  R0B 0L0	2011-02-01 16:54:57.526489	Gillam	NORMAN	f	Gillam	MB	R0B0L0	\N	\N
48	MLPJ	MLPJ	1	mlpj@mts.net	Pauline Johnson Library	23 Main Street	Box 698	Lundar, MB  R0C 1Y0	2011-02-03 10:48:25.445635	Lundar	INTERLAKE	f	Lundar	MB	R0C1Y0	\N	\N
129	admin	admin	1	David.A.Christensen@gmail.com	Maplin-3 Administrator				2012-03-02 15:20:08.314775	\N	\N	f	\N	\N	\N	\N	\N
139	Spruce	Spruce	1	headlib@scrlibrary.mb.ca	Spruce Co-operative	 	 	 	2011-11-04 08:55:19.297548	\N	\N	f	\N	\N	\N	\N	\N
97	MNW	MNW	1	neepawa@wmrlibrary.mb.ca	Western Manitoba Regional  Library - Neepawa	280 Davidson St.	Box 759	Neepawa, MB  R0J 1H0	2011-02-03 12:02:04.730694	Neepawa	WESTMAN	f	Neepawa	MB	R0J1H0	\N	\N
106	MWTS	MWTS	0	lisanne.wood@mts.mb.ca	Manitoba Telecom Services Corporate	489 Empress St.	Box 6666	Winnipeg, MB  R3C 3V6	\N	\N	\N	f	Winnipeg	MB	R3C3V6	\N	\N
29	MGE	MGE	1	gimli.library@mts.net	Evergreen Regional Library - Main	65 First Avenue	Box 1140	Gimli, MB  R0C 1B0	2011-02-03 12:56:09.653775	Gimli	INTERLAKE	f	Gimli	MB	R0C1B0	\N	\N
75	MBA	MBA	1	rmargyle@gmail.com	R.M. of Argyle Public Library	627 Elizabeth Ave. E.	Box 10	Baldur, MB  R0K 0B0	2011-02-01 10:00:40.596398	Baldur	WESTMAN	f	Baldur	MB	R0K0B0	\N	\N
37	MSSM	MSSM	1	stmlibrary@jrlibrary.mb.ca	Jolys Regional Library - St. Malo	189 St. Malo Street	Box 593	St.Malo, MB  R0A 1T0	2011-02-02 15:43:01.43152	St. Malo	EASTMAN	f	St.Malo	MB	R0A1T0	\N	\N
88	MESMN	MESMN	1	smrl1nap@yahoo.ca	Southwestern Manitoba Regional Library - Napinka	57 Souris St.	Box 975	Melita, MB  R0M 1L0	2010-09-14 14:14:28.201392	Napinka	WESTMAN	f	Melita	MB	R0M1L0	\N	\N
111	MSSC	MSSC	1	shilocommunitylibrary@yahoo.ca	Shilo Community Library  (765-3000 ext 3664)		Box Box 177	Shilo, MB  R0K 2A0	2011-02-01 15:25:17.713108	\N	\N	f	Shilo	MB	R0K2A0	\N	\N
102	MHP	MHP	1	victlib@goinet.ca	Victoria Municipal Library	102 Stewart Ave	Box 371	Holland, MB  R0G 0X0	2011-01-27 16:50:14.499442	Holland	CENTRAL	f	Holland	MB	R0G0X0	\N	\N
47	MBB	MBB	1	benlib@mts.net	North-West Regional Library - Benito Branch	140 Main Street	Box 220	Benito, MB  R0L 0C0	2011-01-27 14:18:36.739511	Benito	PARKLAND	f	Benito	MB	R0L0C0	\N	\N
15	MSAG	MSAG	1	bibliosteagathe@atrium.ca	Bibliothèque Ritchot - Ste. Agathe	310 Chemin Pembina Trail	Box 40	Sainte-Agathe, MB  ROG 1YO	2011-02-02 19:05:31.804753	Ste. Agathe	EASTMAN	f	Sainte-Agathe	MB	ROG1YO	\N	\N
82	MAOW	MAOW	1	aill@scrlibrary.mb.ca	South Central Regional Library - Altona	113-125 Centre Ave. E. (324-1503)	Box 650	Altona, MB  R0G 0B0	2011-12-12 14:35:21.057783	Altona	CENTRAL	f	Altona	MB	R0G0B0	\N	\N
21	MVE	MVE	1	borderlibraryvirden@rfnow.com	Border Regional Library - Main	312 - 7th  Avenue	Box 970	Virden, MB  R0M 2C0	2012-05-01 08:29:16.411326	Virden	WESTMAN	f	Virden	MB	R0M2C0	\N	\N
110	MBBB	MBBB	1	beacheslibrary@hotmail.com	Bibliotheque Allard - Beaches	40005 Jackfish Lake Rd. N. Walter Whyte School	Box 279	Victoria Beach, MB  R0E 2C0	2011-01-27 16:15:41.161472	Traverse Bay	EASTMAN	f	Victoria Beach	MB	R0E2C0	\N	\N
57	MDPGL	MDPGL	1	gladstne@mts.net	Parkland Regional Library - Gladstone	42 Morris Avenue N.	Box 720	Gladstone, MB  R0J 0T0	2011-02-03 10:06:30.811072	Gladstone	CENTRAL	f	Gladstone	MB	R0J0T0	\N	\N
56	MDPGP	MDPGP	1	gilbert3@mts.net	Parkland Regional Library - Gilbert Plains	113 Main St. N.	Box 303	Gilbert Plains, MB  R0L 0X0	2011-01-29 16:19:27.923943	Gilbert Plains	PARKLAND	f	Gilbert Plains	MB	R0L0X0	\N	\N
59	MDPHA	MDPHA	1	hamlib@mymts.net	Parkland Regional Library - Hamiota	43 Maple Ave. E.	Box 609	Hamiota, MB  R0M 0T0	2011-02-01 16:33:06.705467	Hamiota	WESTMAN	f	Hamiota	MB	R0M0T0	\N	\N
119	MTPL	MTPL	1	btl@srsd.ca	Bibliothque Publique Tache Public Library - Main		Box 16	Lorette, MB  R0A 0Y0	2011-02-02 16:00:40.614521	Lorette	EASTMAN	f	Lorette	MB	R0A0Y0	\N	\N
113	MWSC	MWSC	1	library@smd.mb.ca	Society for Manitobans with Disabilities - Stephen Sparling	825 Sherbrooks Street		Winnipeg, MB  R3A 1M5	\N	\N	\N	f	Winnipeg	MB	R3A1M5	\N	\N
115	OKE	OKE	0	eroussin@kenora.ca	Kenora Public Library	24 Main St. South		Kenora, Ontario, MB  P9N 1S7	\N	\N	\N	f	Kenora, Ontario	MB	P9N1S7	\N	\N
32	MFF	MFF	1	ffplill@mts.net	Flin Flon Public Library	58 Main Street		Flin Flon, MB  R8A 1J8	2011-12-12 12:56:51.457245	Flin Flon	NORMAN	f	Flin Flon	MB	R8A1J8	\N	\N
24	MCB	MCB	1	illbrl@hotmail.com	Boyne Regional Library	15 - 1st Avenue SW	Box 788	Carman, MB  R0G 0J0	2011-12-12 13:10:44.162827	Carman	CENTRAL	f	Carman	MB	R0G0J0	\N	\N
94	MBW	MBW	1	bdnill@wmrlibrary.mb.ca	Western Manitoba Regional Library - Brandon	710 Rosser Avenue, Unit 1		Brandon, MB  R7A 0K9	2011-12-12 14:08:45.397178	Brandon	WESTMAN	f	Brandon	MB	R7A0K9	\N	\N
135	MMIOW	MMIOW	1	thlib@scrlibrary.mb.ca	South Central Regional Library - Miami	423 Norton Avenue	(Box 431)	Miami, MB  R0G 1H0	2011-12-12 15:28:31.991569	Miami	CENTRAL	f	Miami	MB	R0G1H0	\N	\N
39	MKL	MKL	1	lrl@mts.net	Lakeland Regional Library - Main	318 Williams Ave.	Box 970	Killarney, MB  R0K 1G0	2011-12-12 16:03:53.003063	Killarney	WESTMAN	f	Killarney	MB	R0K1G0	\N	\N
44	MMA	MMA	1	manitoulibrary@mts.net	Manitou Regional Library	418 Main St.	Box 432	Manitou, MB  R0G 1G0	2011-12-30 08:55:30.596456	Manitou	CENTRAL	f	Manitou	MB	R0G1G0	\N	\N
116	CPL	CPL	0		Crocus Plains Regional Secondary School	1930 First Street		Brandon, MB  R7A 6Y6	\N	\N	\N	f	Brandon	MB	R7A6Y6	\N	\N
118	MWJ	MWJ	0	jodi.turner@justice.gc.ca	Department of Justice	301-310 Broadway Avenue		Winnipeg, MB  R3C 0S6	\N	\N	\N	f	Winnipeg	MB	R3C0S6	\N	\N
30	MAB	MAB	1	arborglibrary@mts.net	Evergreen Regional Library - Arborg	292 Main Street	Box 4053	Arborg, MB  R0C 0A0	2012-03-29 09:55:06.585298	Arborg	INTERLAKE	f	Arborg	MB	R0C0A0	\N	\N
36	MSTP	MSTP	1	stplibrary@jrlibrary.mb.ca	Jolys Regional Library - Main	505 Hebert Ave. N.	Box 118	St. Pierre-Jolys, MB  R0A 1V0	2011-02-03 09:05:21.66346	St. Pierre	EASTMAN	f	St. Pierre-Jolys	MB	R0A1V0	\N	\N
99	MW	MW	1	wpl-illo@winnipeg.ca	Winnipeg Public Library : Interlibrary Loans	251 Donald St.		Winnipeg, MB  R3C 3P5	2011-12-12 11:31:38.138719	Winnipeg	WINNIPEG	f	Winnipeg	MB	R3C3P5	\N	\N
92	MTH	MTH	1	interlibraryloans@thompsonlibrary.com	Thompson Public Library	81 Thompson Drive North		Thompson, MB  R8N 0C3	2012-01-19 15:13:17.695393	Thompson	NORMAN	f	Thompson	MB	R8N0C3	\N	\N
20	MBOM	MBOM	1	mbomill@mts.net	Boissevain and Morton Regional Library	436 South Railway St.	Box 340	Boissevain, MB  R0K 0E0	2012-05-03 08:47:47.533285	Boissevain	WESTMAN	f	Boissevain	MB	R0K0E0	\N	\N
101	MWPL	MWPL	1	pls@gov.mb.ca	Public Library Services Branch	300 - 1011 Rosser Avenue		Brandon, MB  R7A 0L5	2012-04-20 15:26:39.119386	\N	\N	t	Brandon	MB	R7A0L5	\N	\N
83	MMOW	MMOW	1	mill@scrlibrary.mb.ca	South Central Regional Library - Morden	514 Stephen Street	Morden, MB  R6M 1T7	204-822-4092	2012-07-13 15:48:05.852295	Morden	CENTRAL	f	\N	\N	\N	\N	\N
69	MPLP	MPLP	1	portlib@portagelibrary.com	Portage La Prairie Regional Library	40-B Royal Road N		Portage La Prairie, MB  R1N 1V1	2012-04-27 14:28:45.534335	Portage la Prairie	CENTRAL	f	Portage La Prairie	MB	R1N1V1	\N	\N
90	MSTE	MSTE	1	steinlib@rocketmail.com	Jake Epp Library	255 Elmdale Street		Steinbach, MB  R5G 0C9	2012-07-13 15:48:20.266993	Steinbach	EASTMAN	f	Steinbach	MB	R5G0C9	\N	\N
85	MSTOS	MSTOS	1	circ@sirlibrary.com	South Interlake Regional Library - Main	419 Main St.		Stonewall, MB  R0C 2Z0	2012-07-13 14:33:15.957439	Stonewall	INTERLAKE	f	Stonewall	MB	R0C2Z0	\N	\N
114	MWEMM	MWEMM	0	LJanower@gov.mb.ca	Manitoba Industry Trade and Mines - Mineral Resource	Suite 360 - 1395 Ellice Ave.		Winnipeg, MB  R3G 3P2	\N	\N	\N	f	Winnipeg	MB	R3G3P2	\N	\N
117	MWHBCA	MWHBCA	0	hbca@gov.mb.ca	Hudsons Bay Company Archives	200 Vaughan St.		Winnipeg, MB  R3C 1T5	\N	\N	\N	f	Winnipeg	MB	R3C1T5	\N	\N
87	MESM	MESM	1	swmblib@mts.net	Southwestern Manitoba Regional Library - Main	149 Main St. S.	Box 639	Melita, MB  R0M 1L0	2011-12-08 14:27:16.546842	Melita	WESTMAN	f	Melita	MB	R0M1L0	\N	\N
46	MSRN	MSRN	1	nwrl@mymts.net	North-West Regional Library - Main	610-1st  St. North	Box 999	Swan River, MB  R0L 1Z0	2012-04-27 11:46:09.958516	Swan River	PARKLAND	f	Swan River	MB	R0L1Z0	\N	\N
\.


--
-- TOC entry 1898 (class 0 OID 17438)
-- Dependencies: 142
-- Data for Name: library_barcodes; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY library_barcodes (lid, borrower, barcode) FROM stdin;
28	73	26240017201073
28	19	26240017301019
28	18	26240017401018
28	14	26240017501014
28	15	26240017601015
28	16	26240017701016
28	79	26240017801079
28	11	26240017901011
28	80	26240018001080
28	34	26240018101034
28	46	26240018201046
28	37	26240018301037
28	90	26240018401090
28	10	26240018501010
28	85	26240018601085
28	36	26240018701036
28	78	26240018801078
28	92	26240018901092
28	91	26240019001091
28	119	26240019101119
28	86	26240019201086
28	136	26240019301136
28	21	26240019401021
28	84	26240019501084
28	121	26240019601121
95	30	2626200101030
95	82	2626200201082
95	75	2626200301075
95	47	2626200401047
95	110	2626200501110
95	26	2626200601026
95	77	2626200701077
95	20	2626200801020
95	94	2626200901094
95	24	2626201001024
95	40	2626201101040
95	28	2626201201028
95	95	2626201301095
95	53	2626201401053
95	25	2626201501025
95	49	2626201601049
95	51	2626201701051
95	52	2626201801052
95	50	2626201901050
95	54	2626202001054
95	55	2626202101055
95	57	2626202201057
95	56	2626202301056
95	58	2626202401058
95	59	2626202501059
95	60	2626202601060
95	61	2626202701061
95	62	2626202801062
95	63	2626202901063
95	64	2626203001064
95	66	2626203101066
95	65	2626203201065
95	107	2626203301107
95	67	2626203401067
95	134	2626203501134
95	22	2626203601022
95	27	2626203701027
95	103	2626203801103
95	87	2626203901087
95	88	2626204001088
95	89	2626204101089
95	32	2626204201032
95	29	2626204301029
95	33	2626204401033
95	96	2626204501096
95	35	2626204601035
95	102	2626204701102
95	120	2626204801120
95	13	2626204901013
95	39	2626205001039
95	17	2626205101017
95	38	2626205201038
95	43	2626205301043
95	48	2626205401048
95	42	2626205501042
95	44	2626205601044
95	23	2626205701023
95	135	2626205801135
95	45	2626205901045
95	83	2626206001083
95	98	2626206101098
95	93	2626206201093
95	12	2626206301012
95	97	2626206401097
95	68	2626206501068
95	122	2626206601122
95	69	2626206701069
95	41	2626206801041
95	72	2626206901072
95	31	2626207001031
95	76	2626207101076
95	71	2626207201071
95	74	2626207301074
95	73	2626207401073
95	19	2626207501019
95	18	2626207601018
95	14	2626207701014
95	15	2626207801015
95	16	2626207901016
95	79	2626208001079
95	11	2626208101011
95	80	2626208201080
95	34	2626208301034
95	46	2626208401046
95	37	2626208501037
95	90	2626208601090
95	10	2626208701010
95	85	2626208801085
95	36	2626208901036
95	78	2626209001078
95	92	2626209101092
95	91	2626209201091
95	119	2626209301119
95	86	2626209401086
95	136	2626209501136
95	21	2626209601021
95	84	2626209701084
95	121	2626209801121
53	30	2632000101030
53	82	2632000201082
53	75	2632000301075
53	47	2632000401047
53	110	2632000501110
53	26	2632000601026
53	77	2632000701077
53	20	2632000801020
53	94	2632000901094
53	24	2632001001024
53	40	2632001101040
53	28	2632001201028
53	95	2632001301095
53	53	2632001401053
53	25	2632001501025
53	49	2632001601049
53	51	2632001701051
53	52	2632001801052
53	50	2632001901050
53	54	2632002001054
53	55	2632002101055
53	57	2632002201057
53	56	2632002301056
53	58	2632002401058
53	59	2632002501059
53	60	2632002601060
53	61	2632002701061
53	62	2632002801062
53	63	2632002901063
53	64	2632003001064
53	66	2632003101066
53	65	2632003201065
53	107	2632003301107
53	67	2632003401067
53	134	2632003501134
53	22	2632003601022
53	27	2632003701027
53	103	2632003801103
53	87	2632003901087
53	88	2632004001088
53	89	2632004101089
53	32	2632004201032
53	29	2632004301029
53	33	2632004401033
53	96	2632004501096
53	35	2632004601035
53	102	2632004701102
53	120	2632004801120
53	13	2632004901013
53	39	2632005001039
53	17	2632005101017
53	38	2632005201038
53	43	2632005301043
53	48	2632005401048
53	42	2632005501042
53	44	2632005601044
53	23	2632005701023
53	135	2632005801135
53	45	2632005901045
53	83	2632006001083
53	98	2632006101098
53	93	2632006201093
53	12	2632006301012
53	97	2632006401097
53	68	2632006501068
53	122	2632006601122
53	69	2632006701069
53	41	2632006801041
53	72	2632006901072
53	31	2632007001031
53	76	2632007101076
53	71	2632007201071
53	74	2632007301074
53	73	2632007401073
53	19	2632007501019
53	18	2632007601018
53	14	2632007701014
53	15	2632007801015
53	16	2632007901016
53	79	2632008001079
53	11	2632008101011
53	80	2632008201080
53	34	2632008301034
53	46	2632008401046
53	37	2632008501037
53	90	2632008601090
53	10	2632008701010
53	85	2632008801085
53	36	2632008901036
53	78	2632009001078
53	92	2632009101092
53	91	2632009201091
53	119	2632009301119
53	86	2632009401086
53	136	2632009501136
53	21	2632009601021
53	84	2632009701084
53	121	2632009801121
25	30	2632009901030
25	82	26320010001082
25	75	26320010101075
25	47	26320010201047
25	110	26320010301110
25	26	26320010401026
25	77	26320010501077
25	20	26320010601020
25	94	26320010701094
25	24	26320010801024
25	40	26320010901040
25	28	26320011001028
25	95	26320011101095
25	53	26320011201053
25	25	26320011301025
25	49	26320011401049
25	51	26320011501051
25	52	26320011601052
25	50	26320011701050
25	54	26320011801054
25	55	26320011901055
25	57	26320012001057
25	56	26320012101056
25	58	26320012201058
25	59	26320012301059
25	60	26320012401060
25	61	26320012501061
25	62	26320012601062
25	63	26320012701063
25	64	26320012801064
25	66	26320012901066
25	65	26320013001065
25	107	26320013101107
25	67	26320013201067
25	134	26320013301134
25	22	26320013401022
25	27	26320013501027
25	103	26320013601103
25	87	26320013701087
25	88	26320013801088
25	89	26320013901089
25	32	26320014001032
25	29	26320014101029
25	33	26320014201033
25	96	26320014301096
25	35	26320014401035
25	102	26320014501102
25	120	26320014601120
25	13	26320014701013
25	39	26320014801039
25	17	26320014901017
25	38	26320015001038
25	43	26320015101043
25	48	26320015201048
25	42	26320015301042
25	44	26320015401044
25	23	26320015501023
25	135	26320015601135
25	45	26320015701045
25	83	26320015801083
25	98	26320015901098
25	93	26320016001093
25	12	26320016101012
25	97	26320016201097
25	68	26320016301068
25	122	26320016401122
25	69	26320016501069
25	41	26320016601041
25	72	26320016701072
25	31	26320016801031
25	76	26320016901076
25	71	26320017001071
25	74	26320017101074
25	73	26320017201073
25	19	26320017301019
25	18	26320017401018
25	14	26320017501014
25	15	26320017601015
25	16	26320017701016
25	79	26320017801079
25	11	26320017901011
25	80	26320018001080
25	34	26320018101034
25	46	26320018201046
25	37	26320018301037
25	90	26320018401090
25	10	26320018501010
25	85	26320018601085
25	36	26320018701036
25	78	26320018801078
25	92	26320018901092
25	91	26320019001091
25	119	26320019101119
25	86	26320019201086
25	136	26320019301136
25	21	26320019401021
25	84	26320019501084
25	121	26320019601121
49	30	2627000101030
49	82	2627000201082
49	75	2627000301075
49	47	2627000401047
49	110	2627000501110
49	26	2627000601026
49	77	2627000701077
49	20	2627000801020
49	94	2627000901094
49	24	2627001001024
49	40	2627001101040
49	28	2627001201028
49	95	2627001301095
49	53	2627001401053
49	25	2627001501025
49	49	2627001601049
49	51	2627001701051
49	52	2627001801052
49	50	2627001901050
49	54	2627002001054
49	55	2627002101055
49	57	2627002201057
49	56	2627002301056
49	58	2627002401058
49	59	2627002501059
49	60	2627002601060
49	61	2627002701061
49	62	2627002801062
49	63	2627002901063
49	64	2627003001064
49	66	2627003101066
49	65	2627003201065
49	107	2627003301107
49	67	2627003401067
49	134	2627003501134
49	22	2627003601022
49	27	2627003701027
49	103	2627003801103
49	87	2627003901087
49	88	2627004001088
49	89	2627004101089
49	32	2627004201032
49	29	2627004301029
49	33	2627004401033
49	96	2627004501096
49	35	2627004601035
49	102	2627004701102
49	120	2627004801120
49	13	2627004901013
49	39	2627005001039
49	17	2627005101017
49	38	2627005201038
49	43	2627005301043
49	48	2627005401048
49	42	2627005501042
49	44	2627005601044
49	23	2627005701023
49	135	2627005801135
49	45	2627005901045
49	83	2627006001083
49	98	2627006101098
49	93	2627006201093
49	12	2627006301012
49	97	2627006401097
49	68	2627006501068
49	122	2627006601122
49	69	2627006701069
49	41	2627006801041
49	72	2627006901072
49	31	2627007001031
49	76	2627007101076
49	71	2627007201071
49	74	2627007301074
49	73	2627007401073
49	19	2627007501019
49	18	2627007601018
49	14	2627007701014
49	15	2627007801015
49	16	2627007901016
49	79	2627008001079
49	11	2627008101011
49	80	2627008201080
49	34	2627008301034
49	46	2627008401046
49	37	2627008501037
49	90	2627008601090
49	10	2627008701010
49	85	2627008801085
49	36	2627008901036
49	78	2627009001078
49	92	2627009101092
49	91	2627009201091
49	119	2627009301119
49	86	2627009401086
49	136	2627009501136
49	21	2627009601021
49	84	2627009701084
49	121	2627009801121
51	30	2627240101030
51	82	2627240201082
51	75	2627240301075
51	47	2627240401047
51	110	2627240501110
51	26	2627240601026
51	77	2627240701077
51	20	2627240801020
51	94	2627240901094
51	24	2627241001024
51	40	2627241101040
51	28	2627241201028
51	95	2627241301095
51	53	2627241401053
51	25	2627241501025
51	49	2627241601049
51	51	2627241701051
51	52	2627241801052
51	50	2627241901050
51	54	2627242001054
51	55	2627242101055
51	57	2627242201057
51	56	2627242301056
51	58	2627242401058
51	59	2627242501059
51	60	2627242601060
51	61	2627242701061
51	62	2627242801062
51	63	2627242901063
51	64	2627243001064
51	66	2627243101066
51	65	2627243201065
51	107	2627243301107
51	67	2627243401067
51	134	2627243501134
51	22	2627243601022
51	27	2627243701027
51	103	2627243801103
51	87	2627243901087
51	88	2627244001088
51	89	2627244101089
51	32	2627244201032
51	29	2627244301029
51	33	2627244401033
51	96	2627244501096
51	35	2627244601035
51	102	2627244701102
51	120	2627244801120
51	13	2627244901013
51	39	2627245001039
51	17	2627245101017
51	38	2627245201038
51	43	2627245301043
51	48	2627245401048
51	42	2627245501042
51	44	2627245601044
51	23	2627245701023
51	135	2627245801135
51	45	2627245901045
51	83	2627246001083
51	98	2627246101098
51	93	2627246201093
51	12	2627246301012
51	97	2627246401097
51	68	2627246501068
51	122	2627246601122
51	69	2627246701069
51	41	2627246801041
51	72	2627246901072
51	31	2627247001031
51	76	2627247101076
51	71	2627247201071
51	74	2627247301074
51	73	2627247401073
51	19	2627247501019
51	18	2627247601018
51	14	2627247701014
51	15	2627247801015
51	16	2627247901016
51	79	2627248001079
51	11	2627248101011
51	80	2627248201080
51	34	2627248301034
51	46	2627248401046
51	37	2627248501037
51	90	2627248601090
51	10	2627248701010
51	85	2627248801085
51	36	2627248901036
51	78	2627249001078
51	92	2627249101092
51	91	2627249201091
51	119	2627249301119
51	86	2627249401086
51	136	2627249501136
51	21	2627249601021
51	84	2627249701084
51	121	2627249801121
52	30	2627260101030
52	82	2627260201082
52	75	2627260301075
52	47	2627260401047
52	110	2627260501110
52	26	2627260601026
52	77	2627260701077
52	20	2627260801020
52	94	2627260901094
52	24	2627261001024
52	40	2627261101040
52	28	2627261201028
52	95	2627261301095
52	53	2627261401053
52	25	2627261501025
52	49	2627261601049
52	51	2627261701051
52	52	2627261801052
52	50	2627261901050
52	54	2627262001054
52	55	2627262101055
52	57	2627262201057
52	56	2627262301056
52	58	2627262401058
52	59	2627262501059
52	60	2627262601060
52	61	2627262701061
52	62	2627262801062
52	63	2627262901063
52	64	2627263001064
52	66	2627263101066
52	65	2627263201065
52	107	2627263301107
52	67	2627263401067
52	134	2627263501134
52	22	2627263601022
52	27	2627263701027
52	103	2627263801103
52	87	2627263901087
52	88	2627264001088
52	89	2627264101089
52	32	2627264201032
52	29	2627264301029
52	33	2627264401033
52	96	2627264501096
52	35	2627264601035
52	102	2627264701102
52	120	2627264801120
52	13	2627264901013
52	39	2627265001039
52	17	2627265101017
52	38	2627265201038
52	43	2627265301043
52	48	2627265401048
52	42	2627265501042
52	44	2627265601044
52	23	2627265701023
52	135	2627265801135
52	45	2627265901045
52	83	2627266001083
52	98	2627266101098
52	93	2627266201093
52	12	2627266301012
52	97	2627266401097
52	68	2627266501068
52	122	2627266601122
52	69	2627266701069
52	41	2627266801041
52	72	2627266901072
52	31	2627267001031
52	76	2627267101076
52	71	2627267201071
52	74	2627267301074
52	73	2627267401073
52	19	2627267501019
52	18	2627267601018
52	14	2627267701014
52	15	2627267801015
52	16	2627267901016
52	79	2627268001079
52	11	2627268101011
52	80	2627268201080
52	34	2627268301034
52	46	2627268401046
52	37	2627268501037
52	90	2627268601090
52	10	2627268701010
52	85	2627268801085
52	36	2627268901036
52	78	2627269001078
52	92	2627269101092
52	91	2627269201091
52	119	2627269301119
52	86	2627269401086
52	136	2627269501136
52	21	2627269601021
52	84	2627269701084
52	121	2627269801121
50	30	2627270101030
50	82	2627270201082
50	75	2627270301075
50	47	2627270401047
50	110	2627270501110
50	26	2627270601026
50	77	2627270701077
50	20	2627270801020
50	94	2627270901094
50	24	2627271001024
50	40	2627271101040
50	28	2627271201028
50	95	2627271301095
50	53	2627271401053
50	25	2627271501025
50	49	2627271601049
50	51	2627271701051
50	52	2627271801052
50	50	2627271901050
50	54	2627272001054
50	55	2627272101055
50	57	2627272201057
50	56	2627272301056
50	58	2627272401058
50	59	2627272501059
50	60	2627272601060
50	61	2627272701061
50	62	2627272801062
50	63	2627272901063
50	64	2627273001064
50	66	2627273101066
50	65	2627273201065
50	107	2627273301107
50	67	2627273401067
50	134	2627273501134
50	22	2627273601022
50	27	2627273701027
50	103	2627273801103
50	87	2627273901087
50	88	2627274001088
50	89	2627274101089
50	32	2627274201032
50	29	2627274301029
50	33	2627274401033
50	96	2627274501096
50	35	2627274601035
50	102	2627274701102
50	120	2627274801120
50	13	2627274901013
50	39	2627275001039
50	17	2627275101017
50	38	2627275201038
50	43	2627275301043
50	48	2627275401048
50	42	2627275501042
50	44	2627275601044
50	23	2627275701023
50	135	2627275801135
50	45	2627275901045
50	83	2627276001083
50	98	2627276101098
50	93	2627276201093
50	12	2627276301012
50	97	2627276401097
50	68	2627276501068
50	122	2627276601122
50	69	2627276701069
50	41	2627276801041
50	72	2627276901072
50	31	2627277001031
50	76	2627277101076
50	71	2627277201071
50	74	2627277301074
50	73	2627277401073
50	19	2627277501019
50	18	2627277601018
50	14	2627277701014
50	15	2627277801015
50	16	2627277901016
50	79	2627278001079
50	11	2627278101011
50	80	2627278201080
50	34	2627278301034
50	46	2627278401046
50	37	2627278501037
50	90	2627278601090
50	10	2627278701010
50	85	2627278801085
50	36	2627278901036
50	78	2627279001078
50	92	2627279101092
50	91	2627279201091
50	119	2627279301119
50	86	2627279401086
50	136	2627279501136
50	21	2627279601021
50	84	2627279701084
50	121	2627279801121
54	30	2627370101030
54	82	2627370201082
54	75	2627370301075
54	47	2627370401047
54	110	2627370501110
54	26	2627370601026
54	77	2627370701077
54	20	2627370801020
54	94	2627370901094
54	24	2627371001024
54	40	2627371101040
54	28	2627371201028
54	95	2627371301095
54	53	2627371401053
54	25	2627371501025
54	49	2627371601049
54	51	2627371701051
54	52	2627371801052
54	50	2627371901050
54	54	2627372001054
54	55	2627372101055
54	57	2627372201057
54	56	2627372301056
54	58	2627372401058
54	59	2627372501059
54	60	2627372601060
54	61	2627372701061
54	62	2627372801062
54	63	2627372901063
54	64	2627373001064
54	66	2627373101066
54	65	2627373201065
54	107	2627373301107
54	67	2627373401067
54	134	2627373501134
54	22	2627373601022
54	27	2627373701027
54	103	2627373801103
54	87	2627373901087
54	88	2627374001088
54	89	2627374101089
54	32	2627374201032
54	29	2627374301029
54	33	2627374401033
54	96	2627374501096
54	35	2627374601035
54	102	2627374701102
54	120	2627374801120
54	13	2627374901013
54	39	2627375001039
54	17	2627375101017
54	38	2627375201038
54	43	2627375301043
54	48	2627375401048
54	42	2627375501042
54	44	2627375601044
54	23	2627375701023
54	135	2627375801135
54	45	2627375901045
54	83	2627376001083
54	98	2627376101098
54	93	2627376201093
54	12	2627376301012
54	97	2627376401097
54	68	2627376501068
54	122	2627376601122
54	69	2627376701069
54	41	2627376801041
54	72	2627376901072
54	31	2627377001031
54	76	2627377101076
54	71	2627377201071
54	74	2627377301074
54	73	2627377401073
54	19	2627377501019
54	18	2627377601018
54	14	2627377701014
54	15	2627377801015
54	16	2627377901016
54	79	2627378001079
54	11	2627378101011
54	80	2627378201080
54	34	2627378301034
54	46	2627378401046
54	37	2627378501037
54	90	2627378601090
54	10	2627378701010
54	85	2627378801085
54	36	2627378901036
54	78	2627379001078
54	92	2627379101092
54	91	2627379201091
54	119	2627379301119
54	86	2627379401086
54	136	2627379501136
54	21	2627379601021
54	84	2627379701084
54	121	2627379801121
55	30	2627360101030
55	82	2627360201082
55	75	2627360301075
55	47	2627360401047
55	110	2627360501110
55	26	2627360601026
55	77	2627360701077
55	20	2627360801020
55	94	2627360901094
55	24	2627361001024
55	40	2627361101040
55	28	2627361201028
55	95	2627361301095
55	53	2627361401053
55	25	2627361501025
55	49	2627361601049
55	51	2627361701051
55	52	2627361801052
55	50	2627361901050
55	54	2627362001054
55	55	2627362101055
55	57	2627362201057
55	56	2627362301056
55	58	2627362401058
55	59	2627362501059
55	60	2627362601060
55	61	2627362701061
55	62	2627362801062
55	63	2627362901063
55	64	2627363001064
55	66	2627363101066
55	65	2627363201065
55	107	2627363301107
55	67	2627363401067
55	134	2627363501134
55	22	2627363601022
55	27	2627363701027
55	103	2627363801103
55	87	2627363901087
55	88	2627364001088
55	89	2627364101089
55	32	2627364201032
55	29	2627364301029
55	33	2627364401033
55	96	2627364501096
55	35	2627364601035
55	102	2627364701102
55	120	2627364801120
55	13	2627364901013
55	39	2627365001039
55	17	2627365101017
55	38	2627365201038
55	43	2627365301043
55	48	2627365401048
55	42	2627365501042
55	44	2627365601044
55	23	2627365701023
55	135	2627365801135
55	45	2627365901045
55	83	2627366001083
55	98	2627366101098
55	93	2627366201093
55	12	2627366301012
55	97	2627366401097
55	68	2627366501068
55	122	2627366601122
55	69	2627366701069
55	41	2627366801041
55	72	2627366901072
55	31	2627367001031
55	76	2627367101076
55	71	2627367201071
55	74	2627367301074
55	73	2627367401073
55	19	2627367501019
55	18	2627367601018
55	14	2627367701014
55	15	2627367801015
55	16	2627367901016
55	79	2627368001079
55	11	2627368101011
55	80	2627368201080
55	34	2627368301034
55	46	2627368401046
55	37	2627368501037
55	90	2627368601090
55	10	2627368701010
55	85	2627368801085
55	36	2627368901036
55	78	2627369001078
55	92	2627369101092
55	91	2627369201091
55	119	2627369301119
55	86	2627369401086
55	136	2627369501136
55	21	2627369601021
55	84	2627369701084
55	121	2627369801121
57	30	2627450101030
57	82	2627450201082
57	75	2627450301075
57	47	2627450401047
57	110	2627450501110
57	26	2627450601026
57	77	2627450701077
57	20	2627450801020
57	94	2627450901094
57	24	2627451001024
57	40	2627451101040
57	28	2627451201028
57	95	2627451301095
57	53	2627451401053
57	25	2627451501025
57	49	2627451601049
57	51	2627451701051
57	52	2627451801052
57	50	2627451901050
57	54	2627452001054
57	55	2627452101055
57	57	2627452201057
57	56	2627452301056
57	58	2627452401058
57	59	2627452501059
57	60	2627452601060
57	61	2627452701061
57	62	2627452801062
57	63	2627452901063
57	64	2627453001064
57	66	2627453101066
57	65	2627453201065
57	107	2627453301107
57	67	2627453401067
57	134	2627453501134
57	22	2627453601022
57	27	2627453701027
57	103	2627453801103
57	87	2627453901087
57	88	2627454001088
57	89	2627454101089
57	32	2627454201032
57	29	2627454301029
57	33	2627454401033
57	96	2627454501096
57	35	2627454601035
57	102	2627454701102
57	120	2627454801120
57	13	2627454901013
57	39	2627455001039
57	17	2627455101017
57	38	2627455201038
57	43	2627455301043
57	48	2627455401048
57	42	2627455501042
57	44	2627455601044
57	23	2627455701023
57	135	2627455801135
57	45	2627455901045
57	83	2627456001083
57	98	2627456101098
57	93	2627456201093
57	12	2627456301012
57	97	2627456401097
57	68	2627456501068
57	122	2627456601122
57	69	2627456701069
57	41	2627456801041
57	72	2627456901072
57	31	2627457001031
57	76	2627457101076
57	71	2627457201071
57	74	2627457301074
57	73	2627457401073
57	19	2627457501019
57	18	2627457601018
57	14	2627457701014
57	15	2627457801015
57	16	2627457901016
57	79	2627458001079
57	11	2627458101011
57	80	2627458201080
57	34	2627458301034
57	46	2627458401046
57	37	2627458501037
57	90	2627458601090
57	10	2627458701010
57	85	2627458801085
57	36	2627458901036
57	78	2627459001078
57	92	2627459101092
57	91	2627459201091
57	119	2627459301119
57	86	2627459401086
57	136	2627459501136
57	21	2627459601021
57	84	2627459701084
57	121	2627459801121
56	30	2627470101030
56	82	2627470201082
56	75	2627470301075
56	47	2627470401047
56	110	2627470501110
56	26	2627470601026
56	77	2627470701077
56	20	2627470801020
56	94	2627470901094
56	24	2627471001024
56	40	2627471101040
56	28	2627471201028
56	95	2627471301095
56	53	2627471401053
56	25	2627471501025
56	49	2627471601049
56	51	2627471701051
56	52	2627471801052
56	50	2627471901050
56	54	2627472001054
56	55	2627472101055
56	57	2627472201057
56	56	2627472301056
56	58	2627472401058
56	59	2627472501059
56	60	2627472601060
56	61	2627472701061
56	62	2627472801062
56	63	2627472901063
56	64	2627473001064
56	66	2627473101066
56	65	2627473201065
56	107	2627473301107
56	67	2627473401067
56	134	2627473501134
56	22	2627473601022
56	27	2627473701027
56	103	2627473801103
56	87	2627473901087
56	88	2627474001088
56	89	2627474101089
56	32	2627474201032
56	29	2627474301029
56	33	2627474401033
56	96	2627474501096
56	35	2627474601035
56	102	2627474701102
56	120	2627474801120
56	13	2627474901013
56	39	2627475001039
56	17	2627475101017
56	38	2627475201038
56	43	2627475301043
56	48	2627475401048
56	42	2627475501042
56	44	2627475601044
56	23	2627475701023
56	135	2627475801135
56	45	2627475901045
56	83	2627476001083
56	98	2627476101098
56	93	2627476201093
56	12	2627476301012
56	97	2627476401097
56	68	2627476501068
56	122	2627476601122
56	69	2627476701069
56	41	2627476801041
56	72	2627476901072
56	31	2627477001031
56	76	2627477101076
56	71	2627477201071
56	74	2627477301074
56	73	2627477401073
56	19	2627477501019
56	18	2627477601018
56	14	2627477701014
56	15	2627477801015
56	16	2627477901016
56	79	2627478001079
56	11	2627478101011
56	80	2627478201080
56	34	2627478301034
56	46	2627478401046
56	37	2627478501037
56	90	2627478601090
56	10	2627478701010
56	85	2627478801085
56	36	2627478901036
56	78	2627479001078
56	92	2627479101092
56	91	2627479201091
56	119	2627479301119
56	86	2627479401086
56	136	2627479501136
56	21	2627479601021
56	84	2627479701084
56	121	2627479801121
58	30	2627480101030
58	82	2627480201082
58	75	2627480301075
58	47	2627480401047
58	110	2627480501110
58	26	2627480601026
58	77	2627480701077
58	20	2627480801020
58	94	2627480901094
58	24	2627481001024
58	40	2627481101040
58	28	2627481201028
58	95	2627481301095
58	53	2627481401053
58	25	2627481501025
58	49	2627481601049
58	51	2627481701051
58	52	2627481801052
58	50	2627481901050
58	54	2627482001054
58	55	2627482101055
58	57	2627482201057
58	56	2627482301056
58	58	2627482401058
58	59	2627482501059
58	60	2627482601060
58	61	2627482701061
58	62	2627482801062
58	63	2627482901063
58	64	2627483001064
58	66	2627483101066
58	65	2627483201065
58	107	2627483301107
58	67	2627483401067
58	134	2627483501134
58	22	2627483601022
58	27	2627483701027
58	103	2627483801103
58	87	2627483901087
58	88	2627484001088
58	89	2627484101089
58	32	2627484201032
58	29	2627484301029
58	33	2627484401033
58	96	2627484501096
58	35	2627484601035
58	102	2627484701102
58	120	2627484801120
58	13	2627484901013
58	39	2627485001039
58	17	2627485101017
58	38	2627485201038
58	43	2627485301043
58	48	2627485401048
58	42	2627485501042
58	44	2627485601044
58	23	2627485701023
58	135	2627485801135
58	45	2627485901045
58	83	2627486001083
58	98	2627486101098
58	93	2627486201093
58	12	2627486301012
58	97	2627486401097
58	68	2627486501068
58	122	2627486601122
58	69	2627486701069
58	41	2627486801041
58	72	2627486901072
58	31	2627487001031
58	76	2627487101076
58	71	2627487201071
58	74	2627487301074
58	73	2627487401073
58	19	2627487501019
58	18	2627487601018
58	14	2627487701014
58	15	2627487801015
58	16	2627487901016
58	79	2627488001079
58	11	2627488101011
58	80	2627488201080
58	34	2627488301034
58	46	2627488401046
58	37	2627488501037
58	90	2627488601090
58	10	2627488701010
58	85	2627488801085
58	36	2627488901036
58	78	2627489001078
58	92	2627489101092
58	91	2627489201091
58	119	2627489301119
58	86	2627489401086
58	136	2627489501136
58	21	2627489601021
58	84	2627489701084
58	121	2627489801121
59	30	2627420101030
59	82	2627420201082
59	75	2627420301075
59	47	2627420401047
59	110	2627420501110
59	26	2627420601026
59	77	2627420701077
59	20	2627420801020
59	94	2627420901094
59	24	2627421001024
59	40	2627421101040
59	28	2627421201028
59	95	2627421301095
59	53	2627421401053
59	25	2627421501025
59	49	2627421601049
59	51	2627421701051
59	52	2627421801052
59	50	2627421901050
59	54	2627422001054
59	55	2627422101055
59	57	2627422201057
59	56	2627422301056
59	58	2627422401058
59	59	2627422501059
59	60	2627422601060
59	61	2627422701061
59	62	2627422801062
59	63	2627422901063
59	64	2627423001064
59	66	2627423101066
59	65	2627423201065
59	107	2627423301107
59	67	2627423401067
59	134	2627423501134
59	22	2627423601022
59	27	2627423701027
59	103	2627423801103
59	87	2627423901087
59	88	2627424001088
59	89	2627424101089
59	32	2627424201032
59	29	2627424301029
59	33	2627424401033
59	96	2627424501096
59	35	2627424601035
59	102	2627424701102
59	120	2627424801120
59	13	2627424901013
59	39	2627425001039
59	17	2627425101017
59	38	2627425201038
59	43	2627425301043
59	48	2627425401048
59	42	2627425501042
59	44	2627425601044
59	23	2627425701023
59	135	2627425801135
59	45	2627425901045
59	83	2627426001083
59	98	2627426101098
59	93	2627426201093
59	12	2627426301012
59	97	2627426401097
59	68	2627426501068
59	122	2627426601122
59	69	2627426701069
59	41	2627426801041
59	72	2627426901072
59	31	2627427001031
59	76	2627427101076
59	71	2627427201071
59	74	2627427301074
59	73	2627427401073
59	19	2627427501019
59	18	2627427601018
59	14	2627427701014
59	15	2627427801015
59	16	2627427901016
59	79	2627428001079
59	11	2627428101011
59	80	2627428201080
59	34	2627428301034
59	46	2627428401046
59	37	2627428501037
59	90	2627428601090
59	10	2627428701010
59	85	2627428801085
59	36	2627428901036
59	78	2627429001078
59	92	2627429101092
59	91	2627429201091
59	119	2627429301119
59	86	2627429401086
59	136	2627429501136
59	21	2627429601021
59	84	2627429701084
59	121	2627429801121
60	30	2627520101030
60	82	2627520201082
60	75	2627520301075
60	47	2627520401047
60	110	2627520501110
60	26	2627520601026
60	77	2627520701077
60	20	2627520801020
60	94	2627520901094
60	24	2627521001024
60	40	2627521101040
60	28	2627521201028
60	95	2627521301095
60	53	2627521401053
60	25	2627521501025
60	49	2627521601049
60	51	2627521701051
60	52	2627521801052
60	50	2627521901050
60	54	2627522001054
60	55	2627522101055
60	57	2627522201057
60	56	2627522301056
60	58	2627522401058
60	59	2627522501059
60	60	2627522601060
60	61	2627522701061
60	62	2627522801062
60	63	2627522901063
60	64	2627523001064
60	66	2627523101066
60	65	2627523201065
60	107	2627523301107
60	67	2627523401067
60	134	2627523501134
60	22	2627523601022
60	27	2627523701027
60	103	2627523801103
60	87	2627523901087
60	88	2627524001088
60	89	2627524101089
60	32	2627524201032
60	29	2627524301029
60	33	2627524401033
60	96	2627524501096
60	35	2627524601035
60	102	2627524701102
60	120	2627524801120
60	13	2627524901013
60	39	2627525001039
60	17	2627525101017
60	38	2627525201038
60	43	2627525301043
60	48	2627525401048
60	42	2627525501042
60	44	2627525601044
60	23	2627525701023
60	135	2627525801135
60	45	2627525901045
60	83	2627526001083
60	98	2627526101098
60	93	2627526201093
60	12	2627526301012
60	97	2627526401097
60	68	2627526501068
60	122	2627526601122
60	69	2627526701069
60	41	2627526801041
60	72	2627526901072
60	31	2627527001031
60	76	2627527101076
60	71	2627527201071
60	74	2627527301074
60	73	2627527401073
60	19	2627527501019
60	18	2627527601018
60	14	2627527701014
60	15	2627527801015
60	16	2627527901016
60	79	2627528001079
60	11	2627528101011
60	80	2627528201080
60	34	2627528301034
60	46	2627528401046
60	37	2627528501037
60	90	2627528601090
60	10	2627528701010
60	85	2627528801085
60	36	2627528901036
60	78	2627529001078
60	92	2627529101092
60	91	2627529201091
60	119	2627529301119
60	86	2627529401086
60	136	2627529501136
60	21	2627529601021
60	84	2627529701084
60	121	2627529801121
61	30	2627620101030
61	82	2627620201082
61	75	2627620301075
61	47	2627620401047
61	110	2627620501110
61	26	2627620601026
61	77	2627620701077
61	20	2627620801020
61	94	2627620901094
61	24	2627621001024
61	40	2627621101040
61	28	2627621201028
61	95	2627621301095
61	53	2627621401053
61	25	2627621501025
61	49	2627621601049
61	51	2627621701051
61	52	2627621801052
61	50	2627621901050
61	54	2627622001054
61	55	2627622101055
61	57	2627622201057
61	56	2627622301056
61	58	2627622401058
61	59	2627622501059
61	60	2627622601060
61	61	2627622701061
61	62	2627622801062
61	63	2627622901063
61	64	2627623001064
61	66	2627623101066
61	65	2627623201065
61	107	2627623301107
61	67	2627623401067
61	134	2627623501134
61	22	2627623601022
61	27	2627623701027
61	103	2627623801103
61	87	2627623901087
61	88	2627624001088
61	89	2627624101089
61	32	2627624201032
61	29	2627624301029
61	33	2627624401033
61	96	2627624501096
61	35	2627624601035
61	102	2627624701102
61	120	2627624801120
61	13	2627624901013
61	39	2627625001039
61	17	2627625101017
61	38	2627625201038
61	43	2627625301043
61	48	2627625401048
61	42	2627625501042
61	44	2627625601044
61	23	2627625701023
61	135	2627625801135
61	45	2627625901045
61	83	2627626001083
61	98	2627626101098
61	93	2627626201093
61	12	2627626301012
61	97	2627626401097
61	68	2627626501068
61	122	2627626601122
61	69	2627626701069
61	41	2627626801041
61	72	2627626901072
61	31	2627627001031
61	76	2627627101076
61	71	2627627201071
61	74	2627627301074
61	73	2627627401073
61	19	2627627501019
61	18	2627627601018
61	14	2627627701014
61	15	2627627801015
61	16	2627627901016
61	79	2627628001079
61	11	2627628101011
61	80	2627628201080
61	34	2627628301034
61	46	2627628401046
61	37	2627628501037
61	90	2627628601090
61	10	2627628701010
61	85	2627628801085
61	36	2627628901036
61	78	2627629001078
61	92	2627629101092
61	91	2627629201091
61	119	2627629301119
61	86	2627629401086
61	136	2627629501136
61	21	2627629601021
61	84	2627629701084
61	121	2627629801121
62	30	2627640101030
62	82	2627640201082
62	75	2627640301075
62	47	2627640401047
62	110	2627640501110
62	26	2627640601026
62	77	2627640701077
62	20	2627640801020
62	94	2627640901094
62	24	2627641001024
62	40	2627641101040
62	28	2627641201028
62	95	2627641301095
62	53	2627641401053
62	25	2627641501025
62	49	2627641601049
62	51	2627641701051
62	52	2627641801052
62	50	2627641901050
62	54	2627642001054
62	55	2627642101055
62	57	2627642201057
62	56	2627642301056
62	58	2627642401058
62	59	2627642501059
62	60	2627642601060
62	61	2627642701061
62	62	2627642801062
62	63	2627642901063
62	64	2627643001064
62	66	2627643101066
62	65	2627643201065
62	107	2627643301107
62	67	2627643401067
62	134	2627643501134
62	22	2627643601022
62	27	2627643701027
62	103	2627643801103
62	87	2627643901087
62	88	2627644001088
62	89	2627644101089
62	32	2627644201032
62	29	2627644301029
62	33	2627644401033
62	96	2627644501096
62	35	2627644601035
62	102	2627644701102
62	120	2627644801120
62	13	2627644901013
62	39	2627645001039
62	17	2627645101017
62	38	2627645201038
62	43	2627645301043
62	48	2627645401048
62	42	2627645501042
62	44	2627645601044
62	23	2627645701023
62	135	2627645801135
62	45	2627645901045
62	83	2627646001083
62	98	2627646101098
62	93	2627646201093
62	12	2627646301012
62	97	2627646401097
62	68	2627646501068
62	122	2627646601122
62	69	2627646701069
62	41	2627646801041
62	72	2627646901072
62	31	2627647001031
62	76	2627647101076
62	71	2627647201071
62	74	2627647301074
62	73	2627647401073
62	19	2627647501019
62	18	2627647601018
62	14	2627647701014
62	15	2627647801015
62	16	2627647901016
62	79	2627648001079
62	11	2627648101011
62	80	2627648201080
62	34	2627648301034
62	46	2627648401046
62	37	2627648501037
62	90	2627648601090
62	10	2627648701010
62	85	2627648801085
62	36	2627648901036
62	78	2627649001078
62	92	2627649101092
62	91	2627649201091
62	119	2627649301119
62	86	2627649401086
62	136	2627649501136
62	21	2627649601021
62	84	2627649701084
62	121	2627649801121
63	30	2627760101030
63	82	2627760201082
63	75	2627760301075
63	47	2627760401047
63	110	2627760501110
63	26	2627760601026
63	77	2627760701077
63	20	2627760801020
63	94	2627760901094
63	24	2627761001024
63	40	2627761101040
63	28	2627761201028
63	95	2627761301095
63	53	2627761401053
63	25	2627761501025
63	49	2627761601049
63	51	2627761701051
63	52	2627761801052
63	50	2627761901050
63	54	2627762001054
63	55	2627762101055
63	57	2627762201057
63	56	2627762301056
63	58	2627762401058
63	59	2627762501059
63	60	2627762601060
63	61	2627762701061
63	62	2627762801062
63	63	2627762901063
63	64	2627763001064
63	66	2627763101066
63	65	2627763201065
63	107	2627763301107
63	67	2627763401067
63	134	2627763501134
63	22	2627763601022
63	27	2627763701027
63	103	2627763801103
63	87	2627763901087
63	88	2627764001088
63	89	2627764101089
63	32	2627764201032
63	29	2627764301029
63	33	2627764401033
63	96	2627764501096
63	35	2627764601035
63	102	2627764701102
63	120	2627764801120
63	13	2627764901013
63	39	2627765001039
63	17	2627765101017
63	38	2627765201038
63	43	2627765301043
63	48	2627765401048
63	42	2627765501042
63	44	2627765601044
63	23	2627765701023
63	135	2627765801135
63	45	2627765901045
63	83	2627766001083
63	98	2627766101098
63	93	2627766201093
63	12	2627766301012
63	97	2627766401097
63	68	2627766501068
63	122	2627766601122
63	69	2627766701069
63	41	2627766801041
63	72	2627766901072
63	31	2627767001031
63	76	2627767101076
63	71	2627767201071
63	74	2627767301074
63	73	2627767401073
63	19	2627767501019
63	18	2627767601018
63	14	2627767701014
63	15	2627767801015
63	16	2627767901016
63	79	2627768001079
63	11	2627768101011
63	80	2627768201080
63	34	2627768301034
63	46	2627768401046
63	37	2627768501037
63	90	2627768601090
63	10	2627768701010
63	85	2627768801085
63	36	2627768901036
63	78	2627769001078
63	92	2627769101092
63	91	2627769201091
63	119	2627769301119
63	86	2627769401086
63	136	2627769501136
63	21	2627769601021
63	84	2627769701084
63	121	2627769801121
64	30	2627769901030
64	82	26277610001082
64	75	26277610101075
64	47	26277610201047
64	110	26277610301110
64	26	26277610401026
64	77	26277610501077
64	20	26277610601020
64	94	26277610701094
64	24	26277610801024
64	40	26277610901040
64	28	26277611001028
64	95	26277611101095
64	53	26277611201053
64	25	26277611301025
64	49	26277611401049
64	51	26277611501051
64	52	26277611601052
64	50	26277611701050
64	54	26277611801054
64	55	26277611901055
64	57	26277612001057
64	56	26277612101056
64	58	26277612201058
64	59	26277612301059
64	60	26277612401060
64	61	26277612501061
64	62	26277612601062
64	63	26277612701063
64	64	26277612801064
64	66	26277612901066
64	65	26277613001065
64	107	26277613101107
64	67	26277613201067
64	134	26277613301134
64	22	26277613401022
64	27	26277613501027
64	103	26277613601103
64	87	26277613701087
64	88	26277613801088
64	89	26277613901089
64	32	26277614001032
64	29	26277614101029
64	33	26277614201033
64	96	26277614301096
64	35	26277614401035
64	102	26277614501102
64	120	26277614601120
64	13	26277614701013
64	39	26277614801039
64	17	26277614901017
64	38	26277615001038
64	43	26277615101043
64	48	26277615201048
64	42	26277615301042
64	44	26277615401044
64	23	26277615501023
64	135	26277615601135
64	45	26277615701045
64	83	26277615801083
64	98	26277615901098
64	93	26277616001093
64	12	26277616101012
64	97	26277616201097
64	68	26277616301068
64	122	26277616401122
64	69	26277616501069
64	41	26277616601041
64	72	26277616701072
64	31	26277616801031
64	76	26277616901076
64	71	26277617001071
64	74	26277617101074
64	73	26277617201073
64	19	26277617301019
64	18	26277617401018
64	14	26277617501014
64	15	26277617601015
64	16	26277617701016
64	79	26277617801079
64	11	26277617901011
64	80	26277618001080
64	34	26277618101034
64	46	26277618201046
64	37	26277618301037
64	90	26277618401090
64	10	26277618501010
64	85	26277618601085
64	36	26277618701036
64	78	26277618801078
64	92	26277618901092
64	91	26277619001091
64	119	26277619101119
64	86	26277619201086
64	136	26277619301136
64	21	26277619401021
64	84	26277619501084
64	121	26277619601121
66	30	2627740101030
66	82	2627740201082
66	75	2627740301075
66	47	2627740401047
66	110	2627740501110
66	26	2627740601026
66	77	2627740701077
66	20	2627740801020
66	94	2627740901094
66	24	2627741001024
66	40	2627741101040
66	28	2627741201028
66	95	2627741301095
66	53	2627741401053
66	25	2627741501025
66	49	2627741601049
66	51	2627741701051
66	52	2627741801052
66	50	2627741901050
66	54	2627742001054
66	55	2627742101055
66	57	2627742201057
66	56	2627742301056
66	58	2627742401058
66	59	2627742501059
66	60	2627742601060
66	61	2627742701061
66	62	2627742801062
66	63	2627742901063
66	64	2627743001064
66	66	2627743101066
66	65	2627743201065
66	107	2627743301107
66	67	2627743401067
66	134	2627743501134
66	22	2627743601022
66	27	2627743701027
66	103	2627743801103
66	87	2627743901087
66	88	2627744001088
66	89	2627744101089
66	32	2627744201032
66	29	2627744301029
66	33	2627744401033
66	96	2627744501096
66	35	2627744601035
66	102	2627744701102
66	120	2627744801120
66	13	2627744901013
66	39	2627745001039
66	17	2627745101017
66	38	2627745201038
66	43	2627745301043
66	48	2627745401048
66	42	2627745501042
66	44	2627745601044
66	23	2627745701023
66	135	2627745801135
66	45	2627745901045
66	83	2627746001083
66	98	2627746101098
66	93	2627746201093
66	12	2627746301012
66	97	2627746401097
66	68	2627746501068
66	122	2627746601122
66	69	2627746701069
66	41	2627746801041
66	72	2627746901072
66	31	2627747001031
66	76	2627747101076
66	71	2627747201071
66	74	2627747301074
66	73	2627747401073
66	19	2627747501019
66	18	2627747601018
66	14	2627747701014
66	15	2627747801015
66	16	2627747901016
66	79	2627748001079
66	11	2627748101011
66	80	2627748201080
66	34	2627748301034
66	46	2627748401046
66	37	2627748501037
66	90	2627748601090
66	10	2627748701010
66	85	2627748801085
66	36	2627748901036
66	78	2627749001078
66	92	2627749101092
66	91	2627749201091
66	119	2627749301119
66	86	2627749401086
66	136	2627749501136
66	21	2627749601021
66	84	2627749701084
66	121	2627749801121
65	30	2627750101030
65	82	2627750201082
65	75	2627750301075
65	47	2627750401047
65	110	2627750501110
65	26	2627750601026
65	77	2627750701077
65	20	2627750801020
65	94	2627750901094
65	24	2627751001024
65	40	2627751101040
65	28	2627751201028
65	95	2627751301095
65	53	2627751401053
65	25	2627751501025
65	49	2627751601049
65	51	2627751701051
65	52	2627751801052
65	50	2627751901050
65	54	2627752001054
65	55	2627752101055
65	57	2627752201057
65	56	2627752301056
65	58	2627752401058
65	59	2627752501059
65	60	2627752601060
65	61	2627752701061
65	62	2627752801062
65	63	2627752901063
65	64	2627753001064
65	66	2627753101066
65	65	2627753201065
65	107	2627753301107
65	67	2627753401067
65	134	2627753501134
65	22	2627753601022
65	27	2627753701027
65	103	2627753801103
65	87	2627753901087
65	88	2627754001088
65	89	2627754101089
65	32	2627754201032
65	29	2627754301029
65	33	2627754401033
65	96	2627754501096
65	35	2627754601035
65	102	2627754701102
65	120	2627754801120
65	13	2627754901013
65	39	2627755001039
65	17	2627755101017
65	38	2627755201038
65	43	2627755301043
65	48	2627755401048
65	42	2627755501042
65	44	2627755601044
65	23	2627755701023
65	135	2627755801135
65	45	2627755901045
65	83	2627756001083
65	98	2627756101098
65	93	2627756201093
65	12	2627756301012
65	97	2627756401097
65	68	2627756501068
65	122	2627756601122
65	69	2627756701069
65	41	2627756801041
65	72	2627756901072
65	31	2627757001031
65	76	2627757101076
65	71	2627757201071
65	74	2627757301074
65	73	2627757401073
65	19	2627757501019
65	18	2627757601018
65	14	2627757701014
65	15	2627757801015
65	16	2627757901016
65	79	2627758001079
65	11	2627758101011
65	80	2627758201080
65	34	2627758301034
65	46	2627758401046
65	37	2627758501037
65	90	2627758601090
65	10	2627758701010
65	85	2627758801085
65	36	2627758901036
65	78	2627759001078
65	92	2627759101092
65	91	2627759201091
65	119	2627759301119
65	86	2627759401086
65	136	2627759501136
65	21	2627759601021
65	84	2627759701084
65	121	2627759801121
107	30	2627780101030
107	82	2627780201082
107	75	2627780301075
107	47	2627780401047
107	110	2627780501110
107	26	2627780601026
107	77	2627780701077
107	20	2627780801020
107	94	2627780901094
107	24	2627781001024
107	40	2627781101040
107	28	2627781201028
107	95	2627781301095
107	53	2627781401053
107	25	2627781501025
107	49	2627781601049
107	51	2627781701051
107	52	2627781801052
107	50	2627781901050
107	54	2627782001054
107	55	2627782101055
107	57	2627782201057
107	56	2627782301056
107	58	2627782401058
107	59	2627782501059
107	60	2627782601060
107	61	2627782701061
107	62	2627782801062
107	63	2627782901063
107	64	2627783001064
107	66	2627783101066
107	65	2627783201065
107	107	2627783301107
107	67	2627783401067
107	134	2627783501134
107	22	2627783601022
107	27	2627783701027
107	103	2627783801103
107	87	2627783901087
107	88	2627784001088
107	89	2627784101089
107	32	2627784201032
107	29	2627784301029
107	33	2627784401033
107	96	2627784501096
107	35	2627784601035
107	102	2627784701102
107	120	2627784801120
107	13	2627784901013
107	39	2627785001039
107	17	2627785101017
107	38	2627785201038
107	43	2627785301043
107	48	2627785401048
107	42	2627785501042
107	44	2627785601044
107	23	2627785701023
107	135	2627785801135
107	45	2627785901045
107	83	2627786001083
107	98	2627786101098
107	93	2627786201093
107	12	2627786301012
107	97	2627786401097
107	68	2627786501068
107	122	2627786601122
107	69	2627786701069
107	41	2627786801041
107	72	2627786901072
107	31	2627787001031
107	76	2627787101076
107	71	2627787201071
107	74	2627787301074
107	73	2627787401073
107	19	2627787501019
107	18	2627787601018
107	14	2627787701014
107	15	2627787801015
107	16	2627787901016
107	79	2627788001079
107	11	2627788101011
107	80	2627788201080
107	34	2627788301034
107	46	2627788401046
107	37	2627788501037
107	90	2627788601090
107	10	2627788701010
107	85	2627788801085
107	36	2627788901036
107	78	2627789001078
107	92	2627789101092
107	91	2627789201091
107	119	2627789301119
107	86	2627789401086
107	136	2627789501136
107	21	2627789601021
107	84	2627789701084
107	121	2627789801121
67	30	2627970101030
67	82	2627970201082
67	75	2627970301075
67	47	2627970401047
67	110	2627970501110
67	26	2627970601026
67	77	2627970701077
67	20	2627970801020
67	94	2627970901094
67	24	2627971001024
67	40	2627971101040
67	28	2627971201028
67	95	2627971301095
67	53	2627971401053
67	25	2627971501025
67	49	2627971601049
67	51	2627971701051
67	52	2627971801052
67	50	2627971901050
67	54	2627972001054
67	55	2627972101055
67	57	2627972201057
67	56	2627972301056
67	58	2627972401058
67	59	2627972501059
67	60	2627972601060
67	61	2627972701061
67	62	2627972801062
67	63	2627972901063
67	64	2627973001064
67	66	2627973101066
67	65	2627973201065
67	107	2627973301107
67	67	2627973401067
67	134	2627973501134
67	22	2627973601022
67	27	2627973701027
67	103	2627973801103
67	87	2627973901087
67	88	2627974001088
67	89	2627974101089
67	32	2627974201032
67	29	2627974301029
67	33	2627974401033
67	96	2627974501096
67	35	2627974601035
67	102	2627974701102
67	120	2627974801120
67	13	2627974901013
67	39	2627975001039
67	17	2627975101017
67	38	2627975201038
67	43	2627975301043
67	48	2627975401048
67	42	2627975501042
67	44	2627975601044
67	23	2627975701023
67	135	2627975801135
67	45	2627975901045
67	83	2627976001083
67	98	2627976101098
67	93	2627976201093
67	12	2627976301012
67	97	2627976401097
67	68	2627976501068
67	122	2627976601122
67	69	2627976701069
67	41	2627976801041
67	72	2627976901072
67	31	2627977001031
67	76	2627977101076
67	71	2627977201071
67	74	2627977301074
67	73	2627977401073
67	19	2627977501019
67	18	2627977601018
67	14	2627977701014
67	15	2627977801015
67	16	2627977901016
67	79	2627978001079
67	11	2627978101011
67	80	2627978201080
67	34	2627978301034
67	46	2627978401046
67	37	2627978501037
67	90	2627978601090
67	10	2627978701010
67	85	2627978801085
67	36	2627978901036
67	78	2627979001078
67	92	2627979101092
67	91	2627979201091
67	119	2627979301119
67	86	2627979401086
67	136	2627979501136
67	21	2627979601021
67	84	2627979701084
67	121	2627979801121
134	30	2637000101030
134	82	2637000201082
134	75	2637000301075
134	47	2637000401047
134	110	2637000501110
134	26	2637000601026
134	77	2637000701077
134	20	2637000801020
134	94	2637000901094
134	24	2637001001024
134	40	2637001101040
134	28	2637001201028
134	95	2637001301095
134	53	2637001401053
134	25	2637001501025
134	49	2637001601049
134	51	2637001701051
134	52	2637001801052
134	50	2637001901050
134	54	2637002001054
134	55	2637002101055
134	57	2637002201057
134	56	2637002301056
134	58	2637002401058
134	59	2637002501059
134	60	2637002601060
134	61	2637002701061
134	62	2637002801062
134	63	2637002901063
134	64	2637003001064
134	66	2637003101066
134	65	2637003201065
134	107	2637003301107
134	67	2637003401067
134	134	2637003501134
134	22	2637003601022
134	27	2637003701027
134	103	2637003801103
134	87	2637003901087
134	88	2637004001088
134	89	2637004101089
134	32	2637004201032
134	29	2637004301029
134	33	2637004401033
134	96	2637004501096
134	35	2637004601035
134	102	2637004701102
134	120	2637004801120
134	13	2637004901013
134	39	2637005001039
134	17	2637005101017
134	38	2637005201038
134	43	2637005301043
134	48	2637005401048
134	42	2637005501042
134	44	2637005601044
134	23	2637005701023
134	135	2637005801135
134	45	2637005901045
134	83	2637006001083
134	98	2637006101098
134	93	2637006201093
134	12	2637006301012
134	97	2637006401097
134	68	2637006501068
134	122	2637006601122
134	69	2637006701069
134	41	2637006801041
134	72	2637006901072
134	31	2637007001031
134	76	2637007101076
134	71	2637007201071
134	74	2637007301074
134	73	2637007401073
134	19	2637007501019
134	18	2637007601018
134	14	2637007701014
134	15	2637007801015
134	16	2637007901016
134	79	2637008001079
134	11	2637008101011
134	80	2637008201080
134	34	2637008301034
134	46	2637008401046
134	37	2637008501037
134	90	2637008601090
134	10	2637008701010
134	85	2637008801085
134	36	2637008901036
134	78	2637009001078
134	92	2637009101092
134	91	2637009201091
134	119	2637009301119
134	86	2637009401086
134	136	2637009501136
134	21	2637009601021
134	84	2637009701084
134	121	2637009801121
22	30	2630000101030
22	82	2630000201082
22	75	2630000301075
22	47	2630000401047
22	110	2630000501110
22	26	2630000601026
22	77	2630000701077
22	20	2630000801020
22	94	2630000901094
22	24	2630001001024
22	40	2630001101040
22	28	2630001201028
22	95	2630001301095
22	53	2630001401053
22	25	2630001501025
22	49	2630001601049
22	51	2630001701051
22	52	2630001801052
22	50	2630001901050
22	54	2630002001054
22	55	2630002101055
22	57	2630002201057
22	56	2630002301056
22	58	2630002401058
22	59	2630002501059
22	60	2630002601060
22	61	2630002701061
22	62	2630002801062
22	63	2630002901063
22	64	2630003001064
22	66	2630003101066
22	65	2630003201065
22	107	2630003301107
22	67	2630003401067
22	134	2630003501134
22	22	2630003601022
22	27	2630003701027
22	103	2630003801103
22	87	2630003901087
22	88	2630004001088
22	89	2630004101089
22	32	2630004201032
22	29	2630004301029
22	33	2630004401033
22	96	2630004501096
22	35	2630004601035
22	102	2630004701102
22	120	2630004801120
22	13	2630004901013
22	39	2630005001039
22	17	2630005101017
22	38	2630005201038
22	43	2630005301043
22	48	2630005401048
22	42	2630005501042
22	44	2630005601044
22	23	2630005701023
22	135	2630005801135
22	45	2630005901045
22	83	2630006001083
22	98	2630006101098
22	93	2630006201093
22	12	2630006301012
22	97	2630006401097
22	68	2630006501068
22	122	2630006601122
22	69	2630006701069
22	41	2630006801041
22	72	2630006901072
22	31	2630007001031
22	76	2630007101076
22	71	2630007201071
22	74	2630007301074
22	73	2630007401073
22	19	2630007501019
22	18	2630007601018
22	14	2630007701014
22	15	2630007801015
22	16	2630007901016
22	79	2630008001079
22	11	2630008101011
22	80	2630008201080
22	34	2630008301034
22	46	2630008401046
22	37	2630008501037
22	90	2630008601090
22	10	2630008701010
22	85	2630008801085
22	36	2630008901036
22	78	2630009001078
22	92	2630009101092
22	91	2630009201091
22	119	2630009301119
22	86	2630009401086
22	136	2630009501136
22	21	2630009601021
22	84	2630009701084
22	121	2630009801121
27	30	2635000101030
27	82	2635000201082
27	75	2635000301075
27	47	2635000401047
27	110	2635000501110
27	26	2635000601026
27	77	2635000701077
27	20	2635000801020
27	94	2635000901094
27	24	2635001001024
27	40	2635001101040
27	28	2635001201028
27	95	2635001301095
27	53	2635001401053
27	25	2635001501025
27	49	2635001601049
27	51	2635001701051
27	52	2635001801052
27	50	2635001901050
27	54	2635002001054
27	55	2635002101055
27	57	2635002201057
27	56	2635002301056
27	58	2635002401058
27	59	2635002501059
27	60	2635002601060
27	61	2635002701061
27	62	2635002801062
27	63	2635002901063
27	64	2635003001064
27	66	2635003101066
27	65	2635003201065
27	107	2635003301107
27	67	2635003401067
27	134	2635003501134
27	22	2635003601022
27	27	2635003701027
27	103	2635003801103
27	87	2635003901087
27	88	2635004001088
27	89	2635004101089
27	32	2635004201032
27	29	2635004301029
27	33	2635004401033
27	96	2635004501096
27	35	2635004601035
27	102	2635004701102
27	120	2635004801120
27	13	2635004901013
27	39	2635005001039
27	17	2635005101017
27	38	2635005201038
27	43	2635005301043
27	48	2635005401048
27	42	2635005501042
27	44	2635005601044
27	23	2635005701023
27	135	2635005801135
27	45	2635005901045
27	83	2635006001083
27	98	2635006101098
27	93	2635006201093
27	12	2635006301012
27	97	2635006401097
27	68	2635006501068
27	122	2635006601122
27	69	2635006701069
27	41	2635006801041
27	72	2635006901072
27	31	2635007001031
27	76	2635007101076
27	71	2635007201071
27	74	2635007301074
27	73	2635007401073
27	19	2635007501019
27	18	2635007601018
27	14	2635007701014
27	15	2635007801015
27	16	2635007901016
27	79	2635008001079
27	11	2635008101011
27	80	2635008201080
27	34	2635008301034
27	46	2635008401046
27	37	2635008501037
27	90	2635008601090
27	10	2635008701010
27	85	2635008801085
27	36	2635008901036
27	78	2635009001078
27	92	2635009101092
27	91	2635009201091
27	119	2635009301119
27	86	2635009401086
27	136	2635009501136
27	21	2635009601021
27	84	2635009701084
27	121	2635009801121
103	30	2637500101030
103	82	2637500201082
103	75	2637500301075
103	47	2637500401047
103	110	2637500501110
103	26	2637500601026
103	77	2637500701077
103	20	2637500801020
103	94	2637500901094
103	24	2637501001024
103	40	2637501101040
103	28	2637501201028
103	95	2637501301095
103	53	2637501401053
103	25	2637501501025
103	49	2637501601049
103	51	2637501701051
103	52	2637501801052
103	50	2637501901050
103	54	2637502001054
103	55	2637502101055
103	57	2637502201057
103	56	2637502301056
103	58	2637502401058
103	59	2637502501059
103	60	2637502601060
103	61	2637502701061
103	62	2637502801062
103	63	2637502901063
103	64	2637503001064
103	66	2637503101066
103	65	2637503201065
103	107	2637503301107
103	67	2637503401067
103	134	2637503501134
103	22	2637503601022
103	27	2637503701027
103	103	2637503801103
103	87	2637503901087
103	88	2637504001088
103	89	2637504101089
103	32	2637504201032
103	29	2637504301029
103	33	2637504401033
103	96	2637504501096
103	35	2637504601035
103	102	2637504701102
103	120	2637504801120
103	13	2637504901013
103	39	2637505001039
103	17	2637505101017
103	38	2637505201038
103	43	2637505301043
103	48	2637505401048
103	42	2637505501042
103	44	2637505601044
103	23	2637505701023
103	135	2637505801135
103	45	2637505901045
103	83	2637506001083
103	98	2637506101098
103	93	2637506201093
103	12	2637506301012
103	97	2637506401097
103	68	2637506501068
103	122	2637506601122
103	69	2637506701069
103	41	2637506801041
103	72	2637506901072
103	31	2637507001031
103	76	2637507101076
103	71	2637507201071
103	74	2637507301074
103	73	2637507401073
103	19	2637507501019
103	18	2637507601018
103	14	2637507701014
103	15	2637507801015
103	16	2637507901016
103	79	2637508001079
103	11	2637508101011
103	80	2637508201080
103	34	2637508301034
103	46	2637508401046
103	37	2637508501037
103	90	2637508601090
103	10	2637508701010
103	85	2637508801085
103	36	2637508901036
103	78	2637509001078
103	92	2637509101092
103	91	2637509201091
103	119	2637509301119
103	86	2637509401086
103	136	2637509501136
103	21	2637509601021
103	84	2637509701084
103	121	2637509801121
87	30	2637600101030
87	82	2637600201082
87	75	2637600301075
87	47	2637600401047
87	110	2637600501110
87	26	2637600601026
87	77	2637600701077
87	20	2637600801020
87	94	2637600901094
87	24	2637601001024
87	40	2637601101040
87	28	2637601201028
87	95	2637601301095
87	53	2637601401053
87	25	2637601501025
87	49	2637601601049
87	51	2637601701051
87	52	2637601801052
87	50	2637601901050
87	54	2637602001054
87	55	2637602101055
87	57	2637602201057
87	56	2637602301056
87	58	2637602401058
87	59	2637602501059
87	60	2637602601060
87	61	2637602701061
87	62	2637602801062
87	63	2637602901063
87	64	2637603001064
87	66	2637603101066
87	65	2637603201065
87	107	2637603301107
87	67	2637603401067
87	134	2637603501134
87	22	2637603601022
87	27	2637603701027
87	103	2637603801103
87	87	2637603901087
87	88	2637604001088
87	89	2637604101089
87	32	2637604201032
87	29	2637604301029
87	33	2637604401033
87	96	2637604501096
87	35	2637604601035
87	102	2637604701102
87	120	2637604801120
87	13	2637604901013
87	39	2637605001039
87	17	2637605101017
87	38	2637605201038
87	43	2637605301043
87	48	2637605401048
87	42	2637605501042
87	44	2637605601044
87	23	2637605701023
87	135	2637605801135
87	45	2637605901045
87	83	2637606001083
87	98	2637606101098
87	93	2637606201093
87	12	2637606301012
87	97	2637606401097
87	68	2637606501068
87	122	2637606601122
87	69	2637606701069
87	41	2637606801041
87	72	2637606901072
87	31	2637607001031
87	76	2637607101076
87	71	2637607201071
87	74	2637607301074
87	73	2637607401073
87	19	2637607501019
87	18	2637607601018
87	14	2637607701014
87	15	2637607801015
87	16	2637607901016
87	79	2637608001079
87	11	2637608101011
87	80	2637608201080
87	34	2637608301034
87	46	2637608401046
87	37	2637608501037
87	90	2637608601090
87	10	2637608701010
87	85	2637608801085
87	36	2637608901036
87	78	2637609001078
87	92	2637609101092
87	91	2637609201091
87	119	2637609301119
87	86	2637609401086
87	136	2637609501136
87	21	2637609601021
87	84	2637609701084
87	121	2637609801121
88	30	2637660101030
88	82	2637660201082
88	75	2637660301075
88	47	2637660401047
88	110	2637660501110
88	26	2637660601026
88	77	2637660701077
88	20	2637660801020
88	94	2637660901094
88	24	2637661001024
88	40	2637661101040
88	28	2637661201028
88	95	2637661301095
88	53	2637661401053
88	25	2637661501025
88	49	2637661601049
88	51	2637661701051
88	52	2637661801052
88	50	2637661901050
88	54	2637662001054
88	55	2637662101055
88	57	2637662201057
88	56	2637662301056
88	58	2637662401058
88	59	2637662501059
88	60	2637662601060
88	61	2637662701061
88	62	2637662801062
88	63	2637662901063
88	64	2637663001064
88	66	2637663101066
88	65	2637663201065
88	107	2637663301107
88	67	2637663401067
88	134	2637663501134
88	22	2637663601022
88	27	2637663701027
88	103	2637663801103
88	87	2637663901087
88	88	2637664001088
88	89	2637664101089
88	32	2637664201032
88	29	2637664301029
88	33	2637664401033
88	96	2637664501096
88	35	2637664601035
88	102	2637664701102
88	120	2637664801120
88	13	2637664901013
88	39	2637665001039
88	17	2637665101017
88	38	2637665201038
88	43	2637665301043
88	48	2637665401048
88	42	2637665501042
88	44	2637665601044
88	23	2637665701023
88	135	2637665801135
88	45	2637665901045
88	83	2637666001083
88	98	2637666101098
88	93	2637666201093
88	12	2637666301012
88	97	2637666401097
88	68	2637666501068
88	122	2637666601122
88	69	2637666701069
88	41	2637666801041
88	72	2637666901072
88	31	2637667001031
88	76	2637667101076
88	71	2637667201071
88	74	2637667301074
88	73	2637667401073
88	19	2637667501019
88	18	2637667601018
88	14	2637667701014
88	15	2637667801015
88	16	2637667901016
88	79	2637668001079
88	11	2637668101011
88	80	2637668201080
88	34	2637668301034
88	46	2637668401046
88	37	2637668501037
88	90	2637668601090
88	10	2637668701010
88	85	2637668801085
88	36	2637668901036
88	78	2637669001078
88	92	2637669101092
88	91	2637669201091
88	119	2637669301119
88	86	2637669401086
88	136	2637669501136
88	21	2637669601021
88	84	2637669701084
88	121	2637669801121
89	30	2637700101030
89	82	2637700201082
89	75	2637700301075
89	47	2637700401047
89	110	2637700501110
89	26	2637700601026
89	77	2637700701077
89	20	2637700801020
89	94	2637700901094
89	24	2637701001024
89	40	2637701101040
89	28	2637701201028
89	95	2637701301095
89	53	2637701401053
89	25	2637701501025
89	49	2637701601049
89	51	2637701701051
89	52	2637701801052
89	50	2637701901050
89	54	2637702001054
89	55	2637702101055
89	57	2637702201057
89	56	2637702301056
89	58	2637702401058
89	59	2637702501059
89	60	2637702601060
89	61	2637702701061
89	62	2637702801062
89	63	2637702901063
89	64	2637703001064
89	66	2637703101066
89	65	2637703201065
89	107	2637703301107
89	67	2637703401067
89	134	2637703501134
89	22	2637703601022
89	27	2637703701027
89	103	2637703801103
89	87	2637703901087
89	88	2637704001088
89	89	2637704101089
89	32	2637704201032
89	29	2637704301029
89	33	2637704401033
89	96	2637704501096
89	35	2637704601035
89	102	2637704701102
89	120	2637704801120
89	13	2637704901013
89	39	2637705001039
89	17	2637705101017
89	38	2637705201038
89	43	2637705301043
89	48	2637705401048
89	42	2637705501042
89	44	2637705601044
89	23	2637705701023
89	135	2637705801135
89	45	2637705901045
89	83	2637706001083
89	98	2637706101098
89	93	2637706201093
89	12	2637706301012
89	97	2637706401097
89	68	2637706501068
89	122	2637706601122
89	69	2637706701069
89	41	2637706801041
89	72	2637706901072
89	31	2637707001031
89	76	2637707101076
89	71	2637707201071
89	74	2637707301074
89	73	2637707401073
89	19	2637707501019
89	18	2637707601018
89	14	2637707701014
89	15	2637707801015
89	16	2637707901016
89	79	2637708001079
89	11	2637708101011
89	80	2637708201080
89	34	2637708301034
89	46	2637708401046
89	37	2637708501037
89	90	2637708601090
89	10	2637708701010
89	85	2637708801085
89	36	2637708901036
89	78	2637709001078
89	92	2637709101092
89	91	2637709201091
89	119	2637709301119
89	86	2637709401086
89	136	2637709501136
89	21	2637709601021
89	84	2637709701084
89	121	2637709801121
32	30	2633000101030
32	82	2633000201082
32	75	2633000301075
32	47	2633000401047
32	110	2633000501110
32	26	2633000601026
32	77	2633000701077
32	20	2633000801020
32	94	2633000901094
32	24	2633001001024
32	40	2633001101040
32	28	2633001201028
32	95	2633001301095
32	53	2633001401053
32	25	2633001501025
32	49	2633001601049
32	51	2633001701051
32	52	2633001801052
32	50	2633001901050
32	54	2633002001054
32	55	2633002101055
32	57	2633002201057
32	56	2633002301056
32	58	2633002401058
32	59	2633002501059
32	60	2633002601060
32	61	2633002701061
32	62	2633002801062
32	63	2633002901063
32	64	2633003001064
32	66	2633003101066
32	65	2633003201065
32	107	2633003301107
32	67	2633003401067
32	134	2633003501134
32	22	2633003601022
32	27	2633003701027
32	103	2633003801103
32	87	2633003901087
32	88	2633004001088
32	89	2633004101089
32	32	2633004201032
32	29	2633004301029
32	33	2633004401033
32	96	2633004501096
32	35	2633004601035
32	102	2633004701102
32	120	2633004801120
32	13	2633004901013
32	39	2633005001039
32	17	2633005101017
32	38	2633005201038
32	43	2633005301043
32	48	2633005401048
32	42	2633005501042
32	44	2633005601044
32	23	2633005701023
32	135	2633005801135
32	45	2633005901045
32	83	2633006001083
32	98	2633006101098
32	93	2633006201093
32	12	2633006301012
32	97	2633006401097
32	68	2633006501068
32	122	2633006601122
32	69	2633006701069
32	41	2633006801041
32	72	2633006901072
32	31	2633007001031
32	76	2633007101076
32	71	2633007201071
32	74	2633007301074
32	73	2633007401073
32	19	2633007501019
32	18	2633007601018
32	14	2633007701014
32	15	2633007801015
32	16	2633007901016
32	79	2633008001079
32	11	2633008101011
32	80	2633008201080
32	34	2633008301034
32	46	2633008401046
32	37	2633008501037
32	90	2633008601090
32	10	2633008701010
32	85	2633008801085
32	36	2633008901036
32	78	2633009001078
32	92	2633009101092
32	91	2633009201091
32	119	2633009301119
32	86	2633009401086
32	136	2633009501136
32	21	2633009601021
32	84	2633009701084
32	121	2633009801121
29	30	2643000101030
29	82	2643000201082
29	75	2643000301075
29	47	2643000401047
29	110	2643000501110
29	26	2643000601026
29	77	2643000701077
29	20	2643000801020
29	94	2643000901094
29	24	2643001001024
29	40	2643001101040
29	28	2643001201028
29	95	2643001301095
29	53	2643001401053
29	25	2643001501025
29	49	2643001601049
29	51	2643001701051
29	52	2643001801052
29	50	2643001901050
29	54	2643002001054
29	55	2643002101055
29	57	2643002201057
29	56	2643002301056
29	58	2643002401058
29	59	2643002501059
29	60	2643002601060
29	61	2643002701061
29	62	2643002801062
29	63	2643002901063
29	64	2643003001064
29	66	2643003101066
29	65	2643003201065
29	107	2643003301107
29	67	2643003401067
29	134	2643003501134
29	22	2643003601022
29	27	2643003701027
29	103	2643003801103
29	87	2643003901087
29	88	2643004001088
29	89	2643004101089
29	32	2643004201032
29	29	2643004301029
29	33	2643004401033
29	96	2643004501096
29	35	2643004601035
29	102	2643004701102
29	120	2643004801120
29	13	2643004901013
29	39	2643005001039
29	17	2643005101017
29	38	2643005201038
29	43	2643005301043
29	48	2643005401048
29	42	2643005501042
29	44	2643005601044
29	23	2643005701023
29	135	2643005801135
29	45	2643005901045
29	83	2643006001083
29	98	2643006101098
29	93	2643006201093
29	12	2643006301012
29	97	2643006401097
29	68	2643006501068
29	122	2643006601122
29	69	2643006701069
29	41	2643006801041
29	72	2643006901072
29	31	2643007001031
29	76	2643007101076
29	71	2643007201071
29	74	2643007301074
29	73	2643007401073
29	19	2643007501019
29	18	2643007601018
29	14	2643007701014
29	15	2643007801015
29	16	2643007901016
29	79	2643008001079
29	11	2643008101011
29	80	2643008201080
29	34	2643008301034
29	46	2643008401046
29	37	2643008501037
29	90	2643008601090
29	10	2643008701010
29	85	2643008801085
29	36	2643008901036
29	78	2643009001078
29	92	2643009101092
29	91	2643009201091
29	119	2643009301119
29	86	2643009401086
29	136	2643009501136
29	21	2643009601021
29	84	2643009701084
29	121	2643009801121
33	30	2644000101030
33	82	2644000201082
33	75	2644000301075
33	47	2644000401047
33	110	2644000501110
33	26	2644000601026
33	77	2644000701077
33	20	2644000801020
33	94	2644000901094
33	24	2644001001024
33	40	2644001101040
33	28	2644001201028
33	95	2644001301095
33	53	2644001401053
33	25	2644001501025
33	49	2644001601049
33	51	2644001701051
33	52	2644001801052
33	50	2644001901050
33	54	2644002001054
33	55	2644002101055
33	57	2644002201057
33	56	2644002301056
33	58	2644002401058
33	59	2644002501059
33	60	2644002601060
33	61	2644002701061
33	62	2644002801062
33	63	2644002901063
33	64	2644003001064
33	66	2644003101066
33	65	2644003201065
33	107	2644003301107
33	67	2644003401067
33	134	2644003501134
33	22	2644003601022
33	27	2644003701027
33	103	2644003801103
33	87	2644003901087
33	88	2644004001088
33	89	2644004101089
33	32	2644004201032
33	29	2644004301029
33	33	2644004401033
33	96	2644004501096
33	35	2644004601035
33	102	2644004701102
33	120	2644004801120
33	13	2644004901013
33	39	2644005001039
33	17	2644005101017
33	38	2644005201038
33	43	2644005301043
33	48	2644005401048
33	42	2644005501042
33	44	2644005601044
33	23	2644005701023
33	135	2644005801135
33	45	2644005901045
33	83	2644006001083
33	98	2644006101098
33	93	2644006201093
33	12	2644006301012
33	97	2644006401097
33	68	2644006501068
33	122	2644006601122
33	69	2644006701069
33	41	2644006801041
33	72	2644006901072
33	31	2644007001031
33	76	2644007101076
33	71	2644007201071
33	74	2644007301074
33	73	2644007401073
33	19	2644007501019
33	18	2644007601018
33	14	2644007701014
33	15	2644007801015
33	16	2644007901016
33	79	2644008001079
33	11	2644008101011
33	80	2644008201080
33	34	2644008301034
33	46	2644008401046
33	37	2644008501037
33	90	2644008601090
33	10	2644008701010
33	85	2644008801085
33	36	2644008901036
33	78	2644009001078
33	92	2644009101092
33	91	2644009201091
33	119	2644009301119
33	86	2644009401086
33	136	2644009501136
33	21	2644009601021
33	84	2644009701084
33	121	2644009801121
96	30	2649000101030
96	82	2649000201082
96	75	2649000301075
96	47	2649000401047
96	110	2649000501110
96	26	2649000601026
96	77	2649000701077
96	20	2649000801020
96	94	2649000901094
96	24	2649001001024
96	40	2649001101040
96	28	2649001201028
96	95	2649001301095
96	53	2649001401053
96	25	2649001501025
96	49	2649001601049
96	51	2649001701051
96	52	2649001801052
96	50	2649001901050
96	54	2649002001054
96	55	2649002101055
96	57	2649002201057
96	56	2649002301056
96	58	2649002401058
96	59	2649002501059
96	60	2649002601060
96	61	2649002701061
96	62	2649002801062
96	63	2649002901063
96	64	2649003001064
96	66	2649003101066
96	65	2649003201065
96	107	2649003301107
96	67	2649003401067
96	134	2649003501134
96	22	2649003601022
96	27	2649003701027
96	103	2649003801103
96	87	2649003901087
96	88	2649004001088
96	89	2649004101089
96	32	2649004201032
96	29	2649004301029
96	33	2649004401033
96	96	2649004501096
96	35	2649004601035
96	102	2649004701102
96	120	2649004801120
96	13	2649004901013
96	39	2649005001039
96	17	2649005101017
96	38	2649005201038
96	43	2649005301043
96	48	2649005401048
96	42	2649005501042
96	44	2649005601044
96	23	2649005701023
96	135	2649005801135
96	45	2649005901045
96	83	2649006001083
96	98	2649006101098
96	93	2649006201093
96	12	2649006301012
96	97	2649006401097
96	68	2649006501068
96	122	2649006601122
96	69	2649006701069
96	41	2649006801041
96	72	2649006901072
96	31	2649007001031
96	76	2649007101076
96	71	2649007201071
96	74	2649007301074
96	73	2649007401073
96	19	2649007501019
96	18	2649007601018
96	14	2649007701014
96	15	2649007801015
96	16	2649007901016
96	79	2649008001079
96	11	2649008101011
96	80	2649008201080
96	34	2649008301034
96	46	2649008401046
96	37	2649008501037
96	90	2649008601090
96	10	2649008701010
96	85	2649008801085
96	36	2649008901036
96	78	2649009001078
96	92	2649009101092
96	91	2649009201091
96	119	2649009301119
96	86	2649009401086
96	136	2649009501136
96	21	2649009601021
96	84	2649009701084
96	121	2649009801121
35	30	2644009901030
35	82	26440010001082
35	75	26440010101075
35	47	26440010201047
35	110	26440010301110
35	26	26440010401026
35	77	26440010501077
35	20	26440010601020
35	94	26440010701094
35	24	26440010801024
35	40	26440010901040
35	28	26440011001028
35	95	26440011101095
35	53	26440011201053
35	25	26440011301025
35	49	26440011401049
35	51	26440011501051
35	52	26440011601052
35	50	26440011701050
35	54	26440011801054
35	55	26440011901055
35	57	26440012001057
35	56	26440012101056
35	58	26440012201058
35	59	26440012301059
35	60	26440012401060
35	61	26440012501061
35	62	26440012601062
35	63	26440012701063
35	64	26440012801064
35	66	26440012901066
35	65	26440013001065
35	107	26440013101107
35	67	26440013201067
35	134	26440013301134
35	22	26440013401022
35	27	26440013501027
35	103	26440013601103
35	87	26440013701087
35	88	26440013801088
35	89	26440013901089
35	32	26440014001032
35	29	26440014101029
35	33	26440014201033
35	96	26440014301096
35	35	26440014401035
35	102	26440014501102
35	120	26440014601120
35	13	26440014701013
35	39	26440014801039
35	17	26440014901017
35	38	26440015001038
35	43	26440015101043
35	48	26440015201048
35	42	26440015301042
35	44	26440015401044
35	23	26440015501023
35	135	26440015601135
35	45	26440015701045
35	83	26440015801083
35	98	26440015901098
35	93	26440016001093
35	12	26440016101012
35	97	26440016201097
35	68	26440016301068
35	122	26440016401122
35	69	26440016501069
35	41	26440016601041
35	72	26440016701072
35	31	26440016801031
35	76	26440016901076
35	71	26440017001071
35	74	26440017101074
35	73	26440017201073
35	19	26440017301019
35	18	26440017401018
35	14	26440017501014
35	15	26440017601015
35	16	26440017701016
35	79	26440017801079
35	11	26440017901011
35	80	26440018001080
35	34	26440018101034
35	46	26440018201046
35	37	26440018301037
35	90	26440018401090
35	10	26440018501010
35	85	26440018601085
35	36	26440018701036
35	78	26440018801078
35	92	26440018901092
35	91	26440019001091
35	119	26440019101119
35	86	26440019201086
35	136	26440019301136
35	21	26440019401021
35	84	26440019501084
35	121	26440019601121
102	30	2647000101030
102	82	2647000201082
102	75	2647000301075
102	47	2647000401047
102	110	2647000501110
102	26	2647000601026
102	77	2647000701077
102	20	2647000801020
102	94	2647000901094
102	24	2647001001024
102	40	2647001101040
102	28	2647001201028
102	95	2647001301095
102	53	2647001401053
102	25	2647001501025
102	49	2647001601049
102	51	2647001701051
102	52	2647001801052
102	50	2647001901050
102	54	2647002001054
102	55	2647002101055
102	57	2647002201057
102	56	2647002301056
102	58	2647002401058
102	59	2647002501059
102	60	2647002601060
102	61	2647002701061
102	62	2647002801062
102	63	2647002901063
102	64	2647003001064
102	66	2647003101066
102	65	2647003201065
102	107	2647003301107
102	67	2647003401067
102	134	2647003501134
102	22	2647003601022
102	27	2647003701027
102	103	2647003801103
102	87	2647003901087
102	88	2647004001088
102	89	2647004101089
102	32	2647004201032
102	29	2647004301029
102	33	2647004401033
102	96	2647004501096
102	35	2647004601035
102	102	2647004701102
102	120	2647004801120
102	13	2647004901013
102	39	2647005001039
102	17	2647005101017
102	38	2647005201038
102	43	2647005301043
102	48	2647005401048
102	42	2647005501042
102	44	2647005601044
102	23	2647005701023
102	135	2647005801135
102	45	2647005901045
102	83	2647006001083
102	98	2647006101098
102	93	2647006201093
102	12	2647006301012
102	97	2647006401097
102	68	2647006501068
102	122	2647006601122
102	69	2647006701069
102	41	2647006801041
102	72	2647006901072
102	31	2647007001031
102	76	2647007101076
102	71	2647007201071
102	74	2647007301074
102	73	2647007401073
102	19	2647007501019
102	18	2647007601018
102	14	2647007701014
102	15	2647007801015
102	16	2647007901016
102	79	2647008001079
102	11	2647008101011
102	80	2647008201080
102	34	2647008301034
102	46	2647008401046
102	37	2647008501037
102	90	2647008601090
102	10	2647008701010
102	85	2647008801085
102	36	2647008901036
102	78	2647009001078
102	92	2647009101092
102	91	2647009201091
102	119	2647009301119
102	86	2647009401086
102	136	2647009501136
102	21	2647009601021
102	84	2647009701084
102	121	2647009801121
120	30	2649009901030
120	82	26490010001082
120	75	26490010101075
120	47	26490010201047
120	110	26490010301110
120	26	26490010401026
120	77	26490010501077
120	20	26490010601020
120	94	26490010701094
120	24	26490010801024
120	40	26490010901040
120	28	26490011001028
120	95	26490011101095
120	53	26490011201053
120	25	26490011301025
120	49	26490011401049
120	51	26490011501051
120	52	26490011601052
120	50	26490011701050
120	54	26490011801054
120	55	26490011901055
120	57	26490012001057
120	56	26490012101056
120	58	26490012201058
120	59	26490012301059
120	60	26490012401060
120	61	26490012501061
120	62	26490012601062
120	63	26490012701063
120	64	26490012801064
120	66	26490012901066
120	65	26490013001065
120	107	26490013101107
120	67	26490013201067
120	134	26490013301134
120	22	26490013401022
120	27	26490013501027
120	103	26490013601103
120	87	26490013701087
120	88	26490013801088
120	89	26490013901089
120	32	26490014001032
120	29	26490014101029
120	33	26490014201033
120	96	26490014301096
120	35	26490014401035
120	102	26490014501102
120	120	26490014601120
120	13	26490014701013
120	39	26490014801039
120	17	26490014901017
120	38	26490015001038
120	43	26490015101043
120	48	26490015201048
120	42	26490015301042
120	44	26490015401044
120	23	26490015501023
120	135	26490015601135
120	45	26490015701045
120	83	26490015801083
120	98	26490015901098
120	93	26490016001093
120	12	26490016101012
120	97	26490016201097
120	68	26490016301068
120	122	26490016401122
120	69	26490016501069
120	41	26490016601041
120	72	26490016701072
120	31	26490016801031
120	76	26490016901076
120	71	26490017001071
120	74	26490017101074
120	73	26490017201073
120	19	26490017301019
120	18	26490017401018
120	14	26490017501014
120	15	26490017601015
120	16	26490017701016
120	79	26490017801079
120	11	26490017901011
120	80	26490018001080
120	34	26490018101034
120	46	26490018201046
120	37	26490018301037
120	90	26490018401090
120	10	26490018501010
120	85	26490018601085
120	36	26490018701036
120	78	26490018801078
120	92	26490018901092
120	91	26490019001091
120	119	26490019101119
120	86	26490019201086
120	136	26490019301136
120	21	26490019401021
120	84	26490019501084
120	121	26490019601121
13	30	2627009901030
13	82	26270010001082
13	75	26270010101075
13	47	26270010201047
13	110	26270010301110
13	26	26270010401026
13	77	26270010501077
13	20	26270010601020
13	94	26270010701094
13	24	26270010801024
13	40	26270010901040
13	28	26270011001028
13	95	26270011101095
13	53	26270011201053
13	25	26270011301025
13	49	26270011401049
13	51	26270011501051
13	52	26270011601052
13	50	26270011701050
13	54	26270011801054
13	55	26270011901055
13	57	26270012001057
13	56	26270012101056
13	58	26270012201058
13	59	26270012301059
13	60	26270012401060
13	61	26270012501061
13	62	26270012601062
13	63	26270012701063
13	64	26270012801064
13	66	26270012901066
13	65	26270013001065
13	107	26270013101107
13	67	26270013201067
13	134	26270013301134
13	22	26270013401022
13	27	26270013501027
13	103	26270013601103
13	87	26270013701087
13	88	26270013801088
13	89	26270013901089
13	32	26270014001032
13	29	26270014101029
13	33	26270014201033
13	96	26270014301096
13	35	26270014401035
13	102	26270014501102
13	120	26270014601120
13	13	26270014701013
13	39	26270014801039
13	17	26270014901017
13	38	26270015001038
13	43	26270015101043
13	48	26270015201048
13	42	26270015301042
13	44	26270015401044
13	23	26270015501023
13	135	26270015601135
13	45	26270015701045
13	83	26270015801083
13	98	26270015901098
13	93	26270016001093
13	12	26270016101012
13	97	26270016201097
13	68	26270016301068
13	122	26270016401122
13	69	26270016501069
13	41	26270016601041
13	72	26270016701072
13	31	26270016801031
13	76	26270016901076
13	71	26270017001071
13	74	26270017101074
13	73	26270017201073
13	19	26270017301019
13	18	26270017401018
13	14	26270017501014
13	15	26270017601015
13	16	26270017701016
13	79	26270017801079
13	11	26270017901011
13	80	26270018001080
13	34	26270018101034
13	46	26270018201046
13	37	26270018301037
13	90	26270018401090
13	10	26270018501010
13	85	26270018601085
13	36	26270018701036
13	78	26270018801078
13	92	26270018901092
13	91	26270019001091
13	119	26270019101119
13	86	26270019201086
13	136	26270019301136
13	21	26270019401021
13	84	26270019501084
13	121	26270019601121
39	30	2655000101030
39	82	2655000201082
39	75	2655000301075
39	47	2655000401047
39	110	2655000501110
39	26	2655000601026
39	77	2655000701077
39	20	2655000801020
39	94	2655000901094
39	24	2655001001024
39	40	2655001101040
39	28	2655001201028
39	95	2655001301095
39	53	2655001401053
39	25	2655001501025
39	49	2655001601049
39	51	2655001701051
39	52	2655001801052
39	50	2655001901050
39	54	2655002001054
39	55	2655002101055
39	57	2655002201057
39	56	2655002301056
39	58	2655002401058
39	59	2655002501059
39	60	2655002601060
39	61	2655002701061
39	62	2655002801062
39	63	2655002901063
39	64	2655003001064
39	66	2655003101066
39	65	2655003201065
39	107	2655003301107
39	67	2655003401067
39	134	2655003501134
39	22	2655003601022
39	27	2655003701027
39	103	2655003801103
39	87	2655003901087
39	88	2655004001088
39	89	2655004101089
39	32	2655004201032
39	29	2655004301029
39	33	2655004401033
39	96	2655004501096
39	35	2655004601035
39	102	2655004701102
39	120	2655004801120
39	13	2655004901013
39	39	2655005001039
39	17	2655005101017
39	38	2655005201038
39	43	2655005301043
39	48	2655005401048
39	42	2655005501042
39	44	2655005601044
39	23	2655005701023
39	135	2655005801135
39	45	2655005901045
39	83	2655006001083
39	98	2655006101098
39	93	2655006201093
39	12	2655006301012
39	97	2655006401097
39	68	2655006501068
39	122	2655006601122
39	69	2655006701069
39	41	2655006801041
39	72	2655006901072
39	31	2655007001031
39	76	2655007101076
39	71	2655007201071
39	74	2655007301074
39	73	2655007401073
39	19	2655007501019
39	18	2655007601018
39	14	2655007701014
39	15	2655007801015
39	16	2655007901016
39	79	2655008001079
39	11	2655008101011
39	80	2655008201080
39	34	2655008301034
39	46	2655008401046
39	37	2655008501037
39	90	2655008601090
39	10	2655008701010
39	85	2655008801085
39	36	2655008901036
39	78	2655009001078
39	92	2655009101092
39	91	2655009201091
39	119	2655009301119
39	86	2655009401086
39	136	2655009501136
39	21	2655009601021
39	84	2655009701084
39	121	2655009801121
17	30	2652000101030
17	82	2652000201082
17	75	2652000301075
17	47	2652000401047
17	110	2652000501110
17	26	2652000601026
17	77	2652000701077
17	20	2652000801020
17	94	2652000901094
17	24	2652001001024
17	40	2652001101040
17	28	2652001201028
17	95	2652001301095
17	53	2652001401053
17	25	2652001501025
17	49	2652001601049
17	51	2652001701051
17	52	2652001801052
17	50	2652001901050
17	54	2652002001054
17	55	2652002101055
17	57	2652002201057
17	56	2652002301056
17	58	2652002401058
17	59	2652002501059
17	60	2652002601060
17	61	2652002701061
17	62	2652002801062
17	63	2652002901063
17	64	2652003001064
17	66	2652003101066
17	65	2652003201065
17	107	2652003301107
17	67	2652003401067
17	134	2652003501134
17	22	2652003601022
17	27	2652003701027
17	103	2652003801103
17	87	2652003901087
17	88	2652004001088
17	89	2652004101089
17	32	2652004201032
17	29	2652004301029
17	33	2652004401033
17	96	2652004501096
17	35	2652004601035
17	102	2652004701102
17	120	2652004801120
17	13	2652004901013
17	39	2652005001039
17	17	2652005101017
17	38	2652005201038
17	43	2652005301043
17	48	2652005401048
17	42	2652005501042
17	44	2652005601044
17	23	2652005701023
17	135	2652005801135
17	45	2652005901045
17	83	2652006001083
17	98	2652006101098
17	93	2652006201093
17	12	2652006301012
17	97	2652006401097
17	68	2652006501068
17	122	2652006601122
17	69	2652006701069
17	41	2652006801041
17	72	2652006901072
17	31	2652007001031
17	76	2652007101076
17	71	2652007201071
17	74	2652007301074
17	73	2652007401073
17	19	2652007501019
17	18	2652007601018
17	14	2652007701014
17	15	2652007801015
17	16	2652007901016
17	79	2652008001079
17	11	2652008101011
17	80	2652008201080
17	34	2652008301034
17	46	2652008401046
17	37	2652008501037
17	90	2652008601090
17	10	2652008701010
17	85	2652008801085
17	36	2652008901036
17	78	2652009001078
17	92	2652009101092
17	91	2652009201091
17	119	2652009301119
17	86	2652009401086
17	136	2652009501136
17	21	2652009601021
17	84	2652009701084
17	121	2652009801121
38	30	2653200101030
38	82	2653200201082
38	75	2653200301075
38	47	2653200401047
38	110	2653200501110
38	26	2653200601026
38	77	2653200701077
38	20	2653200801020
38	94	2653200901094
38	24	2653201001024
38	40	2653201101040
38	28	2653201201028
38	95	2653201301095
38	53	2653201401053
38	25	2653201501025
38	49	2653201601049
38	51	2653201701051
38	52	2653201801052
38	50	2653201901050
38	54	2653202001054
38	55	2653202101055
38	57	2653202201057
38	56	2653202301056
38	58	2653202401058
38	59	2653202501059
38	60	2653202601060
38	61	2653202701061
38	62	2653202801062
38	63	2653202901063
38	64	2653203001064
38	66	2653203101066
38	65	2653203201065
38	107	2653203301107
38	67	2653203401067
38	134	2653203501134
38	22	2653203601022
38	27	2653203701027
38	103	2653203801103
38	87	2653203901087
38	88	2653204001088
38	89	2653204101089
38	32	2653204201032
38	29	2653204301029
38	33	2653204401033
38	96	2653204501096
38	35	2653204601035
38	102	2653204701102
38	120	2653204801120
38	13	2653204901013
38	39	2653205001039
38	17	2653205101017
38	38	2653205201038
38	43	2653205301043
38	48	2653205401048
38	42	2653205501042
38	44	2653205601044
38	23	2653205701023
38	135	2653205801135
38	45	2653205901045
38	83	2653206001083
38	98	2653206101098
38	93	2653206201093
38	12	2653206301012
38	97	2653206401097
38	68	2653206501068
38	122	2653206601122
38	69	2653206701069
38	41	2653206801041
38	72	2653206901072
38	31	2653207001031
38	76	2653207101076
38	71	2653207201071
38	74	2653207301074
38	73	2653207401073
38	19	2653207501019
38	18	2653207601018
38	14	2653207701014
38	15	2653207801015
38	16	2653207901016
38	79	2653208001079
38	11	2653208101011
38	80	2653208201080
38	34	2653208301034
38	46	2653208401046
38	37	2653208501037
38	90	2653208601090
38	10	2653208701010
38	85	2653208801085
38	36	2653208901036
38	78	2653209001078
38	92	2653209101092
38	91	2653209201091
38	119	2653209301119
38	86	2653209401086
38	136	2653209501136
38	21	2653209601021
38	84	2653209701084
38	121	2653209801121
43	30	2655200101030
43	82	2655200201082
43	75	2655200301075
43	47	2655200401047
43	110	2655200501110
43	26	2655200601026
43	77	2655200701077
43	20	2655200801020
43	94	2655200901094
43	24	2655201001024
43	40	2655201101040
43	28	2655201201028
43	95	2655201301095
43	53	2655201401053
43	25	2655201501025
43	49	2655201601049
43	51	2655201701051
43	52	2655201801052
43	50	2655201901050
43	54	2655202001054
43	55	2655202101055
43	57	2655202201057
43	56	2655202301056
43	58	2655202401058
43	59	2655202501059
43	60	2655202601060
43	61	2655202701061
43	62	2655202801062
43	63	2655202901063
43	64	2655203001064
43	66	2655203101066
43	65	2655203201065
43	107	2655203301107
43	67	2655203401067
43	134	2655203501134
43	22	2655203601022
43	27	2655203701027
43	103	2655203801103
43	87	2655203901087
43	88	2655204001088
43	89	2655204101089
43	32	2655204201032
43	29	2655204301029
43	33	2655204401033
43	96	2655204501096
43	35	2655204601035
43	102	2655204701102
43	120	2655204801120
43	13	2655204901013
43	39	2655205001039
43	17	2655205101017
43	38	2655205201038
43	43	2655205301043
43	48	2655205401048
43	42	2655205501042
43	44	2655205601044
43	23	2655205701023
43	135	2655205801135
43	45	2655205901045
43	83	2655206001083
43	98	2655206101098
43	93	2655206201093
43	12	2655206301012
43	97	2655206401097
43	68	2655206501068
43	122	2655206601122
43	69	2655206701069
43	41	2655206801041
43	72	2655206901072
43	31	2655207001031
43	76	2655207101076
43	71	2655207201071
43	74	2655207301074
43	73	2655207401073
43	19	2655207501019
43	18	2655207601018
43	14	2655207701014
43	15	2655207801015
43	16	2655207901016
43	79	2655208001079
43	11	2655208101011
43	80	2655208201080
43	34	2655208301034
43	46	2655208401046
43	37	2655208501037
43	90	2655208601090
43	10	2655208701010
43	85	2655208801085
43	36	2655208901036
43	78	2655209001078
43	92	2655209101092
43	91	2655209201091
43	119	2655209301119
43	86	2655209401086
43	136	2655209501136
43	21	2655209601021
43	84	2655209701084
43	121	2655209801121
48	30	2657500101030
48	82	2657500201082
48	75	2657500301075
48	47	2657500401047
48	110	2657500501110
48	26	2657500601026
48	77	2657500701077
48	20	2657500801020
48	94	2657500901094
48	24	2657501001024
48	40	2657501101040
48	28	2657501201028
48	95	2657501301095
48	53	2657501401053
48	25	2657501501025
48	49	2657501601049
48	51	2657501701051
48	52	2657501801052
48	50	2657501901050
48	54	2657502001054
48	55	2657502101055
48	57	2657502201057
48	56	2657502301056
48	58	2657502401058
48	59	2657502501059
48	60	2657502601060
48	61	2657502701061
48	62	2657502801062
48	63	2657502901063
48	64	2657503001064
48	66	2657503101066
48	65	2657503201065
48	107	2657503301107
48	67	2657503401067
48	134	2657503501134
48	22	2657503601022
48	27	2657503701027
48	103	2657503801103
48	87	2657503901087
48	88	2657504001088
48	89	2657504101089
48	32	2657504201032
48	29	2657504301029
48	33	2657504401033
48	96	2657504501096
48	35	2657504601035
48	102	2657504701102
48	120	2657504801120
48	13	2657504901013
48	39	2657505001039
48	17	2657505101017
48	38	2657505201038
48	43	2657505301043
48	48	2657505401048
48	42	2657505501042
48	44	2657505601044
48	23	2657505701023
48	135	2657505801135
48	45	2657505901045
48	83	2657506001083
48	98	2657506101098
48	93	2657506201093
48	12	2657506301012
48	97	2657506401097
48	68	2657506501068
48	122	2657506601122
48	69	2657506701069
48	41	2657506801041
48	72	2657506901072
48	31	2657507001031
48	76	2657507101076
48	71	2657507201071
48	74	2657507301074
48	73	2657507401073
48	19	2657507501019
48	18	2657507601018
48	14	2657507701014
48	15	2657507801015
48	16	2657507901016
48	79	2657508001079
48	11	2657508101011
48	80	2657508201080
48	34	2657508301034
48	46	2657508401046
48	37	2657508501037
48	90	2657508601090
48	10	2657508701010
48	85	2657508801085
48	36	2657508901036
48	78	2657509001078
48	92	2657509101092
48	91	2657509201091
48	119	2657509301119
48	86	2657509401086
48	136	2657509501136
48	21	2657509601021
48	84	2657509701084
48	121	2657509801121
42	30	2657000101030
42	82	2657000201082
42	75	2657000301075
42	47	2657000401047
42	110	2657000501110
42	26	2657000601026
42	77	2657000701077
42	20	2657000801020
42	94	2657000901094
42	24	2657001001024
42	40	2657001101040
42	28	2657001201028
42	95	2657001301095
42	53	2657001401053
42	25	2657001501025
42	49	2657001601049
42	51	2657001701051
42	52	2657001801052
42	50	2657001901050
42	54	2657002001054
42	55	2657002101055
42	57	2657002201057
42	56	2657002301056
42	58	2657002401058
42	59	2657002501059
42	60	2657002601060
42	61	2657002701061
42	62	2657002801062
42	63	2657002901063
42	64	2657003001064
42	66	2657003101066
42	65	2657003201065
42	107	2657003301107
42	67	2657003401067
42	134	2657003501134
42	22	2657003601022
42	27	2657003701027
42	103	2657003801103
42	87	2657003901087
42	88	2657004001088
42	89	2657004101089
42	32	2657004201032
42	29	2657004301029
42	33	2657004401033
42	96	2657004501096
42	35	2657004601035
42	102	2657004701102
42	120	2657004801120
42	13	2657004901013
42	39	2657005001039
42	17	2657005101017
42	38	2657005201038
42	43	2657005301043
42	48	2657005401048
42	42	2657005501042
42	44	2657005601044
42	23	2657005701023
42	135	2657005801135
42	45	2657005901045
42	83	2657006001083
42	98	2657006101098
42	93	2657006201093
42	12	2657006301012
42	97	2657006401097
42	68	2657006501068
42	122	2657006601122
42	69	2657006701069
42	41	2657006801041
42	72	2657006901072
42	31	2657007001031
42	76	2657007101076
42	71	2657007201071
42	74	2657007301074
42	73	2657007401073
42	19	2657007501019
42	18	2657007601018
42	14	2657007701014
42	15	2657007801015
42	16	2657007901016
42	79	2657008001079
42	11	2657008101011
42	80	2657008201080
42	34	2657008301034
42	46	2657008401046
42	37	2657008501037
42	90	2657008601090
42	10	2657008701010
42	85	2657008801085
42	36	2657008901036
42	78	2657009001078
42	92	2657009101092
42	91	2657009201091
42	119	2657009301119
42	86	2657009401086
42	136	2657009501136
42	21	2657009601021
42	84	2657009701084
42	121	2657009801121
44	30	2662000101030
44	82	2662000201082
44	75	2662000301075
44	47	2662000401047
44	110	2662000501110
44	26	2662000601026
44	77	2662000701077
44	20	2662000801020
44	94	2662000901094
44	24	2662001001024
44	40	2662001101040
44	28	2662001201028
44	95	2662001301095
44	53	2662001401053
44	25	2662001501025
44	49	2662001601049
44	51	2662001701051
44	52	2662001801052
44	50	2662001901050
44	54	2662002001054
44	55	2662002101055
44	57	2662002201057
44	56	2662002301056
44	58	2662002401058
44	59	2662002501059
44	60	2662002601060
44	61	2662002701061
44	62	2662002801062
44	63	2662002901063
44	64	2662003001064
44	66	2662003101066
44	65	2662003201065
44	107	2662003301107
44	67	2662003401067
44	134	2662003501134
44	22	2662003601022
44	27	2662003701027
44	103	2662003801103
44	87	2662003901087
44	88	2662004001088
44	89	2662004101089
44	32	2662004201032
44	29	2662004301029
44	33	2662004401033
44	96	2662004501096
44	35	2662004601035
44	102	2662004701102
44	120	2662004801120
44	13	2662004901013
44	39	2662005001039
44	17	2662005101017
44	38	2662005201038
44	43	2662005301043
44	48	2662005401048
44	42	2662005501042
44	44	2662005601044
44	23	2662005701023
44	135	2662005801135
44	45	2662005901045
44	83	2662006001083
44	98	2662006101098
44	93	2662006201093
44	12	2662006301012
44	97	2662006401097
44	68	2662006501068
44	122	2662006601122
44	69	2662006701069
44	41	2662006801041
44	72	2662006901072
44	31	2662007001031
44	76	2662007101076
44	71	2662007201071
44	74	2662007301074
44	73	2662007401073
44	19	2662007501019
44	18	2662007601018
44	14	2662007701014
44	15	2662007801015
44	16	2662007901016
44	79	2662008001079
44	11	2662008101011
44	80	2662008201080
44	34	2662008301034
44	46	2662008401046
44	37	2662008501037
44	90	2662008601090
44	10	2662008701010
44	85	2662008801085
44	36	2662008901036
44	78	2662009001078
44	92	2662009101092
44	91	2662009201091
44	119	2662009301119
44	86	2662009401086
44	136	2662009501136
44	21	2662009601021
44	84	2662009701084
44	121	2662009801121
23	30	2662200101030
23	82	2662200201082
23	75	2662200301075
23	47	2662200401047
23	110	2662200501110
23	26	2662200601026
23	77	2662200701077
23	20	2662200801020
23	94	2662200901094
23	24	2662201001024
23	40	2662201101040
23	28	2662201201028
23	95	2662201301095
23	53	2662201401053
23	25	2662201501025
23	49	2662201601049
23	51	2662201701051
23	52	2662201801052
23	50	2662201901050
23	54	2662202001054
23	55	2662202101055
23	57	2662202201057
23	56	2662202301056
23	58	2662202401058
23	59	2662202501059
23	60	2662202601060
23	61	2662202701061
23	62	2662202801062
23	63	2662202901063
23	64	2662203001064
23	66	2662203101066
23	65	2662203201065
23	107	2662203301107
23	67	2662203401067
23	134	2662203501134
23	22	2662203601022
23	27	2662203701027
23	103	2662203801103
23	87	2662203901087
23	88	2662204001088
23	89	2662204101089
23	32	2662204201032
23	29	2662204301029
23	33	2662204401033
23	96	2662204501096
23	35	2662204601035
23	102	2662204701102
23	120	2662204801120
23	13	2662204901013
23	39	2662205001039
23	17	2662205101017
23	38	2662205201038
23	43	2662205301043
23	48	2662205401048
23	42	2662205501042
23	44	2662205601044
23	23	2662205701023
23	135	2662205801135
23	45	2662205901045
23	83	2662206001083
23	98	2662206101098
23	93	2662206201093
23	12	2662206301012
23	97	2662206401097
23	68	2662206501068
23	122	2662206601122
23	69	2662206701069
23	41	2662206801041
23	72	2662206901072
23	31	2662207001031
23	76	2662207101076
23	71	2662207201071
23	74	2662207301074
23	73	2662207401073
23	19	2662207501019
23	18	2662207601018
23	14	2662207701014
23	15	2662207801015
23	16	2662207901016
23	79	2662208001079
23	11	2662208101011
23	80	2662208201080
23	34	2662208301034
23	46	2662208401046
23	37	2662208501037
23	90	2662208601090
23	10	2662208701010
23	85	2662208801085
23	36	2662208901036
23	78	2662209001078
23	92	2662209101092
23	91	2662209201091
23	119	2662209301119
23	86	2662209401086
23	136	2662209501136
23	21	2662209601021
23	84	2662209701084
23	121	2662209801121
135	30	2664660101030
135	82	2664660201082
135	75	2664660301075
135	47	2664660401047
135	110	2664660501110
135	26	2664660601026
135	77	2664660701077
135	20	2664660801020
135	94	2664660901094
135	24	2664661001024
135	40	2664661101040
135	28	2664661201028
135	95	2664661301095
135	53	2664661401053
135	25	2664661501025
135	49	2664661601049
135	51	2664661701051
135	52	2664661801052
135	50	2664661901050
135	54	2664662001054
135	55	2664662101055
135	57	2664662201057
135	56	2664662301056
135	58	2664662401058
135	59	2664662501059
135	60	2664662601060
135	61	2664662701061
135	62	2664662801062
135	63	2664662901063
135	64	2664663001064
135	66	2664663101066
135	65	2664663201065
135	107	2664663301107
135	67	2664663401067
135	134	2664663501134
135	22	2664663601022
135	27	2664663701027
135	103	2664663801103
135	87	2664663901087
135	88	2664664001088
135	89	2664664101089
135	32	2664664201032
135	29	2664664301029
135	33	2664664401033
135	96	2664664501096
135	35	2664664601035
135	102	2664664701102
135	120	2664664801120
135	13	2664664901013
135	39	2664665001039
135	17	2664665101017
135	38	2664665201038
135	43	2664665301043
135	48	2664665401048
135	42	2664665501042
135	44	2664665601044
135	23	2664665701023
135	135	2664665801135
135	45	2664665901045
135	83	2664666001083
135	98	2664666101098
135	93	2664666201093
135	12	2664666301012
135	97	2664666401097
135	68	2664666501068
135	122	2664666601122
135	69	2664666701069
135	41	2664666801041
135	72	2664666901072
135	31	2664667001031
135	76	2664667101076
135	71	2664667201071
135	74	2664667301074
135	73	2664667401073
135	19	2664667501019
135	18	2664667601018
135	14	2664667701014
135	15	2664667801015
135	16	2664667901016
135	79	2664668001079
135	11	2664668101011
135	80	2664668201080
135	34	2664668301034
135	46	2664668401046
135	37	2664668501037
135	90	2664668601090
135	10	2664668701010
135	85	2664668801085
135	36	2664668901036
135	78	2664669001078
135	92	2664669101092
135	91	2664669201091
135	119	2664669301119
135	86	2664669401086
135	136	2664669501136
135	21	2664669601021
135	84	2664669701084
135	121	2664669801121
45	30	2666600101030
45	82	2666600201082
45	75	2666600301075
45	47	2666600401047
45	110	2666600501110
45	26	2666600601026
45	77	2666600701077
45	20	2666600801020
45	94	2666600901094
45	24	2666601001024
45	40	2666601101040
45	28	2666601201028
45	95	2666601301095
45	53	2666601401053
45	25	2666601501025
45	49	2666601601049
45	51	2666601701051
45	52	2666601801052
45	50	2666601901050
45	54	2666602001054
45	55	2666602101055
45	57	2666602201057
45	56	2666602301056
45	58	2666602401058
45	59	2666602501059
45	60	2666602601060
45	61	2666602701061
45	62	2666602801062
45	63	2666602901063
45	64	2666603001064
45	66	2666603101066
45	65	2666603201065
45	107	2666603301107
45	67	2666603401067
45	134	2666603501134
45	22	2666603601022
45	27	2666603701027
45	103	2666603801103
45	87	2666603901087
45	88	2666604001088
45	89	2666604101089
45	32	2666604201032
45	29	2666604301029
45	33	2666604401033
45	96	2666604501096
45	35	2666604601035
45	102	2666604701102
45	120	2666604801120
45	13	2666604901013
45	39	2666605001039
45	17	2666605101017
45	38	2666605201038
45	43	2666605301043
45	48	2666605401048
45	42	2666605501042
45	44	2666605601044
45	23	2666605701023
45	135	2666605801135
45	45	2666605901045
45	83	2666606001083
45	98	2666606101098
45	93	2666606201093
45	12	2666606301012
45	97	2666606401097
45	68	2666606501068
45	122	2666606601122
45	69	2666606701069
45	41	2666606801041
45	72	2666606901072
45	31	2666607001031
45	76	2666607101076
45	71	2666607201071
45	74	2666607301074
45	73	2666607401073
45	19	2666607501019
45	18	2666607601018
45	14	2666607701014
45	15	2666607801015
45	16	2666607901016
45	79	2666608001079
45	11	2666608101011
45	80	2666608201080
45	34	2666608301034
45	46	2666608401046
45	37	2666608501037
45	90	2666608601090
45	10	2666608701010
45	85	2666608801085
45	36	2666608901036
45	78	2666609001078
45	92	2666609101092
45	91	2666609201091
45	119	2666609301119
45	86	2666609401086
45	136	2666609501136
45	21	2666609601021
45	84	2666609701084
45	121	2666609801121
83	30	2666900101030
83	82	2666900201082
83	75	2666900301075
83	47	2666900401047
83	110	2666900501110
83	26	2666900601026
83	77	2666900701077
83	20	2666900801020
83	94	2666900901094
83	24	2666901001024
83	40	2666901101040
83	28	2666901201028
83	95	2666901301095
83	53	2666901401053
83	25	2666901501025
83	49	2666901601049
83	51	2666901701051
83	52	2666901801052
83	50	2666901901050
83	54	2666902001054
83	55	2666902101055
83	57	2666902201057
83	56	2666902301056
83	58	2666902401058
83	59	2666902501059
83	60	2666902601060
83	61	2666902701061
83	62	2666902801062
83	63	2666902901063
83	64	2666903001064
83	66	2666903101066
83	65	2666903201065
83	107	2666903301107
83	67	2666903401067
83	134	2666903501134
83	22	2666903601022
83	27	2666903701027
83	103	2666903801103
83	87	2666903901087
83	88	2666904001088
83	89	2666904101089
83	32	2666904201032
83	29	2666904301029
83	33	2666904401033
83	96	2666904501096
83	35	2666904601035
83	102	2666904701102
83	120	2666904801120
83	13	2666904901013
83	39	2666905001039
83	17	2666905101017
83	38	2666905201038
83	43	2666905301043
83	48	2666905401048
83	42	2666905501042
83	44	2666905601044
83	23	2666905701023
83	135	2666905801135
83	45	2666905901045
83	83	2666906001083
83	98	2666906101098
83	93	2666906201093
83	12	2666906301012
83	97	2666906401097
83	68	2666906501068
83	122	2666906601122
83	69	2666906701069
83	41	2666906801041
83	72	2666906901072
83	31	2666907001031
83	76	2666907101076
83	71	2666907201071
83	74	2666907301074
83	73	2666907401073
83	19	2666907501019
83	18	2666907601018
83	14	2666907701014
83	15	2666907801015
83	16	2666907901016
83	79	2666908001079
83	11	2666908101011
83	80	2666908201080
83	34	2666908301034
83	46	2666908401046
83	37	2666908501037
83	90	2666908601090
83	10	2666908701010
83	85	2666908801085
83	36	2666908901036
83	78	2666909001078
83	92	2666909101092
83	91	2666909201091
83	119	2666909301119
83	86	2666909401086
83	136	2666909501136
83	21	2666909601021
83	84	2666909701084
83	121	2666909801121
98	30	2667000101030
98	82	2667000201082
98	75	2667000301075
98	47	2667000401047
98	110	2667000501110
98	26	2667000601026
98	77	2667000701077
98	20	2667000801020
98	94	2667000901094
98	24	2667001001024
98	40	2667001101040
98	28	2667001201028
98	95	2667001301095
98	53	2667001401053
98	25	2667001501025
98	49	2667001601049
98	51	2667001701051
98	52	2667001801052
98	50	2667001901050
98	54	2667002001054
98	55	2667002101055
98	57	2667002201057
98	56	2667002301056
98	58	2667002401058
98	59	2667002501059
98	60	2667002601060
98	61	2667002701061
98	62	2667002801062
98	63	2667002901063
98	64	2667003001064
98	66	2667003101066
98	65	2667003201065
98	107	2667003301107
98	67	2667003401067
98	134	2667003501134
98	22	2667003601022
98	27	2667003701027
98	103	2667003801103
98	87	2667003901087
98	88	2667004001088
98	89	2667004101089
98	32	2667004201032
98	29	2667004301029
98	33	2667004401033
98	96	2667004501096
98	35	2667004601035
98	102	2667004701102
98	120	2667004801120
98	13	2667004901013
98	39	2667005001039
98	17	2667005101017
98	38	2667005201038
98	43	2667005301043
98	48	2667005401048
98	42	2667005501042
98	44	2667005601044
98	23	2667005701023
98	135	2667005801135
98	45	2667005901045
98	83	2667006001083
98	98	2667006101098
98	93	2667006201093
98	12	2667006301012
98	97	2667006401097
98	68	2667006501068
98	122	2667006601122
98	69	2667006701069
98	41	2667006801041
98	72	2667006901072
98	31	2667007001031
98	76	2667007101076
98	71	2667007201071
98	74	2667007301074
98	73	2667007401073
98	19	2667007501019
98	18	2667007601018
98	14	2667007701014
98	15	2667007801015
98	16	2667007901016
98	79	2667008001079
98	11	2667008101011
98	80	2667008201080
98	34	2667008301034
98	46	2667008401046
98	37	2667008501037
98	90	2667008601090
98	10	2667008701010
98	85	2667008801085
98	36	2667008901036
98	78	2667009001078
98	92	2667009101092
98	91	2667009201091
98	119	2667009301119
98	86	2667009401086
98	136	2667009501136
98	21	2667009601021
98	84	2667009701084
98	121	2667009801121
93	30	2668700101030
93	82	2668700201082
93	75	2668700301075
93	47	2668700401047
93	110	2668700501110
93	26	2668700601026
93	77	2668700701077
93	20	2668700801020
93	94	2668700901094
93	24	2668701001024
93	40	2668701101040
93	28	2668701201028
93	95	2668701301095
93	53	2668701401053
93	25	2668701501025
93	49	2668701601049
93	51	2668701701051
93	52	2668701801052
93	50	2668701901050
93	54	2668702001054
93	55	2668702101055
93	57	2668702201057
93	56	2668702301056
93	58	2668702401058
93	59	2668702501059
93	60	2668702601060
93	61	2668702701061
93	62	2668702801062
93	63	2668702901063
93	64	2668703001064
93	66	2668703101066
93	65	2668703201065
93	107	2668703301107
93	67	2668703401067
93	134	2668703501134
93	22	2668703601022
93	27	2668703701027
93	103	2668703801103
93	87	2668703901087
93	88	2668704001088
93	89	2668704101089
93	32	2668704201032
93	29	2668704301029
93	33	2668704401033
93	96	2668704501096
93	35	2668704601035
93	102	2668704701102
93	120	2668704801120
93	13	2668704901013
93	39	2668705001039
93	17	2668705101017
93	38	2668705201038
93	43	2668705301043
93	48	2668705401048
93	42	2668705501042
93	44	2668705601044
93	23	2668705701023
93	135	2668705801135
93	45	2668705901045
93	83	2668706001083
93	98	2668706101098
93	93	2668706201093
93	12	2668706301012
93	97	2668706401097
93	68	2668706501068
93	122	2668706601122
93	69	2668706701069
93	41	2668706801041
93	72	2668706901072
93	31	2668707001031
93	76	2668707101076
93	71	2668707201071
93	74	2668707301074
93	73	2668707401073
93	19	2668707501019
93	18	2668707601018
93	14	2668707701014
93	15	2668707801015
93	16	2668707901016
93	79	2668708001079
93	11	2668708101011
93	80	2668708201080
93	34	2668708301034
93	46	2668708401046
93	37	2668708501037
93	90	2668708601090
93	10	2668708701010
93	85	2668708801085
93	36	2668708901036
93	78	2668709001078
93	92	2668709101092
93	91	2668709201091
93	119	2668709301119
93	86	2668709401086
93	136	2668709501136
93	21	2668709601021
93	84	2668709701084
93	121	2668709801121
12	30	2663900101030
12	82	2663900201082
12	75	2663900301075
12	47	2663900401047
12	110	2663900501110
12	26	2663900601026
12	77	2663900701077
12	20	2663900801020
12	94	2663900901094
12	24	2663901001024
12	40	2663901101040
12	28	2663901201028
12	95	2663901301095
12	53	2663901401053
12	25	2663901501025
12	49	2663901601049
12	51	2663901701051
12	52	2663901801052
12	50	2663901901050
12	54	2663902001054
12	55	2663902101055
12	57	2663902201057
12	56	2663902301056
12	58	2663902401058
12	59	2663902501059
12	60	2663902601060
12	61	2663902701061
12	62	2663902801062
12	63	2663902901063
12	64	2663903001064
12	66	2663903101066
12	65	2663903201065
12	107	2663903301107
12	67	2663903401067
12	134	2663903501134
12	22	2663903601022
12	27	2663903701027
12	103	2663903801103
12	87	2663903901087
12	88	2663904001088
12	89	2663904101089
12	32	2663904201032
12	29	2663904301029
12	33	2663904401033
12	96	2663904501096
12	35	2663904601035
12	102	2663904701102
12	120	2663904801120
12	13	2663904901013
12	39	2663905001039
12	17	2663905101017
12	38	2663905201038
12	43	2663905301043
12	48	2663905401048
12	42	2663905501042
12	44	2663905601044
12	23	2663905701023
12	135	2663905801135
12	45	2663905901045
12	83	2663906001083
12	98	2663906101098
12	93	2663906201093
12	12	2663906301012
12	97	2663906401097
12	68	2663906501068
12	122	2663906601122
12	69	2663906701069
12	41	2663906801041
12	72	2663906901072
12	31	2663907001031
12	76	2663907101076
12	71	2663907201071
12	74	2663907301074
12	73	2663907401073
12	19	2663907501019
12	18	2663907601018
12	14	2663907701014
12	15	2663907801015
12	16	2663907901016
12	79	2663908001079
12	11	2663908101011
12	80	2663908201080
12	34	2663908301034
12	46	2663908401046
12	37	2663908501037
12	90	2663908601090
12	10	2663908701010
12	85	2663908801085
12	36	2663908901036
12	78	2663909001078
12	92	2663909101092
12	91	2663909201091
12	119	2663909301119
12	86	2663909401086
12	136	2663909501136
12	21	2663909601021
12	84	2663909701084
12	121	2663909801121
97	30	2669000101030
97	82	2669000201082
97	75	2669000301075
97	47	2669000401047
97	110	2669000501110
97	26	2669000601026
97	77	2669000701077
97	20	2669000801020
97	94	2669000901094
97	24	2669001001024
97	40	2669001101040
97	28	2669001201028
97	95	2669001301095
97	53	2669001401053
97	25	2669001501025
97	49	2669001601049
97	51	2669001701051
97	52	2669001801052
97	50	2669001901050
97	54	2669002001054
97	55	2669002101055
97	57	2669002201057
97	56	2669002301056
97	58	2669002401058
97	59	2669002501059
97	60	2669002601060
97	61	2669002701061
97	62	2669002801062
97	63	2669002901063
97	64	2669003001064
97	66	2669003101066
97	65	2669003201065
97	107	2669003301107
97	67	2669003401067
97	134	2669003501134
97	22	2669003601022
97	27	2669003701027
97	103	2669003801103
97	87	2669003901087
97	88	2669004001088
97	89	2669004101089
97	32	2669004201032
97	29	2669004301029
97	33	2669004401033
97	96	2669004501096
97	35	2669004601035
97	102	2669004701102
97	120	2669004801120
97	13	2669004901013
97	39	2669005001039
97	17	2669005101017
97	38	2669005201038
97	43	2669005301043
97	48	2669005401048
97	42	2669005501042
97	44	2669005601044
97	23	2669005701023
97	135	2669005801135
97	45	2669005901045
97	83	2669006001083
97	98	2669006101098
97	93	2669006201093
97	12	2669006301012
97	97	2669006401097
97	68	2669006501068
97	122	2669006601122
97	69	2669006701069
97	41	2669006801041
97	72	2669006901072
97	31	2669007001031
97	76	2669007101076
97	71	2669007201071
97	74	2669007301074
97	73	2669007401073
97	19	2669007501019
97	18	2669007601018
97	14	2669007701014
97	15	2669007801015
97	16	2669007901016
97	79	2669008001079
97	11	2669008101011
97	80	2669008201080
97	34	2669008301034
97	46	2669008401046
97	37	2669008501037
97	90	2669008601090
97	10	2669008701010
97	85	2669008801085
97	36	2669008901036
97	78	2669009001078
97	92	2669009101092
97	91	2669009201091
97	119	2669009301119
97	86	2669009401086
97	136	2669009501136
97	21	2669009601021
97	84	2669009701084
97	121	2669009801121
68	30	2670000101030
68	82	2670000201082
68	75	2670000301075
68	47	2670000401047
68	110	2670000501110
68	26	2670000601026
68	77	2670000701077
68	20	2670000801020
68	94	2670000901094
68	24	2670001001024
68	40	2670001101040
68	28	2670001201028
68	95	2670001301095
68	53	2670001401053
68	25	2670001501025
68	49	2670001601049
68	51	2670001701051
68	52	2670001801052
68	50	2670001901050
68	54	2670002001054
68	55	2670002101055
68	57	2670002201057
68	56	2670002301056
68	58	2670002401058
68	59	2670002501059
68	60	2670002601060
68	61	2670002701061
68	62	2670002801062
68	63	2670002901063
68	64	2670003001064
68	66	2670003101066
68	65	2670003201065
68	107	2670003301107
68	67	2670003401067
68	134	2670003501134
68	22	2670003601022
68	27	2670003701027
68	103	2670003801103
68	87	2670003901087
68	88	2670004001088
68	89	2670004101089
68	32	2670004201032
68	29	2670004301029
68	33	2670004401033
68	96	2670004501096
68	35	2670004601035
68	102	2670004701102
68	120	2670004801120
68	13	2670004901013
68	39	2670005001039
68	17	2670005101017
68	38	2670005201038
68	43	2670005301043
68	48	2670005401048
68	42	2670005501042
68	44	2670005601044
68	23	2670005701023
68	135	2670005801135
68	45	2670005901045
68	83	2670006001083
68	98	2670006101098
68	93	2670006201093
68	12	2670006301012
68	97	2670006401097
68	68	2670006501068
68	122	2670006601122
68	69	2670006701069
68	41	2670006801041
68	72	2670006901072
68	31	2670007001031
68	76	2670007101076
68	71	2670007201071
68	74	2670007301074
68	73	2670007401073
68	19	2670007501019
68	18	2670007601018
68	14	2670007701014
68	15	2670007801015
68	16	2670007901016
68	79	2670008001079
68	11	2670008101011
68	80	2670008201080
68	34	2670008301034
68	46	2670008401046
68	37	2670008501037
68	90	2670008601090
68	10	2670008701010
68	85	2670008801085
68	36	2670008901036
68	78	2670009001078
68	92	2670009101092
68	91	2670009201091
68	119	2670009301119
68	86	2670009401086
68	136	2670009501136
68	21	2670009601021
68	84	2670009701084
68	121	2670009801121
122	30	2673600101030
122	82	2673600201082
122	75	2673600301075
122	47	2673600401047
122	110	2673600501110
122	26	2673600601026
122	77	2673600701077
122	20	2673600801020
122	94	2673600901094
122	24	2673601001024
122	40	2673601101040
122	28	2673601201028
122	95	2673601301095
122	53	2673601401053
122	25	2673601501025
122	49	2673601601049
122	51	2673601701051
122	52	2673601801052
122	50	2673601901050
122	54	2673602001054
122	55	2673602101055
122	57	2673602201057
122	56	2673602301056
122	58	2673602401058
122	59	2673602501059
122	60	2673602601060
122	61	2673602701061
122	62	2673602801062
122	63	2673602901063
122	64	2673603001064
122	66	2673603101066
122	65	2673603201065
122	107	2673603301107
122	67	2673603401067
122	134	2673603501134
122	22	2673603601022
122	27	2673603701027
122	103	2673603801103
122	87	2673603901087
122	88	2673604001088
122	89	2673604101089
122	32	2673604201032
122	29	2673604301029
122	33	2673604401033
122	96	2673604501096
122	35	2673604601035
122	102	2673604701102
122	120	2673604801120
122	13	2673604901013
122	39	2673605001039
122	17	2673605101017
122	38	2673605201038
122	43	2673605301043
122	48	2673605401048
122	42	2673605501042
122	44	2673605601044
122	23	2673605701023
122	135	2673605801135
122	45	2673605901045
122	83	2673606001083
122	98	2673606101098
122	93	2673606201093
122	12	2673606301012
122	97	2673606401097
122	68	2673606501068
122	122	2673606601122
122	69	2673606701069
122	41	2673606801041
122	72	2673606901072
122	31	2673607001031
122	76	2673607101076
122	71	2673607201071
122	74	2673607301074
122	73	2673607401073
122	19	2673607501019
122	18	2673607601018
122	14	2673607701014
122	15	2673607801015
122	16	2673607901016
122	79	2673608001079
122	11	2673608101011
122	80	2673608201080
122	34	2673608301034
122	46	2673608401046
122	37	2673608501037
122	90	2673608601090
122	10	2673608701010
122	85	2673608801085
122	36	2673608901036
122	78	2673609001078
122	92	2673609101092
122	91	2673609201091
122	119	2673609301119
122	86	2673609401086
122	136	2673609501136
122	21	2673609601021
122	84	2673609701084
122	121	2673609801121
69	30	2675700101030
69	82	2675700201082
69	75	2675700301075
69	47	2675700401047
69	110	2675700501110
69	26	2675700601026
69	77	2675700701077
69	20	2675700801020
69	94	2675700901094
69	24	2675701001024
69	40	2675701101040
69	28	2675701201028
69	95	2675701301095
69	53	2675701401053
69	25	2675701501025
69	49	2675701601049
69	51	2675701701051
69	52	2675701801052
69	50	2675701901050
69	54	2675702001054
69	55	2675702101055
69	57	2675702201057
69	56	2675702301056
69	58	2675702401058
69	59	2675702501059
69	60	2675702601060
69	61	2675702701061
69	62	2675702801062
69	63	2675702901063
69	64	2675703001064
69	66	2675703101066
69	65	2675703201065
69	107	2675703301107
69	67	2675703401067
69	134	2675703501134
69	22	2675703601022
69	27	2675703701027
69	103	2675703801103
69	87	2675703901087
69	88	2675704001088
69	89	2675704101089
69	32	2675704201032
69	29	2675704301029
69	33	2675704401033
69	96	2675704501096
69	35	2675704601035
69	102	2675704701102
69	120	2675704801120
69	13	2675704901013
69	39	2675705001039
69	17	2675705101017
69	38	2675705201038
69	43	2675705301043
69	48	2675705401048
69	42	2675705501042
69	44	2675705601044
69	23	2675705701023
69	135	2675705801135
69	45	2675705901045
69	83	2675706001083
69	98	2675706101098
69	93	2675706201093
69	12	2675706301012
69	97	2675706401097
69	68	2675706501068
69	122	2675706601122
69	69	2675706701069
69	41	2675706801041
69	72	2675706901072
69	31	2675707001031
69	76	2675707101076
69	71	2675707201071
69	74	2675707301074
69	73	2675707401073
69	19	2675707501019
69	18	2675707601018
69	14	2675707701014
69	15	2675707801015
69	16	2675707901016
69	79	2675708001079
69	11	2675708101011
69	80	2675708201080
69	34	2675708301034
69	46	2675708401046
69	37	2675708501037
69	90	2675708601090
69	10	2675708701010
69	85	2675708801085
69	36	2675708901036
69	78	2675709001078
69	92	2675709101092
69	91	2675709201091
69	119	2675709301119
69	86	2675709401086
69	136	2675709501136
69	21	2675709601021
69	84	2675709701084
69	121	2675709801121
41	30	2676000101030
41	82	2676000201082
41	75	2676000301075
41	47	2676000401047
41	110	2676000501110
41	26	2676000601026
41	77	2676000701077
41	20	2676000801020
41	94	2676000901094
41	24	2676001001024
41	40	2676001101040
41	28	2676001201028
41	95	2676001301095
41	53	2676001401053
41	25	2676001501025
41	49	2676001601049
41	51	2676001701051
41	52	2676001801052
41	50	2676001901050
41	54	2676002001054
41	55	2676002101055
41	57	2676002201057
41	56	2676002301056
41	58	2676002401058
41	59	2676002501059
41	60	2676002601060
41	61	2676002701061
41	62	2676002801062
41	63	2676002901063
41	64	2676003001064
41	66	2676003101066
41	65	2676003201065
41	107	2676003301107
41	67	2676003401067
41	134	2676003501134
41	22	2676003601022
41	27	2676003701027
41	103	2676003801103
41	87	2676003901087
41	88	2676004001088
41	89	2676004101089
41	32	2676004201032
41	29	2676004301029
41	33	2676004401033
41	96	2676004501096
41	35	2676004601035
41	102	2676004701102
41	120	2676004801120
41	13	2676004901013
41	39	2676005001039
41	17	2676005101017
41	38	2676005201038
41	43	2676005301043
41	48	2676005401048
41	42	2676005501042
41	44	2676005601044
41	23	2676005701023
41	135	2676005801135
41	45	2676005901045
41	83	2676006001083
41	98	2676006101098
41	93	2676006201093
41	12	2676006301012
41	97	2676006401097
41	68	2676006501068
41	122	2676006601122
41	69	2676006701069
41	41	2676006801041
41	72	2676006901072
41	31	2676007001031
41	76	2676007101076
41	71	2676007201071
41	74	2676007301074
41	73	2676007401073
41	19	2676007501019
41	18	2676007601018
41	14	2676007701014
41	15	2676007801015
41	16	2676007901016
41	79	2676008001079
41	11	2676008101011
41	80	2676008201080
41	34	2676008301034
41	46	2676008401046
41	37	2676008501037
41	90	2676008601090
41	10	2676008701010
41	85	2676008801085
41	36	2676008901036
41	78	2676009001078
41	92	2676009101092
41	91	2676009201091
41	119	2676009301119
41	86	2676009401086
41	136	2676009501136
41	21	2676009601021
41	84	2676009701084
41	121	2676009801121
72	30	2672000101030
72	82	2672000201082
72	75	2672000301075
72	47	2672000401047
72	110	2672000501110
72	26	2672000601026
72	77	2672000701077
72	20	2672000801020
72	94	2672000901094
72	24	2672001001024
72	40	2672001101040
72	28	2672001201028
72	95	2672001301095
72	53	2672001401053
72	25	2672001501025
72	49	2672001601049
72	51	2672001701051
72	52	2672001801052
72	50	2672001901050
72	54	2672002001054
72	55	2672002101055
72	57	2672002201057
72	56	2672002301056
72	58	2672002401058
72	59	2672002501059
72	60	2672002601060
72	61	2672002701061
72	62	2672002801062
72	63	2672002901063
72	64	2672003001064
72	66	2672003101066
72	65	2672003201065
72	107	2672003301107
72	67	2672003401067
72	134	2672003501134
72	22	2672003601022
72	27	2672003701027
72	103	2672003801103
72	87	2672003901087
72	88	2672004001088
72	89	2672004101089
72	32	2672004201032
72	29	2672004301029
72	33	2672004401033
72	96	2672004501096
72	35	2672004601035
72	102	2672004701102
72	120	2672004801120
72	13	2672004901013
72	39	2672005001039
72	17	2672005101017
72	38	2672005201038
72	43	2672005301043
72	48	2672005401048
72	42	2672005501042
72	44	2672005601044
72	23	2672005701023
72	135	2672005801135
72	45	2672005901045
72	83	2672006001083
72	98	2672006101098
72	93	2672006201093
72	12	2672006301012
72	97	2672006401097
72	68	2672006501068
72	122	2672006601122
72	69	2672006701069
72	41	2672006801041
72	72	2672006901072
72	31	2672007001031
72	76	2672007101076
72	71	2672007201071
72	74	2672007301074
72	73	2672007401073
72	19	2672007501019
72	18	2672007601018
72	14	2672007701014
72	15	2672007801015
72	16	2672007901016
72	79	2672008001079
72	11	2672008101011
72	80	2672008201080
72	34	2672008301034
72	46	2672008401046
72	37	2672008501037
72	90	2672008601090
72	10	2672008701010
72	85	2672008801085
72	36	2672008901036
72	78	2672009001078
72	92	2672009101092
72	91	2672009201091
72	119	2672009301119
72	86	2672009401086
72	136	2672009501136
72	21	2672009601021
72	84	2672009701084
72	121	2672009801121
31	30	2672009901030
31	82	26720010001082
31	75	26720010101075
31	47	26720010201047
31	110	26720010301110
31	26	26720010401026
31	77	26720010501077
31	20	26720010601020
31	94	26720010701094
31	24	26720010801024
31	40	26720010901040
31	28	26720011001028
31	95	26720011101095
31	53	26720011201053
31	25	26720011301025
31	49	26720011401049
31	51	26720011501051
31	52	26720011601052
31	50	26720011701050
31	54	26720011801054
31	55	26720011901055
31	57	26720012001057
31	56	26720012101056
31	58	26720012201058
31	59	26720012301059
31	60	26720012401060
31	61	26720012501061
31	62	26720012601062
31	63	26720012701063
31	64	26720012801064
31	66	26720012901066
31	65	26720013001065
31	107	26720013101107
31	67	26720013201067
31	134	26720013301134
31	22	26720013401022
31	27	26720013501027
31	103	26720013601103
31	87	26720013701087
31	88	26720013801088
31	89	26720013901089
31	32	26720014001032
31	29	26720014101029
31	33	26720014201033
31	96	26720014301096
31	35	26720014401035
31	102	26720014501102
31	120	26720014601120
31	13	26720014701013
31	39	26720014801039
31	17	26720014901017
31	38	26720015001038
31	43	26720015101043
31	48	26720015201048
31	42	26720015301042
31	44	26720015401044
31	23	26720015501023
31	135	26720015601135
31	45	26720015701045
31	83	26720015801083
31	98	26720015901098
31	93	26720016001093
31	12	26720016101012
31	97	26720016201097
31	68	26720016301068
31	122	26720016401122
31	69	26720016501069
31	41	26720016601041
31	72	26720016701072
31	31	26720016801031
31	76	26720016901076
31	71	26720017001071
31	74	26720017101074
31	73	26720017201073
31	19	26720017301019
31	18	26720017401018
31	14	26720017501014
31	15	26720017601015
31	16	26720017701016
31	79	26720017801079
31	11	26720017901011
31	80	26720018001080
31	34	26720018101034
31	46	26720018201046
31	37	26720018301037
31	90	26720018401090
31	10	26720018501010
31	85	26720018601085
31	36	26720018701036
31	78	26720018801078
31	92	26720018901092
31	91	26720019001091
31	119	26720019101119
31	86	26720019201086
31	136	26720019301136
31	21	26720019401021
31	84	26720019501084
31	121	26720019601121
76	30	2673000101030
76	82	2673000201082
76	75	2673000301075
76	47	2673000401047
76	110	2673000501110
76	26	2673000601026
76	77	2673000701077
76	20	2673000801020
76	94	2673000901094
76	24	2673001001024
76	40	2673001101040
76	28	2673001201028
76	95	2673001301095
76	53	2673001401053
76	25	2673001501025
76	49	2673001601049
76	51	2673001701051
76	52	2673001801052
76	50	2673001901050
76	54	2673002001054
76	55	2673002101055
76	57	2673002201057
76	56	2673002301056
76	58	2673002401058
76	59	2673002501059
76	60	2673002601060
76	61	2673002701061
76	62	2673002801062
76	63	2673002901063
76	64	2673003001064
76	66	2673003101066
76	65	2673003201065
76	107	2673003301107
76	67	2673003401067
76	134	2673003501134
76	22	2673003601022
76	27	2673003701027
76	103	2673003801103
76	87	2673003901087
76	88	2673004001088
76	89	2673004101089
76	32	2673004201032
76	29	2673004301029
76	33	2673004401033
76	96	2673004501096
76	35	2673004601035
76	102	2673004701102
76	120	2673004801120
76	13	2673004901013
76	39	2673005001039
76	17	2673005101017
76	38	2673005201038
76	43	2673005301043
76	48	2673005401048
76	42	2673005501042
76	44	2673005601044
76	23	2673005701023
76	135	2673005801135
76	45	2673005901045
76	83	2673006001083
76	98	2673006101098
76	93	2673006201093
76	12	2673006301012
76	97	2673006401097
76	68	2673006501068
76	122	2673006601122
76	69	2673006701069
76	41	2673006801041
76	72	2673006901072
76	31	2673007001031
76	76	2673007101076
76	71	2673007201071
76	74	2673007301074
76	73	2673007401073
76	19	2673007501019
76	18	2673007601018
76	14	2673007701014
76	15	2673007801015
76	16	2673007901016
76	79	2673008001079
76	11	2673008101011
76	80	2673008201080
76	34	2673008301034
76	46	2673008401046
76	37	2673008501037
76	90	2673008601090
76	10	2673008701010
76	85	2673008801085
76	36	2673008901036
76	78	2673009001078
76	92	2673009101092
76	91	2673009201091
76	119	2673009301119
76	86	2673009401086
76	136	2673009501136
76	21	2673009601021
76	84	2673009701084
76	121	2673009801121
71	30	2674700101030
71	82	2674700201082
71	75	2674700301075
71	47	2674700401047
71	110	2674700501110
71	26	2674700601026
71	77	2674700701077
71	20	2674700801020
71	94	2674700901094
71	24	2674701001024
71	40	2674701101040
71	28	2674701201028
71	95	2674701301095
71	53	2674701401053
71	25	2674701501025
71	49	2674701601049
71	51	2674701701051
71	52	2674701801052
71	50	2674701901050
71	54	2674702001054
71	55	2674702101055
71	57	2674702201057
71	56	2674702301056
71	58	2674702401058
71	59	2674702501059
71	60	2674702601060
71	61	2674702701061
71	62	2674702801062
71	63	2674702901063
71	64	2674703001064
71	66	2674703101066
71	65	2674703201065
71	107	2674703301107
71	67	2674703401067
71	134	2674703501134
71	22	2674703601022
71	27	2674703701027
71	103	2674703801103
71	87	2674703901087
71	88	2674704001088
71	89	2674704101089
71	32	2674704201032
71	29	2674704301029
71	33	2674704401033
71	96	2674704501096
71	35	2674704601035
71	102	2674704701102
71	120	2674704801120
71	13	2674704901013
71	39	2674705001039
71	17	2674705101017
71	38	2674705201038
71	43	2674705301043
71	48	2674705401048
71	42	2674705501042
71	44	2674705601044
71	23	2674705701023
71	135	2674705801135
71	45	2674705901045
71	83	2674706001083
71	98	2674706101098
71	93	2674706201093
71	12	2674706301012
71	97	2674706401097
71	68	2674706501068
71	122	2674706601122
71	69	2674706701069
71	41	2674706801041
71	72	2674706901072
71	31	2674707001031
71	76	2674707101076
71	71	2674707201071
71	74	2674707301074
71	73	2674707401073
71	19	2674707501019
71	18	2674707601018
71	14	2674707701014
71	15	2674707801015
71	16	2674707901016
71	79	2674708001079
71	11	2674708101011
71	80	2674708201080
71	34	2674708301034
71	46	2674708401046
71	37	2674708501037
71	90	2674708601090
71	10	2674708701010
71	85	2674708801085
71	36	2674708901036
71	78	2674709001078
71	92	2674709101092
71	91	2674709201091
71	119	2674709301119
71	86	2674709401086
71	136	2674709501136
71	21	2674709601021
71	84	2674709701084
71	121	2674709801121
74	30	2676009901030
74	82	26760010001082
74	75	26760010101075
74	47	26760010201047
74	110	26760010301110
74	26	26760010401026
74	77	26760010501077
74	20	26760010601020
74	94	26760010701094
74	24	26760010801024
74	40	26760010901040
74	28	26760011001028
74	95	26760011101095
74	53	26760011201053
74	25	26760011301025
74	49	26760011401049
74	51	26760011501051
74	52	26760011601052
74	50	26760011701050
74	54	26760011801054
74	55	26760011901055
74	57	26760012001057
74	56	26760012101056
74	58	26760012201058
74	59	26760012301059
74	60	26760012401060
74	61	26760012501061
74	62	26760012601062
74	63	26760012701063
74	64	26760012801064
74	66	26760012901066
74	65	26760013001065
74	107	26760013101107
74	67	26760013201067
74	134	26760013301134
74	22	26760013401022
74	27	26760013501027
74	103	26760013601103
74	87	26760013701087
74	88	26760013801088
74	89	26760013901089
74	32	26760014001032
74	29	26760014101029
74	33	26760014201033
74	96	26760014301096
74	35	26760014401035
74	102	26760014501102
74	120	26760014601120
74	13	26760014701013
74	39	26760014801039
74	17	26760014901017
74	38	26760015001038
74	43	26760015101043
74	48	26760015201048
74	42	26760015301042
74	44	26760015401044
74	23	26760015501023
74	135	26760015601135
74	45	26760015701045
74	83	26760015801083
74	98	26760015901098
74	93	26760016001093
74	12	26760016101012
74	97	26760016201097
74	68	26760016301068
74	122	26760016401122
74	69	26760016501069
74	41	26760016601041
74	72	26760016701072
74	31	26760016801031
74	76	26760016901076
74	71	26760017001071
74	74	26760017101074
74	73	26760017201073
74	19	26760017301019
74	18	26760017401018
74	14	26760017501014
74	15	26760017601015
74	16	26760017701016
74	79	26760017801079
74	11	26760017901011
74	80	26760018001080
74	34	26760018101034
74	46	26760018201046
74	37	26760018301037
74	90	26760018401090
74	10	26760018501010
74	85	26760018601085
74	36	26760018701036
74	78	26760018801078
74	92	26760018901092
74	91	26760019001091
74	119	26760019101119
74	86	26760019201086
74	136	26760019301136
74	21	26760019401021
74	84	26760019501084
74	121	26760019601121
73	30	2677000101030
73	82	2677000201082
73	75	2677000301075
73	47	2677000401047
73	110	2677000501110
73	26	2677000601026
73	77	2677000701077
73	20	2677000801020
73	94	2677000901094
73	24	2677001001024
73	40	2677001101040
73	28	2677001201028
73	95	2677001301095
73	53	2677001401053
73	25	2677001501025
73	49	2677001601049
73	51	2677001701051
73	52	2677001801052
73	50	2677001901050
73	54	2677002001054
73	55	2677002101055
73	57	2677002201057
73	56	2677002301056
73	58	2677002401058
73	59	2677002501059
73	60	2677002601060
73	61	2677002701061
73	62	2677002801062
73	63	2677002901063
73	64	2677003001064
73	66	2677003101066
73	65	2677003201065
73	107	2677003301107
73	67	2677003401067
73	134	2677003501134
73	22	2677003601022
73	27	2677003701027
73	103	2677003801103
73	87	2677003901087
73	88	2677004001088
73	89	2677004101089
73	32	2677004201032
73	29	2677004301029
73	33	2677004401033
73	96	2677004501096
73	35	2677004601035
73	102	2677004701102
73	120	2677004801120
73	13	2677004901013
73	39	2677005001039
73	17	2677005101017
73	38	2677005201038
73	43	2677005301043
73	48	2677005401048
73	42	2677005501042
73	44	2677005601044
73	23	2677005701023
73	135	2677005801135
73	45	2677005901045
73	83	2677006001083
73	98	2677006101098
73	93	2677006201093
73	12	2677006301012
73	97	2677006401097
73	68	2677006501068
73	122	2677006601122
73	69	2677006701069
73	41	2677006801041
73	72	2677006901072
73	31	2677007001031
73	76	2677007101076
73	71	2677007201071
73	74	2677007301074
73	73	2677007401073
73	19	2677007501019
73	18	2677007601018
73	14	2677007701014
73	15	2677007801015
73	16	2677007901016
73	79	2677008001079
73	11	2677008101011
73	80	2677008201080
73	34	2677008301034
73	46	2677008401046
73	37	2677008501037
73	90	2677008601090
73	10	2677008701010
73	85	2677008801085
73	36	2677008901036
73	78	2677009001078
73	92	2677009101092
73	91	2677009201091
73	119	2677009301119
73	86	2677009401086
73	136	2677009501136
73	21	2677009601021
73	84	2677009701084
73	121	2677009801121
19	30	2670009901030
19	82	26700010001082
19	75	26700010101075
19	47	26700010201047
19	110	26700010301110
19	26	26700010401026
19	77	26700010501077
19	20	26700010601020
19	94	26700010701094
19	24	26700010801024
19	40	26700010901040
19	28	26700011001028
19	95	26700011101095
19	53	26700011201053
19	25	26700011301025
19	49	26700011401049
19	51	26700011501051
19	52	26700011601052
19	50	26700011701050
19	54	26700011801054
19	55	26700011901055
19	57	26700012001057
19	56	26700012101056
19	58	26700012201058
19	59	26700012301059
19	60	26700012401060
19	61	26700012501061
19	62	26700012601062
19	63	26700012701063
19	64	26700012801064
19	66	26700012901066
19	65	26700013001065
19	107	26700013101107
19	67	26700013201067
19	134	26700013301134
19	22	26700013401022
19	27	26700013501027
19	103	26700013601103
19	87	26700013701087
19	88	26700013801088
19	89	26700013901089
19	32	26700014001032
19	29	26700014101029
19	33	26700014201033
19	96	26700014301096
19	35	26700014401035
19	102	26700014501102
19	120	26700014601120
19	13	26700014701013
19	39	26700014801039
19	17	26700014901017
19	38	26700015001038
19	43	26700015101043
19	48	26700015201048
19	42	26700015301042
19	44	26700015401044
19	23	26700015501023
19	135	26700015601135
19	45	26700015701045
19	83	26700015801083
19	98	26700015901098
19	93	26700016001093
19	12	26700016101012
19	97	26700016201097
19	68	26700016301068
19	122	26700016401122
19	69	26700016501069
19	41	26700016601041
19	72	26700016701072
19	31	26700016801031
19	76	26700016901076
19	71	26700017001071
19	74	26700017101074
19	73	26700017201073
19	19	26700017301019
19	18	26700017401018
19	14	26700017501014
19	15	26700017601015
19	16	26700017701016
19	79	26700017801079
19	11	26700017901011
19	80	26700018001080
19	34	26700018101034
19	46	26700018201046
19	37	26700018301037
19	90	26700018401090
19	10	26700018501010
19	85	26700018601085
19	36	26700018701036
19	78	26700018801078
19	92	26700018901092
19	91	26700019001091
19	119	26700019101119
19	86	26700019201086
19	136	26700019301136
19	21	26700019401021
19	84	26700019501084
19	121	26700019601121
18	30	26720019701030
18	82	26720019801082
18	75	26720019901075
18	47	26720020001047
18	110	26720020101110
18	26	26720020201026
18	77	26720020301077
18	20	26720020401020
18	94	26720020501094
18	24	26720020601024
18	40	26720020701040
18	28	26720020801028
18	95	26720020901095
18	53	26720021001053
18	25	26720021101025
18	49	26720021201049
18	51	26720021301051
18	52	26720021401052
18	50	26720021501050
18	54	26720021601054
18	55	26720021701055
18	57	26720021801057
18	56	26720021901056
18	58	26720022001058
18	59	26720022101059
18	60	26720022201060
18	61	26720022301061
18	62	26720022401062
18	63	26720022501063
18	64	26720022601064
18	66	26720022701066
18	65	26720022801065
18	107	26720022901107
18	67	26720023001067
18	134	26720023101134
18	22	26720023201022
18	27	26720023301027
18	103	26720023401103
18	87	26720023501087
18	88	26720023601088
18	89	26720023701089
18	32	26720023801032
18	29	26720023901029
18	33	26720024001033
18	96	26720024101096
18	35	26720024201035
18	102	26720024301102
18	120	26720024401120
18	13	26720024501013
18	39	26720024601039
18	17	26720024701017
18	38	26720024801038
18	43	26720024901043
18	48	26720025001048
18	42	26720025101042
18	44	26720025201044
18	23	26720025301023
18	135	26720025401135
18	45	26720025501045
18	83	26720025601083
18	98	26720025701098
18	93	26720025801093
18	12	26720025901012
18	97	26720026001097
18	68	26720026101068
18	122	26720026201122
18	69	26720026301069
18	41	26720026401041
18	72	26720026501072
18	31	26720026601031
18	76	26720026701076
18	71	26720026801071
18	74	26720026901074
18	73	26720027001073
18	19	26720027101019
18	18	26720027201018
18	14	26720027301014
18	15	26720027401015
18	16	26720027501016
18	79	26720027601079
18	11	26720027701011
18	80	26720027801080
18	34	26720027901034
18	46	26720028001046
18	37	26720028101037
18	90	26720028201090
18	10	26720028301010
18	85	26720028401085
18	36	26720028501036
18	78	26720028601078
18	92	26720028701092
18	91	26720028801091
18	119	26720028901119
18	86	26720029001086
18	136	26720029101136
18	21	26720029201021
18	84	26720029301084
18	121	26720029401121
14	30	2672300101030
14	82	2672300201082
14	75	2672300301075
14	47	2672300401047
14	110	2672300501110
14	26	2672300601026
14	77	2672300701077
14	20	2672300801020
14	94	2672300901094
14	24	2672301001024
14	40	2672301101040
14	28	2672301201028
14	95	2672301301095
14	53	2672301401053
14	25	2672301501025
14	49	2672301601049
14	51	2672301701051
14	52	2672301801052
14	50	2672301901050
14	54	2672302001054
14	55	2672302101055
14	57	2672302201057
14	56	2672302301056
14	58	2672302401058
14	59	2672302501059
14	60	2672302601060
14	61	2672302701061
14	62	2672302801062
14	63	2672302901063
14	64	2672303001064
14	66	2672303101066
14	65	2672303201065
14	107	2672303301107
14	67	2672303401067
14	134	2672303501134
14	22	2672303601022
14	27	2672303701027
14	103	2672303801103
14	87	2672303901087
14	88	2672304001088
14	89	2672304101089
14	32	2672304201032
14	29	2672304301029
14	33	2672304401033
14	96	2672304501096
14	35	2672304601035
14	102	2672304701102
14	120	2672304801120
14	13	2672304901013
14	39	2672305001039
14	17	2672305101017
14	38	2672305201038
14	43	2672305301043
14	48	2672305401048
14	42	2672305501042
14	44	2672305601044
14	23	2672305701023
14	135	2672305801135
14	45	2672305901045
14	83	2672306001083
14	98	2672306101098
14	93	2672306201093
14	12	2672306301012
14	97	2672306401097
14	68	2672306501068
14	122	2672306601122
14	69	2672306701069
14	41	2672306801041
14	72	2672306901072
14	31	2672307001031
14	76	2672307101076
14	71	2672307201071
14	74	2672307301074
14	73	2672307401073
14	19	2672307501019
14	18	2672307601018
14	14	2672307701014
14	15	2672307801015
14	16	2672307901016
14	79	2672308001079
14	11	2672308101011
14	80	2672308201080
14	34	2672308301034
14	46	2672308401046
14	37	2672308501037
14	90	2672308601090
14	10	2672308701010
14	85	2672308801085
14	36	2672308901036
14	78	2672309001078
14	92	2672309101092
14	91	2672309201091
14	119	2672309301119
14	86	2672309401086
14	136	2672309501136
14	21	2672309601021
14	84	2672309701084
14	121	2672309801121
15	30	2672400101030
15	82	2672400201082
15	75	2672400301075
15	47	2672400401047
15	110	2672400501110
15	26	2672400601026
15	77	2672400701077
15	20	2672400801020
15	94	2672400901094
15	24	2672401001024
15	40	2672401101040
15	28	2672401201028
15	95	2672401301095
15	53	2672401401053
15	25	2672401501025
15	49	2672401601049
15	51	2672401701051
15	52	2672401801052
15	50	2672401901050
15	54	2672402001054
15	55	2672402101055
15	57	2672402201057
15	56	2672402301056
15	58	2672402401058
15	59	2672402501059
15	60	2672402601060
15	61	2672402701061
15	62	2672402801062
15	63	2672402901063
15	64	2672403001064
15	66	2672403101066
15	65	2672403201065
15	107	2672403301107
15	67	2672403401067
15	134	2672403501134
15	22	2672403601022
15	27	2672403701027
15	103	2672403801103
15	87	2672403901087
15	88	2672404001088
15	89	2672404101089
15	32	2672404201032
15	29	2672404301029
15	33	2672404401033
15	96	2672404501096
15	35	2672404601035
15	102	2672404701102
15	120	2672404801120
15	13	2672404901013
15	39	2672405001039
15	17	2672405101017
15	38	2672405201038
15	43	2672405301043
15	48	2672405401048
15	42	2672405501042
15	44	2672405601044
15	23	2672405701023
15	135	2672405801135
15	45	2672405901045
15	83	2672406001083
15	98	2672406101098
15	93	2672406201093
15	12	2672406301012
15	97	2672406401097
15	68	2672406501068
15	122	2672406601122
15	69	2672406701069
15	41	2672406801041
15	72	2672406901072
15	31	2672407001031
15	76	2672407101076
15	71	2672407201071
15	74	2672407301074
15	73	2672407401073
15	19	2672407501019
15	18	2672407601018
15	14	2672407701014
15	15	2672407801015
15	16	2672407901016
15	79	2672408001079
15	11	2672408101011
15	80	2672408201080
15	34	2672408301034
15	46	2672408401046
15	37	2672408501037
15	90	2672408601090
15	10	2672408701010
15	85	2672408801085
15	36	2672408901036
15	78	2672409001078
15	92	2672409101092
15	91	2672409201091
15	119	2672409301119
15	86	2672409401086
15	136	2672409501136
15	21	2672409601021
15	84	2672409701084
15	121	2672409801121
16	30	2672500101030
16	82	2672500201082
16	75	2672500301075
16	47	2672500401047
16	110	2672500501110
16	26	2672500601026
16	77	2672500701077
16	20	2672500801020
16	94	2672500901094
16	24	2672501001024
16	40	2672501101040
16	28	2672501201028
16	95	2672501301095
16	53	2672501401053
16	25	2672501501025
16	49	2672501601049
16	51	2672501701051
16	52	2672501801052
16	50	2672501901050
16	54	2672502001054
16	55	2672502101055
16	57	2672502201057
16	56	2672502301056
16	58	2672502401058
16	59	2672502501059
16	60	2672502601060
16	61	2672502701061
16	62	2672502801062
16	63	2672502901063
16	64	2672503001064
16	66	2672503101066
16	65	2672503201065
16	107	2672503301107
16	67	2672503401067
16	134	2672503501134
16	22	2672503601022
16	27	2672503701027
16	103	2672503801103
16	87	2672503901087
16	88	2672504001088
16	89	2672504101089
16	32	2672504201032
16	29	2672504301029
16	33	2672504401033
16	96	2672504501096
16	35	2672504601035
16	102	2672504701102
16	120	2672504801120
16	13	2672504901013
16	39	2672505001039
16	17	2672505101017
16	38	2672505201038
16	43	2672505301043
16	48	2672505401048
16	42	2672505501042
16	44	2672505601044
16	23	2672505701023
16	135	2672505801135
16	45	2672505901045
16	83	2672506001083
16	98	2672506101098
16	93	2672506201093
16	12	2672506301012
16	97	2672506401097
16	68	2672506501068
16	122	2672506601122
16	69	2672506701069
16	41	2672506801041
16	72	2672506901072
16	31	2672507001031
16	76	2672507101076
16	71	2672507201071
16	74	2672507301074
16	73	2672507401073
16	19	2672507501019
16	18	2672507601018
16	14	2672507701014
16	15	2672507801015
16	16	2672507901016
16	79	2672508001079
16	11	2672508101011
16	80	2672508201080
16	34	2672508301034
16	46	2672508401046
16	37	2672508501037
16	90	2672508601090
16	10	2672508701010
16	85	2672508801085
16	36	2672508901036
16	78	2672509001078
16	92	2672509101092
16	91	2672509201091
16	119	2672509301119
16	86	2672509401086
16	136	2672509501136
16	21	2672509601021
16	84	2672509701084
16	121	2672509801121
79	30	2673500101030
79	82	2673500201082
79	75	2673500301075
79	47	2673500401047
79	110	2673500501110
79	26	2673500601026
79	77	2673500701077
79	20	2673500801020
79	94	2673500901094
79	24	2673501001024
79	40	2673501101040
79	28	2673501201028
79	95	2673501301095
79	53	2673501401053
79	25	2673501501025
79	49	2673501601049
79	51	2673501701051
79	52	2673501801052
79	50	2673501901050
79	54	2673502001054
79	55	2673502101055
79	57	2673502201057
79	56	2673502301056
79	58	2673502401058
79	59	2673502501059
79	60	2673502601060
79	61	2673502701061
79	62	2673502801062
79	63	2673502901063
79	64	2673503001064
79	66	2673503101066
79	65	2673503201065
79	107	2673503301107
79	67	2673503401067
79	134	2673503501134
79	22	2673503601022
79	27	2673503701027
79	103	2673503801103
79	87	2673503901087
79	88	2673504001088
79	89	2673504101089
79	32	2673504201032
79	29	2673504301029
79	33	2673504401033
79	96	2673504501096
79	35	2673504601035
79	102	2673504701102
79	120	2673504801120
79	13	2673504901013
79	39	2673505001039
79	17	2673505101017
79	38	2673505201038
79	43	2673505301043
79	48	2673505401048
79	42	2673505501042
79	44	2673505601044
79	23	2673505701023
79	135	2673505801135
79	45	2673505901045
79	83	2673506001083
79	98	2673506101098
79	93	2673506201093
79	12	2673506301012
79	97	2673506401097
79	68	2673506501068
79	122	2673506601122
79	69	2673506701069
79	41	2673506801041
79	72	2673506901072
79	31	2673507001031
79	76	2673507101076
79	71	2673507201071
79	74	2673507301074
79	73	2673507401073
79	19	2673507501019
79	18	2673507601018
79	14	2673507701014
79	15	2673507801015
79	16	2673507901016
79	79	2673508001079
79	11	2673508101011
79	80	2673508201080
79	34	2673508301034
79	46	2673508401046
79	37	2673508501037
79	90	2673508601090
79	10	2673508701010
79	85	2673508801085
79	36	2673508901036
79	78	2673509001078
79	92	2673509101092
79	91	2673509201091
79	119	2673509301119
79	86	2673509401086
79	136	2673509501136
79	21	2673509601021
79	84	2673509701084
79	121	2673509801121
11	30	2675200101030
11	82	2675200201082
11	75	2675200301075
11	47	2675200401047
11	110	2675200501110
11	26	2675200601026
11	77	2675200701077
11	20	2675200801020
11	94	2675200901094
11	24	2675201001024
11	40	2675201101040
11	28	2675201201028
11	95	2675201301095
11	53	2675201401053
11	25	2675201501025
11	49	2675201601049
11	51	2675201701051
11	52	2675201801052
11	50	2675201901050
11	54	2675202001054
11	55	2675202101055
11	57	2675202201057
11	56	2675202301056
11	58	2675202401058
11	59	2675202501059
11	60	2675202601060
11	61	2675202701061
11	62	2675202801062
11	63	2675202901063
11	64	2675203001064
11	66	2675203101066
11	65	2675203201065
11	107	2675203301107
11	67	2675203401067
11	134	2675203501134
11	22	2675203601022
11	27	2675203701027
11	103	2675203801103
11	87	2675203901087
11	88	2675204001088
11	89	2675204101089
11	32	2675204201032
11	29	2675204301029
11	33	2675204401033
11	96	2675204501096
11	35	2675204601035
11	102	2675204701102
11	120	2675204801120
11	13	2675204901013
11	39	2675205001039
11	17	2675205101017
11	38	2675205201038
11	43	2675205301043
11	48	2675205401048
11	42	2675205501042
11	44	2675205601044
11	23	2675205701023
11	135	2675205801135
11	45	2675205901045
11	83	2675206001083
11	98	2675206101098
11	93	2675206201093
11	12	2675206301012
11	97	2675206401097
11	68	2675206501068
11	122	2675206601122
11	69	2675206701069
11	41	2675206801041
11	72	2675206901072
11	31	2675207001031
11	76	2675207101076
11	71	2675207201071
11	74	2675207301074
11	73	2675207401073
11	19	2675207501019
11	18	2675207601018
11	14	2675207701014
11	15	2675207801015
11	16	2675207901016
11	79	2675208001079
11	11	2675208101011
11	80	2675208201080
11	34	2675208301034
11	46	2675208401046
11	37	2675208501037
11	90	2675208601090
11	10	2675208701010
11	85	2675208801085
11	36	2675208901036
11	78	2675209001078
11	92	2675209101092
11	91	2675209201091
11	119	2675209301119
11	86	2675209401086
11	136	2675209501136
11	21	2675209601021
11	84	2675209701084
11	121	2675209801121
80	30	2675000101030
80	82	2675000201082
80	75	2675000301075
80	47	2675000401047
80	110	2675000501110
80	26	2675000601026
80	77	2675000701077
80	20	2675000801020
80	94	2675000901094
80	24	2675001001024
80	40	2675001101040
80	28	2675001201028
80	95	2675001301095
80	53	2675001401053
80	25	2675001501025
80	49	2675001601049
80	51	2675001701051
80	52	2675001801052
80	50	2675001901050
80	54	2675002001054
80	55	2675002101055
80	57	2675002201057
80	56	2675002301056
80	58	2675002401058
80	59	2675002501059
80	60	2675002601060
80	61	2675002701061
80	62	2675002801062
80	63	2675002901063
80	64	2675003001064
80	66	2675003101066
80	65	2675003201065
80	107	2675003301107
80	67	2675003401067
80	134	2675003501134
80	22	2675003601022
80	27	2675003701027
80	103	2675003801103
80	87	2675003901087
80	88	2675004001088
80	89	2675004101089
80	32	2675004201032
80	29	2675004301029
80	33	2675004401033
80	96	2675004501096
80	35	2675004601035
80	102	2675004701102
80	120	2675004801120
80	13	2675004901013
80	39	2675005001039
80	17	2675005101017
80	38	2675005201038
80	43	2675005301043
80	48	2675005401048
80	42	2675005501042
80	44	2675005601044
80	23	2675005701023
80	135	2675005801135
80	45	2675005901045
80	83	2675006001083
80	98	2675006101098
80	93	2675006201093
80	12	2675006301012
80	97	2675006401097
80	68	2675006501068
80	122	2675006601122
80	69	2675006701069
80	41	2675006801041
80	72	2675006901072
80	31	2675007001031
80	76	2675007101076
80	71	2675007201071
80	74	2675007301074
80	73	2675007401073
80	19	2675007501019
80	18	2675007601018
80	14	2675007701014
80	15	2675007801015
80	16	2675007901016
80	79	2675008001079
80	11	2675008101011
80	80	2675008201080
80	34	2675008301034
80	46	2675008401046
80	37	2675008501037
80	90	2675008601090
80	10	2675008701010
80	85	2675008801085
80	36	2675008901036
80	78	2675009001078
80	92	2675009101092
80	91	2675009201091
80	119	2675009301119
80	86	2675009401086
80	136	2675009501136
80	21	2675009601021
80	84	2675009701084
80	121	2675009801121
34	30	2676400101030
34	82	2676400201082
34	75	2676400301075
34	47	2676400401047
34	110	2676400501110
34	26	2676400601026
34	77	2676400701077
34	20	2676400801020
34	94	2676400901094
34	24	2676401001024
34	40	2676401101040
34	28	2676401201028
34	95	2676401301095
34	53	2676401401053
34	25	2676401501025
34	49	2676401601049
34	51	2676401701051
34	52	2676401801052
34	50	2676401901050
34	54	2676402001054
34	55	2676402101055
34	57	2676402201057
34	56	2676402301056
34	58	2676402401058
34	59	2676402501059
34	60	2676402601060
34	61	2676402701061
34	62	2676402801062
34	63	2676402901063
34	64	2676403001064
34	66	2676403101066
34	65	2676403201065
34	107	2676403301107
34	67	2676403401067
34	134	2676403501134
34	22	2676403601022
34	27	2676403701027
34	103	2676403801103
34	87	2676403901087
34	88	2676404001088
34	89	2676404101089
34	32	2676404201032
34	29	2676404301029
34	33	2676404401033
34	96	2676404501096
34	35	2676404601035
34	102	2676404701102
34	120	2676404801120
34	13	2676404901013
34	39	2676405001039
34	17	2676405101017
34	38	2676405201038
34	43	2676405301043
34	48	2676405401048
34	42	2676405501042
34	44	2676405601044
34	23	2676405701023
34	135	2676405801135
34	45	2676405901045
34	83	2676406001083
34	98	2676406101098
34	93	2676406201093
34	12	2676406301012
34	97	2676406401097
34	68	2676406501068
34	122	2676406601122
34	69	2676406701069
34	41	2676406801041
34	72	2676406901072
34	31	2676407001031
34	76	2676407101076
34	71	2676407201071
34	74	2676407301074
34	73	2676407401073
34	19	2676407501019
34	18	2676407601018
34	14	2676407701014
34	15	2676407801015
34	16	2676407901016
34	79	2676408001079
34	11	2676408101011
34	80	2676408201080
34	34	2676408301034
34	46	2676408401046
34	37	2676408501037
34	90	2676408601090
34	10	2676408701010
34	85	2676408801085
34	36	2676408901036
34	78	2676409001078
34	92	2676409101092
34	91	2676409201091
34	119	2676409301119
34	86	2676409401086
34	136	2676409501136
34	21	2676409601021
34	84	2676409701084
34	121	2676409801121
46	30	2677600101030
46	82	2677600201082
46	75	2677600301075
46	47	2677600401047
46	110	2677600501110
46	26	2677600601026
46	77	2677600701077
46	20	2677600801020
46	94	2677600901094
46	24	2677601001024
46	40	2677601101040
46	28	2677601201028
46	95	2677601301095
46	53	2677601401053
46	25	2677601501025
46	49	2677601601049
46	51	2677601701051
46	52	2677601801052
46	50	2677601901050
46	54	2677602001054
46	55	2677602101055
46	57	2677602201057
46	56	2677602301056
46	58	2677602401058
46	59	2677602501059
46	60	2677602601060
46	61	2677602701061
46	62	2677602801062
46	63	2677602901063
46	64	2677603001064
46	66	2677603101066
46	65	2677603201065
46	107	2677603301107
46	67	2677603401067
46	134	2677603501134
46	22	2677603601022
46	27	2677603701027
46	103	2677603801103
46	87	2677603901087
46	88	2677604001088
46	89	2677604101089
46	32	2677604201032
46	29	2677604301029
46	33	2677604401033
46	96	2677604501096
46	35	2677604601035
46	102	2677604701102
46	120	2677604801120
46	13	2677604901013
46	39	2677605001039
46	17	2677605101017
46	38	2677605201038
46	43	2677605301043
46	48	2677605401048
46	42	2677605501042
46	44	2677605601044
46	23	2677605701023
46	135	2677605801135
46	45	2677605901045
46	83	2677606001083
46	98	2677606101098
46	93	2677606201093
46	12	2677606301012
46	97	2677606401097
46	68	2677606501068
46	122	2677606601122
46	69	2677606701069
46	41	2677606801041
46	72	2677606901072
46	31	2677607001031
46	76	2677607101076
46	71	2677607201071
46	74	2677607301074
46	73	2677607401073
46	19	2677607501019
46	18	2677607601018
46	14	2677607701014
46	15	2677607801015
46	16	2677607901016
46	79	2677608001079
46	11	2677608101011
46	80	2677608201080
46	34	2677608301034
46	46	2677608401046
46	37	2677608501037
46	90	2677608601090
46	10	2677608701010
46	85	2677608801085
46	36	2677608901036
46	78	2677609001078
46	92	2677609101092
46	91	2677609201091
46	119	2677609301119
46	86	2677609401086
46	136	2677609501136
46	21	2677609601021
46	84	2677609701084
46	121	2677609801121
37	30	2677609901030
37	82	26776010001082
37	75	26776010101075
37	47	26776010201047
37	110	26776010301110
37	26	26776010401026
37	77	26776010501077
37	20	26776010601020
37	94	26776010701094
37	24	26776010801024
37	40	26776010901040
37	28	26776011001028
37	95	26776011101095
37	53	26776011201053
37	25	26776011301025
37	49	26776011401049
37	51	26776011501051
37	52	26776011601052
37	50	26776011701050
37	54	26776011801054
37	55	26776011901055
37	57	26776012001057
37	56	26776012101056
37	58	26776012201058
37	59	26776012301059
37	60	26776012401060
37	61	26776012501061
37	62	26776012601062
37	63	26776012701063
37	64	26776012801064
37	66	26776012901066
37	65	26776013001065
37	107	26776013101107
37	67	26776013201067
37	134	26776013301134
37	22	26776013401022
37	27	26776013501027
37	103	26776013601103
37	87	26776013701087
37	88	26776013801088
37	89	26776013901089
37	32	26776014001032
37	29	26776014101029
37	33	26776014201033
37	96	26776014301096
37	35	26776014401035
37	102	26776014501102
37	120	26776014601120
37	13	26776014701013
37	39	26776014801039
37	17	26776014901017
37	38	26776015001038
37	43	26776015101043
37	48	26776015201048
37	42	26776015301042
37	44	26776015401044
37	23	26776015501023
37	135	26776015601135
37	45	26776015701045
37	83	26776015801083
37	98	26776015901098
37	93	26776016001093
37	12	26776016101012
37	97	26776016201097
37	68	26776016301068
37	122	26776016401122
37	69	26776016501069
37	41	26776016601041
37	72	26776016701072
37	31	26776016801031
37	76	26776016901076
37	71	26776017001071
37	74	26776017101074
37	73	26776017201073
37	19	26776017301019
37	18	26776017401018
37	14	26776017501014
37	15	26776017601015
37	16	26776017701016
37	79	26776017801079
37	11	26776017901011
37	80	26776018001080
37	34	26776018101034
37	46	26776018201046
37	37	26776018301037
37	90	26776018401090
37	10	26776018501010
37	85	26776018601085
37	36	26776018701036
37	78	26776018801078
37	92	26776018901092
37	91	26776019001091
37	119	26776019101119
37	86	26776019201086
37	136	26776019301136
37	21	26776019401021
37	84	26776019501084
37	121	26776019601121
90	30	2678300101030
90	82	2678300201082
90	75	2678300301075
90	47	2678300401047
90	110	2678300501110
90	26	2678300601026
90	77	2678300701077
90	20	2678300801020
90	94	2678300901094
90	24	2678301001024
90	40	2678301101040
90	28	2678301201028
90	95	2678301301095
90	53	2678301401053
90	25	2678301501025
90	49	2678301601049
90	51	2678301701051
90	52	2678301801052
90	50	2678301901050
90	54	2678302001054
90	55	2678302101055
90	57	2678302201057
90	56	2678302301056
90	58	2678302401058
90	59	2678302501059
90	60	2678302601060
90	61	2678302701061
90	62	2678302801062
90	63	2678302901063
90	64	2678303001064
90	66	2678303101066
90	65	2678303201065
90	107	2678303301107
90	67	2678303401067
90	134	2678303501134
90	22	2678303601022
90	27	2678303701027
90	103	2678303801103
90	87	2678303901087
90	88	2678304001088
90	89	2678304101089
90	32	2678304201032
90	29	2678304301029
90	33	2678304401033
90	96	2678304501096
90	35	2678304601035
90	102	2678304701102
90	120	2678304801120
90	13	2678304901013
90	39	2678305001039
90	17	2678305101017
90	38	2678305201038
90	43	2678305301043
90	48	2678305401048
90	42	2678305501042
90	44	2678305601044
90	23	2678305701023
90	135	2678305801135
90	45	2678305901045
90	83	2678306001083
90	98	2678306101098
90	93	2678306201093
90	12	2678306301012
90	97	2678306401097
90	68	2678306501068
90	122	2678306601122
90	69	2678306701069
90	41	2678306801041
90	72	2678306901072
90	31	2678307001031
90	76	2678307101076
90	71	2678307201071
90	74	2678307301074
90	73	2678307401073
90	19	2678307501019
90	18	2678307601018
90	14	2678307701014
90	15	2678307801015
90	16	2678307901016
90	79	2678308001079
90	11	2678308101011
90	80	2678308201080
90	34	2678308301034
90	46	2678308401046
90	37	2678308501037
90	90	2678308601090
90	10	2678308701010
90	85	2678308801085
90	36	2678308901036
90	78	2678309001078
90	92	2678309101092
90	91	2678309201091
90	119	2678309301119
90	86	2678309401086
90	136	2678309501136
90	21	2678309601021
90	84	2678309701084
90	121	2678309801121
10	30	2678400101030
10	82	2678400201082
10	75	2678400301075
10	47	2678400401047
10	110	2678400501110
10	26	2678400601026
10	77	2678400701077
10	20	2678400801020
10	94	2678400901094
10	24	2678401001024
10	40	2678401101040
10	28	2678401201028
10	95	2678401301095
10	53	2678401401053
10	25	2678401501025
10	49	2678401601049
10	51	2678401701051
10	52	2678401801052
10	50	2678401901050
10	54	2678402001054
10	55	2678402101055
10	57	2678402201057
10	56	2678402301056
10	58	2678402401058
10	59	2678402501059
10	60	2678402601060
10	61	2678402701061
10	62	2678402801062
10	63	2678402901063
10	64	2678403001064
10	66	2678403101066
10	65	2678403201065
10	107	2678403301107
10	67	2678403401067
10	134	2678403501134
10	22	2678403601022
10	27	2678403701027
10	103	2678403801103
10	87	2678403901087
10	88	2678404001088
10	89	2678404101089
10	32	2678404201032
10	29	2678404301029
10	33	2678404401033
10	96	2678404501096
10	35	2678404601035
10	102	2678404701102
10	120	2678404801120
10	13	2678404901013
10	39	2678405001039
10	17	2678405101017
10	38	2678405201038
10	43	2678405301043
10	48	2678405401048
10	42	2678405501042
10	44	2678405601044
10	23	2678405701023
10	135	2678405801135
10	45	2678405901045
10	83	2678406001083
10	98	2678406101098
10	93	2678406201093
10	12	2678406301012
10	97	2678406401097
10	68	2678406501068
10	122	2678406601122
10	69	2678406701069
10	41	2678406801041
10	72	2678406901072
10	31	2678407001031
10	76	2678407101076
10	71	2678407201071
10	74	2678407301074
10	73	2678407401073
10	19	2678407501019
10	18	2678407601018
10	14	2678407701014
10	15	2678407801015
10	16	2678407901016
10	79	2678408001079
10	11	2678408101011
10	80	2678408201080
10	34	2678408301034
10	46	2678408401046
10	37	2678408501037
10	90	2678408601090
10	10	2678408701010
10	85	2678408801085
10	36	2678408901036
10	78	2678409001078
10	92	2678409101092
10	91	2678409201091
10	119	2678409301119
10	86	2678409401086
10	136	2678409501136
10	21	2678409601021
10	84	2678409701084
10	121	2678409801121
85	30	2678670101030
85	82	2678670201082
85	75	2678670301075
85	47	2678670401047
85	110	2678670501110
85	26	2678670601026
85	77	2678670701077
85	20	2678670801020
85	94	2678670901094
85	24	2678671001024
85	40	2678671101040
85	28	2678671201028
85	95	2678671301095
85	53	2678671401053
85	25	2678671501025
85	49	2678671601049
85	51	2678671701051
85	52	2678671801052
85	50	2678671901050
85	54	2678672001054
85	55	2678672101055
85	57	2678672201057
85	56	2678672301056
85	58	2678672401058
85	59	2678672501059
85	60	2678672601060
85	61	2678672701061
85	62	2678672801062
85	63	2678672901063
85	64	2678673001064
85	66	2678673101066
85	65	2678673201065
85	107	2678673301107
85	67	2678673401067
85	134	2678673501134
85	22	2678673601022
85	27	2678673701027
85	103	2678673801103
85	87	2678673901087
85	88	2678674001088
85	89	2678674101089
85	32	2678674201032
85	29	2678674301029
85	33	2678674401033
85	96	2678674501096
85	35	2678674601035
85	102	2678674701102
85	120	2678674801120
85	13	2678674901013
85	39	2678675001039
85	17	2678675101017
85	38	2678675201038
85	43	2678675301043
85	48	2678675401048
85	42	2678675501042
85	44	2678675601044
85	23	2678675701023
85	135	2678675801135
85	45	2678675901045
85	83	2678676001083
85	98	2678676101098
85	93	2678676201093
85	12	2678676301012
85	97	2678676401097
85	68	2678676501068
85	122	2678676601122
85	69	2678676701069
85	41	2678676801041
85	72	2678676901072
85	31	2678677001031
85	76	2678677101076
85	71	2678677201071
85	74	2678677301074
85	73	2678677401073
85	19	2678677501019
85	18	2678677601018
85	14	2678677701014
85	15	2678677801015
85	16	2678677901016
85	79	2678678001079
85	11	2678678101011
85	80	2678678201080
85	34	2678678301034
85	46	2678678401046
85	37	2678678501037
85	90	2678678601090
85	10	2678678701010
85	85	2678678801085
85	36	2678678901036
85	78	2678679001078
85	92	2678679101092
85	91	2678679201091
85	119	2678679301119
85	86	2678679401086
85	136	2678679501136
85	21	2678679601021
85	84	2678679701084
85	121	2678679801121
36	30	2678700101030
36	82	2678700201082
36	75	2678700301075
36	47	2678700401047
36	110	2678700501110
36	26	2678700601026
36	77	2678700701077
36	20	2678700801020
36	94	2678700901094
36	24	2678701001024
36	40	2678701101040
36	28	2678701201028
36	95	2678701301095
36	53	2678701401053
36	25	2678701501025
36	49	2678701601049
36	51	2678701701051
36	52	2678701801052
36	50	2678701901050
36	54	2678702001054
36	55	2678702101055
36	57	2678702201057
36	56	2678702301056
36	58	2678702401058
36	59	2678702501059
36	60	2678702601060
36	61	2678702701061
36	62	2678702801062
36	63	2678702901063
36	64	2678703001064
36	66	2678703101066
36	65	2678703201065
36	107	2678703301107
36	67	2678703401067
36	134	2678703501134
36	22	2678703601022
36	27	2678703701027
36	103	2678703801103
36	87	2678703901087
36	88	2678704001088
36	89	2678704101089
36	32	2678704201032
36	29	2678704301029
36	33	2678704401033
36	96	2678704501096
36	35	2678704601035
36	102	2678704701102
36	120	2678704801120
36	13	2678704901013
36	39	2678705001039
36	17	2678705101017
36	38	2678705201038
36	43	2678705301043
36	48	2678705401048
36	42	2678705501042
36	44	2678705601044
36	23	2678705701023
36	135	2678705801135
36	45	2678705901045
36	83	2678706001083
36	98	2678706101098
36	93	2678706201093
36	12	2678706301012
36	97	2678706401097
36	68	2678706501068
36	122	2678706601122
36	69	2678706701069
36	41	2678706801041
36	72	2678706901072
36	31	2678707001031
36	76	2678707101076
36	71	2678707201071
36	74	2678707301074
36	73	2678707401073
36	19	2678707501019
36	18	2678707601018
36	14	2678707701014
36	15	2678707801015
36	16	2678707901016
36	79	2678708001079
36	11	2678708101011
36	80	2678708201080
36	34	2678708301034
36	46	2678708401046
36	37	2678708501037
36	90	2678708601090
36	10	2678708701010
36	85	2678708801085
36	36	2678708901036
36	78	2678709001078
36	92	2678709101092
36	91	2678709201091
36	119	2678709301119
36	86	2678709401086
36	136	2678709501136
36	21	2678709601021
36	84	2678709701084
36	121	2678709801121
78	30	2678709901030
78	82	26787010001082
78	75	26787010101075
78	47	26787010201047
78	110	26787010301110
78	26	26787010401026
78	77	26787010501077
78	20	26787010601020
78	94	26787010701094
78	24	26787010801024
78	40	26787010901040
78	28	26787011001028
78	95	26787011101095
78	53	26787011201053
78	25	26787011301025
78	49	26787011401049
78	51	26787011501051
78	52	26787011601052
78	50	26787011701050
78	54	26787011801054
78	55	26787011901055
78	57	26787012001057
78	56	26787012101056
78	58	26787012201058
78	59	26787012301059
78	60	26787012401060
78	61	26787012501061
78	62	26787012601062
78	63	26787012701063
78	64	26787012801064
78	66	26787012901066
78	65	26787013001065
78	107	26787013101107
78	67	26787013201067
78	134	26787013301134
78	22	26787013401022
78	27	26787013501027
78	103	26787013601103
78	87	26787013701087
78	88	26787013801088
78	89	26787013901089
78	32	26787014001032
78	29	26787014101029
78	33	26787014201033
78	96	26787014301096
78	35	26787014401035
78	102	26787014501102
78	120	26787014601120
78	13	26787014701013
78	39	26787014801039
78	17	26787014901017
78	38	26787015001038
78	43	26787015101043
78	48	26787015201048
78	42	26787015301042
78	44	26787015401044
78	23	26787015501023
78	135	26787015601135
78	45	26787015701045
78	83	26787015801083
78	98	26787015901098
78	93	26787016001093
78	12	26787016101012
78	97	26787016201097
78	68	26787016301068
78	122	26787016401122
78	69	26787016501069
78	41	26787016601041
78	72	26787016701072
78	31	26787016801031
78	76	26787016901076
78	71	26787017001071
78	74	26787017101074
78	73	26787017201073
78	19	26787017301019
78	18	26787017401018
78	14	26787017501014
78	15	26787017601015
78	16	26787017701016
78	79	26787017801079
78	11	26787017901011
78	80	26787018001080
78	34	26787018101034
78	46	26787018201046
78	37	26787018301037
78	90	26787018401090
78	10	26787018501010
78	85	26787018601085
78	36	26787018701036
78	78	26787018801078
78	92	26787018901092
78	91	26787019001091
78	119	26787019101119
78	86	26787019201086
78	136	26787019301136
78	21	26787019401021
78	84	26787019501084
78	121	26787019601121
92	30	2684000101030
92	82	2684000201082
92	75	2684000301075
92	47	2684000401047
92	110	2684000501110
92	26	2684000601026
92	77	2684000701077
92	20	2684000801020
92	94	2684000901094
92	24	2684001001024
92	40	2684001101040
92	28	2684001201028
92	95	2684001301095
92	53	2684001401053
92	25	2684001501025
92	49	2684001601049
92	51	2684001701051
92	52	2684001801052
92	50	2684001901050
92	54	2684002001054
92	55	2684002101055
92	57	2684002201057
92	56	2684002301056
92	58	2684002401058
92	59	2684002501059
92	60	2684002601060
92	61	2684002701061
92	62	2684002801062
92	63	2684002901063
92	64	2684003001064
92	66	2684003101066
92	65	2684003201065
92	107	2684003301107
92	67	2684003401067
92	134	2684003501134
92	22	2684003601022
92	27	2684003701027
92	103	2684003801103
92	87	2684003901087
92	88	2684004001088
92	89	2684004101089
92	32	2684004201032
92	29	2684004301029
92	33	2684004401033
92	96	2684004501096
92	35	2684004601035
92	102	2684004701102
92	120	2684004801120
92	13	2684004901013
92	39	2684005001039
92	17	2684005101017
92	38	2684005201038
92	43	2684005301043
92	48	2684005401048
92	42	2684005501042
92	44	2684005601044
92	23	2684005701023
92	135	2684005801135
92	45	2684005901045
92	83	2684006001083
92	98	2684006101098
92	93	2684006201093
92	12	2684006301012
92	97	2684006401097
92	68	2684006501068
92	122	2684006601122
92	69	2684006701069
92	41	2684006801041
92	72	2684006901072
92	31	2684007001031
92	76	2684007101076
92	71	2684007201071
92	74	2684007301074
92	73	2684007401073
92	19	2684007501019
92	18	2684007601018
92	14	2684007701014
92	15	2684007801015
92	16	2684007901016
92	79	2684008001079
92	11	2684008101011
92	80	2684008201080
92	34	2684008301034
92	46	2684008401046
92	37	2684008501037
92	90	2684008601090
92	10	2684008701010
92	85	2684008801085
92	36	2684008901036
92	78	2684009001078
92	92	2684009101092
92	91	2684009201091
92	119	2684009301119
92	86	2684009401086
92	136	2684009501136
92	21	2684009601021
92	84	2684009701084
92	121	2684009801121
91	30	2687000101030
91	82	2687000201082
91	75	2687000301075
91	47	2687000401047
91	110	2687000501110
91	26	2687000601026
91	77	2687000701077
91	20	2687000801020
91	94	2687000901094
91	24	2687001001024
91	40	2687001101040
91	28	2687001201028
91	95	2687001301095
91	53	2687001401053
91	25	2687001501025
91	49	2687001601049
91	51	2687001701051
91	52	2687001801052
91	50	2687001901050
91	54	2687002001054
91	55	2687002101055
91	57	2687002201057
91	56	2687002301056
91	58	2687002401058
91	59	2687002501059
91	60	2687002601060
91	61	2687002701061
91	62	2687002801062
91	63	2687002901063
91	64	2687003001064
91	66	2687003101066
91	65	2687003201065
91	107	2687003301107
91	67	2687003401067
91	134	2687003501134
91	22	2687003601022
91	27	2687003701027
91	103	2687003801103
91	87	2687003901087
91	88	2687004001088
91	89	2687004101089
91	32	2687004201032
91	29	2687004301029
91	33	2687004401033
91	96	2687004501096
91	35	2687004601035
91	102	2687004701102
91	120	2687004801120
91	13	2687004901013
91	39	2687005001039
91	17	2687005101017
91	38	2687005201038
91	43	2687005301043
91	48	2687005401048
91	42	2687005501042
91	44	2687005601044
91	23	2687005701023
91	135	2687005801135
91	45	2687005901045
91	83	2687006001083
91	98	2687006101098
91	93	2687006201093
91	12	2687006301012
91	97	2687006401097
91	68	2687006501068
91	122	2687006601122
91	69	2687006701069
91	41	2687006801041
91	72	2687006901072
91	31	2687007001031
91	76	2687007101076
91	71	2687007201071
91	74	2687007301074
91	73	2687007401073
91	19	2687007501019
91	18	2687007601018
91	14	2687007701014
91	15	2687007801015
91	16	2687007901016
91	79	2687008001079
91	11	2687008101011
91	80	2687008201080
91	34	2687008301034
91	46	2687008401046
91	37	2687008501037
91	90	2687008601090
91	10	2687008701010
91	85	2687008801085
91	36	2687008901036
91	78	2687009001078
91	92	2687009101092
91	91	2687009201091
91	119	2687009301119
91	86	2687009401086
91	136	2687009501136
91	21	2687009601021
91	84	2687009701084
91	121	2687009801121
119	30	2687500101030
119	82	2687500201082
119	75	2687500301075
119	47	2687500401047
119	110	2687500501110
119	26	2687500601026
119	77	2687500701077
119	20	2687500801020
119	94	2687500901094
119	24	2687501001024
119	40	2687501101040
119	28	2687501201028
119	95	2687501301095
119	53	2687501401053
119	25	2687501501025
119	49	2687501601049
119	51	2687501701051
119	52	2687501801052
119	50	2687501901050
119	54	2687502001054
119	55	2687502101055
119	57	2687502201057
119	56	2687502301056
119	58	2687502401058
119	59	2687502501059
119	60	2687502601060
119	61	2687502701061
119	62	2687502801062
119	63	2687502901063
119	64	2687503001064
119	66	2687503101066
119	65	2687503201065
119	107	2687503301107
119	67	2687503401067
119	134	2687503501134
119	22	2687503601022
119	27	2687503701027
119	103	2687503801103
119	87	2687503901087
119	88	2687504001088
119	89	2687504101089
119	32	2687504201032
119	29	2687504301029
119	33	2687504401033
119	96	2687504501096
119	35	2687504601035
119	102	2687504701102
119	120	2687504801120
119	13	2687504901013
119	39	2687505001039
119	17	2687505101017
119	38	2687505201038
119	43	2687505301043
119	48	2687505401048
119	42	2687505501042
119	44	2687505601044
119	23	2687505701023
119	135	2687505801135
119	45	2687505901045
119	83	2687506001083
119	98	2687506101098
119	93	2687506201093
119	12	2687506301012
119	97	2687506401097
119	68	2687506501068
119	122	2687506601122
119	69	2687506701069
119	41	2687506801041
119	72	2687506901072
119	31	2687507001031
119	76	2687507101076
119	71	2687507201071
119	74	2687507301074
119	73	2687507401073
119	19	2687507501019
119	18	2687507601018
119	14	2687507701014
119	15	2687507801015
119	16	2687507901016
119	79	2687508001079
119	11	2687508101011
119	80	2687508201080
119	34	2687508301034
119	46	2687508401046
119	37	2687508501037
119	90	2687508601090
119	10	2687508701010
119	85	2687508801085
119	36	2687508901036
119	78	2687509001078
119	92	2687509101092
119	91	2687509201091
119	119	2687509301119
119	86	2687509401086
119	136	2687509501136
119	21	2687509601021
119	84	2687509701084
119	121	2687509801121
86	30	2687470101030
86	82	2687470201082
86	75	2687470301075
86	47	2687470401047
86	110	2687470501110
86	26	2687470601026
86	77	2687470701077
86	20	2687470801020
86	94	2687470901094
86	24	2687471001024
86	40	2687471101040
86	28	2687471201028
86	95	2687471301095
86	53	2687471401053
86	25	2687471501025
86	49	2687471601049
86	51	2687471701051
86	52	2687471801052
86	50	2687471901050
86	54	2687472001054
86	55	2687472101055
86	57	2687472201057
86	56	2687472301056
86	58	2687472401058
86	59	2687472501059
86	60	2687472601060
86	61	2687472701061
86	62	2687472801062
86	63	2687472901063
86	64	2687473001064
86	66	2687473101066
86	65	2687473201065
86	107	2687473301107
86	67	2687473401067
86	134	2687473501134
86	22	2687473601022
86	27	2687473701027
86	103	2687473801103
86	87	2687473901087
86	88	2687474001088
86	89	2687474101089
86	32	2687474201032
86	29	2687474301029
86	33	2687474401033
86	96	2687474501096
86	35	2687474601035
86	102	2687474701102
86	120	2687474801120
86	13	2687474901013
86	39	2687475001039
86	17	2687475101017
86	38	2687475201038
86	43	2687475301043
86	48	2687475401048
86	42	2687475501042
86	44	2687475601044
86	23	2687475701023
86	135	2687475801135
86	45	2687475901045
86	83	2687476001083
86	98	2687476101098
86	93	2687476201093
86	12	2687476301012
86	97	2687476401097
86	68	2687476501068
86	122	2687476601122
86	69	2687476701069
86	41	2687476801041
86	72	2687476901072
86	31	2687477001031
86	76	2687477101076
86	71	2687477201071
86	74	2687477301074
86	73	2687477401073
86	19	2687477501019
86	18	2687477601018
86	14	2687477701014
86	15	2687477801015
86	16	2687477901016
86	79	2687478001079
86	11	2687478101011
86	80	2687478201080
86	34	2687478301034
86	46	2687478401046
86	37	2687478501037
86	90	2687478601090
86	10	2687478701010
86	85	2687478801085
86	36	2687478901036
86	78	2687479001078
86	92	2687479101092
86	91	2687479201091
86	119	2687479301119
86	86	2687479401086
86	136	2687479501136
86	21	2687479601021
86	84	2687479701084
86	121	2687479801121
136	30	2682200101030
136	82	2682200201082
136	75	2682200301075
136	47	2682200401047
136	110	2682200501110
136	26	2682200601026
136	77	2682200701077
136	20	2682200801020
136	94	2682200901094
136	24	2682201001024
136	40	2682201101040
136	28	2682201201028
136	95	2682201301095
136	53	2682201401053
136	25	2682201501025
136	49	2682201601049
136	51	2682201701051
136	52	2682201801052
136	50	2682201901050
136	54	2682202001054
136	55	2682202101055
136	57	2682202201057
136	56	2682202301056
136	58	2682202401058
136	59	2682202501059
136	60	2682202601060
136	61	2682202701061
136	62	2682202801062
136	63	2682202901063
136	64	2682203001064
136	66	2682203101066
136	65	2682203201065
136	107	2682203301107
136	67	2682203401067
136	134	2682203501134
136	22	2682203601022
136	27	2682203701027
136	103	2682203801103
136	87	2682203901087
136	88	2682204001088
136	89	2682204101089
136	32	2682204201032
136	29	2682204301029
136	33	2682204401033
136	96	2682204501096
136	35	2682204601035
136	102	2682204701102
136	120	2682204801120
136	13	2682204901013
136	39	2682205001039
136	17	2682205101017
136	38	2682205201038
136	43	2682205301043
136	48	2682205401048
136	42	2682205501042
136	44	2682205601044
136	23	2682205701023
136	135	2682205801135
136	45	2682205901045
136	83	2682206001083
136	98	2682206101098
136	93	2682206201093
136	12	2682206301012
136	97	2682206401097
136	68	2682206501068
136	122	2682206601122
136	69	2682206701069
136	41	2682206801041
136	72	2682206901072
136	31	2682207001031
136	76	2682207101076
136	71	2682207201071
136	74	2682207301074
136	73	2682207401073
136	19	2682207501019
136	18	2682207601018
136	14	2682207701014
136	15	2682207801015
136	16	2682207901016
136	79	2682208001079
136	11	2682208101011
136	80	2682208201080
136	34	2682208301034
136	46	2682208401046
136	37	2682208501037
136	90	2682208601090
136	10	2682208701010
136	85	2682208801085
136	36	2682208901036
136	78	2682209001078
136	92	2682209101092
136	91	2682209201091
136	119	2682209301119
136	86	2682209401086
136	136	2682209501136
136	21	2682209601021
136	84	2682209701084
136	121	2682209801121
21	30	2683000101030
21	82	2683000201082
21	75	2683000301075
21	47	2683000401047
21	110	2683000501110
21	26	2683000601026
21	77	2683000701077
21	20	2683000801020
21	94	2683000901094
21	24	2683001001024
21	40	2683001101040
21	28	2683001201028
21	95	2683001301095
21	53	2683001401053
21	25	2683001501025
21	49	2683001601049
21	51	2683001701051
21	52	2683001801052
21	50	2683001901050
21	54	2683002001054
21	55	2683002101055
21	57	2683002201057
21	56	2683002301056
21	58	2683002401058
21	59	2683002501059
21	60	2683002601060
21	61	2683002701061
21	62	2683002801062
21	63	2683002901063
21	64	2683003001064
21	66	2683003101066
21	65	2683003201065
21	107	2683003301107
21	67	2683003401067
21	134	2683003501134
21	22	2683003601022
21	27	2683003701027
21	103	2683003801103
21	87	2683003901087
21	88	2683004001088
21	89	2683004101089
21	32	2683004201032
21	29	2683004301029
21	33	2683004401033
21	96	2683004501096
21	35	2683004601035
21	102	2683004701102
21	120	2683004801120
21	13	2683004901013
21	39	2683005001039
21	17	2683005101017
21	38	2683005201038
21	43	2683005301043
21	48	2683005401048
21	42	2683005501042
21	44	2683005601044
21	23	2683005701023
21	135	2683005801135
21	45	2683005901045
21	83	2683006001083
21	98	2683006101098
21	93	2683006201093
21	12	2683006301012
21	97	2683006401097
21	68	2683006501068
21	122	2683006601122
21	69	2683006701069
21	41	2683006801041
21	72	2683006901072
21	31	2683007001031
21	76	2683007101076
21	71	2683007201071
21	74	2683007301074
21	73	2683007401073
21	19	2683007501019
21	18	2683007601018
21	14	2683007701014
21	15	2683007801015
21	16	2683007901016
21	79	2683008001079
21	11	2683008101011
21	80	2683008201080
21	34	2683008301034
21	46	2683008401046
21	37	2683008501037
21	90	2683008601090
21	10	2683008701010
21	85	2683008801085
21	36	2683008901036
21	78	2683009001078
21	92	2683009101092
21	91	2683009201091
21	119	2683009301119
21	86	2683009401086
21	136	2683009501136
21	21	2683009601021
21	84	2683009701084
21	121	2683009801121
84	30	2696900101030
84	82	2696900201082
84	75	2696900301075
84	47	2696900401047
84	110	2696900501110
84	26	2696900601026
84	77	2696900701077
84	20	2696900801020
84	94	2696900901094
84	24	2696901001024
84	40	2696901101040
84	28	2696901201028
84	95	2696901301095
84	53	2696901401053
84	25	2696901501025
84	49	2696901601049
84	51	2696901701051
84	52	2696901801052
84	50	2696901901050
84	54	2696902001054
84	55	2696902101055
84	57	2696902201057
84	56	2696902301056
84	58	2696902401058
84	59	2696902501059
84	60	2696902601060
84	61	2696902701061
84	62	2696902801062
84	63	2696902901063
84	64	2696903001064
84	66	2696903101066
84	65	2696903201065
84	107	2696903301107
84	67	2696903401067
84	134	2696903501134
84	22	2696903601022
84	27	2696903701027
84	103	2696903801103
84	87	2696903901087
84	88	2696904001088
84	89	2696904101089
84	32	2696904201032
84	29	2696904301029
84	33	2696904401033
84	96	2696904501096
84	35	2696904601035
84	102	2696904701102
84	120	2696904801120
84	13	2696904901013
84	39	2696905001039
84	17	2696905101017
84	38	2696905201038
84	43	2696905301043
84	48	2696905401048
84	42	2696905501042
84	44	2696905601044
84	23	2696905701023
84	135	2696905801135
84	45	2696905901045
84	83	2696906001083
84	98	2696906101098
84	93	2696906201093
84	12	2696906301012
84	97	2696906401097
84	68	2696906501068
84	122	2696906601122
84	69	2696906701069
84	41	2696906801041
84	72	2696906901072
84	31	2696907001031
84	76	2696907101076
84	71	2696907201071
84	74	2696907301074
84	73	2696907401073
84	19	2696907501019
84	18	2696907601018
84	14	2696907701014
84	15	2696907801015
84	16	2696907901016
84	79	2696908001079
84	11	2696908101011
84	80	2696908201080
84	34	2696908301034
84	46	2696908401046
84	37	2696908501037
84	90	2696908601090
84	10	2696908701010
84	85	2696908801085
84	36	2696908901036
84	78	2696909001078
84	92	2696909101092
84	91	2696909201091
84	119	2696909301119
84	86	2696909401086
84	136	2696909501136
84	21	2696909601021
84	84	2696909701084
84	121	2696909801121
121	30	2892700101030
121	82	2892700201082
121	75	2892700301075
121	47	2892700401047
121	110	2892700501110
121	26	2892700601026
121	77	2892700701077
121	20	2892700801020
121	94	2892700901094
121	24	2892701001024
121	40	2892701101040
121	28	2892701201028
121	95	2892701301095
121	53	2892701401053
121	25	2892701501025
121	49	2892701601049
121	51	2892701701051
121	52	2892701801052
121	50	2892701901050
121	54	2892702001054
121	55	2892702101055
121	57	2892702201057
121	56	2892702301056
121	58	2892702401058
121	59	2892702501059
121	60	2892702601060
121	61	2892702701061
121	62	2892702801062
121	63	2892702901063
121	64	2892703001064
121	66	2892703101066
121	65	2892703201065
121	107	2892703301107
121	67	2892703401067
121	134	2892703501134
121	22	2892703601022
121	27	2892703701027
121	103	2892703801103
121	87	2892703901087
121	88	2892704001088
121	89	2892704101089
121	32	2892704201032
121	29	2892704301029
121	33	2892704401033
121	96	2892704501096
121	35	2892704601035
121	102	2892704701102
121	120	2892704801120
121	13	2892704901013
121	39	2892705001039
121	17	2892705101017
121	38	2892705201038
121	43	2892705301043
121	48	2892705401048
121	42	2892705501042
121	44	2892705601044
121	23	2892705701023
121	135	2892705801135
121	45	2892705901045
121	83	2892706001083
121	98	2892706101098
121	93	2892706201093
121	12	2892706301012
121	97	2892706401097
121	68	2892706501068
121	122	2892706601122
121	69	2892706701069
121	41	2892706801041
121	72	2892706901072
121	31	2892707001031
121	76	2892707101076
121	71	2892707201071
121	74	2892707301074
121	73	2892707401073
121	19	2892707501019
121	18	2892707601018
121	14	2892707701014
121	15	2892707801015
121	16	2892707901016
121	79	2892708001079
121	11	2892708101011
121	80	2892708201080
121	34	2892708301034
121	46	2892708401046
121	37	2892708501037
121	90	2892708601090
121	10	2892708701010
121	85	2892708801085
121	36	2892708901036
121	78	2892709001078
121	92	2892709101092
121	91	2892709201091
121	119	2892709301119
121	86	2892709401086
121	136	2892709501136
121	21	2892709601021
121	84	2892709701084
121	121	2892709801121
30	30	2622000101030
30	82	2622000201082
30	75	2622000301075
30	47	2622000401047
30	110	2622000501110
30	26	2622000601026
30	77	2622000701077
30	20	2622000801020
30	94	2622000901094
30	24	2622001001024
30	40	2622001101040
30	28	2622001201028
30	95	2622001301095
30	53	2622001401053
30	25	2622001501025
30	49	2622001601049
30	51	2622001701051
30	52	2622001801052
30	50	2622001901050
30	54	2622002001054
30	55	2622002101055
30	57	2622002201057
30	56	2622002301056
30	58	2622002401058
30	59	2622002501059
30	60	2622002601060
30	61	2622002701061
30	62	2622002801062
30	63	2622002901063
30	64	2622003001064
30	66	2622003101066
30	65	2622003201065
30	107	2622003301107
30	67	2622003401067
30	134	2622003501134
30	22	2622003601022
30	27	2622003701027
30	103	2622003801103
30	87	2622003901087
30	88	2622004001088
30	89	2622004101089
30	32	2622004201032
30	29	2622004301029
30	33	2622004401033
30	96	2622004501096
30	35	2622004601035
30	102	2622004701102
30	120	2622004801120
30	13	2622004901013
30	39	2622005001039
30	17	2622005101017
30	38	2622005201038
30	43	2622005301043
30	48	2622005401048
30	42	2622005501042
30	44	2622005601044
30	23	2622005701023
30	135	2622005801135
30	45	2622005901045
30	83	2622006001083
30	98	2622006101098
30	93	2622006201093
30	12	2622006301012
30	97	2622006401097
30	68	2622006501068
30	122	2622006601122
30	69	2622006701069
30	41	2622006801041
30	72	2622006901072
30	31	2622007001031
30	76	2622007101076
30	71	2622007201071
30	74	2622007301074
30	73	2622007401073
30	19	2622007501019
30	18	2622007601018
30	14	2622007701014
30	15	2622007801015
30	16	2622007901016
30	79	2622008001079
30	11	2622008101011
30	80	2622008201080
30	34	2622008301034
30	46	2622008401046
30	37	2622008501037
30	90	2622008601090
30	10	2622008701010
30	85	2622008801085
30	36	2622008901036
30	78	2622009001078
30	92	2622009101092
30	91	2622009201091
30	119	2622009301119
30	86	2622009401086
30	136	2622009501136
30	21	2622009601021
30	84	2622009701084
30	121	2622009801121
82	30	2626900101030
82	82	2626900201082
82	75	2626900301075
82	47	2626900401047
82	110	2626900501110
82	26	2626900601026
82	77	2626900701077
82	20	2626900801020
82	94	2626900901094
82	24	2626901001024
82	40	2626901101040
82	28	2626901201028
82	95	2626901301095
82	53	2626901401053
82	25	2626901501025
82	49	2626901601049
82	51	2626901701051
82	52	2626901801052
82	50	2626901901050
82	54	2626902001054
82	55	2626902101055
82	57	2626902201057
82	56	2626902301056
82	58	2626902401058
82	59	2626902501059
82	60	2626902601060
82	61	2626902701061
82	62	2626902801062
82	63	2626902901063
82	64	2626903001064
82	66	2626903101066
82	65	2626903201065
82	107	2626903301107
82	67	2626903401067
82	134	2626903501134
82	22	2626903601022
82	27	2626903701027
82	103	2626903801103
82	87	2626903901087
82	88	2626904001088
82	89	2626904101089
82	32	2626904201032
82	29	2626904301029
82	33	2626904401033
82	96	2626904501096
82	35	2626904601035
82	102	2626904701102
82	120	2626904801120
82	13	2626904901013
82	39	2626905001039
82	17	2626905101017
82	38	2626905201038
82	43	2626905301043
82	48	2626905401048
82	42	2626905501042
82	44	2626905601044
82	23	2626905701023
82	135	2626905801135
82	45	2626905901045
82	83	2626906001083
82	98	2626906101098
82	93	2626906201093
82	12	2626906301012
82	97	2626906401097
82	68	2626906501068
82	122	2626906601122
82	69	2626906701069
82	41	2626906801041
82	72	2626906901072
82	31	2626907001031
82	76	2626907101076
82	71	2626907201071
82	74	2626907301074
82	73	2626907401073
82	19	2626907501019
82	18	2626907601018
82	14	2626907701014
82	15	2626907801015
82	16	2626907901016
82	79	2626908001079
82	11	2626908101011
82	80	2626908201080
82	34	2626908301034
82	46	2626908401046
82	37	2626908501037
82	90	2626908601090
82	10	2626908701010
82	85	2626908801085
82	36	2626908901036
82	78	2626909001078
82	92	2626909101092
82	91	2626909201091
82	119	2626909301119
82	86	2626909401086
82	136	2626909501136
82	21	2626909601021
82	84	2626909701084
82	121	2626909801121
75	30	2622009901030
75	82	26220010001082
75	75	26220010101075
75	47	26220010201047
75	110	26220010301110
75	26	26220010401026
75	77	26220010501077
75	20	26220010601020
75	94	26220010701094
75	24	26220010801024
75	40	26220010901040
75	28	26220011001028
75	95	26220011101095
75	53	26220011201053
75	25	26220011301025
75	49	26220011401049
75	51	26220011501051
75	52	26220011601052
75	50	26220011701050
75	54	26220011801054
75	55	26220011901055
75	57	26220012001057
75	56	26220012101056
75	58	26220012201058
75	59	26220012301059
75	60	26220012401060
75	61	26220012501061
75	62	26220012601062
75	63	26220012701063
75	64	26220012801064
75	66	26220012901066
75	65	26220013001065
75	107	26220013101107
75	67	26220013201067
75	134	26220013301134
75	22	26220013401022
75	27	26220013501027
75	103	26220013601103
75	87	26220013701087
75	88	26220013801088
75	89	26220013901089
75	32	26220014001032
75	29	26220014101029
75	33	26220014201033
75	96	26220014301096
75	35	26220014401035
75	102	26220014501102
75	120	26220014601120
75	13	26220014701013
75	39	26220014801039
75	17	26220014901017
75	38	26220015001038
75	43	26220015101043
75	48	26220015201048
75	42	26220015301042
75	44	26220015401044
75	23	26220015501023
75	135	26220015601135
75	45	26220015701045
75	83	26220015801083
75	98	26220015901098
75	93	26220016001093
75	12	26220016101012
75	97	26220016201097
75	68	26220016301068
75	122	26220016401122
75	69	26220016501069
75	41	26220016601041
75	72	26220016701072
75	31	26220016801031
75	76	26220016901076
75	71	26220017001071
75	74	26220017101074
75	73	26220017201073
75	19	26220017301019
75	18	26220017401018
75	14	26220017501014
75	15	26220017601015
75	16	26220017701016
75	79	26220017801079
75	11	26220017901011
75	80	26220018001080
75	34	26220018101034
75	46	26220018201046
75	37	26220018301037
75	90	26220018401090
75	10	26220018501010
75	85	26220018601085
75	36	26220018701036
75	78	26220018801078
75	92	26220018901092
75	91	26220019001091
75	119	26220019101119
75	86	26220019201086
75	136	26220019301136
75	21	26220019401021
75	84	26220019501084
75	121	26220019601121
47	30	26220019701030
47	82	26220019801082
47	75	26220019901075
47	47	26220020001047
47	110	26220020101110
47	26	26220020201026
47	77	26220020301077
47	20	26220020401020
47	94	26220020501094
47	24	26220020601024
47	40	26220020701040
47	28	26220020801028
47	95	26220020901095
47	53	26220021001053
47	25	26220021101025
47	49	26220021201049
47	51	26220021301051
47	52	26220021401052
47	50	26220021501050
47	54	26220021601054
47	55	26220021701055
47	57	26220021801057
47	56	26220021901056
47	58	26220022001058
47	59	26220022101059
47	60	26220022201060
47	61	26220022301061
47	62	26220022401062
47	63	26220022501063
47	64	26220022601064
47	66	26220022701066
47	65	26220022801065
47	107	26220022901107
47	67	26220023001067
47	134	26220023101134
47	22	26220023201022
47	27	26220023301027
47	103	26220023401103
47	87	26220023501087
47	88	26220023601088
47	89	26220023701089
47	32	26220023801032
47	29	26220023901029
47	33	26220024001033
47	96	26220024101096
47	35	26220024201035
47	102	26220024301102
47	120	26220024401120
47	13	26220024501013
47	39	26220024601039
47	17	26220024701017
47	38	26220024801038
47	43	26220024901043
47	48	26220025001048
47	42	26220025101042
47	44	26220025201044
47	23	26220025301023
47	135	26220025401135
47	45	26220025501045
47	83	26220025601083
47	98	26220025701098
47	93	26220025801093
47	12	26220025901012
47	97	26220026001097
47	68	26220026101068
47	122	26220026201122
47	69	26220026301069
47	41	26220026401041
47	72	26220026501072
47	31	26220026601031
47	76	26220026701076
47	71	26220026801071
47	74	26220026901074
47	73	26220027001073
47	19	26220027101019
47	18	26220027201018
47	14	26220027301014
47	15	26220027401015
47	16	26220027501016
47	79	26220027601079
47	11	26220027701011
47	80	26220027801080
47	34	26220027901034
47	46	26220028001046
47	37	26220028101037
47	90	26220028201090
47	10	26220028301010
47	85	26220028401085
47	36	26220028501036
47	78	26220028601078
47	92	26220028701092
47	91	26220028801091
47	119	26220028901119
47	86	26220029001086
47	136	26220029101136
47	21	26220029201021
47	84	26220029301084
47	121	26220029401121
110	30	2622200101030
110	82	2622200201082
110	75	2622200301075
110	47	2622200401047
110	110	2622200501110
110	26	2622200601026
110	77	2622200701077
110	20	2622200801020
110	94	2622200901094
110	24	2622201001024
110	40	2622201101040
110	28	2622201201028
110	95	2622201301095
110	53	2622201401053
110	25	2622201501025
110	49	2622201601049
110	51	2622201701051
110	52	2622201801052
110	50	2622201901050
110	54	2622202001054
110	55	2622202101055
110	57	2622202201057
110	56	2622202301056
110	58	2622202401058
110	59	2622202501059
110	60	2622202601060
110	61	2622202701061
110	62	2622202801062
110	63	2622202901063
110	64	2622203001064
110	66	2622203101066
110	65	2622203201065
110	107	2622203301107
110	67	2622203401067
110	134	2622203501134
110	22	2622203601022
110	27	2622203701027
110	103	2622203801103
110	87	2622203901087
110	88	2622204001088
110	89	2622204101089
110	32	2622204201032
110	29	2622204301029
110	33	2622204401033
110	96	2622204501096
110	35	2622204601035
110	102	2622204701102
110	120	2622204801120
110	13	2622204901013
110	39	2622205001039
110	17	2622205101017
110	38	2622205201038
110	43	2622205301043
110	48	2622205401048
110	42	2622205501042
110	44	2622205601044
110	23	2622205701023
110	135	2622205801135
110	45	2622205901045
110	83	2622206001083
110	98	2622206101098
110	93	2622206201093
110	12	2622206301012
110	97	2622206401097
110	68	2622206501068
110	122	2622206601122
110	69	2622206701069
110	41	2622206801041
110	72	2622206901072
110	31	2622207001031
110	76	2622207101076
110	71	2622207201071
110	74	2622207301074
110	73	2622207401073
110	19	2622207501019
110	18	2622207601018
110	14	2622207701014
110	15	2622207801015
110	16	2622207901016
110	79	2622208001079
110	11	2622208101011
110	80	2622208201080
110	34	2622208301034
110	46	2622208401046
110	37	2622208501037
110	90	2622208601090
110	10	2622208701010
110	85	2622208801085
110	36	2622208901036
110	78	2622209001078
110	92	2622209101092
110	91	2622209201091
110	119	2622209301119
110	86	2622209401086
110	136	2622209501136
110	21	2622209601021
110	84	2622209701084
110	121	2622209801121
26	30	2622700101030
26	82	2622700201082
26	75	2622700301075
26	47	2622700401047
26	110	2622700501110
26	26	2622700601026
26	77	2622700701077
26	20	2622700801020
26	94	2622700901094
26	24	2622701001024
26	40	2622701101040
26	28	2622701201028
26	95	2622701301095
26	53	2622701401053
26	25	2622701501025
26	49	2622701601049
26	51	2622701701051
26	52	2622701801052
26	50	2622701901050
26	54	2622702001054
26	55	2622702101055
26	57	2622702201057
26	56	2622702301056
26	58	2622702401058
26	59	2622702501059
26	60	2622702601060
26	61	2622702701061
26	62	2622702801062
26	63	2622702901063
26	64	2622703001064
26	66	2622703101066
26	65	2622703201065
26	107	2622703301107
26	67	2622703401067
26	134	2622703501134
26	22	2622703601022
26	27	2622703701027
26	103	2622703801103
26	87	2622703901087
26	88	2622704001088
26	89	2622704101089
26	32	2622704201032
26	29	2622704301029
26	33	2622704401033
26	96	2622704501096
26	35	2622704601035
26	102	2622704701102
26	120	2622704801120
26	13	2622704901013
26	39	2622705001039
26	17	2622705101017
26	38	2622705201038
26	43	2622705301043
26	48	2622705401048
26	42	2622705501042
26	44	2622705601044
26	23	2622705701023
26	135	2622705801135
26	45	2622705901045
26	83	2622706001083
26	98	2622706101098
26	93	2622706201093
26	12	2622706301012
26	97	2622706401097
26	68	2622706501068
26	122	2622706601122
26	69	2622706701069
26	41	2622706801041
26	72	2622706901072
26	31	2622707001031
26	76	2622707101076
26	71	2622707201071
26	74	2622707301074
26	73	2622707401073
26	19	2622707501019
26	18	2622707601018
26	14	2622707701014
26	15	2622707801015
26	16	2622707901016
26	79	2622708001079
26	11	2622708101011
26	80	2622708201080
26	34	2622708301034
26	46	2622708401046
26	37	2622708501037
26	90	2622708601090
26	10	2622708701010
26	85	2622708801085
26	36	2622708901036
26	78	2622709001078
26	92	2622709101092
26	91	2622709201091
26	119	2622709301119
26	86	2622709401086
26	136	2622709501136
26	21	2622709601021
26	84	2622709701084
26	121	2622709801121
77	30	2624000101030
77	82	2624000201082
77	75	2624000301075
77	47	2624000401047
77	110	2624000501110
77	26	2624000601026
77	77	2624000701077
77	20	2624000801020
77	94	2624000901094
77	24	2624001001024
77	40	2624001101040
77	28	2624001201028
77	95	2624001301095
77	53	2624001401053
77	25	2624001501025
77	49	2624001601049
77	51	2624001701051
77	52	2624001801052
77	50	2624001901050
77	54	2624002001054
77	55	2624002101055
77	57	2624002201057
77	56	2624002301056
77	58	2624002401058
77	59	2624002501059
77	60	2624002601060
77	61	2624002701061
77	62	2624002801062
77	63	2624002901063
77	64	2624003001064
77	66	2624003101066
77	65	2624003201065
77	107	2624003301107
77	67	2624003401067
77	134	2624003501134
77	22	2624003601022
77	27	2624003701027
77	103	2624003801103
77	87	2624003901087
77	88	2624004001088
77	89	2624004101089
77	32	2624004201032
77	29	2624004301029
77	33	2624004401033
77	96	2624004501096
77	35	2624004601035
77	102	2624004701102
77	120	2624004801120
77	13	2624004901013
77	39	2624005001039
77	17	2624005101017
77	38	2624005201038
77	43	2624005301043
77	48	2624005401048
77	42	2624005501042
77	44	2624005601044
77	23	2624005701023
77	135	2624005801135
77	45	2624005901045
77	83	2624006001083
77	98	2624006101098
77	93	2624006201093
77	12	2624006301012
77	97	2624006401097
77	68	2624006501068
77	122	2624006601122
77	69	2624006701069
77	41	2624006801041
77	72	2624006901072
77	31	2624007001031
77	76	2624007101076
77	71	2624007201071
77	74	2624007301074
77	73	2624007401073
77	19	2624007501019
77	18	2624007601018
77	14	2624007701014
77	15	2624007801015
77	16	2624007901016
77	79	2624008001079
77	11	2624008101011
77	80	2624008201080
77	34	2624008301034
77	46	2624008401046
77	37	2624008501037
77	90	2624008601090
77	10	2624008701010
77	85	2624008801085
77	36	2624008901036
77	78	2624009001078
77	92	2624009101092
77	91	2624009201091
77	119	2624009301119
77	86	2624009401086
77	136	2624009501136
77	21	2624009601021
77	84	2624009701084
77	121	2624009801121
20	30	2626600101030
20	82	2626600201082
20	75	2626600301075
20	47	2626600401047
20	110	2626600501110
20	26	2626600601026
20	77	2626600701077
20	20	2626600801020
20	94	2626600901094
20	24	2626601001024
20	40	2626601101040
20	28	2626601201028
20	95	2626601301095
20	53	2626601401053
20	25	2626601501025
20	49	2626601601049
20	51	2626601701051
20	52	2626601801052
20	50	2626601901050
20	54	2626602001054
20	55	2626602101055
20	57	2626602201057
20	56	2626602301056
20	58	2626602401058
20	59	2626602501059
20	60	2626602601060
20	61	2626602701061
20	62	2626602801062
20	63	2626602901063
20	64	2626603001064
20	66	2626603101066
20	65	2626603201065
20	107	2626603301107
20	67	2626603401067
20	134	2626603501134
20	22	2626603601022
20	27	2626603701027
20	103	2626603801103
20	87	2626603901087
20	88	2626604001088
20	89	2626604101089
20	32	2626604201032
20	29	2626604301029
20	33	2626604401033
20	96	2626604501096
20	35	2626604601035
20	102	2626604701102
20	120	2626604801120
20	13	2626604901013
20	39	2626605001039
20	17	2626605101017
20	38	2626605201038
20	43	2626605301043
20	48	2626605401048
20	42	2626605501042
20	44	2626605601044
20	23	2626605701023
20	135	2626605801135
20	45	2626605901045
20	83	2626606001083
20	98	2626606101098
20	93	2626606201093
20	12	2626606301012
20	97	2626606401097
20	68	2626606501068
20	122	2626606601122
20	69	2626606701069
20	41	2626606801041
20	72	2626606901072
20	31	2626607001031
20	76	2626607101076
20	71	2626607201071
20	74	2626607301074
20	73	2626607401073
20	19	2626607501019
20	18	2626607601018
20	14	2626607701014
20	15	2626607801015
20	16	2626607901016
20	79	2626608001079
20	11	2626608101011
20	80	2626608201080
20	34	2626608301034
20	46	2626608401046
20	37	2626608501037
20	90	2626608601090
20	10	2626608701010
20	85	2626608801085
20	36	2626608901036
20	78	2626609001078
20	92	2626609101092
20	91	2626609201091
20	119	2626609301119
20	86	2626609401086
20	136	2626609501136
20	21	2626609601021
20	84	2626609701084
20	121	2626609801121
94	30	2629000101030
94	82	2629000201082
94	75	2629000301075
94	47	2629000401047
94	110	2629000501110
94	26	2629000601026
94	77	2629000701077
94	20	2629000801020
94	94	2629000901094
94	24	2629001001024
94	40	2629001101040
94	28	2629001201028
94	95	2629001301095
94	53	2629001401053
94	25	2629001501025
94	49	2629001601049
94	51	2629001701051
94	52	2629001801052
94	50	2629001901050
94	54	2629002001054
94	55	2629002101055
94	57	2629002201057
94	56	2629002301056
94	58	2629002401058
94	59	2629002501059
94	60	2629002601060
94	61	2629002701061
94	62	2629002801062
94	63	2629002901063
94	64	2629003001064
94	66	2629003101066
94	65	2629003201065
94	107	2629003301107
94	67	2629003401067
94	134	2629003501134
94	22	2629003601022
94	27	2629003701027
94	103	2629003801103
94	87	2629003901087
94	88	2629004001088
94	89	2629004101089
94	32	2629004201032
94	29	2629004301029
94	33	2629004401033
94	96	2629004501096
94	35	2629004601035
94	102	2629004701102
94	120	2629004801120
94	13	2629004901013
94	39	2629005001039
94	17	2629005101017
94	38	2629005201038
94	43	2629005301043
94	48	2629005401048
94	42	2629005501042
94	44	2629005601044
94	23	2629005701023
94	135	2629005801135
94	45	2629005901045
94	83	2629006001083
94	98	2629006101098
94	93	2629006201093
94	12	2629006301012
94	97	2629006401097
94	68	2629006501068
94	122	2629006601122
94	69	2629006701069
94	41	2629006801041
94	72	2629006901072
94	31	2629007001031
94	76	2629007101076
94	71	2629007201071
94	74	2629007301074
94	73	2629007401073
94	19	2629007501019
94	18	2629007601018
94	14	2629007701014
94	15	2629007801015
94	16	2629007901016
94	79	2629008001079
94	11	2629008101011
94	80	2629008201080
94	34	2629008301034
94	46	2629008401046
94	37	2629008501037
94	90	2629008601090
94	10	2629008701010
94	85	2629008801085
94	36	2629008901036
94	78	2629009001078
94	92	2629009101092
94	91	2629009201091
94	119	2629009301119
94	86	2629009401086
94	136	2629009501136
94	21	2629009601021
94	84	2629009701084
94	121	2629009801121
24	30	26220029501030
24	82	26220029601082
24	75	26220029701075
24	47	26220029801047
24	110	26220029901110
24	26	26220030001026
24	77	26220030101077
24	20	26220030201020
24	94	26220030301094
24	24	26220030401024
24	40	26220030501040
24	28	26220030601028
24	95	26220030701095
24	53	26220030801053
24	25	26220030901025
24	49	26220031001049
24	51	26220031101051
24	52	26220031201052
24	50	26220031301050
24	54	26220031401054
24	55	26220031501055
24	57	26220031601057
24	56	26220031701056
24	58	26220031801058
24	59	26220031901059
24	60	26220032001060
24	61	26220032101061
24	62	26220032201062
24	63	26220032301063
24	64	26220032401064
24	66	26220032501066
24	65	26220032601065
24	107	26220032701107
24	67	26220032801067
24	134	26220032901134
24	22	26220033001022
24	27	26220033101027
24	103	26220033201103
24	87	26220033301087
24	88	26220033401088
24	89	26220033501089
24	32	26220033601032
24	29	26220033701029
24	33	26220033801033
24	96	26220033901096
24	35	26220034001035
24	102	26220034101102
24	120	26220034201120
24	13	26220034301013
24	39	26220034401039
24	17	26220034501017
24	38	26220034601038
24	43	26220034701043
24	48	26220034801048
24	42	26220034901042
24	44	26220035001044
24	23	26220035101023
24	135	26220035201135
24	45	26220035301045
24	83	26220035401083
24	98	26220035501098
24	93	26220035601093
24	12	26220035701012
24	97	26220035801097
24	68	26220035901068
24	122	26220036001122
24	69	26220036101069
24	41	26220036201041
24	72	26220036301072
24	31	26220036401031
24	76	26220036501076
24	71	26220036601071
24	74	26220036701074
24	73	26220036801073
24	19	26220036901019
24	18	26220037001018
24	14	26220037101014
24	15	26220037201015
24	16	26220037301016
24	79	26220037401079
24	11	26220037501011
24	80	26220037601080
24	34	26220037701034
24	46	26220037801046
24	37	26220037901037
24	90	26220038001090
24	10	26220038101010
24	85	26220038201085
24	36	26220038301036
24	78	26220038401078
24	92	26220038501092
24	91	26220038601091
24	119	26220038701119
24	86	26220038801086
24	136	26220038901136
24	21	26220039001021
24	84	26220039101084
24	121	26220039201121
40	30	2622209901030
40	82	26222010001082
40	75	26222010101075
40	47	26222010201047
40	110	26222010301110
40	26	26222010401026
40	77	26222010501077
40	20	26222010601020
40	94	26222010701094
40	24	26222010801024
40	40	26222010901040
40	28	26222011001028
40	95	26222011101095
40	53	26222011201053
40	25	26222011301025
40	49	26222011401049
40	51	26222011501051
40	52	26222011601052
40	50	26222011701050
40	54	26222011801054
40	55	26222011901055
40	57	26222012001057
40	56	26222012101056
40	58	26222012201058
40	59	26222012301059
40	60	26222012401060
40	61	26222012501061
40	62	26222012601062
40	63	26222012701063
40	64	26222012801064
40	66	26222012901066
40	65	26222013001065
40	107	26222013101107
40	67	26222013201067
40	134	26222013301134
40	22	26222013401022
40	27	26222013501027
40	103	26222013601103
40	87	26222013701087
40	88	26222013801088
40	89	26222013901089
40	32	26222014001032
40	29	26222014101029
40	33	26222014201033
40	96	26222014301096
40	35	26222014401035
40	102	26222014501102
40	120	26222014601120
40	13	26222014701013
40	39	26222014801039
40	17	26222014901017
40	38	26222015001038
40	43	26222015101043
40	48	26222015201048
40	42	26222015301042
40	44	26222015401044
40	23	26222015501023
40	135	26222015601135
40	45	26222015701045
40	83	26222015801083
40	98	26222015901098
40	93	26222016001093
40	12	26222016101012
40	97	26222016201097
40	68	26222016301068
40	122	26222016401122
40	69	26222016501069
40	41	26222016601041
40	72	26222016701072
40	31	26222016801031
40	76	26222016901076
40	71	26222017001071
40	74	26222017101074
40	73	26222017201073
40	19	26222017301019
40	18	26222017401018
40	14	26222017501014
40	15	26222017601015
40	16	26222017701016
40	79	26222017801079
40	11	26222017901011
40	80	26222018001080
40	34	26222018101034
40	46	26222018201046
40	37	26222018301037
40	90	26222018401090
40	10	26222018501010
40	85	26222018601085
40	36	26222018701036
40	78	26222018801078
40	92	26222018901092
40	91	26222019001091
40	119	26222019101119
40	86	26222019201086
40	136	26222019301136
40	21	26222019401021
40	84	26222019501084
40	121	26222019601121
28	30	2624009901030
28	82	26240010001082
28	75	26240010101075
28	47	26240010201047
28	110	26240010301110
28	26	26240010401026
28	77	26240010501077
28	20	26240010601020
28	94	26240010701094
28	24	26240010801024
28	40	26240010901040
28	28	26240011001028
28	95	26240011101095
28	53	26240011201053
28	25	26240011301025
28	49	26240011401049
28	51	26240011501051
28	52	26240011601052
28	50	26240011701050
28	54	26240011801054
28	55	26240011901055
28	57	26240012001057
28	56	26240012101056
28	58	26240012201058
28	59	26240012301059
28	60	26240012401060
28	61	26240012501061
28	62	26240012601062
28	63	26240012701063
28	64	26240012801064
28	66	26240012901066
28	65	26240013001065
28	107	26240013101107
28	67	26240013201067
28	134	26240013301134
28	22	26240013401022
28	27	26240013501027
28	103	26240013601103
28	87	26240013701087
28	88	26240013801088
28	89	26240013901089
28	32	26240014001032
28	29	26240014101029
28	33	26240014201033
28	96	26240014301096
28	35	26240014401035
28	102	26240014501102
28	120	26240014601120
28	13	26240014701013
28	39	26240014801039
28	17	26240014901017
28	38	26240015001038
28	43	26240015101043
28	48	26240015201048
28	42	26240015301042
28	44	26240015401044
28	23	26240015501023
28	135	26240015601135
28	45	26240015701045
28	83	26240015801083
28	98	26240015901098
28	93	26240016001093
28	12	26240016101012
28	97	26240016201097
28	68	26240016301068
28	122	26240016401122
28	69	26240016501069
28	41	26240016601041
28	72	26240016701072
28	31	26240016801031
28	76	26240016901076
28	71	26240017001071
28	74	26240017101074
\.


--
-- TOC entry 1899 (class 0 OID 17443)
-- Dependencies: 144
-- Data for Name: reports; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY reports (rid, rtype, name, description, generator) FROM stdin;
2	Summary	Basic stats	Number of items borrowed and number of items loaned for the selected period.	report-basic-stats
3	Borrowing	Frequent titles	A list of titles borrowed more than once.	report-frequent-titles
4	Borrowing	Frequent authors	A list of authors borrowed more than once.	report-frequent-authors
5	Borrowing	Fic vs nonfic	Total borrowing by fiction/nonfiction.	report-fic-nonfic
6	Summary	Daily/Weekly/Monthly	Borrowed and loaned daily, weekly, and monthly stats for the selected period.	report-dwm
7	Lending	Unfilled	Number of requests you could not fill, by reason.	report-unfilled
8	Borrowing	No sources	List of titles requested which no sources could loan to you	report-no-sources
\.


--
-- TOC entry 1900 (class 0 OID 17452)
-- Dependencies: 146
-- Data for Name: reports_complete; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY reports_complete (rcid, lid, rid, range_start, range_end, report_file) FROM stdin;
\.


--
-- TOC entry 1901 (class 0 OID 17456)
-- Dependencies: 147
-- Data for Name: reports_queue; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY reports_queue (ts, rid, lid, range_start, range_end) FROM stdin;
\.


--
-- TOC entry 1902 (class 0 OID 17462)
-- Dependencies: 149
-- Data for Name: request; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY request (id, title, author, requester, patron_barcode, current_target, note, canada_post_endpoint, canada_post_tracking_number) FROM stdin;
466	Aloe vera	Gage, Diane	33	26440000000001	1	\N	\N	\N
467	Axis	Hachette	33	26440000000001	1	\N	\N	\N
468	Abode of love	Barlow, Kate	33	26440000000001	1	\N	\N	\N
469	Almost human	Gutkind, Lee	33	26440000000001	1	\N	\N	\N
470	Arthur! Arthur!	Black, Arthur	33	26440000000001	1	\N	\N	\N
471	Building with Dad	Nevius, Carol	10	26784000000002	1	\N	\N	\N
472	Butterflies	Neye, Emily	10	26784000000002	1	\N	\N	\N
473	Borrowed light	Hurley, Graham	10	26784000000002	1	\N	\N	\N
474	Barns of western Canada	Hainstock, Bob	10	26784000000002	1	\N	\N	\N
475	Blueberries for Sal	McCloskey, Robert	10	26784000000002	1	\N	\N	\N
476	Cats	Fritzsche, Helga	110	26222000000003	1	\N	\N	\N
477	Cheesemaking made easy	Carroll, Ricki	110	26222000000003	1	\N	\N	\N
478	The Cheshire Cheese cat	Deedy, Carmen Agra	110	26222000000003	1	\N	\N	\N
479	Central America	Lavine, Harold	110	26222000000003	1	\N	\N	\N
480	Count your blessings	Demartini, John F	110	26222000000003	1	\N	\N	\N
481	Deadly Daggers	Lavene, Joyce	136	26822000000004	1	\N	\N	\N
482	Dutch	Morris, Edmund	136	26822000000004	1	\N	\N	\N
483	Death Comes For the Fat Man	Hill, Reginald	136	26822000000004	1	\N	\N	\N
484	Duel a history of duelling	Baldick, Robert	136	26822000000004	1	\N	\N	\N
485	Doors & entryways	Spence, William Perkins	136	26822000000004	1	\N	\N	\N
486	Eagle	Stone, Jeff	11	26752000000005	1	\N	\N	\N
487	Eternal	Smith, Cynthia Leitich	11	26752000000005	1	\N	\N	\N
488	Everything on a waffle	Horvath, Polly	11	26752000000005	1	\N	\N	\N
489	Eastward the sea	Haywood, Charles F	11	26752000000005	1	\N	\N	\N
490	Elvis and me	Presley, Priscilla Beaulieu	11	26752000000005	1	\N	\N	\N
491	Farthing	Walton, Jo	12	26637000000004	1	\N	\N	\N
492	Future perfect	Brockmann, Suzanne	12	26637000000004	1	\N	\N	\N
493	Fearless fourteen	Evanovich, Janet	12	26637000000004	1	\N	\N	\N
494	Felicity	Porter, Felicity	12	26637000000004	1	\N	\N	\N
495	Full moon	Hawthorne, Rachel	12	26637000000004	1	\N	\N	\N
496	Goodness gracious, Gulliver Mulligan	Browne, Susan Chalker	13	26427000000006	1	\N	\N	\N
497	Grace under fire	Scanlan, Lawrence	13	26427000000006	1	\N	\N	\N
498	Geronimo	Thompson, William	13	26427000000006	1	\N	\N	\N
499	Geraldine Moodie	White, Donny	13	26427000000006	1	\N	\N	\N
500	Ghost stories of Manitoba	Smith, Barbara	13	\N	0	\N	\N	\N
501	Ghosts don't eat potato chips	Dadey, Debbie	13	26427000000006	1	\N	\N	\N
502	Highway builders	Adams, Georgie	14	26723000000007	1	\N	\N	\N
503	Heartfelt ways to say Thank You	Griffiths, Kathy Distefano	14	26723000000007	1	\N	\N	\N
504	Human rights worldwide	Kabasakal Arat, Zehra F	14	26723000000007	1	\N	\N	\N
505	Hollywood moon	Wambaugh, Joseph	14	26723000000007	1	\N	\N	\N
506	India	Kalman, Bobbie	15	26724000000008	1	\N	\N	\N
507	Internal combustion	Black, Edwin	15	26724000000008	1	\N	\N	\N
508	Interesting Times	Pratchett, Terry	15	26724000000008	1	\N	\N	\N
509	Inner Harbor	Roberts, Nora	15	26724000000008	1	\N	\N	\N
510	Improbable cause	Jance, Judith A	15	26724000000008	1	\N	\N	\N
511	The Juniper game	Jordan, Sherryl	16	26725000000009	1	\N	\N	\N
512	Judges	Batten, Jack	16	26725000000009	1	\N	\N	\N
513	Jelly Belly	Lee, Dennis	16	\N	0	\N	\N	\N
514	Jellybean fever	Murphy, Joanne Brisson	16	26725000000009	1	\N	\N	\N
515	January	Lord, Gabrielle	16	26725000000009	1	\N	\N	\N
516	Kindness	Pryor, Kimberley Jane	17	26520000000010	1	\N	\N	\N
517	Knights of the black and white	Whyte, Jack	17	26520000000010	1	\N	\N	\N
518	Kelwood ... my cradle	Tolboom, Wanda Neill,Tolboom, Wanda (Neill)	17	26520000000010	1	\N	\N	\N
519	A keen soldier	Clark, Andrew	17	26520000000010	1	\N	\N	\N
520	Keeping the bees	Packer, Laurence	17	26520000000010	1	\N	\N	\N
521	Lightning	Steel, Danielle	19	26700000000011	1	\N	\N	\N
522	Laughter, the best medicine	\N	19	26700000000011	1	\N	\N	\N
523	Legend	Deveraux, Jude	19	26700000000011	1	\N	\N	\N
524	Living, loving & learning	Buscaglia, Leo F	19	26700000000011	1	\N	\N	\N
525	Laser basics	Stevens, Lawrence	19	26700000000011	1	\N	\N	\N
526	Marry me	Booth, Pat	18	26720000000012	1	\N	\N	\N
527	The marmalade man	Allen, Charlotte Vale	18	26720000000012	1	\N	\N	\N
528	The multiplex man	Hogan, James P	18	26720000000012	1	\N	\N	\N
529	A multitude of sins	Ford, Richard	18	26720000000012	1	\N	\N	\N
530	The merry heart	Davies, Robertson	18	26720000000012	1	\N	\N	\N
531	Noodle's knitting	Webster, Sheryl	119	26875000000013	1	\N	\N	\N
532	Nothing is impossible	Reeve, Christopher	119	26875000000013	1	\N	\N	\N
533	Nurture the Nature	Gurian, Michael	119	26875000000013	1	\N	\N	\N
534	Nice new neighbours	Brandenburg, F	119	26875000000013	1	\N	\N	\N
535	Nighttime guardian	Stevens, Amanda	119	26875000000013	1	\N	\N	\N
536	An orderly man	Bogarde, Dirk	20	26266000000014	1	\N	\N	\N
537	Ordinary heroes	Turow, Scott	20	26266000000014	1	\N	\N	\N
538	Openings	\N	20	26266000000014	1	\N	\N	\N
539	Occasional papers	\N	20	26266000000014	1	\N	\N	\N
540	Ocean's thirteen	\N	20	26266000000014	1	\N	\N	\N
541	Pterodactyl	Matthews, Rupert	22	26300000000015	1	\N	\N	\N
542	Playful parenting	Cohen, Lawrence J	22	26300000000015	1	\N	\N	\N
543	Platypus!	Clarke, Ginjer L	22	26300000000015	1	\N	\N	\N
544	Purple secret	R&#8471;&#9837;&#8471;&#698;ohl, John C. G	22	26300000000015	1	\N	\N	\N
545	Pluto	Ring, Susan	22	26300000000015	1	\N	\N	\N
546	Queen's jewels:,The	Bain, Donald	21	26830000000016	1	\N	\N	\N
547	A quiet strength	Oke, Janette	21	26830000000016	1	\N	\N	\N
548	Quills	\N	21	26830000000016	1	\N	\N	\N
549	A Quarter for a Kiss	Clark, Mindy Starns	21	26830000000016	1	\N	\N	\N
550	Quite a year for plums	White, Bailey	21	26830000000016	1	\N	\N	\N
551	Rembrandt	Ripley, Elizabeth	23	26622000000017	1	\N	\N	\N
552	Rebus	Rankin, Ian	23	26622000000017	1	\N	\N	\N
553	Route de Chlifa, La	Marineau, Michele	23	26622000000017	1	\N	\N	\N
554	Ransom	Steel, Danielle	23	26622000000017	1	\N	\N	\N
555	Russia	Murrell, Kathleen Berton	23	26622000000017	1	\N	\N	\N
556	Salvation city	Nunez, Sigrid	24	26220000000018	1	\N	\N	\N
557	A sensible life	Wesley, Mary	24	26220000000018	1	\N	\N	\N
558	Sunstroke	Kellerman, Jesse	24	26220000000018	1	\N	\N	\N
559	Subtle energy	Collinge, William	24	26220000000018	1	\N	\N	\N
560	Suburban renewal	Morsi, Pamela	24	26220000000018	1	\N	\N	\N
561	Transforming power	Rebick, Judy	25	26320000000019	1	\N	\N	\N
562	Turtles	Martin, Louise	25	26320000000019	1	\N	\N	\N
563	Totally free	Moore, Stephanie Perry	25	26320000000019	1	\N	\N	\N
564	Tyrannosaurus	Lindsay, William	25	26320000000019	1	\N	\N	\N
565	Teaching hope	\N	25	26320000000019	1	\N	\N	\N
566	The umbrella	Brett, Jan	26	26227000000020	1	\N	\N	\N
567	The Upper class	Brown, Hobson	26	26227000000020	1	\N	\N	\N
568	United we stand	Pringle, Jim	26	\N	0	\N	\N	\N
569	The unwilling umpire	Roy, Ron	26	26227000000020	1	\N	\N	\N
570	I udderly love you!	Toms, Kate	26	26227000000020	1	\N	\N	\N
571	It's Valentine's Day	Prelutsky, Jack	28	26240000000021	1	\N	\N	\N
572	Le vatican mis  &#777;nu	\N	28	26240000000021	1	\N	\N	\N
573	Voltaire's Bastards	John Ralston Saul	28	26240000000021	1	\N	\N	\N
574	Venus	Bova, Ben	28	26240000000021	1	\N	\N	\N
575	Volcanoes	Wood, Jenny	28	26240000000021	1	\N	\N	\N
576	Winter solstice	Pilcher, Rosamunde	103	26375000000022	1	\N	\N	\N
577	Warrior	Fallon, Jennifer	103	26375000000022	1	\N	\N	\N
578	A winning attitude	Hamilton-McGinty, Rosie	103	26375000000022	1	\N	\N	\N
579	Water for elephants	Gruen, Sara	103	26375000000022	1	\N	\N	\N
580	Westward!	Ross, Dana Fuller	103	26375000000022	1	\N	\N	\N
581	The Xeno Chronicles	Miller, G. Wayne	27	26350000000023	1	\N	\N	\N
582	The XENO solution	Erlick, Nelson	27	26350000000023	1	\N	\N	\N
583	X-ray	Veasey, Nick	27	26350000000023	1	\N	\N	\N
584	Xen	Solomon, D.J	27	26350000000023	1	\N	\N	\N
585	Xtreme art	Hart, Christopher	27	26350000000023	1	\N	\N	\N
586	Young Kate	Andersen, Christopher P	30	26220010000023	1	\N	\N	\N
587	Yellow hippo	Rogers, Alan	30	26220010000023	1	\N	\N	\N
588	Youthful passions	\N	30	26220010000023	1	\N	\N	\N
589	Yankee Doodle Dandy	McDonald, Marci	30	26220010000023	1	\N	\N	\N
590	Yonder	Johnston, Tony	30	26220010000023	1	\N	\N	\N
591	Zero day	Baldacci, David	29	26430000000024	1	\N	\N	\N
592	ZINC-COATED STEEL WIRE STRAND	\N	29	26430000000024	1	\N	\N	\N
593	The Zoning by-law	\N	29	26430000000024	1	\N	\N	\N
594	Zoology;	Burnett, Raymond Will	29	26430000000024	1	\N	\N	\N
595	Zippy's tall tale	Moss, Olivia	29	26430000000024	1	\N	\N	\N
596	Animal fact-file	Hare, Tony	31	26720010000026	1	\N	\N	\N
597	Arthur! Arthur!	Black, Arthur	31	26720010000026	1	\N	\N	\N
598	Alfalfa flats	Gallagher, Jack	31	26720010000026	1	\N	\N	\N
599	Ambulance girl	Stern, Jane	31	26720010000026	1	\N	\N	\N
600	Anywhere she runs	Webb, Debra	31	26720010000026	1	\N	\N	\N
601	Big Girl	Steel, Danielle	34	26764000000027	1	\N	\N	\N
602	Beige	Castellucci, Cecil	34	26764000000027	1	\N	\N	\N
603	Baking	Greenspan, Dorie	34	26764000000027	1	\N	\N	\N
604	Balloons	Zubrowski, Bernie	34	26764000000027	1	\N	\N	\N
605	Blue's checkup	Albee, Sarah	34	26764000000027	1	\N	\N	\N
606	Carlisles all	Johnson, Norma	90	26783000000028	1	\N	\N	\N
607	Candy	Brooks, Kevin	90	26783000000028	1	\N	\N	\N
608	Culpepper's Cannon	Paulsen, Gary	90	26783000000028	1	\N	\N	\N
609	Canary island song	Gunn, Robin Jones	90	26783000000028	1	\N	\N	\N
610	Crescent dawn	Cussler, Clive	90	26783000000028	1	\N	\N	\N
611	Deep wizardry	Duane, Diane	36	26787000000029	1	\N	\N	\N
612	Deer	Dingwall, Laima	36	26787000000029	1	\N	\N	\N
613	Decks	\N	36	26787000000029	1	\N	\N	\N
614	Dracula in love	Essex, Karen	36	26787000000029	1	\N	\N	\N
615	Delhi noir	Sawhney, Hirsh	36	26787000000029	1	\N	\N	\N
616	The eagle	Whyte, Jack	37	26776000000030	1	\N	\N	\N
617	Encore Mafalda	Quino, 1932-	37	26776000000030	1	\N	\N	\N
618	Enigma cipher	Cosby, Andrew	37	26776000000030	1	\N	\N	\N
619	Eggs	Burton, Robert	37	26776000000030	1	\N	\N	\N
620	Envoy of the Black Pine	Gray, Clio	37	26776000000030	1	\N	\N	\N
621	A faint cold fear	Slaughter, Karin	38	26532000000031	1	\N	\N	\N
622	Fever dream	Preston, Douglas J	38	26532000000031	1	\N	\N	\N
623	Fruit	Francis, Brian	38	26532000000031	1	\N	\N	\N
624	The Flock of Geryon	Christie, Agatha	38	26532000000031	1	\N	\N	\N
625	Fabric art workshop	Stein, Susan	38	\N	0	\N	\N	\N
626	Fabric art workshop	Stein, Susan	38	26532000000031	1	\N	\N	\N
627	Guitar for dummies	Phillips, Mark	40	26222010000032	1	\N	\N	\N
628	Gleam and Glow	Bunting, Eve	40	26222010000032	1	\N	\N	\N
629	Gigantic turnip /, The	Sharkey, Niamh	40	26222010000032	1	\N	\N	\N
630	Golf for dummies	McCord, Gary	40	26222010000032	1	\N	\N	\N
631	Honk!	Edwards, pamela duncan,Edwards, Pamela Duncan	39	26550000000032	1	\N	\N	\N
632	The handy science answer book	\N	39	26550000000032	1	\N	\N	\N
633	Haze	Modesitt, L. E	39	26550000000032	1	\N	\N	\N
634	The hobbit : or, there and back again	Tolkien, J. R. R	39	26550000000032	1	\N	\N	\N
635	The Harbor	Neggers, Carla	39	26550000000032	1	\N	\N	\N
636	Ideas	Watson, Peter	42	26570000000033	1	\N	\N	\N
637	Holiday magic	\N	42	26570000000033	1	\N	\N	\N
638	Italy	\N	42	26570000000033	1	\N	\N	\N
639	Images of nature	\N	42	26570000000033	1	\N	\N	\N
640	The Interior plains	Watson, Galadriel	42	26570000000033	1	\N	\N	\N
641	Jackal	Follain, John	43	26552000000034	1	\N	\N	\N
642	The jaguar	Parker, T. Jefferson	43	26552000000034	1	\N	\N	\N
643	Jungle	Greenaway, Theresa	43	26552000000034	1	\N	\N	\N
644	The jester	Patterson, James	43	26552000000034	1	\N	\N	\N
645	Joyful stuffed dolls & animals. --	\N	43	26552000000034	1	\N	\N	\N
646	The kiss	Steel, Danielle	44	\N	0	\N	\N	\N
647	The kiss	Steel, Danielle	44	\N	0	\N	\N	\N
648	The kiss	Steel, Danielle	44	26620000000036	1	\N	\N	\N
649	Kyoto and beyond	\N	44	26620000000036	1	\N	\N	\N
650	Knave of Hearts	Carr, Philippa	44	26620000000036	1	\N	\N	\N
651	Kennel Building and Management	Migliorini, Mario	44	26620000000036	1	\N	\N	\N
652	Knee deep in paradise	Butler, Brett	44	26620000000036	1	\N	\N	\N
653	Looking for Rachel Wallace	Parker, Robert B	98	26670000000037	1	\N	\N	\N
654	Lactose free	Knox, Lucy	98	26670000000037	1	\N	\N	\N
655	Legion	Blatty, William Peter	98	26670000000037	1	\N	\N	\N
656	Latvia	\N	98	26670000000037	1	\N	\N	\N
657	Forty lashes less one	Leonard, Elmore	98	26670000000037	1	\N	\N	\N
658	A Lancaster County Christmas	Fisher, Suzanne Woods	98	26670000000037	1	\N	\N	\N
659	Herbs & edible flowers	Hole, Lois	98	26670000000037	1	\N	\N	\N
660	The mulberry tree	Deveraux, Jude	45	26666000000038	1	\N	\N	\N
661	The Manticore	Davies, Robertson	45	26666000000038	1	\N	\N	\N
662	The Marvel Comics encyclopedia	\N	45	26666000000038	1	\N	\N	\N
663	Hunger Games #3, The	Collins, Suzanne	45	26666000000038	1	\N	\N	\N
664	The innocent man	Grisham, John	45	26666000000038	1	\N	\N	\N
665	The Inuk mountie adventure	Wilson, Eric	45	26666000000038	1	\N	\N	\N
666	New York to Dallas	Robb, J. D	47	26220020000039	1	\N	\N	\N
667	One Perfect Day	Mead, Rebecca	47	26220020000039	1	\N	\N	\N
668	And then there were none	Christie, Agatha	47	26220020000039	1	\N	\N	\N
669	Tuck Everlasting	Babbitt, Natalie	47	26220020000039	1	\N	\N	\N
670	Mother nurture	Hanson, Rick	47	26220020000039	1	\N	\N	\N
671	Open house	Russell, Scott	46	26776010000033	1	\N	\N	\N
672	Old Yeller	Gipson, Fred	46	26776010000033	1	\N	\N	\N
673	The sun also rises	Hemingway, Ernest	46	26776010000033	1	\N	\N	\N
674	Agatha Christie	\N	46	26776010000033	1	\N	\N	\N
675	Auto repair for dummies	Sclar, Deanna	46	26776010000033	1	\N	\N	\N
676	Outboard engines	Sherman, Edwin R	50	26372700000039	1	\N	\N	\N
677	Eternal	Russell, Craig	50	26372700000039	1	\N	\N	\N
678	Know your dalmation	The Pet Library	50	26372700000039	1	\N	\N	\N
679	Poodles	Stahlkuppe, Joe	50	26372700000039	1	\N	\N	\N
680	Jack Russell terrier	Lunis, Natalie	50	26372700000039	1	\N	\N	\N
681	Andrew goes fishing in Manitoba	Szuminsky, Carol	51	26372400000040	1	\N	\N	\N
682	Granny is a darling	Denton, Kady MacDonald	51	26372400000040	1	\N	\N	\N
683	Smooth sailing	Gately, Geo	51	26372400000040	1	\N	\N	\N
684	The sea wolf	London, Jack	51	26372400000040	1	\N	\N	\N
685	The grilling season	Davidson, Diane Mott	51	26372400000040	1	\N	\N	\N
686	Istanbul	\N	52	26372600000041	1	\N	\N	\N
687	Kabloona in the yellow kayak	Jason, Victoria	52	26372600000041	1	\N	\N	\N
688	Arctic dreams	Lopez, Barry Holstun	52	26372600000041	1	\N	\N	\N
689	Sahara	Cussler, Clive	52	26372600000041	1	\N	\N	\N
690	A thousand sisters	Shannon, Lisa	52	26372600000041	1	\N	\N	\N
691	Dauphin	\N	53	26320010000042	1	\N	\N	\N
692	Moscow Rules	Silva, Daniel	53	26320010000042	1	\N	\N	\N
693	True history of the Kelly gang	Carey, Peter	53	26320010000042	1	\N	\N	\N
694	The Monks of Santo Domingo De Silos	\N	53	26320010000042	1	\N	\N	\N
695	Number the Stars	Lowry, Lois,lowry, Lois	53	26320010000042	1	\N	\N	\N
696	Vampires of Ottawa	Wilson, Eric	54	26373700000044	1	\N	\N	\N
697	Black Beauty;	Sewell, Anna	54	26373700000044	1	\N	\N	\N
698	Washington	Chernow, Ron	54	26373700000044	1	\N	\N	\N
699	Mexico	\N	54	26373700000044	1	\N	\N	\N
700	Costa Rica	Frank, Nicole	54	26373700000044	1	\N	\N	\N
701	Greece	Adare, Sierra	55	26373600000045	1	\N	\N	\N
702	Afghanistan	Whitfield, Susan	55	26373600000045	1	\N	\N	\N
703	Foucault's pendulum	Eco, Umberto	55	26373600000045	1	\N	\N	\N
704	Thailand	\N	55	26373600000045	1	\N	\N	\N
705	Vietnam	Kalman, Bobbie	55	26373600000045	1	\N	\N	\N
706	Keeping the bees	Packer, Laurence	56	26374700000046	1	\N	\N	\N
707	Rainbow's end	Vinge, Vernor	56	26374700000046	1	\N	\N	\N
708	The children of the sky	Vinge, Vernor	56	26374700000046	1	\N	\N	\N
709	A fire upon the deep	Vinge, Vernor	56	26374700000046	1	\N	\N	\N
710	Cowboys & aliens	Vinge, Joan D	56	26374700000046	1	\N	\N	\N
711	I, Asimov	Asimov, Isaac	57	26374500000048	1	\N	\N	\N
712	Foundation	Asimov, Isaac	57	26374500000048	1	\N	\N	\N
713	Nightfall	Asimov, Isaac	57	26374500000048	1	\N	\N	\N
714	I, Robot	Asimov, Isaac	57	26374500000048	1	\N	\N	\N
715	Asimov laughs again	Asimov, Isaac	57	26374500000048	1	\N	\N	\N
716	Venus	Bova, Ben	58	26374800000049	1	\N	\N	\N
717	Privateers	Bova, Ben	58	26374800000049	1	\N	\N	\N
718	Mars Life	Bova, Ben	58	26374800000049	1	\N	\N	\N
719	The green trap	Bova, Ben	58	26374800000049	1	\N	\N	\N
720	The immortality factor	Bova, Ben	58	26374800000049	1	\N	\N	\N
721	Beyond the fall of night	Clarke, Arthur Charles	59	26374200000050	1	\N	\N	\N
722	2001 : a space odyssey	Clarke, Arthur C	59	26374200000050	1	\N	\N	\N
723	The light of other days	Clarke, Arthur Charles	59	26374200000050	1	\N	\N	\N
724	The garden of Rama	Clarke, Arthur C	59	26374200000050	1	\N	\N	\N
725	The Last Theorem	Clarke, Arthur C	59	26374200000050	1	\N	\N	\N
726	Man and space	Clarke, Arthur Charles	59	26374200000050	1	\N	\N	\N
727	Lord of the Isles	Drake, David	60	26375200000051	1	\N	\N	\N
728	The mirror of worlds	Drake, David	60	26375200000051	1	\N	\N	\N
729	What distant deeps	Drake, David	60	26375200000051	1	\N	\N	\N
730	Patriots	Drake, David	60	26375200000051	1	\N	\N	\N
731	The Belgariad	Eddings, David	49	26370000000052	1	\N	\N	\N
732	The diamond throne	Eddings, David	49	26370000000052	1	\N	\N	\N
733	The sapphire rose	Eddings, David	49	26370000000052	1	\N	\N	\N
734	Pawn of prophecy	Eddings, David	49	26370000000052	1	\N	\N	\N
735	The Hidden City	Eddings, David	49	26370000000052	1	\N	\N	\N
736	Gunpowder plot	Dunn, Carola	61	26376200000053	1	\N	\N	\N
737	Fuel from water	Peavey, Michael A	61	26376200000053	1	\N	\N	\N
738	Carrots love tomatoes	Riotte, Louise	61	26376200000053	1	\N	\N	\N
739	If I had a million onions	Fitch, Sheree	61	26376200000053	1	\N	\N	\N
740	The urban saint	Boge, Paul H	61	26376200000053	1	\N	\N	\N
741	Coffee indulgences	Blake, Susannah	62	26376400000054	1	\N	\N	\N
742	Black coffee	Christie, Agatha	62	26376400000054	1	\N	\N	\N
743	Pour your heart into it	Schultz, Howard	62	26376400000054	1	\N	\N	\N
744	The coffee trader	Liss, David	62	26376400000054	1	\N	\N	\N
745	Wild coffee and tea substitutes of Canada	Turner, Nancy J	62	26376400000054	1	\N	\N	\N
746	Flipbook animation and other ways to make cartoons move	Jenkins, Patrick	63	26376700000054	1	\N	\N	\N
747	The Calvin and Hobbes lazy Sunday book	Watterson, Bill	63	26376700000054	1	\N	\N	\N
748	Drawing	Welton, Jude	63	26376700000054	1	\N	\N	\N
749	Drawing dinosaurs and other prehistoric animals	Bolognese, Don	63	26376700000054	1	\N	\N	\N
750	Pumpkin painting	McKinney, Jordan	63	26376700000054	1	\N	\N	\N
751	Counting on snow	Newhouse, Maxwell	64	26377600000055	1	\N	\N	\N
752	A feast for crows	Martin, George R. R	64	26377600000055	1	\N	\N	\N
753	Bird-by-bird gardening	Roth, Sally	64	26377600000055	1	\N	\N	\N
754	The not-for-profit CEO workbook	Pidgeon Jr., Walter P	64	26377600000055	1	\N	\N	\N
755	The cowboy and the CEO	Wenger, Christine Anne	64	26377600000055	1	\N	\N	\N
756	The complete guide to windows & doors	\N	65	26377500000056	1	\N	\N	\N
757	Rose windows	Cowen, Painton	65	26377500000056	1	\N	\N	\N
758	The complete guide to decks	\N	65	26377500000056	1	\N	\N	\N
759	The Far Pavillions	Kaye, M.M	65	26377500000056	1	\N	\N	\N
760	The tent	Atwood, Margaret	65	26377500000056	1	\N	\N	\N
761	Backpack gourmet	Yaffe, Linda Frederick	66	26377400000057	1	\N	\N	\N
762	Walking softly in the wilderness	Hart, John	66	26377400000057	1	\N	\N	\N
763	Camp cooking	McMorris, Bill	66	26377400000057	1	\N	\N	\N
764	Le Camping	Jacobson, Cliff	66	26377400000057	1	\N	\N	\N
765	Song of the Paddle	Mason, Bill	66	26377400000057	1	\N	\N	\N
766	Heating, ventilating, and air conditioning library	Brumbaugh, James E	124	26377520000058	1	\N	\N	\N
767	The Haynes automotive heating & air-conditioning systems manual	Stubblefield, Mike	124	26377520000058	1	\N	\N	\N
768	Plumbing	\N	124	26377520000058	1	\N	\N	\N
769	Cottage water systems	Burns, Max	124	26377520000058	1	\N	\N	\N
770	Tapestry	Plain, Belva	124	26377520000058	1	\N	\N	\N
771	Foods that harm, foods that heal	\N	107	26377800000059	1	\N	\N	\N
772	The healing foods	Hausman, Patricia	107	26377800000059	1	\N	\N	\N
773	The Healthy Heart Cookbook: Over 700 Recipes for Every Day and Every Occasion	Piscatella, Joseph C	107	26377800000059	1	\N	\N	\N
774	Company's coming	Pare, Jean	107	26377800000059	1	\N	\N	\N
775	Living with diabetes	Walker, Rosemary	107	26377800000059	1	\N	\N	\N
776	The Group of Seven. -	Mellen, Peter	67	26379700000060	1	\N	\N	\N
777	Aces high;	Clark, Alan	67	26379700000060	1	\N	\N	\N
778	Double deuce	Parker, Robert B	67	26379700000060	1	\N	\N	\N
779	Peter Mansbridge one on one	Mansbridge, Peter	67	26379700000060	1	\N	\N	\N
780	Two Dollar Bill	Woods, Stuart	67	26379700000060	1	\N	\N	\N
781	Belling the cat	Richler, Mordecai	48	26575000000061	1	\N	\N	\N
782	Beyond the marsh; a history of three school districts	Vidir Ladies Aid	48	26575000000061	1	\N	\N	\N
783	Getting started in calligraphy	Baron, Nancy	48	26575000000061	1	\N	\N	\N
784	Mend it better	Roach, Kristin M	48	26575000000061	1	\N	\N	\N
785	Daring to Dream	Roberts, Nora	48	26575000000061	1	\N	\N	\N
786	The dog rules	Sundance, Kyra	122	26360000000063	1	\N	\N	\N
787	Watercolor workshop	Barnes-Mellish, Glynis	122	26360000000063	1	\N	\N	\N
788	This will be difficult to explain	Skibsrud, Johanna	122	26360000000063	1	\N	\N	\N
789	Report on the licensing and enforcement practices of Manitoba Water Stewardship	\N	122	26360000000063	1	\N	\N	\N
790	Schooled	Korman, Gordon	122	26360000000063	1	\N	\N	\N
792	The airline builders	Allen, Oliver E	41	26760000000064	1	\N	\N	\N
791	Matthew and the midnight pilot	Morgan, Allen	41	26760000000064	1	\N	\N	\N
793	Young Scientist book of jets	Hewish, Mark	41	26760000000064	1	\N	\N	\N
794	War and peace	Tolstoy, Leo	41	26760000000064	1	\N	\N	\N
795	Individual power	Hudak, Heather C	41	26760000000064	1	\N	\N	\N
796	Wings along the Winnipeg	Taylor, Peter	68	26700010000065	1	\N	\N	\N
797	Snow in april	Pilcher, Rosamunde	68	26700010000065	1	\N	\N	\N
798	4th of July	Patterson, James	68	26700010000065	1	\N	\N	\N
799	August 1914	Solzhenit&#865;syn, Aleksandr Isaevich	68	26700010000065	1	\N	\N	\N
800	Drums of Autumn	Gabaldon, Diana	68	26700010000065	1	\N	\N	\N
801	The Dirt on Dirt	Bourgeois, Paulette	69	26757010000070	1	\N	\N	\N
802	The sneeze	Lloyd, David	69	26757010000070	1	\N	\N	\N
803	For laughing out loud	\N	69	26757010000070	1	\N	\N	\N
804	Poems to share	Jackson, Leroy F	69	26757010000070	1	\N	\N	\N
805	Le monde des oiseaux	\N	69	26757010000070	1	\N	\N	\N
806	Feed	Anderson, M. T	71	26747000000071	1	\N	\N	\N
807	Freshwater Fishes	Page, Lawrence	71	26747000000071	1	\N	\N	\N
808	Telegraph Days	McMurtry, Larry,McMurtry Larry	71	26747000000071	1	\N	\N	\N
809	The copper scroll	Rosenberg, Joel C	71	26747000000071	1	\N	\N	\N
810	Carpentry	\N	71	26747000000071	1	\N	\N	\N
811	An armadillo is not a pillow	Simmie, Lois	72	\N	0	\N	\N	\N
812	An armadillo is not a pillow	Simmie, Lois	72	26720020000072	1	\N	\N	\N
813	Club sandwich	Samson, Lisa	72	\N	0	\N	\N	\N
814	Club sandwich	Samson, Lisa	72	26720020000072	1	\N	\N	\N
815	The Grapes of Wrath	Steinbeck, John	72	26720020000072	1	\N	\N	\N
816	Machete season	Hatzfeld, Jean	79	26735000000073	1	\N	\N	\N
817	Puss in boots	Perrault, Charles	79	26735000000073	1	\N	\N	\N
818	The Fellowship Of The Ring	Tolkien, J.R.R	79	26735000000073	1	\N	\N	\N
819	Green lantern	Johns, Geoff	79	26735000000073	1	\N	\N	\N
820	Boys, bears, and a serious pair of hiking boots	McDonald, Abby	79	26735000000073	1	\N	\N	\N
821	Tears of the giraffe	McCall Smith, Alexander	73	26770000000074	1	\N	\N	\N
822	Maple moon	Bates, Johanna Van der Zeijst	73	26770000000074	1	\N	\N	\N
823	I've got your number	Kinsella, Sophie	73	26770000000074	1	\N	\N	\N
824	Every living thing	Herriot, James	73	26770000000074	1	\N	\N	\N
825	Strength training for seniors	Fekete, Michael	73	26770000000074	1	\N	\N	\N
826	One hundred years of solitude	Marquez, Gabriel Garcia	75	26220030000075	1	\N	\N	\N
827	Red glove	Black, Holly	75	26220030000075	1	\N	\N	\N
828	The golden disk	Bell, William	75	26220030000075	1	\N	\N	\N
829	Drive	Clement, Nathan	75	26220030000075	1	\N	\N	\N
830	The Pencil	Ahlberg, Allan	75	26220030000075	1	\N	\N	\N
831	The book that  jack wrote	Scieszka, Jon	74	26760010000076	1	\N	\N	\N
832	I'm not really here	Allen, Tim	74	26760010000076	1	\N	\N	\N
833	Dyslexia and other learning difficulties	Selikowitz, Mark	74	26760010000076	1	\N	\N	\N
834	Yeah, I'm a little kid	Borden, Darryl	74	26760010000076	1	\N	\N	\N
835	Grandma's kitchen	Hrechuk, Irene	74	26760010000076	1	\N	\N	\N
836	The folk festival book	Johnson, Steve	77	26240010000077	1	\N	\N	\N
837	Festival crafts	Deshpande, Chris	77	26240010000077	1	\N	\N	\N
838	Hugh Lofting's Doctor Dolittle and the pirates	Perkins, Al	77	26240010000077	1	\N	\N	\N
839	Chew on this	Devins, Susan	77	26240010000077	1	\N	\N	\N
840	Fifty mighty men	MacEwan, John W. Grant	77	26240010000077	1	\N	\N	\N
841	Pirates	Miller, Linda Lael	76	26730000000078	1	\N	\N	\N
842	Corsair	Cussler, Clive	76	26730000000078	1	\N	\N	\N
843	The headache cure	Kandel, Joseph	76	26730000000078	1	\N	\N	\N
844	Sleep	Caldwell, J. Paul	76	26730000000078	1	\N	\N	\N
845	The golden dream of Carlo Chuchio	Alexander, Lloyd	76	26730000000078	1	\N	\N	\N
846	Nelson's Trafalgar	Adkins, Roy	80	26750000000079	1	\N	\N	\N
847	Water for elephants	Gruen, Sara	80	26750000000079	1	\N	\N	\N
848	Elephants	Wexo, John Bonnett	80	26750000000079	1	\N	\N	\N
849	Death of a dormouse	Hill, Reginald	80	26750000000079	1	\N	\N	\N
850	Hyperspace	Packard, Edward	80	26750000000079	1	\N	\N	\N
851	The 60s	Powe-Temperley, Kitty	82	26269000000080	1	\N	\N	\N
852	Model railroads	Herda, D. J	82	26269000000080	1	\N	\N	\N
853	Glass rainbow :, The	Burke, James Lee	82	26269000000080	1	\N	\N	\N
854	Stone cold	Baldacci, David	82	26269000000080	1	\N	\N	\N
855	Shipwrecks	Cerullo, Mary M	82	26269000000080	1	\N	\N	\N
856	Carpal tunnel syndrome	Atencio, Rosemarie	135	26646900000081	1	\N	\N	\N
857	Amigurumi world	Rimoli, Ana Paula	135	26646900000081	1	\N	\N	\N
858	The knowledge factory	\N	135	26646900000081	1	\N	\N	\N
859	Barbeque secrets unbeatable recipes, tips & tricks from a barbecue champion	Shewchuk, Ron	135	26646900000081	1	\N	\N	\N
860	Whose game is it, anyway?	Ginsburg, Richard D	135	26646900000081	1	\N	\N	\N
861	Point blank	Coulter, Catherine	83	26669000000082	1	\N	\N	\N
862	44 Cranberry Point	Macomber, Debbie	83	26669000000082	1	\N	\N	\N
863	The look	Blanchard, Nina	83	26669000000082	1	\N	\N	\N
864	Talk, talk	Chocolate, Deborah M. Newton	83	26669000000082	1	\N	\N	\N
865	Building & maintaining docks	Lamping, Chris	83	26669000000082	1	\N	\N	\N
866	The shipping news	Proulx, Annie	84	26969000000083	1	\N	\N	\N
867	Submarine	Mallard, Neil	84	26969000000083	1	\N	\N	\N
868	Our life with the Rocket	Carrier, Roch	84	26969000000083	1	\N	\N	\N
869	Football in action	Crossingham, John	84	\N	0	\N	\N	\N
870	Football in action	Crossingham, John	84	26969000000083	1	\N	\N	\N
871	Storm cycle	Johansen, Iris	85	26786700000084	1	\N	\N	\N
872	Sundown	Douglas, Jake	85	26786700000084	1	\N	\N	\N
873	Breaker's reef	Blackstock, Terri	85	26786700000084	1	\N	\N	\N
874	Off Armageddon Reef	Weber, David	85	26786700000084	1	\N	\N	\N
875	Skeleton Coast	Cussler, Clive	85	26786700000084	1	\N	\N	\N
876	Coast Road	Delinsky, Barbara	86	26874700000085	1	\N	\N	\N
877	92 Pacific Boulevard	Macomber, Debbie	86	26874700000085	1	\N	\N	\N
878	Atlantic	Winchester, Simon	86	26874700000085	1	\N	\N	\N
879	North star to freedom	Gorrell, Gena K	86	26874700000085	1	\N	\N	\N
880	North Spirit	Jiles, Paulette	86	26874700000085	1	\N	\N	\N
881	Spirit in the rainforest	Wilson, Eric	87	26376000000087	1	\N	\N	\N
882		Bouchard, Dave	87	26376000000087	1	\N	\N	\N
883	The Fort Brandon story	Brown, Roy	87	26376000000087	1	\N	\N	\N
884	Steamboats on the Assiniboine	Brown, Roy	87	26376000000087	1	\N	\N	\N
885	Hmm?	Swanson, Diane	87	26376000000087	1	\N	\N	\N
886	Germany	\N	88	26376600000088	1	\N	\N	\N
887	France	\N	88	26376600000088	1	\N	\N	\N
888	Past imperfect	\N	88	26376600000088	1	\N	\N	\N
889	Belgium	Pateman, Robert	88	26376600000088	1	\N	\N	\N
890	Secrets of the seven smallest states of Europe	Eccardt, Thomas M	88	26376600000088	1	\N	\N	\N
891	Jurassic park	Crichton, Michael	89	26377000000089	1	\N	\N	\N
892	Dawn of the dinosaurs	Fraser, Nicholas C	89	26377000000089	1	\N	\N	\N
893	Tyrannosaurus rex and its kin	Sattler, Helen Roney	89	26377000000089	1	\N	\N	\N
894	Dragons ;	Shuker, Karl	89	26377000000089	1	\N	\N	\N
895	The message of the sphinx	Hancock, Graham	89	26377000000089	1	\N	\N	\N
896	Raptor red	Bakker, Robert T	134	26370010000090	1	\N	\N	\N
897	Swimming with the Plesiosaur	Stone, Rex	134	26370010000090	1	\N	\N	\N
898	Beyond the dinosaurs	Brown, Charlotte Lewis	134	26370010000090	1	\N	\N	\N
899	After the dinosaurs	Brown, Charlotte Lewis	134	26370010000090	1	\N	\N	\N
900	Three nights in August	Bissinger, H. G	134	26370010000090	1	\N	\N	\N
901	Cabbage moon	Wahl, Jan	78	26787010000091	1	\N	\N	\N
902	The squash cookbook	Tarr, Yvonne Young	78	26787010000091	1	\N	\N	\N
903	Giraffes Can't Dance	Andreae, Giles	78	26787010000091	1	\N	\N	\N
904	Sharks	McMillan, Beverly	78	26787010000091	1	\N	\N	\N
905	Tuna Fish Tuesday	\N	78	26787010000091	1	\N	\N	\N
906	Communication	Grimshaw, Carol	91	26870000000093	1	\N	\N	\N
907	Foggy Mountain breakdown and other stories	McCrumb, Sharyn	91	26870000000093	1	\N	\N	\N
908	The case for Mars	Zubrin, Robert	91	26870000000093	1	\N	\N	\N
909	Suddenly	Burnard, Bonnie	91	26870000000093	1	\N	\N	\N
910	Strange worlds, amazing places	\N	91	26870000000093	1	\N	\N	\N
911	From prairie roots	Fairbairn, Garry Lawrence	92	26840000000094	1	\N	\N	\N
912	Snowbirds	Sroka, Mike	92	26840000000094	1	\N	\N	\N
913	To have and have not	Hemingway, Ernest	92	26840000000094	1	\N	\N	\N
914	New Zealand	\N	92	26840000000094	1	\N	\N	\N
915	Saturn	Bova, Ben	92	26840000000094	1	\N	\N	\N
916	Wilderness Manitoba	Wilson, Hap	125	26626000000095	1	\N	\N	\N
917	Motorcycles	Oxlade, Chris	125	26626000000095	1	\N	\N	\N
918	Hot Wheels	Landers, Ace	125	26626000000095	1	\N	\N	\N
919	Canadian pie	Ferguson, Will	125	26626000000095	1	\N	\N	\N
920	So you want to be a producer	Turman, Lawrence	125	26626000000095	1	\N	\N	\N
921	Animation unleashed	Besen, Ellen	93	26687000000096	1	\N	\N	\N
922	Programming the universe	Lloyd, Seth	93	26687000000096	1	\N	\N	\N
923	Operation, survival	Dixon, Franklin W	93	26687000000096	1	\N	\N	\N
924	Spitfire	Price, Alfred	93	26687000000096	1	\N	\N	\N
925	Hornet flight	Follett, Ken	93	26687000000096	1	\N	\N	\N
926	The end of the wasp season	Mina, Denise	102	26470000000098	1	\N	\N	\N
927	Do Unto Otters	Keller, Laurie	102	26470000000098	1	\N	\N	\N
928	Ginger	Voake, Charlotte	102	26470000000098	1	\N	\N	\N
929	Taste of honey	Goudge, Eileen	102	26470000000098	1	\N	\N	\N
930	Food allergy cookbook	Bruce-Gardyne, Lucinda	102	26470000000098	1	\N	\N	\N
931	The harrowing of Gwynedd	Kurtz, Katherine	120	26490000000099	1	\N	\N	\N
932	Streams of Babel	Plum-Ucci, Carol	120	26490000000099	1	\N	\N	\N
933	On writing	King, Stephen	120	26490000000099	1	\N	\N	\N
934	The white plume	Bowman, Charles	120	26490000000099	1	\N	\N	\N
935	Great Northern Railroad fonds	\N	120	26490000000099	1	\N	\N	\N
936	Banking	Hudak, Heather C	94	26290000000100	1	\N	\N	\N
937	A breath of snow and ashes	Gabaldon, Diana	94	26290000000100	1	\N	\N	\N
938	Diamonds	Paterson, Vicky	94	26290000000100	1	\N	\N	\N
939	Sapphire	Rogers, Rosemary	94	26290000000100	1	\N	\N	\N
940	The Alexandria link	Berry, Steve	94	26290000000100	1	\N	\N	\N
941	Cell	King, Stephen	95	26262000000101	1	\N	\N	\N
942	Losing Joe's Place	Korman, Gordon	95	26262000000101	1	\N	\N	\N
943	Success with house plants	\N	95	26262000000101	1	\N	\N	\N
944	Murphy's herd	Paulsen, Gary	95	26262000000101	1	\N	\N	\N
945	Just where you belong	Eubank, Patti Reeder	95	26262000000101	1	\N	\N	\N
947	Creating the prairie xeriscape	Williams, Sara	96	26490000000102	1	\N	\N	\N
946	Where the sidewalk ends	Silverstein, Shel	96	26490000000102	1	\N	\N	\N
948	Blue sky	Wood, Audrey	96	26490000000102	1	\N	\N	\N
949	Windy city blues	Paretsky, Sara	96	26490000000102	1	\N	\N	\N
950	The night sky book	Jobb, Jamie	96	26490000000102	1	\N	\N	\N
951	The Gates	Connolly, John	97	26690000000103	1	\N	\N	\N
952	Gateways	Wilson, F. Paul	97	26690000000103	1	\N	\N	\N
953	The butter did it	Richman, Phyllis C	97	26690000000103	1	\N	\N	\N
954	Churchill's secret agent	Butler, Josephine	97	26690000000103	1	\N	\N	\N
955	Colby Brass	Webb, Debra	97	26690000000103	1	\N	\N	\N
956	Somebody somewhere	Williams, Donna	99	26900000000104	1	\N	\N	\N
957	Summer	Kingsbury, Karen	99	26900000000104	1	\N	\N	\N
958	Seabiscuit	Hillenbrand, Laura	99	26900000000104	1	\N	\N	\N
959	Thirst	Snitow, Alan	99	26900000000104	1	\N	\N	\N
960	Tell me your dreams	Sheldon, Sidney,SHELDON, SIDNEY	99	26900000000104	1	\N	\N	\N
\.


--
-- TOC entry 1903 (class 0 OID 17470)
-- Dependencies: 150
-- Data for Name: request_closed; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY request_closed (id, title, author, requester, patron_barcode, filled_by, attempts, note) FROM stdin;
\.


--
-- TOC entry 1904 (class 0 OID 17476)
-- Dependencies: 151
-- Data for Name: requests_active; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY requests_active (request_id, ts, msg_from, msg_to, status, message) FROM stdin;
466	2012-07-21 18:41:24.198571	33	99	ILL-Request	\N
467	2012-07-21 18:42:08.85337	33	91	ILL-Request	\N
468	2012-07-21 18:42:52.549026	33	101	ILL-Request	\N
469	2012-07-21 18:43:31.405817	33	101	ILL-Request	\N
470	2012-07-21 18:44:04.774031	33	34	ILL-Request	\N
471	2012-07-21 18:45:32.03293	10	92	ILL-Request	\N
472	2012-07-21 18:46:05.658639	10	44	ILL-Request	\N
473	2012-07-21 18:46:47.197137	10	99	ILL-Request	\N
474	2012-07-21 18:47:18.974449	10	68	ILL-Request	\N
475	2012-07-21 18:47:56.08975	10	135	ILL-Request	\N
476	2012-07-21 18:49:00.019174	110	73	ILL-Request	\N
477	2012-07-21 18:49:30.0306	110	26	ILL-Request	\N
478	2012-07-21 18:50:07.794706	110	92	ILL-Request	\N
479	2012-07-21 18:50:45.870087	110	30	ILL-Request	\N
480	2012-07-21 18:51:29.32297	110	99	ILL-Request	\N
481	2012-07-21 18:52:57.132228	136	92	ILL-Request	\N
482	2012-07-21 18:53:47.225234	136	99	ILL-Request	\N
483	2012-07-21 18:54:13.28817	136	30	ILL-Request	\N
484	2012-07-21 18:54:43.290717	136	94	ILL-Request	\N
485	2012-07-21 18:55:20.856915	136	92	ILL-Request	\N
486	2012-07-21 19:16:26.435627	11	79	ILL-Request	\N
487	2012-07-21 19:17:12.439193	11	38	ILL-Request	\N
488	2012-07-21 19:17:49.282118	11	38	ILL-Request	\N
489	2012-07-21 19:18:18.41665	11	31	ILL-Request	\N
490	2012-07-21 19:18:48.410866	11	38	ILL-Request	\N
491	2012-07-21 19:20:01.684802	12	34	ILL-Request	\N
492	2012-07-21 19:21:18.982541	12	35	ILL-Request	\N
493	2012-07-21 19:21:50.751196	12	135	ILL-Request	\N
494	2012-07-21 19:22:35.679651	12	30	ILL-Request	\N
495	2012-07-21 19:23:22.940929	12	79	ILL-Request	\N
496	2012-07-21 19:24:57.256329	13	85	ILL-Request	\N
497	2012-07-21 19:25:44.300473	13	84	ILL-Request	\N
498	2012-07-21 19:26:24.156391	13	30	ILL-Request	\N
499	2012-07-21 19:26:54.966487	13	101	ILL-Request	\N
501	2012-07-21 19:28:00.036449	13	83	ILL-Request	\N
502	2012-07-21 19:29:21.10743	14	48	ILL-Request	\N
503	2012-07-21 19:29:53.091694	14	36	ILL-Request	\N
504	2012-07-21 19:30:27.442201	14	38	ILL-Request	\N
505	2012-07-21 19:31:06.841015	14	92	ILL-Request	\N
506	2012-07-21 19:32:09.702411	15	92	ILL-Request	\N
507	2012-07-21 19:32:31.533922	15	26	ILL-Request	\N
508	2012-07-21 19:32:59.552778	15	25	ILL-Request	\N
509	2012-07-21 19:33:37.428861	15	83	ILL-Request	\N
510	2012-07-21 19:34:15.169595	15	78	ILL-Request	\N
511	2012-07-21 19:35:22.479653	16	94	ILL-Request	\N
512	2012-07-21 19:35:49.757457	16	98	ILL-Request	\N
514	2012-07-21 19:36:55.076529	16	68	ILL-Request	\N
515	2012-07-21 19:37:34.15993	16	79	ILL-Request	\N
516	2012-07-21 19:38:40.570255	17	45	ILL-Request	\N
517	2012-07-21 19:39:35.585988	17	134	ILL-Request	\N
518	2012-07-21 19:39:58.100425	17	94	ILL-Request	\N
519	2012-07-21 19:40:26.904293	17	83	ILL-Request	\N
520	2012-07-21 19:41:18.730408	17	26	ILL-Request	\N
521	2012-07-21 19:42:18.534706	19	20	ILL-Request	\N
522	2012-07-21 19:42:48.079495	19	83	ILL-Request	\N
523	2012-07-21 19:43:33.22503	19	38	ILL-Request	\N
524	2012-07-21 19:44:04.668678	19	98	ILL-Request	\N
525	2012-07-21 19:45:07.548227	19	26	ILL-Request	\N
526	2012-07-21 19:46:13.158882	18	38	ILL-Request	\N
527	2012-07-21 19:46:48.440479	18	20	ILL-Request	\N
528	2012-07-21 19:47:09.165148	18	30	ILL-Request	\N
529	2012-07-21 19:47:50.130946	18	99	ILL-Request	\N
530	2012-07-21 19:48:20.107321	18	101	ILL-Request	\N
531	2012-07-21 19:49:38.221983	119	30	ILL-Request	\N
532	2012-07-21 19:50:06.707135	119	98	ILL-Request	\N
533	2012-07-21 19:50:34.369015	119	101	ILL-Request	\N
534	2012-07-21 19:51:25.878461	119	44	ILL-Request	\N
535	2012-07-21 19:52:02.304648	119	26	ILL-Request	\N
536	2012-07-21 19:53:16.326568	20	99	ILL-Request	\N
537	2012-07-21 19:53:47.654262	20	33	ILL-Request	\N
538	2012-07-21 19:54:21.928418	20	99	ILL-Request	\N
539	2012-07-21 19:55:01.370121	20	100	ILL-Request	\N
540	2012-07-21 19:55:49.986925	20	20	ILL-Request	\N
541	2012-07-21 19:56:51.790881	22	84	ILL-Request	\N
542	2012-07-21 19:57:19.236058	22	94	ILL-Request	\N
543	2012-07-21 19:57:41.103235	22	85	ILL-Request	\N
544	2012-07-21 19:58:11.870129	22	44	ILL-Request	\N
545	2012-07-21 19:58:45.796172	22	72	ILL-Request	\N
546	2012-07-21 20:20:29.490421	21	31	ILL-Request	\N
547	2012-07-21 20:21:04.000214	21	48	ILL-Request	\N
548	2012-07-21 20:21:32.219523	21	99	ILL-Request	\N
549	2012-07-21 20:21:59.206715	21	101	ILL-Request	\N
550	2012-07-21 20:22:24.82171	21	85	ILL-Request	\N
551	2012-07-21 20:23:32.148046	23	84	ILL-Request	\N
552	2012-07-21 20:24:11.030848	23	99	ILL-Request	\N
553	2012-07-21 20:24:47.405647	23	91	ILL-Request	\N
554	2012-07-21 20:25:14.975953	23	20	ILL-Request	\N
555	2012-07-21 20:26:14.089132	23	26	ILL-Request	\N
556	2012-07-21 21:14:48.466143	24	79	ILL-Request	\N
557	2012-07-21 21:15:53.211453	24	101	ILL-Request	\N
558	2012-07-21 21:16:21.764679	24	99	ILL-Request	\N
559	2012-07-21 21:17:05.318732	24	35	ILL-Request	\N
560	2012-07-21 21:17:31.657095	24	83	ILL-Request	\N
561	2012-07-21 21:18:41.199716	25	38	ILL-Request	\N
562	2012-07-21 21:19:10.285656	25	83	ILL-Request	\N
563	2012-07-21 21:19:54.248878	25	71	ILL-Request	\N
564	2012-07-21 21:20:24.160614	25	78	ILL-Request	\N
565	2012-07-21 21:21:07.763732	25	79	ILL-Request	\N
566	2012-07-21 21:42:08.945711	26	84	ILL-Request	\N
567	2012-07-21 21:43:13.56536	26	92	ILL-Request	\N
569	2012-07-21 21:44:46.205089	26	101	ILL-Request	\N
570	2012-07-21 21:45:09.468963	26	101	ILL-Request	\N
571	2012-07-21 21:46:39.994442	28	83	ILL-Request	\N
572	2012-07-21 21:47:17.262092	28	36	ILL-Request	\N
573	2012-07-21 21:47:47.045012	28	44	ILL-Request	\N
574	2012-07-21 21:48:16.964506	28	84	ILL-Request	\N
575	2012-07-21 21:48:57.745539	28	68	ILL-Request	\N
576	2012-07-21 21:50:15.384394	103	11	ILL-Request	\N
577	2012-07-21 21:50:51.176934	103	83	ILL-Request	\N
578	2012-07-21 21:51:26.344612	103	38	ILL-Request	\N
579	2012-07-21 21:56:44.110799	103	26	ILL-Request	\N
580	2012-07-21 21:57:16.330174	103	45	ILL-Request	\N
581	2012-07-21 21:58:27.262599	27	99	ILL-Request	\N
582	2012-07-21 21:58:49.535628	27	36	ILL-Request	\N
583	2012-07-21 21:59:11.367166	27	134	ILL-Request	\N
584	2012-07-21 21:59:47.900049	27	91	ILL-Request	\N
585	2012-07-21 22:00:23.866465	27	10	ILL-Request	\N
586	2012-07-22 10:13:37.35611	30	94	ILL-Request	\N
587	2012-07-22 10:14:16.296446	30	20	ILL-Request	\N
588	2012-07-22 10:14:58.660137	30	99	ILL-Request	\N
589	2012-07-22 10:16:06.636367	30	100	ILL-Request	\N
590	2012-07-22 10:16:35.09856	30	83	ILL-Request	\N
591	2012-07-22 10:18:32.134721	29	78	ILL-Request	\N
592	2012-07-22 10:21:14.159172	29	\N	ILL-Request	\N
593	2012-07-22 10:22:44.150288	29	100	ILL-Request	\N
594	2012-07-22 10:23:46.728443	29	72	ILL-Request	\N
595	2012-07-22 10:25:32.688657	29	83	ILL-Request	\N
596	2012-07-22 10:27:18.054615	31	85	ILL-Request	\N
597	2012-07-22 10:28:11.604971	31	34	ILL-Request	\N
598	2012-07-22 10:28:38.276042	31	85	ILL-Request	\N
599	2012-07-22 10:29:04.239542	31	85	ILL-Request	\N
600	2012-07-22 10:29:33.901783	31	79	ILL-Request	\N
601	2012-07-22 10:31:36.558535	34	30	ILL-Request	\N
602	2012-07-22 10:32:59.562052	34	101	ILL-Request	\N
603	2012-07-22 10:33:49.139791	34	92	ILL-Request	\N
604	2012-07-22 10:34:20.199317	34	82	ILL-Request	\N
605	2012-07-22 10:35:32.21557	34	26	ILL-Request	\N
606	2012-07-22 10:37:19.82244	90	44	ILL-Request	\N
607	2012-07-22 10:37:51.392898	90	101	ILL-Request	\N
608	2012-07-22 10:38:20.203038	90	26	ILL-Request	\N
609	2012-07-22 10:38:59.426429	90	83	ILL-Request	\N
610	2012-07-22 10:39:30.996464	90	44	ILL-Request	\N
611	2012-07-22 10:40:58.445872	36	25	ILL-Request	\N
612	2012-07-22 10:41:33.845849	36	83	ILL-Request	\N
613	2012-07-22 10:42:03.988749	36	20	ILL-Request	\N
614	2012-07-22 10:42:32.867733	36	21	ILL-Request	\N
615	2012-07-22 10:43:17.689392	36	68	ILL-Request	\N
616	2012-07-22 10:44:48.078957	37	79	ILL-Request	\N
617	2012-07-22 10:45:40.35537	37	11	ILL-Request	\N
618	2012-07-22 10:46:50.255508	37	92	ILL-Request	\N
619	2012-07-22 10:47:24.522898	37	99	ILL-Request	\N
620	2012-07-22 10:48:03.737259	37	101	ILL-Request	\N
621	2012-07-22 10:49:49.794973	38	20	ILL-Request	\N
622	2012-07-22 10:50:37.841148	38	25	ILL-Request	\N
623	2012-07-22 10:51:09.658754	38	38	ILL-Request	\N
624	2012-07-22 10:51:48.840318	38	78	ILL-Request	\N
626	2012-07-22 10:54:14.205	38	99	ILL-Request	\N
627	2012-07-22 10:55:47.086264	40	38	ILL-Request	\N
628	2012-07-22 10:56:35.137675	40	101	ILL-Request	\N
629	2012-07-22 10:57:20.700234	40	21	ILL-Request	\N
630	2012-07-22 10:57:52.893485	40	83	ILL-Request	\N
631	2012-07-22 10:59:22.226418	39	85	ILL-Request	\N
632	2012-07-22 11:00:01.658589	39	84	ILL-Request	\N
633	2012-07-22 11:00:44.579223	39	101	ILL-Request	\N
634	2012-07-22 11:01:10.534548	39	101	ILL-Request	\N
635	2012-07-22 11:01:48.842409	39	83	ILL-Request	\N
636	2012-07-22 11:03:38.825348	42	79	ILL-Request	\N
637	2012-07-22 11:04:16.348835	42	79	ILL-Request	\N
638	2012-07-22 11:05:10.65667	42	26	ILL-Request	\N
639	2012-07-22 11:05:44.716274	42	26	ILL-Request	\N
640	2012-07-22 11:06:28.628882	42	20	ILL-Request	\N
641	2012-07-22 11:07:53.056224	43	101	ILL-Request	\N
642	2012-07-22 11:08:19.035962	43	101	ILL-Request	\N
643	2012-07-22 11:09:06.989343	43	25	ILL-Request	\N
644	2012-07-22 11:09:49.494223	43	26	ILL-Request	\N
645	2012-07-22 11:10:53.129969	43	34	ILL-Request	\N
648	2012-07-22 11:28:28.782138	44	20	ILL-Request	\N
649	2012-07-22 11:29:09.42417	44	100	ILL-Request	\N
650	2012-07-22 11:29:52.869551	44	101	ILL-Request	\N
651	2012-07-22 11:31:00.521931	44	78	ILL-Request	\N
652	2012-07-22 11:32:23.433075	44	101	ILL-Request	\N
653	2012-07-22 11:34:21.868093	98	79	ILL-Request	\N
654	2012-07-22 11:35:22.909038	98	94	ILL-Request	\N
655	2012-07-22 11:35:56.140495	98	83	ILL-Request	\N
656	2012-07-22 11:37:07.323399	98	100	ILL-Request	\N
657	2012-07-22 11:37:48.180822	98	38	ILL-Request	\N
658	2012-07-22 11:38:25.15412	98	25	ILL-Request	\N
659	2012-07-22 11:39:01.237802	98	38	ILL-Request	\N
660	2012-07-22 11:40:19.501132	45	82	ILL-Request	\N
661	2012-07-22 11:40:53.768686	45	20	ILL-Request	\N
662	2012-07-22 11:41:27.843107	45	134	ILL-Request	\N
663	2012-07-22 11:42:15.239098	45	31	ILL-Request	\N
664	2012-07-22 11:43:14.69361	45	79	ILL-Request	\N
665	2012-07-22 11:43:52.508851	45	68	ILL-Request	\N
666	2012-07-22 11:46:02.107394	47	35	ILL-Request	\N
667	2012-07-22 11:47:03.295993	47	30	ILL-Request	\N
668	2012-07-22 11:48:03.534143	47	25	ILL-Request	\N
669	2012-07-22 11:48:53.226583	47	92	ILL-Request	\N
670	2012-07-22 11:49:26.26119	47	26	ILL-Request	\N
671	2012-07-22 11:51:15.834451	46	25	ILL-Request	\N
672	2012-07-22 11:52:03.412682	46	134	ILL-Request	\N
673	2012-07-22 11:52:38.362898	46	83	ILL-Request	\N
674	2012-07-22 11:53:15.337171	46	83	ILL-Request	\N
675	2012-07-22 11:53:46.356832	46	84	ILL-Request	\N
676	2012-07-22 12:10:54.296881	50	134	ILL-Request	\N
677	2012-07-22 12:11:36.405782	50	83	ILL-Request	\N
678	2012-07-22 12:12:19.62396	50	72	ILL-Request	\N
679	2012-07-22 12:12:47.385903	50	99	ILL-Request	\N
680	2012-07-22 12:13:22.604143	50	38	ILL-Request	\N
681	2012-07-22 12:18:52.847732	51	79	ILL-Request	\N
682	2012-07-22 12:21:58.552021	51	20	ILL-Request	\N
683	2012-07-22 12:22:30.479767	51	\N	ILL-Request	\N
684	2012-07-22 12:23:15.45039	51	79	ILL-Request	\N
685	2012-07-22 12:24:07.825931	51	134	ILL-Request	\N
686	2012-07-22 12:25:26.597788	52	99	ILL-Request	\N
687	2012-07-22 12:26:00.713624	52	25	ILL-Request	\N
688	2012-07-22 12:26:42.678224	52	45	ILL-Request	\N
689	2012-07-22 12:27:09.281396	52	20	ILL-Request	\N
690	2012-07-22 12:27:35.061693	52	84	ILL-Request	\N
691	2012-07-22 12:28:58.556834	53	100	ILL-Request	\N
692	2012-07-22 12:29:45.593949	53	84	ILL-Request	\N
693	2012-07-22 12:30:18.660747	53	25	ILL-Request	\N
694	2012-07-22 12:31:24.396436	53	98	ILL-Request	\N
695	2012-07-22 12:31:57.123897	53	134	ILL-Request	\N
696	2012-07-22 12:33:12.912575	54	25	ILL-Request	\N
697	2012-07-22 12:34:05.013483	54	34	ILL-Request	\N
698	2012-07-22 12:34:57.280079	54	38	ILL-Request	\N
699	2012-07-22 12:35:37.17801	54	92	ILL-Request	\N
700	2012-07-22 12:36:13.09471	54	82	ILL-Request	\N
701	2012-07-22 12:43:00.454295	55	92	ILL-Request	\N
702	2012-07-22 12:44:02.025028	55	30	ILL-Request	\N
703	2012-07-22 12:44:29.478211	55	84	ILL-Request	\N
704	2012-07-22 12:45:09.592796	55	100	ILL-Request	\N
705	2012-07-22 12:45:44.559035	55	68	ILL-Request	\N
706	2012-07-22 14:20:45.141652	56	92	ILL-Request	\N
707	2012-07-22 14:21:17.158961	56	92	ILL-Request	\N
708	2012-07-22 14:21:43.113491	56	20	ILL-Request	\N
709	2012-07-22 14:22:09.152556	56	92	ILL-Request	\N
710	2012-07-22 14:23:06.998648	56	92	ILL-Request	\N
711	2012-07-22 14:24:10.418996	57	82	ILL-Request	\N
712	2012-07-22 14:24:33.216366	57	83	ILL-Request	\N
713	2012-07-22 14:25:22.334975	57	82	ILL-Request	\N
714	2012-07-22 14:25:51.896118	57	25	ILL-Request	\N
715	2012-07-22 14:26:27.63805	57	94	ILL-Request	\N
716	2012-07-22 14:27:24.419249	58	84	ILL-Request	\N
717	2012-07-22 14:27:46.242834	58	101	ILL-Request	\N
718	2012-07-22 14:28:10.982017	58	84	ILL-Request	\N
719	2012-07-22 14:28:43.608249	58	84	ILL-Request	\N
720	2012-07-22 14:29:21.525626	58	101	ILL-Request	\N
721	2012-07-22 14:30:48.27629	59	134	ILL-Request	\N
722	2012-07-22 14:31:30.522056	59	25	ILL-Request	\N
723	2012-07-22 14:32:12.144758	59	79	ILL-Request	\N
724	2012-07-22 14:32:46.636634	59	98	ILL-Request	\N
725	2012-07-22 14:33:44.648413	59	22	ILL-Request	\N
726	2012-07-22 14:34:35.261303	59	30	ILL-Request	\N
727	2012-07-22 14:35:37.073909	60	78	ILL-Request	\N
728	2012-07-22 14:36:26.509404	60	101	ILL-Request	\N
729	2012-07-22 14:36:48.781063	60	99	ILL-Request	\N
730	2012-07-22 14:37:12.946813	60	83	ILL-Request	\N
731	2012-07-22 14:39:21.234679	49	98	ILL-Request	\N
732	2012-07-22 14:39:41.134705	49	25	ILL-Request	\N
733	2012-07-22 14:39:57.527302	49	68	ILL-Request	\N
734	2012-07-22 14:40:19.132838	49	25	ILL-Request	\N
735	2012-07-22 14:40:40.82302	49	68	ILL-Request	\N
736	2012-07-22 14:41:59.793565	61	25	ILL-Request	\N
737	2012-07-22 14:42:19.609409	61	99	ILL-Request	\N
738	2012-07-22 14:42:38.425965	61	78	ILL-Request	\N
739	2012-07-22 14:43:11.512141	61	84	ILL-Request	\N
740	2012-07-22 14:43:48.443695	61	134	ILL-Request	\N
741	2012-07-22 14:44:41.609769	62	134	ILL-Request	\N
742	2012-07-22 14:45:05.915837	62	20	ILL-Request	\N
743	2012-07-22 14:45:30.104826	62	35	ILL-Request	\N
744	2012-07-22 14:46:09.244197	62	101	ILL-Request	\N
745	2012-07-22 14:46:40.145885	62	99	ILL-Request	\N
746	2012-07-22 14:48:04.799001	63	10	ILL-Request	\N
747	2012-07-22 14:48:42.430432	63	78	ILL-Request	\N
748	2012-07-22 14:49:38.354084	63	82	ILL-Request	\N
749	2012-07-22 14:50:09.697739	63	20	ILL-Request	\N
750	2012-07-22 14:50:33.63657	63	94	ILL-Request	\N
751	2012-07-22 14:51:37.732154	64	35	ILL-Request	\N
752	2012-07-22 14:52:24.209261	64	83	ILL-Request	\N
753	2012-07-22 14:52:44.110802	64	44	ILL-Request	\N
754	2012-07-22 14:53:19.95126	64	100	ILL-Request	\N
755	2012-07-22 14:53:53.92628	64	82	ILL-Request	\N
756	2012-07-22 14:56:50.892469	65	85	ILL-Request	\N
757	2012-07-22 14:57:39.93793	65	34	ILL-Request	\N
758	2012-07-22 14:58:12.548316	65	25	ILL-Request	\N
759	2012-07-22 14:58:47.248315	65	91	ILL-Request	\N
760	2012-07-22 14:59:15.359248	65	84	ILL-Request	\N
761	2012-07-22 15:00:29.36705	66	82	ILL-Request	\N
762	2012-07-22 15:00:56.379373	66	99	ILL-Request	\N
763	2012-07-22 15:01:27.172598	66	33	ILL-Request	\N
764	2012-07-22 15:01:54.393213	66	99	ILL-Request	\N
765	2012-07-22 15:02:32.542542	66	68	ILL-Request	\N
766	2012-07-22 15:03:35.830387	124	84	ILL-Request	\N
767	2012-07-22 15:04:03.417116	124	99	ILL-Request	\N
768	2012-07-22 15:04:27.613183	124	44	ILL-Request	\N
769	2012-07-22 15:04:57.408503	124	20	ILL-Request	\N
770	2012-07-22 15:05:19.731885	124	20	ILL-Request	\N
771	2012-07-22 15:06:36.169703	107	84	ILL-Request	\N
772	2012-07-22 15:07:15.152141	107	26	ILL-Request	\N
773	2012-07-22 15:07:48.844402	107	30	ILL-Request	\N
774	2012-07-22 15:08:32.474476	107	26	ILL-Request	\N
775	2012-07-22 15:09:02.88416	107	83	ILL-Request	\N
776	2012-07-22 15:10:15.584632	67	38	ILL-Request	\N
777	2012-07-22 15:10:49.524995	67	71	ILL-Request	\N
778	2012-07-22 15:11:14.289853	67	25	ILL-Request	\N
779	2012-07-22 15:11:45.058013	67	27	ILL-Request	\N
780	2012-07-22 15:12:24.182305	67	26	ILL-Request	\N
781	2012-07-22 15:13:41.409813	48	79	ILL-Request	\N
782	2012-07-22 15:14:30.919667	48	31	ILL-Request	\N
783	2012-07-22 15:15:00.404728	48	44	ILL-Request	\N
784	2012-07-22 15:15:45.525938	48	79	ILL-Request	\N
785	2012-07-22 15:16:20.325733	48	44	ILL-Request	\N
786	2012-07-22 15:17:50.742512	122	134	ILL-Request	\N
787	2012-07-22 15:18:25.492464	122	92	ILL-Request	\N
788	2012-07-22 15:19:01.177586	122	83	ILL-Request	\N
789	2012-07-22 15:19:38.040188	122	100	ILL-Request	\N
790	2012-07-22 15:20:46.325311	122	30	ILL-Request	\N
791	2012-07-22 15:22:33.883792	41	38	ILL-Request	\N
792	2012-07-22 15:23:21.369587	41	99	ILL-Request	\N
793	2012-07-22 15:25:20.088139	41	71	ILL-Request	\N
794	2012-07-22 15:25:41.703471	41	92	ILL-Request	\N
795	2012-07-22 15:26:18.819645	41	85	ILL-Request	\N
796	2012-07-22 15:27:33.717234	68	100	ILL-Request	\N
797	2012-07-22 15:28:03.355967	68	25	ILL-Request	\N
798	2012-07-22 15:28:38.548615	68	25	ILL-Request	\N
799	2012-07-22 15:29:19.603733	68	34	ILL-Request	\N
800	2012-07-22 15:29:47.408111	68	25	ILL-Request	\N
801	2012-07-22 16:55:17.867363	69	101	ILL-Request	\N
802	2012-07-22 16:55:53.657496	69	36	ILL-Request	\N
803	2012-07-22 16:56:15.96423	69	68	ILL-Request	\N
804	2012-07-22 16:56:49.206068	69	99	ILL-Request	\N
805	2012-07-22 16:57:37.401557	69	10	ILL-Request	\N
806	2012-07-22 16:58:43.469428	71	84	ILL-Request	\N
807	2012-07-22 16:59:12.698131	71	30	ILL-Request	\N
808	2012-07-22 16:59:44.174042	71	10	ILL-Request	\N
809	2012-07-22 17:00:12.262543	71	20	ILL-Request	\N
810	2012-07-22 17:00:48.028553	71	101	ILL-Request	\N
812	2012-07-22 17:02:29.92997	72	83	ILL-Request	\N
814	2012-07-22 17:03:33.316823	72	101	ILL-Request	\N
815	2012-07-22 17:03:58.147181	72	83	ILL-Request	\N
816	2012-07-22 17:05:07.757028	79	84	ILL-Request	\N
817	2012-07-22 17:05:34.36001	79	84	ILL-Request	\N
818	2012-07-22 17:06:22.855547	79	26	ILL-Request	\N
819	2012-07-22 17:06:55.030864	79	101	ILL-Request	\N
820	2012-07-22 17:07:37.152351	79	101	ILL-Request	\N
821	2012-07-22 17:09:00.472011	73	135	ILL-Request	\N
822	2012-07-22 17:10:12.788006	73	36	ILL-Request	\N
823	2012-07-22 17:10:44.641102	73	92	ILL-Request	\N
824	2012-07-22 17:11:14.835518	73	25	ILL-Request	\N
825	2012-07-22 17:11:52.167487	73	79	ILL-Request	\N
826	2012-07-22 17:13:21.541714	75	68	ILL-Request	\N
827	2012-07-22 17:13:55.343956	75	92	ILL-Request	\N
828	2012-07-22 17:14:16.632264	75	82	ILL-Request	\N
829	2012-07-22 17:14:49.103005	75	79	ILL-Request	\N
830	2012-07-22 17:15:16.679247	75	101	ILL-Request	\N
831	2012-07-22 17:16:19.975108	74	83	ILL-Request	\N
832	2012-07-22 17:17:11.800289	74	78	ILL-Request	\N
833	2012-07-22 17:18:08.699762	74	25	ILL-Request	\N
834	2012-07-22 17:19:57.947629	74	20	ILL-Request	\N
835	2012-07-22 17:20:33.181144	74	26	ILL-Request	\N
836	2012-07-22 17:21:40.166244	77	68	ILL-Request	\N
837	2012-07-22 17:22:20.822198	77	83	ILL-Request	\N
838	2012-07-22 17:22:54.982258	77	71	ILL-Request	\N
839	2012-07-22 17:23:48.605011	77	85	ILL-Request	\N
840	2012-07-22 17:24:52.909386	77	20	ILL-Request	\N
841	2012-07-22 17:26:33.3797	76	135	ILL-Request	\N
842	2012-07-22 17:27:09.878635	76	135	ILL-Request	\N
843	2012-07-22 17:27:53.125194	76	84	ILL-Request	\N
844	2012-07-22 17:28:32.522704	76	84	ILL-Request	\N
845	2012-07-22 17:29:34.144352	76	83	ILL-Request	\N
846	2012-07-22 17:31:15.188051	80	38	ILL-Request	\N
847	2012-07-22 17:31:51.99677	80	79	ILL-Request	\N
848	2012-07-22 17:32:31.344932	80	84	ILL-Request	\N
849	2012-07-22 17:33:39.646574	80	98	ILL-Request	\N
850	2012-07-22 17:34:22.083742	80	98	ILL-Request	\N
851	2012-07-22 17:36:00.880074	82	85	ILL-Request	\N
852	2012-07-22 17:36:29.307683	82	26	ILL-Request	\N
853	2012-07-22 17:36:51.056613	82	21	ILL-Request	\N
854	2012-07-22 17:37:33.728315	82	79	ILL-Request	\N
855	2012-07-22 17:38:35.090519	82	79	ILL-Request	\N
856	2012-07-22 17:42:40.51645	135	99	ILL-Request	\N
857	2012-07-22 17:43:17.249717	135	92	ILL-Request	\N
858	2012-07-22 17:43:58.656739	135	34	ILL-Request	\N
859	2012-07-22 17:44:29.617942	135	26	ILL-Request	\N
860	2012-07-22 17:45:46.089002	135	92	ILL-Request	\N
861	2012-07-22 17:46:54.773633	83	25	ILL-Request	\N
862	2012-07-22 17:47:24.759978	83	134	ILL-Request	\N
863	2012-07-22 17:48:18.510368	83	99	ILL-Request	\N
864	2012-07-22 17:49:12.833728	83	36	ILL-Request	\N
865	2012-07-22 17:49:45.644615	83	92	ILL-Request	\N
866	2012-07-22 17:50:48.339132	84	25	ILL-Request	\N
867	2012-07-22 17:51:23.956255	84	36	ILL-Request	\N
868	2012-07-22 17:51:59.338996	84	25	ILL-Request	\N
870	2012-07-22 17:53:18.326741	84	79	ILL-Request	\N
871	2012-07-22 17:54:29.809797	85	92	ILL-Request	\N
872	2012-07-22 17:54:59.480122	85	101	ILL-Request	\N
873	2012-07-22 17:55:24.159629	85	78	ILL-Request	\N
874	2012-07-22 17:55:46.316748	85	84	ILL-Request	\N
875	2012-07-22 17:56:13.628572	85	84	ILL-Request	\N
876	2012-07-22 17:57:18.380851	86	79	ILL-Request	\N
877	2012-07-22 17:57:46.917925	86	25	ILL-Request	\N
878	2012-07-22 17:58:17.362354	86	26	ILL-Request	\N
879	2012-07-22 17:58:51.430956	86	79	ILL-Request	\N
880	2012-07-22 17:59:27.808153	86	83	ILL-Request	\N
881	2012-07-22 18:00:43.969988	87	134	ILL-Request	\N
882	2012-07-22 18:01:22.027221	87	25	ILL-Request	\N
883	2012-07-22 18:02:03.398278	87	34	ILL-Request	\N
884	2012-07-22 18:02:39.249522	87	100	ILL-Request	\N
885	2012-07-22 18:03:02.213798	87	83	ILL-Request	\N
886	2012-07-22 18:04:24.349162	88	38	ILL-Request	\N
887	2012-07-22 18:04:51.49477	88	26	ILL-Request	\N
888	2012-07-22 18:05:39.671777	88	101	ILL-Request	\N
889	2012-07-22 18:06:08.099991	88	94	ILL-Request	\N
890	2012-07-22 18:06:33.430684	88	99	ILL-Request	\N
891	2012-07-22 18:07:31.228872	89	101	ILL-Request	\N
892	2012-07-22 18:07:57.665616	89	101	ILL-Request	\N
893	2012-07-22 18:08:28.118291	89	99	ILL-Request	\N
894	2012-07-22 18:09:06.672492	89	38	ILL-Request	\N
895	2012-07-22 18:09:36.554071	89	83	ILL-Request	\N
896	2012-07-22 18:10:43.980383	134	82	ILL-Request	\N
897	2012-07-22 18:11:22.394323	134	44	ILL-Request	\N
898	2012-07-22 18:11:52.622035	134	25	ILL-Request	\N
899	2012-07-22 18:12:21.417616	134	85	ILL-Request	\N
900	2012-07-22 18:12:51.320527	134	134	ILL-Request	\N
901	2012-07-22 18:26:20.164037	78	34	ILL-Request	\N
902	2012-07-22 18:27:04.092895	78	94	ILL-Request	\N
903	2012-07-22 18:28:46.454773	78	20	ILL-Request	\N
904	2012-07-22 18:30:31.846423	78	27	ILL-Request	\N
905	2012-07-22 18:31:16.975347	78	26	ILL-Request	\N
906	2012-07-22 18:33:12.038304	91	45	ILL-Request	\N
907	2012-07-22 18:33:35.760051	91	82	ILL-Request	\N
908	2012-07-22 18:34:02.40576	91	101	ILL-Request	\N
909	2012-07-22 18:35:00.645186	91	83	ILL-Request	\N
910	2012-07-22 18:35:57.418678	91	44	ILL-Request	\N
911	2012-07-22 18:37:12.808555	92	100	ILL-Request	\N
912	2012-07-22 18:37:44.293476	92	83	ILL-Request	\N
913	2012-07-22 18:38:18.111347	92	101	ILL-Request	\N
914	2012-07-22 18:39:54.790424	92	84	ILL-Request	\N
915	2012-07-22 18:40:51.930105	92	84	ILL-Request	\N
916	2012-07-22 18:42:11.276849	125	134	ILL-Request	\N
917	2012-07-22 18:42:45.562642	125	83	ILL-Request	\N
918	2012-07-22 18:43:16.332047	125	79	ILL-Request	\N
919	2012-07-22 18:44:13.462959	125	79	ILL-Request	\N
920	2012-07-22 18:44:58.280757	125	99	ILL-Request	\N
921	2012-07-22 18:46:30.921806	93	84	ILL-Request	\N
922	2012-07-22 18:47:46.480245	93	68	ILL-Request	\N
923	2012-07-22 18:48:25.920553	93	134	ILL-Request	\N
924	2012-07-22 18:48:57.746281	93	85	ILL-Request	\N
925	2012-07-22 18:49:29.682257	93	83	ILL-Request	\N
926	2012-07-22 18:50:30.927438	102	92	ILL-Request	\N
927	2012-07-22 18:50:51.640502	102	92	ILL-Request	\N
928	2012-07-22 18:51:21.978695	102	85	ILL-Request	\N
929	2012-07-22 18:51:46.318623	102	83	ILL-Request	\N
930	2012-07-22 18:52:26.056181	102	84	ILL-Request	\N
931	2012-07-22 18:53:42.754669	120	134	ILL-Request	\N
932	2012-07-22 18:54:08.842437	120	82	ILL-Request	\N
933	2012-07-22 18:54:50.438684	120	25	ILL-Request	\N
934	2012-07-22 18:56:07.045734	120	68	ILL-Request	\N
935	2012-07-22 18:56:44.769389	120	20	ILL-Request	\N
936	2012-07-22 18:58:39.898233	94	134	ILL-Request	\N
937	2012-07-22 18:59:17.630428	94	45	ILL-Request	\N
938	2012-07-22 18:59:52.130937	94	83	ILL-Request	\N
939	2012-07-22 19:00:31.128344	94	83	ILL-Request	\N
940	2012-07-22 19:01:15.566479	94	134	ILL-Request	\N
941	2012-07-22 19:02:30.381314	95	33	ILL-Request	\N
942	2012-07-22 19:03:17.343866	95	38	ILL-Request	\N
943	2012-07-22 19:04:00.890027	95	25	ILL-Request	\N
944	2012-07-22 19:04:29.675921	95	26	ILL-Request	\N
945	2012-07-22 19:05:11.675151	95	36	ILL-Request	\N
946	2012-07-22 19:06:26.262843	96	38	ILL-Request	\N
947	2012-07-22 19:07:26.308025	96	79	ILL-Request	\N
948	2012-07-22 19:08:50.495012	96	101	ILL-Request	\N
949	2012-07-22 19:09:19.24079	96	84	ILL-Request	\N
950	2012-07-22 19:10:01.410753	96	94	ILL-Request	\N
951	2012-07-22 19:11:47.603173	97	83	ILL-Request	\N
952	2012-07-22 19:12:20.21226	97	82	ILL-Request	\N
953	2012-07-22 19:12:44.584676	97	135	ILL-Request	\N
954	2012-07-22 19:13:12.996893	97	31	ILL-Request	\N
955	2012-07-22 19:14:37.073215	97	134	ILL-Request	\N
956	2012-07-22 19:16:34.101701	99	84	ILL-Request	\N
957	2012-07-22 19:17:02.554366	99	79	ILL-Request	\N
958	2012-07-22 19:17:29.417455	99	25	ILL-Request	\N
959	2012-07-22 19:18:07.191927	99	101	ILL-Request	\N
960	2012-07-22 19:18:56.343656	99	20	ILL-Request	\N
\.


--
-- TOC entry 1905 (class 0 OID 17480)
-- Dependencies: 152
-- Data for Name: requests_history; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY requests_history (request_id, ts, msg_from, msg_to, status, message) FROM stdin;
\.


--
-- TOC entry 1906 (class 0 OID 17483)
-- Dependencies: 153
-- Data for Name: search_statistics; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY search_statistics (sessionid, ts, pqf, duration, records) FROM stdin;
thisisatest-3957	2011-11-04 09:41:07.084859	@attr 1=4 @attr 2=3 @attr 4=2 "ducks"	1	0
thisisatest-4000	2011-11-04 09:45:26.316631	@attr 1=4 @attr 2=3 @attr 4=2 "ducks"	0	0
thisisatest-4004	2011-11-04 09:45:47.705167	@attr 1=4 @attr 2=3 @attr 4=2 "ducks"	0	0
thisisatest-4013	2011-11-04 09:47:40.842222	@attr 1=4 @attr 2=3 @attr 4=2 "ducks"	11	0
thisisatest-4046	2011-11-04 09:50:15.030303	@attr 1=4 @attr 2=3 @attr 4=2 "ducks"	1	0
thisisatest-4057	2011-11-04 09:52:55.351691	@attr 1=4 @attr 2=3 @attr 4=2 "ducks"	10	0
thisisatest-4208	2011-11-04 09:59:33.90824	@attr 1=4 @attr 2=3 @attr 4=2 "ducks"	11	0
thisisatest-4245	2011-11-04 10:02:54.844509	@attr 1=4 @attr 2=3 @attr 4=2 "ducks"	11	0
thisisatest-4376	2011-11-04 10:16:33.023842	@attr 1=4 @attr 2=3 @attr 4=2 "ducks geese"	2	5
485ad4a157af1972c11831da6d9e5b7d-4396	2011-11-04 10:19:08.192487	'@attr 1=4 @attr 2=3 @attr 4=2 "ducks"'	10	0
485ad4a157af1972c11831da6d9e5b7d-4432	2011-11-04 10:20:28.085067	'@attr 1=4 @attr 2=3 @attr 4=2 "ducks"'	20	100
485ad4a157af1972c11831da6d9e5b7d-4495	2011-11-04 10:27:05.641948	'@attr 1=4 @attr 2=3 @attr 4=2 "elephant"'	27	100
485ad4a157af1972c11831da6d9e5b7d-4533	2011-11-04 10:28:41.739675	'@attr 1=4 @attr 2=3 @attr 4=2 "solar system"'	8	39
485ad4a157af1972c11831da6d9e5b7d-4616	2011-11-04 10:36:44.513779	'@attr 1=4 @attr 2=3 @attr 4=2 "solar system"'	7	39
485ad4a157af1972c11831da6d9e5b7d-5197	2011-11-04 10:53:41.547763	'@attr 1=4 @attr 2=3 @attr 4=2 "10 little rubber ducks"'	9	13
485ad4a157af1972c11831da6d9e5b7d-4682	2011-11-04 10:41:53.86744	'@attr 1=4 @attr 2=3 @attr 4=2 "10 little rubber ducks"'	69	13
\.


--
-- TOC entry 1907 (class 0 OID 17492)
-- Dependencies: 154
-- Data for Name: sources; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY sources (request_id, sequence_number, library, call_number) FROM stdin;
466	1	99	undefined
467	1	91	034 HAC
468	1	101	289.9 BAR
468	2	20	B/Barlow
468	3	99	undefined
469	1	101	629.89263 GUT
470	1	34	791.45 BLACK
470	2	94	undefined
471	1	92	E Nev
471	2	85	E NEVIUS
471	3	73	JE.Nev
471	4	79	E NEV
472	1	44	J 595.78
472	2	48	E NEY
472	3	92	EZ 4
472	4	45	undefined
472	5	94	undefined
473	1	99	undefined
473	2	68	CRIME HUR
473	3	94	undefined
473	4	73	F.Hur
474	1	68	728.9/H
474	2	25	728.92209712 Hai
474	3	34	728.92 Hai
474	4	98	728.9220971 Hai
474	5	79	728.922 HAI
474	6	21	undefined
474	7	11	undefined
474	8	99	undefined
474	9	94	undefined
474	10	73	728.9220971 Hai
475	1	135	J E McCl
475	2	82	J E McCl
475	3	45	undefined
475	4	85	E MCCLOSKEY
475	5	34	J/E/McC
475	6	71	T/B McClo
475	7	99	undefined
475	8	35	E MCC
475	9	26	EF MCC,EF MCC
475	10	36	undefined
476	1	73	636.8 Fri
476	2	71	J636.8 Fri
477	1	26	ANF 641 CAR
477	2	16	637.3 Can
477	3	99	undefined
478	1	92	AUD J Deedy
479	1	30	undefined
480	1	99	undefined
481	1	92	PB L
481	2	99	undefined
481	3	79	PB LAV
481	4	73	F.PBMys
482	1	99	undefined
482	2	79	973.927 MOR
482	3	73	B.Rea
482	4	35	B REA
482	5	94	undefined
483	1	30	FIC HIL
483	2	31	FIC HIL
484	1	94	undefined
485	1	92	690.8 Spe
485	2	99	undefined
486	1	79	undefined
486	2	94	undefined
486	3	38	undefined
487	1	38	undefined
487	2	79	undefined
487	3	94	undefined
488	1	38	J FIC HOR
488	2	48	J HOR
488	3	98	J Pbk Ho
488	4	25	J Horvath
488	5	68	JF HOR
488	6	45	undefined
488	7	99	undefined
489	1	31	undefined
490	1	38	BB PRE
490	2	79	921 PRE PRE
490	3	25	B Presley
490	4	73	B.Pre
490	5	71	B Pre
490	6	33	undefined
490	7	94	undefined
490	8	21	undefined
490	9	27	920 PRE
491	1	34	FIC Walton 2006 M
491	2	92	Walton
491	3	68	FIC WAL
491	4	99	undefined
491	5	94	undefined
491	6	79	PB WAL
492	1	35	F BRO
493	1	135	PB F Eva
493	2	101	EVANO
493	3	20	Basement/F/Evanovich/M/c.2
493	4	78	F Eva
493	5	84	F Eva
493	6	82	F Eva
493	7	44	F Eva
493	8	83	F Eva v.14
493	9	73	F.Eva
493	10	25	F Evanovich
493	11	94	undefined
493	12	79	LP F EVA
493	13	91	S FIC EVA
493	14	11	undefined
493	15	17	undefined
493	16	48	F EVA
493	17	38	FIC EVA
493	18	134	F  EVA
493	19	99	undefined
493	20	92	Evanovich
493	21	26	AF EVA
494	1	30	YA FIC POR
495	1	79	Y.A. F HAW
495	2	92	T Hawthorne
495	3	99	undefined
495	4	26	JF HAW
495	5	94	undefined
495	6	91	S FIC HAW
496	1	85	E BROWNE
496	2	68	E B
496	3	94	undefined
496	4	21	undefined
496	5	99	undefined
497	1	84	796.962 Sca
497	2	99	undefined
498	1	30	JR B GER
498	2	31	JR B THO
499	1	101	92 MOO
499	2	99	undefined
500	1	134	398.209 SMI
500	2	26	ANF 133.109 SMI
500	3	73	133.1 Smi
500	4	21	undefined
500	5	91	A 133.1 SMI
500	6	36	undefined
501	1	83	J S Bai v.5
501	2	84	J S Bai v.5
501	3	134	J F DAD
501	4	91	J FIC DAD
501	5	34	J F Dadey
501	6	35	J DAD
501	7	68	EASY READ DAD
501	8	94	undefined
501	9	79	J F DAD
501	10	25	J Dadey
501	11	17	undefined
502	1	48	E ADA
502	2	38	E ADA GREEN 1
502	3	25	E Adams
502	4	99	undefined
502	5	94	undefined
502	6	35	J 629.225 ADA
503	1	36	undefined
504	1	38	undefined
504	2	79	undefined
505	1	92	Wambaugh
505	2	25	LP Wambaugh
505	3	94	undefined
505	4	34	LP Rotation
505	5	38	FIC WAM
505	6	134	F WAM
506	1	92	J 954 Kal
506	2	85	J 954.221 KALMAN
506	3	35	J 954 KAL
507	1	26	ANF BLA 333.8232
507	2	73	333.8 Bla
508	1	25	F Pratchett
508	2	99	undefined
508	3	91	A FIC PRA
509	1	83	LP F Rob v.3
509	2	84	LP F Rob v.3
509	3	82	LP F Rob v.3
509	4	135	PB F Rob v. 3
509	5	71	F Roberts
509	6	91	A FIC ROB
509	7	94	undefined
509	8	27	A FIC ROB
509	9	21	undefined
509	10	26	AF ROB r
509	11	79	PB ROB
509	12	68	FIC ROB
509	13	35	F ROB
509	14	25	F Roberts
509	15	45	undefined
509	16	16	Fic Rob
510	1	78	F Jan M
510	2	99	undefined
510	3	38	PB JAN
510	4	85	FIC JANCE
511	1	94	undefined
512	1	98	347.71014 Bat
512	2	99	undefined
513	1	20	J/811.54/LEE
513	2	83	J 811.54 Lee
513	3	84	J 811.54 Lee
513	4	82	J 811.54 Lee
513	5	135	J 811.54 Lee
513	6	68	E
514	1	68	E pb
515	1	79	J F LOR
515	2	68	TEEN FIC LOR
515	3	94	undefined
515	4	11	undefined
516	1	45	J 177.7 Pry
517	1	134	F WHY
517	2	68	FIC WHY
517	3	27	A FIC WHY (1)
517	4	79	F WHY
517	5	92	Whyte
517	6	98	Fic Wh
517	7	16	Fic Why
517	8	94	undefined
517	9	91	A FIC WHY
518	1	94	undefined
518	2	99	undefined
518	3	79	971.272 TOL
519	1	83	343.71014 Cla
519	2	68	343.71 PRINGLE
519	3	99	undefined
519	4	94	undefined
520	1	26	ANF 595.79 PAC
520	2	68	595.79 PAC
521	1	20	F/Steel
521	2	84	F Ste
521	3	83	LP F Ste
521	4	135	LP F Ste
521	5	78	F Ste
521	6	101	STEEL
521	7	48	F STE
521	8	98	Fic St
521	9	71	F Ste
521	10	38	FIC STE
521	11	26	AF STE
521	12	134	F STE
521	13	91	A FIC STE
521	14	99	undefined
521	15	21	undefined
521	16	94	undefined
521	17	68	fiction
521	18	34	F Steel 1995
521	19	25	LP Steel
521	20	79	F STE
521	21	45	undefined
521	22	16	FIC STE
521	23	33	undefined
522	1	83	808.88 Lau
522	2	82	808.88 Lau
522	3	84	808.88 Lau
522	4	26	ANF 818.540 LAU
522	5	99	undefined
522	6	21	undefined
522	7	36	undefined
522	8	94	undefined
522	9	17	undefined
523	1	38	FIC DEV
523	2	68	FIC DEV
523	3	16	Fic Dev
523	4	73	F.Dev
523	5	25	F Deveraux
523	6	26	AF DEV
523	7	134	F DEV
523	8	45	undefined
523	9	17	undefined
523	10	35	F DEV
523	11	98	Fic De
523	12	34	F / De-49
523	13	94	undefined
523	14	71	F Dev
524	1	98	158 Bus
524	2	25	158 Bus
524	3	71	158 Bus
524	4	16	158.2 Bus
524	5	94	undefined
525	1	26	JNF 621.36 STE
526	1	38	FIC BOO
526	2	94	undefined
526	3	99	undefined
527	1	20	Basement/F/Allen
528	1	30	undefined
529	1	99	undefined
529	2	68	FIC FOR
529	3	94	undefined
530	1	101	818.54 DAV
530	2	83	818.5408 Dav
530	3	85	814 .54 DAVIES,814 .54 DAVIES
530	4	99	undefined
530	5	68	818 DAV
530	6	38	FIC DAV
530	7	94	undefined
531	1	30	JR EASY WEB
531	2	31	JR EASY WEB
532	1	98	B Re
532	2	68	791.43 REEVE
532	3	38	B REE
532	4	99	undefined
532	5	73	B.Ree
532	6	94	undefined
532	7	11	undefined
533	1	101	649.1 GUR
533	2	99	undefined
533	3	79	649 .1 GUR
533	4	22	FRC 649.1 Gur-E
534	1	44	P Bra
535	1	26	AR STE
536	1	99	undefined
537	1	33	undefined
537	2	85	FIC TUROW,FIC TUROW
537	3	35	F TUR
537	4	94	undefined
537	5	91	A FIC TUR
537	6	27	A FIC TUR
537	7	92	Turow
537	8	38	FIC TUR
537	9	25	W F Turow
537	10	68	FIC TUR
537	11	98	Fic Myst Tu
537	12	34	F/Tu-86
537	13	16	Fic Tur
538	1	99	undefined
539	1	100	HT 57 Man Ser. 5 No. 1 c. 1
540	1	20	DVD/Ocean's/PG
541	1	84	J 567.918 Mat
541	2	83	J 567.918 Mat
541	3	82	J 567.918 Mat
541	4	79	J 567.9 MAT
542	1	94	undefined
542	2	99	undefined
543	1	85	E CLARKE
544	1	44	576.5
545	1	72	J523.45   Rin
546	1	31	FIC BAI M
547	1	48	F OKE
547	2	134	F OKE
547	3	26	AF OKE
547	4	92	Oke
547	5	25	LP Oke
547	6	34	F Oke,OKE
547	7	98	Fic Ok
547	8	94	undefined
547	9	22	undefined
548	1	99	undefined
549	1	101	CLARK
549	2	83	CF Cla v.4
549	3	99	undefined
549	4	25	F Clark
549	5	35	F CLA
550	1	85	LP WHITE
550	2	27	LP WHITE
550	3	71	F White LP
550	4	98	T.B. Wh
550	5	99	undefined
551	1	84	J 760 Wal
551	2	99	undefined
552	1	99	undefined
552	2	26	AF RAN
552	3	22	FICTION RAN
553	1	91	SF FIC MAR
554	1	20	F/Steel
554	2	83	F Ste
554	3	84	F Ste
554	4	82	F Ste
554	5	135	F Ste
554	6	78	LP F Ste
554	7	44	Rom Ste
554	8	48	STEEL,STEEL
554	9	98	LP Fic St
554	10	25	W LP Steel
554	11	99	undefined
554	12	45	undefined
554	13	16	Fic Ste
554	14	71	LPGF Steel
554	15	94	undefined
554	16	33	undefined
554	17	11	PS3569.T33828R37 2004,F STE,F STE,F STE,PS3569.T33828 R37 2004
554	18	21	undefined
554	19	91	A FIC STE
554	20	26	AF STE,ALP STE
554	21	22	undefined
554	22	27	LP STEEL
554	23	35	F STE
554	24	134	F STE
554	25	85	FIC STEEL,FIC STEEL
554	26	38	FIC STE
554	27	34	F/St-3
555	1	26	947
555	2	98	J 947 Mur
555	3	45	undefined
555	4	25	J 947 Murrell
555	5	94	undefined
556	1	79	undefined
556	2	38	undefined
556	3	94	undefined
557	1	101	WESLEY
557	2	98	Fic We
557	3	68	fiction
557	4	99	undefined
557	5	94	undefined
558	1	99	undefined
558	2	84	F Kel
558	3	135	F Kel
558	4	35	F KEL
558	5	79	F KEL
558	6	68	CRIME KEL
558	7	92	Kellerman
558	8	34	F/Ke-28 M
558	9	71	Mys/F Kellerman
558	10	85	FIC KELLERMAN,FIC KELLERMAN
558	11	94	undefined
558	12	38	FIC KEL
559	1	35	133.8 COL
560	1	83	PB F Mor
560	2	85	FIC MORSI
560	3	94	undefined
561	1	38	undefined
561	2	79	undefined
561	3	94	undefined
562	1	83	J 597.92 Mar
562	2	84	J 597.92 Mar
562	3	33	undefined
562	4	99	undefined
563	1	71	F/Moore (2) Shadrach
563	2	94	undefined
564	1	78	J 567.97 Lin
564	2	98	J 567.9129 Lin
564	3	99	undefined
564	4	91	J 567.9 LIN,REF 567.97 Lin
565	1	79	371.1023 TEA
565	2	94	undefined
566	1	84	J E Bre
566	2	83	J E Bre
566	3	82	J E Bre
566	4	44	E Bre
566	5	99	undefined
566	6	73	JE.Bre
566	7	134	E BRE
566	8	68	E B
566	9	85	E BRETT
566	10	92	E Bre
566	11	71	C/F Brett
566	12	35	E BRE
566	13	26	EF BRE
567	1	92	T Brown
569	1	101	ROY
569	2	85	J ROY,J ROY
569	3	99	undefined
569	4	17	undefined
569	5	79	J F ROY
569	6	38	J FIC ROY
569	7	91	J FIC ROY
569	8	94	undefined
569	9	35	J ROY
570	1	101	E TOMS
571	1	83	J 808.81933 Pre
571	2	84	J 808.81933 Pre
571	3	20	J/E/Prelutsky
571	4	26	EF PRE
571	5	34	J/E/Pre
571	6	27	E FIC PRE
571	7	99	undefined
572	1	36	undefined
573	1	44	909.09
574	1	84	PB SCFI Bov
574	2	101	BOVA
574	3	99	undefined
574	4	38	FIC BOV
574	5	22	undefined
575	1	68	J551.21/W
575	2	38	J 551.2122 WOO
575	3	26	JNF 521.3 WOO
575	4	94	undefined
576	1	11	undefined
576	2	38	MLDB-LP PIL
576	3	34	F/Pi-64
576	4	22	undefined
576	5	26	AF PIL,AF PIL
576	6	134	F PIL,F PIL
576	7	68	FIC PIL
576	8	25	LP Pilcher
576	9	71	F Pil
576	10	16	Fic Pil
577	1	83	F Fall v.2
577	2	25	F Fallon
577	3	134	F FAL . FANTASY
577	4	94	undefined
578	1	38	undefined
578	2	79	undefined
578	3	94	undefined
579	1	26	AF GRU,AF GRU
579	2	134	F GRU
579	3	73	F.PBGen
579	4	11	undefined
579	5	27	A FIC GRU
579	6	17	undefined
579	7	38	FIC GRU
579	8	92	Gruen
579	9	35	F GRU
579	10	68	FIC GRU
579	11	34	F Gruen 2007
579	12	71	F Gru
580	1	45	undefined
580	2	71	F Ros
580	3	98	Series Pbk Ro
580	4	38	FIC ROS
580	5	21	undefined
580	6	94	undefined
581	1	99	undefined
582	1	36	undefined
583	1	134	778.3 VEA
584	1	91	A FIC SOL
585	1	10	JNF 741.5 MAR
586	1	94	undefined
587	1	20	J/E/Rogers
587	2	38	E ROG YELLOW 1
587	3	71	C/F Rog
588	1	99	undefined
589	1	100	F 5050 McD
589	2	101	971.0647 McD
589	3	83	971.0647 MacD
589	4	38	971.0647 McD
589	5	99	undefined
589	6	134	971.0647 MCD
590	1	83	J E Joh
590	2	84	J E Joh
590	3	82	J E Joh
590	4	99	undefined
591	1	78	F Bal
591	2	82	F Bal
591	3	83	F Bal
591	4	84	F Bal
591	5	44	F Bal
591	6	101	BALDACC
591	7	20	F/Baldacci
591	8	79	F BAL
591	9	94	undefined
591	10	68	CRIME BAL
591	11	35	THRILLER F BAL
591	12	34	F Baldacc 2011
591	13	27	A FIC BAL
591	14	38	FIC BAL
591	15	92	LP Baldacci
591	16	25	W LP Baldacci
591	17	10	FIC BAL,FIC BAL
591	18	73	F.Bal
591	19	134	F BAL
593	1	100	Manitoba RurDev MPB pim3 c. 2
594	1	72	590 Bur
595	1	83	J S But v.8
595	2	82	J S But v.8
595	3	84	J S But s v.8
596	1	85	J R 599.221 HARE
597	1	34	791.45 BLACK
597	2	94	undefined
598	1	85	LP GALLAGHER
598	2	94	undefined
599	1	85	616.02 STERN
599	2	79	921 STE
599	3	99	undefined
600	1	79	PB WEB
600	2	27	A FIC WEB
601	1	30	FIC STE
601	2	31	FIC STE
602	1	101	CASTE
602	2	92	T Castellucci
602	3	68	TEEN FIC CAS
602	4	99	undefined
602	5	94	undefined
603	1	92	641.815 Gre
603	2	94	undefined
604	1	82	J 507.8 Zub
604	2	99	undefined
604	3	94	undefined
605	1	26	EF ALB
605	2	38	E ALB YELLOW 8
605	3	91	ER FIC ALB
605	4	36	undefined
606	1	44	YA Joh
607	1	101	BROOKS
607	2	85	T BROOKS,T BROOKS
607	3	35	T BRO
607	4	99	undefined
607	5	79	Y.A. F BRO
607	6	68	TEEN FIC BRO
607	7	94	undefined
608	1	26	JF PAU
608	2	98	J Pbk Pa
609	1	83	CF Gun
609	2	84	CF Gun
609	3	82	CF Gun
609	4	92	Gunn
609	5	99	undefined
609	6	26	AF GUN
610	1	44	F Cus
610	2	20	F/Cussler
610	3	99	undefined
611	1	25	J Duane
611	2	68	TEEN DUA
611	3	94	undefined
611	4	11	FICTION Duane
611	5	99	undefined
612	1	83	J 591.03 Din
612	2	44	J 599.32
612	3	20	J/599/Nature
612	4	99	undefined
612	5	45	undefined
612	6	38	J 599.7357 DIN
612	7	35	J 599.73 DIN
612	8	71	J599.32 Din
612	9	26	599.322
612	10	94	undefined
613	1	20	690.184/Decks
613	2	78	690.184
613	3	33	690.184 Dec
613	4	25	690.184 Decks
613	5	99	undefined
613	6	85	VID DECKS 847
613	7	94	undefined
614	1	21	F ESSEX
615	1	68	FIC SAW
616	1	79	PB WHY
616	2	134	F WHY
616	3	11	undefined
616	4	98	Fic Wh
616	5	94	undefined
617	1	11	undefined
618	1	92	GN Cosby
619	1	99	undefined
619	2	94	undefined
620	1	101	FIC GRAY
621	1	20	F/Slaughter/M
621	2	78	F Sla M
621	3	25	W F Slaughter
621	4	99	undefined
621	5	33	undefined
621	6	94	undefined
621	7	45	undefined
621	8	85	FIC SLAUGHTER,FIC SLAUGHTER
621	9	68	CRIME SLA
621	10	71	Mys/F Slaughter
621	11	38	FIC SLA
622	1	25	LP Preston
622	2	73	F.Pre
622	3	92	LP Preston
622	4	79	F PRE
622	5	134	F PRE
622	6	26	AF PRE
622	7	94	undefined
622	8	34	F Preston 2010
623	1	38	YA FRA
623	2	10	FIC FRA
623	3	68	FIC FRA
623	4	94	undefined
624	1	78	AB F Chr
625	1	79	702.81 STE
626	1	99	undefined
626	2	79	702.81 STE
627	1	38	undefined
627	2	79	undefined
627	3	94	undefined
628	1	101	BUNTING
628	2	99	undefined
628	3	79	E BUN
628	4	94	undefined
629	1	21	J 398.20947 SHA
630	1	83	796.352 MacC
630	2	134	796.352 MCC
630	3	10	796.35 McC
630	4	94	undefined
630	5	79	796.352 MCC
630	6	11	undefined
630	7	36	undefined
631	1	85	E EDWARDS
631	2	99	undefined
631	3	94	undefined
631	4	21	undefined
631	5	22	undefined
632	1	84	503 Han
632	2	99	undefined
633	1	101	FIC MODES
633	2	84	F Mod
633	3	92	Modesitt, Jr
633	4	99	undefined
633	5	79	F MOD
634	1	101	TOLKIEN
634	2	82	OS J F Tol
634	3	84	J F Tol
634	4	83	J F Tol
634	5	99	undefined
635	1	83	PB F Neg
635	2	84	PB F Neg
635	3	78	F NEG M
635	4	25	F Neggers
635	5	85	FIC NEGGERS
635	6	38	FIC NEG
635	7	99	undefined
635	8	45	undefined
635	9	34	F/Ne-31
635	10	71	F/Neggers
635	11	91	A FIC NEG,FIC NEG
636	1	79	121.3 WAT
636	2	71	undefined
637	1	79	undefined
637	2	38	undefined
637	3	94	undefined
638	1	26	ANF 914 MIC
638	2	10	914.5 FOD
638	3	38	945.092 ITA
638	4	98	945 Ita
639	1	26	JNF 811.540
639	2	38	J 811.5408
639	3	92	J 811.54 Boo
639	4	99	undefined
639	5	45	undefined
639	6	94	undefined
640	1	20	J/917/Canadian
640	2	84	J 917.12 Wat
640	3	83	J 917.12 Wat
640	4	82	J 917.12 Wat
640	5	44	917.12
640	6	94	undefined
640	7	91	917.12 WAT
641	1	101	92 CAR
641	2	99	undefined
641	3	35	364.1 FOL
642	1	101	PARKER
642	2	82	F Par
642	3	83	F Par
642	4	84	F Par
642	5	99	undefined
642	6	92	Parker
642	7	79	F PAR
642	8	134	F PAR
642	9	94	undefined
643	1	25	J/574.626/41/Gre
643	2	134	J 577.34 GRE
643	3	10	JNF 574.52 GRE
643	4	35	J 578 GRE
643	5	92	J 577.34 Gre
643	6	45	undefined
643	7	98	J 574.52642 Gre
643	8	94	undefined
644	1	26	AF PAT
644	2	44	Mys Pat
644	3	20	F/Patterson
644	4	83	F Pat
644	5	84	F Pat
644	6	135	F Pat
644	7	78	F Pat Th
644	8	82	PB F Pat
644	9	101	PATTERS
644	10	99	undefined
644	11	94	undefined
644	12	22	undefined
644	13	10	FIC PAT
644	14	27	A FIC PAT
644	15	25	W LP Patterson
644	16	85	FIC PATTERSON,FIC PATTERSON
644	17	68	CRIME PAT
644	18	16	FIC PAT
644	19	71	His/F Patterson
644	20	38	FIC PAT
645	1	34	745.59 Joy
645	2	99	undefined
646	1	134	F STE
646	2	79	F STE
646	3	16	Fic Ste
646	4	26	AF STE
646	5	68	FIC STE
646	6	34	F/St-3
646	7	35	F STE
646	8	99	undefined
646	9	73	LP.PLS
646	10	27	A FIC STE
646	11	33	STEEL
646	12	38	FIC STE
646	13	22	undefined
646	14	25	LP Steel
646	15	10	FIC STE
647	1	20	F/Steel
647	2	83	F Ste
647	3	84	F Ste
647	4	82	F Ste
647	5	78	F Ste
647	6	135	PB F Ste
647	7	101	STEEL
647	8	44	Rom Ste
647	9	79	F STE
647	10	16	Fic Ste
647	11	45	undefined
647	12	34	F/St-3
647	13	68	FIC STE
648	1	20	F/Steel
648	2	83	F Ste
648	3	84	F Ste
648	4	82	F Ste
648	5	78	F Ste
648	6	135	PB F Ste
648	7	101	STEEL
648	8	44	Rom Ste
648	9	79	F STE
648	10	71	F Ste,F STEEL,F/Steel,FIC STE,Fic,F Steel,F Ste,F Steel,FIC STE,F STE,Rom Ste,F Steel,F Ste,F/Ste,A
648	11	68	LP FIC STE
648	12	16	Fic Ste
648	13	45	undefined
648	14	34	F/St-3
648	15	27	A FIC STE
648	16	98	Fic St
648	17	99	undefined
648	18	38	FIC STE
648	19	33	STEEL
648	20	22	undefined
648	21	134	F STE
648	22	73	LP.PLS
648	23	25	LP Steel
648	24	10	FIC STE
648	25	26	AF STE
648	26	35	F STE
649	1	100	Manitoba SpR 2001 Climate Change
649	2	68	551.5 MAN
649	3	99	undefined
650	1	101	CARR
650	2	84	F Car
650	3	83	F Car
650	4	26	AF CAR
651	1	78	636 Mig
652	1	101	92 BUT
653	1	79	undefined
653	2	38	undefined
653	3	99	undefined
654	1	94	undefined
655	1	83	F Bla
655	2	98	Fic Bl
655	3	94	undefined
655	4	99	undefined
656	1	100	Canada CMHC heos
656	2	99	undefined
657	1	38	FIC LEO
657	2	99	undefined
657	3	27	A FIC LEO
657	4	36	undefined
658	1	25	F Fisher
658	2	82	CF Fis
658	3	84	CF Fis
658	4	83	CF Fis
658	5	26	AF FIS
658	6	71	F Fis
659	1	38	635.7 HOL
659	2	134	635.7 HOL,635.7 HOL
659	3	98	635.7 Hol
659	4	45	undefined
659	5	34	635.7 Hol
659	6	92	635.7 Hol
659	7	27	635 HOL
660	1	82	LP F Dev
660	2	44	Rom Dev
660	3	135	PB F Dev
660	4	71	F/Deveraux
660	5	98	Fic De
660	6	38	FIC DEV
660	7	79	LP F DEV
660	8	33	Fic Dev,DEVERAU,F,F,F,F DEVERAUX,F Dev - E,F Dev - M
660	9	99	undefined
660	10	94	undefined
660	11	21	undefined
660	12	26	AF DEV,AF DEV
660	13	83	F Dev
660	14	84	F Dev
660	15	22	F DEV
660	16	10	FIC DEV
660	17	25	LP Deveraux
660	18	85	LP DEVERAUX
660	19	34	DEVERAU
660	20	45	undefined
660	21	16	Fic Dev
661	1	20	Basement/F/Davies
661	2	34	F/Da-28
661	3	68	fiction
661	4	98	Fic Da
661	5	99	undefined
661	6	94	undefined
661	7	91	A FIC DAV
662	1	134	GN F MAR
662	2	99	undefined
662	3	79	J 741.5 MAR
662	4	94	undefined
663	1	31	JR FIC COL
664	1	79	LP 345.766 GRI
664	2	35	undefined
664	3	68	364.1523 GRI
664	4	17	undefined
664	5	36	undefined
664	6	21	undefined
664	7	22	undefined
664	8	26	AF GRI
664	9	134	F GRI
664	10	92	345.7 Gri
664	11	73	364.1523 Gri
664	12	45	undefined
664	13	38	345.766 GRI
665	1	68	JF WIL
665	2	45	undefined
665	3	98	J Pbk Wi
665	4	71	Y/MYS Wil
665	5	134	J F WIL
665	6	99	undefined
665	7	94	undefined
665	8	36	undefined
665	9	91	J FIC WIL
666	1	35	MYSTERY F ROB
666	2	79	F ROB c.1,F ROB c.2
666	3	134	F ROB
666	4	26	AF ROB
666	5	27	A FIC ROB
667	1	30	395 MEA
668	1	25	F Christie
668	2	134	F CHR
668	3	94	undefined
668	4	34	PBK F CHRISTI
668	5	68	CRIME CHR
668	6	26	AF CHR m
668	7	99	undefined
668	8	73	F.PBMys
668	9	91	A FIC CHR
668	10	10	FIC CHR
669	1	92	J B
669	2	25	J Babbitt
669	3	11	undefined
669	4	17	undefined
669	5	35	J BAB
669	6	22	undefined
669	7	91	J FIC BAB
669	8	26	JF BAB
669	9	134	J F BAB
669	10	99	undefined
669	11	79	J F BAB
669	12	45	undefined
669	13	98	J Pbk Ba
669	14	27	J FIC BAB
669	15	10	JF BAB
670	1	26	ANF 646.7 HAN
671	1	25	796.964 Russell
671	2	73	796.964 Rus
671	3	85	796.964 RUSSELL,796.964 RUSSELL
671	4	35	796.96 RUS
671	5	26	ANF 796.964 RUS
671	6	94	undefined
672	1	134	J F GIP
672	2	10	JF GIP
672	3	26	JF GIP
672	4	45	undefined
672	5	11	J/GIPSON
672	6	73	JR.Gip
672	7	94	undefined
673	1	83	F Hem
673	2	84	F Hem
673	3	25	F Hemingway
673	4	92	Hemingway
673	5	68	FIC HEM
673	6	79	F HEM
673	7	38	FIC HEM
673	8	34	F/He-37
673	9	98	Fic He
673	10	10	CLASSIC HEM
673	11	33	undefined
674	1	83	823.912 Aga
674	2	94	undefined
675	1	84	629.2872 Scl
675	2	99	undefined
675	3	21	undefined
675	4	26	ANF 629.2 SCL
676	1	134	623.87234 SHE
676	2	79	623.87 SHE
676	3	99	undefined
676	4	92	623.87234 She
676	5	94	undefined
677	1	83	F Rus
677	2	92	Russell
677	3	79	F RUS
677	4	94	undefined
678	1	72	636.72 Kno
679	1	99	undefined
679	2	79	636.728 STA
679	3	36	undefined
680	1	38	undefined
680	2	79	undefined
680	3	94	undefined
681	1	79	J 799.1 SZU
681	2	26	JNF/799.109/SZU
681	3	68	J799.1097127 SZU
681	4	35	E SZU,J SZU
681	5	38	E SZU Orange 5
681	6	11	undefined
681	7	91	ER FIC SZU
682	1	20	J/E/Denton
682	2	100	PS 8557 Den
682	3	25	E Denton
682	4	38	E McD YELLOW 7
682	5	79	E DEN
682	6	26	EF DEN
682	7	10	C DEN
682	8	94	undefined
682	9	33	undefined
684	1	79	F LON
684	2	38	FIC LON
684	3	10	FIC LON
684	4	98	Classic Pbk Lo
684	5	134	F LON
684	6	94	undefined
684	7	71	Y/ADV Lon
684	8	16	Fic Lon
685	1	134	F DAV
685	2	38	FIC DAV
685	3	25	F Davidson
685	4	27	A FIC DAV
685	5	73	F.Dav
685	6	45	undefined
685	7	98	Fic Myst Da
685	8	71	Mys/F Dav
686	1	99	undefined
687	1	25	910.9163 Jas
687	2	79	910.9163 JAS
687	3	68	910 JAS
687	4	34	910.9 Jas
687	5	94	undefined
687	6	73	910.9163 Jas
687	7	22	undefined
687	8	38	910.9163 JAS
687	9	134	910.9163 JAS
687	10	98	910.9163327 Jas
687	11	35	B JAS
687	12	99	undefined
687	13	10	910.91 JAS
687	14	26	ANF 910.91 JAS
688	1	45	undefined
688	2	68	917.12/L
688	3	33	undefined
689	1	20	F/Cussler
689	2	83	PB F Cus v.11
689	3	91	A FIC CUS
689	4	35	F CUS
689	5	26	undefined
689	6	44	F Cus
689	7	68	FIC CUS
689	8	99	undefined
689	9	94	undefined
689	10	134	F CUS
689	11	33	Fic Cus
689	12	21	undefined
690	1	84	305.9 Sha
690	2	101	305.90695 SHA
690	3	92	305.4 Sha
690	4	68	305.90695082096751
690	5	35	305.9 SHA
691	1	100	Manitoba CultHR HRB
691	2	99	undefined
692	1	84	F Sil
692	2	44	F Sil
692	3	101	FIC SILVA
692	4	20	F/Silva
692	5	134	F SIL
692	6	25	F Silva
692	7	79	F SIL
692	8	92	Silva
692	9	26	AF SIL
692	10	35	F SIL
692	11	22	F Sil-E
693	1	25	F Carey
693	2	85	FIC CAREY,FIC CAREY
694	1	98	Disc Mo
695	1	134	J F LOW
695	2	10	JF LOW
695	3	11	undefined
695	4	94	undefined
695	5	91	J FIC LOW
695	6	25	J Lowry
695	7	79	J F LOW
695	8	26	JF LOW
695	9	68	JF LOW
695	10	99	undefined
695	11	92	J Lowry
695	12	45	undefined
695	13	98	J Fic Lo
696	1	25	J Wilson
696	2	68	JF
696	3	45	undefined
696	4	98	J Pbk Wi
696	5	35	J WIL
696	6	11	HV8158 .C44 1985,FICTION/WIL/1985,JF WIL,JF WIL,JF WIL,JF WIL,JF WIL,JF WIL,JF WIL,JF WIL,JF WIL,JF
696	7	10	JF WIL,JF WIL
696	8	26	JF WIL
696	9	91	J FIC WIL
697	1	34	J Sewell 1980
697	2	25	J Sewell
697	3	94	undefined
697	4	91	J FIC SEW
697	5	68	JGN 741.5 SEW
697	6	98	J Fic Se
697	7	99	undefined
697	8	11	undefined
697	9	45	undefined
697	10	71	Y/ANI Sew
698	1	38	undefined
698	2	79	undefined
698	3	94	undefined
699	1	92	917.204 Mex
699	2	99	undefined
699	3	68	T820 volume 1,T820 volume 2
699	4	94	undefined
699	5	98	M-56
699	6	34	972
700	1	82	J 927.86 Fra
700	2	84	J 927.86 Fra
700	3	83	J 927.86 Fra
700	4	79	J 972.86 FRA
701	1	92	J 949.5 Ada
701	2	85	J 949.5 ADARE
702	1	30	JR 958.1 WHI
702	2	31	JR 958.1 WHI
703	1	84	F Eco
703	2	44	F Eco
703	3	68	fiction
703	4	71	F Eco
703	5	98	Fic Ec
703	6	99	undefined
703	7	10	FIC ECO
704	1	100	Canada CMHC heos
704	2	99	undefined
704	3	92	915.904 Tha
704	4	94	undefined
705	1	68	J959.7 KAL
706	1	92	595.799 Pac
706	2	79	595.799 PAC
706	3	26	ANF 595.79 PAC
706	4	68	595.79 PAC
706	5	94	undefined
707	1	92	Vinge
707	2	68	SF VIN
707	3	99	undefined
707	4	79	F VIN
707	5	94	undefined
708	1	20	F/Vinge/ScF-Fan
708	2	92	Vinge
708	3	68	SF VIN
708	4	99	undefined
708	5	79	PB VIN
709	1	92	PB V
709	2	68	SF VIN
709	3	99	undefined
710	1	92	PB V
710	2	99	undefined
710	3	79	PB VIN
711	1	82	813.54 Asi
711	2	79	921 ASI ASI
712	1	83	F Asi v.3
712	2	79	PB ASI
712	3	26	AF ASI sf
712	4	99	undefined
713	1	82	F Asi
713	2	134	F ASI . SCI-FI
713	3	99	undefined
713	4	68	SF ASI
713	5	45	undefined
713	6	38	FIC ASI
713	7	98	Fic Sci As
713	8	22	PS 3551 S62 N686 1990,FIC SF,PS3551.S5 N5 1990,PZ481.N52 1990,FICTION/ASI,F ASI,F ASI,F ASI,F ASI,P
714	1	25	F Asimov
714	2	68	SF
714	3	79	F ASI
714	4	26	AF ASI
714	5	10	SF ASI
715	1	94	undefined
716	1	84	PB SCFI Bov
716	2	101	BOVA
716	3	99	undefined
716	4	79	F BOV
716	5	38	FIC BOV
716	6	22	undefined
717	1	101	BOVA
717	2	83	PB SCFI Bov
717	3	84	PB SCFI Bov
717	4	82	PB SCFI Bov
717	5	99	undefined
718	1	84	F Bov
718	2	82	F Bov
718	3	99	undefined
718	4	92	Bova
718	5	79	PB BOV
718	6	22	SF Bova-E
719	1	84	F Bov
719	2	99	undefined
719	3	79	PB BOV
720	1	101	FIC BOVA
720	2	84	F Bov
720	3	99	undefined
720	4	79	PB BOV
721	1	134	F CLA . SCI-FI,F CLA . SCI-FI
721	2	25	F Clarke
721	3	38	FIC CLA
721	4	68	SF CLA
721	5	10	SF CLA
721	6	98	Fic Sci Cl
722	1	25	F Clarke
722	2	99	undefined
722	3	38	FIC CLA
723	1	79	F CLA
723	2	85	FIC CLARKE
724	1	98	Fic Sci Cl
724	2	99	undefined
724	3	26	AF CLA sf
724	4	91	A FIC CLA
725	1	22	F Cla-E SF
726	1	30	undefined
727	1	78	F Dra S. F
727	2	101	DRAKE
727	3	20	F/Drake/ScF-Fan
727	4	79	PB DRA
727	5	68	SF DRA
727	6	99	undefined
727	7	73	F.PBHor
728	1	101	FIC DRAKE
728	2	84	F Dra v.2
728	3	83	F Dra v.2
728	4	92	Drake
728	5	79	PB DRA
728	6	99	undefined
729	1	99	undefined
729	2	92	PB D
730	1	83	PB SCFI Dra
730	2	84	PB FANT Dra
730	3	82	PB FANT Dra
730	4	135	PB FANT Dra
730	5	26	AF DRA sf
730	6	99	undefined
731	1	98	Fic Sci Ed
731	2	71	Sc/F Edd
731	3	134	F EDD
731	4	10	SF EDD
731	5	99	undefined
732	1	25	F Eddings
732	2	68	SF EDD
732	3	11	undefined
732	4	99	undefined
732	5	79	PB EDD
732	6	26	AF EDD sf
732	7	91	S FIC EDD
733	1	68	SF
733	2	79	PB EDD
733	3	26	AF EDD
733	4	98	Sci Pbk Ed
733	5	99	undefined
733	6	91	S FIC EDD
734	1	25	F Eddings
734	2	85	FIC EDDINGS
734	3	68	SF EDD
734	4	134	F EDD . FANTASY
734	5	99	undefined
734	6	27	A FIC EDD BOOK 1
735	1	68	SF EDD
735	2	38	FIC EDD
735	3	34	F Eddings 1994
735	4	26	AF EDD s
735	5	71	F Edd
735	6	98	Sci Pbk Ed
735	7	99	undefined
735	8	91	A FIC EDD
736	1	25	F Dunn
736	2	135	F Dun
736	3	79	PB DUN
736	4	99	undefined
737	1	99	undefined
737	2	94	undefined
738	1	78	635 Rio
738	2	83	635 Rio
738	3	84	635 Rio
738	4	82	635 Rio
738	5	135	635 Rio
738	6	26	ANF 635 RIO
738	7	79	635 RIO
738	8	38	635 RIO
738	9	16	635 Rio
738	10	94	undefined
738	11	27	635 RIO
738	12	99	undefined
739	1	84	ON ORDER
739	2	99	undefined
739	3	79	J 811.54 FIT
740	1	134	307.1416 BOG
740	2	79	921 LEH BOG
740	3	38	B LEH
740	4	35	B LEH
740	5	94	undefined
741	1	134	641.3373 BLA
742	1	20	F/Christie/M
742	2	101	CHRISTIE
742	3	83	F Chr
742	4	84	PB F Chr
742	5	82	F Chr
742	6	135	PB F Chr
742	7	45	undefined
742	8	16	Fic Chr
742	9	34	F/Ch-46 M
742	10	35	MYS CHR
742	11	98	Fic Myst Ch
742	12	26	AF CHR
742	13	21	undefined
742	14	22	undefined
743	1	35	338.7 SCH
743	2	85	647.45 SCHULTZ
743	3	21	undefined
743	4	98	B Sch
743	5	99	undefined
744	1	101	LISS
744	2	84	F Lis
744	3	85	FIC LISS
744	4	68	FIC LIS
744	5	99	undefined
744	6	94	undefined
745	1	99	undefined
745	2	33	undefined
746	1	10	JNF 741.58 JEN
746	2	99	undefined
746	3	21	undefined
746	4	94	undefined
747	1	78	J 741.56973 Wat
747	2	83	741.5973 Wat
747	3	82	741.5973 Wat
747	4	35	741.5 WAT
747	5	68	741.5973 WAT
747	6	94	undefined
747	7	25	J 741.5 Wat
747	8	79	741.5973 WAT,741.5973 WAT
747	9	134	GN F WAT
747	10	99	undefined
747	11	45	undefined
747	12	26	JF WAT
747	13	10	JF WAT
748	1	82	OS J 741.2 Wel
748	2	83	J 741.2 Wel
748	3	84	J 741.2 Wel
748	4	99	undefined
748	5	94	undefined
749	1	20	J/743.6/Bolognese
749	2	79	743 BOL
749	3	71	J743 Bol
750	1	94	undefined
750	2	34	745.59 McK
750	3	26	ANF 745.594 MCK
750	4	21	undefined
750	5	22	undefined
751	1	35	E NEW
751	2	94	undefined
752	1	83	F Mar v.4
752	2	82	PB FANT Mar v.4
752	3	25	F Martin
752	4	27	A FIC MAR
752	5	79	PB MAR,F MAR
752	6	92	Martin
752	7	99	undefined
752	8	134	F MAR . FANTASY
752	9	34	PBK F Martin 2005
752	10	94	undefined
752	11	26	AF MAR
752	12	35	F MAR
753	1	44	639.97
754	1	100	HD 62.6 Pid 2006
755	1	82	PB HARL Wen
755	2	26	AR WEN
756	1	85	690.1823 COMPLETE
756	2	26	ANF 690/.1823 COM
756	3	94	undefined
757	1	34	748.59 Cow
757	2	94	undefined
758	1	25	690.893
758	2	79	690.893 COM
758	3	99	undefined
758	4	92	690.893 Com
758	5	38	690 .893 THE
758	6	35	690 BLA
758	7	94	undefined
759	1	91	A FIC KAY
760	1	84	F Atw
760	2	83	F Atw
760	3	82	F Atw
760	4	44	F Atw
761	1	82	641.578 Yaf
761	2	92	641.578 Yaf
762	1	99	undefined
762	2	94	undefined
763	1	33	undefined
763	2	26	ANF 641.5 MCM
764	1	99	undefined
764	2	16	FL 796.54 Jac
764	3	11	undefined
765	1	68	796.54 MAS
765	2	99	undefined
765	3	94	undefined
765	4	91	A 796.54 MAS
766	1	84	697 Bru 1983
766	2	99	undefined
767	1	99	undefined
767	2	94	undefined
768	1	44	696.1
768	2	101	696.1 PLU
768	3	99	undefined
768	4	35	696.1 TIM
768	5	79	696.1 PLU
768	6	71	696 Tim
768	7	94	undefined
768	8	26	696.1
769	1	20	628.7/Burns/P
769	2	84	628.7 Bur
769	3	79	628.7 BUR
769	4	99	undefined
769	5	10	628.7 BUR
770	1	20	Basement/LP/F/Plain
770	2	78	F Pla
770	3	83	F Pla
770	4	84	F Pla
770	5	25	LP Plain
770	6	71	F Pla LP
770	7	21	undefined
770	8	99	undefined
770	9	94	undefined
770	10	33	undefined
770	11	68	FIC PLA
770	12	134	F PLA
770	13	79	PB PLA
770	14	38	FIC PLA
770	15	16	Fic Pla
770	16	34	F/Pl-69
770	17	98	Fic Pl
771	1	84	615.854 Foo
771	2	83	615.854 Foo
771	3	82	615.854 Foo
771	4	26	ANF 613.2 FOO
771	5	134	613.2 REA
771	6	10	615.85 REA
771	7	25	615.854 Foods
771	8	73	615.8 Rea
771	9	71	615.8 Rea
771	10	21	TX 355 F69 1997,613.2 F6861,615.854 F686,QP141 F68 1997,TX355 F657 1997 fol,TX/355/.F65/1997,615.85
772	1	26	615.8/54
772	2	38	615.854 HAU
772	3	68	615.8 HAU
772	4	45	undefined
772	5	34	615.854
772	6	94	undefined
773	1	30	641.5631 PIS
773	2	31	641.5631 PIS
774	1	26	ANF 641 PAR,ANF 641 PAR
774	2	10	641.66 PAR
774	3	25	641.5123 Par
774	4	85	641.5 PARE
774	5	33	undefined
775	1	83	616.4 Wal
775	2	84	616.4 Wal
775	3	82	616.4 Wal
775	4	20	616.4/Living
775	5	26	ANF WAL 616.462
775	6	92	616.462 Wal
775	7	94	undefined
775	8	21	undefined
775	9	22	undefined
776	1	38	759.11 MEL
776	2	68	759.11/M
776	3	94	undefined
776	4	34	759.11 M48
776	5	98	759.11 Mel
776	6	99	undefined
777	1	71	940.44 Cla
777	2	99	undefined
778	1	25	F Parker
778	2	135	F Par
778	3	83	F Par v.19
778	4	22	undefined
778	5	68	CRIME PAR
778	6	98	Fic Myst Pa
778	7	71	MYSF Park
778	8	134	F PAR
778	9	38	FIC PAR
778	10	99	undefined
778	11	94	undefined
778	12	91	A FIC PAR
779	1	27	920 MAN
779	2	10	920.071 MAN
780	1	26	AF WOO
780	2	92	Woods
780	3	98	Fic Myst Wo
780	4	27	A FIC WOO
780	5	34	F Woods 2005
780	6	16	Fic Woo
781	1	79	814.54 RIC
781	2	99	undefined
781	3	134	814.54 RIC
781	4	94	undefined
781	5	10	814.54 RIC
782	1	31	undefined
782	2	30	undefined
783	1	44	745.6
783	2	25	745.6197 Bar
783	3	99	undefined
783	4	98	745.6197 Bar
783	5	11	745.6197,745.6197,j 745.6 Bar,745.6197 Bar,745.6 Bar,J 745.6197 Bar,J 745.6197 Bar,j 745.6 Bar,J 74
783	6	94	undefined
783	7	22	undefined
784	1	79	646.2 ROA
785	1	44	Rom Rob
785	2	135	F Rob
785	3	78	F ROB
785	4	83	LP F Rob v.1
785	5	84	LP F Rob v.1
785	6	82	LP F Rob v.1
785	7	71	F ROBERTS,ROB,Fic,F Roberts,F,F Rob,ROB,F Roberts,F Roberts #1,FIC ROB,F ROB,Rom Rob,F Rob,Fic Ro,F
785	8	99	undefined
785	9	35	F ROB
785	10	94	undefined
785	11	73	F.PBROM
785	12	11	F ROBERTS,ROB,F Roberts,F,F Rob,F Rob,ROB,F Roberts,F Roberts #1,Fic Rob,ROB,A/F Rob,AF Rob,PB.ROM,
785	13	91	A FIC ROB
785	14	25	F Roberts
785	15	79	PB ROB
785	16	134	F ROB
785	17	26	AF ROB
785	18	16	Fic Rob
785	19	68	FIC ROB
785	20	45	undefined
785	21	98	Fic Ro
786	1	134	636.7 SUN
786	2	99	undefined
787	1	92	751.422 Bar
787	2	134	751.422 BAR
788	1	83	F Ski
788	2	82	F Ski
788	3	84	F Ski
789	1	100	 2s
789	2	99	undefined
790	1	30	JR FIC KOR
790	2	31	JR FIC KOR
791	1	38	E MOR YELLOW 3
791	2	85	E MORGAN
791	3	99	undefined
791	4	35	E MOR
791	5	68	E M
791	6	16	E Fic Mor
791	7	94	undefined
791	8	36	undefined
792	1	99	undefined
792	2	38	R 387.7 ALL
792	3	98	387.706573 All,387.706573 All,387.706573 ALL,387.7/06573/ALLEN,387.706573 All,387.706573
792	4	94	undefined
792	5	91	A 387.7 ALL
793	1	71	J621.43 Hew
794	1	92	Tolstoy
794	2	10	CLASSIC TOL
794	3	73	F.Tol
794	4	99	undefined
794	5	26	AF TOL
794	6	34	891.73 Tol
794	7	94	undefined
794	8	68	fiction
794	9	98	Fic To
795	1	85	J 330.1 HUDAK
796	1	100	QL 685.5 .M3 Tay
796	2	38	598.2971 TAY
796	3	10	598.29 TAY
797	1	25	F Pilcher
797	2	134	F PIL
797	3	27	EPL AUD PIL
797	4	26	AF PIL,AF PIL
797	5	73	F.PBRom
797	6	38	FIC PIL
797	7	68	FIC PIL
797	8	34	F/Pi-64
797	9	71	F Pil
797	10	94	undefined
798	1	25	LP Patterson
798	2	92	LP Patterson
798	3	45	undefined
798	4	34	F/Pa-27 M
798	5	71	PS3566.A822A615 2005,F PAT
798	6	94	undefined
798	7	16	Fic Pat
798	8	33	undefined
798	9	91	A FIC PAT
798	10	26	AF PAT
798	11	21	undefined
798	12	22	undefined
798	13	27	A FIC PAT
798	14	85	LP PATTERSON
798	15	79	F PAT
798	16	134	F PAT,F PAT
798	17	68	CRIME PAT
799	1	34	F/So-4
799	2	98	Fic So
800	1	25	F Gabaldon
800	2	35	F GAB
800	3	94	undefined
800	4	33	undefined
800	5	91	A FIC GAB
800	6	79	PB GAB
800	7	99	undefined
800	8	27	A FIC GAB
800	9	92	Gabaldon
800	10	134	F GAB,F GAB
800	11	68	FIC GAB
800	12	16	Fic Gab
800	13	71	F Gab #4 0697
801	1	101	J 631.4 BOU
801	2	44	J 631.4
801	3	83	J 631.4 Bou
801	4	84	J 631.4 Bou
801	5	82	J 631.4 Bou
801	6	99	undefined
801	7	79	J 631.4 BOU
801	8	92	J 631.4 Bou
801	9	94	undefined
801	10	35	J 631.4 BOU
802	1	36	undefined
803	1	68	J811.07/P
803	2	99	undefined
803	3	94	undefined
804	1	99	undefined
804	2	98	J E Ja
805	1	10	JNFF 598 ERP
806	1	84	YA F And
806	2	83	YA F And
806	3	82	YA F And
806	4	101	ANDERSO
806	5	85	T ANDERSON
806	6	99	undefined
806	7	94	undefined
807	1	30	597.0929 PAG
807	2	31	597.0929 PAG
808	1	10	W McM
808	2	27	A FIC McM
808	3	92	McMurtry
808	4	98	FIC WEST MCM
808	5	34	F/McM-22 W
808	6	71	Wes/F McMurtry
808	7	16	Fic McM
809	1	20	F/Rosenberg/4
809	2	83	CF Ros v.4
809	3	84	CF Ros v.4
809	4	101	ROSENBE
809	5	92	Rosenberg
809	6	99	undefined
809	7	26	AF ROS
809	8	35	F ROS
809	9	94	undefined
809	10	134	F ROS
810	1	101	694 CAR
810	2	99	undefined
810	3	92	AT ILM 694 Car,AT ILM 694 Car,AT ILM 694 Car,AT ILM 694 Car,AT ILM 694 Car,AT ILM 694 Car,AT ILM 69
810	4	68	684.08 BLA
810	5	38	J 694 McP
810	6	94	undefined
810	7	21	undefined
810	8	35	694 BLA
811	1	83	J 811.54 Sim
811	2	84	J 811.54 Sim
811	3	25	J 811.54 Sim
811	4	98	J 811.54 Sim
811	5	38	J 811.54 SIM
811	6	94	undefined
811	7	99	undefined
811	8	21	811,j 811.54 Sim,J 811.54 Sim,J E Simmie,JE Simmie,J 811.54 SIM,J 811 SIM,819.154 SIM,811.54 Sim,J/
811	9	73	811.54 Sim
812	1	83	J 811.54 Sim
812	2	84	J 811.54 Sim
812	3	25	J 811.54 Sim
812	4	98	J 811.54 Sim
812	5	38	J 811.54 SIM
812	6	94	undefined
812	7	99	undefined
812	8	21	811,j 811.54 Sim,J 811.54 Sim,J E Simmie,JE Simmie,J 811.54 SIM,J 811 SIM,819.154 SIM,811.54 Sim,J/
812	9	73	811.54 Sim
813	1	101	SAMSON
813	2	83	CF Sam
813	3	84	CF Sam
813	4	82	CF Sam
813	5	71	F Sams
813	6	99	undefined
813	7	94	undefined
813	8	26	AF SAM
814	1	101	SAMSON
814	2	83	CF Sam
814	3	84	CF Sam
814	4	82	CF Sam
814	5	71	F Sams
814	6	99	undefined
814	7	94	undefined
814	8	26	AF SAM
815	1	83	F Ste
815	2	101	STE
815	3	16	Fic Ste
815	4	92	Steinbeck
815	5	68	fiction pb
815	6	71	F Ste
815	7	99	undefined
815	8	98	Classic Pbk St
815	9	38	FIC STE
815	10	20	Basement/F/Steinbeck
815	11	94	undefined
815	12	79	F STE
815	13	26	AF STE
815	14	22	undefined
815	15	10	FIC STE
815	16	82	LP FIC STE
815	17	91	S FIC STE
815	18	73	F.Ste
815	19	35	F STE
815	20	84	F Ste
815	21	25	F Steinbeck
815	22	85	FIC STEINBECK
816	1	84	967.57104 Hat
816	2	79	967.57104 HAT
816	3	94	undefined
816	4	99	undefined
817	1	84	J 398.2 Per
817	2	99	undefined
817	3	33	undefined
817	4	91	ER FIC PER
818	1	26	AF TOL,AF TOL,AF TOL
818	2	45	undefined
818	3	34	YA/To-57
818	4	91	S FIC TOL
819	1	101	741.5973 JOH
819	2	99	undefined
819	3	94	undefined
819	4	92	GN Johns
819	5	79	J GN JOH
820	1	101	MCDONAL
820	2	83	YA F McDo
820	3	84	YA F McDo
820	4	79	Y.A. F MCD
820	5	92	T McDonald
821	1	135	F McCa v. 2
821	2	44	F McC
821	3	83	F McCa v.2
821	4	84	F McCa v.2
821	5	82	F McCa v.2
821	6	25	F McCall Smith
821	7	92	McCall Smith
821	8	79	LP F MCC
821	9	71	LPGF Smi
821	10	99	undefined
821	11	134	F SMI
821	12	91	A FIC MCC
822	1	36	undefined
823	1	92	Kinsella
823	2	25	F Kinsella
823	3	79	F KIN
823	4	38	FIC KIN
823	5	134	F KIN
823	6	35	F KIN
823	7	34	F Kinsell 2011
823	8	73	F.Kin
824	1	25	B/Her
824	2	79	F HER
824	3	98	B Her
824	4	33	undefined
824	5	94	undefined
824	6	10	B HER
824	7	134	636.089 HER
824	8	38	B HER
824	9	34	B/Her
824	10	26	ANF 636.089092 HER B
824	11	68	636.089 HER
824	12	16	B Her
825	1	79	613.7 FEK
825	2	26	ANF 613.7 FEK
825	3	10	613.70 FEK
825	4	94	undefined
825	5	21	undefined
825	6	22	undefined
826	1	68	FIC GAR
826	2	72	undefined
826	3	45	undefined
826	4	91	A FIC MAR,FIC MAR
827	1	92	T Black
827	2	79	Y.A. F BLA
827	3	99	undefined
828	1	82	J E Bel
828	2	99	undefined
828	3	94	undefined
829	1	79	E CLE
829	2	92	E Cle
829	3	34	E Clement
830	1	101	undefined
830	2	99	undefined
830	3	79	E AHL
830	4	94	undefined
830	5	22	JE Ahl-E
831	1	83	J 811.54 Sci
831	2	84	J 811.54 Sci
831	3	82	J 811.54 Sci
831	4	38	J 811.54 SCI
831	5	25	E Scieszka
831	6	68	E
831	7	45	undefined
831	8	99	undefined
832	1	78	305.2440 All
832	2	82	817.54 All
832	3	83	305.2440207 All
832	4	38	817.54 ALL
832	5	45	undefined
832	6	98	817.54 All
832	7	71	818 All
832	8	94	undefined
832	9	21	undefined
832	10	22	undefined
833	1	25	616.8553/Sel
833	2	22	undefined
834	1	20	J/E/Borden
834	2	68	E
834	3	99	undefined
835	1	26	ANF 641.5971 HRE,ANF 641.5971 HRE
835	2	85	641.5 HRECHUK
835	3	94	undefined
835	4	45	undefined
836	1	68	784.4/J pb
836	2	79	780.7971274 JOH
836	3	99	undefined
836	4	98	780.7971274 Joh
836	5	71	780.797 Joh
836	6	94	undefined
837	1	83	J 745.5941 Des
837	2	98	j 745.5941 Des,745.5941,745.5941,J745.5941Des,745.5941 Des,J/745.5941/DESHPANDE,j745.5/DES,745.5941
837	3	73	745.5941Des
838	1	71	C/F Per
839	1	85	J 641.3 DEVINS
840	1	20	BB/MacEwan
840	2	83	971 MacE
840	3	82	971 MacE
840	4	135	971 MacE
840	5	84	971 MacE
840	6	79	920 MAC
840	7	38	920.7109 McE
840	8	68	971.2/Mac
840	9	34	BB/M-15
840	10	94	undefined
840	11	71	B Col
841	1	135	F Mil
841	2	38	FIC MIL
841	3	134	F MIL
841	4	99	undefined
841	5	68	NC M
841	6	45	undefined
841	7	71	F/Mil
842	1	135	PB F Cus
842	2	101	FIC CUSSL
842	3	79	F CUS
842	4	99	undefined
842	5	26	AF CUS
842	6	21	F Cus-M
842	7	134	F CUS
842	8	35	F CUS
842	9	84	F Cus
842	10	82	F Cus
842	11	44	F Cus
842	12	20	F/Cussler
842	13	83	F Cus v.6
842	14	25	F Cussler
842	15	92	Cussler
842	16	68	FIC CUS
842	17	34	PBK F Cussler 2009
842	18	38	FIC CUS
842	19	94	undefined
843	1	84	616.8 Kan
843	2	82	616.8 Kan
843	3	83	616.8 Kan
843	4	99	undefined
843	5	26	ANF 616.84 KAN
843	6	94	undefined
843	7	10	616.84 KAN
844	1	84	616.8498 Cal
844	2	83	616.8498 Cal
844	3	99	undefined
844	4	94	undefined
845	1	83	J F Ale
845	2	84	J F Ale
845	3	82	J F Ale
845	4	79	J F ALE
845	5	92	J A
845	6	99	undefined
846	1	38	FIC ADK
846	2	68	940.27 ADK
847	1	79	F GRU
847	2	38	FIC GRU
847	3	73	F.PBGen
847	4	34	F Gruen 2007
847	5	68	FIC GRU
847	6	11	undefined
847	7	17	undefined
847	8	71	F Gru
847	9	27	A FIC GRU
847	10	25	F Gruen
847	11	35	F GRU
847	12	10	FIC GRU,FIC GRU
847	13	92	PB G
847	14	134	F GRU
847	15	26	AF GRU,AF GRU
848	1	84	J 599.61 Wex
848	2	78	J 599.61 Wex
848	3	25	599.61/Wex
848	4	26	ANF 599.6 WEX
848	5	71	J599 Wex
848	6	99	undefined
848	7	21	undefined
849	1	98	Myst Pbk Hi
849	2	99	undefined
850	1	98	J Pbk Pa
850	2	71	Y/ADV Cho
850	3	134	J F PAC
851	1	85	J 391.009 POWE-TEMPERLEY
851	2	99	undefined
852	1	26	625.19
852	2	71	J625.1 Her
853	1	21	F BURKE
854	1	79	F BAL
854	2	38	FIC BAL
854	3	27	A FIC BAL
854	4	68	CRIME BAL
854	5	16	Fic Bal
854	6	11	undefined
854	7	17	undefined
854	8	134	F BAL
854	9	26	AF BAL,AF BAL
854	10	35	F BAL
854	11	92	LP Baldacci
854	12	34	PBK F Baldacc
855	1	79	J 930.1028 CER
855	2	92	J 930.1028 Cer
855	3	99	undefined
856	1	99	undefined
857	1	92	746.434 Rim
857	2	99	undefined
858	1	34	J 031.02 Kno
858	2	98	J 031.02 Kno
858	3	33	undefined
859	1	26	ANF 641.5784 SHE
860	1	92	649.57 Gin
860	2	99	undefined
861	1	25	W F Coulter
861	2	68	CRIME COU
861	3	16	Fic Cou
861	4	99	undefined
861	5	26	ALP COU,AF COU
861	6	17	undefined
861	7	94	undefined
861	8	33	undefined
861	9	134	F COU
861	10	36	undefined
861	11	91	A FIC COU
861	12	73	F.Cou
861	13	79	LP F COU
861	14	38	FIC COU
861	15	92	Coulter
861	16	85	FIC COULTER,FIC COULTER
861	17	45	undefined
861	18	34	F/Co-83
862	1	134	F MAC
862	2	25	W LP Macomber #4
862	3	34	F/Ma-26
862	4	94	undefined
862	5	71	F/Mac
862	6	33	F Mac,F Macomber,F Macomber #4
862	7	91	A FIC MAC
862	8	73	F.PBRom
862	9	85	FIC MACOMBER,FIC MACOMBER
862	10	35	F MAC
862	11	11	undefined
862	12	27	A FIC MAC
862	13	26	AF MAC r
862	14	45	undefined
863	1	99	undefined
863	2	34	undefined
864	1	36	J 398.21 CHO
865	1	92	627.31 Lam
865	2	38	643 .2 LAM
865	3	79	627.31 LAM
865	4	98	627.31 La
865	5	99	undefined
866	1	25	F Proulx
866	2	79	PB PRO
866	3	91	S FIC PRO
866	4	92	Proulx
866	5	134	F PRO
866	6	99	undefined
866	7	21	undefined
866	8	35	F PRO
866	9	10	FIC PRO
866	10	17	undefined
867	1	36	undefined
868	1	25	796.962 Carrier
868	2	92	796.962 Car
868	3	85	B RICHARD
868	4	68	796.962 RICHARD
868	5	134	796.962  CAR
868	6	99	undefined
868	7	73	B.Ric
869	1	79	J 796.332 CRO
869	2	35	J 796.33 CRO
869	3	99	undefined
869	4	22	undefined
870	1	79	J 796.332 CRO
870	2	35	J 796.33 CRO
870	3	99	undefined
870	4	22	undefined
871	1	92	Johansen
871	2	99	undefined
871	3	26	AF JOH
871	4	35	F JOH
871	5	73	F.PBMys
871	6	27	A FIC JOH
872	1	101	DOUGLAS
872	2	20	LP/F/Douglas/W
872	3	25	LP Douglas
872	4	85	LP DOUGLAS
872	5	34	F/Do-74 W LP,F/Do-74 W LP
872	6	94	undefined
873	1	78	F Bla Ins
873	2	20	/F/Blackstock
873	3	83	CF Bla v.4
873	4	84	CF Bla v.4
873	5	82	CF Bla v.4
873	6	25	W F Blackstock
873	7	45	undefined
873	8	34	F Blackst 2005
873	9	71	Mys/F Blacks Cape 4
873	10	99	undefined
873	11	79	IN F BLA
873	12	94	undefined
873	13	91	A FIC BLA
874	1	84	F Web
874	2	99	undefined
874	3	85	FIC WEBER
874	4	92	Weber
874	5	21	undefined
874	6	94	undefined
874	7	22	undefined
875	1	84	F Cus v.4
875	2	83	F Cus v.4
875	3	20	F/Cussler
875	4	134	F CUS
875	5	26	AF CUS
875	6	21	undefined
875	7	22	undefined
875	8	35	F CUS
875	9	99	undefined
875	10	79	F CUS
875	11	85	FIC CUSSLER,FIC CUSSLER,FIC CUSSLER
875	12	92	Cussler
875	13	94	undefined
875	14	27	A FIC CUS
876	1	79	PB DEL
876	2	73	LP.PLS
876	3	35	F DEL
876	4	34	F/De-37
876	5	45	undefined
876	6	68	FIC DEL
876	7	71	F Delinsky
876	8	16	Fic Del
876	9	94	undefined
876	10	91	A FIC DEL
876	11	134	F DEL
876	12	25	LP Delinsky
876	13	38	FIC DEL
876	14	85	LP DELINSKY
876	15	26	AF DEL,AF DEL
876	16	10	FIC DEL
876	17	27	A FIC DEL
877	1	25	LP Macomber
877	2	79	PB MAC,PB MAC c.2
877	3	91	A FIC MAC
877	4	35	F MAC
877	5	134	F MAC
877	6	26	AF MAC
877	7	73	F.PBRom
877	8	92	LP Macomber
877	9	34	F Macombe 2009
877	10	71	F Mac
878	1	26	ANF 551.46 WIN
878	2	92	551.46 Win
878	3	68	551.46 WIN
878	4	94	undefined
879	1	79	Y.A. 973.7115 GOR
879	2	26	JNF 973.7 GOR
879	3	99	undefined
879	4	45	undefined
879	5	98	J 973.7115 Gor
879	6	94	undefined
880	1	83	971.3112004973 Jil
880	2	38	971.3112 JIL
880	3	99	undefined
880	4	91	A 971.3 JIL
881	1	134	J F WIL
881	2	25	J Wilson
881	3	10	JF WIL
881	4	11	PS8595/I29Sp/1984,PZ 7 W753 S75 1984,J FIC,PS 8595 I446 S647 1984,FICTION/WIL,JF WIL,JF WIL,JF WIL,
881	5	45	undefined
881	6	35	J WIL
881	7	34	J/F/Wil
881	8	98	J Pbk Wi
881	9	68	JF WIL
881	10	71	Y/Mys Wil
882	1	25	J 811.54 Bou
882	2	79	J 811.54 BOU
882	3	68	Junior/C811.54/B
882	4	34	811.54
882	5	35	J 811.54 BOU
882	6	73	JE.Bou
882	7	10	C BOU
882	8	27	J FIC BOU
882	9	94	undefined
882	10	45	undefined
882	11	38	J 811.54 BOU
883	1	34	971.27 Bro
883	2	98	971.127 Bro
883	3	71	971.27 Bro
883	4	94	undefined
884	1	100	F 5609 .S8 Bro c.3
884	2	34	623.82 Bro
884	3	71	386.2 Bro
884	4	94	undefined
884	5	99	undefined
884	6	79	386.3097 BRO
884	7	73	VF.Manitoba
885	1	83	J 612.82 Swa
885	2	84	J 612.82 Swa
885	3	82	J 612.82 Swa
885	4	99	undefined
885	5	94	undefined
885	6	36	undefined
886	1	38	943.087 GER
886	2	98	J 394.26943 Lor
886	3	33	undefined
886	4	94	undefined
886	5	91	GER
887	1	26	ANF 944 FRA
887	2	10	944 TIM
887	3	25	944 Fra
887	4	34	914.4 FRA 2005
887	5	38	944.08 FRA
887	6	99	undefined
887	7	94	undefined
888	1	101	791.43658 PAS
889	1	94	undefined
890	1	99	undefined
891	1	101	CRICHTO
891	2	83	F Cri
891	3	82	F Cri
891	4	78	F Cri
891	5	94	undefined
891	6	21	undefined
891	7	73	F.PBHor
891	8	91	A FIC CRI
891	9	84	EAL F Cri
891	10	99	undefined
891	11	16	Fic Cri
891	12	68	SF CRI c2
891	13	98	Thriller Pbk Cr
891	14	26	AF CRI
891	15	79	F CRI
892	1	101	560.1762 FRA
892	2	99	undefined
893	1	99	undefined
893	2	94	undefined
894	1	38	398.2454 SHU
894	2	45	undefined
894	3	99	undefined
895	1	83	001.94 Han
895	2	101	001.94 HAN
895	3	99	undefined
896	1	82	F Bak
896	2	101	BAKKER
896	3	68	SF BAK
896	4	71	F Bak
896	5	11	BAKKER,F Bak,Fic BAK,F BA,F Bak,FIC BAK,F BAK,Bakker
896	6	79	F BAK
896	7	10	FIC BAK
897	1	44	J Sto
897	2	83	J S Din v.8
897	3	84	J S Din v.8
897	4	82	J S Din v.8
897	5	135	J F Sto v.8
898	1	25	E Brown
898	2	20	J/E/Brown
899	1	85	J 569 BROWN,J 569 BROWN
900	1	134	796.35 BIS
901	1	34	J/E/Wah
901	2	22	undefined
902	1	94	undefined
903	1	20	J/E/Andrede
903	2	78	J E And
903	3	79	BB AND
903	4	134	E AND
903	5	99	undefined
903	6	92	E And
903	7	17	undefined
903	8	91	ER FIC AND
904	1	27	J NON FIC MCM
904	2	92	J 597.31 McM
904	3	11	undefined
905	1	26	JF TUN
906	1	45	undefined
907	1	82	LP F McCr
907	2	101	McCRUMB
907	3	25	F McCrumb
907	4	26	AF MCC
907	5	99	undefined
907	6	10	FIC McC
908	1	101	919.923 ZUB
908	2	99	undefined
908	3	94	undefined
909	1	83	F Bur
909	2	84	F Bur
909	3	82	F Bur
909	4	101	FIC BURNA
909	5	79	F BUR
909	6	25	F Burnard
909	7	134	F BUR
909	8	10	FIC BUR
909	9	26	AF BUR
909	10	94	undefined
910	1	44	909 Str
910	2	101	909 STR
910	3	20	909/Strange
910	4	26	ANF 910.021 STR
910	5	73	Ref
910	6	99	undefined
910	7	94	undefined
911	1	100	HD 9049 .W3 .C2 Fai
911	2	20	334.983311/Fairbairn
911	3	68	334 FAI
911	4	98	334.683311 Fai
911	5	99	undefined
911	6	94	undefined
912	1	83	797.54 Sro
912	2	84	797.54 Sro
912	3	82	797.54 Sro
912	4	92	797.54 Sro
912	5	99	undefined
912	6	26	ANF 729 SRO
912	7	21	undefined
912	8	38	797.54 SRO
913	1	101	HEMINGW
914	1	84	919.3 New
914	2	100	O.E.C.D. 21 93 51 1
914	3	99	undefined
914	4	82	919.31 New 2012
914	5	92	919.3044 New
914	6	98	M-59
914	7	94	undefined
915	1	84	F Bov
915	2	99	undefined
916	1	134	971.27 WIL
917	1	83	J 629.2275 Oxl
917	2	84	J 629.2275 Oxl
917	3	82	J 629.2275 Oxl
917	4	25	J 629.227 Oxlade
917	5	79	J 629.2275 OXL
918	1	79	E LAN
918	2	38	E LAN Green 1
919	1	79	814.54 FER
919	2	35	814 FER
919	3	27	814 FER
920	1	99	undefined
921	1	84	791.43 Bes
921	2	99	undefined
922	1	68	530.12 LLO
922	2	94	undefined
923	1	134	J F DIX
923	2	35	J DIX
923	3	17	undefined
924	1	85	940.54 PRICE
924	2	99	undefined
924	3	94	undefined
925	1	83	F Fol
925	2	84	F Fol
925	3	82	F Fol
925	4	78	F Fol
925	5	44	F Fol
925	6	20	F/Follett
925	7	25	F Follett
925	8	99	undefined
925	9	17	undefined
925	10	94	undefined
925	11	21	undefined
925	12	22	undefined
925	13	38	FIC FOL
925	14	36	undefined
925	15	85	FIC FOLLETT
925	16	35	F FOL
925	17	10	FIC FOL
925	18	68	CRIME FOL
925	19	98	Fic Myst Fo
925	20	79	F FOL
925	21	134	F FOL
925	22	26	AF FOL
926	1	92	Mina
926	2	34	F Mina 2011
926	3	99	undefined
926	4	79	F MIN
926	5	94	undefined
926	6	134	F MIN
926	7	73	F.Min
927	1	92	E Kel
927	2	79	E KEL
927	3	71	C/F Kel
927	4	99	undefined
927	5	38	E KEL Orange 8
927	6	35	E KEL
927	7	94	undefined
927	8	10	C KEL
928	1	85	BB VOAKE
928	2	99	undefined
928	3	94	undefined
928	4	35	E VOA
929	1	83	F Gou
929	2	82	F Gou
929	3	20	F/Goudge
929	4	101	GOUDGE
929	5	84	F Gou
929	6	25	F Goudge
929	7	99	undefined
929	8	94	undefined
929	9	21	undefined
929	10	85	FIC GOUDGE,FIC GOUDGE
929	11	79	F GOU
929	12	68	FIC GOU
929	13	26	AF GOU
929	14	34	F/Go-72
929	15	16	Fic Gou
929	16	98	Fic Go
929	17	35	F GOU
930	1	84	616.97 Bru
930	2	82	616.97 Bru
930	3	101	641.56318 BRU
931	1	134	F KUR . FANTASY
931	2	99	undefined
931	3	94	undefined
932	1	82	YA F Plu
932	2	84	YA F Plu
932	3	99	undefined
932	4	92	T Plum-Ucci
932	5	94	undefined
933	1	25	LP 813.54 King
933	2	10	B KIN
933	3	85	813.54 KING
933	4	134	813.54 KIN
933	5	26	AB KIN
933	6	98	813.54 Ki
933	7	91	A 920.71 KIN
933	8	22	813.54
934	1	68	625.1/B
935	1	20	PG14/B2
936	1	134	J 332.1 HUD
937	1	45	undefined
937	2	92	Gabaldon
937	3	91	S FIC GAB
937	4	26	AF GAB
937	5	35	F GAB
937	6	16	Fic Gab
937	7	68	FIC GAB
937	8	27	A FIC GAB
937	9	94	undefined
938	1	83	553.8 Pat
938	2	99	undefined
939	1	83	PB F Rog
939	2	85	FIC ROGERS,FIC ROGERS
939	3	98	Fic Pbk Ro
939	4	71	Hist/Rom Rogers
939	5	38	FIC ROG
939	6	99	undefined
940	1	134	F BER
940	2	26	AF BER
940	3	92	Berry
940	4	73	F.Ber
941	1	33	undefined
941	2	83	F Kin
941	3	82	F Kin
941	4	135	F Kin
941	5	84	F Kin
941	6	78	F Kin Th
941	7	20	F/King
941	8	101	KING
941	9	79	F KIN
941	10	134	F KIN
941	11	92	King
941	12	26	AF KIN,AF KIN
941	13	17	undefined
941	14	21	undefined
941	15	22	undefined
942	1	38	J FIC KOR
942	2	25	J Korman
942	3	68	JF KOR
942	4	71	Y/Adv Kor
942	5	99	undefined
942	6	73	T.Kor
943	1	25	635.965 Suc
943	2	38	635.965 SUC
943	3	34	635.965
943	4	94	undefined
943	5	99	undefined
944	1	26	AF PAU w
944	2	94	undefined
944	3	99	undefined
945	1	36	undefined
946	1	38	J 811.54 SIL
946	2	134	F J SIL
946	3	25	J 819.154 Sil
946	4	26	JNF 811.5 SIL,JNF 811.5 SIL
946	5	10	JNF 811.54 SIL
946	6	73	819.154 Sil
946	7	98	811.5/4,J/817/Silverstein,j 811.54 Sil,j 811.54 Sil,J 819.154 Sil,JR 819.154 SIL,J 819.1 Sil,j 811.
946	8	45	undefined
946	9	35	J 811.54 SIL
946	10	92	J 819.154 Sil
947	1	79	undefined
947	2	45	undefined
947	3	11	SB 439.8 W55 1997,635.952 Will,635.9525 W727 1997,SB 439.8 W55 1997,635.9525 W72c,635.9 WIL,SB439 .
947	4	94	undefined
948	1	101	E WOOD
948	2	83	J E Woo
948	3	84	J E Woo
948	4	82	J E Woo
948	5	92	E Woo
949	1	84	F Par
949	2	20	Basement/F/Paretsky/M
949	3	92	Paretsky
949	4	99	undefined
949	5	91	A FIC PAR
949	6	45	undefined
949	7	68	CRIME PAR
949	8	71	Mys
949	9	10	FIC PAR
949	10	98	Myst Pbk Pa
949	11	38	FIC PAR
949	12	26	AF PAR m
950	1	94	undefined
951	1	83	F Con
951	2	84	F Con
951	3	101	FIC CONNO
951	4	92	Connolly
952	1	82	PB F Wil
952	2	85	FIC WILSON
952	3	79	PB WIL
952	4	99	undefined
952	5	94	undefined
953	1	135	LP F Ric
953	2	101	RICHMAN
953	3	99	undefined
954	1	31	undefined
955	1	134	F WEB . ROMANCE
956	1	84	616.89820092 Wil
956	2	20	B/Williams
956	3	101	618.9285882 WIL
956	4	25	B Williams
956	5	79	921 WIL
956	6	10	B WIL
956	7	68	616.89 WILLIAMS
956	8	92	B Williams
956	9	98	B Wil
957	1	79	IN F KIN
957	2	134	F KIN
957	3	26	AF KIN
957	4	92	Kingsbury
957	5	17	undefined
958	1	25	798.4 Hillenbrand
958	2	85	B SEABISCUIT,B SEABISCUIT
958	3	35	798.4 HIL
958	4	134	798.4 HIL
958	5	68	798.4 HIL
958	6	71	798.4 Hil
958	7	98	798.4 Hi
958	8	10	798.40 HIL
958	9	73	798.25 Hil
959	1	101	333.91 SNI
959	2	99	undefined
960	1	20	F/Sheldon
960	2	78	F She M
960	3	82	F She
960	4	83	F She
960	5	84	F She
960	6	135	F She
960	7	101	PLS LP
960	8	35	F SHE
960	9	11	undefined
960	10	94	undefined
960	11	10	FIC SHE
960	12	27	A FIC SHE
960	13	44	Mys She
960	14	134	F SHE
960	15	85	FIC SHELDON,FIC SHELDON
960	16	38	FIC SHE
960	17	91	A FIC SHE
960	18	26	AF SHE
960	19	99	undefined
\.


--
-- TOC entry 1908 (class 0 OID 17498)
-- Dependencies: 156
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY users (uid, username, password, lid) FROM stdin;
41	mp	1f2dfa567dcf95833eddf7aec167fec7	68
2	ucn	700e1a7df87286de270747390fe3788e	131
4	mra	86b546be98d8f58d4dedfb8be7423a19	72
5	mnha	e89aa529e06ed229d936aff5092608af	9
6	mwrr	35bf87d7d860046786606168726cbe3f	105
7	mserc	01998d84dca6a7bed73b967f446e2801	108
8	mwmrc	c9a318aca851ecf75f38e30466537fb5	109
9	mcnc	3d7f502d2b8c5ca937263c2cb777ecd4	95
30	mdpbr	4a59d3a38128a3a31412cf4ec9c6f7a1	50
31	mdpla	28bc3fcf58dbfbc930f18d8754a28e61	60
32	mbi	3b5cf439e9798e9e87b59be9ba44c73e	77
20	MHH	83496aa5fe3863677f6b3bc4c9fabb3a	35
33	dtl	f01036d2d9d32d843afd7c8cbe07637c	1
52	mdpmi	d5feaee643bb5d14c88eb213172dd0f1	62
71	mbbr	e2c99dbe11324bcd3a6e5feffbfb97c4	26
112	mw	38fed7107cee058098ca06304c1beb90	99
113	mth	f8b1336407c5b7a06f012b63ceee438b	92
114	mbom	a1c6edd5601e7b66b28c65f02d527405	20
115	mwpl	381fac69d3dc8e7180674bc872f2e514	101
116	mmow	fd8c2bcaca05c6c7fe142881b85116db	83
117	mplp	0f630dfa1e7b0c92546a162ca2816cf4	69
121	mwhbca	a937a4caedc24463e82993690873205c	117
122	mesm	9002aef48c0cfca797088d022672a794	87
123	msrn	770b1729da61981979a32a95959ccc63	46
1	mvbb	352ace815b677744828712113ad7d014	136
3	mhh	a4310b1057a43a419b440e2814bbe035	132
34	mesp	feaef5abd77327167a8d491fa57c15d3	89
35	mdper	5a0309423c01feb3f9ba07bbc374a602	54
36	mdp	aa36dc6e81e2ac7ad03e12fedcb6a2c0	49
37	mlb	89d021e682f117a6ff8e6fe859cdcc2d	17
38	mdpbo	99824f1451f40d0fbf156e315182c189	52
39	mdpfo	52f25c0475f7c1322c051b0e43811ff7	55
40	mtsir	e6656f12e482102856eba49872da1e16	86
42	msjb	1615e5cee94f054f04b6c7414d506d5b	11
43	me	ab86a1e1ef70dff97959067b723c5c24	22
44	mpm	6b9f893f526fef95aae04d527b862084	41
45	mmnn	e7c48f5ab99d99ce62595d1764b2fb6a	45
46	msad	35f5acf4a0198bf2be6896e2f864b348	14
47	mrp	412ed2e9aeba86664aa62a87e296a1b5	73
48	mdpsi	58416a5db3067c30a43b7ec6b04def19	66
49	mmr	aa29d6984108c685bd651011d6733c00	98
50	mmca	61944fd49aee415a16e6a7b9d6a304f8	23
51	mrd	ed1fbbef5bfb288aa10218943f58e678	76
53	mro	cda0fd2918d19e20ac871ed79a8d2bb0	74
54	mdb	801693b1d56b19d77272b3c6db46a751	25
55	ms	ee33e909372d935d190f4fcb2a92d542	19
56	msel	c2142941567f57b7d4768b8da097f283	79
57	msa	b9342a7d3a63c2b2d444dd9caf437f22	18
58	mrb	13eed552a284d37f230c63de3263cf9b	31
59	mtp	5884bf0e6464833e0550ebb13e0578e3	91
60	mldb	d59b1f76f919957d7ec810682e54fd9e	38
61	mwp	e8cfc01b37b8e9f27af09ffae08eae36	100
62	msog	678d7a201c0aa484f1bd4c7f1bf6abc4	34
63	mrip	8b5751a5a0bfec007233e4f919ed9e6d	71
64	mwow	bde4693ca0e8c4dcfab6cdae666b1647	84
65	mccb	e84a0c8e8704f9c6836eaca5c3b87af7	40
66	mda	c112c8b88569f1cb2d8f22eca738a4b7	53
67	mdpsl	8d04d64c0e07d8a697d8f7bad5c6226f	65
68	mdpbi	ce7a7d55e812f90593ea5b4e4badd7ee	51
69	mscl	7c697c045cfb560d8aea965539f9e57f	16
70	mndp	9ad3be6a4f4922eb9b02dd0d052cbeeb	12
72	mhw	ba210afe3f02f05e1ffbbeab26ceef8b	120
73	mmvr	e3b133ee508586ec76d2fbfc02438426	93
85	mge	33af66ec85c4eeed654987c595fde4df	29
104	mbw	afcea21a1767d28b41b1a932b060c607	94
108	cpl	363ccddc87d476ad5f91d9ca39d24df0	116
109	mwj	fac2db1a64bc2a16887e9bdf17e15f8e	118
110	mab	86ee133db2f0f3158ca63884e9f220c3	30
111	mstp	075e7a0dd3c9593372baad0737d18a5a	36
118	mste	f6d503a34c41b19677eca46479ae4c1d	90
119	mstos	3bccffae5602c27b873cf2f7bfb9faff	85
120	mwemm	167ba9f285a5461d8e9ecf3917772601	114
10	mibr	2ee4d7b098b2cc783e396a4e56f5041e	13
11	msl	8cf205e11d5eb3c998ac34958304c608	80
12	mdpgv	b646bf625fae2a6b72e44d0c4b6204a3	58
13	mdpst	31fcf7b92c33e4e76c449a93c7fdd165	107
14	mds	60a114c91c41983174b484e188856fb3	134
15	mwowh	e2575f1403ab8fd53a4ac4756979d47b	81
16	mdpor	201f27b3166eb7bc3a9a0418256b61bc	63
17	twas	f0f9b8ff2096179b21848c8ffeca7c10	121
18	mpfn	e7c01c1eadab367993e91e53cd90e66a	122
19	mncn	b6b492d63d1d92a2208de4585962f166	125
21	mstr	e73b001a07fa157e3530942b607b37de	78
22	mdpsla	3ad0891d1d96273dfb70d447b8c0842e	124
23	mepl	988f03376abf785e0c17a70817978a88	103
24	mch	040341797a19a29410123669d9ac748c	28
25	mel	0ef174fc614c8d61e2d63329ef7f46c0	27
26	mdpmc	9df8337e51fca70f2fa28e1690617d02	61
27	mlr	fac131120365e920d07c1ef7f062c7b0	42
28	mdpwp	4cf9f79fb2a886fa5115225034f359c3	67
29	mllc	27adf5ccfe5686adb20e448d2bfed42e	43
74	mstg	ec43d7793b528b089b46ba86f3fa2ccd	10
75	asgy	478682934fb55d4fa492cbda66d72fa7	112
76	mbac	2520d5dc90feb905b39f8fab5eccb03b	104
77	mdpro	fee6a8e675c2d0f632368eb24895f9b8	64
78	mgw	62a4dfbbb4de5c046cb446ebba0439ee	96
79	mgi	2d8ba2223ae0795eb813db8aa28bf0aa	33
80	mlpj	766038ecb8581c16ca3364ea506cd2e3	48
81	admin	21232f297a57a5a743894a0e4a801fc3	129
82	spruce	6e5190062ffb7269f769254b13bcc309	139
83	mnw	a90364f2e445df4b74247c4185f6c5f9	97
84	mwts	0cf5871b9bd01be44b36445c3341677e	106
86	mba	91e112b7220af68fcf5be09ee837f7a7	75
87	mssm	8ea075b7ebdac861d367954ed7bf2e91	37
88	mesmn	73b51a4c6a5860ee266150767e665fca	88
89	mssc	e6e241cb7e27a419c815da0651052472	111
90	mhp	e09be4b2786fff7fe6688759c85ee635	102
91	mbb	e899877691f405507dcd8c078df3daf3	47
92	msag	7960d7a492308273cc9081b65f1be4c8	15
93	maow	ccf2df3d9baceff6cadc6e64b69368d0	82
94	mve	ba70d0e436cb672de5325dfcc6eaa8ea	21
95	mbbb	3e7a9bbafaa2dec9d833fc067e24a455	110
96	mdpgl	edcc2968f826bc7adfbd904e3d51b138	57
97	mdpgp	d468211261eb3ac4a9c819b4992ff010	56
98	mdpha	b64352f3ec2130004ef87326a489e96f	59
99	mtpl	5f74b1c09aba48b214b07074dbcba4a3	119
100	mwsc	34aa4390d7d495a868bb1ebd9f2c703d	113
101	oke	0079fcb602361af76c4fd616d60f9414	115
102	mff	119b256eea327771c1c2f9829450ae18	32
103	mcb	dc571867053d4f69c37666db0144d898	24
105	mmiow	b7b4d8bd4b71fedf7a521b5dab489b20	135
106	mkl	324ddb5e2f605b34cce9110cbf390f6b	39
107	mma	a9f9d8d4b6db81aed3933664f7352542	44
\.


--
-- TOC entry 1882 (class 2606 OID 17503)
-- Dependencies: 150 150
-- Name: request_closed_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY request_closed
    ADD CONSTRAINT request_closed_pkey PRIMARY KEY (id);


--
-- TOC entry 1880 (class 2606 OID 17505)
-- Dependencies: 149 149
-- Name: request_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY request
    ADD CONSTRAINT request_pkey PRIMARY KEY (id);


--
-- TOC entry 1884 (class 2606 OID 17507)
-- Dependencies: 153 153
-- Name: search_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY search_statistics
    ADD CONSTRAINT search_statistics_pkey PRIMARY KEY (sessionid);


--
-- TOC entry 1876 (class 2606 OID 17509)
-- Dependencies: 141 141
-- Name: unique_name; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY libraries
    ADD CONSTRAINT unique_name UNIQUE (name);


--
-- TOC entry 1878 (class 2606 OID 17511)
-- Dependencies: 141 141
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY libraries
    ADD CONSTRAINT users_pkey PRIMARY KEY (lid);


--
-- TOC entry 1886 (class 2606 OID 17513)
-- Dependencies: 156 156
-- Name: users_username_key; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 1887 (class 2606 OID 17514)
-- Dependencies: 1877 141 142
-- Name: library_barcodes_borrower_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY library_barcodes
    ADD CONSTRAINT library_barcodes_borrower_fkey FOREIGN KEY (borrower) REFERENCES libraries(lid);


--
-- TOC entry 1888 (class 2606 OID 17519)
-- Dependencies: 150 141 1877
-- Name: request_closed_filled_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY request_closed
    ADD CONSTRAINT request_closed_filled_by_fkey FOREIGN KEY (filled_by) REFERENCES libraries(lid);


--
-- TOC entry 1889 (class 2606 OID 17524)
-- Dependencies: 141 1877 151
-- Name: requests_active_msg_from_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_active
    ADD CONSTRAINT requests_active_msg_from_fkey FOREIGN KEY (msg_from) REFERENCES libraries(lid);


--
-- TOC entry 1890 (class 2606 OID 17529)
-- Dependencies: 151 1877 141
-- Name: requests_active_msg_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_active
    ADD CONSTRAINT requests_active_msg_to_fkey FOREIGN KEY (msg_to) REFERENCES libraries(lid);


--
-- TOC entry 1891 (class 2606 OID 17534)
-- Dependencies: 151 149 1879
-- Name: requests_active_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_active
    ADD CONSTRAINT requests_active_request_id_fkey FOREIGN KEY (request_id) REFERENCES request(id);


--
-- TOC entry 1892 (class 2606 OID 17539)
-- Dependencies: 1877 141 152
-- Name: requests_history_msg_from_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_history
    ADD CONSTRAINT requests_history_msg_from_fkey FOREIGN KEY (msg_from) REFERENCES libraries(lid);


--
-- TOC entry 1893 (class 2606 OID 17544)
-- Dependencies: 152 1877 141
-- Name: requests_history_msg_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_history
    ADD CONSTRAINT requests_history_msg_to_fkey FOREIGN KEY (msg_to) REFERENCES libraries(lid);


--
-- TOC entry 1894 (class 2606 OID 17549)
-- Dependencies: 1881 150 152
-- Name: requests_history_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY requests_history
    ADD CONSTRAINT requests_history_request_id_fkey FOREIGN KEY (request_id) REFERENCES request_closed(id);


--
-- TOC entry 1895 (class 2606 OID 17554)
-- Dependencies: 1877 141 154
-- Name: sources_library_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY sources
    ADD CONSTRAINT sources_library_fkey FOREIGN KEY (library) REFERENCES libraries(lid);


--
-- TOC entry 1896 (class 2606 OID 17559)
-- Dependencies: 1879 149 154
-- Name: sources_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mapapp
--

ALTER TABLE ONLY sources
    ADD CONSTRAINT sources_request_id_fkey FOREIGN KEY (request_id) REFERENCES request(id);


--
-- TOC entry 1913 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2012-07-22 22:19:48 CDT

--
-- PostgreSQL database dump complete
--

