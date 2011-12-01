--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

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
-- Name: request_seq; Type: SEQUENCE SET; Schema: public; Owner: mapapp
--

SELECT pg_catalog.setval('request_seq', 60, true);


SET default_tablespace = '';

SET default_with_oids = false;

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
    filled_by integer
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
-- Data for Name: request; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY request (id, title, author, requester, patron_barcode, current_target) FROM stdin;
1	10 little rubber ducks	Carle, Eric	85	21111000001234	1
2	The valley of the frost giants	Shura, Mary Francis	85	21111000001235	1
4	Buddha for beginners	Asma, Stephen T	85	21111000001234	1
5	The Delta solution	Robinson, Patrick	85	21111000001235	1
8	Railroad war	Bowers, Terrell L	85	21111000001234	1
9	Wheels to rockets ;	Wilkinson, Philip, 1955-	85	21111000001235	1
10	Tangerine	Griffith,Marilynn	85	21111000001234	1
11	Celtic Britain	Thomas, Charles	85	21111000001235	1
12	Tofu 1-2-3	Abrams, Maribeth	85	21111000001236	1
14	Cathedrals and abbeys of England and Wales	Morris, Richard	85	26757000001237	1
15	Techniques for wildlife habitat management of wetlands	Payne, Neil F	85	21111000001237	1
16	The Fender Stratocaster handbook	Balmer, Paul	85	21111000001237	1
17	The Les Paul guitar book	Bacon, Tony	85	21111000001237	1
19	The dance of time	Flint, Eric	85	21111000001235	1
21	Sea turtles	Laskey, Elizabeth	99	22222000004401	1
22	Exploring Mars	Gallant, Roy A	99	22222000004402	1
23	The Gorgon's head;	Hodges, Margaret	99	22222000004403	1
26	Mushrooms, ferns and mosses	Jenser, Amy Elizabeth	99	22222000004403	1
27	Journey to the Orange Islands	West, Tracey	99	22222000004403	1
29	The biography of coffee	Morganelli, Adrianna	99	22222000004401	1
31	The man who discovered flight	Dee, Richard	99	22222000004404	1
33	Zeppelin	Donkin, Andrew	99	22222000004401	1
34	Red star rogue	Sewell, Kenneth	99	22222000004402	1
36	Mrs. Astor regrets	Gordon, Meryl	99	22222000004403	1
37	Start with a digital camera	Odam, John	99	22222000004404	1
39	The Reserve	Banks, Russell	99	22222000004402	1
40	Tickly octopus	Galloway, Ruth	99	22222000004401	1
41	Parrots	Juniper, Tony	101	23333000003301	1
42	Freshwater dolphins	Prevost, John F	101	23333000003301	1
43	Sea turtles	Gibbons, Gail	101	23333000003301	1
44	Cobra	\N	101	\N	0
45	Cobra	Stokvis, Willemijn	101	23333000003301	1
46	Baby porcupine	Lang, Aubrey	101	23333000003302	1
47	Platypus, probably	Collard, Sneed B	101	23333000003302	1
49	Tyrannosaurus rex	Landau, Elaine	101	23333000003302	1
51	Making your own paper	Saddington, Marianne	101	23333000003303	1
52	The carpenter's companion	Chinn, Garry	101	23333000003303	1
53	Lumberjack	Kurelek, William	101	23333000003303	1
56	Moral disorder	Atwood, Margaret Eleanor	101	23333000003304	1
58	To the top of Everest	Skreslet, Laurie	101	23333000003304	1
59	Manitoba's Metis settlement scheme of 1870	Chartrand, Paul L.A.H	101	23333000003304	1
35	Jamaica	Wilson, Amber	99	22222000004403	0
\.


--
-- Data for Name: request_closed; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY request_closed (id, title, author, requester, patron_barcode, filled_by) FROM stdin;
50	Bully for brontosaurus	Gould, Stephen Jay	101	23333000003302	1
48	Can I bring my pterodactyl to school, Ms. Johnson?	Grambling, Lois G	101	23333000003302	1
20	Trout farming in Manitoba	Hayden, Worth	85	21111000001236	1
18	The portable Kipling	Kipling, Rudyard	85	21111000001237	1
13	Hemingway	Lynn, Kenneth Schuyler	85	26757000001237	1
55	Forest explorer	Bishop, Nic	101	23333000003303	1
60	Steamboats on the Assiniboine	Brown, Roy	101	23333000003304	1
54	Precious gold, precious jade	Heisel, Sharon E	101	23333000003303	1
57	Yellowstone National Park	Kalman, Bobbie	101	23333000003304	1
38	The Facebook effect	Kirkpatrick, David	99	22222000004401	1
32	Eat my dust!	Kulling, Monica	99	22222000004404	1
3	The case for Mars	Zubrin, Robert	85	21111000001236	1
6	Old soldiers	Weber, David	85	21111000001235	1
28	29 gifts	Walker, Cami	99	22222000004401	1
30	Wild coffee and tea substitutes of Canada	Turner, Nancy J	99	22222000004401	1
25	Cacti and succulents	Perl, Philip	99	22222000004402	1
24	Plug-in Javascript 100 power solutions	Nixon, Robin	99	22222000004401	1
7	Ducks of the world	Kear, Janet	85	21111000001236	1
\.


--
-- Data for Name: requests_active; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY requests_active (request_id, ts, msg_from, msg_to, status, message) FROM stdin;
1	2011-12-01 11:40:41.833036	85	101	ILL-Request	\N
2	2011-12-01 11:41:28.481447	85	101	ILL-Request	\N
4	2011-12-01 11:42:25.929609	85	101	ILL-Request	\N
5	2011-12-01 11:42:58.223664	85	101	ILL-Request	\N
8	2011-12-01 11:45:34.276478	85	101	ILL-Request	\N
9	2011-12-01 11:46:16.29178	85	101	ILL-Request	\N
10	2011-12-01 11:46:45.554215	85	101	ILL-Request	\N
11	2011-12-01 11:48:09.68614	85	99	ILL-Request	\N
12	2011-12-01 11:48:47.262299	85	99	ILL-Request	\N
14	2011-12-01 11:52:45.66424	85	99	ILL-Request	\N
15	2011-12-01 11:53:28.734328	85	99	ILL-Request	\N
16	2011-12-01 11:54:23.764686	85	99	ILL-Request	\N
17	2011-12-01 11:54:58.544461	85	99	ILL-Request	\N
19	2011-12-01 11:56:28.18205	85	99	ILL-Request	\N
21	2011-12-01 11:58:52.176338	99	101	ILL-Request	\N
22	2011-12-01 11:59:28.74376	99	101	ILL-Request	\N
23	2011-12-01 12:00:24.676481	99	101	ILL-Request	\N
26	2011-12-01 12:50:03.953651	99	101	ILL-Request	\N
27	2011-12-01 12:50:38.933576	99	101	ILL-Request	\N
29	2011-12-01 12:51:52.715898	99	101	ILL-Request	\N
31	2011-12-01 12:52:57.331774	99	85	ILL-Request	\N
33	2011-12-01 12:54:06.588235	99	85	ILL-Request	\N
34	2011-12-01 12:54:53.56491	99	85	ILL-Request	\N
36	2011-12-01 12:56:43.626838	99	85	ILL-Request	\N
37	2011-12-01 12:57:16.608101	99	85	ILL-Request	\N
39	2011-12-01 12:58:20.351881	99	85	ILL-Request	\N
40	2011-12-01 12:58:52.601822	99	85	ILL-Request	\N
41	2011-12-01 13:02:21.443233	101	99	ILL-Request	\N
42	2011-12-01 13:02:51.91277	101	99	ILL-Request	\N
43	2011-12-01 13:03:24.609883	101	99	ILL-Request	\N
45	2011-12-01 13:04:20.206775	101	99	ILL-Request	\N
46	2011-12-01 13:04:53.644692	101	99	ILL-Request	\N
47	2011-12-01 13:05:18.773139	101	99	ILL-Request	\N
49	2011-12-01 13:06:25.605641	101	99	ILL-Request	\N
51	2011-12-01 13:07:36.714005	101	85	ILL-Request	\N
52	2011-12-01 13:08:12.023583	101	85	ILL-Request	\N
53	2011-12-01 13:08:42.660648	101	85	ILL-Request	\N
56	2011-12-01 13:11:46.28655	101	85	ILL-Request	\N
58	2011-12-01 13:13:01.867566	101	85	ILL-Request	\N
59	2011-12-01 13:13:43.773911	101	85	ILL-Request	\N
56	2011-12-01 13:42:32.528448	85	101	ILL-Answer|Unfilled|in-use-on-loan	
39	2011-12-01 13:42:55.617003	85	99	ILL-Answer|Unfilled|non-circulating	
59	2011-12-01 13:43:11.139644	85	101	ILL-Answer|Will-Supply|being-processed-for-supply	
59	2011-12-01 13:43:11.393242	85	101	Shipped	due 2011-12-31
52	2011-12-01 13:43:13.083079	85	101	ILL-Answer|Will-Supply|being-processed-for-supply	
52	2011-12-01 13:43:13.374673	85	101	Shipped	due 2011-12-31
31	2011-12-01 13:43:14.338448	85	99	ILL-Answer|Will-Supply|being-processed-for-supply	
31	2011-12-01 13:43:14.612112	85	99	Shipped	due 2011-12-31
33	2011-12-01 13:43:15.454815	85	99	ILL-Answer|Will-Supply|being-processed-for-supply	
33	2011-12-01 13:43:15.741466	85	99	Shipped	due 2011-12-31
40	2011-12-01 13:43:16.60599	85	99	ILL-Answer|Will-Supply|being-processed-for-supply	
40	2011-12-01 13:43:16.864456	85	99	Shipped	due 2011-12-31
36	2011-12-01 13:43:18.37727	85	99	ILL-Answer|Will-Supply|being-processed-for-supply	
36	2011-12-01 13:43:18.664149	85	99	Shipped	due 2011-12-31
53	2011-12-01 13:43:26.069194	85	101	ILL-Answer|Will-Supply|being-processed-for-supply	
53	2011-12-01 13:43:26.325121	85	101	Shipped	due 2011-12-31
12	2011-12-01 13:44:10.439792	99	85	ILL-Answer|Unfilled|on-hold	
42	2011-12-01 13:44:18.77936	99	101	ILL-Answer|Unfilled|policy-problem	
17	2011-12-01 13:44:25.461651	99	85	ILL-Answer|Will-Supply|being-processed-for-supply	
17	2011-12-01 13:44:25.749546	99	85	Shipped	due 2011-12-31
16	2011-12-01 13:44:26.78015	99	85	ILL-Answer|Will-Supply|being-processed-for-supply	
16	2011-12-01 13:44:27.061041	99	85	Shipped	due 2011-12-31
19	2011-12-01 13:44:28.619133	99	85	ILL-Answer|Will-Supply|being-processed-for-supply	
19	2011-12-01 13:44:28.905303	99	85	Shipped	due 2011-12-31
43	2011-12-01 13:44:29.775756	99	101	ILL-Answer|Will-Supply|being-processed-for-supply	
43	2011-12-01 13:44:30.02976	99	101	Shipped	due 2011-12-31
49	2011-12-01 13:44:36.694484	99	101	ILL-Answer|Will-Supply|being-processed-for-supply	
49	2011-12-01 13:44:36.976611	99	101	Shipped	due 2011-12-31
46	2011-12-01 13:44:38.155579	99	101	ILL-Answer|Will-Supply|being-processed-for-supply	
46	2011-12-01 13:44:38.424988	99	101	Shipped	due 2011-12-31
45	2011-12-01 13:44:45.674494	99	101	ILL-Answer|Will-Supply|being-processed-for-supply	
45	2011-12-01 13:44:45.969753	99	101	Shipped	due 2011-12-31
14	2011-12-01 13:44:56.53728	99	85	ILL-Answer|Will-Supply|being-processed-for-supply	
14	2011-12-01 13:44:56.836307	99	85	Shipped	due 2011-12-31
9	2011-12-01 13:45:40.222041	101	85	ILL-Answer|Unfilled|poor-condition	
21	2011-12-01 13:46:51.388028	101	99	ILL-Answer|Unfilled|on-reserve	
5	2011-12-01 13:47:03.630398	101	85	ILL-Answer|Will-Supply|being-processed-for-supply	
5	2011-12-01 13:47:03.919276	101	85	Shipped	due 2011-12-31
26	2011-12-01 13:47:05.013518	101	99	ILL-Answer|Will-Supply|being-processed-for-supply	
26	2011-12-01 13:47:05.304152	101	99	Shipped	due 2011-12-31
10	2011-12-01 13:47:07.753147	101	85	ILL-Answer|Will-Supply|being-processed-for-supply	
10	2011-12-01 13:47:07.998242	101	85	Shipped	due 2011-12-31
8	2011-12-01 13:47:09.411036	101	85	ILL-Answer|Will-Supply|being-processed-for-supply	
8	2011-12-01 13:47:09.699498	101	85	Shipped	due 2011-12-31
22	2011-12-01 13:47:10.767707	101	99	ILL-Answer|Will-Supply|being-processed-for-supply	
22	2011-12-01 13:47:11.040823	101	99	Shipped	due 2011-12-31
29	2011-12-01 13:47:14.825134	101	99	ILL-Answer|Will-Supply|being-processed-for-supply	
29	2011-12-01 13:47:15.14187	101	99	Shipped	due 2011-12-31
23	2011-12-01 13:47:16.178374	101	99	ILL-Answer|Will-Supply|being-processed-for-supply	
23	2011-12-01 13:47:16.470587	101	99	Shipped	due 2011-12-31
43	2011-12-01 13:50:16.425016	101	99	Received	
49	2011-12-01 13:50:31.639749	101	99	Received	
53	2011-12-01 13:50:33.477075	101	85	Received	
45	2011-12-01 13:50:38.034397	101	99	Received	
52	2011-12-01 13:50:52.881747	101	85	Received	
43	2011-12-01 13:51:39.755194	101	99	Returned	
52	2011-12-01 13:51:41.099278	101	85	Returned	
17	2011-12-01 13:52:17.96164	85	99	Received	
16	2011-12-01 13:52:19.100244	85	99	Received	
8	2011-12-01 13:52:20.346682	85	101	Received	
19	2011-12-01 13:52:21.910834	85	99	Received	
10	2011-12-01 13:52:34.208379	85	101	Received	
17	2011-12-01 13:52:40.204609	85	99	Returned	
10	2011-12-01 13:52:43.412474	85	101	Returned	
31	2011-12-01 13:53:15.61855	99	85	Received	
33	2011-12-01 13:53:16.9384	99	85	Received	
36	2011-12-01 13:53:19.240959	99	85	Received	
23	2011-12-01 13:53:20.585419	99	101	Received	
26	2011-12-01 13:53:22.521843	99	101	Received	
29	2011-12-01 13:53:26.480282	99	101	Received	
31	2011-12-01 13:53:38.986913	99	85	Returned	
26	2011-12-01 13:53:45.357854	99	101	Returned	
29	2011-12-01 13:53:51.23339	99	101	Returned	
\.


--
-- Data for Name: requests_history; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY requests_history (request_id, ts, msg_from, msg_to, status, message) FROM stdin;
50	2011-12-01 13:06:51.68909	101	99	ILL-Request	\N
50	2011-12-01 13:44:42.210098	99	101	ILL-Answer|Will-Supply|being-processed-for-supply	
50	2011-12-01 13:44:42.457582	99	101	Shipped	due 2011-12-31
50	2011-12-01 13:50:18.293436	101	99	Received	
50	2011-12-01 13:51:36.997397	101	99	Returned	
50	2011-12-01 13:54:18.221168	99	101	Checked-in	
48	2011-12-01 13:05:52.539371	101	99	ILL-Request	\N
48	2011-12-01 13:44:31.756314	99	101	ILL-Answer|Will-Supply|being-processed-for-supply	
48	2011-12-01 13:44:32.041575	99	101	Shipped	due 2011-12-31
48	2011-12-01 13:50:45.645413	101	99	Received	
48	2011-12-01 13:51:35.166621	101	99	Returned	
48	2011-12-01 13:54:19.407934	99	101	Checked-in	
20	2011-12-01 11:57:04.082509	85	99	ILL-Request	\N
20	2011-12-01 13:44:32.973545	99	85	ILL-Answer|Will-Supply|being-processed-for-supply	
20	2011-12-01 13:44:33.27922	99	85	Shipped	due 2011-12-31
20	2011-12-01 13:52:33.077646	85	99	Received	
20	2011-12-01 13:52:45.751089	85	99	Returned	
20	2011-12-01 13:54:20.994751	99	85	Checked-in	
18	2011-12-01 11:55:46.154428	85	99	ILL-Request	\N
18	2011-12-01 13:44:35.468897	99	85	ILL-Answer|Will-Supply|being-processed-for-supply	
18	2011-12-01 13:44:35.721297	99	85	Shipped	due 2011-12-31
18	2011-12-01 13:52:30.323038	85	99	Received	
18	2011-12-01 13:52:49.795646	85	99	Returned	
18	2011-12-01 13:54:22.109615	99	85	Checked-in	
13	2011-12-01 11:49:36.399758	85	99	ILL-Request	\N
13	2011-12-01 13:44:39.372504	99	85	ILL-Answer|Will-Supply|being-processed-for-supply	
13	2011-12-01 13:44:39.642526	99	85	Shipped	due 2011-12-31
13	2011-12-01 13:52:28.387866	85	99	Received	
13	2011-12-01 13:52:50.986461	85	99	Returned	
13	2011-12-01 13:54:23.407023	99	85	Checked-in	
55	2011-12-01 13:10:23.028675	101	85	ILL-Request	\N
55	2011-12-01 13:43:08.638611	85	101	ILL-Answer|Will-Supply|being-processed-for-supply	
55	2011-12-01 13:43:08.930506	85	101	Shipped	due 2011-12-31
55	2011-12-01 13:50:12.798292	101	85	Received	
55	2011-12-01 13:51:44.490742	101	85	Returned	
55	2011-12-01 13:54:41.72261	85	101	Checked-in	
60	2011-12-01 13:14:24.606174	101	85	ILL-Request	\N
60	2011-12-01 13:43:10.0376	85	101	ILL-Answer|Will-Supply|being-processed-for-supply	
60	2011-12-01 13:43:10.318827	85	101	Shipped	due 2011-12-31
60	2011-12-01 13:50:14.310954	101	85	Received	
60	2011-12-01 13:51:43.058246	101	85	Returned	
60	2011-12-01 13:54:43.918728	85	101	Checked-in	
54	2011-12-01 13:09:40.43235	101	85	ILL-Request	\N
54	2011-12-01 13:43:20.054805	85	101	ILL-Answer|Will-Supply|being-processed-for-supply	
54	2011-12-01 13:43:20.353999	85	101	Shipped	due 2011-12-31
54	2011-12-01 13:50:25.736326	101	85	Received	
54	2011-12-01 13:51:33.814147	101	85	Returned	
54	2011-12-01 13:54:46.532692	85	101	Checked-in	
57	2011-12-01 13:12:19.940591	101	85	ILL-Request	\N
57	2011-12-01 13:43:21.622018	85	101	ILL-Answer|Will-Supply|being-processed-for-supply	
57	2011-12-01 13:43:21.898975	85	101	Shipped	due 2011-12-31
57	2011-12-01 13:50:27.27244	101	85	Received	
57	2011-12-01 13:51:31.797763	101	85	Returned	
57	2011-12-01 13:54:47.852359	85	101	Checked-in	
38	2011-12-01 12:57:53.416111	99	85	ILL-Request	\N
38	2011-12-01 13:43:23.093866	85	99	ILL-Answer|Will-Supply|being-processed-for-supply	
38	2011-12-01 13:43:23.376746	85	99	Shipped	due 2011-12-31
38	2011-12-01 13:53:23.996146	99	85	Received	
38	2011-12-01 13:53:48.994709	99	85	Returned	
38	2011-12-01 13:54:49.386089	85	99	Checked-in	
32	2011-12-01 12:53:34.549905	99	85	ILL-Request	\N
32	2011-12-01 13:43:24.626193	85	99	ILL-Answer|Will-Supply|being-processed-for-supply	
32	2011-12-01 13:43:24.91015	85	99	Shipped	due 2011-12-31
32	2011-12-01 13:53:25.242508	99	85	Received	
32	2011-12-01 13:53:50.166649	99	85	Returned	
32	2011-12-01 13:54:50.484843	85	99	Checked-in	
3	2011-12-01 11:41:51.734935	85	101	ILL-Request	\N
3	2011-12-01 13:46:55.472608	101	85	ILL-Answer|Will-Supply|being-processed-for-supply	
3	2011-12-01 13:46:55.750069	101	85	Shipped	due 2011-12-31
3	2011-12-01 13:52:26.069784	85	101	Received	
3	2011-12-01 13:52:53.326583	85	101	Returned	
3	2011-12-01 13:55:19.881818	101	85	Checked-in	
6	2011-12-01 11:43:58.341165	85	101	ILL-Request	\N
6	2011-12-01 13:46:57.62036	101	85	ILL-Answer|Will-Supply|being-processed-for-supply	
6	2011-12-01 13:46:57.900446	101	85	Shipped	due 2011-12-31
6	2011-12-01 13:52:24.442814	85	101	Received	
6	2011-12-01 13:52:52.126041	85	101	Returned	
6	2011-12-01 13:55:21.360933	101	85	Checked-in	
28	2011-12-01 12:51:21.036512	99	101	ILL-Request	\N
28	2011-12-01 13:47:11.874799	101	99	ILL-Answer|Will-Supply|being-processed-for-supply	
28	2011-12-01 13:47:12.139211	101	99	Shipped	due 2011-12-31
28	2011-12-01 13:53:33.064454	99	101	Received	
28	2011-12-01 13:53:56.167288	99	101	Returned	
28	2011-12-01 13:55:23.361975	101	99	Checked-in	
30	2011-12-01 12:52:12.59128	99	101	ILL-Request	\N
30	2011-12-01 13:46:59.808281	101	99	ILL-Answer|Will-Supply|being-processed-for-supply	
30	2011-12-01 13:47:00.097836	101	99	Shipped	due 2011-12-31
30	2011-12-01 13:53:30.606111	99	101	Received	
30	2011-12-01 13:53:54.466329	99	101	Returned	
30	2011-12-01 13:55:24.659506	101	99	Checked-in	
25	2011-12-01 12:49:35.729622	99	101	ILL-Request	\N
25	2011-12-01 13:47:01.506478	101	99	ILL-Answer|Will-Supply|being-processed-for-supply	
25	2011-12-01 13:47:01.762791	101	99	Shipped	due 2011-12-31
25	2011-12-01 13:53:29.296659	99	101	Received	
25	2011-12-01 13:53:53.434487	99	101	Returned	
25	2011-12-01 13:55:27.173962	101	99	Checked-in	
24	2011-12-01 12:48:53.892043	99	101	ILL-Request	\N
24	2011-12-01 13:47:13.346411	101	99	ILL-Answer|Will-Supply|being-processed-for-supply	
24	2011-12-01 13:47:13.638523	101	99	Shipped	due 2011-12-31
24	2011-12-01 13:53:27.69718	99	101	Received	
24	2011-12-01 13:53:52.373913	99	101	Returned	
24	2011-12-01 13:55:29.349693	101	99	Checked-in	
7	2011-12-01 11:44:36.047408	85	101	ILL-Request	\N
7	2011-12-01 13:47:06.557827	101	85	ILL-Answer|Will-Supply|being-processed-for-supply	
7	2011-12-01 13:47:06.846919	101	85	Shipped	due 2011-12-31
7	2011-12-01 13:52:31.752161	85	101	Received	
7	2011-12-01 13:52:47.436254	85	101	Returned	
7	2011-12-01 13:55:31.484495	101	85	Checked-in	
\.


--
-- Data for Name: sources; Type: TABLE DATA; Schema: public; Owner: mapapp
--

COPY sources (request_id, sequence_number, library, call_number) FROM stdin;
1	1	101	fake-call-number
2	1	101	fake-call-number
4	1	101	fake-call-number
5	1	101	fake-call-number
8	1	101	fake-call-number
9	1	101	fake-call-number
10	1	101	fake-call-number
11	1	99	fake-call-number
12	1	99	fake-call-number
14	1	99	fake-call-number
15	1	99	fake-call-number
16	1	99	fake-call-number
17	1	99	fake-call-number
19	1	99	fake-call-number
21	1	101	fake-call-number
22	1	101	fake-call-number
23	1	101	fake-call-number
26	1	101	fake-call-number
27	1	101	fake-call-number
29	1	101	fake-call-number
31	1	85	fake-call-number
33	1	85	fake-call-number
34	1	85	fake-call-number
35	1	85	fake-call-number
36	1	85	fake-call-number
37	1	85	fake-call-number
39	1	85	fake-call-number
40	1	85	fake-call-number
41	1	99	fake-call-number
42	1	99	fake-call-number
43	1	99	fake-call-number
44	1	99	fake-call-number
45	1	99	fake-call-number
46	1	99	fake-call-number
47	1	99	fake-call-number
49	1	99	fake-call-number
51	1	85	fake-call-number
52	1	85	fake-call-number
53	1	85	fake-call-number
56	1	85	fake-call-number
58	1	85	fake-call-number
59	1	85	fake-call-number
\.


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
-- PostgreSQL database dump complete
--

