--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: david
--

CREATE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO david;

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
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.authgroups_gid_seq OWNER TO mapapp;

--
-- Name: authgroups_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mapapp
--

ALTER SEQUENCE authgroups_gid_seq OWNED BY authgroups.gid;


--
-- Name: authgroups_gid_seq; Type: SEQUENCE SET; Schema: public; Owner: mapapp
--

SELECT pg_catalog.setval('authgroups_gid_seq', 1, false);


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
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.libraries_lid_seq OWNER TO mapapp;

--
-- Name: libraries_lid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mapapp
--

ALTER SEQUENCE libraries_lid_seq OWNED BY users.uid;


--
-- Name: libraries_lid_seq; Type: SEQUENCE SET; Schema: public; Owner: mapapp
--

SELECT pg_catalog.setval('libraries_lid_seq', 139, true);


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
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.request_seq OWNER TO mapapp;

--
-- Name: request_seq; Type: SEQUENCE SET; Schema: public; Owner: mapapp
--

SELECT pg_catalog.setval('request_seq', 420, true);


--
-- Name: request; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE request (
    id integer DEFAULT nextval('request_seq'::regclass) NOT NULL,
    title character varying(1024),
    author character varying(256),
    requester integer NOT NULL,
    patron_barcode character(14),
    current_source_sequence_number integer DEFAULT 1
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
    call_number character varying(30)
);


ALTER TABLE public.sources OWNER TO mapapp;

--
-- Name: gid; Type: DEFAULT; Schema: public; Owner: mapapp
--

ALTER TABLE authgroups ALTER COLUMN gid SET DEFAULT nextval('authgroups_gid_seq'::regclass);


--
-- Name: uid; Type: DEFAULT; Schema: public; Owner: mapapp
--

ALTER TABLE users ALTER COLUMN uid SET DEFAULT nextval('libraries_lid_seq'::regclass);


--
-- Data for Name: authgroups; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY authgroups (gid, authorization_group) FROM stdin;
1	basic
2	request
3	CDT
4	reports
5	headquarters
6	admin
\.


--
-- Data for Name: libraries; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY libraries (lid, name, password, active, email_address, admin, library, mailing_address_line1, mailing_address_line2, mailing_address_line3, ill_sent, home_zserver_id, home_zserver_location, last_login, unverified_patron_request_limit, town, region, ebsco_user, ebsco_pass, use_standardresource, use_databaseresource, use_electronicresource, use_webresource, wpl_institution_card) FROM stdin;
97	MNW	MNW	1	neepawa@wmrlibrary.mb.ca	0	Western Manitoba Regional  Library - Neepawa	280 Davidson St.	Box 759	Neepawa, MB  R0J 1H0	485	5	mnw	2011-02-03 12:02:04.730694	2	Neepawa	WESTMAN	s6844425	password	t	f	f	f	\N
9	MNHA	MNHA	1	tansi23@hotmail.com	0	Ayamiscikewikamik		Box 250	Norway House, MB  ROB 1BO	0	1	MNHA	2010-07-27 11:50:28.606789	2	\N	\N	\N	\N	t	f	f	f	\N
127	Caitlyn	Caitlyn	0		1	PLS - clerk				0	1		\N	2	\N	\N	\N	\N	t	f	f	f	\N
2	test	123	1	David_A_Christensen@hotmail.com	0	A Test Library	456 Someother St.	Mycity, MB  R7A 0X0	\N	0	1	test	\N	2	\N	\N	\N	\N	t	f	f	f	\N
128	Margo	me	1		1	PLS - staff				\N	1		2008-09-15 15:49:51	2	\N	\N	\N	\N	t	f	f	f	\N
105	MWRR	MWRR	0	lgirardi@rrcc.mb.ca	0	Red River College	2055 Notre Dame Ave		Winnipeg, MB  R3H 0J9	0	1	MWRR	\N	2	\N	\N	\N	\N	t	f	f	f	\N
106	MWTS	MWTS	0	lisanne.wood@mts.mb.ca	0	Manitoba Telecom Services Corporate	489 Empress St.	Box 6666	Winnipeg, MB  R3C 3V6	0	1	MWTS	\N	2	\N	\N	\N	\N	t	f	f	f	\N
108	MSERC	MSERC	0	serc2mb@mb.sympatico.ca	0	Brandon SERC	731B Princess Ave		Brandon, MB  R7A 0P4	0	1	MSERC	\N	2	\N	\N	\N	\N	t	f	f	f	\N
109	MWMRC	MWMRC	0	bdearth@itc.mb.ca	0	Industrial Technology Centre	200-78 Innovation Drive		Winnipeg, MB  R3T 6C2	0	1	MWMRC	\N	2	\N	\N	\N	\N	t	f	f	f	\N
95	MCNC	discover	1	carberry@wmrlibrary.mb.ca	0	Western Manitoba Regional Library - Carberry/North Cypress	115 Main Street	Box 382	Carberry, MB  R0K 0H0	623	5	mcnc	2011-02-01 16:29:41.937069	2	Carberry	WESTMAN	carberry	carberry	t	f	f	f	\N
13	MIBR	MIBR	1	ritchotlib@hotmail.com	0	Bibliothèque Ritchot - Main	310 Lamoureux Rd.	Box 340	Ile des Chenes, MB  R0A 0T0	556	1	MIBR	2011-02-01 16:34:41.862614	2	Ile des Chenes	EASTMAN	s6314735	password	t	f	f	f	\N
68	MP	EDNA	1	email@pinawapubliclibrary.com	0	Pinawa Public Library	Vanier Road	General Delivery	Pinawa, MB  R0E 1L0	845	22		2011-02-02 19:44:16.889087	2	Pinawa	EASTMAN	s1035842	password	t	f	f	f	\N
80	MSL	MSL	1	dslibrary@hotmail.com	0	Snow Lake Community Library	101 Cherry St.	Box 760	Snow Lake, MB  R0B 1M0	274	1	MSL	2011-02-03 12:37:04.304046	2	Snow Lake	NORMAN	s6208129	password	t	f	f	f	\N
29	MGE	MGE	1	gimli.library@mts.net	0	Evergreen Regional Library - Main	65 First Avenue	Box 1140	Gimli, MB  R0C 1B0	596	1	MGE	2011-02-03 12:56:09.653775	2	Gimli	INTERLAKE	evergreenreg	trial	t	f	f	f	\N
58	MDPGV	MDPGV	1	grandvw@mts.net	0	Parkland Regional Library - Grandview	433 Main St.	Box Box 700	Grandview, MB  R0L 0Y0	701	2		2011-02-01 15:07:26.727646	2	Grandview	PARKLAND	grandview	grandview	t	f	f	f	\N
107	MDPST	MDPST	1	stratlibrary@mts.net	0	Parkland Regional Library - Strathclair	50 Main St.	Box 303	Strathclair, MB  R0J 2C0	37	2		2011-01-31 09:12:18.896689	2	Strathclair	WESTMAN	strathclair	strathclair	t	f	f	f	\N
134	MDS	MDS	1	staff@springfieldlibrary.ca	0	Springfield Public Library	Box 340		Dugald, MB  R0E 0K0	\N	1	MDS	2011-02-02 12:28:41.043479	2	Oakbank	EASTMAN	\N	\N	t	f	f	f	\N
81	MWOWH	MWOWH	1	headlib@scrlibrary.mb.ca	0	South Central Regional Library - Office	160 Main Street   (325-5864)	Box 1540	Winkler, MB  R6W 4B4	0	12	MWOWH	2010-09-30 14:30:24.845846	2	\N	\N	\N	\N	t	f	f	f	\N
63	MDPOR	MDPOR	1	orlibrary@inetlink.ca	0	Parkland Regional Library - Ochre River	203 Main St.	Box 219	Ochre River, MB  R0L 1K0	281	2		2011-02-02 17:58:17.64862	2	Ochre River	PARKLAND	s9233164	password	t	f	f	f	\N
137	TEST	TEST	1	nowhere@just.testing	0	A test library				\N	61	TEST	2011-02-02 18:50:18.609395	2	\N	\N	\N	\N	t	f	f	f	\N
121	TWAS	TWAS	1		0	Bren Del Win Centennial Library - Waskada	30 Souris Ave.		Waskada, MB  R0M 2E0	0	47	TWAS	\N	2	Waskada	WESTMAN	\N	\N	t	f	f	f	\N
122	MPFN	MPFN	1	peguislibrary@yahoo.ca	0	Peguis Community	Lot 30 Peguis Indian Reserve	Box Box 190	Peguis, MB  R0J 3J0	0	1	MPFN	2009-03-04 17:23:42	2	Peguis	INTERLAKE	\N	\N	t	f	f	f	\N
75	MBA	MBA	1	rmargyle@gmail.com	0	R.M. of Argyle Public Library	627 Elizabeth Ave. E.	Box 10	Baldur, MB  R0K 0B0	45	1	MBA	2011-02-01 10:00:40.596398	2	Baldur	WESTMAN	s7204480	password	t	f	f	f	\N
125	MNCN	MNCN	1	NCNBranch@Thompsonlibrary.com	0	Thompson Public Library - Nelson House	1 ATEC Drive	Box 454	Nelson House, MB  R0B 1A0	0	10	MNCN	\N	2	Nelson House	NORMAN	\N	\N	t	f	f	f	\N
35	MHH	MHH	1	hml@mts.net	0	Headingley Municipal Library	49 Alboro Street		Headingley, MB  R4J 1A3	1153	44	HML	2011-02-03 10:21:31.672572	2	Headingly	CENTRAL	s6875882	password	t	f	f	f	\N
78	MSTR	MSTR	1	sroselib@mts.net	0	Ste. Rose Regional Library	580 Central Avenue	General Delivery	Ste. Rose du Lac, MB  R0L 1S0	662	1	MSTR	2011-02-03 12:41:49.075946	2	Ste. Rose du Lac	PARKLAND	library	reader	t	f	f	f	\N
124	MDPSLA	MDPSLA	1	lazarelib@mts.net	0	Parkland Regional Library - St. Lazare		Box 201	St. Lazare, MB  R0M 1Y0	43	2		2010-11-25 17:06:24.004507	2	St. Lazare	WESTMAN	\N	\N	t	f	f	f	\N
103	MEPL	MEPL	1	library@townofemerson.com	0	Emerson Library	104 Church Street	Box 340	Emerson, MB  R0A 0L0	147	1	MEPL	2011-01-24 18:56:43.490848	2	Emerson	CENTRAL	s6763302	password	t	f	f	f	\N
37	MSSM	MSSM	1	stmlibrary@jrlibrary.mb.ca	0	Jolys Regional Library - St. Malo	189 St. Malo Street	Box 593	St.Malo, MB  R0A 1T0	200	1	MSSM	2011-02-02 15:43:01.43152	2	St. Malo	EASTMAN	saint	malo	t	f	f	f	\N
28	MCH	MCH	1	mchlibrary@yahoo.ca	0	Churchill Public Library	180 Laverendrye	Box 730	Churchill, MB  R0B 0E0	97	1	MCH	2011-02-03 10:04:52.805515	2	Churchill	NORMAN	s6722383	password	t	f	f	f	\N
27	MEL	MEL	1	epl1@mts.net	0	Eriksdale Public Library	PTH 68  (9 Main St.)	Box 219	Eriksdale, MB  R0C 0W0	389	1	MEL	2011-02-03 12:27:27.45312	2	Eriksdale	INTERLAKE	mel	mel	t	f	f	f	\N
77	MBI	MBI	1	binslb@mts.net	0	Russell & District Library - Binscarth	106 Russell St.	Box  379	Binscarth, MB  R0J 0G0	49	1	MBI	2011-01-12 16:33:26.593717	2	Binscarth	PARKLAND	binscarth	binscarth	t	f	f	f	\N
61	MDPMC	MDPMC	1	mccrea16@mts.net	0	Parkland Regional Library - McCreary	615 Burrows Rd.	Box 297	McCreary, MB  R0J 1B0	112	2		2011-01-18 15:43:28.57626	2	McCreary	PARKLAND	mccreary	mccreary	t	f	f	f	\N
42	MLR	MLR	1	lrlib@mts.net	0	Leaf Rapids Public Library	20 Town Centre	Box 190	Leaf Rapids, MB  R0B 1W0	33	1	MLR	2009-05-25 18:16:48	2	Leaf Rapids	NORMAN	s6970871	password	t	f	f	f	\N
67	MDPWP	MDPWP	1	wpgosis@mts.net	0	Parkland Regional Library - Winnipegosis	130 2nd St.	Box Box 10	Winnipegosis, MB  R0L 2G0	190	2		2011-02-02 14:18:10.749017	2	Winnipegosis	PARKLAND	winnipegosis	winnipegosis	t	f	f	f	\N
88	MESMN	MESMN	1	smrl1nap@yahoo.ca	0	Southwestern Manitoba Regional Library - Napinka	57 Souris St.	Box 975	Melita, MB  R0M 1L0	0	4	MESM	2010-09-14 14:14:28.201392	2	Napinka	WESTMAN	napinka	napinka	t	f	f	f	\N
43	MLLC	MLLC	1	lynnlib@mts.net	0	Lynn Lake Centennial Library	503 Sherritt Ave.	Box 1127	Lynn Lake, MB  R0B 0W0	0	1	MLLC	\N	2	Lynn Lake	NORMAN	s6993334	password	t	f	f	f	\N
50	MDPBR	MDPBR	1	briver@mts.net	0	Parkland Regional Library - Birch River	116 3rd St. East	Box 245	Birch River, MB  R0L 0E0	0	2		2008-12-18 20:36:09	2	Birch River	PARKLAND	birch	river	t	f	f	f	\N
60	MDPLA	MDPLA	1	langlib@mts.net	0	Parkland Regional Library - Langruth	402 Main St.	Box 154	Langruth, MB  R0H 0N0	2	2		2010-07-30 09:16:07.67375	2	Langruth	CENTRAL	langruth	langruth	t	f	f	f	\N
72	MRA	MRA	1	rcreglib@mts.net	0	Rapid City Regional Library	425 3rd Ave.	Box 8	Rapid City, MB  R0K 1W0	104	1	MRA	2011-12-14 09:56:50.843109	2	Rapid City	WESTMAN	s5826566	password	t	f	f	f	\N
90	mste	mste	1	steinlib@rocketmail.com	0	Jake Epp Library	255 Elmdale Street		Steinbach, MB  R5G 0C9	1186	16	Jake Epp	2011-11-30 14:11:19.491873	2	Steinbach	EASTMAN	jake	ebscotrial	t	f	f	f	\N
1	DTL	DTL123	1	David_A_Christensen@hotmail.com	1	The Great Library of Davidland	123 Some Street South	Brandon, MB  R7A 7A1		11	1	mwpl	2009-12-09 15:11:39.580858	2	\N	\N	\N	\N	t	f	f	f	\N
89	MESP	MESP	1	pcilibrary@goinet.ca	0	Southwestern Manitoba Regional Library - Pierson	58 Railway Avenue	Box 39	Pierson, MB  R0M 1S0	189	4	MESP	2011-01-28 09:45:37.364496	2	Pierson	WESTMAN	s2487764	password	t	f	f	f	\N
54	MDPER	MDPER	1	erick11@mts.net	0	Parkland Regional Library - Erickson	20 Main St. W	Box 385	Erickson, MB  R0J 0P0	173	2		2011-02-01 11:11:13.915092	2	Erickson	WESTMAN	s6085216	password	t	f	f	f	\N
49	MDP	MDP	1	prlhq@parklandlib.mb.ca	0	Parkland Regional Library - Main	504 Main St. N.		Dauphin, MB  R7N 1C9	6	2		2011-01-25 13:15:46.362271	2	\N	\N	\N	\N	t	f	f	f	\N
111	MSSC	MSSC	1	shilocommunitylibrary@yahoo.ca	0	Shilo Community Library  (765-3000 ext 3664)		Box Box 177	Shilo, MB  R0K 2A0	52	1	MSSC	2011-02-01 15:25:17.713108	2	\N	\N	\N	\N	t	f	f	f	\N
79	MSEL	MSEL	1	ill@ssarl.org	0	Red River North Regional Library	303 Main Street		Selkirk, MB  R1A 1S7	2778	3	MSEL	2011-02-03 11:43:52.618821	2	Selkirk	INTERLAKE	redrivernorth	steelers	t	f	f	f	\N
138			0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	t	f	f	f	\N
17	MLB	bsjlromd	1	bsjl@bsjl.ca	0	Bibliothèque Saint-Joachim Library	29, baie Normandeau Bay	Box 39	La Broquerie, MB  R0A 0W0	489	57	MLB	2011-02-02 08:08:42.558263	2	La Broquerie	EASTMAN	s6416082	password	t	f	f	f	\N
52	MDPBO	MDPBO	1	bows18@mts.net	0	Parkland Regional Library - Bowsman	105 2nd St.	Box 209	Bowsman, MB  R0L 0H0	25	2		2011-01-04 11:20:46.044179	2	Bowsman	PARKLAND	bowsman	bowsman	t	f	f	f	\N
55	MDPFO	MDPFO	1	foxlib@mts.net	0	Parkland Regional Library - Foxwarren	312 Webster Ave.	Box 204	Foxwarren, MB  R0J 0P0	234	2		2011-02-01 10:41:17.93653	2	Foxwarren	WESTMAN	s9052086	password	t	f	f	f	\N
100	MWP	MWP	1	legislative_library@gov.mb.ca	0	Manitoba Legislative Library	100 - 200 Vaughan		Winnipeg, MB  R3C 1T5	0	14	MWP	2010-05-13 10:04:18.931478	2	\N	\N	\N	\N	t	f	f	f	\N
86	MTSIR	MTSIR	1	teulonbranchlibrary@yahoo.com	0	South Interlake Regional Library - Teulon	19 Beach Road	Box 68	Teulon, MB  R0C 3B0	726	19	Teulon	2011-02-02 10:47:07.748734	2	Teulon	INTERLAKE	teulon	teulon	t	f	f	f	\N
102	MHP	MHP	1	victlib@goinet.ca	0	Victoria Municipal Library	102 Stewart Ave	Box 371	Holland, MB  R0G 0X0	313	1	MHP	2011-01-27 16:50:14.499442	2	Holland	CENTRAL	s6825002	password	t	f	f	f	\N
11	MSJB	MSJB	1	biblio@atrium.ca	0	Bibliothèque Montcalm	113B 2nd	Box 345	Saint-Jean-Baptiste, MB  R0G 2B0	191	1	MSJB	2011-02-02 09:30:53.111402	2	Saint-Jean-Baptiste	CENTRAL	s6151884	password	t	f	f	f	\N
31	MRB	LAKE	1	rlibrary@mts.net	0	Evergreen Regional Library - Riverton	56 Laura Ave.	Box 310	Riverton, MB  R0C 2R0	685	1	MRB	2011-02-02 16:19:56.015028	2	Riverton	INTERLAKE	riverton	riverton	t	f	f	f	\N
47	MBB	MBB	1	benlib@mts.net	0	North-West Regional Library - Benito Branch	140 Main Street	Box 220	Benito, MB  R0L 0C0	592	1	MBB	2011-01-27 14:18:36.739511	2	Benito	PARKLAND	benito	benito	t	f	f	f	\N
22	ME	brlelk	1	elkhornbrl@rfnow.com	0	Border Regional Library - Elkhorn	211 Richhill Ave.	Box 370	Elkhorn, MB  R0M 0N0	297	9	ME	2011-02-03 09:59:18.485715	2	Elkhorn	WESTMAN	borderelkhorn	BorderRegional	t	f	f	f	\N
41	MPM	MPM	1	pmlibrary@mts.net	0	Pilot Mound Public Library - Pilot Mound	219 Broadway Ave. W.	Box 126	Pilot Mound, MB  R0G 1P0	113	1	MPM	2011-02-03 10:55:31.63491	2	Pilot Mound	CENTRAL	pilot	mound	t	f	f	f	\N
45	MMNN	MMNN	1	maclib@mts.net	0	North Norfolk-MacGregor Library	35 Hampton St. E.	Box 760	MacGregor, MB  R0H 0R0	1515	1	MMNN	2011-02-02 15:10:26.856663	2	MacGregor	CENTRAL	s7049550	password	t	f	f	f	\N
14	MSAD	MSAD	1	stadbranch@hotmail.com	0	Bibliothèque Ritchot - St. Adolphe	444 rue La Seine		St. Adolphe, MB  R5A 1C2	293	1	MSAD	2011-02-02 15:52:05.639717	2	St. Adolphe	EASTMAN	sal	adolphe	t	f	f	f	\N
73	MRP	MRP	1	restonlb@yahoo.ca	0	Reston District Library	220 - 4th St.	Box 340	Reston, MB  R0M 1X0	655	45	RDL	2011-02-03 11:23:53.280404	2	Reston	WESTMAN	reston	trial	t	f	f	f	\N
66	MDPSI	MDPSI	1	siglun15@mts.net	0	Parkland Regional Library - Siglunes	5 - 61 Main St.	Box 368	Ashern, MB  R0C 0E0	71	2		2011-02-02 15:17:39.520904	2	Ashern	INTERLAKE	siglunes	siglunes	t	f	f	f	\N
15	MSAG	MSAG	1	bibliosteagathe@atrium.ca	0	Bibliothèque Ritchot - Ste. Agathe	310 Chemin Pembina Trail	Box 40	Sainte-Agathe, MB  ROG 1YO	107	1	MSAG	2011-02-02 19:05:31.804753	2	Ste. Agathe	EASTMAN	saint	agathe	t	f	f	f	\N
23	MMCA	MMCA	1	library@mcauley-mb.com	0	Border Regional Library - McAuley	207 Qu'Appelle Street	Box 234	McAuley, MB  R0M 1H0	44	9	MMCA	2011-01-25 14:27:40.737841	2	McAuley	WESTMAN	bordermcauley	BorderRegional	t	f	f	f	\N
76	MRD	MRD	1	ruslib@mts.net	0	Russell & District Regional Library - Main	339 Main St.	Box 340	Russell, MB  R0J 1W0	940	1	MRD	2011-02-01 13:17:19.029251	2	Russell	PARKLAND	s1036253	password	t	f	f	f	\N
136	MVBB	MVBB	1	victoriabeachbranch@hotmail.com	0	Bibliotheque Allard - Victoria Beach	Box 279	Victoria Beach, MB  R0E 2C0		\N	41	MVBB	2010-12-15 14:34:37.863963	2	\N	\N	\N	\N	t	f	f	f	\N
62	MDPMI	MDPMI	1	minitons@mts.net	0	Parkland Regional Library - Minitonas	300 Main St.	Box 496	Minitonas, MB  R0L 1G0	402	2		2011-02-02 15:14:04.465687	2	Minitonas	PARKLAND	minitonas	minitonas	t	f	f	f	\N
20	MBOM	MBOM	1	mbomill@mts.net	0	Boissevain and Morton Regional Library	436 South Railway St.	Box 340	Boissevain, MB  R0K 0E0	1183	1	MBOM	2011-02-03 11:19:31.00892	2	Boissevain	WESTMAN	s6080402	password	t	f	f	f	\N
74	MRO	MRO	1	rrl@mts.net	0	Rossburn Regional Library	53 Main St. North	Box 87	Rossburn, MB  R0J 1V0	149	1	MRO	2011-01-28 15:18:05.156408	2	Rossburn	PARKLAND	s5913667	password	t	f	f	f	\N
19	MS	lucy	1	somlib@mts.net	0	Bibliotheque Somerset Library	Box 279	289 Carlton Avenue 	Somerset, MB  R0G 2L0	352	1	MS	2011-02-01 15:51:52.043388	2	Somerset	CENTRAL	s6463631	password	t	f	f	f	\N
25	MDB	bdwcl	1	bdwlib@mts.net	0	Bren Del Win Centennial Library	211 North Railway W.	Box 584	Deloraine, MB  R0M 0M0	520	47	MDB	2011-12-11 13:04:07.0358	2	Deloriane	WESTMAN	s6568841	password	t	f	f	f	\N
71	MRIP	MRIP	1	pcrl@mts.net	0	Prairie Crocus Regional Library	137 Main Street	Box 609	Rivers, MB  R0K 1X0	610	37	MRIP	2011-11-30 12:26:50.620987	2	Rivers	WESTMAN	s7183384	password	t	f	f	f	\N
18	msa	msa	1	steannelib@steannemb.ca	0	Bibliothèque Ste. Anne	16 rue de l'Eglise		Ste. Anne, MB  R5H 1H8	607	36	MSA	2011-12-14 10:27:10.867185	2	Ste. Anne	EASTMAN	s6481383	password	t	f	f	f	\N
82	MAOW	maow	1	aill@scrlibrary.mb.ca	0	South Central Regional Library - Altona	113-125 Centre Ave. E. (324-1503)	Box 650	Altona, MB  R0G 0B0	794	12	Altona	2011-12-11 10:32:41.844969	2	Altona	CENTRAL	s6353086	password	t	f	f	f	\N
85	MSTOS	MSTOS	1	circ@sirlibrary.com	0	South Interlake Regional Library - Main	419 Main St.		Stonewall, MB  R0C 2Z0	1391	19	Stonewall	2011-12-14 08:23:56.791976	2	Stonewall	INTERLAKE	s1036635	password	t	f	f	f	\N
84	MWOW	MWOW	1	will@scrlibrary.mb.ca	0	South Central Regional Library - Winkler	160 Main Street (325-7174)	Box 1540	Winkler, MB  R6W 4B4	1408	12	Winkler	2011-12-11 10:31:18.579992	2	Winkler	CENTRAL	s6465864	password	t	f	f	f	\N
98	MMR	MMR	1	mmr@mts.net	0	Minnedosa Regional Library	45 1st  Ave. SE	Box 1226	Minnedosa, MB  R0J 1E0	577	25	Minnedosa	2011-12-14 09:23:21.882524	2	Minnedosa	WESTMAN	minnedosarl	minnedosarl	t	f	f	f	\N
21	MVE	MVE	1	borderlibraryvirden@rfnow.com	0	Border Regional Library - Main	312 - 7th  Avenue	Box 970	Virden, MB  R0M 2C0	1762	9	MVE	2011-12-14 10:43:38.549119	2	Virden	WESTMAN	bordervirden	BorderRegional	t	f	f	f	\N
91	MTP	MTP	1	illthepas@mts.net	0	The Pas Regional Library	53 Edwards Avenue	Box 4100	The Pas, MB  R9A 1R2	779	1	MTP	2011-02-02 15:54:58.568087	2	The Pas	NORMAN	s6571842	password	t	f	f	f	\N
38	MLDB	MLDB	1	mldb@mts.net	0	Lac du Bonnet Regional Library	84-3rd Street	Box 216	Lac du Bonnet, MB  R0E 1A0	1237	39	LDBRL	2011-02-03 10:17:25.172551	2	Lac du Bonnet	EASTMAN	\N	\N	t	f	f	f	\N
46	MSRN	MSRN	1	nwrl@mymts.net	0	North-West Regional Library - Main	610-1st  St. North	Box 999	Swan River, MB  R0L 1Z0	1368	11		2011-02-03 11:42:08.406029	2	Swan River	PARKLAND	s7071953	password	t	f	f	f	\N
40	MCCB	CC111	1	cartlib@mts.net	0	Lakeland Regional Library - Cartwright	483 Veteran Drive	Box 235	Cartwright, MB  R0K 0L0	480	18	Cartwright Library	2011-02-02 16:34:12.994159	2	Cartwright	CENTRAL	cartwright	Cartwright	t	f	f	f	\N
53	MDA	MDA	1	DauphinLibrary@parklandlib.mb.ca	0	Parkland Regional Library - Dauphin	504 Main Street North		Dauphin, MB  R7N 1C9	1918	2		2011-02-02 19:42:49.630926	2	Dauphin	PARKLAND	s4732742	password	t	f	f	f	\N
65	MDPSL	MDPSL	1	sllibrary@mts.net	0	Parkland Regional Library - Shoal Lake	418 Station Road S.	Box 428	Shoal Lake, MB  R0J 1Z0	231	2		2011-02-01 14:06:09.972297	2	Shoal Lake	WESTMAN	s7725300	password	t	f	f	f	\N
39	MKL	MKL	1	lrl@mts.net	0	Lakeland Regional Library - Main	318 Williams Ave.	Box 970	Killarney, MB  R0K 1G0	2060	18	Lakeland Regional Library	2011-02-03 09:31:24.817916	2	Killarney	WESTMAN	s8921274	password	t	f	f	f	\N
51	MDPBI	MDPBI	1	birtlib@mts.net	0	Parkland Regional Library - Birtle	907 Main Street	Box 207	Birtle, MB  R0M 0C0	294	2		2011-02-03 11:31:03.715139	2	Birtle	WESTMAN	birtle	birtle	t	f	f	f	\N
16	MSCL	MSCL	1	stclib@mts.net	0	Bibliothèque Saint-Claude	50 1st Street	Box 203	St. Claude, MB  R0G 1Z0	53	1	MSCL	2011-01-20 11:20:23.16518	2	St. Claude	CENTRAL	s6393310	password	t	f	f	f	\N
110	MBBB	MBBB	1	beacheslibrary@hotmail.com	0	Bibliotheque Allard - Beaches	40005 Jackfish Lake Rd. N. Walter Whyte School	Box 279	Victoria Beach, MB  R0E 2C0	231	41	BBL	2011-01-27 16:15:41.161472	2	Traverse Bay	EASTMAN	s5772290	Password	t	f	f	f	\N
12	MNDP	MNDP	1	ndbiblio@yahoo.ca	0	Bibliothèque Pere Champagne	44 Rue Rogers	Box 399	Notre Dame de Lourdes, MB  R0G 1M0	320	50	MNDP	2011-02-01 09:47:15.311152	2	Notre Dame de Lourdes	CENTRAL	ndbiblio	password	t	f	f	f	\N
69	MPLP	MPLP	1	portlib@portagelibrary.com	0	Portage La Prairie Regional Library	40-B Royal Road N		Portage La Prairie, MB  R1N 1V1	1228	15		2011-02-02 13:51:02.458258	2	Portage la Prairie	CENTRAL	s7165579	password	t	f	f	f	\N
26	MBBR	MBBR	1	brrlibr2@mts.net	0	Brokenhead River Regional Library	427 Park  Ave.	Box 1087	Beausejour, MB  R0E 0C0	1231	42	BRRL	2011-02-02 17:21:32.430374	2	Beausejour	EASTMAN	s4239300	password	t	f	f	f	\N
120	MHW	MHW	1	hartney@wmrlibrary.mb.ca	0	Western Manitoba Regional - Hartney Cameron Branch	209 Airdrie St.	Box 121	Hartney, MB  R0M 0X0	428	5	mhw	2011-01-29 11:28:09.80128	2	Hartney	WESTMAN	\N	\N	t	f	f	f	\N
94	MBW	rescue	1	bdnill@wmrlibrary.mb.ca	0	Western Manitoba Regional Library - Brandon	710 Rosser Avenue, Unit 1		Brandon, MB  R7A 0K9	996	5	mbw	2011-02-02 17:17:51.888922	2	Brandon	WESTMAN	s5521791	p0011656	t	f	f	f	\N
32	MFF	SHOELACE	1	ffplill@mts.net	0	Flin Flon Public Library	58 Main Street		Flin Flon, MB  R8A 1J8	981	64	MFF	2011-02-03 09:48:59.054205	2	Flin Flon	NORMAN	s6829351	password	t	f	f	f	\N
93	MMVR	MMVR	1	valleylib@mts.net	0	Valley Regional Library	141Main Street South	Box 397	Morris, MB  R0G 1K0	812	1	MMVR	2011-02-03 12:17:58.225938	2	Morris	CENTRAL	s6683258	password	t	f	f	f	\N
10	MSTG	MSTG	1	ill@allardlibrary.com	0	Bibliotheque Allard	104086 PTH 11	Box 157	St Georges, MB  R0E 1V0	651	40	BARL	2011-02-03 12:15:00.441084	2	St Georges	EASTMAN	s6091479	password	t	f	f	f	\N
112	ASGY	ASGY	0	lfrolek@yrl.ab.ca	0	Yellowhead Regional		Box 400	Spruce Grove, AB, MB  T7X 2Y1	0	1	ASGY	\N	2	\N	\N	\N	\N	t	f	f	f	\N
104	MBAC	MBAC	1	library@assiniboinec.mb.ca	0	Assiniboine Community College	1430 Victoria Avenue East		Brandon, MB  R7A 2A9	4	1	MBAC	2011-01-25 14:07:16.067536	2	\N	\N	\N	\N	t	f	f	f	\N
44	MMA	MMA	1	manitoulibrary@mts.net	0	Manitou Regional Library	418 Main St.	Box 432	Manitou, MB  R0G 1G0	596	1	MMA	2011-02-02 10:25:10.147195	2	Manitou	CENTRAL	s7007965	password	t	f	f	f	\N
30	MAB	TIME	1	arborglibrary@mts.net	0	Evergreen Regional Library - Arborg	292 Main Street	Box 4053	Arborg, MB  R0C 0A0	1598	1	MAB	2011-02-02 12:49:01.029413	2	Arborg	INTERLAKE	arborg	arborg	t	f	f	f	\N
57	MDPGL	MDPGL	1	gladstne@mts.net	0	Parkland Regional Library - Gladstone	42 Morris Avenue N.	Box 720	Gladstone, MB  R0J 0T0	1125	2		2011-02-03 10:06:30.811072	2	Gladstone	CENTRAL	\N	\N	t	f	f	f	\N
64	MDPRO	MDPRO	1	roblinli@mts.net	0	Parkland Regional Library - Roblin	123 lst Ave. N.	Box 1342	Roblin, MB  R0L 1P0	387	2		2011-01-25 15:18:33.838446	2	Roblin	PARKLAND	roblin	roblin	t	f	f	f	\N
96	MGW	MGW	1	jackie@wmrl.ca	0	Western Manitoba Regional  Library - Glenboro/South Cypress	105 Broadway St.	Box 429	Glenboro, MB  R0K 0X0	518	5	mgw	2011-02-01 16:29:58.638328	2	Glenboro	WESTMAN	glenboro	glenboro	t	f	f	f	\N
33	MGI	MGI11	1	bwinner@gillamnet.com	0	Bette Winner Public Library	235 Mattonnabee Ave.	Box 400	Gillam, MB  R0B 0L0	184	1	MGI	2011-02-01 16:54:57.526489	2	Gillam	NORMAN	bwpl	bwpl	t	f	f	f	\N
48	MLPJ	MLPJ	1	mlpj@mts.net	0	Pauline Johnson Library	23 Main Street	Box 698	Lundar, MB  R0C 1Y0	330	1	MLPJ	2011-02-03 10:48:25.445635	2	Lundar	INTERLAKE	s7132074	password	t	f	f	f	\N
135	MMIOW	MMIOW	1	thlib@scrlibrary.mb.ca	0	South Central Regional Library - Miami	423 Norton Avenue	(Box 431)	Miami, MB  R0G 1H0	\N	12	Miami	2011-02-01 11:22:57.344337	2	Miami	CENTRAL	\N	\N	t	f	f	f	\N
56	MDPGP	MDPGP	1	gilbert3@mts.net	0	Parkland Regional Library - Gilbert Plains	113 Main St. N.	Box 303	Gilbert Plains, MB  R0L 0X0	75	2		2011-01-29 16:19:27.923943	2	Gilbert Plains	PARKLAND	gilbert	plains	t	f	f	f	\N
59	MDPHA	MDPHA	1	hamlib@mymts.net	0	Parkland Regional Library - Hamiota	43 Maple Ave. E.	Box 609	Hamiota, MB  R0M 0T0	361	2		2011-02-01 16:33:06.705467	2	Hamiota	WESTMAN	hamiota	hamiota	t	f	f	f	\N
131	UCN	UCN321	1		1	University Colleges North pilot project				\N	0		2010-12-16 14:12:00.413037	2	\N	\N	\N	\N	t	f	f	f	\N
119	MTPL	MTPL	1	btl@srsd.ca	0	Bibliothque Publique Tache Public Library - Main		Box 16	Lorette, MB  R0A 0Y0	571	1	MTPL	2011-02-02 16:00:40.614521	2	Lorette	EASTMAN	\N	\N	t	f	f	f	\N
113	MWSC	MWSC	1	library@smd.mb.ca	0	Society for Manitobans with Disabilities - Stephen Sparling	825 Sherbrooks Street		Winnipeg, MB  R3A 1M5	0	1	MWSC	\N	2	\N	\N	\N	\N	t	f	f	f	\N
114	MWEMM	MWEMM	0	LJanower@gov.mb.ca	0	Manitoba Industry Trade and Mines - Mineral Resource	Suite 360 - 1395 Ellice Ave.		Winnipeg, MB  R3G 3P2	0	1	MWEMM	\N	2	\N	\N	\N	\N	t	f	f	f	\N
115	OKE	OKE	0	eroussin@kenora.ca	0	Kenora Public Library	24 Main St. South		Kenora, Ontario, MB  P9N 1S7	0	1	OKE	\N	2	\N	\N	\N	\N	t	f	f	f	\N
83	MMOW	MMOW	1	mill@scrlibrary.mb.ca	0	South Central Regional Library - Morden	514 Stephen Street	Morden, MB  R6M 1T7	204-822-4092	2145	12	Morden	2011-12-11 10:31:57.191308	2	Morden	CENTRAL	s5521766	p0011655	t	f	f	f	\N
87	MESM	MESM	1	swmblib@mts.net	0	Southwestern Manitoba Regional Library - Main	149 Main St. S.	Box 639	Melita, MB  R0M 1L0	1290	4	Main	2011-12-14 09:37:23.553132	2	Melita	WESTMAN	s8921298	password	t	t	t	t	\N
34	MSOG	MSOG	1	ill@sourislibrary.mb.ca	0	Glenwood & Souris Regional Library	18 - 114 2nd St. S.	Box 760	Souris, MB  R0K 2C0	1115	34	MSOG	2011-12-14 10:14:31.094645	2	Souris	WESTMAN	s6859026	password	t	f	f	f	\N
116	CPL	CPL	0		0	Crocus Plains Regional Secondary School	1930 First Street		Brandon, MB  R7A 6Y6	0	1	CPL	\N	2	\N	\N	\N	\N	t	f	f	f	\N
117	MWHBCA	MWHBCA	0	hbca@gov.mb.ca	0	Hudsons Bay Company Archives	200 Vaughan St.		Winnipeg, MB  R3C 1T5	0	1	MWHBCA	\N	2	\N	\N	\N	\N	t	f	f	f	\N
118	MWJ	MWJ	0	jodi.turner@justice.gc.ca	0	Department of Justice	301-310 Broadway Avenue		Winnipeg, MB  R3C 0S6	0	1	MWJ	\N	2	\N	\N	\N	\N	t	f	f	f	\N
130	UNC	UNC321	1		0	Delete me!				\N	0		2008-07-28 15:22:43	2	\N	\N	\N	\N	t	f	f	f	\N
36	MSTP	MSTP	1	stplibrary@jrlibrary.mb.ca	0	Jolys Regional Library - Main	505 Hebert Ave. N.	Box 118	St. Pierre-Jolys, MB  R0A 1V0	1607	21	MSTP	2011-02-03 09:05:21.66346	2	St. Pierre	EASTMAN	s6110155	password	t	f	f	f	\N
132	Headingley Municipal Library	MHH	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	t	f	f	f	\N
24	MCB	MCB	1	illbrl@hotmail.com	0	Boyne Regional Library	15 - 1st Avenue SW	Box 788	Carman, MB  R0G 0J0	788	24	Main	2011-12-11 10:17:05.626512	2	Carman	CENTRAL	s1035547	password	t	f	f	f	\N
92	MTH	MTH	1	interlibraryloans@thompsonlibrary.com	0	Thompson Public Library	81 Thompson Drive North		Thompson, MB  R8N 0C3	743	10		2011-12-11 10:17:44.718333	2	Thompson	NORMAN	s8914567	password	t	f	f	f	\N
129	admin	maplin3db	1	David.A.Christensen@gmail.com	1	Maplin-3 Administrator				\N	0		2011-11-26 13:40:33.329782	2	\N	\N	\N	\N	t	f	f	f	\N
101	MWPL	MWPL	1	pls@gov.mb.ca	0	Public Library Services Branch	300 - 1011 Rosser Avenue		Brandon, MB  R7A 0L5	21	1	MWPL	2011-12-11 15:02:25.35302	2	\N	\N	s5521720	password	t	f	f	f	\N
99	MW	MW	1	wpl-illo@winnipeg.ca	0	Winnipeg Public Library : Interlibrary Loans	251 Donald St.		Winnipeg, MB  R3C 3P5	97	28		2011-12-14 08:28:55.271754	2	Winnipeg	WINNIPEG	\N	\N	t	f	f	f	1234567890
\.


--
-- Data for Name: library_barcodes; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY library_barcodes (lid, borrower, barcode) FROM stdin;
1	1	not configured
1	2	not configured
1	9	not configured
1	10	not configured
1	11	not configured
1	12	not configured
1	13	not configured
1	14	not configured
1	15	not configured
1	16	not configured
1	17	not configured
1	18	not configured
1	19	not configured
1	20	not configured
1	21	not configured
1	22	not configured
1	23	not configured
1	24	not configured
1	25	not configured
1	26	not configured
1	27	not configured
1	28	not configured
1	29	not configured
1	30	not configured
1	31	not configured
1	32	not configured
1	33	not configured
1	34	not configured
1	35	not configured
1	36	not configured
1	37	not configured
1	38	not configured
1	39	not configured
1	40	not configured
1	41	not configured
1	42	not configured
1	43	not configured
1	44	not configured
1	45	not configured
1	46	not configured
1	47	not configured
1	48	not configured
1	49	not configured
1	50	not configured
1	51	not configured
1	52	not configured
1	53	not configured
1	54	not configured
1	55	not configured
1	56	not configured
1	57	not configured
1	58	not configured
1	59	not configured
1	60	not configured
1	61	not configured
1	62	not configured
1	63	not configured
1	64	not configured
1	65	not configured
1	66	not configured
1	67	not configured
1	68	not configured
1	69	not configured
1	71	not configured
1	72	not configured
1	73	not configured
1	74	not configured
1	75	not configured
1	76	not configured
1	77	not configured
1	78	not configured
1	79	not configured
1	80	not configured
1	81	not configured
1	82	not configured
1	83	not configured
1	84	not configured
1	85	not configured
1	86	not configured
1	87	not configured
1	88	not configured
1	89	not configured
1	90	not configured
1	91	not configured
1	92	not configured
1	93	not configured
1	94	not configured
1	95	not configured
1	96	not configured
1	97	not configured
1	98	not configured
1	99	not configured
1	100	not configured
1	101	not configured
1	102	not configured
1	103	not configured
1	104	not configured
1	105	not configured
1	106	not configured
1	107	not configured
1	108	not configured
1	109	not configured
1	110	not configured
1	111	not configured
1	112	not configured
1	113	not configured
1	114	not configured
1	115	not configured
1	116	not configured
1	117	not configured
1	118	not configured
1	119	not configured
1	120	not configured
1	121	not configured
1	122	not configured
1	124	not configured
1	125	not configured
1	127	not configured
1	128	not configured
1	129	not configured
1	130	not configured
1	131	not configured
1	132	not configured
1	134	not configured
1	135	not configured
1	136	not configured
1	137	not configured
1	138	not configured
2	1	not configured
2	2	not configured
2	9	not configured
2	10	not configured
2	11	not configured
2	12	not configured
2	13	not configured
2	14	not configured
2	15	not configured
2	16	not configured
2	17	not configured
2	18	not configured
2	19	not configured
2	20	not configured
2	21	not configured
2	22	not configured
2	23	not configured
2	24	not configured
2	25	not configured
2	26	not configured
2	27	not configured
2	28	not configured
2	29	not configured
2	30	not configured
2	31	not configured
2	32	not configured
2	33	not configured
2	34	not configured
2	35	not configured
2	36	not configured
2	37	not configured
2	38	not configured
2	39	not configured
2	40	not configured
2	41	not configured
2	42	not configured
2	43	not configured
2	44	not configured
2	45	not configured
2	46	not configured
2	47	not configured
2	48	not configured
2	49	not configured
2	50	not configured
2	51	not configured
2	52	not configured
2	53	not configured
2	54	not configured
2	55	not configured
2	56	not configured
2	57	not configured
2	58	not configured
2	59	not configured
2	60	not configured
2	61	not configured
2	62	not configured
2	63	not configured
2	64	not configured
2	65	not configured
2	66	not configured
2	67	not configured
2	68	not configured
2	69	not configured
2	71	not configured
2	72	not configured
2	73	not configured
2	74	not configured
2	75	not configured
2	76	not configured
2	77	not configured
2	78	not configured
2	79	not configured
2	80	not configured
2	81	not configured
2	82	not configured
2	83	not configured
2	84	not configured
2	85	not configured
2	86	not configured
2	87	not configured
2	88	not configured
2	89	not configured
2	90	not configured
2	91	not configured
2	92	not configured
2	93	not configured
2	94	not configured
2	95	not configured
2	96	not configured
2	97	not configured
2	98	not configured
2	99	not configured
2	100	not configured
2	101	not configured
2	102	not configured
2	103	not configured
2	104	not configured
2	105	not configured
2	106	not configured
2	107	not configured
2	108	not configured
2	109	not configured
2	110	not configured
2	111	not configured
2	112	not configured
2	113	not configured
2	114	not configured
2	115	not configured
2	116	not configured
2	117	not configured
2	118	not configured
2	119	not configured
2	120	not configured
2	121	not configured
2	122	not configured
2	124	not configured
2	125	not configured
2	127	not configured
2	128	not configured
2	129	not configured
2	130	not configured
2	131	not configured
2	132	not configured
2	134	not configured
2	135	not configured
2	136	not configured
2	137	not configured
2	138	not configured
9	1	not configured
9	2	not configured
9	9	not configured
9	10	not configured
9	11	not configured
9	12	not configured
9	13	not configured
9	14	not configured
9	15	not configured
9	16	not configured
9	17	not configured
9	18	not configured
9	19	not configured
9	20	not configured
9	21	not configured
9	22	not configured
9	23	not configured
9	24	not configured
9	25	not configured
9	26	not configured
9	27	not configured
9	28	not configured
9	29	not configured
9	30	not configured
9	31	not configured
9	32	not configured
9	33	not configured
9	34	not configured
9	35	not configured
9	36	not configured
9	37	not configured
9	38	not configured
9	39	not configured
9	40	not configured
9	41	not configured
9	42	not configured
9	43	not configured
9	44	not configured
9	45	not configured
9	46	not configured
9	47	not configured
9	48	not configured
9	49	not configured
9	50	not configured
9	51	not configured
9	52	not configured
9	53	not configured
9	54	not configured
9	55	not configured
9	56	not configured
9	57	not configured
9	58	not configured
9	59	not configured
9	60	not configured
9	61	not configured
9	62	not configured
9	63	not configured
9	64	not configured
9	65	not configured
9	66	not configured
9	67	not configured
9	68	not configured
9	69	not configured
9	71	not configured
9	72	not configured
9	73	not configured
9	74	not configured
9	75	not configured
9	76	not configured
9	77	not configured
9	78	not configured
9	79	not configured
9	80	not configured
9	81	not configured
9	82	not configured
9	83	not configured
9	84	not configured
9	85	not configured
9	86	not configured
9	87	not configured
9	88	not configured
9	89	not configured
9	90	not configured
9	91	not configured
9	92	not configured
9	93	not configured
9	94	not configured
9	95	not configured
9	96	not configured
9	97	not configured
9	98	not configured
9	99	not configured
9	100	not configured
9	101	not configured
9	102	not configured
9	103	not configured
9	104	not configured
9	105	not configured
9	106	not configured
9	107	not configured
9	108	not configured
9	109	not configured
9	110	not configured
9	111	not configured
9	112	not configured
9	113	not configured
9	114	not configured
9	115	not configured
9	116	not configured
9	117	not configured
9	118	not configured
9	119	not configured
9	120	not configured
9	121	not configured
9	122	not configured
9	124	not configured
9	125	not configured
9	127	not configured
9	128	not configured
9	129	not configured
9	130	not configured
9	131	not configured
9	132	not configured
9	134	not configured
9	135	not configured
9	136	not configured
9	137	not configured
9	138	not configured
10	1	not configured
10	2	not configured
10	9	not configured
10	10	not configured
10	11	not configured
10	12	not configured
10	13	not configured
10	14	not configured
10	15	not configured
10	16	not configured
10	17	not configured
10	18	not configured
10	19	not configured
10	20	not configured
10	21	not configured
10	22	not configured
10	23	not configured
10	24	not configured
10	25	not configured
10	26	not configured
10	27	not configured
10	28	not configured
10	29	not configured
10	30	not configured
10	31	not configured
10	32	not configured
10	33	not configured
10	34	not configured
10	35	not configured
10	36	not configured
10	37	not configured
10	38	not configured
10	39	not configured
10	40	not configured
10	41	not configured
10	42	not configured
10	43	not configured
10	44	not configured
10	45	not configured
10	46	not configured
10	47	not configured
10	48	not configured
10	49	not configured
10	50	not configured
10	51	not configured
10	52	not configured
10	53	not configured
10	54	not configured
10	55	not configured
10	56	not configured
10	57	not configured
10	58	not configured
10	59	not configured
10	60	not configured
10	61	not configured
10	62	not configured
10	63	not configured
10	64	not configured
10	65	not configured
10	66	not configured
10	67	not configured
10	68	not configured
10	69	not configured
10	71	not configured
10	72	not configured
10	73	not configured
10	74	not configured
10	75	not configured
10	76	not configured
10	77	not configured
10	78	not configured
10	79	not configured
10	80	not configured
10	81	not configured
10	82	not configured
10	83	not configured
10	84	not configured
10	85	not configured
10	86	not configured
10	87	not configured
10	88	not configured
10	89	not configured
10	90	not configured
10	91	not configured
10	92	not configured
10	93	not configured
10	94	not configured
10	95	not configured
10	96	not configured
10	97	not configured
10	98	not configured
10	99	not configured
10	100	not configured
10	101	not configured
10	102	not configured
10	103	not configured
10	104	not configured
10	105	not configured
10	106	not configured
10	107	not configured
10	108	not configured
10	109	not configured
10	110	not configured
10	111	not configured
10	112	not configured
10	113	not configured
10	114	not configured
10	115	not configured
10	116	not configured
10	117	not configured
10	118	not configured
10	119	not configured
10	120	not configured
10	121	not configured
10	122	not configured
10	124	not configured
10	125	not configured
10	127	not configured
10	128	not configured
10	129	not configured
10	130	not configured
10	131	not configured
10	132	not configured
10	134	not configured
10	135	not configured
10	136	not configured
10	137	not configured
10	138	not configured
11	1	not configured
11	2	not configured
11	9	not configured
11	10	not configured
11	11	not configured
11	12	not configured
11	13	not configured
11	14	not configured
11	15	not configured
11	16	not configured
11	17	not configured
11	18	not configured
11	19	not configured
11	20	not configured
11	21	not configured
11	22	not configured
11	23	not configured
11	24	not configured
11	25	not configured
11	26	not configured
11	27	not configured
11	28	not configured
11	29	not configured
11	30	not configured
11	31	not configured
11	32	not configured
11	33	not configured
11	34	not configured
11	35	not configured
11	36	not configured
11	37	not configured
11	38	not configured
11	39	not configured
11	40	not configured
11	41	not configured
11	42	not configured
11	43	not configured
11	44	not configured
11	45	not configured
11	46	not configured
11	47	not configured
11	48	not configured
11	49	not configured
11	50	not configured
11	51	not configured
11	52	not configured
11	53	not configured
11	54	not configured
11	55	not configured
11	56	not configured
11	57	not configured
11	58	not configured
11	59	not configured
11	60	not configured
11	61	not configured
11	62	not configured
11	63	not configured
11	64	not configured
11	65	not configured
11	66	not configured
11	67	not configured
11	68	not configured
11	69	not configured
11	71	not configured
11	72	not configured
11	73	not configured
11	74	not configured
11	75	not configured
11	76	not configured
11	77	not configured
11	78	not configured
11	79	not configured
11	80	not configured
11	81	not configured
11	82	not configured
11	83	not configured
11	84	not configured
11	85	not configured
11	86	not configured
11	87	not configured
11	88	not configured
11	89	not configured
11	90	not configured
11	91	not configured
11	92	not configured
11	93	not configured
11	94	not configured
11	95	not configured
11	96	not configured
11	97	not configured
11	98	not configured
11	99	not configured
11	100	not configured
11	101	not configured
11	102	not configured
11	103	not configured
11	104	not configured
11	105	not configured
11	106	not configured
11	107	not configured
11	108	not configured
11	109	not configured
11	110	not configured
11	111	not configured
11	112	not configured
11	113	not configured
11	114	not configured
11	115	not configured
11	116	not configured
11	117	not configured
11	118	not configured
11	119	not configured
11	120	not configured
11	121	not configured
11	122	not configured
11	124	not configured
11	125	not configured
11	127	not configured
11	128	not configured
11	129	not configured
11	130	not configured
11	131	not configured
11	132	not configured
11	134	not configured
11	135	not configured
11	136	not configured
11	137	not configured
11	138	not configured
12	1	not configured
12	2	not configured
12	9	not configured
12	10	not configured
12	11	not configured
12	12	not configured
12	13	not configured
12	14	not configured
12	15	not configured
12	16	not configured
12	17	not configured
12	18	not configured
12	19	not configured
12	20	not configured
12	21	not configured
12	22	not configured
12	23	not configured
12	24	not configured
12	25	not configured
12	26	not configured
12	27	not configured
12	28	not configured
12	29	not configured
12	30	not configured
12	31	not configured
12	32	not configured
12	33	not configured
12	34	not configured
12	35	not configured
12	36	not configured
12	37	not configured
12	38	not configured
12	39	not configured
12	40	not configured
12	41	not configured
12	42	not configured
12	43	not configured
12	44	not configured
12	45	not configured
12	46	not configured
12	47	not configured
12	48	not configured
12	49	not configured
12	50	not configured
12	51	not configured
12	52	not configured
12	53	not configured
12	54	not configured
12	55	not configured
12	56	not configured
12	57	not configured
12	58	not configured
12	59	not configured
12	60	not configured
12	61	not configured
12	62	not configured
12	63	not configured
12	64	not configured
12	65	not configured
12	66	not configured
12	67	not configured
12	68	not configured
12	69	not configured
12	71	not configured
12	72	not configured
12	73	not configured
12	74	not configured
12	75	not configured
12	76	not configured
12	77	not configured
12	78	not configured
12	79	not configured
12	80	not configured
12	81	not configured
12	82	not configured
12	83	not configured
12	84	not configured
12	85	not configured
12	86	not configured
12	87	not configured
12	88	not configured
12	89	not configured
12	90	not configured
12	91	not configured
12	92	not configured
12	93	not configured
12	94	not configured
12	95	not configured
12	96	not configured
12	97	not configured
12	98	not configured
12	99	not configured
12	100	not configured
12	101	not configured
12	102	not configured
12	103	not configured
12	104	not configured
12	105	not configured
12	106	not configured
12	107	not configured
12	108	not configured
12	109	not configured
12	110	not configured
12	111	not configured
12	112	not configured
12	113	not configured
12	114	not configured
12	115	not configured
12	116	not configured
12	117	not configured
12	118	not configured
12	119	not configured
12	120	not configured
12	121	not configured
12	122	not configured
12	124	not configured
12	125	not configured
12	127	not configured
12	128	not configured
12	129	not configured
12	130	not configured
12	131	not configured
12	132	not configured
12	134	not configured
12	135	not configured
12	136	not configured
12	137	not configured
12	138	not configured
13	1	not configured
13	2	not configured
13	9	not configured
13	10	not configured
13	11	not configured
13	12	not configured
13	13	not configured
13	14	not configured
13	15	not configured
13	16	not configured
13	17	not configured
13	18	not configured
13	19	not configured
13	20	not configured
13	21	not configured
13	22	not configured
13	23	not configured
13	24	not configured
13	25	not configured
13	26	not configured
13	27	not configured
13	28	not configured
13	29	not configured
13	30	not configured
13	31	not configured
13	32	not configured
13	33	not configured
13	34	not configured
13	35	not configured
13	36	not configured
13	37	not configured
13	38	not configured
13	39	not configured
13	40	not configured
13	41	not configured
13	42	not configured
13	43	not configured
13	44	not configured
13	45	not configured
13	46	not configured
13	47	not configured
13	48	not configured
13	49	not configured
13	50	not configured
13	51	not configured
13	52	not configured
13	53	not configured
13	54	not configured
13	55	not configured
13	56	not configured
13	57	not configured
13	58	not configured
13	59	not configured
13	60	not configured
13	61	not configured
13	62	not configured
13	63	not configured
13	64	not configured
13	65	not configured
13	66	not configured
13	67	not configured
13	68	not configured
13	69	not configured
13	71	not configured
13	72	not configured
13	73	not configured
13	74	not configured
13	75	not configured
13	76	not configured
13	77	not configured
13	78	not configured
13	79	not configured
13	80	not configured
13	81	not configured
13	82	not configured
13	83	not configured
13	84	not configured
13	85	not configured
13	86	not configured
13	87	not configured
13	88	not configured
13	89	not configured
13	90	not configured
13	91	not configured
13	92	not configured
13	93	not configured
13	94	not configured
13	95	not configured
13	96	not configured
13	97	not configured
13	98	not configured
13	99	not configured
13	100	not configured
13	101	not configured
13	102	not configured
13	103	not configured
13	104	not configured
13	105	not configured
13	106	not configured
13	107	not configured
13	108	not configured
13	109	not configured
13	110	not configured
13	111	not configured
13	112	not configured
13	113	not configured
13	114	not configured
13	115	not configured
13	116	not configured
13	117	not configured
13	118	not configured
13	119	not configured
13	120	not configured
13	121	not configured
13	122	not configured
13	124	not configured
13	125	not configured
13	127	not configured
13	128	not configured
13	129	not configured
13	130	not configured
13	131	not configured
13	132	not configured
13	134	not configured
13	135	not configured
13	136	not configured
13	137	not configured
13	138	not configured
14	1	not configured
14	2	not configured
14	9	not configured
14	10	not configured
14	11	not configured
14	12	not configured
14	13	not configured
14	14	not configured
14	15	not configured
14	16	not configured
14	17	not configured
14	18	not configured
14	19	not configured
14	20	not configured
14	21	not configured
14	22	not configured
14	23	not configured
14	24	not configured
14	25	not configured
14	26	not configured
14	27	not configured
14	28	not configured
14	29	not configured
14	30	not configured
14	31	not configured
14	32	not configured
14	33	not configured
14	34	not configured
14	35	not configured
14	36	not configured
14	37	not configured
14	38	not configured
14	39	not configured
14	40	not configured
14	41	not configured
14	42	not configured
14	43	not configured
14	44	not configured
14	45	not configured
14	46	not configured
14	47	not configured
14	48	not configured
14	49	not configured
14	50	not configured
14	51	not configured
14	52	not configured
14	53	not configured
14	54	not configured
14	55	not configured
14	56	not configured
14	57	not configured
14	58	not configured
14	59	not configured
14	60	not configured
14	61	not configured
14	62	not configured
14	63	not configured
14	64	not configured
14	65	not configured
14	66	not configured
14	67	not configured
14	68	not configured
14	69	not configured
14	71	not configured
14	72	not configured
14	73	not configured
14	74	not configured
14	75	not configured
14	76	not configured
14	77	not configured
14	78	not configured
14	79	not configured
14	80	not configured
14	81	not configured
14	82	not configured
14	83	not configured
14	84	not configured
14	85	not configured
14	86	not configured
14	87	not configured
14	88	not configured
14	89	not configured
14	90	not configured
14	91	not configured
14	92	not configured
14	93	not configured
14	94	not configured
14	95	not configured
14	96	not configured
14	97	not configured
14	98	not configured
14	99	not configured
14	100	not configured
14	101	not configured
14	102	not configured
14	103	not configured
14	104	not configured
14	105	not configured
14	106	not configured
14	107	not configured
14	108	not configured
14	109	not configured
14	110	not configured
14	111	not configured
14	112	not configured
14	113	not configured
14	114	not configured
14	115	not configured
14	116	not configured
14	117	not configured
14	118	not configured
14	119	not configured
14	120	not configured
14	121	not configured
14	122	not configured
14	124	not configured
14	125	not configured
14	127	not configured
14	128	not configured
14	129	not configured
14	130	not configured
14	131	not configured
14	132	not configured
14	134	not configured
14	135	not configured
14	136	not configured
14	137	not configured
14	138	not configured
15	1	not configured
15	2	not configured
15	9	not configured
15	10	not configured
15	11	not configured
15	12	not configured
15	13	not configured
15	14	not configured
15	15	not configured
15	16	not configured
15	17	not configured
15	18	not configured
15	19	not configured
15	20	not configured
15	21	not configured
15	22	not configured
15	23	not configured
15	24	not configured
15	25	not configured
15	26	not configured
15	27	not configured
15	28	not configured
15	29	not configured
15	30	not configured
15	31	not configured
15	32	not configured
15	33	not configured
15	34	not configured
15	35	not configured
15	36	not configured
15	37	not configured
15	38	not configured
15	39	not configured
15	40	not configured
15	41	not configured
15	42	not configured
15	43	not configured
15	44	not configured
15	45	not configured
15	46	not configured
15	47	not configured
15	48	not configured
15	49	not configured
15	50	not configured
15	51	not configured
15	52	not configured
15	53	not configured
15	54	not configured
15	55	not configured
15	56	not configured
15	57	not configured
15	58	not configured
15	59	not configured
15	60	not configured
15	61	not configured
15	62	not configured
15	63	not configured
15	64	not configured
15	65	not configured
15	66	not configured
15	67	not configured
15	68	not configured
15	69	not configured
15	71	not configured
15	72	not configured
15	73	not configured
15	74	not configured
15	75	not configured
15	76	not configured
15	77	not configured
15	78	not configured
15	79	not configured
15	80	not configured
15	81	not configured
15	82	not configured
15	83	not configured
15	84	not configured
15	85	not configured
15	86	not configured
15	87	not configured
15	88	not configured
15	89	not configured
15	90	not configured
15	91	not configured
15	92	not configured
15	93	not configured
15	94	not configured
15	95	not configured
15	96	not configured
15	97	not configured
15	98	not configured
15	99	not configured
15	100	not configured
15	101	not configured
15	102	not configured
15	103	not configured
15	104	not configured
15	105	not configured
15	106	not configured
15	107	not configured
15	108	not configured
15	109	not configured
15	110	not configured
15	111	not configured
15	112	not configured
15	113	not configured
15	114	not configured
15	115	not configured
15	116	not configured
15	117	not configured
15	118	not configured
15	119	not configured
15	120	not configured
15	121	not configured
15	122	not configured
15	124	not configured
15	125	not configured
15	127	not configured
15	128	not configured
15	129	not configured
15	130	not configured
15	131	not configured
15	132	not configured
15	134	not configured
15	135	not configured
15	136	not configured
15	137	not configured
15	138	not configured
16	1	not configured
16	2	not configured
16	9	not configured
16	10	not configured
16	11	not configured
16	12	not configured
16	13	not configured
16	14	not configured
16	15	not configured
16	16	not configured
16	17	not configured
16	18	not configured
16	19	not configured
16	20	not configured
16	21	not configured
16	22	not configured
16	23	not configured
16	24	not configured
16	25	not configured
16	26	not configured
16	27	not configured
16	28	not configured
16	29	not configured
16	30	not configured
16	31	not configured
16	32	not configured
16	33	not configured
16	34	not configured
16	35	not configured
16	36	not configured
16	37	not configured
16	38	not configured
16	39	not configured
16	40	not configured
16	41	not configured
16	42	not configured
16	43	not configured
16	44	not configured
16	45	not configured
16	46	not configured
16	47	not configured
16	48	not configured
16	49	not configured
16	50	not configured
16	51	not configured
16	52	not configured
16	53	not configured
16	54	not configured
16	55	not configured
16	56	not configured
16	57	not configured
16	58	not configured
16	59	not configured
16	60	not configured
16	61	not configured
16	62	not configured
16	63	not configured
16	64	not configured
16	65	not configured
16	66	not configured
16	67	not configured
16	68	not configured
16	69	not configured
16	71	not configured
16	72	not configured
16	73	not configured
16	74	not configured
16	75	not configured
16	76	not configured
16	77	not configured
16	78	not configured
16	79	not configured
16	80	not configured
16	81	not configured
16	82	not configured
16	83	not configured
16	84	not configured
16	85	not configured
16	86	not configured
16	87	not configured
16	88	not configured
16	89	not configured
16	90	not configured
16	91	not configured
16	92	not configured
16	93	not configured
16	94	not configured
16	95	not configured
16	96	not configured
16	97	not configured
16	98	not configured
16	99	not configured
16	100	not configured
16	101	not configured
16	102	not configured
16	103	not configured
16	104	not configured
16	105	not configured
16	106	not configured
16	107	not configured
16	108	not configured
16	109	not configured
16	110	not configured
16	111	not configured
16	112	not configured
16	113	not configured
16	114	not configured
16	115	not configured
16	116	not configured
16	117	not configured
16	118	not configured
16	119	not configured
16	120	not configured
16	121	not configured
16	122	not configured
16	124	not configured
16	125	not configured
16	127	not configured
16	128	not configured
16	129	not configured
16	130	not configured
16	131	not configured
16	132	not configured
16	134	not configured
16	135	not configured
16	136	not configured
16	137	not configured
16	138	not configured
17	1	not configured
17	2	not configured
17	9	not configured
17	10	not configured
17	11	not configured
17	12	not configured
17	13	not configured
17	14	not configured
17	15	not configured
17	16	not configured
17	17	not configured
17	18	not configured
17	19	not configured
17	20	not configured
17	21	not configured
17	22	not configured
17	23	not configured
17	24	not configured
17	25	not configured
17	26	not configured
17	27	not configured
17	28	not configured
17	29	not configured
17	30	not configured
17	31	not configured
17	32	not configured
17	33	not configured
17	34	not configured
17	35	not configured
17	36	not configured
17	37	not configured
17	38	not configured
17	39	not configured
17	40	not configured
17	41	not configured
17	42	not configured
17	43	not configured
17	44	not configured
17	45	not configured
17	46	not configured
17	47	not configured
17	48	not configured
17	49	not configured
17	50	not configured
17	51	not configured
17	52	not configured
17	53	not configured
17	54	not configured
17	55	not configured
17	56	not configured
17	57	not configured
17	58	not configured
17	59	not configured
17	60	not configured
17	61	not configured
17	62	not configured
17	63	not configured
17	64	not configured
17	65	not configured
17	66	not configured
17	67	not configured
17	68	not configured
17	69	not configured
17	71	not configured
17	72	not configured
17	73	not configured
17	74	not configured
17	75	not configured
17	76	not configured
17	77	not configured
17	78	not configured
17	79	not configured
17	80	not configured
17	81	not configured
17	82	not configured
17	83	not configured
17	84	not configured
17	85	not configured
17	86	not configured
17	87	not configured
17	88	not configured
17	89	not configured
17	90	not configured
17	91	not configured
17	92	not configured
17	93	not configured
17	94	not configured
17	95	not configured
17	96	not configured
17	97	not configured
17	98	not configured
17	99	not configured
17	100	not configured
17	101	not configured
17	102	not configured
17	103	not configured
17	104	not configured
17	105	not configured
17	106	not configured
17	107	not configured
17	108	not configured
17	109	not configured
17	110	not configured
17	111	not configured
17	112	not configured
17	113	not configured
17	114	not configured
17	115	not configured
17	116	not configured
17	117	not configured
17	118	not configured
17	119	not configured
17	120	not configured
17	121	not configured
17	122	not configured
17	124	not configured
17	125	not configured
17	127	not configured
17	128	not configured
17	129	not configured
17	130	not configured
17	131	not configured
17	132	not configured
17	134	not configured
17	135	not configured
17	136	not configured
17	137	not configured
17	138	not configured
18	1	not configured
18	2	not configured
18	9	not configured
18	10	not configured
18	11	not configured
18	12	not configured
18	13	not configured
18	14	not configured
18	15	not configured
18	16	not configured
18	17	not configured
18	18	not configured
18	19	not configured
18	20	not configured
18	21	not configured
18	22	not configured
18	23	not configured
18	24	not configured
18	25	not configured
18	26	not configured
18	27	not configured
18	28	not configured
18	29	not configured
18	30	not configured
18	31	not configured
18	32	not configured
18	33	not configured
18	34	not configured
18	35	not configured
18	36	not configured
18	37	not configured
18	38	not configured
18	39	not configured
18	40	not configured
18	41	not configured
18	42	not configured
18	43	not configured
18	44	not configured
18	45	not configured
18	46	not configured
18	47	not configured
18	48	not configured
18	49	not configured
18	50	not configured
18	51	not configured
18	52	not configured
18	53	not configured
18	54	not configured
18	55	not configured
18	56	not configured
18	57	not configured
18	58	not configured
18	59	not configured
18	60	not configured
18	61	not configured
18	62	not configured
18	63	not configured
18	64	not configured
18	65	not configured
18	66	not configured
18	67	not configured
18	68	not configured
18	69	not configured
18	71	not configured
18	72	not configured
18	73	not configured
18	74	not configured
18	75	not configured
18	76	not configured
18	77	not configured
18	78	not configured
18	79	not configured
18	80	not configured
18	81	not configured
18	82	not configured
18	83	not configured
18	84	not configured
18	85	not configured
18	86	not configured
18	87	not configured
18	88	not configured
18	89	not configured
18	90	not configured
18	91	not configured
18	92	not configured
18	93	not configured
18	94	not configured
18	95	not configured
18	96	not configured
18	97	not configured
18	98	not configured
18	99	not configured
18	100	not configured
18	101	not configured
18	102	not configured
18	103	not configured
18	104	not configured
18	105	not configured
18	106	not configured
18	107	not configured
18	108	not configured
18	109	not configured
18	110	not configured
18	111	not configured
18	112	not configured
18	113	not configured
18	114	not configured
18	115	not configured
18	116	not configured
18	117	not configured
18	118	not configured
18	119	not configured
18	120	not configured
18	121	not configured
18	122	not configured
18	124	not configured
18	125	not configured
18	127	not configured
18	128	not configured
18	129	not configured
18	130	not configured
18	131	not configured
18	132	not configured
18	134	not configured
18	135	not configured
18	136	not configured
18	137	not configured
18	138	not configured
19	1	not configured
19	2	not configured
19	9	not configured
19	10	not configured
19	11	not configured
19	12	not configured
19	13	not configured
19	14	not configured
19	15	not configured
19	16	not configured
19	17	not configured
19	18	not configured
19	19	not configured
19	20	not configured
19	21	not configured
19	22	not configured
19	23	not configured
19	24	not configured
19	25	not configured
19	26	not configured
19	27	not configured
19	28	not configured
19	29	not configured
19	30	not configured
19	31	not configured
19	32	not configured
19	33	not configured
19	34	not configured
19	35	not configured
19	36	not configured
19	37	not configured
19	38	not configured
19	39	not configured
19	40	not configured
19	41	not configured
19	42	not configured
19	43	not configured
19	44	not configured
19	45	not configured
19	46	not configured
19	47	not configured
19	48	not configured
19	49	not configured
19	50	not configured
19	51	not configured
19	52	not configured
19	53	not configured
19	54	not configured
19	55	not configured
19	56	not configured
19	57	not configured
19	58	not configured
19	59	not configured
19	60	not configured
19	61	not configured
19	62	not configured
19	63	not configured
19	64	not configured
19	65	not configured
19	66	not configured
19	67	not configured
19	68	not configured
19	69	not configured
19	71	not configured
19	72	not configured
19	73	not configured
19	74	not configured
19	75	not configured
19	76	not configured
19	77	not configured
19	78	not configured
19	79	not configured
19	80	not configured
19	81	not configured
19	82	not configured
19	83	not configured
19	84	not configured
19	85	not configured
19	86	not configured
19	87	not configured
19	88	not configured
19	89	not configured
19	90	not configured
19	91	not configured
19	92	not configured
19	93	not configured
19	94	not configured
19	95	not configured
19	96	not configured
19	97	not configured
19	98	not configured
19	99	not configured
19	100	not configured
19	101	not configured
19	102	not configured
19	103	not configured
19	104	not configured
19	105	not configured
19	106	not configured
19	107	not configured
19	108	not configured
19	109	not configured
19	110	not configured
19	111	not configured
19	112	not configured
19	113	not configured
19	114	not configured
19	115	not configured
19	116	not configured
19	117	not configured
19	118	not configured
19	119	not configured
19	120	not configured
19	121	not configured
19	122	not configured
19	124	not configured
19	125	not configured
19	127	not configured
19	128	not configured
19	129	not configured
19	130	not configured
19	131	not configured
19	132	not configured
19	134	not configured
19	135	not configured
19	136	not configured
19	137	not configured
19	138	not configured
20	1	not configured
20	2	not configured
20	9	not configured
20	10	not configured
20	11	not configured
20	12	not configured
20	13	not configured
20	14	not configured
20	15	not configured
20	16	not configured
20	17	not configured
20	18	not configured
20	19	not configured
20	20	not configured
20	21	not configured
20	22	not configured
20	23	not configured
20	24	not configured
20	25	not configured
20	26	not configured
20	27	not configured
20	28	not configured
20	29	not configured
20	30	not configured
20	31	not configured
20	32	not configured
20	33	not configured
20	34	not configured
20	35	not configured
20	36	not configured
20	37	not configured
20	38	not configured
20	39	not configured
20	40	not configured
20	41	not configured
20	42	not configured
20	43	not configured
20	44	not configured
20	45	not configured
20	46	not configured
20	47	not configured
20	48	not configured
20	49	not configured
20	50	not configured
20	51	not configured
20	52	not configured
20	53	not configured
20	54	not configured
20	55	not configured
20	56	not configured
20	57	not configured
20	58	not configured
20	59	not configured
20	60	not configured
20	61	not configured
20	62	not configured
20	63	not configured
20	64	not configured
20	65	not configured
20	66	not configured
20	67	not configured
20	68	not configured
20	69	not configured
20	71	not configured
20	72	not configured
20	73	not configured
20	74	not configured
20	75	not configured
20	76	not configured
20	77	not configured
20	78	not configured
20	79	not configured
20	80	not configured
20	81	not configured
20	82	not configured
20	83	not configured
20	84	not configured
20	85	not configured
20	86	not configured
20	87	not configured
20	88	not configured
20	89	not configured
20	90	not configured
20	91	not configured
20	92	not configured
20	93	not configured
20	94	not configured
20	95	not configured
20	96	not configured
20	97	not configured
20	98	not configured
20	99	not configured
20	100	not configured
20	101	not configured
20	102	not configured
20	103	not configured
20	104	not configured
20	105	not configured
20	106	not configured
20	107	not configured
20	108	not configured
20	109	not configured
20	110	not configured
20	111	not configured
20	112	not configured
20	113	not configured
20	114	not configured
20	115	not configured
20	116	not configured
20	117	not configured
20	118	not configured
20	119	not configured
20	120	not configured
20	121	not configured
20	122	not configured
20	124	not configured
20	125	not configured
20	127	not configured
20	128	not configured
20	129	not configured
20	130	not configured
20	131	not configured
20	132	not configured
20	134	not configured
20	135	not configured
20	136	not configured
20	137	not configured
20	138	not configured
21	1	not configured
21	2	not configured
21	9	not configured
21	10	not configured
21	11	not configured
21	12	not configured
21	13	not configured
21	14	not configured
21	15	not configured
21	16	not configured
21	17	not configured
21	18	not configured
21	19	not configured
21	20	not configured
21	21	not configured
21	22	not configured
21	23	not configured
21	24	not configured
21	25	not configured
21	26	not configured
21	27	not configured
21	28	not configured
21	29	not configured
21	30	not configured
21	31	not configured
21	32	not configured
21	33	not configured
21	34	not configured
21	35	not configured
21	36	not configured
21	37	not configured
21	38	not configured
21	39	not configured
21	40	not configured
21	41	not configured
21	42	not configured
21	43	not configured
21	44	not configured
21	45	not configured
21	46	not configured
21	47	not configured
21	48	not configured
21	49	not configured
21	50	not configured
21	51	not configured
21	52	not configured
21	53	not configured
21	54	not configured
21	55	not configured
21	56	not configured
21	57	not configured
21	58	not configured
21	59	not configured
21	60	not configured
21	61	not configured
21	62	not configured
21	63	not configured
21	64	not configured
21	65	not configured
21	66	not configured
21	67	not configured
21	68	not configured
21	69	not configured
21	71	not configured
21	72	not configured
21	73	not configured
21	74	not configured
21	75	not configured
21	76	not configured
21	77	not configured
21	78	not configured
21	79	not configured
21	80	not configured
21	81	not configured
21	82	not configured
21	83	not configured
21	84	not configured
21	85	not configured
21	86	not configured
21	87	not configured
21	88	not configured
21	89	not configured
21	90	not configured
21	91	not configured
21	92	not configured
21	93	not configured
21	94	not configured
21	95	not configured
21	96	not configured
21	97	not configured
21	98	not configured
21	99	not configured
21	100	not configured
21	101	not configured
21	102	not configured
21	103	not configured
21	104	not configured
21	105	not configured
21	106	not configured
21	107	not configured
21	108	not configured
21	109	not configured
21	110	not configured
21	111	not configured
21	112	not configured
21	113	not configured
21	114	not configured
21	115	not configured
21	116	not configured
21	117	not configured
21	118	not configured
21	119	not configured
21	120	not configured
21	121	not configured
21	122	not configured
21	124	not configured
21	125	not configured
21	127	not configured
21	128	not configured
21	129	not configured
21	130	not configured
21	131	not configured
21	132	not configured
21	134	not configured
21	135	not configured
21	136	not configured
21	137	not configured
21	138	not configured
22	1	not configured
22	2	not configured
22	9	not configured
22	10	not configured
22	11	not configured
22	12	not configured
22	13	not configured
22	14	not configured
22	15	not configured
22	16	not configured
22	17	not configured
22	18	not configured
22	19	not configured
22	20	not configured
22	21	not configured
22	22	not configured
22	23	not configured
22	24	not configured
22	25	not configured
22	26	not configured
22	27	not configured
22	28	not configured
22	29	not configured
22	30	not configured
22	31	not configured
22	32	not configured
22	33	not configured
22	34	not configured
22	35	not configured
22	36	not configured
22	37	not configured
22	38	not configured
22	39	not configured
22	40	not configured
22	41	not configured
22	42	not configured
22	43	not configured
22	44	not configured
22	45	not configured
22	46	not configured
22	47	not configured
22	48	not configured
22	49	not configured
22	50	not configured
22	51	not configured
22	52	not configured
22	53	not configured
22	54	not configured
22	55	not configured
22	56	not configured
22	57	not configured
22	58	not configured
22	59	not configured
22	60	not configured
22	61	not configured
22	62	not configured
22	63	not configured
22	64	not configured
22	65	not configured
22	66	not configured
22	67	not configured
22	68	not configured
22	69	not configured
22	71	not configured
22	72	not configured
22	73	not configured
22	74	not configured
22	75	not configured
22	76	not configured
22	77	not configured
22	78	not configured
22	79	not configured
22	80	not configured
22	81	not configured
22	82	not configured
22	83	not configured
22	84	not configured
22	85	not configured
22	86	not configured
22	87	not configured
22	88	not configured
22	89	not configured
22	90	not configured
22	91	not configured
22	92	not configured
22	93	not configured
22	94	not configured
22	95	not configured
22	96	not configured
22	97	not configured
22	98	not configured
22	99	not configured
22	100	not configured
22	101	not configured
22	102	not configured
22	103	not configured
22	104	not configured
22	105	not configured
22	106	not configured
22	107	not configured
22	108	not configured
22	109	not configured
22	110	not configured
22	111	not configured
22	112	not configured
22	113	not configured
22	114	not configured
22	115	not configured
22	116	not configured
22	117	not configured
22	118	not configured
22	119	not configured
22	120	not configured
22	121	not configured
22	122	not configured
22	124	not configured
22	125	not configured
22	127	not configured
22	128	not configured
22	129	not configured
22	130	not configured
22	131	not configured
22	132	not configured
22	134	not configured
22	135	not configured
22	136	not configured
22	137	not configured
22	138	not configured
23	1	not configured
23	2	not configured
23	9	not configured
23	10	not configured
23	11	not configured
23	12	not configured
23	13	not configured
23	14	not configured
23	15	not configured
23	16	not configured
23	17	not configured
23	18	not configured
23	19	not configured
23	20	not configured
23	21	not configured
23	22	not configured
23	23	not configured
23	24	not configured
23	25	not configured
23	26	not configured
23	27	not configured
23	28	not configured
23	29	not configured
23	30	not configured
23	31	not configured
23	32	not configured
23	33	not configured
23	34	not configured
23	35	not configured
23	36	not configured
23	37	not configured
23	38	not configured
23	39	not configured
23	40	not configured
23	41	not configured
23	42	not configured
23	43	not configured
23	44	not configured
23	45	not configured
23	46	not configured
23	47	not configured
23	48	not configured
23	49	not configured
23	50	not configured
23	51	not configured
23	52	not configured
23	53	not configured
23	54	not configured
23	55	not configured
23	56	not configured
23	57	not configured
23	58	not configured
23	59	not configured
23	60	not configured
23	61	not configured
23	62	not configured
23	63	not configured
23	64	not configured
23	65	not configured
23	66	not configured
23	67	not configured
23	68	not configured
23	69	not configured
23	71	not configured
23	72	not configured
23	73	not configured
23	74	not configured
23	75	not configured
23	76	not configured
23	77	not configured
23	78	not configured
23	79	not configured
23	80	not configured
23	81	not configured
23	82	not configured
23	83	not configured
23	84	not configured
23	85	not configured
23	86	not configured
23	87	not configured
23	88	not configured
23	89	not configured
23	90	not configured
23	91	not configured
23	92	not configured
23	93	not configured
23	94	not configured
23	95	not configured
23	96	not configured
23	97	not configured
23	98	not configured
23	99	not configured
23	100	not configured
23	101	not configured
23	102	not configured
23	103	not configured
23	104	not configured
23	105	not configured
23	106	not configured
23	107	not configured
23	108	not configured
23	109	not configured
23	110	not configured
23	111	not configured
23	112	not configured
23	113	not configured
23	114	not configured
23	115	not configured
23	116	not configured
23	117	not configured
23	118	not configured
23	119	not configured
23	120	not configured
23	121	not configured
23	122	not configured
23	124	not configured
23	125	not configured
23	127	not configured
23	128	not configured
23	129	not configured
23	130	not configured
23	131	not configured
23	132	not configured
23	134	not configured
23	135	not configured
23	136	not configured
23	137	not configured
23	138	not configured
24	1	not configured
24	2	not configured
24	9	not configured
24	10	not configured
24	11	not configured
24	12	not configured
24	13	not configured
24	14	not configured
24	15	not configured
24	16	not configured
24	17	not configured
24	18	not configured
24	19	not configured
24	20	not configured
24	21	not configured
24	22	not configured
24	23	not configured
24	24	not configured
24	25	not configured
24	26	not configured
24	27	not configured
24	28	not configured
24	29	not configured
24	30	not configured
24	31	not configured
24	32	not configured
24	33	not configured
24	34	not configured
24	35	not configured
24	36	not configured
24	37	not configured
24	38	not configured
24	39	not configured
24	40	not configured
24	41	not configured
24	42	not configured
24	43	not configured
24	44	not configured
24	45	not configured
24	46	not configured
24	47	not configured
24	48	not configured
24	49	not configured
24	50	not configured
24	51	not configured
24	52	not configured
24	53	not configured
24	54	not configured
24	55	not configured
24	56	not configured
24	57	not configured
24	58	not configured
24	59	not configured
24	60	not configured
24	61	not configured
24	62	not configured
24	63	not configured
24	64	not configured
24	65	not configured
24	66	not configured
24	67	not configured
24	68	not configured
24	69	not configured
24	71	not configured
24	72	not configured
24	73	not configured
24	74	not configured
24	75	not configured
24	76	not configured
24	77	not configured
24	78	not configured
24	79	not configured
24	80	not configured
24	81	not configured
24	82	not configured
24	83	not configured
24	84	not configured
24	85	not configured
24	86	not configured
24	87	not configured
24	88	not configured
24	89	not configured
24	90	not configured
24	91	not configured
24	92	not configured
24	93	not configured
24	94	not configured
24	95	not configured
24	96	not configured
24	97	not configured
24	98	not configured
24	99	not configured
24	100	not configured
24	101	not configured
24	102	not configured
24	103	not configured
24	104	not configured
24	105	not configured
24	106	not configured
24	107	not configured
24	108	not configured
24	109	not configured
24	110	not configured
24	111	not configured
24	112	not configured
24	113	not configured
24	114	not configured
24	115	not configured
24	116	not configured
24	117	not configured
24	118	not configured
24	119	not configured
24	120	not configured
24	121	not configured
24	122	not configured
24	124	not configured
24	125	not configured
24	127	not configured
24	128	not configured
24	129	not configured
24	130	not configured
24	131	not configured
24	132	not configured
24	134	not configured
24	135	not configured
24	136	not configured
24	137	not configured
24	138	not configured
25	1	not configured
25	2	not configured
25	9	not configured
25	10	not configured
25	11	not configured
25	12	not configured
25	13	not configured
25	14	not configured
25	15	not configured
25	16	not configured
25	17	not configured
25	18	not configured
25	19	not configured
25	20	not configured
25	21	not configured
25	22	not configured
25	23	not configured
25	24	not configured
25	25	not configured
25	26	not configured
25	27	not configured
25	28	not configured
25	29	not configured
25	30	not configured
25	31	not configured
25	32	not configured
25	33	not configured
25	34	not configured
25	35	not configured
25	36	not configured
25	37	not configured
25	38	not configured
25	39	not configured
25	40	not configured
25	41	not configured
25	42	not configured
25	43	not configured
25	44	not configured
25	45	not configured
25	46	not configured
25	47	not configured
25	48	not configured
25	49	not configured
25	50	not configured
25	51	not configured
25	52	not configured
25	53	not configured
25	54	not configured
25	55	not configured
25	56	not configured
25	57	not configured
25	58	not configured
25	59	not configured
25	60	not configured
25	61	not configured
25	62	not configured
25	63	not configured
25	64	not configured
25	65	not configured
25	66	not configured
25	67	not configured
25	68	not configured
25	69	not configured
25	71	not configured
25	72	not configured
25	73	not configured
25	74	not configured
25	75	not configured
25	76	not configured
25	77	not configured
25	78	not configured
25	79	not configured
25	80	not configured
25	81	not configured
25	82	not configured
25	83	not configured
25	84	not configured
25	85	not configured
25	86	not configured
25	87	not configured
25	88	not configured
25	89	not configured
25	90	not configured
25	91	not configured
25	92	not configured
25	93	not configured
25	94	not configured
25	95	not configured
25	96	not configured
25	97	not configured
25	98	not configured
25	99	not configured
25	100	not configured
25	101	not configured
25	102	not configured
25	103	not configured
25	104	not configured
25	105	not configured
25	106	not configured
25	107	not configured
25	108	not configured
25	109	not configured
25	110	not configured
25	111	not configured
25	112	not configured
25	113	not configured
25	114	not configured
25	115	not configured
25	116	not configured
25	117	not configured
25	118	not configured
25	119	not configured
25	120	not configured
25	121	not configured
25	122	not configured
25	124	not configured
25	125	not configured
25	127	not configured
25	128	not configured
25	129	not configured
25	130	not configured
25	131	not configured
25	132	not configured
25	134	not configured
25	135	not configured
25	136	not configured
25	137	not configured
25	138	not configured
26	1	not configured
26	2	not configured
26	9	not configured
26	10	not configured
26	11	not configured
26	12	not configured
26	13	not configured
26	14	not configured
26	15	not configured
26	16	not configured
26	17	not configured
26	18	not configured
26	19	not configured
26	20	not configured
26	21	not configured
26	22	not configured
26	23	not configured
26	24	not configured
26	25	not configured
26	26	not configured
26	27	not configured
26	28	not configured
26	29	not configured
26	30	not configured
26	31	not configured
26	32	not configured
26	33	not configured
26	34	not configured
26	35	not configured
26	36	not configured
26	37	not configured
26	38	not configured
26	39	not configured
26	40	not configured
26	41	not configured
26	42	not configured
26	43	not configured
26	44	not configured
26	45	not configured
26	46	not configured
26	47	not configured
26	48	not configured
26	49	not configured
26	50	not configured
26	51	not configured
26	52	not configured
26	53	not configured
26	54	not configured
26	55	not configured
26	56	not configured
26	57	not configured
26	58	not configured
26	59	not configured
26	60	not configured
26	61	not configured
26	62	not configured
26	63	not configured
26	64	not configured
26	65	not configured
26	66	not configured
26	67	not configured
26	68	not configured
26	69	not configured
26	71	not configured
26	72	not configured
26	73	not configured
26	74	not configured
26	75	not configured
26	76	not configured
26	77	not configured
26	78	not configured
26	79	not configured
26	80	not configured
26	81	not configured
26	82	not configured
26	83	not configured
26	84	not configured
26	85	not configured
26	86	not configured
26	87	not configured
26	88	not configured
26	89	not configured
26	90	not configured
26	91	not configured
26	92	not configured
26	93	not configured
26	94	not configured
26	95	not configured
26	96	not configured
26	97	not configured
26	98	not configured
26	99	not configured
26	100	not configured
26	101	not configured
26	102	not configured
26	103	not configured
26	104	not configured
26	105	not configured
26	106	not configured
26	107	not configured
26	108	not configured
26	109	not configured
26	110	not configured
26	111	not configured
26	112	not configured
26	113	not configured
26	114	not configured
26	115	not configured
26	116	not configured
26	117	not configured
26	118	not configured
26	119	not configured
26	120	not configured
26	121	not configured
26	122	not configured
26	124	not configured
26	125	not configured
26	127	not configured
26	128	not configured
26	129	not configured
26	130	not configured
26	131	not configured
26	132	not configured
26	134	not configured
26	135	not configured
26	136	not configured
26	137	not configured
26	138	not configured
27	1	not configured
27	2	not configured
27	9	not configured
27	10	not configured
27	11	not configured
27	12	not configured
27	13	not configured
27	14	not configured
27	15	not configured
27	16	not configured
27	17	not configured
27	18	not configured
27	19	not configured
27	20	not configured
27	21	not configured
27	22	not configured
27	23	not configured
27	24	not configured
27	25	not configured
27	26	not configured
27	27	not configured
27	28	not configured
27	29	not configured
27	30	not configured
27	31	not configured
27	32	not configured
27	33	not configured
27	34	not configured
27	35	not configured
27	36	not configured
27	37	not configured
27	38	not configured
27	39	not configured
27	40	not configured
27	41	not configured
27	42	not configured
27	43	not configured
27	44	not configured
27	45	not configured
27	46	not configured
27	47	not configured
27	48	not configured
27	49	not configured
27	50	not configured
27	51	not configured
27	52	not configured
27	53	not configured
27	54	not configured
27	55	not configured
27	56	not configured
27	57	not configured
27	58	not configured
27	59	not configured
27	60	not configured
27	61	not configured
27	62	not configured
27	63	not configured
27	64	not configured
27	65	not configured
27	66	not configured
27	67	not configured
27	68	not configured
27	69	not configured
27	71	not configured
27	72	not configured
27	73	not configured
27	74	not configured
27	75	not configured
27	76	not configured
27	77	not configured
27	78	not configured
27	79	not configured
27	80	not configured
27	81	not configured
27	82	not configured
27	83	not configured
27	84	not configured
27	85	not configured
27	86	not configured
27	87	not configured
27	88	not configured
27	89	not configured
27	90	not configured
27	91	not configured
27	92	not configured
27	93	not configured
27	94	not configured
27	95	not configured
27	96	not configured
27	97	not configured
27	98	not configured
27	99	not configured
27	100	not configured
27	101	not configured
27	102	not configured
27	103	not configured
27	104	not configured
27	105	not configured
27	106	not configured
27	107	not configured
27	108	not configured
27	109	not configured
27	110	not configured
27	111	not configured
27	112	not configured
27	113	not configured
27	114	not configured
27	115	not configured
27	116	not configured
27	117	not configured
27	118	not configured
27	119	not configured
27	120	not configured
27	121	not configured
27	122	not configured
27	124	not configured
27	125	not configured
27	127	not configured
27	128	not configured
27	129	not configured
27	130	not configured
27	131	not configured
27	132	not configured
27	134	not configured
27	135	not configured
27	136	not configured
27	137	not configured
27	138	not configured
28	1	not configured
28	2	not configured
28	9	not configured
28	10	not configured
28	11	not configured
28	12	not configured
28	13	not configured
28	14	not configured
28	15	not configured
28	16	not configured
28	17	not configured
28	18	not configured
28	19	not configured
28	20	not configured
28	21	not configured
28	22	not configured
28	23	not configured
28	24	not configured
28	25	not configured
28	26	not configured
28	27	not configured
28	28	not configured
28	29	not configured
28	30	not configured
28	31	not configured
28	32	not configured
28	33	not configured
28	34	not configured
28	35	not configured
28	36	not configured
28	37	not configured
28	38	not configured
28	39	not configured
28	40	not configured
28	41	not configured
28	42	not configured
28	43	not configured
28	44	not configured
28	45	not configured
28	46	not configured
28	47	not configured
28	48	not configured
28	49	not configured
28	50	not configured
28	51	not configured
28	52	not configured
28	53	not configured
28	54	not configured
28	55	not configured
28	56	not configured
28	57	not configured
28	58	not configured
28	59	not configured
28	60	not configured
28	61	not configured
28	62	not configured
28	63	not configured
28	64	not configured
28	65	not configured
28	66	not configured
28	67	not configured
28	68	not configured
28	69	not configured
28	71	not configured
28	72	not configured
28	73	not configured
28	74	not configured
28	75	not configured
28	76	not configured
28	77	not configured
28	78	not configured
28	79	not configured
28	80	not configured
28	81	not configured
28	82	not configured
28	83	not configured
28	84	not configured
28	85	not configured
28	86	not configured
28	87	not configured
28	88	not configured
28	89	not configured
28	90	not configured
28	91	not configured
28	92	not configured
28	93	not configured
28	94	not configured
28	95	not configured
28	96	not configured
28	97	not configured
28	98	not configured
28	99	not configured
28	100	not configured
28	101	not configured
28	102	not configured
28	103	not configured
28	104	not configured
28	105	not configured
28	106	not configured
28	107	not configured
28	108	not configured
28	109	not configured
28	110	not configured
28	111	not configured
28	112	not configured
28	113	not configured
28	114	not configured
28	115	not configured
28	116	not configured
28	117	not configured
28	118	not configured
28	119	not configured
28	120	not configured
28	121	not configured
28	122	not configured
28	124	not configured
28	125	not configured
28	127	not configured
28	128	not configured
28	129	not configured
28	130	not configured
28	131	not configured
28	132	not configured
28	134	not configured
28	135	not configured
28	136	not configured
28	137	not configured
28	138	not configured
29	1	not configured
29	2	not configured
29	9	not configured
29	10	not configured
29	11	not configured
29	12	not configured
29	13	not configured
29	14	not configured
29	15	not configured
29	16	not configured
29	17	not configured
29	18	not configured
29	19	not configured
29	20	not configured
29	21	not configured
29	22	not configured
29	23	not configured
29	24	not configured
29	25	not configured
29	26	not configured
29	27	not configured
29	28	not configured
29	29	not configured
29	30	not configured
29	31	not configured
29	32	not configured
29	33	not configured
29	34	not configured
29	35	not configured
29	36	not configured
29	37	not configured
29	38	not configured
29	39	not configured
29	40	not configured
29	41	not configured
29	42	not configured
29	43	not configured
29	44	not configured
29	45	not configured
29	46	not configured
29	47	not configured
29	48	not configured
29	49	not configured
29	50	not configured
29	51	not configured
29	52	not configured
29	53	not configured
29	54	not configured
29	55	not configured
29	56	not configured
29	57	not configured
29	58	not configured
29	59	not configured
29	60	not configured
29	61	not configured
29	62	not configured
29	63	not configured
29	64	not configured
29	65	not configured
29	66	not configured
29	67	not configured
29	68	not configured
29	69	not configured
29	71	not configured
29	72	not configured
29	73	not configured
29	74	not configured
29	75	not configured
29	76	not configured
29	77	not configured
29	78	not configured
29	79	not configured
29	80	not configured
29	81	not configured
29	82	not configured
29	83	not configured
29	84	not configured
29	85	not configured
29	86	not configured
29	87	not configured
29	88	not configured
29	89	not configured
29	90	not configured
29	91	not configured
29	92	not configured
29	93	not configured
29	94	not configured
29	95	not configured
29	96	not configured
29	97	not configured
29	98	not configured
29	99	not configured
29	100	not configured
29	101	not configured
29	102	not configured
29	103	not configured
29	104	not configured
29	105	not configured
29	106	not configured
29	107	not configured
29	108	not configured
29	109	not configured
29	110	not configured
29	111	not configured
29	112	not configured
29	113	not configured
29	114	not configured
29	115	not configured
29	116	not configured
29	117	not configured
29	118	not configured
29	119	not configured
29	120	not configured
29	121	not configured
29	122	not configured
29	124	not configured
29	125	not configured
29	127	not configured
29	128	not configured
29	129	not configured
29	130	not configured
29	131	not configured
29	132	not configured
29	134	not configured
29	135	not configured
29	136	not configured
29	137	not configured
29	138	not configured
30	1	not configured
30	2	not configured
30	9	not configured
30	10	not configured
30	11	not configured
30	12	not configured
30	13	not configured
30	14	not configured
30	15	not configured
30	16	not configured
30	17	not configured
30	18	not configured
30	19	not configured
30	20	not configured
30	21	not configured
30	22	not configured
30	23	not configured
30	24	not configured
30	25	not configured
30	26	not configured
30	27	not configured
30	28	not configured
30	29	not configured
30	30	not configured
30	31	not configured
30	32	not configured
30	33	not configured
30	34	not configured
30	35	not configured
30	36	not configured
30	37	not configured
30	38	not configured
30	39	not configured
30	40	not configured
30	41	not configured
30	42	not configured
30	43	not configured
30	44	not configured
30	45	not configured
30	46	not configured
30	47	not configured
30	48	not configured
30	49	not configured
30	50	not configured
30	51	not configured
30	52	not configured
30	53	not configured
30	54	not configured
30	55	not configured
30	56	not configured
30	57	not configured
30	58	not configured
30	59	not configured
30	60	not configured
30	61	not configured
30	62	not configured
30	63	not configured
30	64	not configured
30	65	not configured
30	66	not configured
30	67	not configured
30	68	not configured
30	69	not configured
30	71	not configured
30	72	not configured
30	73	not configured
30	74	not configured
30	75	not configured
30	76	not configured
30	77	not configured
30	78	not configured
30	79	not configured
30	80	not configured
30	81	not configured
30	82	not configured
30	83	not configured
30	84	not configured
30	85	not configured
30	86	not configured
30	87	not configured
30	88	not configured
30	89	not configured
30	90	not configured
30	91	not configured
30	92	not configured
30	93	not configured
30	94	not configured
30	95	not configured
30	96	not configured
30	97	not configured
30	98	not configured
30	99	not configured
30	100	not configured
30	101	not configured
30	102	not configured
30	103	not configured
30	104	not configured
30	105	not configured
30	106	not configured
30	107	not configured
30	108	not configured
30	109	not configured
30	110	not configured
30	111	not configured
30	112	not configured
30	113	not configured
30	114	not configured
30	115	not configured
30	116	not configured
30	117	not configured
30	118	not configured
30	119	not configured
30	120	not configured
30	121	not configured
30	122	not configured
30	124	not configured
30	125	not configured
30	127	not configured
30	128	not configured
30	129	not configured
30	130	not configured
30	131	not configured
30	132	not configured
30	134	not configured
30	135	not configured
30	136	not configured
30	137	not configured
30	138	not configured
31	1	not configured
31	2	not configured
31	9	not configured
31	10	not configured
31	11	not configured
31	12	not configured
31	13	not configured
31	14	not configured
31	15	not configured
31	16	not configured
31	17	not configured
31	18	not configured
31	19	not configured
31	20	not configured
31	21	not configured
31	22	not configured
31	23	not configured
31	24	not configured
31	25	not configured
31	26	not configured
31	27	not configured
31	28	not configured
31	29	not configured
31	30	not configured
31	31	not configured
31	32	not configured
31	33	not configured
31	34	not configured
31	35	not configured
31	36	not configured
31	37	not configured
31	38	not configured
31	39	not configured
31	40	not configured
31	41	not configured
31	42	not configured
31	43	not configured
31	44	not configured
31	45	not configured
31	46	not configured
31	47	not configured
31	48	not configured
31	49	not configured
31	50	not configured
31	51	not configured
31	52	not configured
31	53	not configured
31	54	not configured
31	55	not configured
31	56	not configured
31	57	not configured
31	58	not configured
31	59	not configured
31	60	not configured
31	61	not configured
31	62	not configured
31	63	not configured
31	64	not configured
31	65	not configured
31	66	not configured
31	67	not configured
31	68	not configured
31	69	not configured
31	71	not configured
31	72	not configured
31	73	not configured
31	74	not configured
31	75	not configured
31	76	not configured
31	77	not configured
31	78	not configured
31	79	not configured
31	80	not configured
31	81	not configured
31	82	not configured
31	83	not configured
31	84	not configured
31	85	not configured
31	86	not configured
31	87	not configured
31	88	not configured
31	89	not configured
31	90	not configured
31	91	not configured
31	92	not configured
31	93	not configured
31	94	not configured
31	95	not configured
31	96	not configured
31	97	not configured
31	98	not configured
31	99	not configured
31	100	not configured
31	101	not configured
31	102	not configured
31	103	not configured
31	104	not configured
31	105	not configured
31	106	not configured
31	107	not configured
31	108	not configured
31	109	not configured
31	110	not configured
31	111	not configured
31	112	not configured
31	113	not configured
31	114	not configured
31	115	not configured
31	116	not configured
31	117	not configured
31	118	not configured
31	119	not configured
31	120	not configured
31	121	not configured
31	122	not configured
31	124	not configured
31	125	not configured
31	127	not configured
31	128	not configured
31	129	not configured
31	130	not configured
31	131	not configured
31	132	not configured
31	134	not configured
31	135	not configured
31	136	not configured
31	137	not configured
31	138	not configured
32	1	not configured
32	2	not configured
32	9	not configured
32	10	not configured
32	11	not configured
32	12	not configured
32	13	not configured
32	14	not configured
32	15	not configured
32	16	not configured
32	17	not configured
32	18	not configured
32	19	not configured
32	20	not configured
32	21	not configured
32	22	not configured
32	23	not configured
32	24	not configured
32	25	not configured
32	26	not configured
32	27	not configured
32	28	not configured
32	29	not configured
32	30	not configured
32	31	not configured
32	32	not configured
32	33	not configured
32	34	not configured
32	35	not configured
32	36	not configured
32	37	not configured
32	38	not configured
32	39	not configured
32	40	not configured
32	41	not configured
32	42	not configured
32	43	not configured
32	44	not configured
32	45	not configured
32	46	not configured
32	47	not configured
32	48	not configured
32	49	not configured
32	50	not configured
32	51	not configured
32	52	not configured
32	53	not configured
32	54	not configured
32	55	not configured
32	56	not configured
32	57	not configured
32	58	not configured
32	59	not configured
32	60	not configured
32	61	not configured
32	62	not configured
32	63	not configured
32	64	not configured
32	65	not configured
32	66	not configured
32	67	not configured
32	68	not configured
32	69	not configured
32	71	not configured
32	72	not configured
32	73	not configured
32	74	not configured
32	75	not configured
32	76	not configured
32	77	not configured
32	78	not configured
32	79	not configured
32	80	not configured
32	81	not configured
32	82	not configured
32	83	not configured
32	84	not configured
32	85	not configured
32	86	not configured
32	87	not configured
32	88	not configured
32	89	not configured
32	90	not configured
32	91	not configured
32	92	not configured
32	93	not configured
32	94	not configured
32	95	not configured
32	96	not configured
32	97	not configured
32	98	not configured
32	99	not configured
32	100	not configured
32	101	not configured
32	102	not configured
32	103	not configured
32	104	not configured
32	105	not configured
32	106	not configured
32	107	not configured
32	108	not configured
32	109	not configured
32	110	not configured
32	111	not configured
32	112	not configured
32	113	not configured
32	114	not configured
32	115	not configured
32	116	not configured
32	117	not configured
32	118	not configured
32	119	not configured
32	120	not configured
32	121	not configured
32	122	not configured
32	124	not configured
32	125	not configured
32	127	not configured
32	128	not configured
32	129	not configured
32	130	not configured
32	131	not configured
32	132	not configured
32	134	not configured
32	135	not configured
32	136	not configured
32	137	not configured
32	138	not configured
33	1	not configured
33	2	not configured
33	9	not configured
33	10	not configured
33	11	not configured
33	12	not configured
33	13	not configured
33	14	not configured
33	15	not configured
33	16	not configured
33	17	not configured
33	18	not configured
33	19	not configured
33	20	not configured
33	21	not configured
33	22	not configured
33	23	not configured
33	24	not configured
33	25	not configured
33	26	not configured
33	27	not configured
33	28	not configured
33	29	not configured
33	30	not configured
33	31	not configured
33	32	not configured
33	33	not configured
33	34	not configured
33	35	not configured
33	36	not configured
33	37	not configured
33	38	not configured
33	39	not configured
33	40	not configured
33	41	not configured
33	42	not configured
33	43	not configured
33	44	not configured
33	45	not configured
33	46	not configured
33	47	not configured
33	48	not configured
33	49	not configured
33	50	not configured
33	51	not configured
33	52	not configured
33	53	not configured
33	54	not configured
33	55	not configured
33	56	not configured
33	57	not configured
33	58	not configured
33	59	not configured
33	60	not configured
33	61	not configured
33	62	not configured
33	63	not configured
33	64	not configured
33	65	not configured
33	66	not configured
33	67	not configured
33	68	not configured
33	69	not configured
33	71	not configured
33	72	not configured
33	73	not configured
33	74	not configured
33	75	not configured
33	76	not configured
33	77	not configured
33	78	not configured
33	79	not configured
33	80	not configured
33	81	not configured
33	82	not configured
33	83	not configured
33	84	not configured
33	85	not configured
33	86	not configured
33	87	not configured
33	88	not configured
33	89	not configured
33	90	not configured
33	91	not configured
33	92	not configured
33	93	not configured
33	94	not configured
33	95	not configured
33	96	not configured
33	97	not configured
33	98	not configured
33	99	not configured
33	100	not configured
33	101	not configured
33	102	not configured
33	103	not configured
33	104	not configured
33	105	not configured
33	106	not configured
33	107	not configured
33	108	not configured
33	109	not configured
33	110	not configured
33	111	not configured
33	112	not configured
33	113	not configured
33	114	not configured
33	115	not configured
33	116	not configured
33	117	not configured
33	118	not configured
33	119	not configured
33	120	not configured
33	121	not configured
33	122	not configured
33	124	not configured
33	125	not configured
33	127	not configured
33	128	not configured
33	129	not configured
33	130	not configured
33	131	not configured
33	132	not configured
33	134	not configured
33	135	not configured
33	136	not configured
33	137	not configured
33	138	not configured
34	1	not configured
34	2	not configured
34	9	not configured
34	10	not configured
34	11	not configured
34	12	not configured
34	13	not configured
34	14	not configured
34	15	not configured
34	16	not configured
34	17	not configured
34	18	not configured
34	19	not configured
34	20	not configured
34	21	not configured
34	22	not configured
34	23	not configured
34	24	not configured
34	25	not configured
34	26	not configured
34	27	not configured
34	28	not configured
34	29	not configured
34	30	not configured
34	31	not configured
34	32	not configured
34	33	not configured
34	34	not configured
34	35	not configured
34	36	not configured
34	37	not configured
34	38	not configured
34	39	not configured
34	40	not configured
34	41	not configured
34	42	not configured
34	43	not configured
34	44	not configured
34	45	not configured
34	46	not configured
34	47	not configured
34	48	not configured
34	49	not configured
34	50	not configured
34	51	not configured
34	52	not configured
34	53	not configured
34	54	not configured
34	55	not configured
34	56	not configured
34	57	not configured
34	58	not configured
34	59	not configured
34	60	not configured
34	61	not configured
34	62	not configured
34	63	not configured
34	64	not configured
34	65	not configured
34	66	not configured
34	67	not configured
34	68	not configured
34	69	not configured
34	71	not configured
34	72	not configured
34	73	not configured
34	74	not configured
34	75	not configured
34	76	not configured
34	77	not configured
34	78	not configured
34	79	not configured
34	80	not configured
34	81	not configured
34	82	not configured
34	83	not configured
34	84	not configured
34	85	not configured
34	86	not configured
34	87	not configured
34	88	not configured
34	89	not configured
34	90	not configured
34	91	not configured
34	92	not configured
34	93	not configured
34	94	not configured
34	95	not configured
34	96	not configured
34	97	not configured
34	98	not configured
34	99	not configured
34	100	not configured
34	101	not configured
34	102	not configured
34	103	not configured
34	104	not configured
34	105	not configured
34	106	not configured
34	107	not configured
34	108	not configured
34	109	not configured
34	110	not configured
34	111	not configured
34	112	not configured
34	113	not configured
34	114	not configured
34	115	not configured
34	116	not configured
34	117	not configured
34	118	not configured
34	119	not configured
34	120	not configured
34	121	not configured
34	122	not configured
34	124	not configured
34	125	not configured
34	127	not configured
34	128	not configured
34	129	not configured
34	130	not configured
34	131	not configured
34	132	not configured
34	134	not configured
34	135	not configured
34	136	not configured
34	137	not configured
34	138	not configured
35	1	not configured
35	2	not configured
35	9	not configured
35	10	not configured
35	11	not configured
35	12	not configured
35	13	not configured
35	14	not configured
35	15	not configured
35	16	not configured
35	17	not configured
35	18	not configured
35	19	not configured
35	20	not configured
35	21	not configured
35	22	not configured
35	23	not configured
35	24	not configured
35	25	not configured
35	26	not configured
35	27	not configured
35	28	not configured
35	29	not configured
35	30	not configured
35	31	not configured
35	32	not configured
35	33	not configured
35	34	not configured
35	35	not configured
35	36	not configured
35	37	not configured
35	38	not configured
35	39	not configured
35	40	not configured
35	41	not configured
35	42	not configured
35	43	not configured
35	44	not configured
35	45	not configured
35	46	not configured
35	47	not configured
35	48	not configured
35	49	not configured
35	50	not configured
35	51	not configured
35	52	not configured
35	53	not configured
35	54	not configured
35	55	not configured
35	56	not configured
35	57	not configured
35	58	not configured
35	59	not configured
35	60	not configured
35	61	not configured
35	62	not configured
35	63	not configured
35	64	not configured
35	65	not configured
35	66	not configured
35	67	not configured
35	68	not configured
35	69	not configured
35	71	not configured
35	72	not configured
35	73	not configured
35	74	not configured
35	75	not configured
35	76	not configured
35	77	not configured
35	78	not configured
35	79	not configured
35	80	not configured
35	81	not configured
35	82	not configured
35	83	not configured
35	84	not configured
35	85	not configured
35	86	not configured
35	87	not configured
35	88	not configured
35	89	not configured
35	90	not configured
35	91	not configured
35	92	not configured
35	93	not configured
35	94	not configured
35	95	not configured
35	96	not configured
35	97	not configured
35	98	not configured
35	99	not configured
35	100	not configured
35	101	not configured
35	102	not configured
35	103	not configured
35	104	not configured
35	105	not configured
35	106	not configured
35	107	not configured
35	108	not configured
35	109	not configured
35	110	not configured
35	111	not configured
35	112	not configured
35	113	not configured
35	114	not configured
35	115	not configured
35	116	not configured
35	117	not configured
35	118	not configured
35	119	not configured
35	120	not configured
35	121	not configured
35	122	not configured
35	124	not configured
35	125	not configured
35	127	not configured
35	128	not configured
35	129	not configured
35	130	not configured
35	131	not configured
35	132	not configured
35	134	not configured
35	135	not configured
35	136	not configured
35	137	not configured
35	138	not configured
36	1	not configured
36	2	not configured
36	9	not configured
36	10	not configured
36	11	not configured
36	12	not configured
36	13	not configured
36	14	not configured
36	15	not configured
36	16	not configured
36	17	not configured
36	18	not configured
36	19	not configured
36	20	not configured
36	21	not configured
36	22	not configured
36	23	not configured
36	24	not configured
36	25	not configured
36	26	not configured
36	27	not configured
36	28	not configured
36	29	not configured
36	30	not configured
36	31	not configured
36	32	not configured
36	33	not configured
36	34	not configured
36	35	not configured
36	36	not configured
36	37	not configured
36	38	not configured
36	39	not configured
36	40	not configured
36	41	not configured
36	42	not configured
36	43	not configured
36	44	not configured
36	45	not configured
36	46	not configured
36	47	not configured
36	48	not configured
36	49	not configured
36	50	not configured
36	51	not configured
36	52	not configured
36	53	not configured
36	54	not configured
36	55	not configured
36	56	not configured
36	57	not configured
36	58	not configured
36	59	not configured
36	60	not configured
36	61	not configured
36	62	not configured
36	63	not configured
36	64	not configured
36	65	not configured
36	66	not configured
36	67	not configured
36	68	not configured
36	69	not configured
36	71	not configured
36	72	not configured
36	73	not configured
36	74	not configured
36	75	not configured
36	76	not configured
36	77	not configured
36	78	not configured
36	79	not configured
36	80	not configured
36	81	not configured
36	82	not configured
36	83	not configured
36	84	not configured
36	85	not configured
36	86	not configured
36	87	not configured
36	88	not configured
36	89	not configured
36	90	not configured
36	91	not configured
36	92	not configured
36	93	not configured
36	94	not configured
36	95	not configured
36	96	not configured
36	97	not configured
36	98	not configured
36	99	not configured
36	100	not configured
36	101	not configured
36	102	not configured
36	103	not configured
36	104	not configured
36	105	not configured
36	106	not configured
36	107	not configured
36	108	not configured
36	109	not configured
36	110	not configured
36	111	not configured
36	112	not configured
36	113	not configured
36	114	not configured
36	115	not configured
36	116	not configured
36	117	not configured
36	118	not configured
36	119	not configured
36	120	not configured
36	121	not configured
36	122	not configured
36	124	not configured
36	125	not configured
36	127	not configured
36	128	not configured
36	129	not configured
36	130	not configured
36	131	not configured
36	132	not configured
36	134	not configured
36	135	not configured
36	136	not configured
36	137	not configured
36	138	not configured
37	1	not configured
37	2	not configured
37	9	not configured
37	10	not configured
37	11	not configured
37	12	not configured
37	13	not configured
37	14	not configured
37	15	not configured
37	16	not configured
37	17	not configured
37	18	not configured
37	19	not configured
37	20	not configured
37	21	not configured
37	22	not configured
37	23	not configured
37	24	not configured
37	25	not configured
37	26	not configured
37	27	not configured
37	28	not configured
37	29	not configured
37	30	not configured
37	31	not configured
37	32	not configured
37	33	not configured
37	34	not configured
37	35	not configured
37	36	not configured
37	37	not configured
37	38	not configured
37	39	not configured
37	40	not configured
37	41	not configured
37	42	not configured
37	43	not configured
37	44	not configured
37	45	not configured
37	46	not configured
37	47	not configured
37	48	not configured
37	49	not configured
37	50	not configured
37	51	not configured
37	52	not configured
37	53	not configured
37	54	not configured
37	55	not configured
37	56	not configured
37	57	not configured
37	58	not configured
37	59	not configured
37	60	not configured
37	61	not configured
37	62	not configured
37	63	not configured
37	64	not configured
37	65	not configured
37	66	not configured
37	67	not configured
37	68	not configured
37	69	not configured
37	71	not configured
37	72	not configured
37	73	not configured
37	74	not configured
37	75	not configured
37	76	not configured
37	77	not configured
37	78	not configured
37	79	not configured
37	80	not configured
37	81	not configured
37	82	not configured
37	83	not configured
37	84	not configured
37	85	not configured
37	86	not configured
37	87	not configured
37	88	not configured
37	89	not configured
37	90	not configured
37	91	not configured
37	92	not configured
37	93	not configured
37	94	not configured
37	95	not configured
37	96	not configured
37	97	not configured
37	98	not configured
37	99	not configured
37	100	not configured
37	101	not configured
37	102	not configured
37	103	not configured
37	104	not configured
37	105	not configured
37	106	not configured
37	107	not configured
37	108	not configured
37	109	not configured
37	110	not configured
37	111	not configured
37	112	not configured
37	113	not configured
37	114	not configured
37	115	not configured
37	116	not configured
37	117	not configured
37	118	not configured
37	119	not configured
37	120	not configured
37	121	not configured
37	122	not configured
37	124	not configured
37	125	not configured
37	127	not configured
37	128	not configured
37	129	not configured
37	130	not configured
37	131	not configured
37	132	not configured
37	134	not configured
37	135	not configured
37	136	not configured
37	137	not configured
37	138	not configured
38	1	not configured
38	2	not configured
38	9	not configured
38	10	not configured
38	11	not configured
38	12	not configured
38	13	not configured
38	14	not configured
38	15	not configured
38	16	not configured
38	17	not configured
38	18	not configured
38	19	not configured
38	20	not configured
38	21	not configured
38	22	not configured
38	23	not configured
38	24	not configured
38	25	not configured
38	26	not configured
38	27	not configured
38	28	not configured
38	29	not configured
38	30	not configured
38	31	not configured
38	32	not configured
38	33	not configured
38	34	not configured
38	35	not configured
38	36	not configured
38	37	not configured
38	38	not configured
38	39	not configured
38	40	not configured
38	41	not configured
38	42	not configured
38	43	not configured
38	44	not configured
38	45	not configured
38	46	not configured
38	47	not configured
38	48	not configured
38	49	not configured
38	50	not configured
38	51	not configured
38	52	not configured
38	53	not configured
38	54	not configured
38	55	not configured
38	56	not configured
38	57	not configured
38	58	not configured
38	59	not configured
38	60	not configured
38	61	not configured
38	62	not configured
38	63	not configured
38	64	not configured
38	65	not configured
38	66	not configured
38	67	not configured
38	68	not configured
38	69	not configured
38	71	not configured
38	72	not configured
38	73	not configured
38	74	not configured
38	75	not configured
38	76	not configured
38	77	not configured
38	78	not configured
38	79	not configured
38	80	not configured
38	81	not configured
38	82	not configured
38	83	not configured
38	84	not configured
38	85	not configured
38	86	not configured
38	87	not configured
38	88	not configured
38	89	not configured
38	90	not configured
38	91	not configured
38	92	not configured
38	93	not configured
38	94	not configured
38	95	not configured
38	96	not configured
38	97	not configured
38	98	not configured
38	99	not configured
38	100	not configured
38	101	not configured
38	102	not configured
38	103	not configured
38	104	not configured
38	105	not configured
38	106	not configured
38	107	not configured
38	108	not configured
38	109	not configured
38	110	not configured
38	111	not configured
38	112	not configured
38	113	not configured
38	114	not configured
38	115	not configured
38	116	not configured
38	117	not configured
38	118	not configured
38	119	not configured
38	120	not configured
38	121	not configured
38	122	not configured
38	124	not configured
38	125	not configured
38	127	not configured
38	128	not configured
38	129	not configured
38	130	not configured
38	131	not configured
38	132	not configured
38	134	not configured
38	135	not configured
38	136	not configured
38	137	not configured
38	138	not configured
39	1	not configured
39	2	not configured
39	9	not configured
39	10	not configured
39	11	not configured
39	12	not configured
39	13	not configured
39	14	not configured
39	15	not configured
39	16	not configured
39	17	not configured
39	18	not configured
39	19	not configured
39	20	not configured
39	21	not configured
39	22	not configured
39	23	not configured
39	24	not configured
39	25	not configured
39	26	not configured
39	27	not configured
39	28	not configured
39	29	not configured
39	30	not configured
39	31	not configured
39	32	not configured
39	33	not configured
39	34	not configured
39	35	not configured
39	36	not configured
39	37	not configured
39	38	not configured
39	39	not configured
39	40	not configured
39	41	not configured
39	42	not configured
39	43	not configured
39	44	not configured
39	45	not configured
39	46	not configured
39	47	not configured
39	48	not configured
39	49	not configured
39	50	not configured
39	51	not configured
39	52	not configured
39	53	not configured
39	54	not configured
39	55	not configured
39	56	not configured
39	57	not configured
39	58	not configured
39	59	not configured
39	60	not configured
39	61	not configured
39	62	not configured
39	63	not configured
39	64	not configured
39	65	not configured
39	66	not configured
39	67	not configured
39	68	not configured
39	69	not configured
39	71	not configured
39	72	not configured
39	73	not configured
39	74	not configured
39	75	not configured
39	76	not configured
39	77	not configured
39	78	not configured
39	79	not configured
39	80	not configured
39	81	not configured
39	82	not configured
39	83	not configured
39	84	not configured
39	85	not configured
39	86	not configured
39	87	not configured
39	88	not configured
39	89	not configured
39	90	not configured
39	91	not configured
39	92	not configured
39	93	not configured
39	94	not configured
39	95	not configured
39	96	not configured
39	97	not configured
39	98	not configured
39	99	not configured
39	100	not configured
39	101	not configured
39	102	not configured
39	103	not configured
39	104	not configured
39	105	not configured
39	106	not configured
39	107	not configured
39	108	not configured
39	109	not configured
39	110	not configured
39	111	not configured
39	112	not configured
39	113	not configured
39	114	not configured
39	115	not configured
39	116	not configured
39	117	not configured
39	118	not configured
39	119	not configured
39	120	not configured
39	121	not configured
39	122	not configured
39	124	not configured
39	125	not configured
39	127	not configured
39	128	not configured
39	129	not configured
39	130	not configured
39	131	not configured
39	132	not configured
39	134	not configured
39	135	not configured
39	136	not configured
39	137	not configured
39	138	not configured
40	1	not configured
40	2	not configured
40	9	not configured
40	10	not configured
40	11	not configured
40	12	not configured
40	13	not configured
40	14	not configured
40	15	not configured
40	16	not configured
40	17	not configured
40	18	not configured
40	19	not configured
40	20	not configured
40	21	not configured
40	22	not configured
40	23	not configured
40	24	not configured
40	25	not configured
40	26	not configured
40	27	not configured
40	28	not configured
40	29	not configured
40	30	not configured
40	31	not configured
40	32	not configured
40	33	not configured
40	34	not configured
40	35	not configured
40	36	not configured
40	37	not configured
40	38	not configured
40	39	not configured
40	40	not configured
40	41	not configured
40	42	not configured
40	43	not configured
40	44	not configured
40	45	not configured
40	46	not configured
40	47	not configured
40	48	not configured
40	49	not configured
40	50	not configured
40	51	not configured
40	52	not configured
40	53	not configured
40	54	not configured
40	55	not configured
40	56	not configured
40	57	not configured
40	58	not configured
40	59	not configured
40	60	not configured
40	61	not configured
40	62	not configured
40	63	not configured
40	64	not configured
40	65	not configured
40	66	not configured
40	67	not configured
40	68	not configured
40	69	not configured
40	71	not configured
40	72	not configured
40	73	not configured
40	74	not configured
40	75	not configured
40	76	not configured
40	77	not configured
40	78	not configured
40	79	not configured
40	80	not configured
40	81	not configured
40	82	not configured
40	83	not configured
40	84	not configured
40	85	not configured
40	86	not configured
40	87	not configured
40	88	not configured
40	89	not configured
40	90	not configured
40	91	not configured
40	92	not configured
40	93	not configured
40	94	not configured
40	95	not configured
40	96	not configured
40	97	not configured
40	98	not configured
40	99	not configured
40	100	not configured
40	101	not configured
40	102	not configured
40	103	not configured
40	104	not configured
40	105	not configured
40	106	not configured
40	107	not configured
40	108	not configured
40	109	not configured
40	110	not configured
40	111	not configured
40	112	not configured
40	113	not configured
40	114	not configured
40	115	not configured
40	116	not configured
40	117	not configured
40	118	not configured
40	119	not configured
40	120	not configured
40	121	not configured
40	122	not configured
40	124	not configured
40	125	not configured
40	127	not configured
40	128	not configured
40	129	not configured
40	130	not configured
40	131	not configured
40	132	not configured
40	134	not configured
40	135	not configured
40	136	not configured
40	137	not configured
40	138	not configured
41	1	not configured
41	2	not configured
41	9	not configured
41	10	not configured
41	11	not configured
41	12	not configured
41	13	not configured
41	14	not configured
41	15	not configured
41	16	not configured
41	17	not configured
41	18	not configured
41	19	not configured
41	20	not configured
41	21	not configured
41	22	not configured
41	23	not configured
41	24	not configured
41	25	not configured
41	26	not configured
41	27	not configured
41	28	not configured
41	29	not configured
41	30	not configured
41	31	not configured
41	32	not configured
41	33	not configured
41	34	not configured
41	35	not configured
41	36	not configured
41	37	not configured
41	38	not configured
41	39	not configured
41	40	not configured
41	41	not configured
41	42	not configured
41	43	not configured
41	44	not configured
41	45	not configured
41	46	not configured
41	47	not configured
41	48	not configured
41	49	not configured
41	50	not configured
41	51	not configured
41	52	not configured
41	53	not configured
41	54	not configured
41	55	not configured
41	56	not configured
41	57	not configured
41	58	not configured
41	59	not configured
41	60	not configured
41	61	not configured
41	62	not configured
41	63	not configured
41	64	not configured
41	65	not configured
41	66	not configured
41	67	not configured
41	68	not configured
41	69	not configured
41	71	not configured
41	72	not configured
41	73	not configured
41	74	not configured
41	75	not configured
41	76	not configured
41	77	not configured
41	78	not configured
41	79	not configured
41	80	not configured
41	81	not configured
41	82	not configured
41	83	not configured
41	84	not configured
41	85	not configured
41	86	not configured
41	87	not configured
41	88	not configured
41	89	not configured
41	90	not configured
41	91	not configured
41	92	not configured
41	93	not configured
41	94	not configured
41	95	not configured
41	96	not configured
41	97	not configured
41	98	not configured
41	99	not configured
41	100	not configured
41	101	not configured
41	102	not configured
41	103	not configured
41	104	not configured
41	105	not configured
41	106	not configured
41	107	not configured
41	108	not configured
41	109	not configured
41	110	not configured
41	111	not configured
41	112	not configured
41	113	not configured
41	114	not configured
41	115	not configured
41	116	not configured
41	117	not configured
41	118	not configured
41	119	not configured
41	120	not configured
41	121	not configured
41	122	not configured
41	124	not configured
41	125	not configured
41	127	not configured
41	128	not configured
41	129	not configured
41	130	not configured
41	131	not configured
41	132	not configured
41	134	not configured
41	135	not configured
41	136	not configured
41	137	not configured
41	138	not configured
42	1	not configured
42	2	not configured
42	9	not configured
42	10	not configured
42	11	not configured
42	12	not configured
42	13	not configured
42	14	not configured
42	15	not configured
42	16	not configured
42	17	not configured
42	18	not configured
42	19	not configured
42	20	not configured
42	21	not configured
42	22	not configured
42	23	not configured
42	24	not configured
42	25	not configured
42	26	not configured
42	27	not configured
42	28	not configured
42	29	not configured
42	30	not configured
42	31	not configured
42	32	not configured
42	33	not configured
42	34	not configured
42	35	not configured
42	36	not configured
42	37	not configured
42	38	not configured
42	39	not configured
42	40	not configured
42	41	not configured
42	42	not configured
42	43	not configured
42	44	not configured
42	45	not configured
42	46	not configured
42	47	not configured
42	48	not configured
42	49	not configured
42	50	not configured
42	51	not configured
42	52	not configured
42	53	not configured
42	54	not configured
42	55	not configured
42	56	not configured
42	57	not configured
42	58	not configured
42	59	not configured
42	60	not configured
42	61	not configured
42	62	not configured
42	63	not configured
42	64	not configured
42	65	not configured
42	66	not configured
42	67	not configured
42	68	not configured
42	69	not configured
42	71	not configured
42	72	not configured
42	73	not configured
42	74	not configured
42	75	not configured
42	76	not configured
42	77	not configured
42	78	not configured
42	79	not configured
42	80	not configured
42	81	not configured
42	82	not configured
42	83	not configured
42	84	not configured
42	85	not configured
42	86	not configured
42	87	not configured
42	88	not configured
42	89	not configured
42	90	not configured
42	91	not configured
42	92	not configured
42	93	not configured
42	94	not configured
42	95	not configured
42	96	not configured
42	97	not configured
42	98	not configured
42	99	not configured
42	100	not configured
42	101	not configured
42	102	not configured
42	103	not configured
42	104	not configured
42	105	not configured
42	106	not configured
42	107	not configured
42	108	not configured
42	109	not configured
42	110	not configured
42	111	not configured
42	112	not configured
42	113	not configured
42	114	not configured
42	115	not configured
42	116	not configured
42	117	not configured
42	118	not configured
42	119	not configured
42	120	not configured
42	121	not configured
42	122	not configured
42	124	not configured
42	125	not configured
42	127	not configured
42	128	not configured
42	129	not configured
42	130	not configured
42	131	not configured
42	132	not configured
42	134	not configured
42	135	not configured
42	136	not configured
42	137	not configured
42	138	not configured
43	1	not configured
43	2	not configured
43	9	not configured
43	10	not configured
43	11	not configured
43	12	not configured
43	13	not configured
43	14	not configured
43	15	not configured
43	16	not configured
43	17	not configured
43	18	not configured
43	19	not configured
43	20	not configured
43	21	not configured
43	22	not configured
43	23	not configured
43	24	not configured
43	25	not configured
43	26	not configured
43	27	not configured
43	28	not configured
43	29	not configured
43	30	not configured
43	31	not configured
43	32	not configured
43	33	not configured
43	34	not configured
43	35	not configured
43	36	not configured
43	37	not configured
43	38	not configured
43	39	not configured
43	40	not configured
43	41	not configured
43	42	not configured
43	43	not configured
43	44	not configured
43	45	not configured
43	46	not configured
43	47	not configured
43	48	not configured
43	49	not configured
43	50	not configured
43	51	not configured
43	52	not configured
43	53	not configured
43	54	not configured
43	55	not configured
43	56	not configured
43	57	not configured
43	58	not configured
43	59	not configured
43	60	not configured
43	61	not configured
43	62	not configured
43	63	not configured
43	64	not configured
43	65	not configured
43	66	not configured
43	67	not configured
43	68	not configured
43	69	not configured
43	71	not configured
43	72	not configured
43	73	not configured
43	74	not configured
43	75	not configured
43	76	not configured
43	77	not configured
43	78	not configured
43	79	not configured
43	80	not configured
43	81	not configured
43	82	not configured
43	83	not configured
43	84	not configured
43	85	not configured
43	86	not configured
43	87	not configured
43	88	not configured
43	89	not configured
43	90	not configured
43	91	not configured
43	92	not configured
43	93	not configured
43	94	not configured
43	95	not configured
43	96	not configured
43	97	not configured
43	98	not configured
43	99	not configured
43	100	not configured
43	101	not configured
43	102	not configured
43	103	not configured
43	104	not configured
43	105	not configured
43	106	not configured
43	107	not configured
43	108	not configured
43	109	not configured
43	110	not configured
43	111	not configured
43	112	not configured
43	113	not configured
43	114	not configured
43	115	not configured
43	116	not configured
43	117	not configured
43	118	not configured
43	119	not configured
43	120	not configured
43	121	not configured
43	122	not configured
43	124	not configured
43	125	not configured
43	127	not configured
43	128	not configured
43	129	not configured
43	130	not configured
43	131	not configured
43	132	not configured
43	134	not configured
43	135	not configured
43	136	not configured
43	137	not configured
43	138	not configured
44	1	not configured
44	2	not configured
44	9	not configured
44	10	not configured
44	11	not configured
44	12	not configured
44	13	not configured
44	14	not configured
44	15	not configured
44	16	not configured
44	17	not configured
44	18	not configured
44	19	not configured
44	20	not configured
44	21	not configured
44	22	not configured
44	23	not configured
44	24	not configured
44	25	not configured
44	26	not configured
44	27	not configured
44	28	not configured
44	29	not configured
44	30	not configured
44	31	not configured
44	32	not configured
44	33	not configured
44	34	not configured
44	35	not configured
44	36	not configured
44	37	not configured
44	38	not configured
44	39	not configured
44	40	not configured
44	41	not configured
44	42	not configured
44	43	not configured
44	44	not configured
44	45	not configured
44	46	not configured
44	47	not configured
44	48	not configured
44	49	not configured
44	50	not configured
44	51	not configured
44	52	not configured
44	53	not configured
44	54	not configured
44	55	not configured
44	56	not configured
44	57	not configured
44	58	not configured
44	59	not configured
44	60	not configured
44	61	not configured
44	62	not configured
44	63	not configured
44	64	not configured
44	65	not configured
44	66	not configured
44	67	not configured
44	68	not configured
44	69	not configured
44	71	not configured
44	72	not configured
44	73	not configured
44	74	not configured
44	75	not configured
44	76	not configured
44	77	not configured
44	78	not configured
44	79	not configured
44	80	not configured
44	81	not configured
44	82	not configured
44	83	not configured
44	84	not configured
44	85	not configured
44	86	not configured
44	87	not configured
44	88	not configured
44	89	not configured
44	90	not configured
44	91	not configured
44	92	not configured
44	93	not configured
44	94	not configured
44	95	not configured
44	96	not configured
44	97	not configured
44	98	not configured
44	99	not configured
44	100	not configured
44	101	not configured
44	102	not configured
44	103	not configured
44	104	not configured
44	105	not configured
44	106	not configured
44	107	not configured
44	108	not configured
44	109	not configured
44	110	not configured
44	111	not configured
44	112	not configured
44	113	not configured
44	114	not configured
44	115	not configured
44	116	not configured
44	117	not configured
44	118	not configured
44	119	not configured
44	120	not configured
44	121	not configured
44	122	not configured
44	124	not configured
44	125	not configured
44	127	not configured
44	128	not configured
44	129	not configured
44	130	not configured
44	131	not configured
44	132	not configured
44	134	not configured
44	135	not configured
44	136	not configured
44	137	not configured
44	138	not configured
45	1	not configured
45	2	not configured
45	9	not configured
45	10	not configured
45	11	not configured
45	12	not configured
45	13	not configured
45	14	not configured
45	15	not configured
45	16	not configured
45	17	not configured
45	18	not configured
45	19	not configured
45	20	not configured
45	21	not configured
45	22	not configured
45	23	not configured
45	24	not configured
45	25	not configured
45	26	not configured
45	27	not configured
45	28	not configured
45	29	not configured
45	30	not configured
45	31	not configured
45	32	not configured
45	33	not configured
45	34	not configured
45	35	not configured
45	36	not configured
45	37	not configured
45	38	not configured
45	39	not configured
45	40	not configured
45	41	not configured
45	42	not configured
45	43	not configured
45	44	not configured
45	45	not configured
45	46	not configured
45	47	not configured
45	48	not configured
45	49	not configured
45	50	not configured
45	51	not configured
45	52	not configured
45	53	not configured
45	54	not configured
45	55	not configured
45	56	not configured
45	57	not configured
45	58	not configured
45	59	not configured
45	60	not configured
45	61	not configured
45	62	not configured
45	63	not configured
45	64	not configured
45	65	not configured
45	66	not configured
45	67	not configured
45	68	not configured
45	69	not configured
45	71	not configured
45	72	not configured
45	73	not configured
45	74	not configured
45	75	not configured
45	76	not configured
45	77	not configured
45	78	not configured
45	79	not configured
45	80	not configured
45	81	not configured
45	82	not configured
45	83	not configured
45	84	not configured
45	85	not configured
45	86	not configured
45	87	not configured
45	88	not configured
45	89	not configured
45	90	not configured
45	91	not configured
45	92	not configured
45	93	not configured
45	94	not configured
45	95	not configured
45	96	not configured
45	97	not configured
45	98	not configured
45	99	not configured
45	100	not configured
45	101	not configured
45	102	not configured
45	103	not configured
45	104	not configured
45	105	not configured
45	106	not configured
45	107	not configured
45	108	not configured
45	109	not configured
45	110	not configured
45	111	not configured
45	112	not configured
45	113	not configured
45	114	not configured
45	115	not configured
45	116	not configured
45	117	not configured
45	118	not configured
45	119	not configured
45	120	not configured
45	121	not configured
45	122	not configured
45	124	not configured
45	125	not configured
45	127	not configured
45	128	not configured
45	129	not configured
45	130	not configured
45	131	not configured
45	132	not configured
45	134	not configured
45	135	not configured
45	136	not configured
45	137	not configured
45	138	not configured
46	1	not configured
46	2	not configured
46	9	not configured
46	10	not configured
46	11	not configured
46	12	not configured
46	13	not configured
46	14	not configured
46	15	not configured
46	16	not configured
46	17	not configured
46	18	not configured
46	19	not configured
46	20	not configured
46	21	not configured
46	22	not configured
46	23	not configured
46	24	not configured
46	25	not configured
46	26	not configured
46	27	not configured
46	28	not configured
46	29	not configured
46	30	not configured
46	31	not configured
46	32	not configured
46	33	not configured
46	34	not configured
46	35	not configured
46	36	not configured
46	37	not configured
46	38	not configured
46	39	not configured
46	40	not configured
46	41	not configured
46	42	not configured
46	43	not configured
46	44	not configured
46	45	not configured
46	46	not configured
46	47	not configured
46	48	not configured
46	49	not configured
46	50	not configured
46	51	not configured
46	52	not configured
46	53	not configured
46	54	not configured
46	55	not configured
46	56	not configured
46	57	not configured
46	58	not configured
46	59	not configured
46	60	not configured
46	61	not configured
46	62	not configured
46	63	not configured
46	64	not configured
46	65	not configured
46	66	not configured
46	67	not configured
46	68	not configured
46	69	not configured
46	71	not configured
46	72	not configured
46	73	not configured
46	74	not configured
46	75	not configured
46	76	not configured
46	77	not configured
46	78	not configured
46	79	not configured
46	80	not configured
46	81	not configured
46	82	not configured
46	83	not configured
46	84	not configured
46	85	not configured
46	86	not configured
46	87	not configured
46	88	not configured
46	89	not configured
46	90	not configured
46	91	not configured
46	92	not configured
46	93	not configured
46	94	not configured
46	95	not configured
46	96	not configured
46	97	not configured
46	98	not configured
46	99	not configured
46	100	not configured
46	101	not configured
46	102	not configured
46	103	not configured
46	104	not configured
46	105	not configured
46	106	not configured
46	107	not configured
46	108	not configured
46	109	not configured
46	110	not configured
46	111	not configured
46	112	not configured
46	113	not configured
46	114	not configured
46	115	not configured
46	116	not configured
46	117	not configured
46	118	not configured
46	119	not configured
46	120	not configured
46	121	not configured
46	122	not configured
46	124	not configured
46	125	not configured
46	127	not configured
46	128	not configured
46	129	not configured
46	130	not configured
46	131	not configured
46	132	not configured
46	134	not configured
46	135	not configured
46	136	not configured
46	137	not configured
46	138	not configured
47	1	not configured
47	2	not configured
47	9	not configured
47	10	not configured
47	11	not configured
47	12	not configured
47	13	not configured
47	14	not configured
47	15	not configured
47	16	not configured
47	17	not configured
47	18	not configured
47	19	not configured
47	20	not configured
47	21	not configured
47	22	not configured
47	23	not configured
47	24	not configured
47	25	not configured
47	26	not configured
47	27	not configured
47	28	not configured
47	29	not configured
47	30	not configured
47	31	not configured
47	32	not configured
47	33	not configured
47	34	not configured
47	35	not configured
47	36	not configured
47	37	not configured
47	38	not configured
47	39	not configured
47	40	not configured
47	41	not configured
47	42	not configured
47	43	not configured
47	44	not configured
47	45	not configured
47	46	not configured
47	47	not configured
47	48	not configured
47	49	not configured
47	50	not configured
47	51	not configured
47	52	not configured
47	53	not configured
47	54	not configured
47	55	not configured
47	56	not configured
47	57	not configured
47	58	not configured
47	59	not configured
47	60	not configured
47	61	not configured
47	62	not configured
47	63	not configured
47	64	not configured
47	65	not configured
47	66	not configured
47	67	not configured
47	68	not configured
47	69	not configured
47	71	not configured
47	72	not configured
47	73	not configured
47	74	not configured
47	75	not configured
47	76	not configured
47	77	not configured
47	78	not configured
47	79	not configured
47	80	not configured
47	81	not configured
47	82	not configured
47	83	not configured
47	84	not configured
47	85	not configured
47	86	not configured
47	87	not configured
47	88	not configured
47	89	not configured
47	90	not configured
47	91	not configured
47	92	not configured
47	93	not configured
47	94	not configured
47	95	not configured
47	96	not configured
47	97	not configured
47	98	not configured
47	99	not configured
47	100	not configured
47	101	not configured
47	102	not configured
47	103	not configured
47	104	not configured
47	105	not configured
47	106	not configured
47	107	not configured
47	108	not configured
47	109	not configured
47	110	not configured
47	111	not configured
47	112	not configured
47	113	not configured
47	114	not configured
47	115	not configured
47	116	not configured
47	117	not configured
47	118	not configured
47	119	not configured
47	120	not configured
47	121	not configured
47	122	not configured
47	124	not configured
47	125	not configured
47	127	not configured
47	128	not configured
47	129	not configured
47	130	not configured
47	131	not configured
47	132	not configured
47	134	not configured
47	135	not configured
47	136	not configured
47	137	not configured
47	138	not configured
48	1	not configured
48	2	not configured
48	9	not configured
48	10	not configured
48	11	not configured
48	12	not configured
48	13	not configured
48	14	not configured
48	15	not configured
48	16	not configured
48	17	not configured
48	18	not configured
48	19	not configured
48	20	not configured
48	21	not configured
48	22	not configured
48	23	not configured
48	24	not configured
48	25	not configured
48	26	not configured
48	27	not configured
48	28	not configured
48	29	not configured
48	30	not configured
48	31	not configured
48	32	not configured
48	33	not configured
48	34	not configured
48	35	not configured
48	36	not configured
48	37	not configured
48	38	not configured
48	39	not configured
48	40	not configured
48	41	not configured
48	42	not configured
48	43	not configured
48	44	not configured
48	45	not configured
48	46	not configured
48	47	not configured
48	48	not configured
48	49	not configured
48	50	not configured
48	51	not configured
48	52	not configured
48	53	not configured
48	54	not configured
48	55	not configured
48	56	not configured
48	57	not configured
48	58	not configured
48	59	not configured
48	60	not configured
48	61	not configured
48	62	not configured
48	63	not configured
48	64	not configured
48	65	not configured
48	66	not configured
48	67	not configured
48	68	not configured
48	69	not configured
48	71	not configured
48	72	not configured
48	73	not configured
48	74	not configured
48	75	not configured
48	76	not configured
48	77	not configured
48	78	not configured
48	79	not configured
48	80	not configured
48	81	not configured
48	82	not configured
48	83	not configured
48	84	not configured
48	85	not configured
48	86	not configured
48	87	not configured
48	88	not configured
48	89	not configured
48	90	not configured
48	91	not configured
48	92	not configured
48	93	not configured
48	94	not configured
48	95	not configured
48	96	not configured
48	97	not configured
48	98	not configured
48	99	not configured
48	100	not configured
48	101	not configured
48	102	not configured
48	103	not configured
48	104	not configured
48	105	not configured
48	106	not configured
48	107	not configured
48	108	not configured
48	109	not configured
48	110	not configured
48	111	not configured
48	112	not configured
48	113	not configured
48	114	not configured
48	115	not configured
48	116	not configured
48	117	not configured
48	118	not configured
48	119	not configured
48	120	not configured
48	121	not configured
48	122	not configured
48	124	not configured
48	125	not configured
48	127	not configured
48	128	not configured
48	129	not configured
48	130	not configured
48	131	not configured
48	132	not configured
48	134	not configured
48	135	not configured
48	136	not configured
48	137	not configured
48	138	not configured
49	1	not configured
49	2	not configured
49	9	not configured
49	10	not configured
49	11	not configured
49	12	not configured
49	13	not configured
49	14	not configured
49	15	not configured
49	16	not configured
49	17	not configured
49	18	not configured
49	19	not configured
49	20	not configured
49	21	not configured
49	22	not configured
49	23	not configured
49	24	not configured
49	25	not configured
49	26	not configured
49	27	not configured
49	28	not configured
49	29	not configured
49	30	not configured
49	31	not configured
49	32	not configured
49	33	not configured
49	34	not configured
49	35	not configured
49	36	not configured
49	37	not configured
49	38	not configured
49	39	not configured
49	40	not configured
49	41	not configured
49	42	not configured
49	43	not configured
49	44	not configured
49	45	not configured
49	46	not configured
49	47	not configured
49	48	not configured
49	49	not configured
49	50	not configured
49	51	not configured
49	52	not configured
49	53	not configured
49	54	not configured
49	55	not configured
49	56	not configured
49	57	not configured
49	58	not configured
49	59	not configured
49	60	not configured
49	61	not configured
49	62	not configured
49	63	not configured
49	64	not configured
49	65	not configured
49	66	not configured
49	67	not configured
49	68	not configured
49	69	not configured
49	71	not configured
49	72	not configured
49	73	not configured
49	74	not configured
49	75	not configured
49	76	not configured
49	77	not configured
49	78	not configured
49	79	not configured
49	80	not configured
49	81	not configured
49	82	not configured
49	83	not configured
49	84	not configured
49	85	not configured
49	86	not configured
49	87	not configured
49	88	not configured
49	89	not configured
49	90	not configured
49	91	not configured
49	92	not configured
49	93	not configured
49	94	not configured
49	95	not configured
49	96	not configured
49	97	not configured
49	98	not configured
49	99	not configured
49	100	not configured
49	101	not configured
49	102	not configured
49	103	not configured
49	104	not configured
49	105	not configured
49	106	not configured
49	107	not configured
49	108	not configured
49	109	not configured
49	110	not configured
49	111	not configured
49	112	not configured
49	113	not configured
49	114	not configured
49	115	not configured
49	116	not configured
49	117	not configured
49	118	not configured
49	119	not configured
49	120	not configured
49	121	not configured
49	122	not configured
49	124	not configured
49	125	not configured
49	127	not configured
49	128	not configured
49	129	not configured
49	130	not configured
49	131	not configured
49	132	not configured
49	134	not configured
49	135	not configured
49	136	not configured
49	137	not configured
49	138	not configured
50	1	not configured
50	2	not configured
50	9	not configured
50	10	not configured
50	11	not configured
50	12	not configured
50	13	not configured
50	14	not configured
50	15	not configured
50	16	not configured
50	17	not configured
50	18	not configured
50	19	not configured
50	20	not configured
50	21	not configured
50	22	not configured
50	23	not configured
50	24	not configured
50	25	not configured
50	26	not configured
50	27	not configured
50	28	not configured
50	29	not configured
50	30	not configured
50	31	not configured
50	32	not configured
50	33	not configured
50	34	not configured
50	35	not configured
50	36	not configured
50	37	not configured
50	38	not configured
50	39	not configured
50	40	not configured
50	41	not configured
50	42	not configured
50	43	not configured
50	44	not configured
50	45	not configured
50	46	not configured
50	47	not configured
50	48	not configured
50	49	not configured
50	50	not configured
50	51	not configured
50	52	not configured
50	53	not configured
50	54	not configured
50	55	not configured
50	56	not configured
50	57	not configured
50	58	not configured
50	59	not configured
50	60	not configured
50	61	not configured
50	62	not configured
50	63	not configured
50	64	not configured
50	65	not configured
50	66	not configured
50	67	not configured
50	68	not configured
50	69	not configured
50	71	not configured
50	72	not configured
50	73	not configured
50	74	not configured
50	75	not configured
50	76	not configured
50	77	not configured
50	78	not configured
50	79	not configured
50	80	not configured
50	81	not configured
50	82	not configured
50	83	not configured
50	84	not configured
50	85	not configured
50	86	not configured
50	87	not configured
50	88	not configured
50	89	not configured
50	90	not configured
50	91	not configured
50	92	not configured
50	93	not configured
50	94	not configured
50	95	not configured
50	96	not configured
50	97	not configured
50	98	not configured
50	99	not configured
50	100	not configured
50	101	not configured
50	102	not configured
50	103	not configured
50	104	not configured
50	105	not configured
50	106	not configured
50	107	not configured
50	108	not configured
50	109	not configured
50	110	not configured
50	111	not configured
50	112	not configured
50	113	not configured
50	114	not configured
50	115	not configured
50	116	not configured
50	117	not configured
50	118	not configured
50	119	not configured
50	120	not configured
50	121	not configured
50	122	not configured
50	124	not configured
50	125	not configured
50	127	not configured
50	128	not configured
50	129	not configured
50	130	not configured
50	131	not configured
50	132	not configured
50	134	not configured
50	135	not configured
50	136	not configured
50	137	not configured
50	138	not configured
51	1	not configured
51	2	not configured
51	9	not configured
51	10	not configured
51	11	not configured
51	12	not configured
51	13	not configured
51	14	not configured
51	15	not configured
51	16	not configured
51	17	not configured
51	18	not configured
51	19	not configured
51	20	not configured
51	21	not configured
51	22	not configured
51	23	not configured
51	24	not configured
51	25	not configured
51	26	not configured
51	27	not configured
51	28	not configured
51	29	not configured
51	30	not configured
51	31	not configured
51	32	not configured
51	33	not configured
51	34	not configured
51	35	not configured
51	36	not configured
51	37	not configured
51	38	not configured
51	39	not configured
51	40	not configured
51	41	not configured
51	42	not configured
51	43	not configured
51	44	not configured
51	45	not configured
51	46	not configured
51	47	not configured
51	48	not configured
51	49	not configured
51	50	not configured
51	51	not configured
51	52	not configured
51	53	not configured
51	54	not configured
51	55	not configured
51	56	not configured
51	57	not configured
51	58	not configured
51	59	not configured
51	60	not configured
51	61	not configured
51	62	not configured
51	63	not configured
51	64	not configured
51	65	not configured
51	66	not configured
51	67	not configured
51	68	not configured
51	69	not configured
51	71	not configured
51	72	not configured
51	73	not configured
51	74	not configured
51	75	not configured
51	76	not configured
51	77	not configured
51	78	not configured
51	79	not configured
51	80	not configured
51	81	not configured
51	82	not configured
51	83	not configured
51	84	not configured
51	85	not configured
51	86	not configured
51	87	not configured
51	88	not configured
51	89	not configured
51	90	not configured
51	91	not configured
51	92	not configured
51	93	not configured
51	94	not configured
51	95	not configured
51	96	not configured
51	97	not configured
51	98	not configured
51	99	not configured
51	100	not configured
51	101	not configured
51	102	not configured
51	103	not configured
51	104	not configured
51	105	not configured
51	106	not configured
51	107	not configured
51	108	not configured
51	109	not configured
51	110	not configured
51	111	not configured
51	112	not configured
51	113	not configured
51	114	not configured
51	115	not configured
51	116	not configured
51	117	not configured
51	118	not configured
51	119	not configured
51	120	not configured
51	121	not configured
51	122	not configured
51	124	not configured
51	125	not configured
51	127	not configured
51	128	not configured
51	129	not configured
51	130	not configured
51	131	not configured
51	132	not configured
51	134	not configured
51	135	not configured
51	136	not configured
51	137	not configured
51	138	not configured
52	1	not configured
52	2	not configured
52	9	not configured
52	10	not configured
52	11	not configured
52	12	not configured
52	13	not configured
52	14	not configured
52	15	not configured
52	16	not configured
52	17	not configured
52	18	not configured
52	19	not configured
52	20	not configured
52	21	not configured
52	22	not configured
52	23	not configured
52	24	not configured
52	25	not configured
52	26	not configured
52	27	not configured
52	28	not configured
52	29	not configured
52	30	not configured
52	31	not configured
52	32	not configured
52	33	not configured
52	34	not configured
52	35	not configured
52	36	not configured
52	37	not configured
52	38	not configured
52	39	not configured
52	40	not configured
52	41	not configured
52	42	not configured
52	43	not configured
52	44	not configured
52	45	not configured
52	46	not configured
52	47	not configured
52	48	not configured
52	49	not configured
52	50	not configured
52	51	not configured
52	52	not configured
52	53	not configured
52	54	not configured
52	55	not configured
52	56	not configured
52	57	not configured
52	58	not configured
52	59	not configured
52	60	not configured
52	61	not configured
52	62	not configured
52	63	not configured
52	64	not configured
52	65	not configured
52	66	not configured
52	67	not configured
52	68	not configured
52	69	not configured
52	71	not configured
52	72	not configured
52	73	not configured
52	74	not configured
52	75	not configured
52	76	not configured
52	77	not configured
52	78	not configured
52	79	not configured
52	80	not configured
52	81	not configured
52	82	not configured
52	83	not configured
52	84	not configured
52	85	not configured
52	86	not configured
52	87	not configured
52	88	not configured
52	89	not configured
52	90	not configured
52	91	not configured
52	92	not configured
52	93	not configured
52	94	not configured
52	95	not configured
52	96	not configured
52	97	not configured
52	98	not configured
52	99	not configured
52	100	not configured
52	101	not configured
52	102	not configured
52	103	not configured
52	104	not configured
52	105	not configured
52	106	not configured
52	107	not configured
52	108	not configured
52	109	not configured
52	110	not configured
52	111	not configured
52	112	not configured
52	113	not configured
52	114	not configured
52	115	not configured
52	116	not configured
52	117	not configured
52	118	not configured
52	119	not configured
52	120	not configured
52	121	not configured
52	122	not configured
52	124	not configured
52	125	not configured
52	127	not configured
52	128	not configured
52	129	not configured
52	130	not configured
52	131	not configured
52	132	not configured
52	134	not configured
52	135	not configured
52	136	not configured
52	137	not configured
52	138	not configured
53	1	not configured
53	2	not configured
53	9	not configured
53	10	not configured
53	11	not configured
53	12	not configured
53	13	not configured
53	14	not configured
53	15	not configured
53	16	not configured
53	17	not configured
53	18	not configured
53	19	not configured
53	20	not configured
53	21	not configured
53	22	not configured
53	23	not configured
53	24	not configured
53	25	not configured
53	26	not configured
53	27	not configured
53	28	not configured
53	29	not configured
53	30	not configured
53	31	not configured
53	32	not configured
53	33	not configured
53	34	not configured
53	35	not configured
53	36	not configured
53	37	not configured
53	38	not configured
53	39	not configured
53	40	not configured
53	41	not configured
53	42	not configured
53	43	not configured
53	44	not configured
53	45	not configured
53	46	not configured
53	47	not configured
53	48	not configured
53	49	not configured
53	50	not configured
53	51	not configured
53	52	not configured
53	53	not configured
53	54	not configured
53	55	not configured
53	56	not configured
53	57	not configured
53	58	not configured
53	59	not configured
53	60	not configured
53	61	not configured
53	62	not configured
53	63	not configured
53	64	not configured
53	65	not configured
53	66	not configured
53	67	not configured
53	68	not configured
53	69	not configured
53	71	not configured
53	72	not configured
53	73	not configured
53	74	not configured
53	75	not configured
53	76	not configured
53	77	not configured
53	78	not configured
53	79	not configured
53	80	not configured
53	81	not configured
53	82	not configured
53	83	not configured
53	84	not configured
53	85	not configured
53	86	not configured
53	87	not configured
53	88	not configured
53	89	not configured
53	90	not configured
53	91	not configured
53	92	not configured
53	93	not configured
53	94	not configured
53	95	not configured
53	96	not configured
53	97	not configured
53	98	not configured
53	99	not configured
53	100	not configured
53	101	not configured
53	102	not configured
53	103	not configured
53	104	not configured
53	105	not configured
53	106	not configured
53	107	not configured
53	108	not configured
53	109	not configured
53	110	not configured
53	111	not configured
53	112	not configured
53	113	not configured
53	114	not configured
53	115	not configured
53	116	not configured
53	117	not configured
53	118	not configured
53	119	not configured
53	120	not configured
53	121	not configured
53	122	not configured
53	124	not configured
53	125	not configured
53	127	not configured
53	128	not configured
53	129	not configured
53	130	not configured
53	131	not configured
53	132	not configured
53	134	not configured
53	135	not configured
53	136	not configured
53	137	not configured
53	138	not configured
54	1	not configured
54	2	not configured
54	9	not configured
54	10	not configured
54	11	not configured
54	12	not configured
54	13	not configured
54	14	not configured
54	15	not configured
54	16	not configured
54	17	not configured
54	18	not configured
54	19	not configured
54	20	not configured
54	21	not configured
54	22	not configured
54	23	not configured
54	24	not configured
54	25	not configured
54	26	not configured
54	27	not configured
54	28	not configured
54	29	not configured
54	30	not configured
54	31	not configured
54	32	not configured
54	33	not configured
54	34	not configured
54	35	not configured
54	36	not configured
54	37	not configured
54	38	not configured
54	39	not configured
54	40	not configured
54	41	not configured
54	42	not configured
54	43	not configured
54	44	not configured
54	45	not configured
54	46	not configured
54	47	not configured
54	48	not configured
54	49	not configured
54	50	not configured
54	51	not configured
54	52	not configured
54	53	not configured
54	54	not configured
54	55	not configured
54	56	not configured
54	57	not configured
54	58	not configured
54	59	not configured
54	60	not configured
54	61	not configured
54	62	not configured
54	63	not configured
54	64	not configured
54	65	not configured
54	66	not configured
54	67	not configured
54	68	not configured
54	69	not configured
54	71	not configured
54	72	not configured
54	73	not configured
54	74	not configured
54	75	not configured
54	76	not configured
54	77	not configured
54	78	not configured
54	79	not configured
54	80	not configured
54	81	not configured
54	82	not configured
54	83	not configured
54	84	not configured
54	85	not configured
54	86	not configured
54	87	not configured
54	88	not configured
54	89	not configured
54	90	not configured
54	91	not configured
54	92	not configured
54	93	not configured
54	94	not configured
54	95	not configured
54	96	not configured
54	97	not configured
54	98	not configured
54	99	not configured
54	100	not configured
54	101	not configured
54	102	not configured
54	103	not configured
54	104	not configured
54	105	not configured
54	106	not configured
54	107	not configured
54	108	not configured
54	109	not configured
54	110	not configured
54	111	not configured
54	112	not configured
54	113	not configured
54	114	not configured
54	115	not configured
54	116	not configured
54	117	not configured
54	118	not configured
54	119	not configured
54	120	not configured
54	121	not configured
54	122	not configured
54	124	not configured
54	125	not configured
54	127	not configured
54	128	not configured
54	129	not configured
54	130	not configured
54	131	not configured
54	132	not configured
54	134	not configured
54	135	not configured
54	136	not configured
54	137	not configured
54	138	not configured
55	1	not configured
55	2	not configured
55	9	not configured
55	10	not configured
55	11	not configured
55	12	not configured
55	13	not configured
55	14	not configured
55	15	not configured
55	16	not configured
55	17	not configured
55	18	not configured
55	19	not configured
55	20	not configured
55	21	not configured
55	22	not configured
55	23	not configured
55	24	not configured
55	25	not configured
55	26	not configured
55	27	not configured
55	28	not configured
55	29	not configured
55	30	not configured
55	31	not configured
55	32	not configured
55	33	not configured
55	34	not configured
55	35	not configured
55	36	not configured
55	37	not configured
55	38	not configured
55	39	not configured
55	40	not configured
55	41	not configured
55	42	not configured
55	43	not configured
55	44	not configured
55	45	not configured
55	46	not configured
55	47	not configured
55	48	not configured
55	49	not configured
55	50	not configured
55	51	not configured
55	52	not configured
55	53	not configured
55	54	not configured
55	55	not configured
55	56	not configured
55	57	not configured
55	58	not configured
55	59	not configured
55	60	not configured
55	61	not configured
55	62	not configured
55	63	not configured
55	64	not configured
55	65	not configured
55	66	not configured
55	67	not configured
55	68	not configured
55	69	not configured
55	71	not configured
55	72	not configured
55	73	not configured
55	74	not configured
55	75	not configured
55	76	not configured
55	77	not configured
55	78	not configured
55	79	not configured
55	80	not configured
55	81	not configured
55	82	not configured
55	83	not configured
55	84	not configured
55	85	not configured
55	86	not configured
55	87	not configured
55	88	not configured
55	89	not configured
55	90	not configured
55	91	not configured
55	92	not configured
55	93	not configured
55	94	not configured
55	95	not configured
55	96	not configured
55	97	not configured
55	98	not configured
55	99	not configured
55	100	not configured
55	101	not configured
55	102	not configured
55	103	not configured
55	104	not configured
55	105	not configured
55	106	not configured
55	107	not configured
55	108	not configured
55	109	not configured
55	110	not configured
55	111	not configured
55	112	not configured
55	113	not configured
55	114	not configured
55	115	not configured
55	116	not configured
55	117	not configured
55	118	not configured
55	119	not configured
55	120	not configured
55	121	not configured
55	122	not configured
55	124	not configured
55	125	not configured
55	127	not configured
55	128	not configured
55	129	not configured
55	130	not configured
55	131	not configured
55	132	not configured
55	134	not configured
55	135	not configured
55	136	not configured
55	137	not configured
55	138	not configured
56	1	not configured
56	2	not configured
56	9	not configured
56	10	not configured
56	11	not configured
56	12	not configured
56	13	not configured
56	14	not configured
56	15	not configured
56	16	not configured
56	17	not configured
56	18	not configured
56	19	not configured
56	20	not configured
56	21	not configured
56	22	not configured
56	23	not configured
56	24	not configured
56	25	not configured
56	26	not configured
56	27	not configured
56	28	not configured
56	29	not configured
56	30	not configured
56	31	not configured
56	32	not configured
56	33	not configured
56	34	not configured
56	35	not configured
56	36	not configured
56	37	not configured
56	38	not configured
56	39	not configured
56	40	not configured
56	41	not configured
56	42	not configured
56	43	not configured
56	44	not configured
56	45	not configured
56	46	not configured
56	47	not configured
56	48	not configured
56	49	not configured
56	50	not configured
56	51	not configured
56	52	not configured
56	53	not configured
56	54	not configured
56	55	not configured
56	56	not configured
56	57	not configured
56	58	not configured
56	59	not configured
56	60	not configured
56	61	not configured
56	62	not configured
56	63	not configured
56	64	not configured
56	65	not configured
56	66	not configured
56	67	not configured
56	68	not configured
56	69	not configured
56	71	not configured
56	72	not configured
56	73	not configured
56	74	not configured
56	75	not configured
56	76	not configured
56	77	not configured
56	78	not configured
56	79	not configured
56	80	not configured
56	81	not configured
56	82	not configured
56	83	not configured
56	84	not configured
56	85	not configured
56	86	not configured
56	87	not configured
56	88	not configured
56	89	not configured
56	90	not configured
56	91	not configured
56	92	not configured
56	93	not configured
56	94	not configured
56	95	not configured
56	96	not configured
56	97	not configured
56	98	not configured
56	99	not configured
56	100	not configured
56	101	not configured
56	102	not configured
56	103	not configured
56	104	not configured
56	105	not configured
56	106	not configured
56	107	not configured
56	108	not configured
56	109	not configured
56	110	not configured
56	111	not configured
56	112	not configured
56	113	not configured
56	114	not configured
56	115	not configured
56	116	not configured
56	117	not configured
56	118	not configured
56	119	not configured
56	120	not configured
56	121	not configured
56	122	not configured
56	124	not configured
56	125	not configured
56	127	not configured
56	128	not configured
56	129	not configured
56	130	not configured
56	131	not configured
56	132	not configured
56	134	not configured
56	135	not configured
56	136	not configured
56	137	not configured
56	138	not configured
57	1	not configured
57	2	not configured
57	9	not configured
57	10	not configured
57	11	not configured
57	12	not configured
57	13	not configured
57	14	not configured
57	15	not configured
57	16	not configured
57	17	not configured
57	18	not configured
57	19	not configured
57	20	not configured
57	21	not configured
57	22	not configured
57	23	not configured
57	24	not configured
57	25	not configured
57	26	not configured
57	27	not configured
57	28	not configured
57	29	not configured
57	30	not configured
57	31	not configured
57	32	not configured
57	33	not configured
57	34	not configured
57	35	not configured
57	36	not configured
57	37	not configured
57	38	not configured
57	39	not configured
57	40	not configured
57	41	not configured
57	42	not configured
57	43	not configured
57	44	not configured
57	45	not configured
57	46	not configured
57	47	not configured
57	48	not configured
57	49	not configured
57	50	not configured
57	51	not configured
57	52	not configured
57	53	not configured
57	54	not configured
57	55	not configured
57	56	not configured
57	57	not configured
57	58	not configured
57	59	not configured
57	60	not configured
57	61	not configured
57	62	not configured
57	63	not configured
57	64	not configured
57	65	not configured
57	66	not configured
57	67	not configured
57	68	not configured
57	69	not configured
57	71	not configured
57	72	not configured
57	73	not configured
57	74	not configured
57	75	not configured
57	76	not configured
57	77	not configured
57	78	not configured
57	79	not configured
57	80	not configured
57	81	not configured
57	82	not configured
57	83	not configured
57	84	not configured
57	85	not configured
57	86	not configured
57	87	not configured
57	88	not configured
57	89	not configured
57	90	not configured
57	91	not configured
57	92	not configured
57	93	not configured
57	94	not configured
57	95	not configured
57	96	not configured
57	97	not configured
57	98	not configured
57	99	not configured
57	100	not configured
57	101	not configured
57	102	not configured
57	103	not configured
57	104	not configured
57	105	not configured
57	106	not configured
57	107	not configured
57	108	not configured
57	109	not configured
57	110	not configured
57	111	not configured
57	112	not configured
57	113	not configured
57	114	not configured
57	115	not configured
57	116	not configured
57	117	not configured
57	118	not configured
57	119	not configured
57	120	not configured
57	121	not configured
57	122	not configured
57	124	not configured
57	125	not configured
57	127	not configured
57	128	not configured
57	129	not configured
57	130	not configured
57	131	not configured
57	132	not configured
57	134	not configured
57	135	not configured
57	136	not configured
57	137	not configured
57	138	not configured
58	1	not configured
58	2	not configured
58	9	not configured
58	10	not configured
58	11	not configured
58	12	not configured
58	13	not configured
58	14	not configured
58	15	not configured
58	16	not configured
58	17	not configured
58	18	not configured
58	19	not configured
58	20	not configured
58	21	not configured
58	22	not configured
58	23	not configured
58	24	not configured
58	25	not configured
58	26	not configured
58	27	not configured
58	28	not configured
58	29	not configured
58	30	not configured
58	31	not configured
58	32	not configured
58	33	not configured
58	34	not configured
58	35	not configured
58	36	not configured
58	37	not configured
58	38	not configured
58	39	not configured
58	40	not configured
58	41	not configured
58	42	not configured
58	43	not configured
58	44	not configured
58	45	not configured
58	46	not configured
58	47	not configured
58	48	not configured
58	49	not configured
58	50	not configured
58	51	not configured
58	52	not configured
58	53	not configured
58	54	not configured
58	55	not configured
58	56	not configured
58	57	not configured
58	58	not configured
58	59	not configured
58	60	not configured
58	61	not configured
58	62	not configured
58	63	not configured
58	64	not configured
58	65	not configured
58	66	not configured
58	67	not configured
58	68	not configured
58	69	not configured
58	71	not configured
58	72	not configured
58	73	not configured
58	74	not configured
58	75	not configured
58	76	not configured
58	77	not configured
58	78	not configured
58	79	not configured
58	80	not configured
58	81	not configured
58	82	not configured
58	83	not configured
58	84	not configured
58	85	not configured
58	86	not configured
58	87	not configured
58	88	not configured
58	89	not configured
58	90	not configured
58	91	not configured
58	92	not configured
58	93	not configured
58	94	not configured
58	95	not configured
58	96	not configured
58	97	not configured
58	98	not configured
58	99	not configured
58	100	not configured
58	101	not configured
58	102	not configured
58	103	not configured
58	104	not configured
58	105	not configured
58	106	not configured
58	107	not configured
58	108	not configured
58	109	not configured
58	110	not configured
58	111	not configured
58	112	not configured
58	113	not configured
58	114	not configured
58	115	not configured
58	116	not configured
58	117	not configured
58	118	not configured
58	119	not configured
58	120	not configured
58	121	not configured
58	122	not configured
58	124	not configured
58	125	not configured
58	127	not configured
58	128	not configured
58	129	not configured
58	130	not configured
58	131	not configured
58	132	not configured
58	134	not configured
58	135	not configured
58	136	not configured
58	137	not configured
58	138	not configured
59	1	not configured
59	2	not configured
59	9	not configured
59	10	not configured
59	11	not configured
59	12	not configured
59	13	not configured
59	14	not configured
59	15	not configured
59	16	not configured
59	17	not configured
59	18	not configured
59	19	not configured
59	20	not configured
59	21	not configured
59	22	not configured
59	23	not configured
59	24	not configured
59	25	not configured
59	26	not configured
59	27	not configured
59	28	not configured
59	29	not configured
59	30	not configured
59	31	not configured
59	32	not configured
59	33	not configured
59	34	not configured
59	35	not configured
59	36	not configured
59	37	not configured
59	38	not configured
59	39	not configured
59	40	not configured
59	41	not configured
59	42	not configured
59	43	not configured
59	44	not configured
59	45	not configured
59	46	not configured
59	47	not configured
59	48	not configured
59	49	not configured
59	50	not configured
59	51	not configured
59	52	not configured
59	53	not configured
59	54	not configured
59	55	not configured
59	56	not configured
59	57	not configured
59	58	not configured
59	59	not configured
59	60	not configured
59	61	not configured
59	62	not configured
59	63	not configured
59	64	not configured
59	65	not configured
59	66	not configured
59	67	not configured
59	68	not configured
59	69	not configured
59	71	not configured
59	72	not configured
59	73	not configured
59	74	not configured
59	75	not configured
59	76	not configured
59	77	not configured
59	78	not configured
59	79	not configured
59	80	not configured
59	81	not configured
59	82	not configured
59	83	not configured
59	84	not configured
59	85	not configured
59	86	not configured
59	87	not configured
59	88	not configured
59	89	not configured
59	90	not configured
59	91	not configured
59	92	not configured
59	93	not configured
59	94	not configured
59	95	not configured
59	96	not configured
59	97	not configured
59	98	not configured
59	99	not configured
59	100	not configured
59	101	not configured
59	102	not configured
59	103	not configured
59	104	not configured
59	105	not configured
59	106	not configured
59	107	not configured
59	108	not configured
59	109	not configured
59	110	not configured
59	111	not configured
59	112	not configured
59	113	not configured
59	114	not configured
59	115	not configured
59	116	not configured
59	117	not configured
59	118	not configured
59	119	not configured
59	120	not configured
59	121	not configured
59	122	not configured
59	124	not configured
59	125	not configured
59	127	not configured
59	128	not configured
59	129	not configured
59	130	not configured
59	131	not configured
59	132	not configured
59	134	not configured
59	135	not configured
59	136	not configured
59	137	not configured
59	138	not configured
60	1	not configured
60	2	not configured
60	9	not configured
60	10	not configured
60	11	not configured
60	12	not configured
60	13	not configured
60	14	not configured
60	15	not configured
60	16	not configured
60	17	not configured
60	18	not configured
60	19	not configured
60	20	not configured
60	21	not configured
60	22	not configured
60	23	not configured
60	24	not configured
60	25	not configured
60	26	not configured
60	27	not configured
60	28	not configured
60	29	not configured
60	30	not configured
60	31	not configured
60	32	not configured
60	33	not configured
60	34	not configured
60	35	not configured
60	36	not configured
60	37	not configured
60	38	not configured
60	39	not configured
60	40	not configured
60	41	not configured
60	42	not configured
60	43	not configured
60	44	not configured
60	45	not configured
60	46	not configured
60	47	not configured
60	48	not configured
60	49	not configured
60	50	not configured
60	51	not configured
60	52	not configured
60	53	not configured
60	54	not configured
60	55	not configured
60	56	not configured
60	57	not configured
60	58	not configured
60	59	not configured
60	60	not configured
60	61	not configured
60	62	not configured
60	63	not configured
60	64	not configured
60	65	not configured
60	66	not configured
60	67	not configured
60	68	not configured
60	69	not configured
60	71	not configured
60	72	not configured
60	73	not configured
60	74	not configured
60	75	not configured
60	76	not configured
60	77	not configured
60	78	not configured
60	79	not configured
60	80	not configured
60	81	not configured
60	82	not configured
60	83	not configured
60	84	not configured
60	85	not configured
60	86	not configured
60	87	not configured
60	88	not configured
60	89	not configured
60	90	not configured
60	91	not configured
60	92	not configured
60	93	not configured
60	94	not configured
60	95	not configured
60	96	not configured
60	97	not configured
60	98	not configured
60	99	not configured
60	100	not configured
60	101	not configured
60	102	not configured
60	103	not configured
60	104	not configured
60	105	not configured
60	106	not configured
60	107	not configured
60	108	not configured
60	109	not configured
60	110	not configured
60	111	not configured
60	112	not configured
60	113	not configured
60	114	not configured
60	115	not configured
60	116	not configured
60	117	not configured
60	118	not configured
60	119	not configured
60	120	not configured
60	121	not configured
60	122	not configured
60	124	not configured
60	125	not configured
60	127	not configured
60	128	not configured
60	129	not configured
60	130	not configured
60	131	not configured
60	132	not configured
60	134	not configured
60	135	not configured
60	136	not configured
60	137	not configured
60	138	not configured
61	1	not configured
61	2	not configured
61	9	not configured
61	10	not configured
61	11	not configured
61	12	not configured
61	13	not configured
61	14	not configured
61	15	not configured
61	16	not configured
61	17	not configured
61	18	not configured
61	19	not configured
61	20	not configured
61	21	not configured
61	22	not configured
61	23	not configured
61	24	not configured
61	25	not configured
61	26	not configured
61	27	not configured
61	28	not configured
61	29	not configured
61	30	not configured
61	31	not configured
61	32	not configured
61	33	not configured
61	34	not configured
61	35	not configured
61	36	not configured
61	37	not configured
61	38	not configured
61	39	not configured
61	40	not configured
61	41	not configured
61	42	not configured
61	43	not configured
61	44	not configured
61	45	not configured
61	46	not configured
61	47	not configured
61	48	not configured
61	49	not configured
61	50	not configured
61	51	not configured
61	52	not configured
61	53	not configured
61	54	not configured
61	55	not configured
61	56	not configured
61	57	not configured
61	58	not configured
61	59	not configured
61	60	not configured
61	61	not configured
61	62	not configured
61	63	not configured
61	64	not configured
61	65	not configured
61	66	not configured
61	67	not configured
61	68	not configured
61	69	not configured
61	71	not configured
61	72	not configured
61	73	not configured
61	74	not configured
61	75	not configured
61	76	not configured
61	77	not configured
61	78	not configured
61	79	not configured
61	80	not configured
61	81	not configured
61	82	not configured
61	83	not configured
61	84	not configured
61	85	not configured
61	86	not configured
61	87	not configured
61	88	not configured
61	89	not configured
61	90	not configured
61	91	not configured
61	92	not configured
61	93	not configured
61	94	not configured
61	95	not configured
61	96	not configured
61	97	not configured
61	98	not configured
61	99	not configured
61	100	not configured
61	101	not configured
61	102	not configured
61	103	not configured
61	104	not configured
61	105	not configured
61	106	not configured
61	107	not configured
61	108	not configured
61	109	not configured
61	110	not configured
61	111	not configured
61	112	not configured
61	113	not configured
61	114	not configured
61	115	not configured
61	116	not configured
61	117	not configured
61	118	not configured
61	119	not configured
61	120	not configured
61	121	not configured
61	122	not configured
61	124	not configured
61	125	not configured
61	127	not configured
61	128	not configured
61	129	not configured
61	130	not configured
61	131	not configured
61	132	not configured
61	134	not configured
61	135	not configured
61	136	not configured
61	137	not configured
61	138	not configured
62	1	not configured
62	2	not configured
62	9	not configured
62	10	not configured
62	11	not configured
62	12	not configured
62	13	not configured
62	14	not configured
62	15	not configured
62	16	not configured
62	17	not configured
62	18	not configured
62	19	not configured
62	20	not configured
62	21	not configured
62	22	not configured
62	23	not configured
62	24	not configured
62	25	not configured
62	26	not configured
62	27	not configured
62	28	not configured
62	29	not configured
62	30	not configured
62	31	not configured
62	32	not configured
62	33	not configured
62	34	not configured
62	35	not configured
62	36	not configured
62	37	not configured
62	38	not configured
62	39	not configured
62	40	not configured
62	41	not configured
62	42	not configured
62	43	not configured
62	44	not configured
62	45	not configured
62	46	not configured
62	47	not configured
62	48	not configured
62	49	not configured
62	50	not configured
62	51	not configured
62	52	not configured
62	53	not configured
62	54	not configured
62	55	not configured
62	56	not configured
62	57	not configured
62	58	not configured
62	59	not configured
62	60	not configured
62	61	not configured
62	62	not configured
62	63	not configured
62	64	not configured
62	65	not configured
62	66	not configured
62	67	not configured
62	68	not configured
62	69	not configured
62	71	not configured
62	72	not configured
62	73	not configured
62	74	not configured
62	75	not configured
62	76	not configured
62	77	not configured
62	78	not configured
62	79	not configured
62	80	not configured
62	81	not configured
62	82	not configured
62	83	not configured
62	84	not configured
62	85	not configured
62	86	not configured
62	87	not configured
62	88	not configured
62	89	not configured
62	90	not configured
62	91	not configured
62	92	not configured
62	93	not configured
62	94	not configured
62	95	not configured
62	96	not configured
62	97	not configured
62	98	not configured
62	99	not configured
62	100	not configured
62	101	not configured
62	102	not configured
62	103	not configured
62	104	not configured
62	105	not configured
62	106	not configured
62	107	not configured
62	108	not configured
62	109	not configured
62	110	not configured
62	111	not configured
62	112	not configured
62	113	not configured
62	114	not configured
62	115	not configured
62	116	not configured
62	117	not configured
62	118	not configured
62	119	not configured
62	120	not configured
62	121	not configured
62	122	not configured
62	124	not configured
62	125	not configured
62	127	not configured
62	128	not configured
62	129	not configured
62	130	not configured
62	131	not configured
62	132	not configured
62	134	not configured
62	135	not configured
62	136	not configured
62	137	not configured
62	138	not configured
63	1	not configured
63	2	not configured
63	9	not configured
63	10	not configured
63	11	not configured
63	12	not configured
63	13	not configured
63	14	not configured
63	15	not configured
63	16	not configured
63	17	not configured
63	18	not configured
63	19	not configured
63	20	not configured
63	21	not configured
63	22	not configured
63	23	not configured
63	24	not configured
63	25	not configured
63	26	not configured
63	27	not configured
63	28	not configured
63	29	not configured
63	30	not configured
63	31	not configured
63	32	not configured
63	33	not configured
63	34	not configured
63	35	not configured
63	36	not configured
63	37	not configured
63	38	not configured
63	39	not configured
63	40	not configured
63	41	not configured
63	42	not configured
63	43	not configured
63	44	not configured
63	45	not configured
63	46	not configured
63	47	not configured
63	48	not configured
63	49	not configured
63	50	not configured
63	51	not configured
63	52	not configured
63	53	not configured
63	54	not configured
63	55	not configured
63	56	not configured
63	57	not configured
63	58	not configured
63	59	not configured
63	60	not configured
63	61	not configured
63	62	not configured
63	63	not configured
63	64	not configured
63	65	not configured
63	66	not configured
63	67	not configured
63	68	not configured
63	69	not configured
63	71	not configured
63	72	not configured
63	73	not configured
63	74	not configured
63	75	not configured
63	76	not configured
63	77	not configured
63	78	not configured
63	79	not configured
63	80	not configured
63	81	not configured
63	82	not configured
63	83	not configured
63	84	not configured
63	85	not configured
63	86	not configured
63	87	not configured
63	88	not configured
63	89	not configured
63	90	not configured
63	91	not configured
63	92	not configured
63	93	not configured
63	94	not configured
63	95	not configured
63	96	not configured
63	97	not configured
63	98	not configured
63	99	not configured
63	100	not configured
63	101	not configured
63	102	not configured
63	103	not configured
63	104	not configured
63	105	not configured
63	106	not configured
63	107	not configured
63	108	not configured
63	109	not configured
63	110	not configured
63	111	not configured
63	112	not configured
63	113	not configured
63	114	not configured
63	115	not configured
63	116	not configured
63	117	not configured
63	118	not configured
63	119	not configured
63	120	not configured
63	121	not configured
63	122	not configured
63	124	not configured
63	125	not configured
63	127	not configured
63	128	not configured
63	129	not configured
63	130	not configured
63	131	not configured
63	132	not configured
63	134	not configured
63	135	not configured
63	136	not configured
63	137	not configured
63	138	not configured
64	1	not configured
64	2	not configured
64	9	not configured
64	10	not configured
64	11	not configured
64	12	not configured
64	13	not configured
64	14	not configured
64	15	not configured
64	16	not configured
64	17	not configured
64	18	not configured
64	19	not configured
64	20	not configured
64	21	not configured
64	22	not configured
64	23	not configured
64	24	not configured
64	25	not configured
64	26	not configured
64	27	not configured
64	28	not configured
64	29	not configured
64	30	not configured
64	31	not configured
64	32	not configured
64	33	not configured
64	34	not configured
64	35	not configured
64	36	not configured
64	37	not configured
64	38	not configured
64	39	not configured
64	40	not configured
64	41	not configured
64	42	not configured
64	43	not configured
64	44	not configured
64	45	not configured
64	46	not configured
64	47	not configured
64	48	not configured
64	49	not configured
64	50	not configured
64	51	not configured
64	52	not configured
64	53	not configured
64	54	not configured
64	55	not configured
64	56	not configured
64	57	not configured
64	58	not configured
64	59	not configured
64	60	not configured
64	61	not configured
64	62	not configured
64	63	not configured
64	64	not configured
64	65	not configured
64	66	not configured
64	67	not configured
64	68	not configured
64	69	not configured
64	71	not configured
64	72	not configured
64	73	not configured
64	74	not configured
64	75	not configured
64	76	not configured
64	77	not configured
64	78	not configured
64	79	not configured
64	80	not configured
64	81	not configured
64	82	not configured
64	83	not configured
64	84	not configured
64	85	not configured
64	86	not configured
64	87	not configured
64	88	not configured
64	89	not configured
64	90	not configured
64	91	not configured
64	92	not configured
64	93	not configured
64	94	not configured
64	95	not configured
64	96	not configured
64	97	not configured
64	98	not configured
64	99	not configured
64	100	not configured
64	101	not configured
64	102	not configured
64	103	not configured
64	104	not configured
64	105	not configured
64	106	not configured
64	107	not configured
64	108	not configured
64	109	not configured
64	110	not configured
64	111	not configured
64	112	not configured
64	113	not configured
64	114	not configured
64	115	not configured
64	116	not configured
64	117	not configured
64	118	not configured
64	119	not configured
64	120	not configured
64	121	not configured
64	122	not configured
64	124	not configured
64	125	not configured
64	127	not configured
64	128	not configured
64	129	not configured
64	130	not configured
64	131	not configured
64	132	not configured
64	134	not configured
64	135	not configured
64	136	not configured
64	137	not configured
64	138	not configured
65	1	not configured
65	2	not configured
65	9	not configured
65	10	not configured
65	11	not configured
65	12	not configured
65	13	not configured
65	14	not configured
65	15	not configured
65	16	not configured
65	17	not configured
65	18	not configured
65	19	not configured
65	20	not configured
65	21	not configured
65	22	not configured
65	23	not configured
65	24	not configured
65	25	not configured
65	26	not configured
65	27	not configured
65	28	not configured
65	29	not configured
65	30	not configured
65	31	not configured
65	32	not configured
65	33	not configured
65	34	not configured
65	35	not configured
65	36	not configured
65	37	not configured
65	38	not configured
65	39	not configured
65	40	not configured
65	41	not configured
65	42	not configured
65	43	not configured
65	44	not configured
65	45	not configured
65	46	not configured
65	47	not configured
65	48	not configured
65	49	not configured
65	50	not configured
65	51	not configured
65	52	not configured
65	53	not configured
65	54	not configured
65	55	not configured
65	56	not configured
65	57	not configured
65	58	not configured
65	59	not configured
65	60	not configured
65	61	not configured
65	62	not configured
65	63	not configured
65	64	not configured
65	65	not configured
65	66	not configured
65	67	not configured
65	68	not configured
65	69	not configured
65	71	not configured
65	72	not configured
65	73	not configured
65	74	not configured
65	75	not configured
65	76	not configured
65	77	not configured
65	78	not configured
65	79	not configured
65	80	not configured
65	81	not configured
65	82	not configured
65	83	not configured
65	84	not configured
65	85	not configured
65	86	not configured
65	87	not configured
65	88	not configured
65	89	not configured
65	90	not configured
65	91	not configured
65	92	not configured
65	93	not configured
65	94	not configured
65	95	not configured
65	96	not configured
65	97	not configured
65	98	not configured
65	99	not configured
65	100	not configured
65	101	not configured
65	102	not configured
65	103	not configured
65	104	not configured
65	105	not configured
65	106	not configured
65	107	not configured
65	108	not configured
65	109	not configured
65	110	not configured
65	111	not configured
65	112	not configured
65	113	not configured
65	114	not configured
65	115	not configured
65	116	not configured
65	117	not configured
65	118	not configured
65	119	not configured
65	120	not configured
65	121	not configured
65	122	not configured
65	124	not configured
65	125	not configured
65	127	not configured
65	128	not configured
65	129	not configured
65	130	not configured
65	131	not configured
65	132	not configured
65	134	not configured
65	135	not configured
65	136	not configured
65	137	not configured
65	138	not configured
66	1	not configured
66	2	not configured
66	9	not configured
66	10	not configured
66	11	not configured
66	12	not configured
66	13	not configured
66	14	not configured
66	15	not configured
66	16	not configured
66	17	not configured
66	18	not configured
66	19	not configured
66	20	not configured
66	21	not configured
66	22	not configured
66	23	not configured
66	24	not configured
66	25	not configured
66	26	not configured
66	27	not configured
66	28	not configured
66	29	not configured
66	30	not configured
66	31	not configured
66	32	not configured
66	33	not configured
66	34	not configured
66	35	not configured
66	36	not configured
66	37	not configured
66	38	not configured
66	39	not configured
66	40	not configured
66	41	not configured
66	42	not configured
66	43	not configured
66	44	not configured
66	45	not configured
66	46	not configured
66	47	not configured
66	48	not configured
66	49	not configured
66	50	not configured
66	51	not configured
66	52	not configured
66	53	not configured
66	54	not configured
66	55	not configured
66	56	not configured
66	57	not configured
66	58	not configured
66	59	not configured
66	60	not configured
66	61	not configured
66	62	not configured
66	63	not configured
66	64	not configured
66	65	not configured
66	66	not configured
66	67	not configured
66	68	not configured
66	69	not configured
66	71	not configured
66	72	not configured
66	73	not configured
66	74	not configured
66	75	not configured
66	76	not configured
66	77	not configured
66	78	not configured
66	79	not configured
66	80	not configured
66	81	not configured
66	82	not configured
66	83	not configured
66	84	not configured
66	85	not configured
66	86	not configured
66	87	not configured
66	88	not configured
66	89	not configured
66	90	not configured
66	91	not configured
66	92	not configured
66	93	not configured
66	94	not configured
66	95	not configured
66	96	not configured
66	97	not configured
66	98	not configured
66	99	not configured
66	100	not configured
66	101	not configured
66	102	not configured
66	103	not configured
66	104	not configured
66	105	not configured
66	106	not configured
66	107	not configured
66	108	not configured
66	109	not configured
66	110	not configured
66	111	not configured
66	112	not configured
66	113	not configured
66	114	not configured
66	115	not configured
66	116	not configured
66	117	not configured
66	118	not configured
66	119	not configured
66	120	not configured
66	121	not configured
66	122	not configured
66	124	not configured
66	125	not configured
66	127	not configured
66	128	not configured
66	129	not configured
66	130	not configured
66	131	not configured
66	132	not configured
66	134	not configured
66	135	not configured
66	136	not configured
66	137	not configured
66	138	not configured
67	1	not configured
67	2	not configured
67	9	not configured
67	10	not configured
67	11	not configured
67	12	not configured
67	13	not configured
67	14	not configured
67	15	not configured
67	16	not configured
67	17	not configured
67	18	not configured
67	19	not configured
67	20	not configured
67	21	not configured
67	22	not configured
67	23	not configured
67	24	not configured
67	25	not configured
67	26	not configured
67	27	not configured
67	28	not configured
67	29	not configured
67	30	not configured
67	31	not configured
67	32	not configured
67	33	not configured
67	34	not configured
67	35	not configured
67	36	not configured
67	37	not configured
67	38	not configured
67	39	not configured
67	40	not configured
67	41	not configured
67	42	not configured
67	43	not configured
67	44	not configured
67	45	not configured
67	46	not configured
67	47	not configured
67	48	not configured
67	49	not configured
67	50	not configured
67	51	not configured
67	52	not configured
67	53	not configured
67	54	not configured
67	55	not configured
67	56	not configured
67	57	not configured
67	58	not configured
67	59	not configured
67	60	not configured
67	61	not configured
67	62	not configured
67	63	not configured
67	64	not configured
67	65	not configured
67	66	not configured
67	67	not configured
67	68	not configured
67	69	not configured
67	71	not configured
67	72	not configured
67	73	not configured
67	74	not configured
67	75	not configured
67	76	not configured
67	77	not configured
67	78	not configured
67	79	not configured
67	80	not configured
67	81	not configured
67	82	not configured
67	83	not configured
67	84	not configured
67	85	not configured
67	86	not configured
67	87	not configured
67	88	not configured
67	89	not configured
67	90	not configured
67	91	not configured
67	92	not configured
67	93	not configured
67	94	not configured
67	95	not configured
67	96	not configured
67	97	not configured
67	98	not configured
67	99	not configured
67	100	not configured
67	101	not configured
67	102	not configured
67	103	not configured
67	104	not configured
67	105	not configured
67	106	not configured
67	107	not configured
67	108	not configured
67	109	not configured
67	110	not configured
67	111	not configured
67	112	not configured
67	113	not configured
67	114	not configured
67	115	not configured
67	116	not configured
67	117	not configured
67	118	not configured
67	119	not configured
67	120	not configured
67	121	not configured
67	122	not configured
67	124	not configured
67	125	not configured
67	127	not configured
67	128	not configured
67	129	not configured
67	130	not configured
67	131	not configured
67	132	not configured
67	134	not configured
67	135	not configured
67	136	not configured
67	137	not configured
67	138	not configured
68	1	not configured
68	2	not configured
68	9	not configured
68	10	not configured
68	11	not configured
68	12	not configured
68	13	not configured
68	14	not configured
68	15	not configured
68	16	not configured
68	17	not configured
68	18	not configured
68	19	not configured
68	20	not configured
68	21	not configured
68	22	not configured
68	23	not configured
68	24	not configured
68	25	not configured
68	26	not configured
68	27	not configured
68	28	not configured
68	29	not configured
68	30	not configured
68	31	not configured
68	32	not configured
68	33	not configured
68	34	not configured
68	35	not configured
68	36	not configured
68	37	not configured
68	38	not configured
68	39	not configured
68	40	not configured
68	41	not configured
68	42	not configured
68	43	not configured
68	44	not configured
68	45	not configured
68	46	not configured
68	47	not configured
68	48	not configured
68	49	not configured
68	50	not configured
68	51	not configured
68	52	not configured
68	53	not configured
68	54	not configured
68	55	not configured
68	56	not configured
68	57	not configured
68	58	not configured
68	59	not configured
68	60	not configured
68	61	not configured
68	62	not configured
68	63	not configured
68	64	not configured
68	65	not configured
68	66	not configured
68	67	not configured
68	68	not configured
68	69	not configured
68	71	not configured
68	72	not configured
68	73	not configured
68	74	not configured
68	75	not configured
68	76	not configured
68	77	not configured
68	78	not configured
68	79	not configured
68	80	not configured
68	81	not configured
68	82	not configured
68	83	not configured
68	84	not configured
68	85	not configured
68	86	not configured
68	87	not configured
68	88	not configured
68	89	not configured
68	90	not configured
68	91	not configured
68	92	not configured
68	93	not configured
68	94	not configured
68	95	not configured
68	96	not configured
68	97	not configured
68	98	not configured
68	99	not configured
68	100	not configured
68	101	not configured
68	102	not configured
68	103	not configured
68	104	not configured
68	105	not configured
68	106	not configured
68	107	not configured
68	108	not configured
68	109	not configured
68	110	not configured
68	111	not configured
68	112	not configured
68	113	not configured
68	114	not configured
68	115	not configured
68	116	not configured
68	117	not configured
68	118	not configured
68	119	not configured
68	120	not configured
68	121	not configured
68	122	not configured
68	124	not configured
68	125	not configured
68	127	not configured
68	128	not configured
68	129	not configured
68	130	not configured
68	131	not configured
68	132	not configured
68	134	not configured
68	135	not configured
68	136	not configured
68	137	not configured
68	138	not configured
69	1	not configured
69	2	not configured
69	9	not configured
69	10	not configured
69	11	not configured
69	12	not configured
69	13	not configured
69	14	not configured
69	15	not configured
69	16	not configured
69	17	not configured
69	18	not configured
69	19	not configured
69	20	not configured
69	21	not configured
69	22	not configured
69	23	not configured
69	24	not configured
69	25	not configured
69	26	not configured
69	27	not configured
69	28	not configured
69	29	not configured
69	30	not configured
69	31	not configured
69	32	not configured
69	33	not configured
69	34	not configured
69	35	not configured
69	36	not configured
69	37	not configured
69	38	not configured
69	39	not configured
69	40	not configured
69	41	not configured
69	42	not configured
69	43	not configured
69	44	not configured
69	45	not configured
69	46	not configured
69	47	not configured
69	48	not configured
69	49	not configured
69	50	not configured
69	51	not configured
69	52	not configured
69	53	not configured
69	54	not configured
69	55	not configured
69	56	not configured
69	57	not configured
69	58	not configured
69	59	not configured
69	60	not configured
69	61	not configured
69	62	not configured
69	63	not configured
69	64	not configured
69	65	not configured
69	66	not configured
69	67	not configured
69	68	not configured
69	69	not configured
69	71	not configured
69	72	not configured
69	73	not configured
69	74	not configured
69	75	not configured
69	76	not configured
69	77	not configured
69	78	not configured
69	79	not configured
69	80	not configured
69	81	not configured
69	82	not configured
69	83	not configured
69	84	not configured
69	85	not configured
69	86	not configured
69	87	not configured
69	88	not configured
69	89	not configured
69	90	not configured
69	91	not configured
69	92	not configured
69	93	not configured
69	94	not configured
69	95	not configured
69	96	not configured
69	97	not configured
69	98	not configured
69	99	not configured
69	100	not configured
69	101	not configured
69	102	not configured
69	103	not configured
69	104	not configured
69	105	not configured
69	106	not configured
69	107	not configured
69	108	not configured
69	109	not configured
69	110	not configured
69	111	not configured
69	112	not configured
69	113	not configured
69	114	not configured
69	115	not configured
69	116	not configured
69	117	not configured
69	118	not configured
69	119	not configured
69	120	not configured
69	121	not configured
69	122	not configured
69	124	not configured
69	125	not configured
69	127	not configured
69	128	not configured
69	129	not configured
69	130	not configured
69	131	not configured
69	132	not configured
69	134	not configured
69	135	not configured
69	136	not configured
69	137	not configured
69	138	not configured
71	1	not configured
71	2	not configured
71	9	not configured
71	10	not configured
71	11	not configured
71	12	not configured
71	13	not configured
71	14	not configured
71	15	not configured
71	16	not configured
71	17	not configured
71	18	not configured
71	19	not configured
71	20	not configured
71	21	not configured
71	22	not configured
71	23	not configured
71	24	not configured
71	25	not configured
71	26	not configured
71	27	not configured
71	28	not configured
71	29	not configured
71	30	not configured
71	31	not configured
71	32	not configured
71	33	not configured
71	34	not configured
71	35	not configured
71	36	not configured
71	37	not configured
71	38	not configured
71	39	not configured
71	40	not configured
71	41	not configured
71	42	not configured
71	43	not configured
71	44	not configured
71	45	not configured
71	46	not configured
71	47	not configured
71	48	not configured
71	49	not configured
71	50	not configured
71	51	not configured
71	52	not configured
71	53	not configured
71	54	not configured
71	55	not configured
71	56	not configured
71	57	not configured
71	58	not configured
71	59	not configured
71	60	not configured
71	61	not configured
71	62	not configured
71	63	not configured
71	64	not configured
71	65	not configured
71	66	not configured
71	67	not configured
71	68	not configured
71	69	not configured
71	71	not configured
71	72	not configured
71	73	not configured
71	74	not configured
71	75	not configured
71	76	not configured
71	77	not configured
71	78	not configured
71	79	not configured
71	80	not configured
71	81	not configured
71	82	not configured
71	83	not configured
71	84	not configured
71	85	not configured
71	86	not configured
71	87	not configured
71	88	not configured
71	89	not configured
71	90	not configured
71	91	not configured
71	92	not configured
71	93	not configured
71	94	not configured
71	95	not configured
71	96	not configured
71	97	not configured
71	98	not configured
71	99	not configured
71	100	not configured
71	101	not configured
71	102	not configured
71	103	not configured
71	104	not configured
71	105	not configured
71	106	not configured
71	107	not configured
71	108	not configured
71	109	not configured
71	110	not configured
71	111	not configured
71	112	not configured
71	113	not configured
71	114	not configured
71	115	not configured
71	116	not configured
71	117	not configured
71	118	not configured
71	119	not configured
71	120	not configured
71	121	not configured
71	122	not configured
71	124	not configured
71	125	not configured
71	127	not configured
71	128	not configured
71	129	not configured
71	130	not configured
71	131	not configured
71	132	not configured
71	134	not configured
71	135	not configured
71	136	not configured
71	137	not configured
71	138	not configured
72	1	not configured
72	2	not configured
72	9	not configured
72	10	not configured
72	11	not configured
72	12	not configured
72	13	not configured
72	14	not configured
72	15	not configured
72	16	not configured
72	17	not configured
72	18	not configured
72	19	not configured
72	20	not configured
72	21	not configured
72	22	not configured
72	23	not configured
72	24	not configured
72	25	not configured
72	26	not configured
72	27	not configured
72	28	not configured
72	29	not configured
72	30	not configured
72	31	not configured
72	32	not configured
72	33	not configured
72	34	not configured
72	35	not configured
72	36	not configured
72	37	not configured
72	38	not configured
72	39	not configured
72	40	not configured
72	41	not configured
72	42	not configured
72	43	not configured
72	44	not configured
72	45	not configured
72	46	not configured
72	47	not configured
72	48	not configured
72	49	not configured
72	50	not configured
72	51	not configured
72	52	not configured
72	53	not configured
72	54	not configured
72	55	not configured
72	56	not configured
72	57	not configured
72	58	not configured
72	59	not configured
72	60	not configured
72	61	not configured
72	62	not configured
72	63	not configured
72	64	not configured
72	65	not configured
72	66	not configured
72	67	not configured
72	68	not configured
72	69	not configured
72	71	not configured
72	72	not configured
72	73	not configured
72	74	not configured
72	75	not configured
72	76	not configured
72	77	not configured
72	78	not configured
72	79	not configured
72	80	not configured
72	81	not configured
72	82	not configured
72	83	not configured
72	84	not configured
72	85	not configured
72	86	not configured
72	87	not configured
72	88	not configured
72	89	not configured
72	90	not configured
72	91	not configured
72	92	not configured
72	93	not configured
72	94	not configured
72	95	not configured
72	96	not configured
72	97	not configured
72	98	not configured
72	99	not configured
72	100	not configured
72	101	not configured
72	102	not configured
72	103	not configured
72	104	not configured
72	105	not configured
72	106	not configured
72	107	not configured
72	108	not configured
72	109	not configured
72	110	not configured
72	111	not configured
72	112	not configured
72	113	not configured
72	114	not configured
72	115	not configured
72	116	not configured
72	117	not configured
72	118	not configured
72	119	not configured
72	120	not configured
72	121	not configured
72	122	not configured
72	124	not configured
72	125	not configured
72	127	not configured
72	128	not configured
72	129	not configured
72	130	not configured
72	131	not configured
72	132	not configured
72	134	not configured
72	135	not configured
72	136	not configured
72	137	not configured
72	138	not configured
73	1	not configured
73	2	not configured
73	9	not configured
73	10	not configured
73	11	not configured
73	12	not configured
73	13	not configured
73	14	not configured
73	15	not configured
73	16	not configured
73	17	not configured
73	18	not configured
73	19	not configured
73	20	not configured
73	21	not configured
73	22	not configured
73	23	not configured
73	24	not configured
73	25	not configured
73	26	not configured
73	27	not configured
73	28	not configured
73	29	not configured
73	30	not configured
73	31	not configured
73	32	not configured
73	33	not configured
73	34	not configured
73	35	not configured
73	36	not configured
73	37	not configured
73	38	not configured
73	39	not configured
73	40	not configured
73	41	not configured
73	42	not configured
73	43	not configured
73	44	not configured
73	45	not configured
73	46	not configured
73	47	not configured
73	48	not configured
73	49	not configured
73	50	not configured
73	51	not configured
73	52	not configured
73	53	not configured
73	54	not configured
73	55	not configured
73	56	not configured
73	57	not configured
73	58	not configured
73	59	not configured
73	60	not configured
73	61	not configured
73	62	not configured
73	63	not configured
73	64	not configured
73	65	not configured
73	66	not configured
73	67	not configured
73	68	not configured
73	69	not configured
73	71	not configured
73	72	not configured
73	73	not configured
73	74	not configured
73	75	not configured
73	76	not configured
73	77	not configured
73	78	not configured
73	79	not configured
73	80	not configured
73	81	not configured
73	82	not configured
73	83	not configured
73	84	not configured
73	85	not configured
73	86	not configured
73	87	not configured
73	88	not configured
73	89	not configured
73	90	not configured
73	91	not configured
73	92	not configured
73	93	not configured
73	94	not configured
73	95	not configured
73	96	not configured
73	97	not configured
73	98	not configured
73	99	not configured
73	100	not configured
73	101	not configured
73	102	not configured
73	103	not configured
73	104	not configured
73	105	not configured
73	106	not configured
73	107	not configured
73	108	not configured
73	109	not configured
73	110	not configured
73	111	not configured
73	112	not configured
73	113	not configured
73	114	not configured
73	115	not configured
73	116	not configured
73	117	not configured
73	118	not configured
73	119	not configured
73	120	not configured
73	121	not configured
73	122	not configured
73	124	not configured
73	125	not configured
73	127	not configured
73	128	not configured
73	129	not configured
73	130	not configured
73	131	not configured
73	132	not configured
73	134	not configured
73	135	not configured
73	136	not configured
73	137	not configured
73	138	not configured
74	1	not configured
74	2	not configured
74	9	not configured
74	10	not configured
74	11	not configured
74	12	not configured
74	13	not configured
74	14	not configured
74	15	not configured
74	16	not configured
74	17	not configured
74	18	not configured
74	19	not configured
74	20	not configured
74	21	not configured
74	22	not configured
74	23	not configured
74	24	not configured
74	25	not configured
74	26	not configured
74	27	not configured
74	28	not configured
74	29	not configured
74	30	not configured
74	31	not configured
74	32	not configured
74	33	not configured
74	34	not configured
74	35	not configured
74	36	not configured
74	37	not configured
74	38	not configured
74	39	not configured
74	40	not configured
74	41	not configured
74	42	not configured
74	43	not configured
74	44	not configured
74	45	not configured
74	46	not configured
74	47	not configured
74	48	not configured
74	49	not configured
74	50	not configured
74	51	not configured
74	52	not configured
74	53	not configured
74	54	not configured
74	55	not configured
74	56	not configured
74	57	not configured
74	58	not configured
74	59	not configured
74	60	not configured
74	61	not configured
74	62	not configured
74	63	not configured
74	64	not configured
74	65	not configured
74	66	not configured
74	67	not configured
74	68	not configured
74	69	not configured
74	71	not configured
74	72	not configured
74	73	not configured
74	74	not configured
74	75	not configured
74	76	not configured
74	77	not configured
74	78	not configured
74	79	not configured
74	80	not configured
74	81	not configured
74	82	not configured
74	83	not configured
74	84	not configured
74	85	not configured
74	86	not configured
74	87	not configured
74	88	not configured
74	89	not configured
74	90	not configured
74	91	not configured
74	92	not configured
74	93	not configured
74	94	not configured
74	95	not configured
74	96	not configured
74	97	not configured
74	98	not configured
74	99	not configured
74	100	not configured
74	101	not configured
74	102	not configured
74	103	not configured
74	104	not configured
74	105	not configured
74	106	not configured
74	107	not configured
74	108	not configured
74	109	not configured
74	110	not configured
74	111	not configured
74	112	not configured
74	113	not configured
74	114	not configured
74	115	not configured
74	116	not configured
74	117	not configured
74	118	not configured
74	119	not configured
74	120	not configured
74	121	not configured
74	122	not configured
74	124	not configured
74	125	not configured
74	127	not configured
74	128	not configured
74	129	not configured
74	130	not configured
74	131	not configured
74	132	not configured
74	134	not configured
74	135	not configured
74	136	not configured
74	137	not configured
74	138	not configured
75	1	not configured
75	2	not configured
75	9	not configured
75	10	not configured
75	11	not configured
75	12	not configured
75	13	not configured
75	14	not configured
75	15	not configured
75	16	not configured
75	17	not configured
75	18	not configured
75	19	not configured
75	20	not configured
75	21	not configured
75	22	not configured
75	23	not configured
75	24	not configured
75	25	not configured
75	26	not configured
75	27	not configured
75	28	not configured
75	29	not configured
75	30	not configured
75	31	not configured
75	32	not configured
75	33	not configured
75	34	not configured
75	35	not configured
75	36	not configured
75	37	not configured
75	38	not configured
75	39	not configured
75	40	not configured
75	41	not configured
75	42	not configured
75	43	not configured
75	44	not configured
75	45	not configured
75	46	not configured
75	47	not configured
75	48	not configured
75	49	not configured
75	50	not configured
75	51	not configured
75	52	not configured
75	53	not configured
75	54	not configured
75	55	not configured
75	56	not configured
75	57	not configured
75	58	not configured
75	59	not configured
75	60	not configured
75	61	not configured
75	62	not configured
75	63	not configured
75	64	not configured
75	65	not configured
75	66	not configured
75	67	not configured
75	68	not configured
75	69	not configured
75	71	not configured
75	72	not configured
75	73	not configured
75	74	not configured
75	75	not configured
75	76	not configured
75	77	not configured
75	78	not configured
75	79	not configured
75	80	not configured
75	81	not configured
75	82	not configured
75	83	not configured
75	84	not configured
75	85	not configured
75	86	not configured
75	87	not configured
75	88	not configured
75	89	not configured
75	90	not configured
75	91	not configured
75	92	not configured
75	93	not configured
75	94	not configured
75	95	not configured
75	96	not configured
75	97	not configured
75	98	not configured
75	99	not configured
75	100	not configured
75	101	not configured
75	102	not configured
75	103	not configured
75	104	not configured
75	105	not configured
75	106	not configured
75	107	not configured
75	108	not configured
75	109	not configured
75	110	not configured
75	111	not configured
75	112	not configured
75	113	not configured
75	114	not configured
75	115	not configured
75	116	not configured
75	117	not configured
75	118	not configured
75	119	not configured
75	120	not configured
75	121	not configured
75	122	not configured
75	124	not configured
75	125	not configured
75	127	not configured
75	128	not configured
75	129	not configured
75	130	not configured
75	131	not configured
75	132	not configured
75	134	not configured
75	135	not configured
75	136	not configured
75	137	not configured
75	138	not configured
76	1	not configured
76	2	not configured
76	9	not configured
76	10	not configured
76	11	not configured
76	12	not configured
76	13	not configured
76	14	not configured
76	15	not configured
76	16	not configured
76	17	not configured
76	18	not configured
76	19	not configured
76	20	not configured
76	21	not configured
76	22	not configured
76	23	not configured
76	24	not configured
76	25	not configured
76	26	not configured
76	27	not configured
76	28	not configured
76	29	not configured
76	30	not configured
76	31	not configured
76	32	not configured
76	33	not configured
76	34	not configured
76	35	not configured
76	36	not configured
76	37	not configured
76	38	not configured
76	39	not configured
76	40	not configured
76	41	not configured
76	42	not configured
76	43	not configured
76	44	not configured
76	45	not configured
76	46	not configured
76	47	not configured
76	48	not configured
76	49	not configured
76	50	not configured
76	51	not configured
76	52	not configured
76	53	not configured
76	54	not configured
76	55	not configured
76	56	not configured
76	57	not configured
76	58	not configured
76	59	not configured
76	60	not configured
76	61	not configured
76	62	not configured
76	63	not configured
76	64	not configured
76	65	not configured
76	66	not configured
76	67	not configured
76	68	not configured
76	69	not configured
76	71	not configured
76	72	not configured
76	73	not configured
76	74	not configured
76	75	not configured
76	76	not configured
76	77	not configured
76	78	not configured
76	79	not configured
76	80	not configured
76	81	not configured
76	82	not configured
76	83	not configured
76	84	not configured
76	85	not configured
76	86	not configured
76	87	not configured
76	88	not configured
76	89	not configured
76	90	not configured
76	91	not configured
76	92	not configured
76	93	not configured
76	94	not configured
76	95	not configured
76	96	not configured
76	97	not configured
76	98	not configured
76	99	not configured
76	100	not configured
76	101	not configured
76	102	not configured
76	103	not configured
76	104	not configured
76	105	not configured
76	106	not configured
76	107	not configured
76	108	not configured
76	109	not configured
76	110	not configured
76	111	not configured
76	112	not configured
76	113	not configured
76	114	not configured
76	115	not configured
76	116	not configured
76	117	not configured
76	118	not configured
76	119	not configured
76	120	not configured
76	121	not configured
76	122	not configured
76	124	not configured
76	125	not configured
76	127	not configured
76	128	not configured
76	129	not configured
76	130	not configured
76	131	not configured
76	132	not configured
76	134	not configured
76	135	not configured
76	136	not configured
76	137	not configured
76	138	not configured
77	1	not configured
77	2	not configured
77	9	not configured
77	10	not configured
77	11	not configured
77	12	not configured
77	13	not configured
77	14	not configured
77	15	not configured
77	16	not configured
77	17	not configured
77	18	not configured
77	19	not configured
77	20	not configured
77	21	not configured
77	22	not configured
77	23	not configured
77	24	not configured
77	25	not configured
77	26	not configured
77	27	not configured
77	28	not configured
77	29	not configured
77	30	not configured
77	31	not configured
77	32	not configured
77	33	not configured
77	34	not configured
77	35	not configured
77	36	not configured
77	37	not configured
77	38	not configured
77	39	not configured
77	40	not configured
77	41	not configured
77	42	not configured
77	43	not configured
77	44	not configured
77	45	not configured
77	46	not configured
77	47	not configured
77	48	not configured
77	49	not configured
77	50	not configured
77	51	not configured
77	52	not configured
77	53	not configured
77	54	not configured
77	55	not configured
77	56	not configured
77	57	not configured
77	58	not configured
77	59	not configured
77	60	not configured
77	61	not configured
77	62	not configured
77	63	not configured
77	64	not configured
77	65	not configured
77	66	not configured
77	67	not configured
77	68	not configured
77	69	not configured
77	71	not configured
77	72	not configured
77	73	not configured
77	74	not configured
77	75	not configured
77	76	not configured
77	77	not configured
77	78	not configured
77	79	not configured
77	80	not configured
77	81	not configured
77	82	not configured
77	83	not configured
77	84	not configured
77	85	not configured
77	86	not configured
77	87	not configured
77	88	not configured
77	89	not configured
77	90	not configured
77	91	not configured
77	92	not configured
77	93	not configured
77	94	not configured
77	95	not configured
77	96	not configured
77	97	not configured
77	98	not configured
77	99	not configured
77	100	not configured
77	101	not configured
77	102	not configured
77	103	not configured
77	104	not configured
77	105	not configured
77	106	not configured
77	107	not configured
77	108	not configured
77	109	not configured
77	110	not configured
77	111	not configured
77	112	not configured
77	113	not configured
77	114	not configured
77	115	not configured
77	116	not configured
77	117	not configured
77	118	not configured
77	119	not configured
77	120	not configured
77	121	not configured
77	122	not configured
77	124	not configured
77	125	not configured
77	127	not configured
77	128	not configured
77	129	not configured
77	130	not configured
77	131	not configured
77	132	not configured
77	134	not configured
77	135	not configured
77	136	not configured
77	137	not configured
77	138	not configured
78	1	not configured
78	2	not configured
78	9	not configured
78	10	not configured
78	11	not configured
78	12	not configured
78	13	not configured
78	14	not configured
78	15	not configured
78	16	not configured
78	17	not configured
78	18	not configured
78	19	not configured
78	20	not configured
78	21	not configured
78	22	not configured
78	23	not configured
78	24	not configured
78	25	not configured
78	26	not configured
78	27	not configured
78	28	not configured
78	29	not configured
78	30	not configured
78	31	not configured
78	32	not configured
78	33	not configured
78	34	not configured
78	35	not configured
78	36	not configured
78	37	not configured
78	38	not configured
78	39	not configured
78	40	not configured
78	41	not configured
78	42	not configured
78	43	not configured
78	44	not configured
78	45	not configured
78	46	not configured
78	47	not configured
78	48	not configured
78	49	not configured
78	50	not configured
78	51	not configured
78	52	not configured
78	53	not configured
78	54	not configured
78	55	not configured
78	56	not configured
78	57	not configured
78	58	not configured
78	59	not configured
78	60	not configured
78	61	not configured
78	62	not configured
78	63	not configured
78	64	not configured
78	65	not configured
78	66	not configured
78	67	not configured
78	68	not configured
78	69	not configured
78	71	not configured
78	72	not configured
78	73	not configured
78	74	not configured
78	75	not configured
78	76	not configured
78	77	not configured
78	78	not configured
78	79	not configured
78	80	not configured
78	81	not configured
78	82	not configured
78	83	not configured
78	84	not configured
78	85	not configured
78	86	not configured
78	87	not configured
78	88	not configured
78	89	not configured
78	90	not configured
78	91	not configured
78	92	not configured
78	93	not configured
78	94	not configured
78	95	not configured
78	96	not configured
78	97	not configured
78	98	not configured
78	99	not configured
78	100	not configured
78	101	not configured
78	102	not configured
78	103	not configured
78	104	not configured
78	105	not configured
78	106	not configured
78	107	not configured
78	108	not configured
78	109	not configured
78	110	not configured
78	111	not configured
78	112	not configured
78	113	not configured
78	114	not configured
78	115	not configured
78	116	not configured
78	117	not configured
78	118	not configured
78	119	not configured
78	120	not configured
78	121	not configured
78	122	not configured
78	124	not configured
78	125	not configured
78	127	not configured
78	128	not configured
78	129	not configured
78	130	not configured
78	131	not configured
78	132	not configured
78	134	not configured
78	135	not configured
78	136	not configured
78	137	not configured
78	138	not configured
79	1	not configured
79	2	not configured
79	9	not configured
79	10	not configured
79	11	not configured
79	12	not configured
79	13	not configured
79	14	not configured
79	15	not configured
79	16	not configured
79	17	not configured
79	18	not configured
79	19	not configured
79	20	not configured
79	21	not configured
79	22	not configured
79	23	not configured
79	24	not configured
79	25	not configured
79	26	not configured
79	27	not configured
79	28	not configured
79	29	not configured
79	30	not configured
79	31	not configured
79	32	not configured
79	33	not configured
79	34	not configured
79	35	not configured
79	36	not configured
79	37	not configured
79	38	not configured
79	39	not configured
79	40	not configured
79	41	not configured
79	42	not configured
79	43	not configured
79	44	not configured
79	45	not configured
79	46	not configured
79	47	not configured
79	48	not configured
79	49	not configured
79	50	not configured
79	51	not configured
79	52	not configured
79	53	not configured
79	54	not configured
79	55	not configured
79	56	not configured
79	57	not configured
79	58	not configured
79	59	not configured
79	60	not configured
79	61	not configured
79	62	not configured
79	63	not configured
79	64	not configured
79	65	not configured
79	66	not configured
79	67	not configured
79	68	not configured
79	69	not configured
79	71	not configured
79	72	not configured
79	73	not configured
79	74	not configured
79	75	not configured
79	76	not configured
79	77	not configured
79	78	not configured
79	79	not configured
79	80	not configured
79	81	not configured
79	82	not configured
79	83	not configured
79	84	not configured
79	85	not configured
79	86	not configured
79	87	not configured
79	88	not configured
79	89	not configured
79	90	not configured
79	91	not configured
79	92	not configured
79	93	not configured
79	94	not configured
79	95	not configured
79	96	not configured
79	97	not configured
79	98	not configured
79	99	not configured
79	100	not configured
79	101	not configured
79	102	not configured
79	103	not configured
79	104	not configured
79	105	not configured
79	106	not configured
79	107	not configured
79	108	not configured
79	109	not configured
79	110	not configured
79	111	not configured
79	112	not configured
79	113	not configured
79	114	not configured
79	115	not configured
79	116	not configured
79	117	not configured
79	118	not configured
79	119	not configured
79	120	not configured
79	121	not configured
79	122	not configured
79	124	not configured
79	125	not configured
79	127	not configured
79	128	not configured
79	129	not configured
79	130	not configured
79	131	not configured
79	132	not configured
79	134	not configured
79	135	not configured
79	136	not configured
79	137	not configured
79	138	not configured
80	1	not configured
80	2	not configured
80	9	not configured
80	10	not configured
80	11	not configured
80	12	not configured
80	13	not configured
80	14	not configured
80	15	not configured
80	16	not configured
80	17	not configured
80	18	not configured
80	19	not configured
80	20	not configured
80	21	not configured
80	22	not configured
80	23	not configured
80	24	not configured
80	25	not configured
80	26	not configured
80	27	not configured
80	28	not configured
80	29	not configured
80	30	not configured
80	31	not configured
80	32	not configured
80	33	not configured
80	34	not configured
80	35	not configured
80	36	not configured
80	37	not configured
80	38	not configured
80	39	not configured
80	40	not configured
80	41	not configured
80	42	not configured
80	43	not configured
80	44	not configured
80	45	not configured
80	46	not configured
80	47	not configured
80	48	not configured
80	49	not configured
80	50	not configured
80	51	not configured
80	52	not configured
80	53	not configured
80	54	not configured
80	55	not configured
80	56	not configured
80	57	not configured
80	58	not configured
80	59	not configured
80	60	not configured
80	61	not configured
80	62	not configured
80	63	not configured
80	64	not configured
80	65	not configured
80	66	not configured
80	67	not configured
80	68	not configured
80	69	not configured
80	71	not configured
80	72	not configured
80	73	not configured
80	74	not configured
80	75	not configured
80	76	not configured
80	77	not configured
80	78	not configured
80	79	not configured
80	80	not configured
80	81	not configured
80	82	not configured
80	83	not configured
80	84	not configured
80	85	not configured
80	86	not configured
80	87	not configured
80	88	not configured
80	89	not configured
80	90	not configured
80	91	not configured
80	92	not configured
80	93	not configured
80	94	not configured
80	95	not configured
80	96	not configured
80	97	not configured
80	98	not configured
80	99	not configured
80	100	not configured
80	101	not configured
80	102	not configured
80	103	not configured
80	104	not configured
80	105	not configured
80	106	not configured
80	107	not configured
80	108	not configured
80	109	not configured
80	110	not configured
80	111	not configured
80	112	not configured
80	113	not configured
80	114	not configured
80	115	not configured
80	116	not configured
80	117	not configured
80	118	not configured
80	119	not configured
80	120	not configured
80	121	not configured
80	122	not configured
80	124	not configured
80	125	not configured
80	127	not configured
80	128	not configured
80	129	not configured
80	130	not configured
80	131	not configured
80	132	not configured
80	134	not configured
80	135	not configured
80	136	not configured
80	137	not configured
80	138	not configured
81	1	not configured
81	2	not configured
81	9	not configured
81	10	not configured
81	11	not configured
81	12	not configured
81	13	not configured
81	14	not configured
81	15	not configured
81	16	not configured
81	17	not configured
81	18	not configured
81	19	not configured
81	20	not configured
81	21	not configured
81	22	not configured
81	23	not configured
81	24	not configured
81	25	not configured
81	26	not configured
81	27	not configured
81	28	not configured
81	29	not configured
81	30	not configured
81	31	not configured
81	32	not configured
81	33	not configured
81	34	not configured
81	35	not configured
81	36	not configured
81	37	not configured
81	38	not configured
81	39	not configured
81	40	not configured
81	41	not configured
81	42	not configured
81	43	not configured
81	44	not configured
81	45	not configured
81	46	not configured
81	47	not configured
81	48	not configured
81	49	not configured
81	50	not configured
81	51	not configured
81	52	not configured
81	53	not configured
81	54	not configured
81	55	not configured
81	56	not configured
81	57	not configured
81	58	not configured
81	59	not configured
81	60	not configured
81	61	not configured
81	62	not configured
81	63	not configured
81	64	not configured
81	65	not configured
81	66	not configured
81	67	not configured
81	68	not configured
81	69	not configured
81	71	not configured
81	72	not configured
81	73	not configured
81	74	not configured
81	75	not configured
81	76	not configured
81	77	not configured
81	78	not configured
81	79	not configured
81	80	not configured
81	81	not configured
81	82	not configured
81	83	not configured
81	84	not configured
81	85	not configured
81	86	not configured
81	87	not configured
81	88	not configured
81	89	not configured
81	90	not configured
81	91	not configured
81	92	not configured
81	93	not configured
81	94	not configured
81	95	not configured
81	96	not configured
81	97	not configured
81	98	not configured
81	99	not configured
81	100	not configured
81	101	not configured
81	102	not configured
81	103	not configured
81	104	not configured
81	105	not configured
81	106	not configured
81	107	not configured
81	108	not configured
81	109	not configured
81	110	not configured
81	111	not configured
81	112	not configured
81	113	not configured
81	114	not configured
81	115	not configured
81	116	not configured
81	117	not configured
81	118	not configured
81	119	not configured
81	120	not configured
81	121	not configured
81	122	not configured
81	124	not configured
81	125	not configured
81	127	not configured
81	128	not configured
81	129	not configured
81	130	not configured
81	131	not configured
81	132	not configured
81	134	not configured
81	135	not configured
81	136	not configured
81	137	not configured
81	138	not configured
82	1	not configured
82	2	not configured
82	9	not configured
82	10	not configured
82	11	not configured
82	12	not configured
82	13	not configured
82	14	not configured
82	15	not configured
82	16	not configured
82	17	not configured
82	18	not configured
82	19	not configured
82	20	not configured
82	21	not configured
82	22	not configured
82	23	not configured
82	24	not configured
82	25	not configured
82	26	not configured
82	27	not configured
82	28	not configured
82	29	not configured
82	30	not configured
82	31	not configured
82	32	not configured
82	33	not configured
82	34	not configured
82	35	not configured
82	36	not configured
82	37	not configured
82	38	not configured
82	39	not configured
82	40	not configured
82	41	not configured
82	42	not configured
82	43	not configured
82	44	not configured
82	45	not configured
82	46	not configured
82	47	not configured
82	48	not configured
82	49	not configured
82	50	not configured
82	51	not configured
82	52	not configured
82	53	not configured
82	54	not configured
82	55	not configured
82	56	not configured
82	57	not configured
82	58	not configured
82	59	not configured
82	60	not configured
82	61	not configured
82	62	not configured
82	63	not configured
82	64	not configured
82	65	not configured
82	66	not configured
82	67	not configured
82	68	not configured
82	69	not configured
82	71	not configured
82	72	not configured
82	73	not configured
82	74	not configured
82	75	not configured
82	76	not configured
82	77	not configured
82	78	not configured
82	79	not configured
82	80	not configured
82	81	not configured
82	82	not configured
82	83	not configured
82	84	not configured
82	85	not configured
82	86	not configured
82	87	not configured
82	88	not configured
82	89	not configured
82	90	not configured
82	91	not configured
82	92	not configured
82	93	not configured
82	94	not configured
82	95	not configured
82	96	not configured
82	97	not configured
82	98	not configured
82	99	not configured
82	100	not configured
82	101	not configured
82	102	not configured
82	103	not configured
82	104	not configured
82	105	not configured
82	106	not configured
82	107	not configured
82	108	not configured
82	109	not configured
82	110	not configured
82	111	not configured
82	112	not configured
82	113	not configured
82	114	not configured
82	115	not configured
82	116	not configured
82	117	not configured
82	118	not configured
82	119	not configured
82	120	not configured
82	121	not configured
82	122	not configured
82	124	not configured
82	125	not configured
82	127	not configured
82	128	not configured
82	129	not configured
82	130	not configured
82	131	not configured
82	132	not configured
82	134	not configured
82	135	not configured
82	136	not configured
82	137	not configured
82	138	not configured
83	1	not configured
83	2	not configured
83	9	not configured
83	10	not configured
83	11	not configured
83	12	not configured
83	13	not configured
83	14	not configured
83	15	not configured
83	16	not configured
83	17	not configured
83	18	not configured
83	19	not configured
83	20	not configured
83	21	not configured
83	22	not configured
83	23	not configured
83	24	not configured
83	25	not configured
83	26	not configured
83	27	not configured
83	28	not configured
83	29	not configured
83	30	not configured
83	31	not configured
83	32	not configured
83	33	not configured
83	34	not configured
83	35	not configured
83	36	not configured
83	37	not configured
83	38	not configured
83	39	not configured
83	40	not configured
83	41	not configured
83	42	not configured
83	43	not configured
83	44	not configured
83	45	not configured
83	46	not configured
83	47	not configured
83	48	not configured
83	49	not configured
83	50	not configured
83	51	not configured
83	52	not configured
83	53	not configured
83	54	not configured
83	55	not configured
83	56	not configured
83	57	not configured
83	58	not configured
83	59	not configured
83	60	not configured
83	61	not configured
83	62	not configured
83	63	not configured
83	64	not configured
83	65	not configured
83	66	not configured
83	67	not configured
83	68	not configured
83	69	not configured
83	71	not configured
83	72	not configured
83	73	not configured
83	74	not configured
83	75	not configured
83	76	not configured
83	77	not configured
83	78	not configured
83	79	not configured
83	80	not configured
83	81	not configured
83	82	not configured
83	83	not configured
83	84	not configured
83	85	not configured
83	86	not configured
83	87	not configured
83	88	not configured
83	89	not configured
83	90	not configured
83	91	not configured
83	92	not configured
83	93	not configured
83	94	not configured
83	95	not configured
83	96	not configured
83	97	not configured
83	98	not configured
83	99	not configured
83	100	not configured
83	101	not configured
83	102	not configured
83	103	not configured
83	104	not configured
83	105	not configured
83	106	not configured
83	107	not configured
83	108	not configured
83	109	not configured
83	110	not configured
83	111	not configured
83	112	not configured
83	113	not configured
83	114	not configured
83	115	not configured
83	116	not configured
83	117	not configured
83	118	not configured
83	119	not configured
83	120	not configured
83	121	not configured
83	122	not configured
83	124	not configured
83	125	not configured
83	127	not configured
83	128	not configured
83	129	not configured
83	130	not configured
83	131	not configured
83	132	not configured
83	134	not configured
83	135	not configured
83	136	not configured
83	137	not configured
83	138	not configured
84	1	not configured
84	2	not configured
84	9	not configured
84	10	not configured
84	11	not configured
84	12	not configured
84	13	not configured
84	14	not configured
84	15	not configured
84	16	not configured
84	17	not configured
84	18	not configured
84	19	not configured
84	20	not configured
84	21	not configured
84	22	not configured
84	23	not configured
84	24	not configured
84	25	not configured
84	26	not configured
84	27	not configured
84	28	not configured
84	29	not configured
84	30	not configured
84	31	not configured
84	32	not configured
84	33	not configured
84	34	not configured
84	35	not configured
84	36	not configured
84	37	not configured
84	38	not configured
84	39	not configured
84	40	not configured
84	41	not configured
84	42	not configured
84	43	not configured
84	44	not configured
84	45	not configured
84	46	not configured
84	47	not configured
84	48	not configured
84	49	not configured
84	50	not configured
84	51	not configured
84	52	not configured
84	53	not configured
84	54	not configured
84	55	not configured
84	56	not configured
84	57	not configured
84	58	not configured
84	59	not configured
84	60	not configured
84	61	not configured
84	62	not configured
84	63	not configured
84	64	not configured
84	65	not configured
84	66	not configured
84	67	not configured
84	68	not configured
84	69	not configured
84	71	not configured
84	72	not configured
84	73	not configured
84	74	not configured
84	75	not configured
84	76	not configured
84	77	not configured
84	78	not configured
84	79	not configured
84	80	not configured
84	81	not configured
84	82	not configured
84	83	not configured
84	84	not configured
84	85	not configured
84	86	not configured
84	87	not configured
84	88	not configured
84	89	not configured
84	90	not configured
84	91	not configured
84	92	not configured
84	93	not configured
84	94	not configured
84	95	not configured
84	96	not configured
84	97	not configured
84	98	not configured
84	99	not configured
84	100	not configured
84	101	not configured
84	102	not configured
84	103	not configured
84	104	not configured
84	105	not configured
84	106	not configured
84	107	not configured
84	108	not configured
84	109	not configured
84	110	not configured
84	111	not configured
84	112	not configured
84	113	not configured
84	114	not configured
84	115	not configured
84	116	not configured
84	117	not configured
84	118	not configured
84	119	not configured
84	120	not configured
84	121	not configured
84	122	not configured
84	124	not configured
84	125	not configured
84	127	not configured
84	128	not configured
84	129	not configured
84	130	not configured
84	131	not configured
84	132	not configured
84	134	not configured
84	135	not configured
84	136	not configured
84	137	not configured
84	138	not configured
85	1	26757000001234
86	1	not configured
86	2	not configured
86	9	not configured
86	10	not configured
86	11	not configured
86	12	not configured
86	13	not configured
86	14	not configured
86	15	not configured
86	16	not configured
86	17	not configured
86	18	not configured
86	19	not configured
86	20	not configured
86	21	not configured
86	22	not configured
86	23	not configured
86	24	not configured
86	25	not configured
86	26	not configured
86	27	not configured
86	28	not configured
86	29	not configured
86	30	not configured
86	31	not configured
86	32	not configured
86	33	not configured
86	34	not configured
86	35	not configured
86	36	not configured
86	37	not configured
86	38	not configured
86	39	not configured
86	40	not configured
86	41	not configured
86	42	not configured
86	43	not configured
86	44	not configured
86	45	not configured
86	46	not configured
86	47	not configured
86	48	not configured
86	49	not configured
86	50	not configured
86	51	not configured
86	52	not configured
86	53	not configured
86	54	not configured
86	55	not configured
86	56	not configured
86	57	not configured
86	58	not configured
86	59	not configured
86	60	not configured
86	61	not configured
86	62	not configured
86	63	not configured
86	64	not configured
86	65	not configured
86	66	not configured
86	67	not configured
86	68	not configured
86	69	not configured
86	71	not configured
85	42	26757000001234
86	72	not configured
86	73	not configured
86	74	not configured
86	75	not configured
86	76	not configured
86	77	not configured
86	78	not configured
86	79	not configured
86	80	not configured
86	81	not configured
86	82	not configured
86	83	not configured
86	84	not configured
86	85	not configured
86	86	not configured
86	87	not configured
86	88	not configured
86	89	not configured
86	90	not configured
86	91	not configured
86	92	not configured
86	93	not configured
86	94	not configured
86	95	not configured
86	96	not configured
86	97	not configured
86	98	not configured
86	99	not configured
86	100	not configured
86	101	not configured
86	102	not configured
86	103	not configured
86	104	not configured
86	105	not configured
86	106	not configured
86	107	not configured
86	108	not configured
86	109	not configured
86	110	not configured
86	111	not configured
86	112	not configured
86	113	not configured
86	114	not configured
86	115	not configured
86	116	not configured
86	117	not configured
86	118	not configured
86	119	not configured
86	120	not configured
86	121	not configured
86	122	not configured
86	124	not configured
86	125	not configured
86	127	not configured
86	128	not configured
86	129	not configured
86	130	not configured
86	131	not configured
86	132	not configured
86	134	not configured
86	135	not configured
86	136	not configured
86	137	not configured
86	138	not configured
87	1	not configured
87	2	not configured
87	9	not configured
87	10	not configured
87	11	not configured
87	12	not configured
87	13	not configured
87	14	not configured
87	15	not configured
87	16	not configured
87	17	not configured
87	18	not configured
87	19	not configured
87	20	not configured
87	21	not configured
87	22	not configured
87	23	not configured
87	24	not configured
87	25	not configured
87	26	not configured
87	27	not configured
87	28	not configured
87	29	not configured
87	30	not configured
87	31	not configured
87	32	not configured
87	33	not configured
87	34	not configured
87	35	not configured
87	36	not configured
87	37	not configured
87	38	not configured
87	39	not configured
87	40	not configured
87	41	not configured
87	42	not configured
87	43	not configured
87	44	not configured
87	45	not configured
87	46	not configured
87	47	not configured
87	48	not configured
87	49	not configured
87	50	not configured
87	51	not configured
87	52	not configured
87	53	not configured
87	54	not configured
87	55	not configured
87	56	not configured
87	57	not configured
87	58	not configured
87	59	not configured
87	60	not configured
87	61	not configured
87	62	not configured
87	63	not configured
87	64	not configured
87	65	not configured
87	66	not configured
87	67	not configured
87	68	not configured
87	69	not configured
87	71	not configured
87	72	not configured
87	73	not configured
87	74	not configured
87	75	not configured
87	76	not configured
87	77	not configured
87	78	not configured
87	79	not configured
87	80	not configured
87	81	not configured
87	82	not configured
87	83	not configured
87	84	not configured
87	85	not configured
87	86	not configured
87	87	not configured
87	88	not configured
87	89	not configured
87	90	not configured
87	91	not configured
87	92	not configured
87	93	not configured
87	94	not configured
87	95	not configured
87	96	not configured
87	97	not configured
87	98	not configured
87	99	not configured
87	100	not configured
87	101	not configured
87	102	not configured
87	103	not configured
87	104	not configured
87	105	not configured
87	106	not configured
87	107	not configured
87	108	not configured
87	109	not configured
87	110	not configured
87	111	not configured
87	112	not configured
87	113	not configured
87	114	not configured
87	115	not configured
87	116	not configured
87	117	not configured
87	118	not configured
87	119	not configured
87	120	not configured
87	121	not configured
87	122	not configured
87	124	not configured
87	125	not configured
87	127	not configured
87	128	not configured
87	129	not configured
87	130	not configured
87	131	not configured
87	132	not configured
87	134	not configured
87	135	not configured
87	136	not configured
87	137	not configured
87	138	not configured
88	1	not configured
88	2	not configured
88	9	not configured
88	10	not configured
88	11	not configured
88	12	not configured
88	13	not configured
88	14	not configured
88	15	not configured
88	16	not configured
88	17	not configured
88	18	not configured
88	19	not configured
88	20	not configured
88	21	not configured
88	22	not configured
88	23	not configured
88	24	not configured
88	25	not configured
88	26	not configured
88	27	not configured
88	28	not configured
88	29	not configured
88	30	not configured
88	31	not configured
88	32	not configured
88	33	not configured
88	34	not configured
88	35	not configured
88	36	not configured
88	37	not configured
88	38	not configured
88	39	not configured
88	40	not configured
88	41	not configured
88	42	not configured
88	43	not configured
88	44	not configured
88	45	not configured
88	46	not configured
88	47	not configured
88	48	not configured
88	49	not configured
88	50	not configured
88	51	not configured
88	52	not configured
88	53	not configured
88	54	not configured
88	55	not configured
88	56	not configured
88	57	not configured
88	58	not configured
88	59	not configured
88	60	not configured
88	61	not configured
88	62	not configured
88	63	not configured
88	64	not configured
88	65	not configured
88	66	not configured
88	67	not configured
88	68	not configured
88	69	not configured
88	71	not configured
88	72	not configured
88	73	not configured
88	74	not configured
88	75	not configured
88	76	not configured
88	77	not configured
88	78	not configured
88	79	not configured
88	80	not configured
88	81	not configured
88	82	not configured
88	83	not configured
88	84	not configured
88	85	not configured
88	86	not configured
88	87	not configured
88	88	not configured
88	89	not configured
88	90	not configured
88	91	not configured
88	92	not configured
88	93	not configured
88	94	not configured
88	95	not configured
88	96	not configured
88	97	not configured
88	98	not configured
88	99	not configured
88	100	not configured
88	101	not configured
88	102	not configured
88	103	not configured
88	104	not configured
88	105	not configured
88	106	not configured
88	107	not configured
88	108	not configured
88	109	not configured
88	110	not configured
88	111	not configured
88	112	not configured
88	113	not configured
88	114	not configured
88	115	not configured
88	116	not configured
88	117	not configured
88	118	not configured
88	119	not configured
88	120	not configured
88	121	not configured
88	122	not configured
88	124	not configured
88	125	not configured
88	127	not configured
88	128	not configured
88	129	not configured
88	130	not configured
88	131	not configured
88	132	not configured
88	134	not configured
88	135	not configured
88	136	not configured
88	137	not configured
88	138	not configured
89	1	not configured
89	2	not configured
89	9	not configured
89	10	not configured
89	11	not configured
89	12	not configured
89	13	not configured
89	14	not configured
89	15	not configured
89	16	not configured
89	17	not configured
89	18	not configured
89	19	not configured
89	20	not configured
89	21	not configured
89	22	not configured
89	23	not configured
89	24	not configured
89	25	not configured
89	26	not configured
89	27	not configured
89	28	not configured
89	29	not configured
89	30	not configured
89	31	not configured
89	32	not configured
89	33	not configured
89	34	not configured
89	35	not configured
89	36	not configured
89	37	not configured
89	38	not configured
89	39	not configured
89	40	not configured
89	41	not configured
89	42	not configured
89	43	not configured
89	44	not configured
89	45	not configured
89	46	not configured
89	47	not configured
89	48	not configured
89	49	not configured
89	50	not configured
89	51	not configured
89	52	not configured
89	53	not configured
89	54	not configured
89	55	not configured
89	56	not configured
89	57	not configured
89	58	not configured
89	59	not configured
89	60	not configured
89	61	not configured
89	62	not configured
89	63	not configured
89	64	not configured
89	65	not configured
89	66	not configured
89	67	not configured
89	68	not configured
89	69	not configured
89	71	not configured
89	72	not configured
89	73	not configured
89	74	not configured
89	75	not configured
89	76	not configured
89	77	not configured
89	78	not configured
89	79	not configured
89	80	not configured
89	81	not configured
89	82	not configured
89	83	not configured
89	84	not configured
89	85	not configured
89	86	not configured
89	87	not configured
89	88	not configured
89	89	not configured
89	90	not configured
89	91	not configured
89	92	not configured
89	93	not configured
89	94	not configured
89	95	not configured
89	96	not configured
89	97	not configured
89	98	not configured
89	99	not configured
89	100	not configured
89	101	not configured
89	102	not configured
89	103	not configured
89	104	not configured
89	105	not configured
89	106	not configured
89	107	not configured
89	108	not configured
89	109	not configured
89	110	not configured
89	111	not configured
89	112	not configured
89	113	not configured
89	114	not configured
89	115	not configured
89	116	not configured
89	117	not configured
89	118	not configured
89	119	not configured
89	120	not configured
89	121	not configured
89	122	not configured
89	124	not configured
89	125	not configured
89	127	not configured
89	128	not configured
89	129	not configured
89	130	not configured
89	131	not configured
89	132	not configured
89	134	not configured
89	135	not configured
89	136	not configured
89	137	not configured
89	138	not configured
90	1	not configured
90	2	not configured
90	9	not configured
90	10	not configured
90	11	not configured
90	12	not configured
90	13	not configured
90	14	not configured
90	15	not configured
90	16	not configured
90	17	not configured
90	18	not configured
90	19	not configured
90	20	not configured
90	21	not configured
90	22	not configured
90	23	not configured
90	24	not configured
90	25	not configured
90	26	not configured
90	27	not configured
90	28	not configured
90	29	not configured
90	30	not configured
90	31	not configured
90	32	not configured
90	33	not configured
90	34	not configured
90	35	not configured
90	36	not configured
90	37	not configured
90	38	not configured
90	39	not configured
90	40	not configured
90	41	not configured
90	42	not configured
90	43	not configured
90	44	not configured
90	45	not configured
90	46	not configured
90	47	not configured
90	48	not configured
90	49	not configured
90	50	not configured
90	51	not configured
90	52	not configured
90	53	not configured
90	54	not configured
90	55	not configured
90	56	not configured
90	57	not configured
90	58	not configured
90	59	not configured
90	60	not configured
90	61	not configured
90	62	not configured
90	63	not configured
90	64	not configured
90	65	not configured
90	66	not configured
90	67	not configured
90	68	not configured
90	69	not configured
90	71	not configured
90	72	not configured
90	73	not configured
90	74	not configured
90	75	not configured
90	76	not configured
90	77	not configured
90	78	not configured
90	79	not configured
90	80	not configured
90	81	not configured
90	82	not configured
90	83	not configured
90	84	not configured
90	85	not configured
90	86	not configured
90	87	not configured
90	88	not configured
90	89	not configured
90	90	not configured
90	91	not configured
90	92	not configured
90	93	not configured
90	94	not configured
90	95	not configured
90	96	not configured
90	97	not configured
90	98	not configured
90	99	not configured
90	100	not configured
90	101	not configured
90	102	not configured
90	103	not configured
90	104	not configured
90	105	not configured
90	106	not configured
90	107	not configured
90	108	not configured
90	109	not configured
90	110	not configured
90	111	not configured
90	112	not configured
90	113	not configured
90	114	not configured
90	115	not configured
90	116	not configured
90	117	not configured
90	118	not configured
90	119	not configured
90	120	not configured
90	121	not configured
90	122	not configured
90	124	not configured
90	125	not configured
90	127	not configured
90	128	not configured
90	129	not configured
90	130	not configured
90	131	not configured
90	132	not configured
90	134	not configured
90	135	not configured
90	136	not configured
90	137	not configured
90	138	not configured
91	1	not configured
91	2	not configured
91	9	not configured
91	10	not configured
91	11	not configured
91	12	not configured
91	13	not configured
91	14	not configured
91	15	not configured
91	16	not configured
91	17	not configured
91	18	not configured
91	19	not configured
91	20	not configured
91	21	not configured
91	22	not configured
91	23	not configured
91	24	not configured
91	25	not configured
91	26	not configured
91	27	not configured
91	28	not configured
91	29	not configured
91	30	not configured
91	31	not configured
91	32	not configured
91	33	not configured
91	34	not configured
91	35	not configured
91	36	not configured
91	37	not configured
91	38	not configured
91	39	not configured
91	40	not configured
91	41	not configured
91	42	not configured
91	43	not configured
91	44	not configured
91	45	not configured
91	46	not configured
91	47	not configured
91	48	not configured
91	49	not configured
91	50	not configured
91	51	not configured
91	52	not configured
91	53	not configured
91	54	not configured
91	55	not configured
91	56	not configured
91	57	not configured
91	58	not configured
91	59	not configured
91	60	not configured
91	61	not configured
91	62	not configured
91	63	not configured
91	64	not configured
91	65	not configured
91	66	not configured
91	67	not configured
91	68	not configured
91	69	not configured
91	71	not configured
91	72	not configured
91	73	not configured
91	74	not configured
91	75	not configured
91	76	not configured
91	77	not configured
91	78	not configured
91	79	not configured
91	80	not configured
91	81	not configured
91	82	not configured
91	83	not configured
91	84	not configured
91	85	not configured
91	86	not configured
91	87	not configured
91	88	not configured
91	89	not configured
91	90	not configured
91	91	not configured
91	92	not configured
91	93	not configured
91	94	not configured
91	95	not configured
91	96	not configured
91	97	not configured
91	98	not configured
91	99	not configured
91	100	not configured
91	101	not configured
91	102	not configured
91	103	not configured
91	104	not configured
91	105	not configured
91	106	not configured
91	107	not configured
91	108	not configured
91	109	not configured
91	110	not configured
91	111	not configured
91	112	not configured
91	113	not configured
91	114	not configured
91	115	not configured
91	116	not configured
91	117	not configured
91	118	not configured
91	119	not configured
91	120	not configured
91	121	not configured
91	122	not configured
91	124	not configured
91	125	not configured
91	127	not configured
91	128	not configured
91	129	not configured
91	130	not configured
91	131	not configured
91	132	not configured
91	134	not configured
91	135	not configured
91	136	not configured
91	137	not configured
91	138	not configured
92	1	not configured
92	2	not configured
92	9	not configured
92	10	not configured
92	11	not configured
92	12	not configured
92	13	not configured
92	14	not configured
92	15	not configured
92	16	not configured
92	17	not configured
92	18	not configured
92	19	not configured
92	20	not configured
92	21	not configured
92	22	not configured
92	23	not configured
92	24	not configured
92	25	not configured
92	26	not configured
92	27	not configured
92	28	not configured
92	29	not configured
92	30	not configured
92	31	not configured
92	32	not configured
92	33	not configured
92	34	not configured
92	35	not configured
92	36	not configured
92	37	not configured
92	38	not configured
92	39	not configured
92	40	not configured
92	41	not configured
92	42	not configured
92	43	not configured
92	44	not configured
92	45	not configured
92	46	not configured
92	47	not configured
92	48	not configured
92	49	not configured
92	50	not configured
92	51	not configured
92	52	not configured
92	53	not configured
92	54	not configured
92	55	not configured
92	56	not configured
92	57	not configured
92	58	not configured
92	59	not configured
92	60	not configured
92	61	not configured
92	62	not configured
92	63	not configured
92	64	not configured
92	65	not configured
92	66	not configured
92	67	not configured
92	68	not configured
92	69	not configured
92	71	not configured
92	72	not configured
92	73	not configured
92	74	not configured
92	75	not configured
92	76	not configured
92	77	not configured
92	78	not configured
92	79	not configured
92	80	not configured
92	81	not configured
92	82	not configured
92	83	not configured
92	84	not configured
92	85	not configured
92	86	not configured
92	87	not configured
92	88	not configured
92	89	not configured
92	90	not configured
92	91	not configured
92	92	not configured
92	93	not configured
92	94	not configured
92	95	not configured
92	96	not configured
92	97	not configured
92	98	not configured
92	99	not configured
92	100	not configured
92	101	not configured
92	102	not configured
92	103	not configured
92	104	not configured
92	105	not configured
92	106	not configured
92	107	not configured
92	108	not configured
92	109	not configured
92	110	not configured
92	111	not configured
92	112	not configured
92	113	not configured
92	114	not configured
92	115	not configured
92	116	not configured
92	117	not configured
92	118	not configured
92	119	not configured
92	120	not configured
92	121	not configured
92	122	not configured
92	124	not configured
92	125	not configured
92	127	not configured
92	128	not configured
92	129	not configured
92	130	not configured
92	131	not configured
92	132	not configured
92	134	not configured
92	135	not configured
92	136	not configured
92	137	not configured
92	138	not configured
93	1	not configured
93	2	not configured
93	9	not configured
93	10	not configured
93	11	not configured
93	12	not configured
93	13	not configured
93	14	not configured
93	15	not configured
93	16	not configured
93	17	not configured
93	18	not configured
93	19	not configured
93	20	not configured
93	21	not configured
93	22	not configured
93	23	not configured
93	24	not configured
93	25	not configured
93	26	not configured
93	27	not configured
93	28	not configured
93	29	not configured
93	30	not configured
93	31	not configured
93	32	not configured
93	33	not configured
93	34	not configured
93	35	not configured
93	36	not configured
93	37	not configured
93	38	not configured
93	39	not configured
93	40	not configured
93	41	not configured
93	42	not configured
93	43	not configured
93	44	not configured
93	45	not configured
93	46	not configured
93	47	not configured
93	48	not configured
93	49	not configured
93	50	not configured
93	51	not configured
93	52	not configured
93	53	not configured
93	54	not configured
93	55	not configured
93	56	not configured
93	57	not configured
93	58	not configured
93	59	not configured
93	60	not configured
93	61	not configured
93	62	not configured
93	63	not configured
93	64	not configured
93	65	not configured
93	66	not configured
93	67	not configured
93	68	not configured
93	69	not configured
93	71	not configured
93	72	not configured
93	73	not configured
93	74	not configured
93	75	not configured
93	76	not configured
93	77	not configured
93	78	not configured
93	79	not configured
93	80	not configured
93	81	not configured
93	82	not configured
93	83	not configured
93	84	not configured
93	85	not configured
93	86	not configured
93	87	not configured
93	88	not configured
93	89	not configured
93	90	not configured
93	91	not configured
93	92	not configured
93	93	not configured
93	94	not configured
93	95	not configured
93	96	not configured
93	97	not configured
93	98	not configured
93	99	not configured
93	100	not configured
93	101	not configured
93	102	not configured
93	103	not configured
93	104	not configured
93	105	not configured
93	106	not configured
93	107	not configured
93	108	not configured
93	109	not configured
93	110	not configured
93	111	not configured
93	112	not configured
93	113	not configured
93	114	not configured
93	115	not configured
93	116	not configured
93	117	not configured
93	118	not configured
93	119	not configured
93	120	not configured
93	121	not configured
93	122	not configured
93	124	not configured
93	125	not configured
93	127	not configured
93	128	not configured
93	129	not configured
93	130	not configured
93	131	not configured
93	132	not configured
93	134	not configured
93	135	not configured
93	136	not configured
93	137	not configured
93	138	not configured
94	1	not configured
94	2	not configured
94	9	not configured
94	10	not configured
94	11	not configured
94	12	not configured
94	13	not configured
94	14	not configured
94	15	not configured
94	16	not configured
94	17	not configured
94	18	not configured
94	19	not configured
94	20	not configured
94	21	not configured
94	22	not configured
94	23	not configured
94	24	not configured
94	25	not configured
94	26	not configured
94	27	not configured
94	28	not configured
94	29	not configured
94	30	not configured
94	31	not configured
94	32	not configured
94	33	not configured
94	34	not configured
94	35	not configured
94	36	not configured
94	37	not configured
94	38	not configured
94	39	not configured
94	40	not configured
94	41	not configured
94	42	not configured
94	43	not configured
94	44	not configured
94	45	not configured
94	46	not configured
94	47	not configured
94	48	not configured
94	49	not configured
94	50	not configured
94	51	not configured
94	52	not configured
94	53	not configured
94	54	not configured
94	55	not configured
94	56	not configured
94	57	not configured
94	58	not configured
94	59	not configured
94	60	not configured
94	61	not configured
94	62	not configured
94	63	not configured
94	64	not configured
94	65	not configured
94	66	not configured
94	67	not configured
94	68	not configured
94	69	not configured
94	71	not configured
94	72	not configured
94	73	not configured
94	74	not configured
94	75	not configured
94	76	not configured
94	77	not configured
94	78	not configured
94	79	not configured
94	80	not configured
94	81	not configured
94	82	not configured
94	83	not configured
94	84	not configured
94	85	not configured
94	86	not configured
94	87	not configured
94	88	not configured
94	89	not configured
94	90	not configured
94	91	not configured
94	92	not configured
94	93	not configured
94	94	not configured
94	95	not configured
94	96	not configured
94	97	not configured
94	98	not configured
94	99	not configured
94	100	not configured
94	101	not configured
94	102	not configured
94	103	not configured
94	104	not configured
94	105	not configured
94	106	not configured
94	107	not configured
94	108	not configured
94	109	not configured
94	110	not configured
94	111	not configured
94	112	not configured
94	113	not configured
94	114	not configured
94	115	not configured
94	116	not configured
94	117	not configured
94	118	not configured
94	119	not configured
94	120	not configured
94	121	not configured
94	122	not configured
94	124	not configured
94	125	not configured
94	127	not configured
94	128	not configured
94	129	not configured
94	130	not configured
94	131	not configured
94	132	not configured
94	134	not configured
94	135	not configured
94	136	not configured
94	137	not configured
94	138	not configured
95	1	not configured
95	2	not configured
95	9	not configured
95	10	not configured
95	11	not configured
95	12	not configured
95	13	not configured
95	14	not configured
95	15	not configured
95	16	not configured
95	17	not configured
95	18	not configured
95	19	not configured
95	20	not configured
95	21	not configured
95	22	not configured
95	23	not configured
95	24	not configured
95	25	not configured
95	26	not configured
95	27	not configured
95	28	not configured
95	29	not configured
95	30	not configured
95	31	not configured
95	32	not configured
95	33	not configured
95	34	not configured
95	35	not configured
95	36	not configured
95	37	not configured
95	38	not configured
95	39	not configured
95	40	not configured
95	41	not configured
95	42	not configured
95	43	not configured
95	44	not configured
95	45	not configured
95	46	not configured
95	47	not configured
95	48	not configured
95	49	not configured
95	50	not configured
95	51	not configured
95	52	not configured
95	53	not configured
95	54	not configured
95	55	not configured
95	56	not configured
95	57	not configured
95	58	not configured
95	59	not configured
95	60	not configured
95	61	not configured
95	62	not configured
95	63	not configured
95	64	not configured
95	65	not configured
95	66	not configured
95	67	not configured
95	68	not configured
95	69	not configured
95	71	not configured
95	72	not configured
95	73	not configured
95	74	not configured
95	75	not configured
95	76	not configured
95	77	not configured
95	78	not configured
95	79	not configured
95	80	not configured
95	81	not configured
95	82	not configured
95	83	not configured
95	84	not configured
95	85	not configured
95	86	not configured
95	87	not configured
95	88	not configured
95	89	not configured
95	90	not configured
95	91	not configured
95	92	not configured
95	93	not configured
95	94	not configured
95	95	not configured
95	96	not configured
95	97	not configured
95	98	not configured
95	99	not configured
95	100	not configured
95	101	not configured
95	102	not configured
95	103	not configured
95	104	not configured
95	105	not configured
95	106	not configured
95	107	not configured
95	108	not configured
95	109	not configured
95	110	not configured
95	111	not configured
95	112	not configured
95	113	not configured
95	114	not configured
95	115	not configured
95	116	not configured
95	117	not configured
95	118	not configured
95	119	not configured
95	120	not configured
95	121	not configured
95	122	not configured
95	124	not configured
95	125	not configured
95	127	not configured
95	128	not configured
95	129	not configured
95	130	not configured
95	131	not configured
95	132	not configured
95	134	not configured
95	135	not configured
95	136	not configured
95	137	not configured
95	138	not configured
96	1	not configured
96	2	not configured
96	9	not configured
96	10	not configured
96	11	not configured
96	12	not configured
96	13	not configured
96	14	not configured
96	15	not configured
96	16	not configured
96	17	not configured
96	18	not configured
96	19	not configured
96	20	not configured
96	21	not configured
96	22	not configured
96	23	not configured
96	24	not configured
96	25	not configured
96	26	not configured
96	27	not configured
96	28	not configured
96	29	not configured
96	30	not configured
96	31	not configured
96	32	not configured
96	33	not configured
96	34	not configured
96	35	not configured
96	36	not configured
96	37	not configured
96	38	not configured
96	39	not configured
96	40	not configured
96	41	not configured
96	42	not configured
96	43	not configured
96	44	not configured
96	45	not configured
96	46	not configured
96	47	not configured
96	48	not configured
96	49	not configured
96	50	not configured
96	51	not configured
96	52	not configured
96	53	not configured
96	54	not configured
96	55	not configured
96	56	not configured
96	57	not configured
96	58	not configured
96	59	not configured
96	60	not configured
96	61	not configured
96	62	not configured
96	63	not configured
96	64	not configured
96	65	not configured
96	66	not configured
96	67	not configured
96	68	not configured
96	69	not configured
96	71	not configured
96	72	not configured
96	73	not configured
96	74	not configured
96	75	not configured
96	76	not configured
96	77	not configured
96	78	not configured
96	79	not configured
96	80	not configured
96	81	not configured
96	82	not configured
96	83	not configured
96	84	not configured
96	85	not configured
96	86	not configured
96	87	not configured
96	88	not configured
96	89	not configured
96	90	not configured
96	91	not configured
96	92	not configured
96	93	not configured
96	94	not configured
96	95	not configured
96	96	not configured
96	97	not configured
96	98	not configured
96	99	not configured
96	100	not configured
96	101	not configured
96	102	not configured
96	103	not configured
96	104	not configured
96	105	not configured
96	106	not configured
96	107	not configured
96	108	not configured
96	109	not configured
96	110	not configured
96	111	not configured
96	112	not configured
96	113	not configured
96	114	not configured
96	115	not configured
96	116	not configured
96	117	not configured
96	118	not configured
96	119	not configured
96	120	not configured
96	121	not configured
96	122	not configured
96	124	not configured
96	125	not configured
96	127	not configured
96	128	not configured
96	129	not configured
96	130	not configured
96	131	not configured
96	132	not configured
96	134	not configured
96	135	not configured
96	136	not configured
96	137	not configured
96	138	not configured
97	1	not configured
97	2	not configured
97	9	not configured
97	10	not configured
97	11	not configured
97	12	not configured
97	13	not configured
97	14	not configured
97	15	not configured
97	16	not configured
97	17	not configured
97	18	not configured
97	19	not configured
97	20	not configured
97	21	not configured
97	22	not configured
97	23	not configured
97	24	not configured
97	25	not configured
97	26	not configured
97	27	not configured
97	28	not configured
97	29	not configured
97	30	not configured
97	31	not configured
97	32	not configured
97	33	not configured
97	34	not configured
97	35	not configured
97	36	not configured
97	37	not configured
97	38	not configured
97	39	not configured
97	40	not configured
97	41	not configured
97	42	not configured
97	43	not configured
97	44	not configured
97	45	not configured
97	46	not configured
97	47	not configured
97	48	not configured
97	49	not configured
97	50	not configured
97	51	not configured
97	52	not configured
97	53	not configured
97	54	not configured
97	55	not configured
97	56	not configured
97	57	not configured
97	58	not configured
97	59	not configured
97	60	not configured
97	61	not configured
97	62	not configured
97	63	not configured
97	64	not configured
97	65	not configured
97	66	not configured
97	67	not configured
97	68	not configured
97	69	not configured
97	71	not configured
97	72	not configured
97	73	not configured
97	74	not configured
97	75	not configured
97	76	not configured
97	77	not configured
97	78	not configured
97	79	not configured
97	80	not configured
97	81	not configured
97	82	not configured
97	83	not configured
97	84	not configured
97	85	not configured
97	86	not configured
97	87	not configured
97	88	not configured
97	89	not configured
97	90	not configured
97	91	not configured
97	92	not configured
97	93	not configured
97	94	not configured
97	95	not configured
97	96	not configured
97	97	not configured
97	98	not configured
97	99	not configured
97	100	not configured
97	101	not configured
97	102	not configured
97	103	not configured
97	104	not configured
97	105	not configured
97	106	not configured
97	107	not configured
97	108	not configured
97	109	not configured
97	110	not configured
97	111	not configured
97	112	not configured
97	113	not configured
97	114	not configured
97	115	not configured
97	116	not configured
97	117	not configured
97	118	not configured
97	119	not configured
97	120	not configured
97	121	not configured
97	122	not configured
97	124	not configured
97	125	not configured
97	127	not configured
97	128	not configured
97	129	not configured
97	130	not configured
97	131	not configured
97	132	not configured
97	134	not configured
97	135	not configured
97	136	not configured
97	137	not configured
97	138	not configured
98	1	not configured
98	2	not configured
98	9	not configured
98	10	not configured
98	11	not configured
98	12	not configured
98	13	not configured
98	14	not configured
98	15	not configured
98	16	not configured
98	17	not configured
98	18	not configured
98	19	not configured
98	20	not configured
98	21	not configured
98	22	not configured
98	23	not configured
98	24	not configured
98	25	not configured
98	26	not configured
98	27	not configured
98	28	not configured
98	29	not configured
98	30	not configured
98	31	not configured
98	32	not configured
98	33	not configured
98	34	not configured
98	35	not configured
98	36	not configured
98	37	not configured
98	38	not configured
98	39	not configured
98	40	not configured
98	41	not configured
98	42	not configured
98	43	not configured
98	44	not configured
98	45	not configured
98	46	not configured
98	47	not configured
98	48	not configured
98	49	not configured
98	50	not configured
98	51	not configured
98	52	not configured
98	53	not configured
98	54	not configured
98	55	not configured
98	56	not configured
98	57	not configured
98	58	not configured
98	59	not configured
98	60	not configured
98	61	not configured
98	62	not configured
98	63	not configured
98	64	not configured
98	65	not configured
98	66	not configured
98	67	not configured
98	68	not configured
98	69	not configured
98	71	not configured
98	72	not configured
98	73	not configured
98	74	not configured
98	75	not configured
98	76	not configured
98	77	not configured
98	78	not configured
98	79	not configured
98	80	not configured
98	81	not configured
98	82	not configured
98	83	not configured
98	84	not configured
98	85	not configured
98	86	not configured
98	87	not configured
98	88	not configured
98	89	not configured
98	90	not configured
98	91	not configured
98	92	not configured
98	93	not configured
98	94	not configured
98	95	not configured
98	96	not configured
98	97	not configured
98	98	not configured
98	99	not configured
98	100	not configured
98	101	not configured
98	102	not configured
98	103	not configured
98	104	not configured
98	105	not configured
98	106	not configured
98	107	not configured
98	108	not configured
98	109	not configured
98	110	not configured
98	111	not configured
98	112	not configured
98	113	not configured
98	114	not configured
98	115	not configured
98	116	not configured
98	117	not configured
98	118	not configured
98	119	not configured
98	120	not configured
98	121	not configured
98	122	not configured
98	124	not configured
98	125	not configured
98	127	not configured
98	128	not configured
98	129	not configured
98	130	not configured
98	131	not configured
98	132	not configured
98	134	not configured
98	135	not configured
98	136	not configured
98	137	not configured
98	138	not configured
99	1	not configured
99	2	not configured
99	9	not configured
99	10	not configured
99	11	not configured
99	12	not configured
99	13	not configured
99	14	not configured
99	15	not configured
99	16	not configured
99	17	not configured
99	18	not configured
99	19	not configured
99	20	not configured
99	21	not configured
99	22	not configured
99	23	not configured
99	24	not configured
99	25	not configured
99	26	not configured
99	27	not configured
99	28	not configured
99	29	not configured
99	30	not configured
99	31	not configured
99	32	not configured
99	33	not configured
99	34	not configured
99	35	not configured
99	36	not configured
99	37	not configured
99	38	not configured
99	39	not configured
99	40	not configured
99	41	not configured
99	42	not configured
99	43	not configured
99	44	not configured
99	45	not configured
99	46	not configured
99	47	not configured
99	48	not configured
99	49	not configured
99	50	not configured
99	51	not configured
99	52	not configured
99	53	not configured
99	54	not configured
99	55	not configured
99	56	not configured
99	57	not configured
99	58	not configured
99	59	not configured
99	60	not configured
99	61	not configured
99	62	not configured
99	63	not configured
99	64	not configured
99	65	not configured
99	66	not configured
99	67	not configured
99	68	not configured
99	69	not configured
99	71	not configured
99	72	not configured
99	73	not configured
99	74	not configured
99	75	not configured
99	76	not configured
99	77	not configured
99	78	not configured
99	79	not configured
99	80	not configured
99	81	not configured
99	82	not configured
99	83	not configured
99	84	not configured
99	85	not configured
99	86	not configured
99	87	not configured
99	88	not configured
99	89	not configured
99	90	not configured
99	91	not configured
99	92	not configured
99	93	not configured
99	94	not configured
99	95	not configured
99	96	not configured
99	97	not configured
99	98	not configured
99	99	not configured
99	100	not configured
99	101	not configured
99	102	not configured
99	103	not configured
99	104	not configured
99	105	not configured
99	106	not configured
99	107	not configured
99	108	not configured
99	109	not configured
99	110	not configured
99	111	not configured
99	112	not configured
99	113	not configured
99	114	not configured
99	115	not configured
99	116	not configured
99	117	not configured
99	118	not configured
99	119	not configured
99	120	not configured
99	121	not configured
99	122	not configured
99	124	not configured
99	125	not configured
99	127	not configured
99	128	not configured
99	129	not configured
99	130	not configured
99	131	not configured
99	132	not configured
99	134	not configured
99	135	not configured
99	136	not configured
99	137	not configured
99	138	not configured
100	1	not configured
100	2	not configured
100	9	not configured
100	10	not configured
100	11	not configured
100	12	not configured
100	13	not configured
100	14	not configured
100	15	not configured
100	16	not configured
100	17	not configured
100	18	not configured
100	19	not configured
100	20	not configured
100	21	not configured
100	22	not configured
100	23	not configured
100	24	not configured
100	25	not configured
100	26	not configured
100	27	not configured
100	28	not configured
100	29	not configured
100	30	not configured
100	31	not configured
100	32	not configured
100	33	not configured
100	34	not configured
100	35	not configured
100	36	not configured
100	37	not configured
100	38	not configured
100	39	not configured
100	40	not configured
100	41	not configured
100	42	not configured
100	43	not configured
100	44	not configured
100	45	not configured
100	46	not configured
100	47	not configured
100	48	not configured
100	49	not configured
100	50	not configured
100	51	not configured
100	52	not configured
100	53	not configured
100	54	not configured
100	55	not configured
100	56	not configured
100	57	not configured
100	58	not configured
100	59	not configured
100	60	not configured
100	61	not configured
100	62	not configured
100	63	not configured
100	64	not configured
100	65	not configured
100	66	not configured
100	67	not configured
100	68	not configured
100	69	not configured
100	71	not configured
100	72	not configured
100	73	not configured
100	74	not configured
100	75	not configured
100	76	not configured
100	77	not configured
100	78	not configured
100	79	not configured
100	80	not configured
100	81	not configured
100	82	not configured
100	83	not configured
100	84	not configured
100	85	not configured
100	86	not configured
100	87	not configured
100	88	not configured
100	89	not configured
100	90	not configured
100	91	not configured
100	92	not configured
100	93	not configured
100	94	not configured
100	95	not configured
100	96	not configured
100	97	not configured
100	98	not configured
100	99	not configured
100	100	not configured
100	101	not configured
100	102	not configured
100	103	not configured
100	104	not configured
100	105	not configured
100	106	not configured
100	107	not configured
100	108	not configured
100	109	not configured
100	110	not configured
100	111	not configured
100	112	not configured
100	113	not configured
100	114	not configured
100	115	not configured
100	116	not configured
100	117	not configured
100	118	not configured
100	119	not configured
100	120	not configured
100	121	not configured
100	122	not configured
100	124	not configured
100	125	not configured
100	127	not configured
100	128	not configured
100	129	not configured
100	130	not configured
100	131	not configured
100	132	not configured
100	134	not configured
100	135	not configured
100	136	not configured
100	137	not configured
100	138	not configured
101	1	not configured
101	2	not configured
101	9	not configured
101	10	not configured
101	11	not configured
101	12	not configured
101	13	not configured
101	14	not configured
101	15	not configured
101	16	not configured
101	17	not configured
101	18	not configured
101	19	not configured
101	20	not configured
101	21	not configured
101	22	not configured
101	23	not configured
101	24	not configured
101	25	not configured
101	26	not configured
101	27	not configured
101	28	not configured
101	29	not configured
101	30	not configured
101	31	not configured
101	32	not configured
101	33	not configured
101	34	not configured
101	35	not configured
101	36	not configured
101	37	not configured
101	38	not configured
101	39	not configured
101	40	not configured
101	41	not configured
101	42	not configured
101	43	not configured
101	44	not configured
101	45	not configured
101	46	not configured
101	47	not configured
101	48	not configured
101	49	not configured
101	50	not configured
101	51	not configured
101	52	not configured
101	53	not configured
101	54	not configured
101	55	not configured
101	56	not configured
101	57	not configured
101	58	not configured
101	59	not configured
101	60	not configured
101	61	not configured
101	62	not configured
101	63	not configured
101	64	not configured
101	65	not configured
101	66	not configured
101	67	not configured
101	68	not configured
101	69	not configured
101	71	not configured
101	72	not configured
101	73	not configured
101	74	not configured
101	75	not configured
101	76	not configured
101	77	not configured
101	78	not configured
101	79	not configured
101	80	not configured
101	81	not configured
101	82	not configured
101	83	not configured
101	84	not configured
101	85	not configured
101	86	not configured
101	87	not configured
101	88	not configured
101	89	not configured
101	90	not configured
101	91	not configured
101	92	not configured
101	93	not configured
101	94	not configured
101	95	not configured
101	96	not configured
101	97	not configured
101	98	not configured
101	99	not configured
101	100	not configured
101	101	not configured
101	102	not configured
101	103	not configured
101	104	not configured
101	105	not configured
101	106	not configured
101	107	not configured
101	108	not configured
101	109	not configured
101	110	not configured
101	111	not configured
101	112	not configured
101	113	not configured
101	114	not configured
101	115	not configured
101	116	not configured
101	117	not configured
101	118	not configured
101	119	not configured
101	120	not configured
101	121	not configured
101	122	not configured
101	124	not configured
101	125	not configured
101	127	not configured
101	128	not configured
101	129	not configured
101	130	not configured
101	131	not configured
101	132	not configured
101	134	not configured
101	135	not configured
101	136	not configured
101	137	not configured
101	138	not configured
102	1	not configured
102	2	not configured
102	9	not configured
102	10	not configured
102	11	not configured
102	12	not configured
102	13	not configured
102	14	not configured
102	15	not configured
102	16	not configured
102	17	not configured
102	18	not configured
102	19	not configured
102	20	not configured
102	21	not configured
102	22	not configured
102	23	not configured
102	24	not configured
102	25	not configured
102	26	not configured
102	27	not configured
102	28	not configured
102	29	not configured
102	30	not configured
102	31	not configured
102	32	not configured
102	33	not configured
102	34	not configured
102	35	not configured
102	36	not configured
102	37	not configured
102	38	not configured
102	39	not configured
102	40	not configured
102	41	not configured
102	42	not configured
102	43	not configured
102	44	not configured
102	45	not configured
102	46	not configured
102	47	not configured
102	48	not configured
102	49	not configured
102	50	not configured
102	51	not configured
102	52	not configured
102	53	not configured
102	54	not configured
102	55	not configured
102	56	not configured
102	57	not configured
102	58	not configured
102	59	not configured
102	60	not configured
102	61	not configured
102	62	not configured
102	63	not configured
102	64	not configured
102	65	not configured
102	66	not configured
102	67	not configured
102	68	not configured
102	69	not configured
102	71	not configured
102	72	not configured
102	73	not configured
102	74	not configured
102	75	not configured
102	76	not configured
102	77	not configured
102	78	not configured
102	79	not configured
102	80	not configured
102	81	not configured
102	82	not configured
102	83	not configured
102	84	not configured
102	85	not configured
102	86	not configured
102	87	not configured
102	88	not configured
102	89	not configured
102	90	not configured
102	91	not configured
102	92	not configured
102	93	not configured
102	94	not configured
102	95	not configured
102	96	not configured
102	97	not configured
102	98	not configured
102	99	not configured
102	100	not configured
102	101	not configured
102	102	not configured
102	103	not configured
102	104	not configured
102	105	not configured
102	106	not configured
102	107	not configured
102	108	not configured
102	109	not configured
102	110	not configured
102	111	not configured
102	112	not configured
102	113	not configured
102	114	not configured
102	115	not configured
102	116	not configured
102	117	not configured
102	118	not configured
102	119	not configured
102	120	not configured
102	121	not configured
102	122	not configured
102	124	not configured
102	125	not configured
102	127	not configured
102	128	not configured
102	129	not configured
102	130	not configured
102	131	not configured
102	132	not configured
102	134	not configured
102	135	not configured
102	136	not configured
102	137	not configured
102	138	not configured
103	1	not configured
103	2	not configured
103	9	not configured
103	10	not configured
103	11	not configured
103	12	not configured
103	13	not configured
103	14	not configured
103	15	not configured
103	16	not configured
103	17	not configured
103	18	not configured
103	19	not configured
103	20	not configured
103	21	not configured
103	22	not configured
103	23	not configured
103	24	not configured
103	25	not configured
103	26	not configured
103	27	not configured
103	28	not configured
103	29	not configured
103	30	not configured
103	31	not configured
103	32	not configured
103	33	not configured
103	34	not configured
103	35	not configured
103	36	not configured
103	37	not configured
103	38	not configured
103	39	not configured
103	40	not configured
103	41	not configured
103	42	not configured
103	43	not configured
103	44	not configured
103	45	not configured
103	46	not configured
103	47	not configured
103	48	not configured
103	49	not configured
103	50	not configured
103	51	not configured
103	52	not configured
103	53	not configured
103	54	not configured
103	55	not configured
103	56	not configured
103	57	not configured
103	58	not configured
103	59	not configured
103	60	not configured
103	61	not configured
103	62	not configured
103	63	not configured
103	64	not configured
103	65	not configured
103	66	not configured
103	67	not configured
103	68	not configured
103	69	not configured
103	71	not configured
103	72	not configured
103	73	not configured
103	74	not configured
103	75	not configured
103	76	not configured
103	77	not configured
103	78	not configured
103	79	not configured
103	80	not configured
103	81	not configured
103	82	not configured
103	83	not configured
103	84	not configured
103	85	not configured
103	86	not configured
103	87	not configured
103	88	not configured
103	89	not configured
103	90	not configured
103	91	not configured
103	92	not configured
103	93	not configured
103	94	not configured
103	95	not configured
103	96	not configured
103	97	not configured
103	98	not configured
103	99	not configured
103	100	not configured
103	101	not configured
103	102	not configured
103	103	not configured
103	104	not configured
103	105	not configured
103	106	not configured
103	107	not configured
103	108	not configured
103	109	not configured
103	110	not configured
103	111	not configured
103	112	not configured
103	113	not configured
103	114	not configured
103	115	not configured
103	116	not configured
103	117	not configured
103	118	not configured
103	119	not configured
103	120	not configured
103	121	not configured
103	122	not configured
103	124	not configured
103	125	not configured
103	127	not configured
103	128	not configured
103	129	not configured
103	130	not configured
103	131	not configured
103	132	not configured
103	134	not configured
103	135	not configured
103	136	not configured
103	137	not configured
103	138	not configured
104	1	not configured
104	2	not configured
104	9	not configured
104	10	not configured
104	11	not configured
104	12	not configured
104	13	not configured
104	14	not configured
104	15	not configured
104	16	not configured
104	17	not configured
104	18	not configured
104	19	not configured
104	20	not configured
104	21	not configured
104	22	not configured
104	23	not configured
104	24	not configured
104	25	not configured
104	26	not configured
104	27	not configured
104	28	not configured
104	29	not configured
104	30	not configured
104	31	not configured
104	32	not configured
104	33	not configured
104	34	not configured
104	35	not configured
104	36	not configured
104	37	not configured
104	38	not configured
104	39	not configured
104	40	not configured
104	41	not configured
104	42	not configured
104	43	not configured
104	44	not configured
104	45	not configured
104	46	not configured
104	47	not configured
104	48	not configured
104	49	not configured
104	50	not configured
104	51	not configured
104	52	not configured
104	53	not configured
104	54	not configured
104	55	not configured
104	56	not configured
104	57	not configured
104	58	not configured
104	59	not configured
104	60	not configured
104	61	not configured
104	62	not configured
104	63	not configured
104	64	not configured
104	65	not configured
104	66	not configured
104	67	not configured
104	68	not configured
104	69	not configured
104	71	not configured
104	72	not configured
104	73	not configured
104	74	not configured
104	75	not configured
104	76	not configured
104	77	not configured
104	78	not configured
104	79	not configured
104	80	not configured
104	81	not configured
104	82	not configured
104	83	not configured
104	84	not configured
104	85	not configured
104	86	not configured
104	87	not configured
104	88	not configured
104	89	not configured
104	90	not configured
104	91	not configured
104	92	not configured
104	93	not configured
104	94	not configured
104	95	not configured
104	96	not configured
104	97	not configured
104	98	not configured
104	99	not configured
104	100	not configured
104	101	not configured
104	102	not configured
104	103	not configured
104	104	not configured
104	105	not configured
104	106	not configured
104	107	not configured
104	108	not configured
104	109	not configured
104	110	not configured
104	111	not configured
104	112	not configured
104	113	not configured
104	114	not configured
104	115	not configured
104	116	not configured
104	117	not configured
104	118	not configured
104	119	not configured
104	120	not configured
104	121	not configured
104	122	not configured
104	124	not configured
104	125	not configured
104	127	not configured
104	128	not configured
104	129	not configured
104	130	not configured
104	131	not configured
104	132	not configured
104	134	not configured
104	135	not configured
104	136	not configured
104	137	not configured
104	138	not configured
105	1	not configured
105	2	not configured
105	9	not configured
105	10	not configured
105	11	not configured
105	12	not configured
105	13	not configured
105	14	not configured
105	15	not configured
105	16	not configured
105	17	not configured
105	18	not configured
105	19	not configured
105	20	not configured
105	21	not configured
105	22	not configured
105	23	not configured
105	24	not configured
105	25	not configured
105	26	not configured
105	27	not configured
105	28	not configured
105	29	not configured
105	30	not configured
105	31	not configured
105	32	not configured
105	33	not configured
105	34	not configured
105	35	not configured
105	36	not configured
105	37	not configured
105	38	not configured
105	39	not configured
105	40	not configured
105	41	not configured
105	42	not configured
105	43	not configured
105	44	not configured
105	45	not configured
105	46	not configured
105	47	not configured
105	48	not configured
105	49	not configured
105	50	not configured
105	51	not configured
105	52	not configured
105	53	not configured
105	54	not configured
105	55	not configured
105	56	not configured
105	57	not configured
105	58	not configured
105	59	not configured
105	60	not configured
105	61	not configured
105	62	not configured
105	63	not configured
105	64	not configured
105	65	not configured
105	66	not configured
105	67	not configured
105	68	not configured
105	69	not configured
105	71	not configured
105	72	not configured
105	73	not configured
105	74	not configured
105	75	not configured
105	76	not configured
105	77	not configured
105	78	not configured
105	79	not configured
105	80	not configured
105	81	not configured
105	82	not configured
105	83	not configured
105	84	not configured
105	85	not configured
105	86	not configured
105	87	not configured
105	88	not configured
105	89	not configured
105	90	not configured
105	91	not configured
105	92	not configured
105	93	not configured
105	94	not configured
105	95	not configured
105	96	not configured
105	97	not configured
105	98	not configured
105	99	not configured
105	100	not configured
105	101	not configured
105	102	not configured
105	103	not configured
105	104	not configured
105	105	not configured
105	106	not configured
105	107	not configured
105	108	not configured
105	109	not configured
105	110	not configured
105	111	not configured
105	112	not configured
105	113	not configured
105	114	not configured
105	115	not configured
105	116	not configured
105	117	not configured
105	118	not configured
105	119	not configured
105	120	not configured
105	121	not configured
105	122	not configured
105	124	not configured
105	125	not configured
105	127	not configured
105	128	not configured
105	129	not configured
105	130	not configured
105	131	not configured
105	132	not configured
105	134	not configured
105	135	not configured
105	136	not configured
105	137	not configured
105	138	not configured
106	1	not configured
106	2	not configured
106	9	not configured
106	10	not configured
106	11	not configured
106	12	not configured
106	13	not configured
106	14	not configured
106	15	not configured
106	16	not configured
106	17	not configured
106	18	not configured
106	19	not configured
106	20	not configured
106	21	not configured
106	22	not configured
106	23	not configured
106	24	not configured
106	25	not configured
106	26	not configured
106	27	not configured
106	28	not configured
106	29	not configured
106	30	not configured
106	31	not configured
106	32	not configured
106	33	not configured
106	34	not configured
106	35	not configured
106	36	not configured
106	37	not configured
106	38	not configured
106	39	not configured
106	40	not configured
106	41	not configured
106	42	not configured
106	43	not configured
106	44	not configured
106	45	not configured
106	46	not configured
106	47	not configured
106	48	not configured
106	49	not configured
106	50	not configured
106	51	not configured
106	52	not configured
106	53	not configured
106	54	not configured
106	55	not configured
106	56	not configured
106	57	not configured
106	58	not configured
106	59	not configured
106	60	not configured
106	61	not configured
106	62	not configured
106	63	not configured
106	64	not configured
106	65	not configured
106	66	not configured
106	67	not configured
106	68	not configured
106	69	not configured
106	71	not configured
106	72	not configured
106	73	not configured
106	74	not configured
106	75	not configured
106	76	not configured
106	77	not configured
106	78	not configured
106	79	not configured
106	80	not configured
106	81	not configured
106	82	not configured
106	83	not configured
106	84	not configured
106	85	not configured
106	86	not configured
106	87	not configured
106	88	not configured
106	89	not configured
106	90	not configured
106	91	not configured
106	92	not configured
106	93	not configured
106	94	not configured
106	95	not configured
106	96	not configured
106	97	not configured
106	98	not configured
106	99	not configured
106	100	not configured
106	101	not configured
106	102	not configured
106	103	not configured
106	104	not configured
106	105	not configured
106	106	not configured
106	107	not configured
106	108	not configured
106	109	not configured
106	110	not configured
106	111	not configured
106	112	not configured
106	113	not configured
106	114	not configured
106	115	not configured
106	116	not configured
106	117	not configured
106	118	not configured
106	119	not configured
106	120	not configured
106	121	not configured
106	122	not configured
106	124	not configured
106	125	not configured
106	127	not configured
106	128	not configured
106	129	not configured
106	130	not configured
106	131	not configured
106	132	not configured
106	134	not configured
106	135	not configured
106	136	not configured
106	137	not configured
106	138	not configured
107	1	not configured
107	2	not configured
107	9	not configured
107	10	not configured
107	11	not configured
107	12	not configured
107	13	not configured
107	14	not configured
107	15	not configured
107	16	not configured
107	17	not configured
107	18	not configured
107	19	not configured
107	20	not configured
107	21	not configured
107	22	not configured
107	23	not configured
107	24	not configured
107	25	not configured
107	26	not configured
107	27	not configured
107	28	not configured
107	29	not configured
107	30	not configured
107	31	not configured
107	32	not configured
107	33	not configured
107	34	not configured
107	35	not configured
107	36	not configured
107	37	not configured
107	38	not configured
107	39	not configured
107	40	not configured
107	41	not configured
107	42	not configured
107	43	not configured
107	44	not configured
107	45	not configured
107	46	not configured
107	47	not configured
107	48	not configured
107	49	not configured
107	50	not configured
107	51	not configured
107	52	not configured
107	53	not configured
107	54	not configured
107	55	not configured
107	56	not configured
107	57	not configured
107	58	not configured
107	59	not configured
107	60	not configured
107	61	not configured
107	62	not configured
107	63	not configured
107	64	not configured
107	65	not configured
107	66	not configured
107	67	not configured
107	68	not configured
107	69	not configured
107	71	not configured
107	72	not configured
107	73	not configured
107	74	not configured
107	75	not configured
107	76	not configured
107	77	not configured
107	78	not configured
107	79	not configured
107	80	not configured
107	81	not configured
107	82	not configured
107	83	not configured
107	84	not configured
107	85	not configured
107	86	not configured
107	87	not configured
107	88	not configured
107	89	not configured
107	90	not configured
107	91	not configured
107	92	not configured
107	93	not configured
107	94	not configured
107	95	not configured
107	96	not configured
107	97	not configured
107	98	not configured
107	99	not configured
107	100	not configured
107	101	not configured
107	102	not configured
107	103	not configured
107	104	not configured
107	105	not configured
107	106	not configured
107	107	not configured
107	108	not configured
107	109	not configured
107	110	not configured
107	111	not configured
107	112	not configured
107	113	not configured
107	114	not configured
107	115	not configured
107	116	not configured
107	117	not configured
107	118	not configured
107	119	not configured
107	120	not configured
107	121	not configured
107	122	not configured
107	124	not configured
107	125	not configured
107	127	not configured
107	128	not configured
107	129	not configured
107	130	not configured
107	131	not configured
107	132	not configured
107	134	not configured
107	135	not configured
107	136	not configured
107	137	not configured
107	138	not configured
108	1	not configured
108	2	not configured
108	9	not configured
108	10	not configured
108	11	not configured
108	12	not configured
108	13	not configured
108	14	not configured
108	15	not configured
108	16	not configured
108	17	not configured
108	18	not configured
108	19	not configured
108	20	not configured
108	21	not configured
108	22	not configured
108	23	not configured
108	24	not configured
108	25	not configured
108	26	not configured
108	27	not configured
108	28	not configured
108	29	not configured
108	30	not configured
108	31	not configured
108	32	not configured
108	33	not configured
108	34	not configured
108	35	not configured
108	36	not configured
108	37	not configured
108	38	not configured
108	39	not configured
108	40	not configured
108	41	not configured
108	42	not configured
108	43	not configured
108	44	not configured
108	45	not configured
108	46	not configured
108	47	not configured
108	48	not configured
108	49	not configured
108	50	not configured
108	51	not configured
108	52	not configured
108	53	not configured
108	54	not configured
108	55	not configured
108	56	not configured
108	57	not configured
108	58	not configured
108	59	not configured
108	60	not configured
108	61	not configured
108	62	not configured
108	63	not configured
108	64	not configured
108	65	not configured
108	66	not configured
108	67	not configured
108	68	not configured
108	69	not configured
108	71	not configured
108	72	not configured
108	73	not configured
108	74	not configured
108	75	not configured
108	76	not configured
108	77	not configured
108	78	not configured
108	79	not configured
108	80	not configured
108	81	not configured
108	82	not configured
108	83	not configured
108	84	not configured
108	85	not configured
108	86	not configured
108	87	not configured
108	88	not configured
108	89	not configured
108	90	not configured
108	91	not configured
108	92	not configured
108	93	not configured
108	94	not configured
108	95	not configured
108	96	not configured
108	97	not configured
108	98	not configured
108	99	not configured
108	100	not configured
108	101	not configured
108	102	not configured
108	103	not configured
108	104	not configured
108	105	not configured
108	106	not configured
108	107	not configured
108	108	not configured
108	109	not configured
108	110	not configured
108	111	not configured
108	112	not configured
108	113	not configured
108	114	not configured
108	115	not configured
108	116	not configured
108	117	not configured
108	118	not configured
108	119	not configured
108	120	not configured
108	121	not configured
108	122	not configured
108	124	not configured
108	125	not configured
108	127	not configured
108	128	not configured
108	129	not configured
108	130	not configured
108	131	not configured
108	132	not configured
108	134	not configured
108	135	not configured
108	136	not configured
108	137	not configured
108	138	not configured
109	1	not configured
109	2	not configured
109	9	not configured
109	10	not configured
109	11	not configured
109	12	not configured
109	13	not configured
109	14	not configured
109	15	not configured
109	16	not configured
109	17	not configured
109	18	not configured
109	19	not configured
109	20	not configured
109	21	not configured
109	22	not configured
109	23	not configured
109	24	not configured
109	25	not configured
109	26	not configured
109	27	not configured
109	28	not configured
109	29	not configured
109	30	not configured
109	31	not configured
109	32	not configured
109	33	not configured
109	34	not configured
109	35	not configured
109	36	not configured
109	37	not configured
109	38	not configured
109	39	not configured
109	40	not configured
109	41	not configured
109	42	not configured
109	43	not configured
109	44	not configured
109	45	not configured
109	46	not configured
109	47	not configured
109	48	not configured
109	49	not configured
109	50	not configured
109	51	not configured
109	52	not configured
109	53	not configured
109	54	not configured
109	55	not configured
109	56	not configured
109	57	not configured
109	58	not configured
109	59	not configured
109	60	not configured
109	61	not configured
109	62	not configured
109	63	not configured
109	64	not configured
109	65	not configured
109	66	not configured
109	67	not configured
109	68	not configured
109	69	not configured
109	71	not configured
109	72	not configured
109	73	not configured
109	74	not configured
109	75	not configured
109	76	not configured
109	77	not configured
109	78	not configured
109	79	not configured
109	80	not configured
109	81	not configured
109	82	not configured
109	83	not configured
109	84	not configured
109	85	not configured
109	86	not configured
109	87	not configured
109	88	not configured
109	89	not configured
109	90	not configured
109	91	not configured
109	92	not configured
109	93	not configured
109	94	not configured
109	95	not configured
109	96	not configured
109	97	not configured
109	98	not configured
109	99	not configured
109	100	not configured
109	101	not configured
109	102	not configured
109	103	not configured
109	104	not configured
109	105	not configured
109	106	not configured
109	107	not configured
109	108	not configured
109	109	not configured
109	110	not configured
109	111	not configured
109	112	not configured
109	113	not configured
109	114	not configured
109	115	not configured
109	116	not configured
109	117	not configured
109	118	not configured
109	119	not configured
109	120	not configured
109	121	not configured
109	122	not configured
109	124	not configured
109	125	not configured
109	127	not configured
109	128	not configured
109	129	not configured
109	130	not configured
109	131	not configured
109	132	not configured
109	134	not configured
109	135	not configured
109	136	not configured
109	137	not configured
109	138	not configured
110	1	not configured
110	2	not configured
110	9	not configured
110	10	not configured
110	11	not configured
110	12	not configured
110	13	not configured
110	14	not configured
110	15	not configured
110	16	not configured
110	17	not configured
110	18	not configured
110	19	not configured
110	20	not configured
110	21	not configured
110	22	not configured
110	23	not configured
110	24	not configured
110	25	not configured
110	26	not configured
110	27	not configured
110	28	not configured
110	29	not configured
110	30	not configured
110	31	not configured
110	32	not configured
110	33	not configured
110	34	not configured
110	35	not configured
110	36	not configured
110	37	not configured
110	38	not configured
110	39	not configured
110	40	not configured
110	41	not configured
110	42	not configured
110	43	not configured
110	44	not configured
110	45	not configured
110	46	not configured
110	47	not configured
110	48	not configured
110	49	not configured
110	50	not configured
110	51	not configured
110	52	not configured
110	53	not configured
110	54	not configured
110	55	not configured
110	56	not configured
110	57	not configured
110	58	not configured
110	59	not configured
110	60	not configured
110	61	not configured
110	62	not configured
110	63	not configured
110	64	not configured
110	65	not configured
110	66	not configured
110	67	not configured
110	68	not configured
110	69	not configured
110	71	not configured
110	72	not configured
110	73	not configured
110	74	not configured
110	75	not configured
110	76	not configured
110	77	not configured
110	78	not configured
110	79	not configured
110	80	not configured
110	81	not configured
110	82	not configured
110	83	not configured
110	84	not configured
110	85	not configured
110	86	not configured
110	87	not configured
110	88	not configured
110	89	not configured
110	90	not configured
110	91	not configured
110	92	not configured
110	93	not configured
110	94	not configured
110	95	not configured
110	96	not configured
110	97	not configured
110	98	not configured
110	99	not configured
110	100	not configured
110	101	not configured
110	102	not configured
110	103	not configured
110	104	not configured
110	105	not configured
110	106	not configured
110	107	not configured
110	108	not configured
110	109	not configured
110	110	not configured
110	111	not configured
110	112	not configured
110	113	not configured
110	114	not configured
110	115	not configured
110	116	not configured
110	117	not configured
110	118	not configured
110	119	not configured
110	120	not configured
110	121	not configured
110	122	not configured
110	124	not configured
110	125	not configured
110	127	not configured
110	128	not configured
110	129	not configured
110	130	not configured
110	131	not configured
110	132	not configured
110	134	not configured
110	135	not configured
110	136	not configured
110	137	not configured
110	138	not configured
111	1	not configured
111	2	not configured
111	9	not configured
111	10	not configured
111	11	not configured
111	12	not configured
111	13	not configured
111	14	not configured
111	15	not configured
111	16	not configured
111	17	not configured
111	18	not configured
111	19	not configured
111	20	not configured
111	21	not configured
111	22	not configured
111	23	not configured
111	24	not configured
111	25	not configured
111	26	not configured
111	27	not configured
111	28	not configured
111	29	not configured
111	30	not configured
111	31	not configured
111	32	not configured
111	33	not configured
111	34	not configured
111	35	not configured
111	36	not configured
111	37	not configured
111	38	not configured
111	39	not configured
111	40	not configured
111	41	not configured
111	42	not configured
111	43	not configured
111	44	not configured
111	45	not configured
111	46	not configured
111	47	not configured
111	48	not configured
111	49	not configured
111	50	not configured
111	51	not configured
111	52	not configured
111	53	not configured
111	54	not configured
111	55	not configured
111	56	not configured
111	57	not configured
111	58	not configured
111	59	not configured
111	60	not configured
111	61	not configured
111	62	not configured
111	63	not configured
111	64	not configured
111	65	not configured
111	66	not configured
111	67	not configured
111	68	not configured
111	69	not configured
111	71	not configured
111	72	not configured
111	73	not configured
111	74	not configured
111	75	not configured
111	76	not configured
111	77	not configured
111	78	not configured
111	79	not configured
111	80	not configured
111	81	not configured
111	82	not configured
111	83	not configured
111	84	not configured
111	85	not configured
111	86	not configured
111	87	not configured
111	88	not configured
111	89	not configured
111	90	not configured
111	91	not configured
111	92	not configured
111	93	not configured
111	94	not configured
111	95	not configured
111	96	not configured
111	97	not configured
111	98	not configured
111	99	not configured
111	100	not configured
111	101	not configured
111	102	not configured
111	103	not configured
111	104	not configured
111	105	not configured
111	106	not configured
111	107	not configured
111	108	not configured
111	109	not configured
111	110	not configured
111	111	not configured
111	112	not configured
111	113	not configured
111	114	not configured
111	115	not configured
111	116	not configured
111	117	not configured
111	118	not configured
111	119	not configured
111	120	not configured
111	121	not configured
111	122	not configured
111	124	not configured
111	125	not configured
111	127	not configured
111	128	not configured
111	129	not configured
111	130	not configured
111	131	not configured
111	132	not configured
111	134	not configured
111	135	not configured
111	136	not configured
111	137	not configured
111	138	not configured
112	1	not configured
112	2	not configured
112	9	not configured
112	10	not configured
112	11	not configured
112	12	not configured
112	13	not configured
112	14	not configured
112	15	not configured
112	16	not configured
112	17	not configured
112	18	not configured
112	19	not configured
112	20	not configured
112	21	not configured
112	22	not configured
112	23	not configured
112	24	not configured
112	25	not configured
112	26	not configured
112	27	not configured
112	28	not configured
112	29	not configured
112	30	not configured
112	31	not configured
112	32	not configured
112	33	not configured
112	34	not configured
112	35	not configured
112	36	not configured
112	37	not configured
112	38	not configured
112	39	not configured
112	40	not configured
112	41	not configured
112	42	not configured
112	43	not configured
112	44	not configured
112	45	not configured
112	46	not configured
112	47	not configured
112	48	not configured
112	49	not configured
112	50	not configured
112	51	not configured
112	52	not configured
112	53	not configured
112	54	not configured
112	55	not configured
112	56	not configured
112	57	not configured
112	58	not configured
112	59	not configured
112	60	not configured
112	61	not configured
112	62	not configured
112	63	not configured
112	64	not configured
112	65	not configured
112	66	not configured
112	67	not configured
112	68	not configured
112	69	not configured
112	71	not configured
112	72	not configured
112	73	not configured
112	74	not configured
112	75	not configured
112	76	not configured
112	77	not configured
112	78	not configured
112	79	not configured
112	80	not configured
112	81	not configured
112	82	not configured
112	83	not configured
112	84	not configured
112	85	not configured
112	86	not configured
112	87	not configured
112	88	not configured
112	89	not configured
112	90	not configured
112	91	not configured
112	92	not configured
112	93	not configured
112	94	not configured
112	95	not configured
112	96	not configured
112	97	not configured
112	98	not configured
112	99	not configured
112	100	not configured
112	101	not configured
112	102	not configured
112	103	not configured
112	104	not configured
112	105	not configured
112	106	not configured
112	107	not configured
112	108	not configured
112	109	not configured
112	110	not configured
112	111	not configured
112	112	not configured
112	113	not configured
112	114	not configured
112	115	not configured
112	116	not configured
112	117	not configured
112	118	not configured
112	119	not configured
112	120	not configured
112	121	not configured
112	122	not configured
112	124	not configured
112	125	not configured
112	127	not configured
112	128	not configured
112	129	not configured
112	130	not configured
112	131	not configured
112	132	not configured
112	134	not configured
112	135	not configured
112	136	not configured
112	137	not configured
112	138	not configured
113	1	not configured
113	2	not configured
113	9	not configured
113	10	not configured
113	11	not configured
113	12	not configured
113	13	not configured
113	14	not configured
113	15	not configured
113	16	not configured
113	17	not configured
113	18	not configured
113	19	not configured
113	20	not configured
113	21	not configured
113	22	not configured
113	23	not configured
113	24	not configured
113	25	not configured
113	26	not configured
113	27	not configured
113	28	not configured
113	29	not configured
113	30	not configured
113	31	not configured
113	32	not configured
113	33	not configured
113	34	not configured
113	35	not configured
113	36	not configured
113	37	not configured
113	38	not configured
113	39	not configured
113	40	not configured
113	41	not configured
113	42	not configured
113	43	not configured
113	44	not configured
113	45	not configured
113	46	not configured
113	47	not configured
113	48	not configured
113	49	not configured
113	50	not configured
113	51	not configured
113	52	not configured
113	53	not configured
113	54	not configured
113	55	not configured
113	56	not configured
113	57	not configured
113	58	not configured
113	59	not configured
113	60	not configured
113	61	not configured
113	62	not configured
113	63	not configured
113	64	not configured
113	65	not configured
113	66	not configured
113	67	not configured
113	68	not configured
113	69	not configured
113	71	not configured
113	72	not configured
113	73	not configured
113	74	not configured
113	75	not configured
113	76	not configured
113	77	not configured
113	78	not configured
113	79	not configured
113	80	not configured
113	81	not configured
113	82	not configured
113	83	not configured
113	84	not configured
113	85	not configured
113	86	not configured
113	87	not configured
113	88	not configured
113	89	not configured
113	90	not configured
113	91	not configured
113	92	not configured
113	93	not configured
113	94	not configured
113	95	not configured
113	96	not configured
113	97	not configured
113	98	not configured
113	99	not configured
113	100	not configured
113	101	not configured
113	102	not configured
113	103	not configured
113	104	not configured
113	105	not configured
113	106	not configured
113	107	not configured
113	108	not configured
113	109	not configured
113	110	not configured
113	111	not configured
113	112	not configured
113	113	not configured
113	114	not configured
113	115	not configured
113	116	not configured
113	117	not configured
113	118	not configured
113	119	not configured
113	120	not configured
113	121	not configured
113	122	not configured
113	124	not configured
113	125	not configured
113	127	not configured
113	128	not configured
113	129	not configured
113	130	not configured
113	131	not configured
113	132	not configured
113	134	not configured
113	135	not configured
113	136	not configured
113	137	not configured
113	138	not configured
114	1	not configured
114	2	not configured
114	9	not configured
114	10	not configured
114	11	not configured
114	12	not configured
114	13	not configured
114	14	not configured
114	15	not configured
114	16	not configured
114	17	not configured
114	18	not configured
114	19	not configured
114	20	not configured
114	21	not configured
114	22	not configured
114	23	not configured
114	24	not configured
114	25	not configured
114	26	not configured
114	27	not configured
114	28	not configured
114	29	not configured
114	30	not configured
114	31	not configured
114	32	not configured
114	33	not configured
114	34	not configured
114	35	not configured
114	36	not configured
114	37	not configured
114	38	not configured
114	39	not configured
114	40	not configured
114	41	not configured
114	42	not configured
114	43	not configured
114	44	not configured
114	45	not configured
114	46	not configured
114	47	not configured
114	48	not configured
114	49	not configured
114	50	not configured
114	51	not configured
114	52	not configured
114	53	not configured
114	54	not configured
114	55	not configured
114	56	not configured
114	57	not configured
114	58	not configured
114	59	not configured
114	60	not configured
114	61	not configured
114	62	not configured
114	63	not configured
114	64	not configured
114	65	not configured
114	66	not configured
114	67	not configured
114	68	not configured
114	69	not configured
114	71	not configured
114	72	not configured
114	73	not configured
114	74	not configured
114	75	not configured
114	76	not configured
114	77	not configured
114	78	not configured
114	79	not configured
114	80	not configured
114	81	not configured
114	82	not configured
114	83	not configured
114	84	not configured
114	85	not configured
114	86	not configured
114	87	not configured
114	88	not configured
114	89	not configured
114	90	not configured
114	91	not configured
114	92	not configured
114	93	not configured
114	94	not configured
114	95	not configured
114	96	not configured
114	97	not configured
114	98	not configured
114	99	not configured
114	100	not configured
114	101	not configured
114	102	not configured
114	103	not configured
114	104	not configured
114	105	not configured
114	106	not configured
114	107	not configured
114	108	not configured
114	109	not configured
114	110	not configured
114	111	not configured
114	112	not configured
114	113	not configured
114	114	not configured
114	115	not configured
114	116	not configured
114	117	not configured
114	118	not configured
114	119	not configured
114	120	not configured
114	121	not configured
114	122	not configured
114	124	not configured
114	125	not configured
114	127	not configured
114	128	not configured
114	129	not configured
114	130	not configured
114	131	not configured
114	132	not configured
114	134	not configured
114	135	not configured
114	136	not configured
114	137	not configured
114	138	not configured
115	1	not configured
115	2	not configured
115	9	not configured
115	10	not configured
115	11	not configured
115	12	not configured
115	13	not configured
115	14	not configured
115	15	not configured
115	16	not configured
115	17	not configured
115	18	not configured
115	19	not configured
115	20	not configured
115	21	not configured
115	22	not configured
115	23	not configured
115	24	not configured
115	25	not configured
115	26	not configured
115	27	not configured
115	28	not configured
115	29	not configured
115	30	not configured
115	31	not configured
115	32	not configured
115	33	not configured
115	34	not configured
115	35	not configured
115	36	not configured
115	37	not configured
115	38	not configured
115	39	not configured
115	40	not configured
115	41	not configured
115	42	not configured
115	43	not configured
115	44	not configured
115	45	not configured
115	46	not configured
115	47	not configured
115	48	not configured
115	49	not configured
115	50	not configured
115	51	not configured
115	52	not configured
115	53	not configured
115	54	not configured
115	55	not configured
115	56	not configured
115	57	not configured
115	58	not configured
115	59	not configured
115	60	not configured
115	61	not configured
115	62	not configured
115	63	not configured
115	64	not configured
115	65	not configured
115	66	not configured
115	67	not configured
115	68	not configured
115	69	not configured
115	71	not configured
115	72	not configured
115	73	not configured
115	74	not configured
115	75	not configured
115	76	not configured
115	77	not configured
115	78	not configured
115	79	not configured
115	80	not configured
115	81	not configured
115	82	not configured
115	83	not configured
115	84	not configured
115	85	not configured
115	86	not configured
115	87	not configured
115	88	not configured
115	89	not configured
115	90	not configured
115	91	not configured
115	92	not configured
115	93	not configured
115	94	not configured
115	95	not configured
115	96	not configured
115	97	not configured
115	98	not configured
115	99	not configured
115	100	not configured
115	101	not configured
115	102	not configured
115	103	not configured
115	104	not configured
115	105	not configured
115	106	not configured
115	107	not configured
115	108	not configured
115	109	not configured
115	110	not configured
115	111	not configured
115	112	not configured
115	113	not configured
115	114	not configured
115	115	not configured
115	116	not configured
115	117	not configured
115	118	not configured
115	119	not configured
115	120	not configured
115	121	not configured
115	122	not configured
115	124	not configured
115	125	not configured
115	127	not configured
115	128	not configured
115	129	not configured
115	130	not configured
115	131	not configured
115	132	not configured
115	134	not configured
115	135	not configured
115	136	not configured
115	137	not configured
115	138	not configured
116	1	not configured
116	2	not configured
116	9	not configured
116	10	not configured
116	11	not configured
116	12	not configured
116	13	not configured
116	14	not configured
116	15	not configured
116	16	not configured
116	17	not configured
116	18	not configured
116	19	not configured
116	20	not configured
116	21	not configured
116	22	not configured
116	23	not configured
116	24	not configured
116	25	not configured
116	26	not configured
116	27	not configured
116	28	not configured
116	29	not configured
116	30	not configured
116	31	not configured
116	32	not configured
116	33	not configured
116	34	not configured
116	35	not configured
116	36	not configured
116	37	not configured
116	38	not configured
116	39	not configured
116	40	not configured
116	41	not configured
116	42	not configured
116	43	not configured
116	44	not configured
116	45	not configured
116	46	not configured
116	47	not configured
116	48	not configured
116	49	not configured
116	50	not configured
116	51	not configured
116	52	not configured
116	53	not configured
116	54	not configured
116	55	not configured
116	56	not configured
116	57	not configured
116	58	not configured
116	59	not configured
116	60	not configured
116	61	not configured
116	62	not configured
116	63	not configured
116	64	not configured
116	65	not configured
116	66	not configured
116	67	not configured
116	68	not configured
116	69	not configured
116	71	not configured
116	72	not configured
116	73	not configured
116	74	not configured
116	75	not configured
116	76	not configured
116	77	not configured
116	78	not configured
116	79	not configured
116	80	not configured
116	81	not configured
116	82	not configured
116	83	not configured
116	84	not configured
116	85	not configured
116	86	not configured
116	87	not configured
116	88	not configured
116	89	not configured
116	90	not configured
116	91	not configured
116	92	not configured
116	93	not configured
116	94	not configured
116	95	not configured
116	96	not configured
116	97	not configured
116	98	not configured
116	99	not configured
116	100	not configured
116	101	not configured
116	102	not configured
116	103	not configured
116	104	not configured
116	105	not configured
116	106	not configured
116	107	not configured
116	108	not configured
116	109	not configured
116	110	not configured
116	111	not configured
116	112	not configured
116	113	not configured
116	114	not configured
116	115	not configured
116	116	not configured
116	117	not configured
116	118	not configured
116	119	not configured
116	120	not configured
116	121	not configured
116	122	not configured
116	124	not configured
116	125	not configured
116	127	not configured
116	128	not configured
116	129	not configured
116	130	not configured
116	131	not configured
116	132	not configured
116	134	not configured
116	135	not configured
116	136	not configured
116	137	not configured
116	138	not configured
117	1	not configured
117	2	not configured
117	9	not configured
117	10	not configured
117	11	not configured
117	12	not configured
117	13	not configured
117	14	not configured
117	15	not configured
117	16	not configured
117	17	not configured
117	18	not configured
117	19	not configured
117	20	not configured
117	21	not configured
117	22	not configured
117	23	not configured
117	24	not configured
117	25	not configured
117	26	not configured
117	27	not configured
117	28	not configured
117	29	not configured
117	30	not configured
117	31	not configured
117	32	not configured
117	33	not configured
117	34	not configured
117	35	not configured
117	36	not configured
117	37	not configured
117	38	not configured
117	39	not configured
117	40	not configured
117	41	not configured
117	42	not configured
117	43	not configured
117	44	not configured
117	45	not configured
117	46	not configured
117	47	not configured
117	48	not configured
117	49	not configured
117	50	not configured
117	51	not configured
117	52	not configured
117	53	not configured
117	54	not configured
117	55	not configured
117	56	not configured
117	57	not configured
117	58	not configured
117	59	not configured
117	60	not configured
117	61	not configured
117	62	not configured
117	63	not configured
117	64	not configured
117	65	not configured
117	66	not configured
117	67	not configured
117	68	not configured
117	69	not configured
117	71	not configured
117	72	not configured
117	73	not configured
117	74	not configured
117	75	not configured
117	76	not configured
117	77	not configured
117	78	not configured
117	79	not configured
117	80	not configured
117	81	not configured
117	82	not configured
117	83	not configured
117	84	not configured
117	85	not configured
117	86	not configured
117	87	not configured
117	88	not configured
117	89	not configured
117	90	not configured
117	91	not configured
117	92	not configured
117	93	not configured
117	94	not configured
117	95	not configured
117	96	not configured
117	97	not configured
117	98	not configured
117	99	not configured
117	100	not configured
117	101	not configured
117	102	not configured
117	103	not configured
117	104	not configured
117	105	not configured
117	106	not configured
117	107	not configured
117	108	not configured
117	109	not configured
117	110	not configured
117	111	not configured
117	112	not configured
117	113	not configured
117	114	not configured
117	115	not configured
117	116	not configured
117	117	not configured
117	118	not configured
117	119	not configured
117	120	not configured
117	121	not configured
117	122	not configured
117	124	not configured
117	125	not configured
117	127	not configured
117	128	not configured
117	129	not configured
117	130	not configured
117	131	not configured
117	132	not configured
117	134	not configured
117	135	not configured
117	136	not configured
117	137	not configured
117	138	not configured
118	1	not configured
118	2	not configured
118	9	not configured
118	10	not configured
118	11	not configured
118	12	not configured
118	13	not configured
118	14	not configured
118	15	not configured
118	16	not configured
118	17	not configured
118	18	not configured
118	19	not configured
118	20	not configured
118	21	not configured
118	22	not configured
118	23	not configured
118	24	not configured
118	25	not configured
118	26	not configured
118	27	not configured
118	28	not configured
118	29	not configured
118	30	not configured
118	31	not configured
118	32	not configured
118	33	not configured
118	34	not configured
118	35	not configured
118	36	not configured
118	37	not configured
118	38	not configured
118	39	not configured
118	40	not configured
118	41	not configured
118	42	not configured
118	43	not configured
118	44	not configured
118	45	not configured
118	46	not configured
118	47	not configured
118	48	not configured
118	49	not configured
118	50	not configured
118	51	not configured
118	52	not configured
118	53	not configured
118	54	not configured
118	55	not configured
118	56	not configured
118	57	not configured
118	58	not configured
118	59	not configured
118	60	not configured
118	61	not configured
118	62	not configured
118	63	not configured
118	64	not configured
118	65	not configured
118	66	not configured
118	67	not configured
118	68	not configured
118	69	not configured
118	71	not configured
118	72	not configured
118	73	not configured
118	74	not configured
118	75	not configured
118	76	not configured
118	77	not configured
118	78	not configured
118	79	not configured
118	80	not configured
118	81	not configured
118	82	not configured
118	83	not configured
118	84	not configured
118	85	not configured
118	86	not configured
118	87	not configured
118	88	not configured
118	89	not configured
118	90	not configured
118	91	not configured
118	92	not configured
118	93	not configured
118	94	not configured
118	95	not configured
118	96	not configured
118	97	not configured
118	98	not configured
118	99	not configured
118	100	not configured
118	101	not configured
118	102	not configured
118	103	not configured
118	104	not configured
118	105	not configured
118	106	not configured
118	107	not configured
118	108	not configured
118	109	not configured
118	110	not configured
118	111	not configured
118	112	not configured
118	113	not configured
118	114	not configured
118	115	not configured
118	116	not configured
118	117	not configured
118	118	not configured
118	119	not configured
118	120	not configured
118	121	not configured
118	122	not configured
118	124	not configured
118	125	not configured
118	127	not configured
118	128	not configured
118	129	not configured
118	130	not configured
118	131	not configured
118	132	not configured
118	134	not configured
118	135	not configured
118	136	not configured
118	137	not configured
118	138	not configured
119	1	not configured
119	2	not configured
119	9	not configured
119	10	not configured
119	11	not configured
119	12	not configured
119	13	not configured
119	14	not configured
119	15	not configured
119	16	not configured
119	17	not configured
119	18	not configured
119	19	not configured
119	20	not configured
119	21	not configured
119	22	not configured
119	23	not configured
119	24	not configured
119	25	not configured
119	26	not configured
119	27	not configured
119	28	not configured
119	29	not configured
119	30	not configured
119	31	not configured
119	32	not configured
119	33	not configured
119	34	not configured
119	35	not configured
119	36	not configured
119	37	not configured
119	38	not configured
119	39	not configured
119	40	not configured
119	41	not configured
119	42	not configured
119	43	not configured
119	44	not configured
119	45	not configured
119	46	not configured
119	47	not configured
119	48	not configured
119	49	not configured
119	50	not configured
119	51	not configured
119	52	not configured
119	53	not configured
119	54	not configured
119	55	not configured
119	56	not configured
119	57	not configured
119	58	not configured
119	59	not configured
119	60	not configured
119	61	not configured
119	62	not configured
119	63	not configured
119	64	not configured
119	65	not configured
119	66	not configured
119	67	not configured
119	68	not configured
119	69	not configured
119	71	not configured
119	72	not configured
119	73	not configured
119	74	not configured
119	75	not configured
119	76	not configured
119	77	not configured
119	78	not configured
119	79	not configured
119	80	not configured
119	81	not configured
119	82	not configured
119	83	not configured
119	84	not configured
119	85	not configured
119	86	not configured
119	87	not configured
119	88	not configured
119	89	not configured
119	90	not configured
119	91	not configured
119	92	not configured
119	93	not configured
119	94	not configured
119	95	not configured
119	96	not configured
119	97	not configured
119	98	not configured
119	99	not configured
119	100	not configured
119	101	not configured
119	102	not configured
119	103	not configured
119	104	not configured
119	105	not configured
119	106	not configured
119	107	not configured
119	108	not configured
119	109	not configured
119	110	not configured
119	111	not configured
119	112	not configured
119	113	not configured
119	114	not configured
119	115	not configured
119	116	not configured
119	117	not configured
119	118	not configured
119	119	not configured
119	120	not configured
119	121	not configured
119	122	not configured
119	124	not configured
119	125	not configured
119	127	not configured
119	128	not configured
119	129	not configured
119	130	not configured
119	131	not configured
119	132	not configured
119	134	not configured
119	135	not configured
119	136	not configured
119	137	not configured
119	138	not configured
120	1	not configured
120	2	not configured
120	9	not configured
120	10	not configured
120	11	not configured
120	12	not configured
120	13	not configured
120	14	not configured
120	15	not configured
120	16	not configured
120	17	not configured
120	18	not configured
120	19	not configured
120	20	not configured
120	21	not configured
120	22	not configured
120	23	not configured
120	24	not configured
120	25	not configured
120	26	not configured
120	27	not configured
120	28	not configured
120	29	not configured
120	30	not configured
120	31	not configured
120	32	not configured
120	33	not configured
120	34	not configured
120	35	not configured
120	36	not configured
120	37	not configured
120	38	not configured
120	39	not configured
120	40	not configured
120	41	not configured
120	42	not configured
120	43	not configured
120	44	not configured
120	45	not configured
120	46	not configured
120	47	not configured
120	48	not configured
120	49	not configured
120	50	not configured
120	51	not configured
120	52	not configured
120	53	not configured
120	54	not configured
120	55	not configured
120	56	not configured
120	57	not configured
120	58	not configured
120	59	not configured
120	60	not configured
120	61	not configured
120	62	not configured
120	63	not configured
120	64	not configured
120	65	not configured
120	66	not configured
120	67	not configured
120	68	not configured
120	69	not configured
120	71	not configured
120	72	not configured
120	73	not configured
120	74	not configured
120	75	not configured
120	76	not configured
120	77	not configured
120	78	not configured
120	79	not configured
120	80	not configured
120	81	not configured
120	82	not configured
120	83	not configured
120	84	not configured
120	85	not configured
120	86	not configured
120	87	not configured
120	88	not configured
120	89	not configured
120	90	not configured
120	91	not configured
120	92	not configured
120	93	not configured
120	94	not configured
120	95	not configured
120	96	not configured
120	97	not configured
120	98	not configured
120	99	not configured
120	100	not configured
120	101	not configured
120	102	not configured
120	103	not configured
120	104	not configured
120	105	not configured
120	106	not configured
120	107	not configured
120	108	not configured
120	109	not configured
120	110	not configured
120	111	not configured
120	112	not configured
120	113	not configured
120	114	not configured
120	115	not configured
120	116	not configured
120	117	not configured
120	118	not configured
120	119	not configured
120	120	not configured
120	121	not configured
120	122	not configured
120	124	not configured
120	125	not configured
120	127	not configured
120	128	not configured
120	129	not configured
120	130	not configured
120	131	not configured
120	132	not configured
120	134	not configured
120	135	not configured
120	136	not configured
120	137	not configured
120	138	not configured
121	1	not configured
121	2	not configured
121	9	not configured
121	10	not configured
121	11	not configured
121	12	not configured
121	13	not configured
121	14	not configured
121	15	not configured
121	16	not configured
121	17	not configured
121	18	not configured
121	19	not configured
121	20	not configured
121	21	not configured
121	22	not configured
121	23	not configured
121	24	not configured
121	25	not configured
121	26	not configured
121	27	not configured
121	28	not configured
121	29	not configured
121	30	not configured
121	31	not configured
121	32	not configured
121	33	not configured
121	34	not configured
121	35	not configured
121	36	not configured
121	37	not configured
121	38	not configured
121	39	not configured
121	40	not configured
121	41	not configured
121	42	not configured
121	43	not configured
121	44	not configured
121	45	not configured
121	46	not configured
121	47	not configured
121	48	not configured
121	49	not configured
121	50	not configured
121	51	not configured
121	52	not configured
121	53	not configured
121	54	not configured
121	55	not configured
121	56	not configured
121	57	not configured
121	58	not configured
121	59	not configured
121	60	not configured
121	61	not configured
121	62	not configured
121	63	not configured
121	64	not configured
121	65	not configured
121	66	not configured
121	67	not configured
121	68	not configured
121	69	not configured
121	71	not configured
121	72	not configured
121	73	not configured
121	74	not configured
121	75	not configured
121	76	not configured
121	77	not configured
121	78	not configured
121	79	not configured
121	80	not configured
121	81	not configured
121	82	not configured
121	83	not configured
121	84	not configured
121	85	not configured
121	86	not configured
121	87	not configured
121	88	not configured
121	89	not configured
121	90	not configured
121	91	not configured
121	92	not configured
121	93	not configured
121	94	not configured
121	95	not configured
121	96	not configured
121	97	not configured
121	98	not configured
121	99	not configured
121	100	not configured
121	101	not configured
121	102	not configured
121	103	not configured
121	104	not configured
121	105	not configured
121	106	not configured
121	107	not configured
121	108	not configured
121	109	not configured
121	110	not configured
121	111	not configured
121	112	not configured
121	113	not configured
121	114	not configured
121	115	not configured
121	116	not configured
121	117	not configured
121	118	not configured
121	119	not configured
121	120	not configured
121	121	not configured
121	122	not configured
121	124	not configured
121	125	not configured
121	127	not configured
121	128	not configured
121	129	not configured
121	130	not configured
121	131	not configured
121	132	not configured
121	134	not configured
121	135	not configured
121	136	not configured
121	137	not configured
121	138	not configured
122	1	not configured
122	2	not configured
122	9	not configured
122	10	not configured
122	11	not configured
122	12	not configured
122	13	not configured
122	14	not configured
122	15	not configured
122	16	not configured
122	17	not configured
122	18	not configured
122	19	not configured
122	20	not configured
122	21	not configured
122	22	not configured
122	23	not configured
122	24	not configured
122	25	not configured
122	26	not configured
122	27	not configured
122	28	not configured
122	29	not configured
122	30	not configured
122	31	not configured
122	32	not configured
122	33	not configured
122	34	not configured
122	35	not configured
122	36	not configured
122	37	not configured
122	38	not configured
122	39	not configured
122	40	not configured
122	41	not configured
122	42	not configured
122	43	not configured
122	44	not configured
122	45	not configured
122	46	not configured
122	47	not configured
122	48	not configured
122	49	not configured
122	50	not configured
122	51	not configured
122	52	not configured
122	53	not configured
122	54	not configured
122	55	not configured
122	56	not configured
122	57	not configured
122	58	not configured
122	59	not configured
122	60	not configured
122	61	not configured
122	62	not configured
122	63	not configured
122	64	not configured
122	65	not configured
122	66	not configured
122	67	not configured
122	68	not configured
122	69	not configured
122	71	not configured
122	72	not configured
122	73	not configured
122	74	not configured
122	75	not configured
122	76	not configured
122	77	not configured
122	78	not configured
122	79	not configured
122	80	not configured
122	81	not configured
122	82	not configured
122	83	not configured
122	84	not configured
122	85	not configured
122	86	not configured
122	87	not configured
122	88	not configured
122	89	not configured
122	90	not configured
122	91	not configured
122	92	not configured
122	93	not configured
122	94	not configured
122	95	not configured
122	96	not configured
122	97	not configured
122	98	not configured
122	99	not configured
122	100	not configured
122	101	not configured
122	102	not configured
122	103	not configured
122	104	not configured
122	105	not configured
122	106	not configured
122	107	not configured
122	108	not configured
122	109	not configured
122	110	not configured
122	111	not configured
122	112	not configured
122	113	not configured
122	114	not configured
122	115	not configured
122	116	not configured
122	117	not configured
122	118	not configured
122	119	not configured
122	120	not configured
122	121	not configured
122	122	not configured
122	124	not configured
122	125	not configured
122	127	not configured
122	128	not configured
122	129	not configured
122	130	not configured
122	131	not configured
122	132	not configured
122	134	not configured
122	135	not configured
122	136	not configured
122	137	not configured
122	138	not configured
124	1	not configured
124	2	not configured
124	9	not configured
124	10	not configured
124	11	not configured
124	12	not configured
124	13	not configured
124	14	not configured
124	15	not configured
124	16	not configured
124	17	not configured
124	18	not configured
124	19	not configured
124	20	not configured
124	21	not configured
124	22	not configured
124	23	not configured
124	24	not configured
124	25	not configured
124	26	not configured
124	27	not configured
124	28	not configured
124	29	not configured
124	30	not configured
124	31	not configured
124	32	not configured
124	33	not configured
124	34	not configured
124	35	not configured
124	36	not configured
124	37	not configured
124	38	not configured
124	39	not configured
124	40	not configured
124	41	not configured
124	42	not configured
124	43	not configured
124	44	not configured
124	45	not configured
124	46	not configured
124	47	not configured
124	48	not configured
124	49	not configured
124	50	not configured
124	51	not configured
124	52	not configured
124	53	not configured
124	54	not configured
124	55	not configured
124	56	not configured
124	57	not configured
124	58	not configured
124	59	not configured
124	60	not configured
124	61	not configured
124	62	not configured
124	63	not configured
124	64	not configured
124	65	not configured
124	66	not configured
124	67	not configured
124	68	not configured
124	69	not configured
124	71	not configured
124	72	not configured
124	73	not configured
124	74	not configured
124	75	not configured
124	76	not configured
124	77	not configured
124	78	not configured
124	79	not configured
124	80	not configured
124	81	not configured
124	82	not configured
124	83	not configured
124	84	not configured
124	85	not configured
124	86	not configured
124	87	not configured
124	88	not configured
124	89	not configured
124	90	not configured
124	91	not configured
124	92	not configured
124	93	not configured
124	94	not configured
124	95	not configured
124	96	not configured
124	97	not configured
124	98	not configured
124	99	not configured
124	100	not configured
124	101	not configured
124	102	not configured
124	103	not configured
124	104	not configured
124	105	not configured
124	106	not configured
124	107	not configured
124	108	not configured
124	109	not configured
124	110	not configured
124	111	not configured
124	112	not configured
124	113	not configured
124	114	not configured
124	115	not configured
124	116	not configured
124	117	not configured
124	118	not configured
124	119	not configured
124	120	not configured
124	121	not configured
124	122	not configured
124	124	not configured
124	125	not configured
124	127	not configured
124	128	not configured
124	129	not configured
124	130	not configured
124	131	not configured
124	132	not configured
124	134	not configured
124	135	not configured
124	136	not configured
124	137	not configured
124	138	not configured
125	1	not configured
125	2	not configured
125	9	not configured
125	10	not configured
125	11	not configured
125	12	not configured
125	13	not configured
125	14	not configured
125	15	not configured
125	16	not configured
125	17	not configured
125	18	not configured
125	19	not configured
125	20	not configured
125	21	not configured
125	22	not configured
125	23	not configured
125	24	not configured
125	25	not configured
125	26	not configured
125	27	not configured
125	28	not configured
125	29	not configured
125	30	not configured
125	31	not configured
125	32	not configured
125	33	not configured
125	34	not configured
125	35	not configured
125	36	not configured
125	37	not configured
125	38	not configured
125	39	not configured
125	40	not configured
125	41	not configured
125	42	not configured
125	43	not configured
125	44	not configured
125	45	not configured
125	46	not configured
125	47	not configured
125	48	not configured
125	49	not configured
125	50	not configured
125	51	not configured
125	52	not configured
125	53	not configured
125	54	not configured
125	55	not configured
125	56	not configured
125	57	not configured
125	58	not configured
125	59	not configured
125	60	not configured
125	61	not configured
125	62	not configured
125	63	not configured
125	64	not configured
125	65	not configured
125	66	not configured
125	67	not configured
125	68	not configured
125	69	not configured
125	71	not configured
125	72	not configured
125	73	not configured
125	74	not configured
125	75	not configured
125	76	not configured
125	77	not configured
125	78	not configured
125	79	not configured
125	80	not configured
125	81	not configured
125	82	not configured
125	83	not configured
125	84	not configured
125	85	not configured
125	86	not configured
125	87	not configured
125	88	not configured
125	89	not configured
125	90	not configured
125	91	not configured
125	92	not configured
125	93	not configured
125	94	not configured
125	95	not configured
125	96	not configured
125	97	not configured
125	98	not configured
125	99	not configured
125	100	not configured
125	101	not configured
125	102	not configured
125	103	not configured
125	104	not configured
125	105	not configured
125	106	not configured
125	107	not configured
125	108	not configured
125	109	not configured
125	110	not configured
125	111	not configured
125	112	not configured
125	113	not configured
125	114	not configured
125	115	not configured
125	116	not configured
125	117	not configured
125	118	not configured
125	119	not configured
125	120	not configured
125	121	not configured
125	122	not configured
125	124	not configured
125	125	not configured
125	127	not configured
125	128	not configured
125	129	not configured
125	130	not configured
125	131	not configured
125	132	not configured
125	134	not configured
125	135	not configured
125	136	not configured
125	137	not configured
125	138	not configured
127	1	not configured
127	2	not configured
127	9	not configured
127	10	not configured
127	11	not configured
127	12	not configured
127	13	not configured
127	14	not configured
127	15	not configured
127	16	not configured
127	17	not configured
127	18	not configured
127	19	not configured
127	20	not configured
127	21	not configured
127	22	not configured
127	23	not configured
127	24	not configured
127	25	not configured
127	26	not configured
127	27	not configured
127	28	not configured
127	29	not configured
127	30	not configured
127	31	not configured
127	32	not configured
127	33	not configured
127	34	not configured
127	35	not configured
127	36	not configured
127	37	not configured
127	38	not configured
127	39	not configured
127	40	not configured
127	41	not configured
127	42	not configured
127	43	not configured
127	44	not configured
127	45	not configured
127	46	not configured
127	47	not configured
127	48	not configured
127	49	not configured
127	50	not configured
127	51	not configured
127	52	not configured
127	53	not configured
127	54	not configured
127	55	not configured
127	56	not configured
127	57	not configured
127	58	not configured
127	59	not configured
127	60	not configured
127	61	not configured
127	62	not configured
127	63	not configured
127	64	not configured
127	65	not configured
127	66	not configured
127	67	not configured
127	68	not configured
127	69	not configured
127	71	not configured
127	72	not configured
127	73	not configured
127	74	not configured
127	75	not configured
127	76	not configured
127	77	not configured
127	78	not configured
127	79	not configured
127	80	not configured
127	81	not configured
127	82	not configured
127	83	not configured
127	84	not configured
127	85	not configured
127	86	not configured
127	87	not configured
127	88	not configured
127	89	not configured
127	90	not configured
127	91	not configured
127	92	not configured
127	93	not configured
127	94	not configured
127	95	not configured
127	96	not configured
127	97	not configured
127	98	not configured
127	99	not configured
127	100	not configured
127	101	not configured
127	102	not configured
127	103	not configured
127	104	not configured
127	105	not configured
127	106	not configured
127	107	not configured
127	108	not configured
127	109	not configured
127	110	not configured
127	111	not configured
127	112	not configured
127	113	not configured
127	114	not configured
127	115	not configured
127	116	not configured
127	117	not configured
127	118	not configured
127	119	not configured
127	120	not configured
127	121	not configured
127	122	not configured
127	124	not configured
127	125	not configured
127	127	not configured
127	128	not configured
127	129	not configured
127	130	not configured
127	131	not configured
127	132	not configured
127	134	not configured
127	135	not configured
127	136	not configured
127	137	not configured
127	138	not configured
128	1	not configured
128	2	not configured
128	9	not configured
128	10	not configured
128	11	not configured
128	12	not configured
128	13	not configured
128	14	not configured
128	15	not configured
128	16	not configured
128	17	not configured
128	18	not configured
128	19	not configured
128	20	not configured
128	21	not configured
128	22	not configured
128	23	not configured
128	24	not configured
128	25	not configured
128	26	not configured
128	27	not configured
128	28	not configured
128	29	not configured
128	30	not configured
128	31	not configured
128	32	not configured
128	33	not configured
128	34	not configured
128	35	not configured
128	36	not configured
128	37	not configured
128	38	not configured
128	39	not configured
128	40	not configured
128	41	not configured
128	42	not configured
128	43	not configured
128	44	not configured
128	45	not configured
128	46	not configured
128	47	not configured
128	48	not configured
128	49	not configured
128	50	not configured
128	51	not configured
128	52	not configured
128	53	not configured
128	54	not configured
128	55	not configured
128	56	not configured
128	57	not configured
128	58	not configured
128	59	not configured
128	60	not configured
128	61	not configured
128	62	not configured
128	63	not configured
128	64	not configured
128	65	not configured
128	66	not configured
128	67	not configured
128	68	not configured
128	69	not configured
128	71	not configured
128	72	not configured
128	73	not configured
128	74	not configured
128	75	not configured
128	76	not configured
128	77	not configured
128	78	not configured
128	79	not configured
128	80	not configured
128	81	not configured
128	82	not configured
128	83	not configured
128	84	not configured
128	85	not configured
128	86	not configured
128	87	not configured
128	88	not configured
128	89	not configured
128	90	not configured
128	91	not configured
128	92	not configured
128	93	not configured
128	94	not configured
128	95	not configured
128	96	not configured
128	97	not configured
128	98	not configured
128	99	not configured
128	100	not configured
128	101	not configured
128	102	not configured
128	103	not configured
128	104	not configured
128	105	not configured
128	106	not configured
128	107	not configured
128	108	not configured
128	109	not configured
128	110	not configured
128	111	not configured
128	112	not configured
128	113	not configured
128	114	not configured
128	115	not configured
128	116	not configured
128	117	not configured
128	118	not configured
128	119	not configured
128	120	not configured
128	121	not configured
128	122	not configured
128	124	not configured
128	125	not configured
128	127	not configured
128	128	not configured
128	129	not configured
128	130	not configured
128	131	not configured
128	132	not configured
128	134	not configured
128	135	not configured
128	136	not configured
128	137	not configured
128	138	not configured
129	1	not configured
129	2	not configured
129	9	not configured
129	10	not configured
129	11	not configured
129	12	not configured
129	13	not configured
129	14	not configured
129	15	not configured
129	16	not configured
129	17	not configured
129	18	not configured
129	19	not configured
129	20	not configured
129	21	not configured
129	22	not configured
129	23	not configured
129	24	not configured
129	25	not configured
129	26	not configured
129	27	not configured
129	28	not configured
129	29	not configured
129	30	not configured
129	31	not configured
129	32	not configured
129	33	not configured
129	34	not configured
129	35	not configured
129	36	not configured
129	37	not configured
129	38	not configured
129	39	not configured
129	40	not configured
129	41	not configured
129	42	not configured
129	43	not configured
129	44	not configured
129	45	not configured
129	46	not configured
129	47	not configured
129	48	not configured
129	49	not configured
129	50	not configured
129	51	not configured
129	52	not configured
129	53	not configured
129	54	not configured
129	55	not configured
129	56	not configured
129	57	not configured
129	58	not configured
129	59	not configured
129	60	not configured
129	61	not configured
129	62	not configured
129	63	not configured
129	64	not configured
129	65	not configured
129	66	not configured
129	67	not configured
129	68	not configured
129	69	not configured
129	71	not configured
129	72	not configured
129	73	not configured
129	74	not configured
129	75	not configured
129	76	not configured
129	77	not configured
129	78	not configured
129	79	not configured
129	80	not configured
129	81	not configured
129	82	not configured
129	83	not configured
129	84	not configured
129	85	not configured
129	86	not configured
129	87	not configured
129	88	not configured
129	89	not configured
129	90	not configured
129	91	not configured
129	92	not configured
129	93	not configured
129	94	not configured
129	95	not configured
129	96	not configured
129	97	not configured
129	98	not configured
129	99	not configured
129	100	not configured
129	101	not configured
129	102	not configured
129	103	not configured
129	104	not configured
129	105	not configured
129	106	not configured
129	107	not configured
129	108	not configured
129	109	not configured
129	110	not configured
129	111	not configured
129	112	not configured
129	113	not configured
129	114	not configured
129	115	not configured
129	116	not configured
129	117	not configured
129	118	not configured
129	119	not configured
129	120	not configured
129	121	not configured
129	122	not configured
129	124	not configured
129	125	not configured
129	127	not configured
129	128	not configured
129	129	not configured
129	130	not configured
129	131	not configured
129	132	not configured
129	134	not configured
129	135	not configured
129	136	not configured
129	137	not configured
129	138	not configured
130	1	not configured
130	2	not configured
130	9	not configured
130	10	not configured
130	11	not configured
130	12	not configured
130	13	not configured
130	14	not configured
130	15	not configured
130	16	not configured
130	17	not configured
130	18	not configured
130	19	not configured
130	20	not configured
130	21	not configured
130	22	not configured
130	23	not configured
130	24	not configured
130	25	not configured
130	26	not configured
130	27	not configured
130	28	not configured
130	29	not configured
130	30	not configured
130	31	not configured
130	32	not configured
130	33	not configured
130	34	not configured
130	35	not configured
130	36	not configured
130	37	not configured
130	38	not configured
130	39	not configured
130	40	not configured
130	41	not configured
130	42	not configured
130	43	not configured
130	44	not configured
130	45	not configured
130	46	not configured
130	47	not configured
130	48	not configured
130	49	not configured
130	50	not configured
130	51	not configured
130	52	not configured
130	53	not configured
130	54	not configured
130	55	not configured
130	56	not configured
130	57	not configured
130	58	not configured
130	59	not configured
130	60	not configured
130	61	not configured
130	62	not configured
130	63	not configured
130	64	not configured
130	65	not configured
130	66	not configured
130	67	not configured
130	68	not configured
130	69	not configured
130	71	not configured
130	72	not configured
130	73	not configured
130	74	not configured
130	75	not configured
130	76	not configured
130	77	not configured
130	78	not configured
130	79	not configured
130	80	not configured
130	81	not configured
130	82	not configured
130	83	not configured
130	84	not configured
130	85	not configured
130	86	not configured
130	87	not configured
130	88	not configured
130	89	not configured
130	90	not configured
130	91	not configured
130	92	not configured
130	93	not configured
130	94	not configured
130	95	not configured
130	96	not configured
130	97	not configured
130	98	not configured
130	99	not configured
130	100	not configured
130	101	not configured
130	102	not configured
130	103	not configured
130	104	not configured
130	105	not configured
130	106	not configured
130	107	not configured
130	108	not configured
130	109	not configured
130	110	not configured
130	111	not configured
130	112	not configured
130	113	not configured
130	114	not configured
130	115	not configured
130	116	not configured
130	117	not configured
130	118	not configured
130	119	not configured
130	120	not configured
130	121	not configured
130	122	not configured
130	124	not configured
130	125	not configured
130	127	not configured
130	128	not configured
130	129	not configured
130	130	not configured
130	131	not configured
130	132	not configured
130	134	not configured
130	135	not configured
130	136	not configured
130	137	not configured
130	138	not configured
131	1	not configured
131	2	not configured
131	9	not configured
131	10	not configured
131	11	not configured
131	12	not configured
131	13	not configured
131	14	not configured
131	15	not configured
131	16	not configured
131	17	not configured
131	18	not configured
131	19	not configured
131	20	not configured
131	21	not configured
131	22	not configured
131	23	not configured
131	24	not configured
131	25	not configured
131	26	not configured
131	27	not configured
131	28	not configured
131	29	not configured
131	30	not configured
131	31	not configured
131	32	not configured
131	33	not configured
131	34	not configured
131	35	not configured
131	36	not configured
131	37	not configured
131	38	not configured
131	39	not configured
131	40	not configured
131	41	not configured
131	42	not configured
131	43	not configured
131	44	not configured
131	45	not configured
131	46	not configured
131	47	not configured
131	48	not configured
131	49	not configured
131	50	not configured
131	51	not configured
131	52	not configured
131	53	not configured
131	54	not configured
131	55	not configured
131	56	not configured
131	57	not configured
131	58	not configured
131	59	not configured
131	60	not configured
131	61	not configured
131	62	not configured
131	63	not configured
131	64	not configured
131	65	not configured
131	66	not configured
131	67	not configured
131	68	not configured
131	69	not configured
131	71	not configured
131	72	not configured
131	73	not configured
131	74	not configured
131	75	not configured
131	76	not configured
131	77	not configured
131	78	not configured
131	79	not configured
131	80	not configured
131	81	not configured
131	82	not configured
131	83	not configured
131	84	not configured
131	85	not configured
131	86	not configured
131	87	not configured
131	88	not configured
131	89	not configured
131	90	not configured
131	91	not configured
131	92	not configured
131	93	not configured
131	94	not configured
131	95	not configured
131	96	not configured
131	97	not configured
131	98	not configured
131	99	not configured
131	100	not configured
131	101	not configured
131	102	not configured
131	103	not configured
131	104	not configured
131	105	not configured
131	106	not configured
131	107	not configured
131	108	not configured
131	109	not configured
131	110	not configured
131	111	not configured
131	112	not configured
131	113	not configured
131	114	not configured
131	115	not configured
131	116	not configured
131	117	not configured
131	118	not configured
131	119	not configured
131	120	not configured
131	121	not configured
131	122	not configured
131	124	not configured
131	125	not configured
131	127	not configured
131	128	not configured
131	129	not configured
131	130	not configured
131	131	not configured
131	132	not configured
131	134	not configured
131	135	not configured
131	136	not configured
131	137	not configured
131	138	not configured
132	1	not configured
132	2	not configured
132	9	not configured
132	10	not configured
132	11	not configured
132	12	not configured
132	13	not configured
132	14	not configured
132	15	not configured
132	16	not configured
132	17	not configured
132	18	not configured
132	19	not configured
132	20	not configured
132	21	not configured
132	22	not configured
132	23	not configured
132	24	not configured
132	25	not configured
132	26	not configured
132	27	not configured
132	28	not configured
132	29	not configured
132	30	not configured
132	31	not configured
132	32	not configured
132	33	not configured
132	34	not configured
132	35	not configured
132	36	not configured
132	37	not configured
132	38	not configured
132	39	not configured
132	40	not configured
132	41	not configured
132	42	not configured
132	43	not configured
132	44	not configured
132	45	not configured
132	46	not configured
132	47	not configured
132	48	not configured
132	49	not configured
132	50	not configured
132	51	not configured
132	52	not configured
132	53	not configured
132	54	not configured
132	55	not configured
132	56	not configured
132	57	not configured
132	58	not configured
132	59	not configured
132	60	not configured
132	61	not configured
132	62	not configured
132	63	not configured
132	64	not configured
132	65	not configured
132	66	not configured
132	67	not configured
132	68	not configured
132	69	not configured
132	71	not configured
132	72	not configured
132	73	not configured
132	74	not configured
132	75	not configured
132	76	not configured
132	77	not configured
132	78	not configured
132	79	not configured
132	80	not configured
132	81	not configured
132	82	not configured
132	83	not configured
132	84	not configured
132	85	not configured
132	86	not configured
132	87	not configured
132	88	not configured
132	89	not configured
132	90	not configured
132	91	not configured
132	92	not configured
132	93	not configured
132	94	not configured
132	95	not configured
132	96	not configured
132	97	not configured
132	98	not configured
132	99	not configured
132	100	not configured
132	101	not configured
132	102	not configured
132	103	not configured
132	104	not configured
132	105	not configured
132	106	not configured
132	107	not configured
132	108	not configured
132	109	not configured
132	110	not configured
132	111	not configured
132	112	not configured
132	113	not configured
132	114	not configured
132	115	not configured
132	116	not configured
132	117	not configured
132	118	not configured
132	119	not configured
132	120	not configured
132	121	not configured
132	122	not configured
132	124	not configured
132	125	not configured
132	127	not configured
132	128	not configured
132	129	not configured
132	130	not configured
132	131	not configured
132	132	not configured
132	134	not configured
132	135	not configured
132	136	not configured
132	137	not configured
132	138	not configured
134	1	not configured
134	2	not configured
134	9	not configured
134	10	not configured
134	11	not configured
134	12	not configured
134	13	not configured
134	14	not configured
134	15	not configured
134	16	not configured
134	17	not configured
134	18	not configured
134	19	not configured
134	20	not configured
134	21	not configured
134	22	not configured
134	23	not configured
134	24	not configured
134	25	not configured
134	26	not configured
134	27	not configured
134	28	not configured
134	29	not configured
134	30	not configured
134	31	not configured
134	32	not configured
134	33	not configured
134	34	not configured
134	35	not configured
134	36	not configured
134	37	not configured
134	38	not configured
134	39	not configured
134	40	not configured
134	41	not configured
134	42	not configured
134	43	not configured
134	44	not configured
134	45	not configured
134	46	not configured
134	47	not configured
134	48	not configured
134	49	not configured
134	50	not configured
134	51	not configured
134	52	not configured
134	53	not configured
134	54	not configured
134	55	not configured
134	56	not configured
134	57	not configured
134	58	not configured
134	59	not configured
134	60	not configured
134	61	not configured
134	62	not configured
134	63	not configured
134	64	not configured
134	65	not configured
134	66	not configured
134	67	not configured
134	68	not configured
134	69	not configured
134	71	not configured
134	72	not configured
134	73	not configured
134	74	not configured
134	75	not configured
134	76	not configured
134	77	not configured
134	78	not configured
134	79	not configured
134	80	not configured
134	81	not configured
134	82	not configured
134	83	not configured
134	84	not configured
134	85	not configured
134	86	not configured
134	87	not configured
134	88	not configured
134	89	not configured
134	90	not configured
134	91	not configured
134	92	not configured
134	93	not configured
134	94	not configured
134	95	not configured
134	96	not configured
134	97	not configured
134	98	not configured
134	99	not configured
134	100	not configured
134	101	not configured
134	102	not configured
134	103	not configured
134	104	not configured
134	105	not configured
134	106	not configured
134	107	not configured
134	108	not configured
134	109	not configured
134	110	not configured
134	111	not configured
134	112	not configured
134	113	not configured
134	114	not configured
134	115	not configured
134	116	not configured
134	117	not configured
134	118	not configured
134	119	not configured
134	120	not configured
134	121	not configured
134	122	not configured
134	124	not configured
134	125	not configured
134	127	not configured
134	128	not configured
134	129	not configured
134	130	not configured
134	131	not configured
134	132	not configured
134	134	not configured
134	135	not configured
134	136	not configured
134	137	not configured
134	138	not configured
135	1	not configured
135	2	not configured
135	9	not configured
135	10	not configured
135	11	not configured
135	12	not configured
135	13	not configured
135	14	not configured
135	15	not configured
135	16	not configured
135	17	not configured
135	18	not configured
135	19	not configured
135	20	not configured
135	21	not configured
135	22	not configured
135	23	not configured
135	24	not configured
135	25	not configured
135	26	not configured
135	27	not configured
135	28	not configured
135	29	not configured
135	30	not configured
135	31	not configured
135	32	not configured
135	33	not configured
135	34	not configured
135	35	not configured
135	36	not configured
135	37	not configured
135	38	not configured
135	39	not configured
135	40	not configured
135	41	not configured
135	42	not configured
135	43	not configured
135	44	not configured
135	45	not configured
135	46	not configured
135	47	not configured
135	48	not configured
135	49	not configured
135	50	not configured
135	51	not configured
135	52	not configured
135	53	not configured
135	54	not configured
135	55	not configured
135	56	not configured
135	57	not configured
135	58	not configured
135	59	not configured
135	60	not configured
135	61	not configured
135	62	not configured
135	63	not configured
135	64	not configured
135	65	not configured
135	66	not configured
135	67	not configured
135	68	not configured
135	69	not configured
135	71	not configured
135	72	not configured
135	73	not configured
135	74	not configured
135	75	not configured
135	76	not configured
135	77	not configured
135	78	not configured
135	79	not configured
135	80	not configured
135	81	not configured
135	82	not configured
135	83	not configured
135	84	not configured
135	85	not configured
135	86	not configured
135	87	not configured
135	88	not configured
135	89	not configured
135	90	not configured
135	91	not configured
135	92	not configured
135	93	not configured
135	94	not configured
135	95	not configured
135	96	not configured
135	97	not configured
135	98	not configured
135	99	not configured
135	100	not configured
135	101	not configured
135	102	not configured
135	103	not configured
135	104	not configured
135	105	not configured
135	106	not configured
135	107	not configured
135	108	not configured
135	109	not configured
135	110	not configured
135	111	not configured
135	112	not configured
135	113	not configured
135	114	not configured
135	115	not configured
135	116	not configured
135	117	not configured
135	118	not configured
135	119	not configured
135	120	not configured
135	121	not configured
135	122	not configured
135	124	not configured
135	125	not configured
135	127	not configured
135	128	not configured
135	129	not configured
135	130	not configured
135	131	not configured
135	132	not configured
135	134	not configured
135	135	not configured
135	136	not configured
135	137	not configured
135	138	not configured
136	1	not configured
136	2	not configured
136	9	not configured
136	10	not configured
136	11	not configured
136	12	not configured
136	13	not configured
136	14	not configured
136	15	not configured
136	16	not configured
136	17	not configured
136	18	not configured
136	19	not configured
136	20	not configured
136	21	not configured
136	22	not configured
136	23	not configured
136	24	not configured
136	25	not configured
136	26	not configured
136	27	not configured
136	28	not configured
136	29	not configured
136	30	not configured
136	31	not configured
136	32	not configured
136	33	not configured
136	34	not configured
136	35	not configured
136	36	not configured
136	37	not configured
136	38	not configured
136	39	not configured
136	40	not configured
136	41	not configured
136	42	not configured
136	43	not configured
136	44	not configured
136	45	not configured
136	46	not configured
136	47	not configured
136	48	not configured
136	49	not configured
136	50	not configured
136	51	not configured
136	52	not configured
136	53	not configured
136	54	not configured
136	55	not configured
136	56	not configured
136	57	not configured
136	58	not configured
136	59	not configured
136	60	not configured
136	61	not configured
136	62	not configured
136	63	not configured
136	64	not configured
136	65	not configured
136	66	not configured
136	67	not configured
136	68	not configured
136	69	not configured
136	71	not configured
136	72	not configured
136	73	not configured
136	74	not configured
136	75	not configured
136	76	not configured
136	77	not configured
136	78	not configured
136	79	not configured
136	80	not configured
136	81	not configured
136	82	not configured
136	83	not configured
136	84	not configured
136	85	not configured
136	86	not configured
136	87	not configured
136	88	not configured
136	89	not configured
136	90	not configured
136	91	not configured
136	92	not configured
136	93	not configured
136	94	not configured
136	95	not configured
136	96	not configured
136	97	not configured
136	98	not configured
136	99	not configured
136	100	not configured
136	101	not configured
136	102	not configured
136	103	not configured
136	104	not configured
136	105	not configured
136	106	not configured
136	107	not configured
136	108	not configured
136	109	not configured
136	110	not configured
136	111	not configured
136	112	not configured
136	113	not configured
136	114	not configured
136	115	not configured
136	116	not configured
136	117	not configured
136	118	not configured
136	119	not configured
136	120	not configured
136	121	not configured
136	122	not configured
136	124	not configured
136	125	not configured
136	127	not configured
136	128	not configured
136	129	not configured
136	130	not configured
136	131	not configured
136	132	not configured
136	134	not configured
136	135	not configured
136	136	not configured
136	137	not configured
136	138	not configured
137	1	not configured
137	2	not configured
137	9	not configured
137	10	not configured
137	11	not configured
137	12	not configured
137	13	not configured
137	14	not configured
137	15	not configured
137	16	not configured
137	17	not configured
137	18	not configured
137	19	not configured
137	20	not configured
137	21	not configured
137	22	not configured
137	23	not configured
137	24	not configured
137	25	not configured
137	26	not configured
137	27	not configured
137	28	not configured
137	29	not configured
137	30	not configured
137	31	not configured
137	32	not configured
137	33	not configured
137	34	not configured
137	35	not configured
137	36	not configured
137	37	not configured
137	38	not configured
137	39	not configured
137	40	not configured
137	41	not configured
137	42	not configured
137	43	not configured
137	44	not configured
137	45	not configured
137	46	not configured
137	47	not configured
137	48	not configured
137	49	not configured
137	50	not configured
137	51	not configured
137	52	not configured
137	53	not configured
137	54	not configured
137	55	not configured
137	56	not configured
137	57	not configured
137	58	not configured
137	59	not configured
137	60	not configured
137	61	not configured
137	62	not configured
137	63	not configured
137	64	not configured
137	65	not configured
137	66	not configured
137	67	not configured
137	68	not configured
137	69	not configured
137	71	not configured
137	72	not configured
137	73	not configured
137	74	not configured
137	75	not configured
137	76	not configured
137	77	not configured
137	78	not configured
137	79	not configured
137	80	not configured
137	81	not configured
137	82	not configured
137	83	not configured
137	84	not configured
137	85	not configured
137	86	not configured
137	87	not configured
137	88	not configured
137	89	not configured
137	90	not configured
137	91	not configured
137	92	not configured
137	93	not configured
137	94	not configured
137	95	not configured
137	96	not configured
137	97	not configured
137	98	not configured
137	99	not configured
137	100	not configured
137	101	not configured
137	102	not configured
137	103	not configured
137	104	not configured
137	105	not configured
137	106	not configured
137	107	not configured
137	108	not configured
137	109	not configured
137	110	not configured
137	111	not configured
137	112	not configured
137	113	not configured
137	114	not configured
137	115	not configured
137	116	not configured
137	117	not configured
137	118	not configured
137	119	not configured
137	120	not configured
137	121	not configured
137	122	not configured
137	124	not configured
137	125	not configured
137	127	not configured
137	128	not configured
137	129	not configured
137	130	not configured
137	131	not configured
137	132	not configured
137	134	not configured
137	135	not configured
137	136	not configured
137	137	not configured
137	138	not configured
138	1	not configured
138	2	not configured
138	9	not configured
138	10	not configured
138	11	not configured
138	12	not configured
138	13	not configured
138	14	not configured
138	15	not configured
138	16	not configured
138	17	not configured
138	18	not configured
138	19	not configured
138	20	not configured
138	21	not configured
138	22	not configured
138	23	not configured
138	24	not configured
138	25	not configured
138	26	not configured
138	27	not configured
138	28	not configured
138	29	not configured
138	30	not configured
138	31	not configured
138	32	not configured
138	33	not configured
138	34	not configured
138	35	not configured
138	36	not configured
138	37	not configured
138	38	not configured
138	39	not configured
138	40	not configured
138	41	not configured
138	42	not configured
138	43	not configured
138	44	not configured
138	45	not configured
138	46	not configured
138	47	not configured
138	48	not configured
138	49	not configured
138	50	not configured
138	51	not configured
138	52	not configured
138	53	not configured
138	54	not configured
138	55	not configured
138	56	not configured
138	57	not configured
138	58	not configured
138	59	not configured
138	60	not configured
138	61	not configured
138	62	not configured
138	63	not configured
138	64	not configured
138	65	not configured
138	66	not configured
138	67	not configured
138	68	not configured
138	69	not configured
138	71	not configured
138	72	not configured
138	73	not configured
138	74	not configured
138	75	not configured
138	76	not configured
138	77	not configured
138	78	not configured
138	79	not configured
138	80	not configured
138	81	not configured
138	82	not configured
138	83	not configured
138	84	not configured
138	85	not configured
138	86	not configured
138	87	not configured
138	88	not configured
138	89	not configured
138	90	not configured
138	91	not configured
138	92	not configured
138	93	not configured
138	94	not configured
138	95	not configured
138	96	not configured
138	97	not configured
138	98	not configured
138	99	not configured
138	100	not configured
138	101	not configured
138	102	not configured
138	103	not configured
138	104	not configured
138	105	not configured
138	106	not configured
138	107	not configured
138	108	not configured
138	109	not configured
138	110	not configured
138	111	not configured
138	112	not configured
138	113	not configured
138	114	not configured
138	115	not configured
138	116	not configured
138	117	not configured
138	118	not configured
138	119	not configured
138	120	not configured
138	121	not configured
138	122	not configured
138	124	not configured
138	125	not configured
138	127	not configured
138	128	not configured
138	129	not configured
138	130	not configured
138	131	not configured
138	132	not configured
138	134	not configured
138	135	not configured
138	136	not configured
138	137	not configured
138	138	not configured
85	137	26757000001234
85	11	26757000001234
85	101	26757000005678
85	2	26757000001234
85	9	26757000001234
85	10	26757000001234
85	12	26757000001234
85	13	26757000001234
85	14	26757000001234
85	15	26757000001234
85	16	26757000001234
85	17	26757000001234
85	18	26757000001234
85	19	26757000001234
85	20	26757000001234
85	21	26757000001234
85	22	26757000001234
85	23	26757000001234
85	24	26757000001234
85	25	26757000001234
85	26	26757000001234
85	27	26757000001234
85	28	26757000001234
85	29	26757000001234
85	30	26757000001234
85	31	26757000001234
85	32	26757000001234
85	33	26757000001234
85	34	26757000001234
85	35	26757000001234
85	36	26757000001234
85	37	26757000001234
85	38	26757000001234
85	39	26757000001234
85	40	26757000001234
85	41	26757000001234
85	43	26757000001234
85	44	26757000001234
85	45	26757000001234
85	46	26757000001234
85	47	26757000001234
85	48	26757000001234
85	49	26757000001234
85	50	26757000001234
85	51	26757000001234
85	52	26757000001234
85	53	26757000001234
85	54	26757000001234
85	55	26757000001234
85	56	26757000001234
85	57	26757000001234
85	58	26757000001234
85	59	26757000001234
85	60	26757000001234
85	61	26757000001234
85	62	26757000001234
85	63	26757000001234
85	64	26757000001234
85	65	26757000001234
85	66	26757000001234
85	67	26757000001234
85	68	26757000001234
85	69	26757000001234
85	71	26757000001234
85	72	26757000001234
85	73	26757000001234
85	74	26757000001234
85	75	26757000001234
85	76	26757000001234
85	77	26757000001234
85	78	26757000001234
85	79	26757000001234
85	80	26757000001234
85	81	26757000001234
85	82	26757000001234
85	83	26757000001234
85	84	26757000001234
85	85	26757000001234
85	86	26757000001234
85	87	26757000001234
85	88	26757000001234
85	89	26757000001234
85	90	26757000001234
85	91	26757000001234
85	92	26757000001234
85	93	26757000001234
85	94	26757000001234
85	95	26757000001234
85	96	26757000001234
85	97	26757000001234
85	98	26757000001234
85	99	26757000001234
85	100	26757000001234
85	102	26757000001234
85	103	26757000001234
85	104	26757000001234
85	105	26757000001234
85	106	26757000001234
85	107	26757000001234
85	108	26757000001234
85	109	26757000001234
85	110	26757000001234
85	111	26757000001234
85	112	26757000001234
85	113	26757000001234
85	114	26757000001234
85	115	26757000001234
85	116	26757000001234
85	117	26757000001234
85	118	26757000001234
85	119	26757000001234
85	120	26757000001234
85	121	26757000001234
85	122	26757000001234
85	124	26757000001234
85	125	26757000001234
85	127	26757000001234
85	128	26757000001234
85	129	26757000001234
85	130	26757000001234
85	131	26757000001234
85	132	26757000001234
85	134	26757000001234
85	135	26757000001234
85	136	26757000001234
85	138	26757000001234
\.


--
-- Data for Name: request; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY request (id, title, author, requester, patron_barcode, current_source_sequence_number) FROM stdin;
4	Alps and their people, The	Bullen, Susan	85	26786700000001	1
5	Appalachian spring	Gustafson, Eleanor	85	26786700000001	1
6	Andes [videorecording]	\N	85	26786700000001	1
7	Alchemy	\N	85	26786700000001	1
8	Accident	Steel, Danielle	85	26786700000001	1
9	Accelerate	\N	85	26786700000001	1
10	According to Jake and the kid	Mitchell, W. O	85	26786700000001	1
11	Ace Ventura	\N	85	26786700000001	1
12	Active training	Silberman, Melvin L	85	26786700000001	1
13	Acute care nursing in the home	\N	85	26786700000001	1
14	Adventure guides	\N	85	26786700000001	1
15	The aerobats:  the world's great aerial demonstration teams	Yenne, Bill	85	26786700000001	1
16	Anchor Hocking's Fire-King & more	Florence, Gene	85	26786700000001	1
17	Angle of repose	Stegner, Wallace Earle	85	26786700000001	1
18	Arctic Alphabet	Lynch, Wayne	85	26786700000001	1
19	Astronomy today	Asimov, Isaac	85	26786700000001	1
20	Appetite for life	Fitch, Noel Riley	85	26786700000001	1
21	Backhoes	McClellan, Ray	32	26330000000002	1
22	Bradford Angier's Backcountry basics	Angier, Bradford	32	26330000000002	1
23	Bachelor Jim	Boon, Clarence A	32	26330000000002	1
24	Bad company	Wick, Steve	32	26330000000002	1
25	Barbarian tides	\N	32	26330000000002	1
26	Bank shot	Westlake, Donald E	32	26330000000002	1
27	Barbie	\N	32	26330000000002	1
28	Battle ready	Clancy, Tom	32	26330000000002	1
29	Beach road	Patterson, James	32	\N	0
30	Beach Girls	Rice, Luanne	32	26330000000002	1
31	Bowling	Strickland, Robert	32	26330000000002	1
32	Bear attacks	Herrero, Stephen	32	26330000000002	1
1	Awkward aardvark	Mwalimu	85	26786700000001	1
2	Apples	Browning, Frank	85	26786700000001	1
3	Arthur! Arthur!	Black, Arthur	85	26786700000001	1
33	Beggar maid, queen	Peters, Maureen	32	26330000000002	1
34	Bedside manners	Barker, Margaret	32	26330000000002	1
35	Belle Arabelle	Marokvia, Mireille	32	26330000000002	1
36	Biology	Campbell, Neil A	32	26330000000002	1
37	Bird	Burnie, David	32	26330000000002	1
38	Black Beauty;	Sewell, Anna	32	26330000000002	1
39	Ballroom dancing	\N	32	26330000000002	1
40	Beaver skins and mountain men ;	Burger, Carl	32	26330000000002	1
41	Contempt of court	Curriden, Mark	24	26220000000003	1
42	Contemporary Canadian painting	Withrow, William J	24	26220000000003	1
43	Courtesy becomes me	Bayer, Lewena	24	26220000000003	1
44	Cosmopolitan	Cecchini, Toby	24	26220000000003	1
45	Curiosity	Thomas, Joan	24	26220000000003	1
46	Crossword answer book, The	Newman, Stanley	24	26220000000003	1
47	Colony	Siddons, Anne Rivers	24	26220000000003	1
48	Community Helpers from A to Z	Kalman, Bobbie	24	26220000000003	1
49	Canadian diplomacy and the Korean war, 1950-1953	Donaghy, Greg	24	26220000000003	1
50	Control	Anderson, Jack	24	26220000000003	1
51	Crude world	Maass, Peter	24	26220000000003	1
52	Creed	Harte, Bryce	24	26220000000003	1
53	Cree language structures	Ahenakew, Freda	24	26220000000003	1
54	Critical	Cook, Robin	24	26220000000003	1
55	Cultural Anthropology	Kottak Conrad Phillip,Kottak, Conrad Phillip	24	26220000000003	1
56	Cyanide wells	Muller, Marcia	24	26220000000003	1
57	Calligraphy	Campbell, Fiona	24	26220000000003	1
58	Coots, codgers and curmudgeons	Sisson, Hal C	24	26220000000003	1
59	Calumet City	Newton, Charlie	24	26220000000003	1
60	Cradle to canoe	Kraiker, Rolf	24	26220000000003	1
61	Disturbance	Burke, Jan	92	26840000000004	1
62	Duke	Boswell, John	92	26840000000004	1
63	Dialogue	Turco, Lewis	92	26840000000004	1
64	Deadlock	Johansen, Iris	92	26840000000004	1
65	Diaspora by design	Moghissi, Haideh	92	26840000000004	1
66	Doctor Zhivago	Pasternak, Boris Leonidovich	92	26840000000004	1
67	The diversity of life	Wilson, Edward O	92	26840000000004	1
68	Dude, where's my country?	Moore, Michael	92	\N	0
69	Dude ranch	Bryant, Bonnie	92	26840000000004	1
70	Dragon	Cussler, Clive	92	26840000000004	1
71	Danger point	Wentworth, Patricia	92	26840000000004	1
72	Disciplining dissent	\N	92	26840000000004	1
73	Dinosaur	Norman, David	92	26840000000004	1
74	Dyslexia	Landau, Elaine	92	26840000000004	1
75	Digital photography for dummies	King, Julie Adair	92	26840000000004	1
76	Domestic descendants	Moscow, Henry	92	26840000000004	1
77	A Delicate balance	Albee, Edward	92	26840000000004	1
78	Delicate dances	\N	92	26840000000004	1
79	Dirty Blonde	Scottoline, Lisa	92	26840000000004	1
80	Deforestation	Owens, Caleb	92	26840000000004	1
81	Electric mischief	Bartholomew, Alan	71	26747000000005	1
82	The Echelon vendetta	Stone, David	71	26747000000005	1
83	Energy	Oxlade, Chris	71	26747000000005	1
84	Enigma	Harris, Robert	71	26747000000005	1
85	The entropy effect	McIntyre, Vonda N	71	26747000000005	1
86	Eternal prairie	Adams, R	71	26747000000005	1
87	Everlasting	Woodiwiss, Kathleen E	71	26747000000005	1
88	Earth	Asimov, Issac	71	26747000000005	1
89	Ethics	Wekesser, Carol	71	26747000000005	1
90	L'escargot	Monette, Lise	71	26747000000005	1
91	Elephant song	Smith, Wilbur A	71	26747000000005	1
92	Eau Canada	\N	71	26747000000005	1
93	Eutopia: a novel of terrible optimism	Nickle, David	71	26747000000005	1
94	Ethnic conflict	Cozic, Charles (ed.)	71	26747000000005	1
95	Ethernet	Spurgeon, Charles	71	26747000000005	1
96	English masterpieces;	Mack, Maynard	71	26747000000005	1
97	Employment Equity Act	\N	71	26747000000005	1
98	Evolution	Moore, Ruth Ellen	71	26747000000005	1
99	Ear, nose, and throat disorders sourcebook	\N	71	26747000000005	1
100	Excel 2007	Jacobs, Kathy	71	26747000000005	1
101	Face forward	Aucoin, Kevyn	68	26700000000006	1
102	Flying finish. --	Francis, Dick	68	26700000000006	1
103	Family	Bombeck, Erma	68	26700000000006	1
104	Flowers for Algernon	Keyes, Daniel	68	26700000000006	1
105	Frugal Gourmet collection [videorecording] :, The	\N	68	26700000000006	1
106	Fruitful encounters	Brush, Stephen G	68	26700000000006	1
107	The Franklin Expedition As Recorded In Hudson's Bay Company Post Journals	Houston, C. Stuart	68	26700000000006	1
108	Following the line of duty :the other side of the battle	King, Herbert R	68	26700000000006	1
109	Football fugitive	Christopher, Matt	68	26700000000006	1
110	Fried green tomatoes	\N	68	26700000000006	1
111	Fancy Nancy	O'Connor, Jane	68	26700000000006	1
112	FILTER, AIR, HIGH EFFICIENCY RIGID TYPE, FOR REMOVAL OF PARTICULATE FROM VENTILATING SYSTEMS	\N	68	26700000000006	1
113	Fear of frying	Churchill, Jill	68	26700000000006	1
114	Field hockey	Gutman, Bill	68	26700000000006	1
115	Futile efforts	Piccirilli, Tom	68	26700000000006	1
116	Ferrari	McKenna, A. T	68	26700000000006	1
117	Feudal coats-of-arms	Foster, Joseph	68	26700000000006	1
118	Fur traders	\N	68	26700000000006	1
119	Feather on the moon	Whitney, Phyllis A	68	26700000000006	1
120	Financial freedom in 8 minutes a day	Hulnick, Ron	68	26700000000006	1
121	Giants! Giants! Giants!	\N	94	26290000000007	1
122	Giraffe family	Goodall, Jane	94	\N	0
123	Giraffe	Ledgard, J.M	94	26290000000007	1
124	Gaelic envy	White, Nancy	94	26290000000007	1
125	Germ	Liparulo, Robert	94	26290000000007	1
126	Giggle, giggle, quack	Cronin, Doreen	94	26290000000007	1
127	Gorgeous	Vail, Rachel	94	26290000000007	1
128	Generous death	Pickard, Nancy	94	26290000000007	1
129	Good night, sleep tight, don't let the bedbugs bite!	De Groat, Diane	94	26290000000007	1
130	Grammar matters	Ghomeshi, Jila	94	26290000000007	1
131	Golden fox	Smith, Wilbur A	94	26290000000007	1
132	Genius	Gleick, James	94	26290000000007	1
133	Gentlemen of the road	Chabon, Michael	94	26290000000007	1
134	Gulliver in Lilliput	Findlay, Lisa	94	26290000000007	1
135	Goal!	Javaherbin, Mina	94	26290000000007	1
136	Gentlemen of adventure	Gann, Ernest Kellogg	94	26290000000007	1
137	Geology rocks!	Blobaum, Cindy	94	26290000000007	1
138	Ghost	\N	94	26290000000007	1
139	Goose	Bang, Molly	94	26290000000007	1
140	Galapagos	\N	94	26290000000007	1
141	Hardware;	Barnes, Linda	90	26830000000008	1
142	Hegemony or survival	Chomsky, Noam	90	26830000000008	1
143	Helping your anxious child	Rapee, Ronald M	90	26830000000008	1
144	Hubris	Isikoff, Michael	90	26830000000008	1
145	Happiness sold separately	Winston, Lolly	90	26830000000008	1
146	The honor of the queen	Weber, David	90	26830000000008	1
147	Horrible Harry goes to the moon	Kline, Suzy	90	26830000000008	1
148	Honourable intentions	Barr, Natalie	90	26830000000008	1
149	Harry Potter and the Chamber of Secrets	Rowling, J. K	90	\N	0
150	Harry Potter and the goblet of fire	Rowling, J. K	90	26830000000008	1
151	Hallucinogens	Barter, James	90	26830000000008	1
152	Hummingbird	Spencer, LaVyrle	90	26830000000008	1
153	Harry Houdini	Macleod, Elizabeth,MacLeod, Elizabeth	90	26830000000008	1
154	Hawk	Hawk, Tony	90	26830000000008	1
155	Healing grief	Van Praagh, James	90	26830000000008	1
156	Hello Canada!	Young, Scott	90	26830000000008	1
157	Heritage	\N	90	26830000000008	1
158	Humble pie	Benrey, Ron	90	26830000000008	1
159	Half empty	Rakoff, David	90	26830000000008	1
160	Honey	Andrews, V.C	90	26830000000008	1
161	Internal affairs	Dial, Connie	82	26269000000009	1
162	Invisible	McCourtney, Lorena	82	\N	0
163	Invisible prey	Sandford, John	82	26269000000009	1
164	Icon	Forsyth, Frederick	82	26269000000009	1
165	Ideology	Eagleton, Terry	82	26269000000009	1
166	Irish whiskey	Greeley, Andrew M	82	26269000000009	1
167	Imperial Rome	Hadas, Moses	82	26269000000009	1
168	Investigative reports [videorecording]	\N	82	26269000000009	1
169	The illuminating world of light with Max Axiom, super scientist	Sohn, Emily	82	26269000000009	1
170	The imaginary Indian	Francis, Daniel	82	26269000000009	1
171	Infernal devices	Reeve, Philip	82	26269000000009	1
172	Intelligent universe	Gardner, James N	82	26269000000009	1
173	I'm not suffering from insanity-- I'm enjoying every minute of it!	Linamen, Karen Scalf	82	26269000000009	1
174	Insidious	\N	82	26269000000009	1
175	Ironic	Grills, Barry	82	26269000000009	1
176	The integral trees	Niven, Larry	82	26269000000009	1
177	Identity : the autobiography of Edward L. Stephanson (Sveinsson)	Stephanson, Edward L	82	26269000000009	1
178	Independent means	Townson, Monica	82	26269000000009	1
179	Islam	\N	82	26269000000009	1
180	Internet	Jefferis, David	82	26269000000009	1
181	Jade	Barr, Pat	84	26969000000010	1
182	Jealous?	De la Cruz, Melissa	84	26969000000010	1
183	Justice	Kellerman, Faye	84	26969000000010	1
184	Jellyfish	Herriges, Ann	84	26969000000010	1
185	Jelly belly	Lee, Dennis	84	\N	0
186	Jelly Belly	Smith, Robert Kimmel	84	26969000000010	1
187	Jesse James	Brant, Marley	84	26969000000010	1
188	Jumpstart the world	Hyde, Catherine Ryan	84	26969000000010	1
189	Jazzy jeans	Baskett, Mickey	84	26969000000010	1
190	Jerome	Ressner, Philip	84	26969000000010	1
191	Justin Case	Vail, Rachel	84	26969000000010	1
192	Journey to Portugal	Saramago, Jos.&#780;	84	26969000000010	1
193	Johnny Appleseed	Kellogg, Steven	84	26969000000010	1
194	Jacob's ladder	\N	84	26969000000010	1
195	Jumping Lessons	Leitch, Patricia	84	26969000000010	1
196	Jilted	McKenzie, Lorna	84	26969000000010	1
197	Just joking!	Griffiths, Andy	84	26969000000010	1
198	Japan	Seidensticker, Edward	84	26969000000010	1
199	The Jolly Mon	Buffett, Jimmy	84	26969000000010	1
200	Jackson's dilemma	Murdoch, Iris	84	26969000000010	1
201	Karma	Smith, Mitchell	83	26669000000011	1
202	Kinetic and potential energy	Viegas, Jennifer	83	26669000000011	1
203	Kamchatka	\N	83	26669000000011	1
204	Kiss of a dark moon	Kohler, Sharie	83	26669000000011	1
205	Kentucky!	Ross, Dana Fuller	83	26669000000011	1
206	Kick	Myers, Walter Dean	83	26669000000011	1
207	Klondike	Berton, Pierre	83	26669000000011	1
208	Knight	Gravett, Christopher	83	26669000000011	1
209	Killer pancake	Davidson, Diane Mott	83	26669000000011	1
210	The Kite Runner	Hosseini, Khaled,Hosseini, KHaled	83	26669000000011	1
211	Kickstart	Herman, Alexander	83	26669000000011	1
212	Koko's kitten	Patterson, Francine	83	26669000000011	1
213	The Koran	Dawood, N.J	83	26669000000011	1
214	Kuwait-- in pictures	\N	83	26669000000011	1
215	Kumquat May, I'll always love you	Grant, Cynthia D	83	26669000000011	1
216	Killer whales	Patent, Dorothy Hinshaw	83	26669000000011	1
217	Kids are worth it !	Coloroso, Barbara	83	26669000000011	1
218	Kirk Douglas	\N	83	26669000000011	1
219	Kanada	Wiseman, Eva	83	26669000000011	1
220	Kneeling in Bethlehem	Weems, Ann	83	26669000000011	1
240	Leaving	Kingsbury, Karen	135	26646900000012	1
222	Latin America	Fuentes, Carlos	135	26646900000012	1
221	Landscape Planning	Adam, Judith	135	26646900000012	1
223	Lutheran St. Matthew, Stony Plain, Alberta	Baron, Eric J. (Eric John), 1923-	135	26646900000012	1
224	Let sleeping dogs lie	Ledbetter, Suzann	135	26646900000012	1
225	Leadbelly	Jess, Tyehimba	135	26646900000012	1
226	Leadership	Hillier, Rick	135	26646900000012	1
227	Looking for Rachel Wallace	Parker, Robert B	135	26646900000012	1
228	Learning	Kingsbury, Karen	135	26646900000012	1
229	Love comes softly	Oke, Janette	135	26646900000012	1
230	Lone star cafe	Wingate, Lisa	135	26646900000012	1
231	Lemon	Strube, Cordelia	135	26646900000012	1
232	Last Chance Bay	Carter, Anne	135	26646900000012	1
233	Liberating Atlantis	Turtledove, Harry	135	26646900000012	1
234	Lightning	Koontz, Dean R	135	26646900000012	1
235	Lighting solutions	\N	135	26646900000012	1
236	Little Women	Alcott, Louis May	135	26646900000012	1
237	Lester B Pearson; The geek	Gibb, Gordon R	135	26646900000012	1
238	Leonardo Da Vinci	Pedretti, Carlo	135	26646900000012	1
239	The law-bringers	Conway, Elliot	135	26646900000012	1
241	The maiden	Deveraux, Jude	20	26266000000013	1
242	Malachite	Langan, Ruth	20	26266000000013	1
243	Malachi McCormick's Irish country cooking	McCormick, Malachi	20	26266000000013	1
244	Mort	Pratchett, Terry	20	26266000000013	1
245	Model railroads	Herda, D. J	20	26266000000013	1
246	The Method	\N	20	26266000000013	1
247	Martial arts in action	Levigne, Heather	20	\N	0
248	Martial law	Dixon, Franklin W	20	26266000000013	1
249	Men are from Mars, women are from Venus	Gray, John	20	\N	0
250	Marriage	Swedenborg, Emanuel.  (1688-1772)	20	26266000000013	1
251	Multiple choice	Tashjian, Janet	20	26266000000013	1
252	Murder on the orient express	Christie, Agatha	20	26266000000013	1
253	Mastering the guitar	Bay, William	20	26266000000013	1
254	Margarita, martini, mojito	Gage, Allan	20	26266000000013	1
255	The mulberry tree	Deveraux, Jude	20	26266000000013	1
256	Money, Money, Money	McBain, Ed	20	26266000000013	1
257	Material witness	Tanenbaum, Robert K	20	26266000000013	1
258	Murder most fowl	Crider, Bill	20	26266000000013	1
259	A majority of one	Stubbs, Lewis St. George	20	26266000000013	1
260	Mythology	Hamilton, Edith	20	26266000000013	1
261	Naive art in the West	Czernecki, Stefan	39	26550000000014	1
262	The nature of the beast	Fyfield, Frances	39	26550000000014	1
263	Notorious	Dailey, Janet	39	26550000000014	1
264	Norbert Nipkin	McConnell, Robert	39	26550000000014	1
265	Nordic Vision walk	\N	39	26550000000014	1
266	Noon	Taseer, Aatish	39	26550000000014	1
267	Naughty nautical neighbors	Auerbach, Annie	39	26550000000014	1
268	Noble house	Clavell, James	39	26550000000014	1
269	Notable Canadian children's books	\N	39	26550000000014	1
270	The name of the rose	Eco, Umberto	39	26550000000014	1
271	The Nonsuch	Rankin, Laird	39	26550000000014	1
272	Nickel and dimed	Ehrenreich, Barbara	39	26550000000014	1
273	Nerd gone wild	Thompson, Vicki Lewis	39	26550000000014	1
274	NASTY BUSINESS	Paradis, Peter	39	26550000000014	1
275	Needle and thread	Martin, Ann M	39	26550000000014	1
276	Nervous water	Tapply, William G	39	26550000000014	1
277	Nectar	Prior, Lily	39	26550000000014	1
278	Neil Armstrong	Westman, Paul	39	26550000000014	1
279	Nutrients in the Canadian environment	Ironside, G. R	39	26550000000014	1
280	Nobel	\N	39	26550000000014	1
281	Obsidian butterfly	Hamilton, Laurell K	30	26220100000015	1
282	Opus Dei	Allen, John L	30	26220100000015	1
283	Ocean	MacQuitty, Miranda	30	26220100000015	1
284	An obvious enchantment	Malarkey, Tucker	30	26220100000015	1
285	Original sin	James, P. D	30	26220100000015	1
286	Out of the shadows, SATB	Purifoy, John	30	26220100000015	1
287	Oriental rugs	Allane, Lee	30	26220100000015	1
288	Order in chaos	Whyte, Jack	30	26220100000015	1
289	Ordinary heroes	Turow, Scott	30	26220100000015	1
290	Orient et Occident au temps des Croisades	Cahen, Claude	30	26220100000015	1
291	Orbit	Nance, John J	30	26220100000015	1
292	Open house	Berg, Elizabeth	30	26220100000015	1
293	Open sources	\N	30	26220100000015	1
294	Oil spill!	Berger, Melvin	30	26220100000015	1
295	Oil	Piper, Allan	30	26220100000015	1
296	Olive Kitteridge	Strout, Elizabeth	30	26220100000015	1
297	Ominous	Brian, Kate	30	26220100000015	1
298	Opal	Snelling, Lauraine	30	26220100000015	1
299	Oral history	\N	30	26220100000015	1
300	On the other side	Wolff-Monckeberg, Mathilde	30	26220100000015	1
301	Peking	Bonavia, David	98	26670000000016	1
302	Pugs	Maggitti, Phil	98	26670000000016	1
303	Paris 1919	Macmillan, Margaret Olwen,MacMillan, Margaret Olwen	98	26670000000016	1
304	Pancakes, pancakes!	Carle, Eric	98	26670000000016	1
305	Powder river	Cotton, Ralph W	98	26670000000016	1
306	Palace	Massy, Christian de	98	26670000000016	1
307	Partial payments	Epstein, Joseph	98	26670000000016	1
308	Park prisoners	Waiser, Bill	98	26670000000016	1
309	Pork, perfect pork	\N	98	26670000000016	1
310	Pastries, pies and tarts	\N	98	26670000000016	1
311	Plumbing 1-2-3	Cory, Steve	98	26670000000016	1
312	Puzzle in a pear tree	Hall, Parnell	98	26670000000016	1
313	Porridge and old clothes	Scott, Eileen M	98	26670000000016	1
314	Pirates!	\N	98	26670000000016	1
315	Pluto	Asimov, Isaac	98	26670000000016	1
316	Plank houses	Gibson, Karen Bush	98	26670000000016	1
317	Perfect	McNaught, Judith,MCNaught, Judith	98	26670000000016	1
318	Puppies	Sjonger, Rebecca	98	26670000000016	1
319	Ping and Pong	Lee, Dennis	98	26670000000016	1
320	Planets	Sagan, Carl	98	26670000000016	1
321	A quiche before dying	Churchill, Jill	87	26376000000017	1
322	Quick Science	Herman and Nina Schneider	87	26376000000017	1
323	Quick cooking for busy people	Wokes, Karen	87	26376000000017	1
324	Quiet!	Bright, Paul	87	26376000000017	1
325	Queen of sorcery	Eddings, David	87	26376000000017	1
326	The queen of the damned	Rice, Anne	87	26376000000017	1
327	Quintessential Tarantino	Page, Edwin	87	26376000000017	1
328	QUERY PROCESSING TECHNIQUES FOR DISTRIBUTED, RELATIONAL DATA BASE SYSTEMS : COMPUTER SCIENCE, DISTRIBUTED DATABASE SYSTEMS, NO.13	EPSTEIN, ROBERT S	87	26376000000017	1
329	Quarrel with murder	Creasey, John	87	26376000000017	1
330	Quirky, jerky, extra perky	Cleary, Brian P	87	26376000000017	1
331	The quixotic vision of Sinclair Lewis	Light, Martin	87	26376000000017	1
332	Quasi-democracy ?	Stewart, David Kenney	87	26376000000017	1
333	Queensland, Australia	\N	87	26376000000017	1
334	Quality Equation 4-H club pack	Manitoba 4-H	87	26376000000017	1
335	Quantity time	MacGregor, Roy	87	26376000000017	1
336	Quelle surprise pour Caro!	Wark, Laurie	87	26376000000017	1
337	Quick & easy gourd crafts	Baskett, Mickey	87	26376000000017	1
338	Quick cozy flannel quilts	\N	87	26376000000017	1
339	All quiet on the western front;	Remarque, Erich Maria	87	26376000000017	1
340	Quite a year for plums	White, Bailey	87	\N	0
341	Quite early one morning. --	Thomas, Dylan	87	26376000000017	1
342	Redneck Cinderella	McLane, Luann,McLane, LuAnn	72	26720000000018	1
343	Redcoat	Cornwell, Bernard	72	26720000000018	1
344	Roughneck Cowboy	Thomas, Marin	72	26720000000018	1
345	Radio astronomy	Richardson, Adele	72	26720000000018	1
346	Routine activities, opportunity and crime in the inner city	Kohm, Steven A	72	26720000000018	1
347	Raisins and almonds: A Phryne Fisher Mystery	Greenwood, Kerry	72	26720000000018	1
348	Reading by Lightning	Thomas, Joan	72	26720000000018	1
349	Racing the Wind	Baglio, Ben M,Baglio Ben M	72	26720000000018	1
350	Retire rich!	Gadsden, Stephen	72	26720000000018	1
351	Revolver	Sedgwick, Marcus	72	26720000000018	1
352	Rescue	Shreve, Anita	72	26720000000018	1
353	Revenue Canada	\N	72	26720000000018	1
354	Reality bites	Morgan, Melissa J	72	26720000000018	1
355	Realty check	Rinomato, Sandra	72	26720000000018	1
356	Regrets only	Quinn, Sally	72	26720000000018	1
357	Reinventing the sacred	Kauffman, Stuart A	72	26720000000018	1
358	The Roman;	Waltari, Mika Toimi	72	26720000000018	1
359	Running hot	Krentz, Jayne Ann	72	26720000000018	1
360	The radioactive boy scout	Silverstein, Ken	72	26720000000018	1
361	Suddenly	Delinsky, Barbara	34	26764000000019	1
362	Sailing to Capri	Adler, Elizabeth	34	26764000000019	1
363	Shelter	Coben, Harlan	34	26764000000019	1
364	Silly Tilly's Valentine	Hoban, Lillian	34	26764000000019	1
365	Sugar daddy	Kleypas, Lisa	34	26764000000019	1
366	Sunken treasure	Gibbons, Gail	34	26764000000019	1
367	Surface rights in Manitoba	\N	34	26764000000019	1
368	Scratch the Surface	Conant, Susan	34	26764000000019	1
369	Sleeping beauty	Margolin, Phillip	34	26764000000019	1
370	Stupid white men --	Moore, Michael	34	26764000000019	1
371	Shame	Rushdie, Salman	34	26764000000019	1
372	Subtle	Brooks, Bruce	34	26764000000019	1
373	Snakes	Grace, Eric	34	26764000000019	1
374	Sweet liar	Deveraux, Jude	34	26764000000019	1
375	Stealth	Miller, Karen	34	26764000000019	1
376	Steel Magnolias	Bootsman Video	34	26764000000019	1
377	Sharing	Nielsen, Shelly	34	26764000000019	1
378	S'mores	Adams, Lisa	34	26764000000019	1
379	Slightly shady	Quick, Amanda	34	26764000000019	1
380	Spruce Woods adventure	Gamache, Donna Firby	34	26764000000019	1
381	Tennis	Gutman, Bill	18	26720100000020	1
382	Turtles	Martin, Louise	18	26720100000020	1
383	Tanks	Hogg, Ian V	18	26720100000020	1
384	Toys	Patterson, James	18	26720100000020	1
385	A Terrible beauty	\N	18	26720100000020	1
386	Tongue twisters	Chmielewski, Gary	18	26720100000020	1
387	Taxes for Canadians for dummies	\N	18	26720100000020	1
388	Taxi	\N	18	26720100000020	1
389	Trust Me	Krentz, Jayne Ann	18	26720100000020	1
390	Titanic	\N	18	\N	0
391	Titanic	Hustak, Alan	18	26720100000020	1
392	Tipping point, The	Gladwell, Malcolm	18	26720100000020	1
393	Time and tide	Fleming, Thomas J	18	26720100000020	1
394	Tesla	Cheney, Margaret	18	26720100000020	1
395	Tao;	Rawson, Philip S	18	26720100000020	1
396	Thirst	Oliver, Mary	18	26720100000020	1
397	The tide at sunrise;	Warner, Denis Ashton	18	26720100000020	1
398	Timeline	Crichton, Michael	18	26720100000020	1
399	Tibet	\N	18	26720100000020	1
400	Three cups of tea	Mortenson, Greg	18	26720100000020	1
401	The undertaker	Clarke, Richard	21	26830000000021	1
402	Underwater life	Miller-Schroeder, Patricia	21	26830000000021	1
403	Understanding Shakespeare	Ludowyk, E. F. C	21	26830000000021	1
404	Ulterior motives	Blackstock, Terri	21	26830000000021	1
405	Und ob ich schon wanderte --	Klassen, Peter P	21	26830000000021	1
406	The unfortunate marriage of Azeb Yitades	Mezlekia, Nega	21	26830000000021	1
407	Unorthodox openings	Benjamin, Joel	21	26830000000021	1
408	Undying love	Lacy, Al	21	26830000000021	1
409	Unearthly asylum	Bracegirdle, P. J	21	26830000000021	1
410	Undercover Blues	\N	21	26830000000021	1
411	Unstable ideas	Kagan, Jerome	21	26830000000021	1
412	Unreliable sources	Lee, Martin A	21	26830000000021	1
413	The umbrella	Brett, Jan	21	26830000000021	1
414	Underwear!	Monsell, Mary Elise	21	26830000000021	1
415	Until you	McNaught, Judith	21	\N	0
416		Sher, Julian	21	\N	0
417	Until Forever	Lindsey, Johanna	21	26830000000021	1
418	Ulysses	Geringer, Laura	21	26830000000021	1
419	Uruguay	Morrison, Marion	21	26830000000021	1
420	Ukraine	Shevchenko, Anna	21	26830000000021	1
\.


--
-- Data for Name: request_closed; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY request_closed (id, title, author, requester, patron_barcode, filled_by, attempts) FROM stdin;
\.


--
-- Data for Name: requests_active; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY requests_active (request_id, ts, msg_from, msg_to, status, message) FROM stdin;
1	2011-12-12 11:50:50.131983	85	90	ILL-Request	\N
2	2011-12-12 11:51:28.563778	85	99	ILL-Request	\N
3	2011-12-12 11:52:19.316667	85	90	ILL-Request	\N
4	2011-12-12 11:52:55.572766	85	32	ILL-Request	\N
5	2011-12-12 11:53:36.033538	85	90	ILL-Request	\N
6	2011-12-12 11:54:06.546173	85	21	ILL-Request	\N
7	2011-12-12 11:55:27.673781	85	101	ILL-Request	\N
8	2011-12-12 11:56:09.61186	85	39	ILL-Request	\N
9	2011-12-12 11:56:40.124281	85	101	ILL-Request	\N
10	2011-12-12 11:57:15.849335	85	84	ILL-Request	\N
11	2011-12-12 11:57:53.687573	85	25	ILL-Request	\N
12	2011-12-12 11:58:29.787813	85	99	ILL-Request	\N
13	2011-12-12 11:59:09.873812	85	48	ILL-Request	\N
14	2011-12-12 12:00:03.136649	85	99	ILL-Request	\N
15	2011-12-12 12:01:04.535545	85	72	ILL-Request	\N
16	2011-12-12 12:51:40.621998	85	101	ILL-Request	\N
17	2011-12-12 12:52:23.096104	85	84	ILL-Request	\N
18	2011-12-12 12:53:14.197327	85	98	ILL-Request	\N
19	2011-12-12 12:54:20.627123	85	30	ILL-Request	\N
20	2011-12-12 12:55:33.694451	85	101	ILL-Request	\N
21	2011-12-12 12:58:14.477502	32	83	ILL-Request	\N
22	2011-12-12 12:59:09.832974	32	72	ILL-Request	\N
23	2011-12-12 12:59:40.779665	32	84	ILL-Request	\N
24	2011-12-12 13:01:00.01523	32	33	ILL-Request	\N
25	2011-12-12 13:01:31.205609	32	82	ILL-Request	\N
26	2011-12-12 13:02:06.472254	32	90	ILL-Request	\N
27	2011-12-12 13:02:39.717211	32	85	ILL-Request	\N
28	2011-12-12 13:03:08.576603	32	68	ILL-Request	\N
30	2011-12-12 13:04:24.130224	32	87	ILL-Request	\N
31	2011-12-12 13:04:49.170239	32	24	ILL-Request	\N
32	2011-12-12 13:05:12.586817	32	46	ILL-Request	\N
33	2011-12-12 13:05:49.687341	32	24	ILL-Request	\N
34	2011-12-12 13:06:48.299765	32	20	ILL-Request	\N
35	2011-12-12 13:07:44.986537	32	101	ILL-Request	\N
36	2011-12-12 13:08:17.055182	32	24	ILL-Request	\N
37	2011-12-12 13:08:42.396886	32	98	ILL-Request	\N
38	2011-12-12 13:09:39.71185	32	34	ILL-Request	\N
39	2011-12-12 13:10:06.919288	32	99	ILL-Request	\N
40	2011-12-12 13:10:33.534191	32	20	ILL-Request	\N
41	2011-12-12 13:12:20.477484	24	39	ILL-Request	\N
42	2011-12-12 13:12:57.107761	24	71	ILL-Request	\N
43	2011-12-12 13:13:25.920195	24	82	ILL-Request	\N
44	2011-12-12 13:13:57.311397	24	99	ILL-Request	\N
45	2011-12-12 13:14:47.560049	24	92	ILL-Request	\N
46	2011-12-12 13:16:18.964972	24	101	ILL-Request	\N
47	2011-12-12 13:16:44.449908	24	90	ILL-Request	\N
48	2011-12-12 13:17:24.078383	24	85	ILL-Request	\N
49	2011-12-12 13:19:01.102517	24	20	ILL-Request	\N
50	2011-12-12 13:19:30.005684	24	68	ILL-Request	\N
51	2011-12-12 13:20:06.028608	24	84	ILL-Request	\N
52	2011-12-12 13:20:32.489519	24	68	ILL-Request	\N
53	2011-12-12 13:20:56.951128	24	85	ILL-Request	\N
54	2011-12-12 13:21:24.133848	24	92	ILL-Request	\N
55	2011-12-12 13:21:54.539522	24	98	ILL-Request	\N
56	2011-12-12 13:22:28.795501	24	68	ILL-Request	\N
57	2011-12-12 13:23:06.657959	24	34	ILL-Request	\N
58	2011-12-12 13:23:52.550051	24	135	ILL-Request	\N
59	2011-12-12 13:24:18.158784	24	92	ILL-Request	\N
60	2011-12-12 13:24:41.028184	24	82	ILL-Request	\N
61	2011-12-12 13:26:40.424336	92	83	ILL-Request	\N
62	2011-12-12 13:27:19.132191	92	101	ILL-Request	\N
63	2011-12-12 13:28:06.657214	92	99	ILL-Request	\N
64	2011-12-12 13:28:39.125241	92	21	ILL-Request	\N
65	2011-12-12 13:29:15.909345	92	100	ILL-Request	\N
66	2011-12-12 13:29:54.618103	92	68	ILL-Request	\N
67	2011-12-12 13:30:28.58704	92	90	ILL-Request	\N
69	2011-12-12 13:31:27.038779	92	24	ILL-Request	\N
70	2011-12-12 13:31:48.810979	92	24	ILL-Request	\N
71	2011-12-12 13:32:23.767993	92	85	ILL-Request	\N
72	2011-12-12 13:33:09.211942	92	99	ILL-Request	\N
73	2011-12-12 13:33:44.680083	92	135	ILL-Request	\N
74	2011-12-12 13:34:07.656283	92	83	ILL-Request	\N
75	2011-12-12 13:34:32.381518	92	68	ILL-Request	\N
76	2011-12-12 13:35:03.040534	92	71	ILL-Request	\N
77	2011-12-12 13:35:55.484357	92	20	ILL-Request	\N
78	2011-12-12 13:36:23.998635	92	100	ILL-Request	\N
79	2011-12-12 13:37:00.906436	92	84	ILL-Request	\N
80	2011-12-12 13:37:24.136213	92	101	ILL-Request	\N
81	2011-12-12 13:39:02.669787	71	92	ILL-Request	\N
82	2011-12-12 13:39:41.989933	71	84	ILL-Request	\N
83	2011-12-12 13:40:15.149512	71	24	ILL-Request	\N
84	2011-12-12 13:40:43.920005	71	83	ILL-Request	\N
85	2011-12-12 13:41:56.461802	71	90	ILL-Request	\N
86	2011-12-12 13:42:21.942357	71	82	ILL-Request	\N
87	2011-12-12 13:42:48.829225	71	68	ILL-Request	\N
88	2011-12-12 13:43:19.418968	71	30	ILL-Request	\N
89	2011-12-12 13:43:50.876861	71	30	ILL-Request	\N
90	2011-12-12 13:44:15.270209	71	18	ILL-Request	\N
91	2011-12-12 13:44:42.265563	71	92	ILL-Request	\N
92	2011-12-12 13:45:14.302066	71	68	ILL-Request	\N
93	2011-12-12 13:46:02.14789	71	21	ILL-Request	\N
94	2011-12-12 13:46:34.481816	71	46	ILL-Request	\N
95	2011-12-12 13:47:24.596394	71	99	ILL-Request	\N
96	2011-12-12 13:47:51.321097	71	87	ILL-Request	\N
97	2011-12-12 13:48:44.640537	71	100	ILL-Request	\N
98	2011-12-12 13:49:20.128048	71	30	ILL-Request	\N
99	2011-12-12 13:50:19.182286	71	99	ILL-Request	\N
100	2011-12-12 13:51:49.577034	71	84	ILL-Request	\N
101	2011-12-12 13:53:53.597236	68	24	ILL-Request	\N
102	2011-12-12 13:54:25.340122	68	85	ILL-Request	\N
103	2011-12-12 13:54:57.889057	68	72	ILL-Request	\N
104	2011-12-12 13:55:33.157018	68	82	ILL-Request	\N
105	2011-12-12 13:56:06.403645	68	21	ILL-Request	\N
106	2011-12-12 13:56:47.674555	68	99	ILL-Request	\N
107	2011-12-12 13:58:15.914902	68	100	ILL-Request	\N
108	2011-12-12 13:59:40.293506	68	85	ILL-Request	\N
109	2011-12-12 14:00:10.209084	68	24	ILL-Request	\N
110	2011-12-12 14:00:35.40303	68	24	ILL-Request	\N
111	2011-12-12 14:01:32.658274	68	32	ILL-Request	\N
112	2011-12-12 14:02:37.639421	68	100	ILL-Request	\N
113	2011-12-12 14:03:12.157837	68	99	ILL-Request	\N
114	2011-12-12 14:03:48.026405	68	71	ILL-Request	\N
115	2011-12-12 14:04:09.030815	68	99	ILL-Request	\N
116	2011-12-12 14:04:35.960231	68	92	ILL-Request	\N
117	2011-12-12 14:05:06.920308	68	87	ILL-Request	\N
118	2011-12-12 14:05:53.946344	68	83	ILL-Request	\N
119	2011-12-12 14:06:35.570558	68	83	ILL-Request	\N
120	2011-12-12 14:07:44.78444	68	72	ILL-Request	\N
121	2011-12-12 14:10:02.479906	94	24	ILL-Request	\N
123	2011-12-12 14:10:52.051085	94	98	ILL-Request	\N
124	2011-12-12 14:11:29.959928	94	98	ILL-Request	\N
125	2011-12-12 14:11:57.532108	94	83	ILL-Request	\N
126	2011-12-12 14:12:18.603327	94	84	ILL-Request	\N
127	2011-12-12 14:12:46.586589	94	92	ILL-Request	\N
128	2011-12-12 14:13:10.660581	94	68	ILL-Request	\N
129	2011-12-12 14:13:43.937374	94	83	ILL-Request	\N
130	2011-12-12 14:14:22.378119	94	68	ILL-Request	\N
131	2011-12-12 14:15:10.225835	94	92	ILL-Request	\N
132	2011-12-12 14:15:48.238522	94	98	ILL-Request	\N
133	2011-12-12 14:16:17.061615	94	92	ILL-Request	\N
134	2011-12-12 14:16:46.684677	94	92	ILL-Request	\N
135	2011-12-12 14:17:25.697616	94	84	ILL-Request	\N
136	2011-12-12 14:17:57.121767	94	83	ILL-Request	\N
137	2011-12-12 14:18:23.993277	94	90	ILL-Request	\N
138	2011-12-12 14:19:22.464258	94	87	ILL-Request	\N
139	2011-12-12 14:20:02.531045	94	99	ILL-Request	\N
140	2011-12-12 14:20:42.059131	94	90	ILL-Request	\N
141	2011-12-12 14:22:13.234947	90	68	ILL-Request	\N
142	2011-12-12 14:22:52.083192	90	82	ILL-Request	\N
143	2011-12-12 14:23:34.3907	90	68	ILL-Request	\N
144	2011-12-12 14:24:02.549379	90	85	ILL-Request	\N
145	2011-12-12 14:24:36.229548	90	24	ILL-Request	\N
146	2011-12-12 14:25:10.542511	90	68	ILL-Request	\N
147	2011-12-12 14:25:41.955667	90	83	ILL-Request	\N
148	2011-12-12 14:26:22.403377	90	72	ILL-Request	\N
150	2011-12-12 14:27:41.453323	90	84	ILL-Request	\N
151	2011-12-12 14:28:33.862456	90	85	ILL-Request	\N
152	2011-12-12 14:29:39.269655	90	72	ILL-Request	\N
153	2011-12-12 14:30:05.53657	90	68	ILL-Request	\N
154	2011-12-12 14:31:11.031843	90	99	ILL-Request	\N
155	2011-12-12 14:31:46.22666	90	85	ILL-Request	\N
156	2011-12-12 14:32:19.330816	90	24	ILL-Request	\N
157	2011-12-12 14:32:45.355583	90	98	ILL-Request	\N
158	2011-12-12 14:33:11.529716	90	135	ILL-Request	\N
159	2011-12-12 14:33:50.048152	90	87	ILL-Request	\N
160	2011-12-12 14:34:34.187858	90	24	ILL-Request	\N
161	2011-12-12 14:38:07.224084	82	92	ILL-Request	\N
163	2011-12-12 14:38:52.628066	82	24	ILL-Request	\N
164	2011-12-12 14:39:24.210881	82	84	ILL-Request	\N
165	2011-12-12 14:40:37.669561	82	99	ILL-Request	\N
166	2011-12-12 14:41:11.328467	82	68	ILL-Request	\N
167	2011-12-12 14:41:44.496293	82	71	ILL-Request	\N
168	2011-12-12 14:42:30.030032	82	21	ILL-Request	\N
169	2011-12-12 14:43:10.718122	82	84	ILL-Request	\N
170	2011-12-12 14:44:00.851325	82	92	ILL-Request	\N
171	2011-12-12 14:44:36.78407	82	92	ILL-Request	\N
172	2011-12-12 14:45:20.619641	82	68	ILL-Request	\N
173	2011-12-12 14:46:04.224945	82	85	ILL-Request	\N
174	2011-12-12 14:46:37.250516	82	85	ILL-Request	\N
175	2011-12-12 14:47:26.851477	82	20	ILL-Request	\N
176	2011-12-12 14:48:13.244657	82	20	ILL-Request	\N
177	2011-12-12 14:49:49.371067	82	30	ILL-Request	\N
178	2011-12-12 14:50:53.333343	82	101	ILL-Request	\N
179	2011-12-12 14:51:27.121511	82	24	ILL-Request	\N
180	2011-12-12 14:52:18.196101	82	72	ILL-Request	\N
181	2011-12-12 15:00:57.406569	84	90	ILL-Request	\N
182	2011-12-12 15:01:59.417657	84	39	ILL-Request	\N
183	2011-12-12 15:03:09.564977	84	68	ILL-Request	\N
184	2011-12-12 15:04:00.687386	84	46	ILL-Request	\N
186	2011-12-12 15:04:57.325223	84	87	ILL-Request	\N
187	2011-12-12 15:05:21.379333	84	39	ILL-Request	\N
188	2011-12-12 15:06:05.928876	84	92	ILL-Request	\N
189	2011-12-12 15:06:37.471895	84	92	ILL-Request	\N
190	2011-12-12 15:07:04.898959	84	30	ILL-Request	\N
191	2011-12-12 15:08:09.314809	84	85	ILL-Request	\N
192	2011-12-12 15:09:05.211998	84	18	ILL-Request	\N
193	2011-12-12 15:10:06.268685	84	87	ILL-Request	\N
194	2011-12-12 15:10:46.220394	84	18	ILL-Request	\N
195	2011-12-12 15:11:24.421921	84	90	ILL-Request	\N
196	2011-12-12 15:11:51.467454	84	46	ILL-Request	\N
197	2011-12-12 15:12:30.820836	84	18	ILL-Request	\N
198	2011-12-12 15:13:28.585085	84	30	ILL-Request	\N
199	2011-12-12 15:14:11.079606	84	25	ILL-Request	\N
200	2011-12-12 15:14:40.871951	84	68	ILL-Request	\N
201	2011-12-12 15:16:11.221397	83	90	ILL-Request	\N
202	2011-12-12 15:16:40.479814	83	99	ILL-Request	\N
203	2011-12-12 15:17:14.958293	83	100	ILL-Request	\N
204	2011-12-12 15:17:56.522719	83	47	ILL-Request	\N
205	2011-12-12 15:18:45.653049	83	20	ILL-Request	\N
206	2011-12-12 15:19:14.184193	83	92	ILL-Request	\N
207	2011-12-12 15:19:54.410957	83	78	ILL-Request	\N
208	2011-12-12 15:20:22.850752	83	39	ILL-Request	\N
209	2011-12-12 15:20:51.343124	83	24	ILL-Request	\N
210	2011-12-12 15:21:30.150758	83	30	ILL-Request	\N
211	2011-12-12 15:21:59.781261	83	85	ILL-Request	\N
212	2011-12-12 15:22:51.474231	83	78	ILL-Request	\N
213	2011-12-12 15:23:40.755886	83	30	ILL-Request	\N
214	2011-12-12 15:24:13.289274	83	98	ILL-Request	\N
215	2011-12-12 15:24:37.883211	83	99	ILL-Request	\N
216	2011-12-12 15:25:12.029777	83	92	ILL-Request	\N
217	2011-12-12 15:25:41.801372	83	68	ILL-Request	\N
218	2011-12-12 15:26:30.43688	83	90	ILL-Request	\N
219	2011-12-12 15:26:59.662468	83	18	ILL-Request	\N
220	2011-12-12 15:28:08.017819	83	87	ILL-Request	\N
221	2011-12-12 15:31:13.996356	135	72	ILL-Request	\N
222	2011-12-12 15:32:36.972591	135	99	ILL-Request	\N
223	2011-12-12 15:34:27.780224	135	32	ILL-Request	\N
224	2011-12-12 15:35:11.140415	135	85	ILL-Request	\N
225	2011-12-12 15:36:02.042402	135	99	ILL-Request	\N
226	2011-12-12 15:36:43.313077	135	92	ILL-Request	\N
227	2011-12-12 15:37:41.065009	135	101	ILL-Request	\N
228	2011-12-12 15:38:06.21619	135	34	ILL-Request	\N
229	2011-12-12 15:38:37.381751	135	87	ILL-Request	\N
230	2011-12-12 15:39:32.993965	135	34	ILL-Request	\N
231	2011-12-12 15:40:20.582109	135	32	ILL-Request	\N
232	2011-12-12 15:41:32.792406	135	90	ILL-Request	\N
233	2011-12-12 15:42:52.485761	135	83	ILL-Request	\N
234	2011-12-12 15:43:28.738888	135	85	ILL-Request	\N
235	2011-12-12 15:44:00.538629	135	24	ILL-Request	\N
236	2011-12-12 15:45:33.393967	135	98	ILL-Request	\N
237	2011-12-12 15:46:11.60923	135	33	ILL-Request	\N
238	2011-12-12 15:46:56.013957	135	68	ILL-Request	\N
239	2011-12-12 15:47:59.02812	135	34	ILL-Request	\N
240	2011-12-12 15:48:33.320835	135	24	ILL-Request	\N
241	2011-12-12 15:50:17.764901	20	90	ILL-Request	\N
242	2011-12-12 15:50:49.931138	20	85	ILL-Request	\N
243	2011-12-12 15:51:28.239027	20	99	ILL-Request	\N
244	2011-12-12 15:51:55.804179	20	25	ILL-Request	\N
245	2011-12-12 15:52:20.663142	20	71	ILL-Request	\N
246	2011-12-12 15:53:36.600528	20	92	ILL-Request	\N
248	2011-12-12 15:54:23.148559	20	24	ILL-Request	\N
250	2011-12-12 15:55:43.887316	20	46	ILL-Request	\N
251	2011-12-12 15:56:23.28394	20	85	ILL-Request	\N
252	2011-12-12 15:57:09.009408	20	90	ILL-Request	\N
253	2011-12-12 15:57:57.346481	20	99	ILL-Request	\N
254	2011-12-12 15:58:49.207141	20	99	ILL-Request	\N
255	2011-12-12 15:59:40.455233	20	84	ILL-Request	\N
256	2011-12-12 16:00:09.958768	20	24	ILL-Request	\N
257	2011-12-12 16:00:38.452248	20	98	ILL-Request	\N
258	2011-12-12 16:01:06.479353	20	99	ILL-Request	\N
259	2011-12-12 16:01:47.714305	20	30	ILL-Request	\N
260	2011-12-12 16:03:07.455484	20	18	ILL-Request	\N
261	2011-12-12 16:05:10.753758	39	44	ILL-Request	\N
262	2011-12-12 16:06:39.628688	39	34	ILL-Request	\N
263	2011-12-12 16:07:25.709881	39	68	ILL-Request	\N
264	2011-12-12 16:07:51.336613	39	25	ILL-Request	\N
265	2011-12-12 16:08:37.132789	39	83	ILL-Request	\N
266	2011-12-12 16:09:08.453501	39	24	ILL-Request	\N
267	2011-12-12 16:10:16.565046	39	68	ILL-Request	\N
268	2011-12-12 16:11:06.19256	39	68	ILL-Request	\N
269	2011-12-12 16:11:50.897702	39	99	ILL-Request	\N
270	2011-12-12 16:12:25.370927	39	98	ILL-Request	\N
271	2011-12-12 16:12:56.478974	39	72	ILL-Request	\N
272	2011-12-12 16:13:29.816966	39	83	ILL-Request	\N
273	2011-12-12 16:13:57.113121	39	84	ILL-Request	\N
274	2011-12-12 16:14:23.674677	39	85	ILL-Request	\N
275	2011-12-12 16:14:52.320332	39	83	ILL-Request	\N
276	2011-12-12 16:15:20.083685	39	99	ILL-Request	\N
277	2011-12-12 16:16:13.012449	39	99	ILL-Request	\N
278	2011-12-12 16:16:37.620778	39	90	ILL-Request	\N
279	2011-12-12 16:17:33.64786	39	99	ILL-Request	\N
280	2011-12-12 16:18:05.540528	39	101	ILL-Request	\N
281	2011-12-12 16:19:50.091845	30	90	ILL-Request	\N
282	2011-12-12 16:21:02.925809	30	90	ILL-Request	\N
283	2011-12-12 16:21:30.11714	30	92	ILL-Request	\N
284	2011-12-12 16:21:59.233566	30	85	ILL-Request	\N
285	2011-12-12 16:22:26.729936	30	68	ILL-Request	\N
286	2011-12-12 16:23:09.484564	30	46	ILL-Request	\N
287	2011-12-12 16:23:41.386416	30	68	ILL-Request	\N
288	2011-12-12 16:24:41.6287	30	83	ILL-Request	\N
289	2011-12-12 16:25:17.919097	30	90	ILL-Request	\N
290	2011-12-12 16:25:55.626328	30	99	ILL-Request	\N
291	2011-12-12 16:26:25.792517	30	90	ILL-Request	\N
292	2011-12-12 16:27:03.804439	30	85	ILL-Request	\N
293	2011-12-12 16:27:43.44054	30	99	ILL-Request	\N
294	2011-12-12 16:28:31.156221	30	101	ILL-Request	\N
295	2011-12-12 16:28:57.643798	30	32	ILL-Request	\N
296	2011-12-12 16:29:32.073494	30	82	ILL-Request	\N
297	2011-12-12 16:29:59.056048	30	20	ILL-Request	\N
298	2011-12-12 16:30:25.061633	30	72	ILL-Request	\N
299	2011-12-12 16:30:56.786092	30	100	ILL-Request	\N
300	2011-12-12 16:31:45.978074	30	99	ILL-Request	\N
301	2011-12-14 09:25:56.203352	98	71	ILL-Request	\N
302	2011-12-14 09:26:25.558531	98	24	ILL-Request	\N
303	2011-12-14 09:26:52.813593	98	85	ILL-Request	\N
304	2011-12-14 09:27:20.080797	98	83	ILL-Request	\N
305	2011-12-14 09:27:48.647448	98	24	ILL-Request	\N
306	2011-12-14 09:28:16.557698	98	101	ILL-Request	\N
307	2011-12-14 09:28:49.009708	98	99	ILL-Request	\N
308	2011-12-14 09:29:41.072983	98	87	ILL-Request	\N
309	2011-12-14 09:30:09.675364	98	83	ILL-Request	\N
310	2011-12-14 09:31:04.886022	98	99	ILL-Request	\N
311	2011-12-14 09:31:42.853117	98	101	ILL-Request	\N
312	2011-12-14 09:32:29.649825	98	90	ILL-Request	\N
313	2011-12-14 09:32:48.027872	98	24	ILL-Request	\N
314	2011-12-14 09:33:08.531177	98	87	ILL-Request	\N
315	2011-12-14 09:33:30.786411	98	78	ILL-Request	\N
316	2011-12-14 09:34:02.994325	98	99	ILL-Request	\N
317	2011-12-14 09:34:27.085039	98	90	ILL-Request	\N
318	2011-12-14 09:34:46.765711	98	85	ILL-Request	\N
319	2011-12-14 09:35:12.612675	98	25	ILL-Request	\N
320	2011-12-14 09:35:59.316343	98	30	ILL-Request	\N
321	2011-12-14 09:38:57.172686	87	90	ILL-Request	\N
322	2011-12-14 09:40:28.565598	87	78	ILL-Request	\N
323	2011-12-14 09:41:26.686301	87	48	ILL-Request	\N
324	2011-12-14 09:41:57.847228	87	24	ILL-Request	\N
325	2011-12-14 09:44:09.104472	87	24	ILL-Request	\N
326	2011-12-14 09:44:50.044114	87	24	ILL-Request	\N
327	2011-12-14 09:45:44.652476	87	99	ILL-Request	\N
328	2011-12-14 09:46:21.367784	87	100	ILL-Request	\N
329	2011-12-14 09:47:15.014853	87	90	ILL-Request	\N
330	2011-12-14 09:48:19.668347	87	84	ILL-Request	\N
331	2011-12-14 09:48:55.930497	87	99	ILL-Request	\N
332	2011-12-14 09:49:24.008925	87	100	ILL-Request	\N
333	2011-12-14 09:49:54.885519	87	82	ILL-Request	\N
334	2011-12-14 09:51:23.34779	87	20	ILL-Request	\N
335	2011-12-14 09:51:52.237831	87	68	ILL-Request	\N
336	2011-12-14 09:52:52.931071	87	78	ILL-Request	\N
337	2011-12-14 09:53:43.019362	87	92	ILL-Request	\N
338	2011-12-14 09:54:21.855188	87	39	ILL-Request	\N
339	2011-12-14 09:54:57.264724	87	24	ILL-Request	\N
341	2011-12-14 09:56:07.68337	87	68	ILL-Request	\N
342	2011-12-14 09:57:56.996435	72	92	ILL-Request	\N
343	2011-12-14 10:00:41.524767	72	20	ILL-Request	\N
344	2011-12-14 10:01:06.871082	72	32	ILL-Request	\N
345	2011-12-14 10:01:33.837847	72	24	ILL-Request	\N
346	2011-12-14 10:02:20.065519	72	100	ILL-Request	\N
347	2011-12-14 10:03:09.737269	72	21	ILL-Request	\N
348	2011-12-14 10:03:33.212421	72	71	ILL-Request	\N
349	2011-12-14 10:04:02.452587	72	98	ILL-Request	\N
350	2011-12-14 10:04:35.95265	72	90	ILL-Request	\N
351	2011-12-14 10:04:55.878968	72	92	ILL-Request	\N
352	2011-12-14 10:07:48.489667	72	24	ILL-Request	\N
353	2011-12-14 10:08:27.28677	72	100	ILL-Request	\N
354	2011-12-14 10:08:58.229345	72	92	ILL-Request	\N
355	2011-12-14 10:09:17.995202	72	92	ILL-Request	\N
356	2011-12-14 10:10:02.061783	72	101	ILL-Request	\N
357	2011-12-14 10:10:52.381595	72	92	ILL-Request	\N
358	2011-12-14 10:11:30.904689	72	84	ILL-Request	\N
359	2011-12-14 10:12:14.113974	72	39	ILL-Request	\N
360	2011-12-14 10:12:55.898202	72	99	ILL-Request	\N
361	2011-12-14 10:16:37.666219	34	39	ILL-Request	\N
362	2011-12-14 10:17:08.364118	34	83	ILL-Request	\N
363	2011-12-14 10:17:37.051878	34	83	ILL-Request	\N
364	2011-12-14 10:18:03.344209	34	83	ILL-Request	\N
365	2011-12-14 10:18:31.158129	34	24	ILL-Request	\N
366	2011-12-14 10:19:35.059263	34	82	ILL-Request	\N
367	2011-12-14 10:20:06.41039	34	84	ILL-Request	\N
368	2011-12-14 10:20:32.796395	34	90	ILL-Request	\N
369	2011-12-14 10:21:03.469305	34	85	ILL-Request	\N
370	2011-12-14 10:21:36.675805	34	85	ILL-Request	\N
371	2011-12-14 10:21:55.326172	34	83	ILL-Request	\N
372	2011-12-14 10:22:15.224309	34	90	ILL-Request	\N
373	2011-12-14 10:22:48.605301	34	83	ILL-Request	\N
374	2011-12-14 10:23:11.027802	34	98	ILL-Request	\N
375	2011-12-14 10:23:57.331455	34	24	ILL-Request	\N
376	2011-12-14 10:24:26.067961	34	72	ILL-Request	\N
377	2011-12-14 10:24:53.833372	34	90	ILL-Request	\N
378	2011-12-14 10:25:19.61578	34	85	ILL-Request	\N
379	2011-12-14 10:25:50.06976	34	83	ILL-Request	\N
380	2011-12-14 10:26:43.021646	34	83	ILL-Request	\N
381	2011-12-14 10:28:36.72511	18	71	ILL-Request	\N
382	2011-12-14 10:29:06.970853	18	83	ILL-Request	\N
383	2011-12-14 10:30:49.664907	18	99	ILL-Request	\N
384	2011-12-14 10:31:15.755368	18	24	ILL-Request	\N
385	2011-12-14 10:31:48.277595	18	90	ILL-Request	\N
386	2011-12-14 10:32:14.226424	18	90	ILL-Request	\N
387	2011-12-14 10:32:38.396192	18	31	ILL-Request	\N
388	2011-12-14 10:33:43.035761	18	98	ILL-Request	\N
389	2011-12-14 10:35:02.881865	18	83	ILL-Request	\N
391	2011-12-14 10:36:41.30357	18	99	ILL-Request	\N
392	2011-12-14 10:37:16.920071	18	31	ILL-Request	\N
393	2011-12-14 10:38:18.107809	18	24	ILL-Request	\N
394	2011-12-14 10:38:40.039667	18	92	ILL-Request	\N
395	2011-12-14 10:39:08.742187	18	72	ILL-Request	\N
396	2011-12-14 10:39:53.617974	18	32	ILL-Request	\N
397	2011-12-14 10:40:38.787495	18	101	ILL-Request	\N
398	2011-12-14 10:41:44.876879	18	87	ILL-Request	\N
399	2011-12-14 10:42:42.420491	18	99	ILL-Request	\N
400	2011-12-14 10:43:14.696096	18	83	ILL-Request	\N
401	2011-12-14 10:44:52.922437	21	34	ILL-Request	\N
402	2011-12-14 10:45:24.601445	21	85	ILL-Request	\N
403	2011-12-14 10:46:09.405142	21	101	ILL-Request	\N
404	2011-12-14 10:46:34.15077	21	24	ILL-Request	\N
405	2011-12-14 10:47:07.298163	21	90	ILL-Request	\N
406	2011-12-14 10:48:10.013088	21	87	ILL-Request	\N
407	2011-12-14 10:48:50.340951	21	99	ILL-Request	\N
408	2011-12-14 10:49:12.163244	21	90	ILL-Request	\N
409	2011-12-14 10:49:35.268996	21	24	ILL-Request	\N
410	2011-12-14 10:51:40.812891	21	98	ILL-Request	\N
411	2011-12-14 10:52:13.748427	21	99	ILL-Request	\N
412	2011-12-14 10:52:45.085318	21	100	ILL-Request	\N
413	2011-12-14 10:53:13.989089	21	84	ILL-Request	\N
414	2011-12-14 10:53:34.929211	21	31	ILL-Request	\N
417	2011-12-14 10:54:51.452849	21	16	ILL-Request	\N
418	2011-12-14 10:55:32.882754	21	87	ILL-Request	\N
419	2011-12-14 10:56:21.488919	21	84	ILL-Request	\N
420	2011-12-14 10:57:14.353683	21	84	ILL-Request	\N
\.


--
-- Data for Name: requests_history; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY requests_history (request_id, ts, msg_from, msg_to, status, message) FROM stdin;
\.


--
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
-- Data for Name: sources; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY sources (request_id, sequence_number, library, call_number) FROM stdin;
1	1	90	E Mwalimu 1989
1	2	99	undefined
2	1	99	undefined
2	2	101	641.3411
3	1	90	817.54 Bla 1991
3	2	34	791.45 BLACK
4	1	32	J 949.407 Bul
5	1	90	ChrFic Gustaf son 1984
5	2	98	Fic Gu
6	1	21	DVD 13845
7	1	101	undefined
8	1	39	F Steel,F Steel (pbk)
8	2	101	undefined
8	3	99	undefined
8	4	48	F STE
8	5	47	undefined
8	6	90	Steel 1994
8	7	25	LP Steel
8	8	71	F Ste
8	9	34	F/St-3
8	10	87	LP F Ste
9	1	101	undefined
10	1	84	F Mit
10	2	82	F Mit
10	3	44	F Mit
10	4	101	undefined
10	5	46	undefined
10	6	68	undefined
10	7	24	Fic MIT
10	8	90	Mitchell 1989
10	9	87	F Mit
10	10	99	undefined
10	11	25	F Mitchell
10	12	34	F/Mi-69
11	1	25	Video 554
11	2	101	undefined
12	1	99	undefined
12	2	100	HF/5549.5/.T7/Sil
13	1	48	649.8
14	1	99	undefined
15	1	72	797.54 Yen
16	1	101	748.2
17	1	84	F Ste
17	2	99	undefined
17	3	90	Stegner 1992
17	4	101	undefined
17	5	46	undefined
18	1	98	J 577.09113 Lyn
18	2	39	J577.09113 Lynch
18	3	25	J 577 Lynch
18	4	34	J 577.09 Lyn
19	1	30	undefined
20	1	101	92
20	2	68	undefined
20	3	99	undefined
21	1	83	J 629.225 McCl
22	1	72	613.69 Ang
23	1	84	F Boo
23	2	83	F Boo
23	3	100	PS 8553 Boo
23	4	47	undefined
23	5	87	F Boo
23	6	99	undefined
23	7	39	F Boon,F Boon
23	8	98	Fic Bo
23	9	25	F Boom
23	10	71	F Boo
23	11	101	undefined
24	1	33	undefined
24	2	47	undefined
25	1	82	930 Bar 1988
25	2	44	930/Bar
25	3	98	Ref 930 Tim
25	4	39	930 Barbarian
25	5	99	undefined
26	1	90	Westlake 1972
26	2	34	F/We-52 M
27	1	85	E BARBIE
27	2	24	DVD 2592
27	3	39	688.7221 Barbie
27	4	101	undefined
27	5	33	undefined
28	1	68	359.9 Zinni
28	2	71	359.96 Clancy
28	3	46	undefined
28	4	21	undefined
29	1	24	F PAT LP
29	2	48	F PAT
29	3	33	undefined
29	4	92	Patterson
29	5	25	LP Patterson
29	6	34	F/Pa-27 M
30	1	87	F Ric #5 Hubbard's Point
30	2	84	PB F Ric
30	3	83	LP F Ric
30	4	82	PB F Ric
30	5	24	F Ric
30	6	39	F Rice (pbk)
30	7	34	F/Ri-36
30	8	25	F Rice
30	9	48	F RIC
31	1	24	794.6 STR
31	2	99	undefined
31	3	101	undefined
32	1	46	undefined
32	2	99	undefined
33	1	24	F PET LP
33	2	71	Lp F Pet
33	3	101	undefined
34	1	20	LP/F/Barker
35	1	101	undefined
35	2	47	undefined
36	1	24	574 CAM
36	2	101	undefined
37	1	98	J 598 Bur
37	2	39	J598 Burnie
37	3	33	undefined
38	1	34	J Sewell 1980
38	2	101	SEWELL
38	3	99	undefined
38	4	48	JF Sewell,SEWELL
38	5	71	Y/ANI Sew
38	6	25	J Sewell
39	1	99	undefined
40	1	20	Basement/917/Burger
40	2	78	J 917 Bur
41	1	39	345.730234 Curriden
41	2	99	undefined
42	1	71	759.11 Wit
42	2	101	759.11,759.11
43	1	82	J 395.122 Bay
43	2	99	undefined
43	3	100	BJ/1857/.C5/Bay
44	1	99	undefined
45	1	92	Thomas
46	1	101	undefined
47	1	90	Siddons 1992
47	2	24	Fic SID
47	3	99	undefined
47	4	87	F Sid
47	5	34	F/Si-1
47	6	25	LP Siddons
47	7	46	undefined
47	8	47	undefined
48	1	85	J 331.702 KALMAN
48	2	90	J 331.702 Kal 1998
49	1	20	Gov/E2-210/2001
50	1	68	undefined
51	1	84	338.2 Maa
52	1	68	undefined
52	2	71	Wes/F Har
53	1	85	497.3 AHENAKEW
53	2	92	497.3 Ahe
54	1	92	Cook
54	2	90	Cook 2007
54	3	24	F COO
54	4	101	undefined
54	5	39	F Cook
54	6	25	W LP Cook
54	7	47	F COOK
55	1	98	306 Kot
55	2	101	undefined
56	1	68	undefined
56	2	83	F Mul
56	3	84	F Mul
56	4	82	F Mul
56	5	85	FIC MULLER,FIC MULLER
56	6	87	F Mul M
56	7	98	Fic Myst Mu
56	8	39	F Muller M
56	9	99	undefined
56	10	21	undefined
57	1	34	J 745.61 Cam
57	2	25	J 745.61
58	1	135	F Sis
59	1	92	Newton
59	2	99	undefined
60	1	82	797.122083 Kra
60	2	99	undefined
60	3	101	797.122
60	4	92	797.122 Kra
60	5	87	797. 122 083 Kra
61	1	83	F Bur
61	2	84	F Bur
61	3	20	F/Burke/M
62	1	101	undefined
62	2	33	undefined
63	1	99	undefined
64	1	21	F JOHANSEN
65	1	100	FC 106 .M9 Mog
66	1	68	undefined
67	1	90	333.95 Wil 1999
67	2	101	333.95
68	1	84	973.931 Moo
68	2	82	973.931 Moo
68	3	85	973.931 MOORE
68	4	99	undefined
68	5	21	undefined
68	6	46	undefined
68	7	90	817.6 Moo 2003
68	8	101	973.931
68	9	92	973.931 Moo
69	1	24	J F Bry #6 saddle club
69	2	90	J Bryant 1989
69	3	101	undefined
70	1	24	Fic CUS
70	2	87	F Cus
70	3	90	Cussler 1990
70	4	98	Fic Myst Cu
70	5	101	CUSSLER
71	1	85	FIC WENTWORTH
71	2	90	Went worth 1942
71	3	98	LP Fic We
71	4	99	undefined
72	1	99	undefined
73	1	135	J 567.91 Nor
73	2	44	J 567.91/Nor
73	3	68	J568 NOR
73	4	99	undefined
73	5	24	J 567.91 NOR
73	6	25	J/567.91/Nor
73	7	39	J567.91 Norman
73	8	98	J 567.91 Nor
73	9	34	J/567.91 Nor
74	1	83	J 616.85 Lan
74	2	84	J 616.85 Lan
74	3	82	J 616.85 Lan
74	4	90	YA 616.85 Lan 2004
74	5	99	undefined
75	1	68	undefined
75	2	90	778.3 Kin 2003
75	3	101	undefined
75	4	39	771 King
75	5	71	770 King
75	6	21	undefined
76	1	71	636 Mos
76	2	46	undefined
77	1	20	Drama/812/Albee
78	1	100	HD/2769.2/.C3/Del
79	1	84	F Sco
79	2	83	F Sco
79	3	82	F Sco
79	4	44	Mys Sco
79	5	101	undefined
79	6	39	F Scottoline,F Scottoli (pbk)
79	7	34	FIC SCOTT 2006 M
79	8	48	F SCO
79	9	33	undefined
79	10	46	undefined
79	11	85	FIC SCOTTOLINE,FIC SCOTTOLINE
79	12	24	F SCO M
79	13	92	Scottoline
79	14	98	Fic Myst Sc
79	15	25	W LP Scottoline
80	1	101	undefined
81	1	92	J 621.31 Bar
81	2	85	J 621.31 BARTHOLOMEW
81	3	90	J 621.31 Bar 2002
81	4	68	undefined
81	5	46	undefined
82	1	84	F Sto
82	2	92	Stone
82	3	39	F Stone
82	4	87	F Sto #1 Micah Dalton Series
82	5	85	FIC STONE
82	6	99	undefined
83	1	24	J 531.6 OXL
84	1	83	F Har
84	2	84	F Har
84	3	90	Harris 1995
84	4	98	Fic Myst Ha
84	5	68	undefined
84	6	34	F/Ha-24 M
84	7	48	F HAR
84	8	101	HARRIS
84	9	46	undefined
85	1	90	SciFi  McIntyre 1981
85	2	101	undefined
86	1	82	929.509712 Ada
86	2	99	undefined
86	3	87	929. 509 712 Ada
86	4	39	929.509712 Adams
86	5	101	929.509712
86	6	100	GT/3213/Ada
87	1	68	undefined
87	2	84	F Woo
87	3	83	F Woo
87	4	82	F Woo
87	5	25	F Woodiwiss
87	6	101	undefined
87	7	92	LP Woodiwiss
87	8	99	undefined
87	9	90	Woodiwiss 2007
87	10	34	undefined
87	11	87	LP F Woo
87	12	39	F Woodiwis
88	1	30	undefined
89	1	30	undefined
90	1	18	FL J 594.3 MON
91	1	92	Smith
91	2	90	Smith 1991
91	3	46	undefined
91	4	99	undefined
91	5	98	Fic Sm
91	6	39	F Smith
91	7	34	PBK F Smith 1992
91	8	87	F Smi
91	9	25	F Smith
91	10	101	SMITH,SMITH
92	1	68	333.91 BAK
93	1	21	F NICKLE
94	1	46	undefined
95	1	99	undefined
96	1	87	821 Eng 1961
97	1	100	Canada/EmpImm
98	1	30	undefined
99	1	99	undefined
100	1	84	005.54 Jac
101	1	24	646.7 AUC
101	2	25	646.7 Aucoin
101	3	101	646.72
102	1	85	FIC FRANCIS
102	2	101	undefined
102	3	98	Fic Myst Fr
102	4	90	LP Francis 1966
102	5	99	undefined
102	6	39	F Francis (pbk)
103	1	72	A/F Bom
104	1	82	J F Key
104	2	101	undefined
104	3	85	T KEYES
104	4	99	undefined
105	1	21	undefined
106	1	99	undefined
107	1	100	undefined
108	1	85	940.54 KING
109	1	24	J F Chr
109	2	83	J F Chr
109	3	82	J F Chr
109	4	84	J S Mat
109	5	85	J CHRISTOPHER
109	6	98	J Fic Ch
109	7	68	undefined
109	8	90	J Christo pher 1976
109	9	87	J F Chr
110	1	24	DVD 2430
110	2	85	VID FRIED 280
111	1	32	Br O'Con p.b
112	1	100	undefined
113	1	99	undefined
113	2	92	Churchill
113	3	90	LP Churchill 2006
113	4	101	CHURCHI
114	1	71	J796.35 Gut
114	2	90	J 796.355 Gut
114	3	47	undefined
115	1	99	undefined
116	1	92	J 629.2222 McK
117	1	87	929.6 Fos
118	1	83	J 971.01 Hud
118	2	85	J 971 FUR
118	3	39	J971 Fur
118	4	47	J 381.439 FUR
119	1	83	F Whi
119	2	84	F Whi
119	3	78	F Whi M
119	4	101	Whi,Whi,Whi
119	5	24	Fic WHI
119	6	90	Whitney 1988
119	7	87	F Whi
120	1	72	333.024 Hul
121	1	24	J F Hok
122	1	68	undefined
123	1	98	Fic Le
124	1	98	Disc Wh
125	1	83	CF Lip
125	2	84	CF Lip
125	3	90	ChrFic Liparulo 2006
125	4	39	F Liparulo SF
125	5	85	FIC LIPARULO
125	6	99	undefined
126	1	84	J E Cro
126	2	83	J E Cro
126	3	82	J E Cro
126	4	68	undefined
126	5	47	undefined
126	6	85	E CRONIN,E CRONIN
126	7	90	E Cronin 2002
126	8	92	E Cro
126	9	39	JE Cronin
126	10	87	J E Cro
126	11	101	undefined
126	12	99	undefined
127	1	92	T Vail
127	2	101	undefined
127	3	25	J Vail
127	4	39	YF Vail #2
128	1	68	undefined
128	2	90	Pickard 1984
128	3	87	LP F Pic M
128	4	101	PICKARD
129	1	83	J E Deg
129	2	84	J E Deg
129	3	82	J E Deg
129	4	99	undefined
129	5	47	undefined
130	1	68	306.44 GHO
130	2	100	PE 1074.75 Gho
130	3	24	306.44 GHO
131	1	92	Smith
131	2	34	F/Sm-5
131	3	90	Smith 1990
131	4	25	F Smith
131	5	87	F Smi #4 Courtneys of Africa
131	6	39	F Smith S3V5
132	1	98	B Fey
133	1	92	AUD Chabon
134	1	92	EZ 5
134	2	90	NR Findlay 2010
135	1	84	J E Jav
136	1	83	F Gan
136	2	24	Fic GAN
136	3	101	GANN
136	4	99	undefined
137	1	90	J 551 Blo 1999
137	2	68	undefined
137	3	92	J 551.078 Blo
138	1	87	FC DVD Boyne May 11/11
139	1	99	undefined
139	2	68	undefined
139	3	21	undefined
139	4	47	undefined
140	1	90	DVD 791.436 IMAX Galapagos
140	2	85	DVD GALAPAGOS 1966
141	1	68	undefined
141	2	85	FIC BARNES
141	3	25	F Barnes
141	4	87	F Bar M
141	5	90	Barnes 1995
141	6	34	F/Ba-26 M
141	7	101	BARNES
142	1	82	327.73 Cho
142	2	135	327.73 Cho
142	3	85	327.73 CHOMSKY
142	4	39	327.73009 Chomsky
142	5	99	undefined
142	6	101	327.73
143	1	68	undefined
143	2	99	undefined
143	3	34	618.92 RAPEE 2008
144	1	85	956.7044 ISIKOFF
144	2	99	undefined
145	1	24	F WIN
145	2	87	F Win
145	3	85	FIC WINSTON
145	4	92	Winston
145	5	39	F Winston
145	6	25	F Winston
146	1	68	undefined
146	2	99	undefined
146	3	101	WEBER
147	1	83	J F Kli
147	2	99	undefined
147	3	85	J KLINE
147	4	90	J Kline 2000
147	5	98	J Pbk Kl
147	6	46	undefined
148	1	72	LP Bar
149	1	85	J ROWLING,J ROWLING
149	2	101	ROWLING
150	1	84	FC J Row v.4
150	2	99	undefined
151	1	85	T 362.29 BARTER
152	1	72	A/F Spe
153	1	68	undefined
153	2	83	J 793.8 MacL
153	3	99	undefined
153	4	21	undefined
154	1	99	undefined
154	2	68	undefined
155	1	85	155.9 VAN PRAAGH
155	2	98	155.937 Van
155	3	90	155.937 Van 2000
155	4	46	undefined
156	1	24	B. HEW
156	2	98	B Hew
156	3	90	B Hewitt 1985
156	4	87	B Hew
156	5	99	undefined
156	6	46	undefined
157	1	98	971.273,971.273
157	2	34	971.27 Nee
157	3	101	971.273
158	1	135	CF Ben v.3
158	2	90	ChrFic Benrey 2004
159	1	87	F Rak
159	2	39	undefined
160	1	24	F And SHO #4
160	2	34	F/An-2
161	1	92	Dial
162	1	24	F McC M #1 Ivy Malone mystery
162	2	90	ChrFic McCourtney 2004
162	3	34	F/McC-13 M
162	4	25	F McCourtney
163	1	24	F SAN
163	2	101	undefined
163	3	44	Mys San
163	4	83	F San
163	5	84	F San
163	6	82	F San
163	7	135	F San
163	8	90	Sandford 2007
163	9	92	Sandford
163	10	34	PBK F Sandfor 2007
163	11	39	F Sandford,F Sandford (pbk)
163	12	25	W F Sandford
164	1	84	LP F For
164	2	83	F For
164	3	82	F For
164	4	34	F / Fo-77
164	5	25	F Forsyth
164	6	46	undefined
164	7	68	undefined
164	8	101	FORSYTH,FORSYTH
164	9	92	Forsyth
164	10	85	PAPERBACK FORSYTH
164	11	99	undefined
164	12	87	F For
165	1	99	undefined
166	1	68	undefined
166	2	85	FIC GREELEY
166	3	24	FIC GRE
166	4	90	Greeley 1998
166	5	71	F Gre
166	6	98	Fic Gr
166	7	33	Fic Gre
166	8	47	undefined
167	1	71	913.37 Had
167	2	101	undefined
167	3	99	undefined
168	1	21	undefined
169	1	84	J 535 Soh
170	1	92	305.897 Fra
170	2	46	undefined
170	3	100	E/98/.P99/Fra
171	1	92	T Reeve
171	2	99	undefined
172	1	68	576.8 GAR
173	1	85	248.8 LINAMEN
173	2	90	248.8 Lin 2002
173	3	99	undefined
174	1	85	DVD INSIDIOUS 1486
175	1	20	B/Morissette
176	1	20	F/Niven/ScF-Fan
177	1	30	undefined
178	1	101	332.024
178	2	99	undefined
179	1	24	297 ISL
179	2	99	undefined
179	3	100	Periodical/Annals/588
180	1	72	J 04.67 Jef
181	1	90	Barr 1982
181	2	101	undefined
181	3	34	F/Ba-27
182	1	39	YF De la Cruz #2
183	1	68	undefined
183	2	85	PAPERBACK KELLERMAN
183	3	98	Fic Myst Ke
183	4	34	F/Ke-28 M
183	5	39	F Kellerma M (pbk)
184	1	46	J E OCEA
185	1	68	undefined
185	2	90	J 811.54 Lee
185	3	101	undefined
185	4	46	undefined
185	5	47	undefined
185	6	83	J 811.54 Lee
185	7	84	J 811.54 Lee
185	8	82	J 811.54 Lee
185	9	135	J 811.54 Lee
185	10	92	J 811 Lee
186	1	87	J F Smi
186	2	99	undefined
187	1	39	B James
188	1	92	T Hyde
188	2	99	undefined
188	3	101	undefined
189	1	92	746.4 Bas
189	2	99	undefined
190	1	30	undefined
191	1	85	J VAIL
192	1	18	914.690444 SAR
193	1	87	J E Keo
193	2	99	undefined
193	3	47	undefined
194	1	18	DVD E MSA # 19
195	1	90	J Leitch 1992
195	2	98	J Pbk Le
195	3	48	J LEI
196	1	46	undefined
197	1	18	J FIC GRI
198	1	30	undefined
199	1	25	E Buffett
199	2	101	undefined
199	3	99	undefined
200	1	68	FIC MUR
200	2	98	Fic Mu
200	3	87	PLS LP Block #29
200	4	99	undefined
200	5	101	MURDOCH
200	6	47	undefined
201	1	90	Smith 1994
201	2	68	CRIME SMI
201	3	99	undefined
202	1	99	undefined
203	1	100	DK/771.K2/1996
204	1	47	ROM PBK
205	1	20	Basement/F/Ross
205	2	78	F Ros
206	1	92	T Myers
206	2	101	undefined
207	1	78	971.21 Ber
207	2	44	971.9 Ber
208	1	39	J940.1 Gravett
208	2	98	940.1 Gra,J 940.1 Gra,940.1
208	3	92	J 940.1 Gra
208	4	87	J 940. 1 Gra
208	5	25	940.1 Gra
208	6	21	undefined
209	1	24	F Dav
209	2	99	undefined
209	3	98	Fic Myst Da
209	4	71	Mys/F Dav
209	5	39	F Davidson M
209	6	25	F Davidson
210	1	30	undefined
210	2	33	Fic Hos
211	1	85	920.071 HERMAN
212	1	78	J 599.8846 Pat
212	2	68	undefined
213	1	30	297 KOR
214	1	98	953/.6705,915.367,953.6705
215	1	99	undefined
216	1	92	J 599.53 Pat
216	2	99	undefined
217	1	68	undefined
217	2	34	649.64 Col
217	3	101	649.6
217	4	98	649.64 Col
217	5	99	undefined
217	6	87	649.6
217	7	48	649.6
218	1	90	DVD Kirk 2002
219	1	18	T FIC WIS
220	1	87	811.54 Wee
221	1	72	712.6 Ada
222	1	99	undefined
223	1	32	284.171233 Bar
224	1	85	FIC LEDBETTER
225	1	99	undefined
226	1	92	658.4 Hil
226	2	87	658.4092 Hil
227	1	101	undefined
227	2	99	undefined
228	1	34	F Kingsbu 2011
228	2	71	F Kin 
228	3	24	F KIN #2 bailey flanigan
229	1	87	F Oke
229	2	98	Fic Ok
229	3	71	F Oke #1
229	4	34	F/Ok-2R
229	5	25	F Oke
230	1	34	F/Wi-72
230	2	101	undefined
230	3	25	W LP Wingate
231	1	32	F Str p.b
232	1	90	YA Carter 2004
232	2	84	J F Car
232	3	83	J F Car
232	4	82	J F Car
232	5	24	J F Car
233	1	83	PB SCFI Tur
233	2	84	PB SCFI Tur
233	3	82	PB SCFI Tur
234	1	85	LP KOONTZ
234	2	90	Koontz 1989
234	3	99	undefined
234	4	68	undefined
234	5	33	undefined
235	1	24	747.92 Lig
235	2	87	747.92 Lig
235	3	39	747.92
236	1	98	J Pbk Al
236	2	34	FAl-5 LP
237	1	33	J 971.064 Gib
238	1	68	709.2 Da Vinci
238	2	25	W 759.5 Pedretti
238	3	46	undefined
239	1	34	F/Co-76 W LP
239	2	25	LP Conway
240	1	24	F KIN #1 bailey flanigan
240	2	39	LP F Kingsbur S10 v1
240	3	34	F Kingsbu 2011
240	4	25	F Kingsbury
240	5	71	F Kin
241	1	90	Deveraux 1988
241	2	101	undefined
241	3	71	F Dev
241	4	21	undefined
241	5	99	undefined
242	1	85	ROMANCEPB LANGAN
243	1	99	undefined
244	1	25	F Pratchett
245	1	71	J625.1 Her
245	2	101	undefined
246	1	92	DVD 38753
247	1	78	J 796.8 Lev
248	1	24	J F DIX #9 pb
248	2	84	J S Har v.9
248	3	82	J S Har v.9
248	4	83	J F Dix v.9
249	1	68	undefined
249	2	98	646.78 Gr
249	3	24	646.78 Gra
249	4	71	646.7 Gray
250	1	46	undefined
251	1	85	J TASHJIAN
251	2	99	undefined
251	3	25	J Tashjian
252	1	90	Christie 1934
252	2	24	F Chr
252	3	101	undefined
252	4	39	LP F Christie M
252	5	34	F/Ch-46 M
252	6	25	F Christie
252	7	99	undefined
253	1	99	undefined
254	1	99	undefined
255	1	84	FC DEVERAU
255	2	87	CD Deveraux (5 discs)
255	3	99	undefined
256	1	24	FIC MCB
256	2	87	F McBa M
256	3	71	Mys/F McB
256	4	39	TB/CD F McBain
256	5	99	undefined
256	6	34	F/McB-12 M
257	1	98	Myst Pbk Ta
257	2	87	F Tan M
257	3	101	undefined
258	1	99	undefined
259	1	30	undefined
260	1	18	398.2 Ham
261	1	44	709.71
261	2	20	709.71/Czernecki
261	3	78	J 709.71220 Cze
262	1	34	LP F Fyfield 2001
262	2	92	Fyfield
263	1	68	undefined
263	2	84	LP F Dai
263	3	99	undefined
263	4	83	F Dai
263	5	82	F Dai
263	6	135	F Dai
263	7	90	Dailey 1996
263	8	85	LP DAILEY
263	9	98	Fic Da
263	10	39	C F Dailey
263	11	87	F Dai
263	12	25	F Dailey
264	1	25	E McConnell
264	2	101	undefined
265	1	83	VIDEO HOW-TO Nor
266	1	24	F TAS
267	1	68	EASY READ SPO
267	2	34	J/F/Aue
267	3	92	Series
267	4	101	undefined
268	1	68	undefined
268	2	83	F Cla
268	3	84	F Cla
268	4	78	F Cla
268	5	90	Clavell 1981
268	6	99	undefined
268	7	101	undefined
268	8	98	Fic Cl
268	9	71	F Cla,F Cla
268	10	25	F Clavell
268	11	33	Fic Cla
269	1	99	undefined
269	2	100	Canada/NatLib/Annual
270	1	98	Fic Ec
270	2	72	A/F ECO
271	1	72	623.821 Ran
272	1	83	305.569 Ehr
272	2	24	305.5690 EHR
272	3	99	undefined
273	1	84	PB F Tho
273	2	83	PB F Tho
273	3	101	undefined
274	1	85	364.1092 PARADIS
274	2	99	undefined
274	3	101	undefined
275	1	83	J S Mai v.2
275	2	82	J S Mai v.2
275	3	90	J Martin 2007
275	4	24	J F MAR #2 pb. main street
275	5	92	Series
275	6	101	undefined
276	1	99	undefined
276	2	85	FIC TAPPLY
276	3	24	F TAP M
277	1	99	undefined
278	1	90	J B Armstrong 1980
279	1	99	undefined
280	1	101	undefined
281	1	90	Hamilton 2000
281	2	92	Hamilton
281	3	87	F Ham
281	4	99	undefined
281	5	25	F Hamilton
281	6	101	undefined
282	1	90	267 All 2005
282	2	99	undefined
283	1	92	J 551.46 MacQ
283	2	85	J 551.46 MACQUITTY
283	3	101	undefined
283	4	25	551.46 MacQ
283	5	48	J 551.46 MAC
284	1	85	FIC MALARKEY
284	2	99	undefined
285	1	68	undefined
285	2	34	F/Ja-23
285	3	98	Myst Pbk Ja
285	4	92	James
285	5	39	F James M
285	6	25	F James
286	1	46	undefined
287	1	68	undefined
287	2	99	undefined
288	1	83	F Why v.3
288	2	84	F Why v.3
288	3	82	F Why v.3
289	1	90	Turow 2005
289	2	83	F Tur
289	3	84	F Tur
289	4	82	F Tur
289	5	39	F Turow
289	6	34	F/Tu-86
289	7	33	undefined
289	8	68	undefined
289	9	24	F TUR
289	10	87	F Tur M
289	11	85	FIC TUROW,FIC TUROW
289	12	98	Fic Myst Tu
289	13	92	Turow
289	14	25	W F Turow
290	1	99	undefined
291	1	90	Nance 2006
291	2	68	FIC NAN
291	3	84	F Nan
291	4	83	F Nan
291	5	82	F Nan
291	6	99	undefined
291	7	85	FIC NANCE
291	8	92	Nance
291	9	101	undefined
291	10	71	F/Nance
291	11	25	F Nance
292	1	85	FIC BERG,FIC BERG
292	2	90	Berg 2000
292	3	39	F Berg
292	4	101	undefined
292	5	25	F Berg
292	6	48	F BER
292	7	46	undefined
292	8	68	undefined
292	9	24	FIC BER
292	10	87	F Ber
292	11	98	Fic Be
292	12	34	F/Be-45
292	13	92	Berg
292	14	71	F/Berg
293	1	99	undefined
294	1	101	undefined
295	1	32	J 553.2 Pip
296	1	82	F Str
296	2	90	Strout 2008
296	3	101	undefined
296	4	24	F STR
296	5	25	F Strout
297	1	20	J/F/Brian/v. 13
297	2	84	YA F Bri
298	1	72	A/F   Sne
299	1	100	F/5005/Ora,F/5005/Ora
299	2	99	undefined
300	1	99	undefined
301	1	71	915.1 Bon
301	2	101	undefined
301	3	99	undefined
302	1	24	636.76 MAG
302	2	99	undefined
303	1	85	940.3 MACMILLAN
303	2	24	940.3141 MacM
303	3	90	940.3 Mac 2002
303	4	39	940.3141 Macmillan
303	5	46	undefined
303	6	47	undefined
304	1	83	J E Car
304	2	135	J E Car
304	3	24	J E Car
304	4	99	undefined
304	5	90	E Carle 1990
304	6	68	undefined
304	7	48	E CAR
304	8	101	undefined
304	9	21	undefined
305	1	24	F Cot W pb
305	2	99	undefined
306	1	101	920
306	2	99	undefined
306	3	90	944.949 Mas 1986
306	4	98	B Mas
307	1	99	undefined
308	1	87	971. 06 Wai
309	1	83	641.664 Por
309	2	84	641.664 Por
309	3	24	641.664 POR
309	4	98	641.664 Por
309	5	33	undefined
310	1	99	undefined
311	1	101	696.1 COR
311	2	30	696.1 COR
311	3	31	696.1 COR
312	1	90	Hall 2002
312	2	101	undefined
313	1	24	971.273 SCO
313	2	98	BB Sco
313	3	99	undefined
313	4	101	971.273,971.273
314	1	87	J E Gar
314	2	101	undefined
315	1	78	J 523.482 Asi
315	2	135	J 523.482 Asi 1990
315	3	101	undefined
316	1	99	undefined
317	1	90	McNaught 1993
317	2	98	Fic McN
317	3	34	F/McN-23
317	4	25	F McNaught
317	5	87	F McN
318	1	85	J 636.7 SJONGER
318	2	101	undefined
318	3	99	undefined
318	4	92	J 636.7 Sjo
318	5	87	J 636.707 Sjo
319	1	25	E Lee
320	1	30	undefined
321	1	90	Churchill 1993
321	2	101	undefined
322	1	78	561.7 Sch
323	1	48	641.555,641.555
324	1	24	J E Bri
324	2	90	E Bright 2003
325	1	24	FIC EDD
325	2	87	SF Edd #2
325	3	68	undefined
325	4	90	Fantasy Eddings 1982
325	5	25	F Eddings
326	1	24	F Ric VAM #3 pb
326	2	71	F Ric
326	3	68	undefined
326	4	39	F Rice #3
326	5	87	F Ric #3
326	6	25	F Rice
327	1	99	undefined
328	1	100	undefined
329	1	90	LP Creasey 1977
330	1	84	J 428.2 Cle
331	1	99	undefined
332	1	100	JL/339/.A45/Ste
333	1	82	OS 994.306 Que
334	1	20	undefined
335	1	68	undefined
336	1	78	FL J E War
337	1	92	745.5 Bas
338	1	39	746.46041 Quick
339	1	24	822 REM
339	2	99	undefined
339	3	90	Remarque 1930
339	4	101	undefined
339	5	68	undefined
339	6	87	F Rem
339	7	71	War/F Rem
339	8	92	Remarque
339	9	25	F Remarque
339	10	98	Fic Re
340	1	84	F Whi
340	2	85	LP WHITE
340	3	87	F Whi
340	4	71	F White LP
340	5	98	T.B. Wh
340	6	99	undefined
341	1	68	undefined
341	2	99	undefined
342	1	92	PB M
342	2	25	F McLane
343	1	20	LP/F/Cornwell
344	1	32	T
345	1	24	J 522.682 Ric
345	2	39	J522.682 Richardson
346	1	100	HV 6171 Koh
347	1	21	F GREENWOOD
348	1	71	F Tho
348	2	68	FIC THO
348	3	34	F Thomas 2008 c2
348	4	48	F THO
349	1	98	J Pbk Ba
349	2	68	JF DOLPHIN DIARIES
349	3	39	JF Baglio #6
349	4	48	J DOL
350	1	90	332.02401 Gad 1999
350	2	99	undefined
351	1	92	T Sedgwick
351	2	99	undefined
352	1	24	F SHR LP
352	2	34	F Shreve 2010
352	3	71	F Shreve
352	4	48	F SHR
353	1	100	Canada/AudGen/Annual/1996/c11
354	1	92	Series
354	2	101	undefined
355	1	92	643.12 Rin
355	2	83	643 Rin
355	3	84	643 Rin
355	4	99	undefined
355	5	101	undefined
356	1	101	undefined
356	2	90	Quinn 1986
356	3	34	undefined
356	4	71	F Qui
356	5	98	Fic Qu
356	6	99	undefined
356	7	33	undefined
357	1	92	215 Kau
358	1	84	F Wal
359	1	39	F Krentz
359	2	24	F KRE
359	3	92	Krentz
359	4	25	W F Krentz
359	5	71	F/Kren
359	6	48	F KRE
359	7	47	F KRENTZ
360	1	99	undefined
361	1	39	F Delinsky
361	2	90	LP Delinsky 1993
361	3	85	FIC DELINSKY
361	4	92	Delinsky
361	5	25	LP Delinsky
361	6	101	undefined
362	1	83	F Adl
362	2	84	F Adl
362	3	92	Adler
362	4	90	LP Adler 2006
362	5	24	F ADL
362	6	85	FIC ADLER
362	7	39	F Adler
362	8	98	Fic Ad
363	1	83	YA F Cob
363	2	84	YA F Cob
363	3	24	J F COB
363	4	92	T Coben
363	5	90	YA Coben 2011
363	6	39	F Coben
363	7	87	Y F Cob
363	8	34	F Coben 2011
364	1	83	BR Hob
364	2	84	BR Hob
364	3	82	BR Hob
364	4	24	J E Hob
364	5	47	undefined
364	6	101	undefined
364	7	85	E HOBAN
364	8	99	undefined
364	9	90	NR Hoban 1998
364	10	98	J E Ho
364	11	87	J E Hob
364	12	48	E HOB
365	1	24	F KLE
365	2	84	F Kle
365	3	82	PB F Kle
365	4	39	F Kleypas,CF Kleypas
365	5	87	F Kle #1 Travis Series
365	6	92	Kleypas
365	7	34	Kleypas 2007
365	8	25	F Kleypas
366	1	82	J 975.941 Gib
366	2	99	undefined
366	3	98	910.4 GIB,975.941
367	1	84	343.077 Sur
367	2	83	343.077 Sur
367	3	99	undefined
367	4	100	Manitoba SurfRBd
368	1	90	Conant 2005
368	2	99	undefined
368	3	85	FIC CONANT
368	4	98	Myst Pbk Co
369	1	85	PAPERBACK MARGOLIN
369	2	34	F Mar
369	3	21	undefined
369	4	90	Margolin 2004
369	5	24	F Mar
369	6	68	undefined
369	7	98	Fic Myst Ma
369	8	25	W LP Margolin
369	9	101	undefined
369	10	87	LP F Mar M
370	1	85	818.5403 MOORE,818.5403 MOORE
370	2	101	817.6
370	3	68	undefined
370	4	25	817.6 Moore
370	5	99	undefined
370	6	100	PN/6288/Moo
371	1	83	F Rus
371	2	90	Rushdie 1983
371	3	99	undefined
371	4	101	RUSHDIE,RUSHDIE
372	1	90	J Brooks 1999
372	2	85	J BROOKS
372	3	24	J F Bro WOL #10 pb
372	4	101	undefined
373	1	83	J 597.96 Gra
373	2	84	J 597.96 Gra
373	3	92	J 597.96 Gra
373	4	99	undefined
373	5	101	undefined
374	1	98	Fic De
374	2	34	F/De-51
374	3	47	undefined
374	4	87	LP F Dev
374	5	16	Fic Dev
374	6	39	F Deveraux
374	7	25	F Deveraux
374	8	71	F Dev
374	9	48	F DEV
374	10	33	Fic Dev
374	11	46	undefined
375	1	24	F STA SF #2 clone wars gambit
376	1	72	VID   Ste
377	1	90	E Nielsen 1992
377	2	101	undefined
378	1	85	641.8 ADAMS
379	1	83	LP F Qui
379	2	84	F Qui
379	3	82	F Qui
379	4	85	FIC QUICK,FIC QUICK
379	5	34	F/Qu-4
379	6	71	F/Qui
379	7	68	undefined
379	8	98	Fic Qu
379	9	25	F Quick
379	10	99	undefined
379	11	46	undefined
379	12	33	undefined
379	13	92	LP Quick
379	14	90	LP Quick 2001
379	15	101	undefined
379	16	39	F Quick
379	17	87	F Qui
380	1	83	J F Gam
380	2	84	J F Gam
380	3	82	J F Gam
380	4	98	J Fic Ga
380	5	39	JF Gamache
380	6	34	J/F/Gam
380	7	71	Y/ADV Gam
380	8	100	PS 8563 Gam
380	9	101	GAMACHE,GAMACHE
381	1	71	J796.34 Gut
381	2	101	undefined
381	3	46	undefined
382	1	83	J 597.92 Mar
382	2	84	J 597.92 Mar
382	3	101	undefined
382	4	99	undefined
382	5	90	J 597.92 Mar 1989
382	6	33	undefined
383	1	99	undefined
383	2	39	J358.18 Hogg
383	3	46	undefined
384	1	24	F PAT LP
384	2	25	F Patterson
384	3	71	Mys/F Pat
384	4	34	F Patters 2011
384	5	68	CRIME PAT
385	1	90	759.11 Ter
385	2	68	undefined
385	3	99	undefined
385	4	87	759.11 Ter
386	1	90	J 818 Chm 1986
386	2	68	undefined
387	1	31	undefined
387	2	21	undefined
388	1	98	M-1769
389	1	83	F Kre
389	2	84	F Kre
389	3	99	undefined
389	4	101	undefined
389	5	90	Krentz 1995
389	6	87	F Kre
389	7	68	undefined
389	8	98	Fic Kr
389	9	48	F KRE
390	1	99	undefined
390	2	98	M-303
391	1	99	undefined
391	2	83	910.91634 Hus
391	3	84	910.91634 Hus
391	4	82	910.91634 Hus
391	5	87	909. 09631 Hus
391	6	85	910.9163 HUSTAK
391	7	90	910.91634 Hus 1998
391	8	101	910.916^34
391	9	100	G/530/.T6/Hus
392	1	31	302 GLA
393	1	24	Fic FLE
394	1	92	B Tesla
395	1	72	181.09514 Raw
396	1	32	811 Oli
397	1	101	undefined
398	1	87	LP F Cri
399	1	99	undefined
399	2	101	undefined
400	1	83	371.82 Mor
400	2	84	371.82 Mor
400	3	82	371.82 Mor
400	4	101	undefined
400	5	25	371.82209549 Mortenson
400	6	39	371.822 Morten
400	7	90	371.829 Mor 2006
400	8	92	371.822 Mor
400	9	24	371.822 MOR
400	10	87	371.822 Mor,371.822 Mor
400	11	34	371.82 Mortens
400	12	98	371.82209549 Mo
400	13	68	undefined
401	1	34	F/Cl-51W
401	2	99	undefined
401	3	101	undefined
401	4	47	undefined
402	1	85	J 578.76 MILLER-SCHROEDER
403	1	101	undefined
403	2	87	822. 3 Sha
403	3	90	822.3 Lud 1962
403	4	39	822.3 Ludowyk
403	5	68	undefined
403	6	47	undefined
404	1	24	F BLA #3 suncoast chronicles
404	2	98	Fic Bl
404	3	90	ChrFic Blackstock 1996
404	4	25	F Blackstock
404	5	84	CF Bla v.3
404	6	101	BLACKST,BLACKST
404	7	99	undefined
405	1	90	G 289.70947 Kla 1997
406	1	87	F Mez
407	1	99	undefined
408	1	90	ChrFic Lacy 2002
408	2	99	undefined
408	3	101	LACY
409	1	24	J F BRA #2 the joy of spooking
409	2	92	J Bracegirdle
409	3	99	undefined
409	4	101	undefined
410	1	98	T.B. Bl
411	1	99	undefined
412	1	100	PN/4888/.O25/Lee
413	1	84	J E Bre
413	2	83	J E Bre
413	3	82	J E Bre
413	4	44	E Bre
413	5	99	undefined
413	6	46	undefined
413	7	85	E BRETT
413	8	24	J E Bre
413	9	68	undefined
413	10	90	E Brett 2004
413	11	92	E Bre
413	12	71	C/F Brett
413	13	101	BRETT
414	1	31	JR EASY MON
415	1	34	PBK F McNaugh
415	2	68	undefined
415	3	99	undefined
416	1	68	undefined
416	2	87	364. 1523 092 She
416	3	24	364.1523 SHE
416	4	100	HV/6535/.C33/She
416	5	99	undefined
417	1	16	Fic Lin
417	2	84	PB F Lin
417	3	44	Rom Lin
417	4	68	undefined
417	5	48	undefined
418	1	87	J 292. 211 Ger
419	1	84	J 989.5 Mor
419	2	99	undefined
420	1	84	947.7 She
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY users (uid, name, password, active, email_address, admin, library, mailing_address_line1, mailing_address_line2, mailing_address_line3, ill_sent, home_zserver_id, home_zserver_location, last_login) FROM stdin;
\.


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

