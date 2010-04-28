--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'Standard public schema';


--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE PROCEDURAL LANGUAGE plpgsql;


SET search_path = public, pg_catalog;

--
-- Name: update_ts(); Type: FUNCTION; Schema: public; Owner: mapapp
--

CREATE FUNCTION update_ts() RETURNS "trigger"
    AS $$
   BEGIN
     NEW.ts = NOW();
     RETURN NEW;
   END;
$$
    LANGUAGE plpgsql;


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
-- Name: ill_stats; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE ill_stats (
    uid smallint,
    target_id smallint,
    "location" character varying(40),
    ts timestamp without time zone DEFAULT now() NOT NULL,
    callno character varying(20),
    pubdate character varying(20)
);


ALTER TABLE public.ill_stats OWNER TO mapapp;

--
-- Name: locations; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE locations (
    target_id smallint,
    "location" character varying(8),
    name character varying(100),
    email_address character varying(200),
    ill_received smallint
);


ALTER TABLE public.locations OWNER TO mapapp;

--
-- Name: marc; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE marc (
    sessionid character varying(40),
    id smallint,
    ts timestamp without time zone DEFAULT now() NOT NULL,
    marc bytea,
    found_at_server character varying(200),
    target_id smallint,
    title character varying(255),
    author character varying(255),
    isbn character varying(20)
);


ALTER TABLE public.marc OWNER TO mapapp;

--
-- Name: notforloan; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE notforloan (
    target smallint,
    tag character(3),
    subfield character(1),
    text character varying(15),
    atstart smallint DEFAULT 0::smallint
);


ALTER TABLE public.notforloan OWNER TO mapapp;

--
-- Name: public_libraryregionandtown; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE public_libraryregionandtown (
    id integer NOT NULL,
    library character varying(50),
    town character varying(50),
    region character varying(15),
    libtype character varying(15),
    email character varying(255)
);


ALTER TABLE public.public_libraryregionandtown OWNER TO mapapp;

--
-- Name: public_libraryregionandtown_id_seq; Type: SEQUENCE; Schema: public; Owner: mapapp
--

CREATE SEQUENCE public_libraryregionandtown_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.public_libraryregionandtown_id_seq OWNER TO mapapp;

--
-- Name: public_libraryregionandtown_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mapapp
--

ALTER SEQUENCE public_libraryregionandtown_id_seq OWNED BY public_libraryregionandtown.id;


--
-- Name: public_libraryregionandtown_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mapapp
--

SELECT pg_catalog.setval('public_libraryregionandtown_id_seq', 1, false);


--
-- Name: public_requests; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE public_requests (
    sessionid character varying(40),
    requestid smallint,
    id smallint,
    ts timestamp without time zone DEFAULT now() NOT NULL,
    marc bytea,
    found_at_server character varying(200),
    target_id smallint,
    title character varying(255),
    author character varying(255),
    isbn character varying(20)
);


ALTER TABLE public.public_requests OWNER TO mapapp;

--
-- Name: search_pid; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE search_pid (
    sessionid character varying(50),
    pid smallint
);


ALTER TABLE public.search_pid OWNER TO mapapp;

--
-- Name: status_check; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE status_check (
    sessionid character varying(50),
    target_id smallint,
    event smallint,
    msg character varying(255),
    ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.status_check OWNER TO mapapp;

--
-- Name: targets; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE targets (
    id integer NOT NULL,
    name character varying(80) NOT NULL,
    z3950_connection_string character varying(80) NOT NULL,
    email_address character varying(200),
    available smallint,
    holdings_tag character(3),
    holdings_location character(1),
    holdings_callno character(1),
    holdings_avail character(1),
    holdings_collection character(1),
    holdings_due character varying(20),
    ill_received smallint,
    handles_holdings_improperly smallint,
    iselectronicresource smallint DEFAULT 0::smallint,
    iswebresource smallint DEFAULT 0::smallint,
    isstandardresource smallint DEFAULT 0::smallint,
    preferredrecordsyntax character varying(10),
    requires_credentials smallint DEFAULT 0
);


ALTER TABLE public.targets OWNER TO mapapp;

--
-- Name: targets_id_seq; Type: SEQUENCE; Schema: public; Owner: mapapp
--

CREATE SEQUENCE targets_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.targets_id_seq OWNER TO mapapp;

--
-- Name: targets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mapapp
--

ALTER SEQUENCE targets_id_seq OWNED BY targets.id;


--
-- Name: targets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mapapp
--

SELECT pg_catalog.setval('targets_id_seq', 44, true);


--
-- Name: user_authgroups; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE user_authgroups (
    uid smallint,
    gid smallint
);


ALTER TABLE public.user_authgroups OWNER TO mapapp;

--
-- Name: user_target; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE user_target (
    uid smallint,
    target_id smallint
);


ALTER TABLE public.user_target OWNER TO mapapp;

--
-- Name: user_zserver_credentials; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE user_zserver_credentials (
    uid integer,
    zid integer,
    username character varying(80),
    "password" character varying(80)
);


ALTER TABLE public.user_zserver_credentials OWNER TO mapapp;

--
-- Name: users; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE users (
    uid integer NOT NULL,
    name character varying(30),
    "password" character varying(30),
    active smallint,
    email_address character varying(200),
    "admin" smallint,
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
-- Name: users_uid_seq; Type: SEQUENCE; Schema: public; Owner: mapapp
--

CREATE SEQUENCE users_uid_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.users_uid_seq OWNER TO mapapp;

--
-- Name: users_uid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mapapp
--

ALTER SEQUENCE users_uid_seq OWNED BY users.uid;


--
-- Name: users_uid_seq; Type: SEQUENCE SET; Schema: public; Owner: mapapp
--

SELECT pg_catalog.setval('users_uid_seq', 1, false);


--
-- Name: vendor; Type: TABLE; Schema: public; Owner: mapapp; Tablespace: 
--

CREATE TABLE vendor (
    name character varying(30),
    "password" character varying(30),
    active smallint DEFAULT 0::smallint
);


ALTER TABLE public.vendor OWNER TO mapapp;

--
-- Name: gid; Type: DEFAULT; Schema: public; Owner: mapapp
--

ALTER TABLE authgroups ALTER COLUMN gid SET DEFAULT nextval('authgroups_gid_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: mapapp
--

ALTER TABLE public_libraryregionandtown ALTER COLUMN id SET DEFAULT nextval('public_libraryregionandtown_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: mapapp
--

ALTER TABLE targets ALTER COLUMN id SET DEFAULT nextval('targets_id_seq'::regclass);


--
-- Name: uid; Type: DEFAULT; Schema: public; Owner: mapapp
--

ALTER TABLE users ALTER COLUMN uid SET DEFAULT nextval('users_uid_seq'::regclass);


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
-- Data for Name: ill_stats; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY ill_stats (uid, target_id, "location", ts, callno, pubdate) FROM stdin;
1	1		2008-11-06 16:49:10	\N	\N
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY locations (target_id, "location", name, email_address, ill_received) FROM stdin;
1	MNHA	Ayamiscikewikamik	tansi23@hotmail.com	0
1	MSTG	Bibliothèque Allard	allardill@hotmail.com	76
1	MSJB	Bibliothèque Montcalm	biblio@atrium.ca	75
1	MNDP	Bibliothèque Pere Champagne	ndbiblio@yahoo.ca	0
1	MIBR	Bibliothèque Ritchot - Main	ritchot@atrium.ca	57
1	MSAD	Bibliothèque Ritchot - St. Adolphe	stadbranch@hotmail.com	0
1	MSAG	Bibliothèque Ritchot - Ste. Agathe	bibliosteagathe@atrium.ca	0
1	MSCL	Bibliothèque Saint-Claude	stclib@mts.net	0
1	MLB	Bibliothèque Saint-Joachim	bsjl@bsjl.ca	75
1	MSA	Bibliothèque Ste. Anne	steannelib@steannemb.ca	50
1	MS	Bibliothèque Somerset	somlib@mts.net	31
1	MBOM	Boissevain and Morton Regional Library	mbom@mts.net	89
1	MVE	Border Regional Library - Main	borderregionallibrary@rfnow.com	57
1	ME	Border Regional Library - Elkhorn	elkhornbrl@rfnow.com	5
1	MMCA	Border Regional Library - McAuley	library@mcauley-mb.com	4
1	MCB	Boyne Regional Library	boynereg@mts.net	99
1	MBBR	Brokenhead River Regional Library	brrlibr2@mts.net	274
1	MEL	Eriksdale Public Library	epl1@mts.net	18
1	MCH	Churchill Public Library	mchlibrary@yahoo.ca	59
1	MGE	Evergreen Regional Library - Main	exec@mts.net	169
1	MAB	Evergreen Regional Library - Arborg	arborlib@mts.net	2
1	MRB	Evergreen Regional Library - Riverton	rlibrary@mts.net	2
1	MFF	Flin Flon Public Library	ffpl@mts.net	41
1	MGI	Bette Winner Public Library	bwinner@gillamnet.com	16
1	MHH	Headingley Municipal Library	hml@mts.net	116
1	MSTP	Jolys Regional Library - Main	stplibrary@jrlibrary.mb.ca	108
1	MSSM	Jolys Regional Library - St. Malo	stmlibrary@jrlibrary.mb.ca	0
1	MKL	Lakeland Regional Library - Main	lrl@mts.net	57
1	MCCB	Lakeland Regional Library - Cartwright	cartlib@mts.net	0
1	MPM	Pilot Mound Public Library - Pilot Mound	pmlibrary@mts.net	0
1	MLR	Leaf Rapids Public Library	lrlib@mts.net	28
1	MLLC	Lynn Lake Centennial Library	lynnlib@mts.net	0
1	MMA	Manitou Public Library	manitoulibrary@mts.net	27
1	MMNN	North Norfolk-MacGregor Library	maclib@mts.net	66
1	MSRN	North-West Regional Library - Main	nwrl@mts.net	10
1	MBB	North-West Regional Library - Benito	benlib@mts.net	52
1	MLPJ	Pauline Johnson Library	mlpj@mts.net	51
1	MP	Pinawa Public Library	plibrary@sdwhiteshell.mb.ca	96
1	MRIP	Prairie Crocus Regional Library	pcrl@mts.net	24
1	MRA	Rapid City Regional Library	rcreglib@mts.net	46
1	MRP	Reston District Library	restonlb@yahoo.ca	95
1	MRO	Rossburn Regional Library	rrl@mts.net	0
1	MBA	R.M. of Argyle Public Library	rmargyle@gmail.com	0
1	MRD	Russell & District Regional Library - Main	ruslib@mts.net	0
1	MBI	Russell & District Library - Binscarth	binslb@mts.net	0
1	MSTR	Ste. Rose Regional Library	sroselib@mts.net	74
1	MSL	Snow Lake Community Library	dslibrary@hotmail.com	44
1	MSTO	South Interlake Regional Library - Main	circ@sirlibrary.com	19
1	MTSIR	South Interlake Library - Teulon	teulonbranchlibrary@yahoo.com	0
1	MESM	Southwestern Manitoba Regional Library - Main	swmblib@mts.net	41
1	MESMN	Southwestern Manitoba Regional Library - Napinka	smrl1nap@yahoo.ca	0
1	MESP	Southwestern Manitoba Regional Library - Pierson	pcilibrary@goinet.ca	35
1	MTP	The Pas Regional Library	library@mts.net	11
1	MTH	Thompson Public Library	interlibraryloans@thompsonlibrary.com	99
1	MMVR	Valley Regional Library	valleylib@mts.net	58
1	MMR	Minnedosa Regional Library	mmr@mts.net	124
1	MWP	Manitoba Legislative Library	legislative_library@gov.mb.ca	0
1	MWPL	Public Library Services	pls@gov.mb.ca	130
1	MEPL	Emerson Library	emlibrary@hotmail.com	67
1	MBAC	Assiniboine Community College	library@assiniboinec.mb.ca	0
1	MWRR	Red River College	lgirardi@rrcc.mb.ca	0
1	MWTS	Manitoba Telecom Services Corporate	lisanne.wood@mts.mb.ca	0
1	MSERC	Brandon SERC	serc2mb@mb.sympatico.ca	0
1	MWMRC	Industrial Technology Centre	bdearth@itc.mb.ca	0
1	MBBB	Bibliotheque Allard - Beaches	beacheslibrary@hotmail.com	1
1	MMLM	Morden School		0
1	MSSC	Shilo Community Library	shilocommunitylibrary@yahoo.ca	0
1	MSEMH	Selkirk Mental Health Centre	loweiss@gov.mb.ca	0
1	PLSAV	PLS Audio/Visual	AV@gov.mb.ca	0
1	ASGY	Yellowhead Regional	lfrolek@yrl.ab.ca	0
1	PLSOS	PLS Openshelf	openshelf@gov.mb.ca	0
1	MWHBCA	Hudsons Bay Company Archives	hbca@gov.mb.ca	0
1	MWSC	Society for Manitobans with Disabilities - Stephen Sparling	library@smd.mb.ca	0
1	MWEMM	Manitoba Industry Trade and Mines - Mineral Resource	LJanower@gov.mb.ca	0
1	MTPL	Bibliothèque Publique Tache Public Library - Main	btl@srsd.ca	46
1	MWJ	Department of Justice	jodi.turner@justice.gc.ca	0
1	MBAG	Canadian Agriculture Library - Brandon	libbrandon@agr.gc.ca	0
1	MNCN	Thompson Public Library - Nelson House	NCNBranch@Thompsonlibrary.com	0
1	MPFN	Peguis Community	peguislibrary@yahoo.ca	0
5	MBW	Western Manitoba Regional Library - Main	bdnill@wmrl.ca	625
5	MCNC	Western Manitoba Regional Library - Carberry/North Cypress	carberry@wmrl.ca	97
5	MGW	Western Manitoba Regional  Library - Glenboro/South Cypress	glenboro@wmrl.ca	35
5	MNW	Western Manitoba Regional  Library - Neepawa	neepawa@wmrl.ca	96
5	MHW	Western Manitoba Regional - Hartney Cameron Branch	hartney@wmrl.ca	0
1	DTL	Great Library of Davidland	David_A_Christensen@hotmail.com	0
1	test	Test Library	David.A.Christensen@gmail.com	0
12	Altona	South Central Regional Library - Altona	scrlalib@mts.net	159
12	Morden	South Central Regional Library - Morden	scrlillm@mts.net	358
12	Winkler	South Central Regional Library - Winkler	scrlillw@mts.net	357
19	Stonewal	South Interlake Regional Library - Stonewall	circ@sirlibrary.com	\N
19	Teulon	South Interlake Regional Library - Teulon	teulonbranchlibrary@yahoo.com	\N
28	CENT	Millenium Library	wpl-illo@winnipeg.ca	339
\.


--
-- Data for Name: marc; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY marc (sessionid, id, ts, marc, found_at_server, target_id, title, author, isbn) FROM stdin;
DAVID	1	2009-09-29 11:22:34.500715	00787cam a2200265 a 4500001001300000003000500013005001700018008004100035010001700076020001500093020002200108035001400130040001300144049000800157050002200165082001400187100002000201245007500221260004800296300003300344650001200377650001200389852006100401949005900462\\036PLSb10003822\\036MWPL\\03620010301104045.0\\036010301s1979    pau    e          1 eng d\\036  \\037a   87001908 \\036  \\037a0830608036\\036  \\037a0830628037 (pbk.)\\036  \\037a137646305\\036  \\037aDLC\\037cDLC\\036  \\037aPLS\\03600\\037aSF487\\037b.H414 1987\\0360 \\037a636.5\\037219\\0361 \\037aHaynes, Cynthia\\03610\\037aRaising turkeys, ducks, geese, pigeons, and guineas /\\037cCynthia Haynes.\\0360 \\037aBlue Ridge Summit, PA :\\037bTAB Books,\\037cc1987.\\036  \\037axi, 354 p. :\\037bill. ;\\037c24 cm.\\036 0\\037aPoultry\\036 0\\037aPigeons\\0360 \\037aMWPL\\037bMWPL\\037bPLS\\037bMAIN\\037h636.5\\037iHAY\\037kNF\\037p36757001019044\\037t1\\036  \\037mLeaf Rapids\\037cPLS UC\\037d636.5 HAY\\037sUnion Catalogue Item\\037t\\036\\035	PLS Union Catalogue	1	Raising turkeys, ducks, geese, pigeons, and guineas /	Haynes Cynthia	0830608036
\.


--
-- Data for Name: notforloan; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY notforloan (target, tag, subfield, text, atstart) FROM stdin;
2	949	a	PARKVI	0
2	949	a	DPHNVI	0
12	500	a	local	0
2	949	a	DPILL	0
2	949	a	DPHNPR	0
4	500	a	Local	0
12	084	a	ON ORDER	0
12	084	a	ILL 	0
18	500	a	Local	0
9	500	a	LOCAL	0
11	500	a	local	0
16	500	a	Local	0
2	949	g	2	1
5	245	h	videorecording	0
15	500	a	local	0
28	245	h	DVD	1
2	008	\N	0901	1
15	852	h	PROCESSED	0
2	008	\N	0811	1
5	245	h	sound recording	0
5	245	h	periodical	0
2	008	\N	0812	1
22	500	a	2009-02	0
1	500	a	local	0
\.


--
-- Data for Name: public_libraryregionandtown; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY public_libraryregionandtown (id, library, town, region, libtype, email) FROM stdin;
1	Bette Winner Public Library	Gillam	NORMAN	Established	bwinner@gillamnet.com
2	Bibliotheque Allard	Traverse Bay	EASTMAN	Satellite	beacheslibrary@hotmail.com
3	Bibliothèque Allard	St Georges	EASTMAN	Established	allardILL@hotmail.com
4	Bibliothèque Montcalm	Saint-Jean-Baptiste	CENTRAL	Established	biblio@atrium.ca
5	Bibliothèque Pere Champagne	Notre Dame de Lourdes	CENTRAL	Established	ndbiblio@yahoo.ca
6	Bibliothèque Publique Tache Public Library	Lorette	EASTMAN	Established	btl@srsd.ca
7	Bibliothèque Ritchot	Ile des Chenes	EASTMAN	Established	ritchotlib@hotmail.com
8	Bibliothèque Ritchot	St. Adolphe	EASTMAN	Satellite	stadbranch@hotmail.com
9	Bibliothèque Ritchot	Ste. Agathe	EASTMAN	Satellite	bibliosteagathe@atrium.ca
10	Bibliothèque Saint-Claude	St. Claude	CENTRAL	Established	stclib@mts.net
11	Bibliothèque Saint-Joachim	La Broquerie	EASTMAN	Established	bsjl@bsjl.ca
12	Bibliothèque Somerset	Somerset	CENTRAL	Established	somlib@mts.net
13	Bibliothèque Ste. Anne	Ste. Anne	EASTMAN	Established	steannelib@steannemb.ca
14	Boissevain and Morton Regional Library	Boissevain	WESTMAN	Established	mbomill@mts.net
15	Border Regional Library	Elkhorn	WESTMAN	Branch	brlelk@yahoo.ca
16	Border Regional Library	Virden	WESTMAN	Established	borderlibraryvirden@rfnow.com
17	Border Regional Library	McAuley	WESTMAN	Branch	library@mcauley-mb.com
18	Boyne Regional Library	Carman	CENTRAL	Established	illbrl@hotmail.com
19	Bren Del Win Centennial Library	Deloriane	WESTMAN	Established	bdwlib@mts.net
20	Bren Del Win Centennial Library	Waskada	WESTMAN	Branch	bdwlib@mts.net
21	Brokenhead River Regional Library	Beausejour	EASTMAN	Established	brrlibr2@mts.net
22	Churchill Public Library	Churchill	NORMAN	Established	mchlibrary@yahoo.ca
23	Emerson Library	Emerson	CENTRAL	Established	emlibrary@hotmail.com
24	Eriksdale Public Library	Eriksdale	INTERLAKE	Established	epl1@mts.net
25	Evergreen Regional Library	Arborg	INTERLAKE	Branch	arborlib@mts.net
26	Evergreen Regional Library	Gimli	INTERLAKE	Established	exec@mts.net
27	Evergreen Regional Library	Riverton	INTERLAKE	Branch	rlibrary@mts.net
28	Flin Flon Public Library	Flin Flon	NORMAN	Established	ffplill@mts.net
29	Glenwood and Souris Regional Library	Souris	WESTMAN	Established	gsrl@mts.net
30	Headingley Municipal Library	Headingly	CENTRAL	Established	hml@mts.net
31	Jake Epp Library	Steinbach	EASTMAN	Established	steinlib@rocketmail.com
32	Jolys Regional Library	St. Pierre	EASTMAN	Established	stplibrary@jrlibrary.mb.ca
33	Jolys Regional Library	St. Malo	EASTMAN	Branch	stmlibrary@jrlibrary.mb.ca
34	Lac Du Bonnet Regional Library	Lac du Bonnet	EASTMAN	Established	mldb@mts.net
35	Lakeland Regional Library	Cartwright	CENTRAL	Branch	cartlib@mts.net
36	Lakeland Regional Library	Killarney	WESTMAN	Established	lrl@mts.net
37	Leaf Rapids Public Library	Leaf Rapids	NORMAN	Established	lrlib@mts.net
38	Lynn Lake Centennial Library	Lynn Lake	NORMAN	Established	curling99@hotmail.com
39	Manitou Regional Library	Manitou	CENTRAL	Established	manitoulibrary@mts.net
40	Minnedosa Regional Library	Minnedosa	WESTMAN	Established	mmr@mts.net
41	North Norfolk-MacGregor Library	MacGregor	CENTRAL	Established	maclib@mts.net
42	North-West Regional Library	Benito	PARKLAND	Branch	benlib@mts.net
43	North-West Regional Library	Swan River	PARKLAND	Established	nwrl@mts.net
44	Parkland Regional Library	Birch River	PARKLAND	Branch	briver@mts.net
45	Parkland Regional Library	Birtle	WESTMAN	Branch	birtlib@mts.net
46	Parkland Regional Library	Bowsman	PARKLAND	Branch	bows18@mts.net
47	Parkland Regional Library	Dauphin	PARKLAND	Branch	DauphinLibrary@parklandlib.mb.ca
48	Parkland Regional Library	Erickson	WESTMAN	Branch	erick11@mts.net
49	Parkland Regional Library	Foxwarren	WESTMAN	Branch	foxlib@mts.net
50	Parkland Regional Library	Gilbert Plains	PARKLAND	Branch	gilbert3@mts.net
51	Parkland Regional Library	Gladstone	CENTRAL	Branch	gladstne@mts.net
52	Parkland Regional Library	Grandview	PARKLAND	Branch	grandvw@mts.net
53	Parkland Regional Library	Hamiota	WESTMAN	Branch	hamlib@mts.net
54	Parkland Regional Library	Langruth	CENTRAL	Branch	langlib@mts.net
55	Parkland Regional Library	McCreary	PARKLAND	Branch	mccrea16@mts.net
56	Parkland Regional Library	Minitonas	PARKLAND	Branch	minitons@mts.net
57	Parkland Regional Library	Ochre River	PARKLAND	Branch	orlibrary@inetlink.ca
58	Parkland Regional Library	Roblin	PARKLAND	Branch	roblinli@mts.net
59	Parkland Regional Library	Shoal Lake	WESTMAN	Branch	sllibrary@mts.net
60	Parkland Regional Library	Siglunes	CENTRAL	Branch	siglun15@mts.net
61	Parkland Regional Library	St. Lazare	WESTMAN	Branch	lazarelib@mts.net
62	Parkland Regional Library	Strathclair	WESTMAN	Branch	stratlibrary@mts.net
63	Parkland Regional Library	Winnipegosis	PARKLAND	Branch	wpgosis@mts.net
64	Pauline Johnson Library	Lundar	INTERLAKE	Established	mlpj@mts.net
65	Peguis Public	Peguis	INTERLAKE	Established	peguislibrary@yahoo.ca
66	Pilot Mound Public Library	Pilot Mound	CENTRAL	Established	pmlibrary@mts.net
67	Pinawa Public Library	Pinawa	EASTMAN	Established	email@pinawapubliclibrary.com
68	Portage La Prairie Regional Library	Portage la Prairie	CENTRAL	Established	portlib@portagelibrary.com
69	Prairie Crocus Regional Library	Rivers	WESTMAN	Established	pcrl@mts.net
70	R.M. of Argyle Public Library	Baldur	WESTMAN	Established	rmargyle@gmail.com
71	Rapid City Regional Library	Rapid City	WESTMAN	Established	rcreglib@mts.net
72	Red River North Regional Library	Selkirk	INTERLAKE	Established	library@ssarl.org
73	Reston District Library	Reston	WESTMAN	Established	restonlb@yahoo.ca
74	Rossburn Regional Library	Rossburn	PARKLAND	Established	rrl@mts.net
75	Russell and District Library	Binscarth	PARKLAND	Branch	binslb@mts.net
76	Russell and District Regional Library	Russell	PARKLAND	Established	ruslib@mts.net
77	Snow Lake Community Library	Snow Lake	NORMAN	Established	dslibrary@hotmail.com
78	South Central Regional Library	Altona	CENTRAL	Branch	scrlilla@mts.net
79	South Central Regional Library	Morden	CENTRAL	Branch	scrlillm@mts.net
80	South Central Regional Library	Winkler	CENTRAL	Branch	scrlillw@mts.net
81	South Interlake Library	Teulon	INTERLAKE	Branch	teulonbranchlibrary@yahoo.com
82	South Interlake Regional Library	Stonewall	INTERLAKE	Established	circ@sirlibrary.com
83	Southwestern Manitoba Regional Library	Melita	WESTMAN	Established	swmblib@mts.net
84	Southwestern Manitoba Regional Library	Napinka	WESTMAN	Branch	smrl1nap@yahoo.ca
85	Southwestern Manitoba Regional Library	Pierson	WESTMAN	Branch	pcilibrary@goinet.ca
86	Springfield Municipal	Oakbank	EASTMAN	Established	
87	Ste. Rose Regional Library	Ste. Rose du Lac	PARKLAND	Established	illstroselibrary@mts.net
88	The Pas Regional Library	The Pas	NORMAN	Established	illthepas@mts.net
89	Thompson Public Library	Thompson	NORMAN	Established	interlibraryloans@thompsonlibrary.com
90	Thompson Public Library	Nelson House	NORMAN	Branch	NCNBranch@Thompsonlibrary.com
91	Valley Regional Library	Morris	CENTRAL	Established	valleylib@mts.net
92	Victoria Municipal Library	Holland	CENTRAL	Established	victlib@goinet.ca
93	Western Manitoba Regional Library	Hartney	WESTMAN	Branch	hartney@wmrl.ca
94	Western Manitoba Regional Library	Glenboro	WESTMAN	Branch	glenboro@wmrl.ca
95	Western Manitoba Regional Library	Neepawa	WESTMAN	Branch	neepawa@wmrl.ca
96	Western Manitoba Regional Library	Carberry	WESTMAN	Branch	carberry@wmrl.ca
97	Western Manitoba Regional Library	Brandon	WESTMAN	Established	bdnill@wmrl.ca
\.


--
-- Data for Name: public_requests; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY public_requests (sessionid, requestid, id, ts, marc, found_at_server, target_id, title, author, isbn) FROM stdin;
\.


--
-- Data for Name: search_pid; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY search_pid (sessionid, pid) FROM stdin;
c4e3d12bc24e2d00cc06bac36d0fe8fc	26513
\.


--
-- Data for Name: status_check; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY status_check (sessionid, target_id, event, msg, ts) FROM stdin;
DAVID	1	99	130 hits.  Records acquired.	2009-09-29 11:22:33.489595
\.


--
-- Data for Name: targets; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY targets (id, name, z3950_connection_string, email_address, available, holdings_tag, holdings_location, holdings_callno, holdings_avail, holdings_collection, holdings_due, ill_received, handles_holdings_improperly, iselectronicresource, iswebresource, isstandardresource, preferredrecordsyntax, requires_credentials) FROM stdin;
2	Parkland Regional Library	207.161.70.145:5666/LSPacZ	DauphinLibrary@parklandlib.mb.ca	1	949	a	c	 	b		1196	0	0	0	1	usmarc	0
3	Red River North Regional Library	24.76.72.252:210/Main	ill@ssarl.org	0	852	a	h	y	 		1173	0	0	0	1	usmarc	0
4	Southwestern Manitoba Regional Library	216.130.92.141:210/Melita_ILS	swmblib@mts.net	0	852	b	h	u	 	z	68	0	0	0	1	usmarc	0
5	Western Manitoba Regional Library	216.36.147.26:210/horizon	bdnill@wmrl.ca	1	090	b	a	 	 		1416	0	0	0	1	usmarc	0
9	Border Regional Library	216.36.186.84:210/L4U_Agent	borderlibraryvirden@rfnow.com	0	949	a	c	 	 		0	0	0	0	1	usmarc	0
10	Thompson Public Library	206.45.111.14:210/ILS	interlibraryloans@thompsonlibrary.com	1	852	 	h	u	b		142	0	0	0	1	usmarc	0
11	Northwest Regional Library - Swan River	206.45.96.178:210/L4U_Agent	nwrl@mts.net	0	949	a	c	 	 		0	0	0	0	1	usmarc	0
12	South Central Regional Library	206.45.116.103:210/ILS	scrlillm@mts.net	1	852	b	h	y	 	z	889	0	0	0	1	usmarc	0
13	The Pas Regional Library	206.45.107.244:210/L4U_Agent	illthepas@mts.net	1	   	 	 	 	 		0	0	0	0	1	usmarc	0
14	Legislative Library	library.gov.mb.ca:211/legislative	legislative_library@gov.mb.ca	1	852	a	h	 	c		84	1	0	0	1	usmarc	0
15	Portage la Prairie Regional Library	24.79.32.253:210/Destiny	portlib@portagelibrary.com	1	852	b	h	y	 		872	0	0	0	1	usmarc	0
16	Jake Epp Library	jakeepp.gotdns.com:210/ils	steinlib@rocketmail.com	0	852	b	h	y	 		1234	0	0	0	1	usmarc	0
18	Lakeland Regional Library	206.45.118.101:210/InsigniaLibrary	lrl@mts.net	0	852	a	h	y	 		905	0	0	0	1	usmarc	0
19	South Interlake Regional Library	206.45.182.133:210/Stonewall_ILS	circ@sirlibrary.com	0	852	b	h	y	 	z	635	0	0	0	1	usmarc	0
20	Northwest Regional Library - Benito	206.45.217.109:210/L4U_Agent	benlib@mts.net	0	949	a	c	 	 		0	0	0	0	0	usmarc	0
21	Jolys Regional Library	66.244.209.14:210/L4U_Agent	stplibrary@jrlibrary.mb.ca	0	949	a	c	 	 		0	0	0	0	1	usmarc	0
22	Pinawa Public Library	206.45.117.102:210/Pinawa_ILS	email@pinawapubliclibrary.com	1	949	b	x	 	a		182	0	0	0	1	usmarc	0
23	Bibliothèque Saint-Claude	207.161.134.96:210/sclils	stclib@mts.net	0	852	b	h	y	 		0	0	0	0	1	usmarc	0
24	Boyne Regional Library	206.45.105.104:210/ILS	illbrl@hotmail.com	1	852	b	h	y	 		176	0	0	0	1	usmarc	0
25	Minnedosa Regional Library	206.45.123.128:210/minnedosa_ils	mmr@mts.net	0	852	a	h	y	b		62	0	0	0	1	usmarc	0
28	Winnipeg Public Library	198.163.53.31:210/horizon	wpl-illo@winnipeg.ca	1	949	b	n	 	m		1189	0	0	0	1	usmarc	0
29	Wikipedia	econtent.indexdata.com:210/wikipedia		1	   	 	 	 	 		0	1	0	1	0	usmarc	0
30	Project Gutenberg	econtent.indexdata.com:210/gutenberg		1	856	u	 	 	 		\N	0	1	0	0	usmarc	0
31	Open Content Alliance - Canadian Libraries	econtent.indexdata.com:210/oca-toronto		1	856	u	 	 	 		\N	0	1	0	0	usmarc	0
32	Open Content Alliance - American Libraries	econtent.indexdata.com:210/oca-americana		1	856	u	 	 	 		\N	1	1	0	0	usmarc	0
33	Open Directory Project	econtent.indexdata.com:210/dmoz		1	856	u	 	 	 		\N	0	0	1	0	usmarc	0
34	Glenwood and Souris Regional Library	206.45.123.156:210/ILS	gsrl@mts.net	0	852	a	h	y	 	z	117	0	0	0	1	usmarc	0
36	Bibliothèque Ste. Anne	72.2.10.68:210/steanne_ils	steannelib@steannemb.ca	0	852	b	h	y	 		3	0	0	0	1	usmarc	0
35	Bette Winner Public Library	bettewinner.commstream.net:210/L4U_Agent	bwinner@gillamnet.com	0	949	a	c	 	 		0	0	0	0	1	usmarc	0
1	PLS Union Catalogue	library.gov.mb.ca:210/maplin	pls@gov.mb.ca	1	949	m	d	s	c	t	4415	1	0	0	1	opac	0
37	Bibliotheque Allard	24.76.92.231:210/biblioall	david.a.christensen@gmail.com	1	852	a	h	y	 		\N	0	0	0	1	usmarc	0
38	Bibliotheque Allard - Beaches	24.76.92.231:210/bibliobeaches	david.a.christensen@gmail.com	1	852	a	h	y	 		\N	0	0	0	1	usmarc	0
39	Brokenhead River	24.76.92.231:210/broken	david.a.christensen@gmail.com	1	852	a	h	y	 		\N	0	0	0	1	usmarc	0
40	Eriksdale Public	24.76.92.231:210/eriksdale	david.a.christensen@gmail.com	1	852	a	h	y	 		\N	0	0	0	1	usmarc	0
41	Headingly Municipal	24.76.92.231:210/headmun	david.a.christensen@gmail.com	1	852	a	h	y	 		\N	0	0	0	1	usmarc	0
42	Reston District	24.76.92.231:210/reston	david.a.christensen@gmail.com	1	852	a	h	y	 		\N	0	0	0	1	usmarc	0
43	Springfield Public	24.76.92.231:210/spring	david.a.christensen@gmail.com	1	852	a	h	y	 		\N	0	0	0	1	usmarc	0
\.


--
-- Data for Name: user_authgroups; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY user_authgroups (uid, gid) FROM stdin;
1	6
129	6
127	6
129	4
131	6
99	3
\.


--
-- Data for Name: user_target; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY user_target (uid, target_id) FROM stdin;
101	1
49	2
79	3
87	4
94	5
21	9
92	10
46	11
81	12
36	21
98	25
68	22
85	19
91	13
69	15
47	20
101	14
39	18
90	16
24	24
16	23
99	28
18	36
33	35
34	34
79	41
\.


--
-- Data for Name: user_zserver_credentials; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY user_zserver_credentials (uid, zid, username, "password") FROM stdin;
101	44	s5521720.main.z3950	ebsco
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY users (uid, name, "password", active, email_address, "admin", library, mailing_address_line1, mailing_address_line2, mailing_address_line3, ill_sent, home_zserver_id, home_zserver_location, last_login) FROM stdin;
1	DTL	DTL123	1	David_A_Christensen@hotmail.com	1	The Great Library of Davidland	123 Some Street South	Brandon, MB  R7A 7A1		11	1	mwpl	2008-12-10 19:53:02
2	test	123	1	David_A_Christensen@hotmail.com	0	A Test Library	456 Someother St.	Mycity, MB  R7A 0X0	\N	0	1	test	\N
13	MIBR	MIBR	1	ritchotlib@hotmail.com	0	Bibliothèque Ritchot - Main	310 Lamoureux Rd.	Box 340	Ile des Chenes, MB  R0A 0T0	95	1	MIBR	2009-01-07 02:09:26
12	MNDP	MNDP	1	ndbiblio@yahoo.ca	0	Bibliothèque Pere Champagne	44 Rue Rogers	Box 399	Notre Dame de Lourdes, MB  R0G 1M0	89	1	MNDP	2009-01-06 22:56:13
11	MSJB	MSJB	1	biblio@atrium.ca	0	Bibliothèque Montcalm	113B 2nd	Box 345	Saint-Jean-Baptiste, MB  R0G 2B0	54	1	MSJB	2009-01-07 01:28:45
10	MSTG	MSTG	1	allardill@hotmail.com	0	Bibliothèque Allard	14 Baie Caron S.	Box 157	St Georges, MB  R0E 1V0	135	1	MSTG	2009-01-06 20:07:00
9	MNHA	MNHA	1	tansi23@hotmail.com	0	Ayamiscikewikamik		Box 250	Norway House, MB  ROB 1BO	0	1	MNHA	\N
14	MSAD	MSAD	1	stadbranch@hotmail.com	0	Bibliothèque Ritchot - St. Adolphe	444 rue La Seine		St. Adolphe, MB  R5A 1C2	0	1	MSAD	\N
15	MSAG	MSAG	1	bibliosteagathe@atrium.ca	0	Bibliothèque Ritchot - Ste. Agathe	310 Chemin Pembina Trail	Box 40	Sainte-Agathe, MB  ROG 1YO	13	1	MSAG	2008-12-12 15:32:50
16	MSCL	MSCL	1	stclib@mts.net	0	Bibliothèque Saint-Claude	50 1st Street	Box 203	St. Claude, MB  R0G 1Z0	6	1	MSCL	2008-12-19 01:19:13
17	MLB	MLB	1	bsjl@bsjl.ca	0	Bibliothèque Saint-Joachim Library	29, baie Normandeau Bay	Box 39	La Broquerie, MB  R0A 0W0	133	1	MLB	2009-01-06 20:14:12
18	MSA	MSA	1	steannelib@steannemb.ca	0	Bibliothèque Ste. Anne	16 rue de l'Eglise		Ste. Anne, MB  R5H 1H8	144	36	MSA	2009-01-06 22:55:36
19	MS	lucy	1	somlib@mts.net	0	Bibliothèque Somerset Library	Box 279	289 Carlton Avenue 	Somerset, MB  R0G 2L0	100	1	MS	2009-01-06 23:13:14
20	MBOM	MBOM	1	mbomill@mts.net	0	Boissevain and Morton Regional Library	436 South Railway St.	Box 340	Boissevain, MB  R0K 0E0	326	1	MBOM	2009-01-06 22:51:59
21	MVE	MVE	1	borderlibraryvirden@rfnow.com	0	Border Regional Library - Main	312 - 7th  Avenue	Box 970	Virden, MB  R0M 2C0	470	9	MVE	2009-01-06 22:37:39
22	ME	brlelk	1	elkhornbrl@rfnow.com	0	Border Regional Library - Elkhorn	211 Richhill Ave.	Box 370	Elkhorn, MB  R0M 0N0	71	9	ME	2008-12-30 22:19:21
23	MMCA	MMCA	1	library@mcauley-mb.com	0	Border Regional Library - McAuley	207 Qu'Appelle Street	Box 234	McAuley, MB  R0M 1H0	12	9	MMCA	2008-12-09 22:15:28
24	MCB	MCB	1	illbrl@hotmail.com	0	Boyne Regional Library	15 - 1st Avenue SW	Box 788	Carman, MB  R0G 0J0	266	1	MCB	2009-01-06 17:09:05
25	MDB	bdwcl	1	bdwlib@mts.net	0	Bren Del Win Centennial Library	211 North Railway W.	Box 584	Deloraine, MB  R0M 0M0	95	1	MDB	2009-01-06 22:48:44
26	MBBR	MBBR	1	brrlibr2@mts.net	0	Brokenhead River Regional Library	427 Park  Ave.	Box 1087	Beausejour, MB  R0E 0C0	316	1	MBBR	2009-01-06 21:11:50
27	MEL	MEL	1	epl1@mts.net	0	Eriksdale Public Library	PTH 68  (9 Main St.)	Box 219	Eriksdale, MB  R0C 0W0	201	1	MEL	2009-01-02 23:10:24
28	MCH	MCH	1	mchlibrary@yahoo.ca	0	Churchill Public Library	180 Laverendrye	Box 730	Churchill, MB  R0B 0E0	46	1	MCH	2009-01-07 01:25:53
29	MGE	MGE	1	exec@mts.net	0	Evergreen Regional Library - Main	65 First Avenue	Box 1140	Gimli, MB  R0C 1B0	108	1	MGE	2009-01-06 17:07:59
30	MAB	TIME	1	arborlib@mts.net	0	Evergreen Regional Library - Arborg	292 Main Street	Box 4053	Arborg, MB  R0C 0A0	407	1	MAB	2009-01-06 21:17:38
31	MRB	MRB	1	rlibrary@mts.net	0	Evergreen Regional Library - Riverton	56 Laura Ave.	Box 310	Riverton, MB  R0C 2R0	146	1	MRB	2009-01-06 18:32:57
32	MFF	SHOELACE	1	ffplill@mts.net	0	Flin Flon Public Library	58 Main Street		Flin Flon, MB  R8A 1J8	261	1	MFF	2009-01-06 21:43:43
33	MGI	MGI11	1	bwinner@gillamnet.com	0	Bette Winner Public Library	235 Mattonnabee Ave.	Box 400	Gillam, MB  R0B 0L0	29	1	MGI	2008-12-11 21:37:43
34	MSOG	MSOG	1	gsrl@mts.net	0	Glenwood & Souris Regional Library	18 - 114 2nd St. S.	Box 760	Souris, MB  R0K 2C0	227	1	MSOG	2009-01-06 22:51:48
35	MHH	MHH	1	hml@mts.net	0	Headingley Municipal Library	81 Alboro Street		Headingley, MB  R4J 1A3	210	1	MHH	2009-01-06 01:10:43
36	MSTP	MSTP	1	stplibrary@jrlibrary.mb.ca	0	Jolys Regional Library - Main	505 Hebert Ave. N.	Box 118	St. Pierre-Jolys, MB  R0A 1V0	541	21	MSTP	2009-01-06 21:29:56
37	MSSM	MSSM	1	stmlibrary@jrlibrary.mb.ca	0	Jolys Regional Library - St. Malo	189 St. Malo Street	Box 593	St.Malo, MB  R0A 1T0	29	1	MSSM	2009-01-06 23:13:59
38	MLDB	MLDB	1	mldb@mts.net	0	Lac Du Bonnet Regional Library	84-3rd Street	Box 216	Lac Du Bonnet, MB  R0E 1A0	372	1	MLDB	2009-01-06 18:24:10
39	MKL	MKL	1	lrl@mts.net	0	Lakeland Regional Library - Main	318 Williams Ave.	Box 970	Killarney, MB  R0K 1G0	548	18	Lakeland Regional Library	2009-01-06 22:12:22
40	MCCB	CC111	1	cartlib@mts.net	0	Lakeland Regional Library - Cartwright	483 Veteran Drive	Box 235	Cartwright, MB  R0K 0L0	133	18	Cartwright Library	2009-01-06 20:55:05
41	MPM	MPM	1	pmlibrary@mts.net	0	Pilot Mound Public Library - Pilot Mound	219 Broadway Ave. W.	Box 126	Pilot Mound, MB  R0G 1P0	30	1	MPM	2009-01-06 18:56:03
42	MLR	MLR	1	lrlib@mts.net	0	Leaf Rapids Public Library	20 Town Centre	Box 190	Leaf Rapids, MB  R0B 1W0	2	1	MLR	2008-12-18 20:28:05
43	MLLC	MLLC	1	lynnlib@mts.net	0	Lynn Lake Centennial Library	503 Sherritt Ave.	Box 1127	Lynn Lake, MB  R0B 0W0	0	1	MLLC	\N
44	MMA	MMA	1	manitoulibrary@mts.net	0	Manitou Public Library	418 Main St.	Box 432	Manitou, MB  R0G 1G0	171	1	MMA	2009-01-06 19:12:51
45	MMNN	MMNN	1	maclib@mts.net	0	North Norfolk-MacGregor Library	35 Hampton St. E.	Box 760	MacGregor, MB  R0H 0R0	349	1	MMNN	2009-01-02 23:12:48
46	MSRN	MSRN	1	nwrl@mts.net	0	North-West Regional Library - Main	610-1st  St. North	Box 999	Swan River, MB  R0L 1Z0	357	11		2009-01-06 18:47:53
47	MBB	MBB	1	benlib@mts.net	0	North-West Regional Library - Benito Branch	140 Main Street	Box 220	Benito, MB  R0L 0C0	201	1	MBB	2008-12-19 22:38:33
48	MLPJ	MLPJ	1	mlpj@mts.net	0	Pauline Johnson Library	23 Main Street	Box 698	Lundar, MB  R0C 1Y0	65	1	MLPJ	2008-12-09 19:56:42
49	MDP	MDP	1	prlhq@parklandlib.mb.ca	0	Parkland Regional Library - Main	504 Main St. N.		Dauphin, MB  R7N 1C9	6	2		2009-01-06 21:46:57
50	MDPBR	MDPBR	1	briver@mts.net	0	Parkland Regional Library - Birch River	116 3rd St. East	Box 245	Birch River, MB  R0L 0E0	0	2		2008-12-18 20:36:09
51	MDPBI	MDPBI	1	birtlib@mts.net	0	Parkland Regional Library - Birtle	907 Main Street	Box 207	Birtle, MB  R0M 0C0	67	2		2009-01-06 21:58:44
52	MDPBO	MDPBO	1	bows18@mts.net	0	Parkland Regional Library - Bowsman	105 2nd St.	Box 209	Bowsman, MB  R0L 0H0	1	2		2008-12-18 20:59:41
53	MDA	MDA	1	DauphinLibrary@parklandlib.mb.ca	0	Parkland Regional Library - Dauphin	504 Main Street North		Dauphin, MB  R7N 1C9	453	2		2009-01-06 23:24:20
54	MDPER	MDPER	1	erick11@mts.net	0	Parkland Regional Library - Erickson	20 Main St. W	Box 385	Erickson, MB  R0J 0P0	32	2		2009-01-06 21:18:39
55	MDPFO	MDPFO	1	foxlib@mts.net	0	Parkland Regional Library - Foxwarren	312 Webster Ave.	Box 204	Foxwarren, MB  R0J 0P0	20	2		2009-01-06 20:47:46
56	MDPGP	MDPGP	1	gilbert3@mts.net	0	Parkland Regional Library - Gilbert Plains	113 Main St. N.	Box 303	Gilbert Plains, MB  R0L 0X0	26	2		2009-01-03 20:52:47
57	MDPGL	MDPGL	1	gladstne@mts.net	0	Parkland Regional Library - Gladstone	42 Morris Avenue N.	Box 720	Gladstone, MB  R0J 0T0	227	2		2009-01-03 15:55:59
58	MDPGV	MDPGV	1	grandvw@mts.net	0	Parkland Regional Library - Grandview	433 Main St.	Box Box 700	Grandview, MB  R0L 0Y0	104	2		2009-01-03 20:36:45
59	MDPHA	MDPHA	1	hamlib@mts.net	0	Parkland Regional Library - Hamiota	43 Maple Ave. E.	Box 609	Hamiota, MB  R0M 0T0	49	2		2009-01-06 19:39:56
60	MDPLA	MDPLA	1	langlib@mts.net	0	Parkland Regional Library - Langruth	402 Main St.	Box 154	Langruth, MB  R0H 0N0	0	2		2008-12-19 22:53:12
61	MDPMC	MDPMC	1	mccrea16@mts.net	0	Parkland Regional Library - McCreary	615 Burrows Rd.	Box 297	McCreary, MB  R0J 1B0	16	2		2008-12-19 22:54:43
62	MDPMI	MDPMI	1	minitons@mts.net	0	Parkland Regional Library - Minitonas	300 Main St.	Box 496	Minitonas, MB  R0L 1G0	106	2		2009-01-06 21:08:47
63	MDPOR	MDPOR	1	orlibrary@inetlink.ca	0	Parkland Regional Library - Ochre River	203 Main St.	Box 219	Ochre River, MB  R0L 1K0	53	2		2009-01-02 20:34:52
64	MDPRO	MDPRO	1	roblinli@mts.net	0	Parkland Regional Library - Roblin	123 lst Ave. N.	Box 1342	Roblin, MB  R0L 1P0	77	2		2009-01-06 22:23:08
65	MDPSL	MDPSL	1	sllibrary@mts.net	0	Parkland Regional Library - Shoal Lake	418 Station Road S.	Box 428	Shoal Lake, MB  R0J 1Z0	78	2		2008-12-22 15:59:46
66	MDPSI	MDPSI	1	siglun15@mts.net	0	Parkland Regional Library - Siglunes	5 - 61 Main St.	Box 368	Ashern, MB  R0C 0E0	9	2		2009-01-05 22:15:02
67	MDPWP	MDPWP	1	wpgosis@mts.net	0	Parkland Regional Library - Winnipegosis	130 2nd St.	Box Box 10	Winnipegosis, MB  R0L 2G0	28	2		2009-01-02 21:12:16
68	MP	EDNA	1	email@pinawapubliclibrary.com	0	Pinawa Public Library	Vanier Road	General Delivery	Pinawa, MB  R0E 1L0	191	22		2009-05-29 16:31:52
69	MPLP	MPLP	1	portlib@portagelibrary.com	0	Portage La Prairie Regional Library	40-B Royal Road N		Portage La Prairie, MB  R1N 1V1	354	15		2009-01-03 20:13:02
71	MRIP	MRIP	1	pcrl@mts.net	0	Prairie Crocus Regional Library	137 Main Street	Box 609	Rivers, MB  R0K 1X0	185	1	MRIP	2009-01-03 16:44:41
72	MRA	MRA	1	rcreglib@mts.net	0	Rapid City Regional Library	425 3rd Ave.	Box 8	Rapid City, MB  R0K 1W0	32	1	MRA	2009-01-06 22:26:34
73	MRP	MRP	1	restonlb@yahoo.ca	0	Reston District Library	220 - 4th St.	Box 340	Reston, MB  R0M 1X0	197	1	MRP	2009-01-06 20:40:53
74	MRO	MRO	1	rrl@mts.net	0	Rossburn Regional Library	53 Main St. North	Box 87	Rossburn, MB  R0J 1V0	19	1	MRO	2008-12-23 15:42:43
75	MBA	MBA	1	rmargyle@gmail.com	0	R.M. of Argyle Public Library	627 Elizabeth Ave. E.	Box 10	Baldur, MB  R0K 0B0	8	1	MBA	2008-12-11 01:25:12
76	MRD	MRD	1	ruslib@mts.net	0	Russell & District Regional Library - Main	339 Main St.	Box 340	Russell, MB  R0J 1W0	316	1	MRD	2009-01-06 20:55:49
77	MBI	MBI	1	binslb@mts.net	0	Russell & District Library - Binscarth	106 Russell St.	Box  379	Binscarth, MB  R0J 0G0	0	1	MBI	2008-11-13 17:52:20
78	MSTR	MSTR	1	sroselib@mts.net	0	Ste. Rose Regional Library	580 Central Avenue	General Delivery	Ste. Rose du Lac, MB  R0L 1S0	191	1	MSTR	2009-01-06 21:05:38
79	MSEL	MSEL	1	ill@ssarl.org	0	Red River North Regional Library	303 Main Street		Selkirk, MB  R1A 1S7	703	3	MSEL	2009-01-02 17:36:44
80	MSL	MSL	1	dslibrary@hotmail.com	0	Snow Lake Community Library	101 Cherry St.	Box 760	Snow Lake, MB  R0B 1M0	55	1	MSL	2009-01-06 21:44:02
81	MWOWH	MWOWH	1	scrlheadlib@mts.net	0	South Central Regional Library - Office	160 Main Street   (325-5864)	Box 1540	Winkler, MB  R6W 4B4	0	12	MWOWH	2008-12-11 18:57:50
82	MAOW	maow	1	scrlilla@mts.net	0	South Central Regional Library - Altona	113-125 Centre Ave. E. (324-1503)	Box 650	Altona, MB  R0G 0B0	289	12	Altona	2009-01-06 17:21:53
83	MMOW	MMOW	1	scrlillm@mts.net	0	South Central Regional Library - Morden	514 Stephen Street	Morden, MB  R6M 1T7	204-822-4092	564	12	Morden	2009-01-06 22:33:49
84	MWOW	MWOW	1	scrlillw@mts.net	0	South Central Regional Library - Winkler	160 Main Street (325-7174)	Box 1540	Winkler, MB  R6W 4B4	327	12	Winkler	2009-01-05 20:44:43
85	MSTOS	mstos	1	circ@sirlibrary.com	0	South Interlake Regional Library - Main	419 Main St.		Stonewall, MB  R0C 2Z0	366	19	Stonewall	2009-01-06 17:26:39
86	MTSIR	MTSIR	1	teulonbranchlibrary@yahoo.com	0	South Interlake Regional Library - Teulon	19 Beach Road	Box 68	Teulon, MB  R0C 3B0	238	19	Teulon	2009-01-06 21:20:29
87	MESM	MESM	1	swmblib@mts.net	0	Southwestern Manitoba Regional Library - Main	149 Main St. S.	Box 639	Melita, MB  R0M 1L0	373	4	Main	2009-01-03 22:25:11
88	MESMN	MESMN	1	smrl1nap@yahoo.ca	0	Southwestern Manitoba Regional Library - Napinka	57 Souris St.	Box 975	Melita, MB  R0M 1L0	0	4	MESM	\N
89	MESP	MESP	1	pcilibrary@goinet.ca	0	Southwestern Manitoba Regional Library - Pierson	58 Railway Avenue	Box 39	Pierson, MB  R0M 1S0	35	4	MESP	2008-12-29 16:15:20
90	MSTE	MSTE	1	steinlib@rocketmail.com	0	Jake Epp Library	255 Elmdale Street		Steinbach, MB  R5G 0C9	352	16	Jake Epp	2009-01-06 22:18:42
91	MTP	MTP	1	illthepas@mts.net	0	The Pas Regional Library	53 Edwards Avenue	Box 4100	The Pas, MB  R9A 1R2	192	1	MTP	2009-01-06 18:41:50
92	MTH	MTH	1	interlibraryloans@thompsonlibrary.com	0	Thompson Public Library	81 Thompson Drive North		Thompson, MB  R8N 0C3	180	10		2009-01-06 15:05:52
93	MMVR	MMVR	1	valleylib@mts.net	0	Valley Regional Library	141Main Street South	Box 397	Morris, MB  R0G 1K0	202	1	MMVR	2009-01-06 22:30:12
94	MBW	rescue	1	bdnill@wmrlibrary.mb.ca	0	Western Manitoba Regional Library - Brandon	710 Rosser Avenue, Unit 1		Brandon, MB  R7A 0K9	276	5	mbw	2009-01-03 17:24:02
95	MCNC	discover	1	carberry@wmrlibrary.mb.ca	0	Western Manitoba Regional Library - Carberry/North Cypress	115 Main Street	Box 382	Carberry, MB  R0K 0H0	157	5	mcnc	2009-01-06 20:36:24
96	MGW	MGW	1	jackie@wmrl.ca	0	Western Manitoba Regional  Library - Glenboro/South Cypress	105 Broadway St.	Box 429	Glenboro, MB  R0K 0X0	127	5	mgw	2009-01-06 21:29:56
97	MNW	MNW	1	neepawa@wmrlibrary.mb.ca	0	Western Manitoba Regional  Library - Neepawa	280 Davidson St.	Box 759	Neepawa, MB  R0J 1H0	96	5	mnw	2009-01-03 20:24:22
98	MMR	MMR	1	mmr@mts.net	0	Minnedosa Regional Library	45 1st  Ave. SE	Box 1226	Minnedosa, MB  R0J 1E0	189	25	Minnedosa	2009-01-07 01:14:07
99	MW	MW	1	wpl-illo@winnipeg.ca	0	Winnipeg Public Library : Interlibrary Loans	251 Donald St.		Winnipeg, MB  R3C 3P5	14	28		2008-12-31 19:30:36
100	MWP	MWP	1	legislative_library@gov.mb.ca	0	Manitoba Legislative Library	200 Vaughn		Winnipeg, MB  R3C 1T5	0	1	MWP	\N
102	MHP	MHP	1	victlib@goinet.ca	0	Victoria Municipal Library	102 Stewart Ave	Box 371	Holland, MB  R0G 0X0	63	1	MHP	2009-01-06 20:47:25
103	MEPL	MEPL	1	emlibrary@hotmail.com	0	Emerson Library	104 Church Street	Box 340	Emerson, MB  R0A 0L0	30	1	MEPL	2009-01-04 20:44:48
104	MBAC	MBAC	1	library@assiniboinec.mb.ca	0	Assiniboine Community College	1430 Victoria Avenue East		Brandon, MB  R7A 2A9	0	1	MBAC	\N
105	MWRR	MWRR	0	lgirardi@rrcc.mb.ca	0	Red River College	2055 Notre Dame Ave		Winnipeg, MB  R3H 0J9	0	1	MWRR	\N
106	MWTS	MWTS	0	lisanne.wood@mts.mb.ca	0	Manitoba Telecom Services Corporate	489 Empress St.	Box 6666	Winnipeg, MB  R3C 3V6	0	1	MWTS	\N
107	MDPST	MDPST	1	stratlibrary@mts.net	0	Parkland Regional Library - Strathclair	50 Main St.	Box 303	Strathclair, MB  R0J 2C0	2	2		2009-01-05 19:23:31
108	MSERC	MSERC	0	serc2mb@mb.sympatico.ca	0	Brandon SERC	731B Princess Ave		Brandon, MB  R7A 0P4	0	1	MSERC	\N
109	MWMRC	MWMRC	0	bdearth@itc.mb.ca	0	Industrial Technology Centre	200-78 Innovation Drive		Winnipeg, MB  R3T 6C2	0	1	MWMRC	\N
110	MBBB	MBBB	1	beacheslibrary@hotmail.com	0	Bibliotheque Allard - Beaches	40005 Jackfish Lake Rd. N. Walter Whyte School	Box 255	Traverse Bay, MB  R0E 2A0	52	1	MBBB	2008-12-30 15:03:48
111	MSSC	MSSC	1	shilocommunitylibrary@yahoo.ca	0	Shilo Community Library		Box Box 177	Shilo, MB  R0K 2A0	8	1	MSSC	2008-12-16 00:19:31
112	ASGY	ASGY	0	lfrolek@yrl.ab.ca	0	Yellowhead Regional		Box 400	Spruce Grove, AB, MB  T7X 2Y1	0	1	ASGY	\N
113	MWSC	MWSC	1	library@smd.mb.ca	0	Society for Manitobans with Disabilities - Stephen Sparling	825 Sherbrooks Street		Winnipeg, MB  R3A 1M5	0	1	MWSC	\N
114	MWEMM	MWEMM	0	LJanower@gov.mb.ca	0	Manitoba Industry Trade and Mines - Mineral Resource	Suite 360 - 1395 Ellice Ave.		Winnipeg, MB  R3G 3P2	0	1	MWEMM	\N
115	OKE	OKE	0	eroussin@kenora.ca	0	Kenora Public Library	24 Main St. South		Kenora, Ontario, MB  P9N 1S7	0	1	OKE	\N
116	CPL	CPL	0		0	Crocus Plains Regional Secondary School	1930 First Street		Brandon, MB  R7A 6Y6	0	1	CPL	\N
117	MWHBCA	MWHBCA	0	hbca@gov.mb.ca	0	Hudsons Bay Company Archives	200 Vaughan St.		Winnipeg, MB  R3C 1T5	0	1	MWHBCA	\N
118	MWJ	MWJ	0	jodi.turner@justice.gc.ca	0	Department of Justice	301-310 Broadway Avenue		Winnipeg, MB  R3C 0S6	0	1	MWJ	\N
119	MTPL	MTPL	1	btl@srsd.ca	0	Bibliothèque Publique Tache Public Library - Main		Box 16	Lorette, MB  R0A 0Y0	242	1	MTPL	2009-01-07 02:42:08
120	MHW	MHW	1	hartney@wmrlibrary.mb.ca	0	Western Manitoba Regional - Hartney Cameron Branch	209 Airdrie St.	Box 121	Hartney, MB  R0M 0X0	93	5	mhw	2009-01-06 18:41:53
121	TWAS	TWAS	1		0	Bren Del Win Centennial Library - Waskada	30 Souris Ave.		Waskada, MB  R0M 2E0	0	1	TWAS	\N
122	MPFN	MPFN	1	peguislibrary@yahoo.ca	0	Peguis Community	Lot 30 Peguis Indian Reserve	Box Box 190	Peguis, MB  R0J 3J0	0	1	MPFN	\N
124	MDPSLA	MDPSLA	1	lazarelib@mts.net	0	Parkland Regional Library - St. Lazare		Box 201	St. Lazare, MB  R0M 1Y0	19	2		2008-12-22 15:55:01
125	MNCN	MNCN	1	NCNBranch@Thompsonlibrary.com	0	Thompson Public Library - Nelson House	1 ATEC Drive	Box 454	Nelson House, MB  R0B 1A0	0	10	MNCN	\N
127	Caitlyn	Caitlyn	0		1	PLS - clerk				0	1		\N
128	Margo	me	1		1	PLS - staff				\N	1		2008-09-15 15:49:51
130	UNC	UNC321	1		0	Delete me!				\N	0		2008-07-28 15:22:43
131	UCN	UCN321	1		1	University Colleges North pilot project				\N	0		2008-10-29 15:35:00
101	MWPL	MWPL	1	pls@gov.mb.ca	0	Public Library Services	1525 1st St. South		Brandon, MB  R7A 7A1	6	1	MWPL	2009-07-03 15:41:50.450235
129	admin	maplin3db	1	David.A.Christensen@gmail.com	1	Maplin-3 Administrator				\N	0		2009-09-29 10:10:12.282103
\.


--
-- Data for Name: vendor; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY vendor (name, "password", active) FROM stdin;
L4U	L4U	1
\.


--
-- Name: authgroups_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY authgroups
    ADD CONSTRAINT authgroups_pkey PRIMARY KEY (gid);


--
-- Name: public_libraryregionandtown_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY public_libraryregionandtown
    ADD CONSTRAINT public_libraryregionandtown_pkey PRIMARY KEY (id);


--
-- Name: targets_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY targets
    ADD CONSTRAINT targets_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: mapapp; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (uid);


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

