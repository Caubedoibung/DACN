--
-- PostgreSQL database dump
--

\restrict p7pwFIzBBReIQA4UJ7hHq2n0nCo2rvy7tH8iFTfoNnVppNXx3EVjpi5CUWUHYeu

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2025-12-06 11:52:45

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6501 (class 0 OID 21089)
-- Dependencies: 220
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."User" (user_id, full_name, email, password_hash, age, gender, height_cm, weight_kg, created_at, last_login, activity_level, diet_type, allergies, health_goals, goal_type, goal_weight, activity_factor, bmr, tdee, daily_calorie_target, daily_protein_target, daily_fat_target, daily_carb_target, daily_water_target, is_deleted, updated_at, avatar_url) FROM stdin;
2	Trương Ngọc Linh	truongngoclinh312@gmail.com	$2a$10$Mm8RcVfF96bAodhPMMUcd.hIRrprvll0j9U06i4Baa8WOKmpmnTWG	19	female	160.00	42.00	2025-11-23 20:43:25.828394	2025-11-26 16:58:30.11047-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	2025-11-23 20:43:25.828394	\N
3	vmc	vmc@gmail.com	$2a$10$Mmxw2G1Xag49ov9HS/9DYeOb2NbW0eYxaWeeEJzJ0zmJ2Ocp02RPO	20	female	180.00	60.00	2025-11-24 05:23:47.634179	2025-12-04 22:20:01.350451-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	2025-11-24 05:23:47.634179	\N
4	k2	truonghoankiet3@gmail.com	$2a$10$3pjNpQsfJ1SpUFc4hDwhaOUEFkazI2ijpfIbCzo6z505AKSIPqQUa	21	female	180.00	60.00	2025-11-27 04:52:23.478157	2025-12-04 23:31:50.410714-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	2025-11-27 04:52:23.478157	\N
1	k1	truonghoankiet1@gmail.com	$2a$10$OApO5T.eU7fki/0ThPJ.KuxDWUREhS3.b3mGK/SsPlYMZSkkdmEbe	20	male	174.00	60.00	2025-11-19 07:19:15.359239	2025-12-05 20:48:33.90019-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	2025-11-19 18:29:56.553496	/uploads/avatars/avatar_1764053523370_1764053523446.jpeg
\.


--
-- TOC entry 6507 (class 0 OID 21160)
-- Dependencies: 226
-- Data for Name: admin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin (admin_id, username, password_hash, created_at, is_deleted) FROM stdin;
1	truonghoankiet@gmail.com	$2a$10$2yLz3oLecSssabunEcrT2.ANxWm9.J60PE1ZRwHwahW/yZv.zATjC	2025-11-19 07:18:40.627012	f
2	truonghoankiet3@gmail.com	$2a$10$4od/qVm8f6a83e3WbnSzZuVjixoLweNbRpTU5SCLZg.PfUeG9IYUu	2025-11-19 16:30:17.863746	f
\.


--
-- TOC entry 6637 (class 0 OID 22921)
-- Dependencies: 366
-- Data for Name: admin_verification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_verification (verification_id, username, password_hash, code, expires_at, created_at) FROM stdin;
\.


--
-- TOC entry 6584 (class 0 OID 22096)
-- Dependencies: 305
-- Data for Name: adminconversation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adminconversation (admin_conversation_id, user_id, status, subject, created_at, updated_at) FROM stdin;
1	1	active	Hỗ trợ khách hàng	2025-11-19 19:11:13.623869	2025-11-20 20:28:21.873639
2	2	active	Hỗ trợ khách hàng	2025-11-23 20:44:25.160152	2025-11-23 20:44:25.160152
4	4	active	Hỗ trợ khách hàng	2025-11-27 04:52:32.95183	2025-11-27 04:52:32.95183
3	3	active	Hỗ trợ khách hàng	2025-11-24 05:24:56.365371	2025-12-03 23:25:35.94197
\.


--
-- TOC entry 6586 (class 0 OID 22117)
-- Dependencies: 307
-- Data for Name: adminmessage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adminmessage (admin_message_id, admin_conversation_id, sender_type, sender_id, message_text, image_url, is_read, created_at) FROM stdin;
5	1	admin	1	Chào bạn	\N	t	2025-11-20 19:02:03.663145
6	1	admin	1	Bạn đang gặp vấn đề gì cần mình hỗ trợ không ?	\N	t	2025-11-20 20:28:21.864931
9	3	admin	1	Ban can giup gi khong ?	\N	t	2025-12-03 23:25:35.934003
1	1	user	1	Xin chào	\N	t	2025-11-19 19:11:17.739636
2	1	user	1	123	\N	t	2025-11-19 22:55:01.273442
3	1	user	1	dfsaf	\N	t	2025-11-19 22:55:09.327581
4	1	user	1	fa	\N	t	2025-11-19 23:34:13.138275
7	1	user	1	không có gì	\N	t	2025-11-23 20:40:38.741655
8	3	user	3	11232	\N	t	2025-12-03 21:08:22.958648
\.


--
-- TOC entry 6510 (class 0 OID 21185)
-- Dependencies: 229
-- Data for Name: adminrole; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adminrole (admin_id, role_id) FROM stdin;
1	1
\.


--
-- TOC entry 6559 (class 0 OID 21786)
-- Dependencies: 278
-- Data for Name: aminoacid; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.aminoacid (amino_acid_id, code, name, hex_color, home_display, created_at) FROM stdin;
1	ILE	Isoleucine	#A8E6A3	t	2025-11-20 19:11:02.837067-08
2	PHE	Phenylalanine	#F4A7B9	f	2025-11-20 19:11:02.837067-08
3	HIS	Histidine	#B58ED9	f	2025-11-20 19:11:02.837067-08
4	LYS	Lysine	#4CC9F0	t	2025-11-20 19:11:02.837067-08
5	THR	Threonine	#76D7C4	f	2025-11-20 19:11:02.837067-08
6	VAL	Valine	#FFB570	t	2025-11-20 19:11:02.837067-08
7	TRP	Tryptophan	#6A5ACD	t	2025-11-20 19:11:02.837067-08
8	MET	Methionine	#F6D55C	t	2025-11-20 19:11:02.837067-08
9	LEU	Leucine	#E76F51	t	2025-11-20 19:11:02.837067-08
\.


--
-- TOC entry 6561 (class 0 OID 21802)
-- Dependencies: 280
-- Data for Name: aminorequirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.aminorequirement (amino_requirement_id, amino_acid_id, sex, age_min, age_max, per_kg, amount, unit, notes) FROM stdin;
10	3	\N	0	0	t	28	mg	WHO/FAO requirement for infants 0-6 months
11	3	\N	1	1	t	20	mg	WHO/FAO requirement for infants 7-12 months
12	3	\N	1	3	t	16	mg	WHO/FAO requirement for children 1-3 years
13	3	\N	4	8	t	15	mg	WHO/FAO requirement for children 4-8 years
14	3	\N	19	120	t	14	mg	WHO/FAO adult requirement 14 mg/kg/day
15	1	\N	0	0	t	46	mg	WHO/FAO requirement for infants 0-6 months
16	1	\N	1	1	t	43	mg	WHO/FAO requirement for infants 7-12 months
17	1	\N	1	3	t	28	mg	WHO/FAO requirement for children 1-3 years
18	1	\N	4	8	t	22	mg	WHO/FAO requirement for children 4-8 years
19	1	\N	19	120	t	19	mg	WHO/FAO adult requirement 19 mg/kg/day
20	9	\N	0	0	t	93	mg	WHO/FAO requirement for infants 0-6 months
21	9	\N	1	1	t	89	mg	WHO/FAO requirement for infants 7-12 months
22	9	\N	1	3	t	63	mg	WHO/FAO requirement for children 1-3 years
23	9	\N	4	8	t	49	mg	WHO/FAO requirement for children 4-8 years
24	9	\N	19	120	t	42	mg	WHO/FAO adult requirement 42 mg/kg/day
25	4	\N	0	0	t	66	mg	WHO/FAO requirement for infants 0-6 months
26	4	\N	1	1	t	64	mg	WHO/FAO requirement for infants 7-12 months
27	4	\N	1	3	t	58	mg	WHO/FAO requirement for children 1-3 years
28	4	\N	4	8	t	45	mg	WHO/FAO requirement for children 4-8 years
29	4	\N	19	120	t	30	mg	WHO/FAO adult requirement 30 mg/kg/day
30	8	\N	0	0	t	33	mg	WHO/FAO requirement for infants 0-6 months (Met + Cys)
31	8	\N	1	1	t	30	mg	WHO/FAO requirement for infants 7-12 months (Met + Cys)
32	8	\N	1	3	t	27	mg	WHO/FAO requirement for children 1-3 years (Met + Cys)
33	8	\N	4	8	t	21	mg	WHO/FAO requirement for children 4-8 years (Met + Cys)
34	8	\N	19	120	t	15	mg	WHO/FAO adult requirement 15 mg/kg/day (Met + Cys)
35	2	\N	0	0	t	52	mg	WHO/FAO requirement for infants 0-6 months (Phe + Tyr)
36	2	\N	1	1	t	46	mg	WHO/FAO requirement for infants 7-12 months (Phe + Tyr)
37	2	\N	1	3	t	41	mg	WHO/FAO requirement for children 1-3 years (Phe + Tyr)
38	2	\N	4	8	t	31	mg	WHO/FAO requirement for children 4-8 years (Phe + Tyr)
39	2	\N	19	120	t	25	mg	WHO/FAO adult requirement 25 mg/kg/day (Phe + Tyr)
40	5	\N	0	0	t	43	mg	WHO/FAO requirement for infants 0-6 months
41	5	\N	1	1	t	35	mg	WHO/FAO requirement for infants 7-12 months
42	5	\N	1	3	t	34	mg	WHO/FAO requirement for children 1-3 years
43	5	\N	4	8	t	28	mg	WHO/FAO requirement for children 4-8 years
44	5	\N	19	120	t	15	mg	WHO/FAO adult requirement 15 mg/kg/day
45	7	\N	0	0	t	12.5	mg	WHO/FAO requirement for infants 0-6 months
46	7	\N	1	1	t	11	mg	WHO/FAO requirement for infants 7-12 months
47	7	\N	1	3	t	8.5	mg	WHO/FAO requirement for children 1-3 years
48	7	\N	4	8	t	6.6	mg	WHO/FAO requirement for children 4-8 years
49	7	\N	19	120	t	4	mg	WHO/FAO adult requirement 4 mg/kg/day
50	6	\N	0	0	t	55	mg	WHO/FAO requirement for infants 0-6 months
51	6	\N	1	1	t	49	mg	WHO/FAO requirement for infants 7-12 months
52	6	\N	1	3	t	37	mg	WHO/FAO requirement for children 1-3 years
53	6	\N	4	8	t	29	mg	WHO/FAO requirement for children 4-8 years
54	6	\N	19	120	t	26	mg	WHO/FAO adult requirement 26 mg/kg/day
\.


--
-- TOC entry 6578 (class 0 OID 22030)
-- Dependencies: 299
-- Data for Name: bodymeasurement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bodymeasurement (measurement_id, user_id, measurement_date, weight_kg, height_cm, bmi, bmi_score, bmi_category, source, notes, created_at) FROM stdin;
1	1	2025-11-19 07:19:57.574968	60.00	174.00	19.82	9	normal	profile_update	Auto-created from profile update	2025-11-19 07:19:57.574968
2	2	2025-11-23 20:44:04.627771	42.00	160.00	16.41	3	underweight	profile_update	Auto-created from profile update	2025-11-23 20:44:04.627771
3	3	2025-11-24 05:24:39.709436	60.00	180.00	18.52	9	normal	profile_update	Auto-created from profile update	2025-11-24 05:24:39.709436
4	1	2025-11-24 22:52:03.733412	60.00	174.00	19.82	9	normal	profile_update	Auto-created from profile update	2025-11-24 22:52:03.733412
5	1	2025-11-24 22:52:15.989212	60.00	174.00	19.82	9	normal	profile_update	Auto-created from profile update	2025-11-24 22:52:15.989212
6	3	2025-11-29 01:32:36.375268	60.00	180.00	18.52	9	normal	profile_update	Auto-created from profile update	2025-11-29 01:32:36.375268
7	4	2025-12-04 06:34:12.518714	60.00	180.00	18.52	9	normal	profile_update	Auto-created from profile update	2025-12-04 06:34:12.518714
\.


--
-- TOC entry 6580 (class 0 OID 22056)
-- Dependencies: 301
-- Data for Name: chatbotconversation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chatbotconversation (conversation_id, user_id, title, created_at, updated_at) FROM stdin;
1	1	New conversation	2025-11-19 19:11:13.476368	2025-11-19 19:11:13.476368
2	2	New conversation	2025-11-23 20:44:25.100477	2025-11-23 20:44:25.100477
3	3	New conversation	2025-11-24 05:24:56.282746	2025-11-24 05:24:56.282746
4	4	New conversation	2025-11-27 04:52:32.83719	2025-11-27 04:52:32.83719
\.


--
-- TOC entry 6582 (class 0 OID 22075)
-- Dependencies: 303
-- Data for Name: chatbotmessage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chatbotmessage (message_id, conversation_id, sender, message_text, image_url, nutrition_data, is_approved, created_at) FROM stdin;
1	1	user	Phân tích dinh dưỡng ảnh này	/uploads/chat/food-1763624237138.jpg	\N	\N	2025-11-19 23:37:17.141989
3	1	user	Phân tích dinh dưỡng ảnh này	/uploads/chat/food-1763642795572.jpg	\N	\N	2025-11-20 04:46:35.57444
2	1	bot	Tôi đã phân tích món: Phở Bò. Vui lòng xác nhận kết quả dinh dưỡng bên dưới.	\N	{"food_name": "Phở Bò", "nutrients": [{"unit": "mg", "amount": 0.1, "nutrient_code": "VITB1", "nutrient_name": "Vitamin B1 (Thiamine)"}, {"unit": "mg", "amount": 3, "nutrient_code": "VITB3", "nutrient_name": "Vitamin B3 (Niacin)"}, {"unit": "mg", "amount": 0.3, "nutrient_code": "VITB6", "nutrient_name": "Vitamin B6 (Pyridoxine)"}, {"unit": "µg", "amount": 0.8, "nutrient_code": "VITB12", "nutrient_name": "Vitamin B12 (Cobalamin)"}, {"unit": "mg", "amount": 2.5, "nutrient_code": "MIN_FE", "nutrient_name": "Iron (Fe)"}, {"unit": "mg", "amount": 250, "nutrient_code": "MIN_K", "nutrient_name": "Potassium (K)"}, {"unit": "mg", "amount": 800, "nutrient_code": "MIN_NA", "nutrient_name": "Sodium (Na)"}, {"unit": "mg", "amount": 2, "nutrient_code": "MIN_ZN", "nutrient_name": "Zinc (Zn)"}, {"unit": "mg", "amount": 150, "nutrient_code": "MIN_P", "nutrient_name": "Phosphorus (P)"}], "confidence": 0.95}	t	2025-11-19 23:37:21.135124
5	1	user	Xin chào bạn, bạn có thể tự giới thiệu với bạn được không ?	\N	\N	\N	2025-11-20 20:13:54.218295
6	1	bot	Chào bạn! Tôi là trợ lý AI về dinh dưỡng của ứng dụng My Diary. Tôi có thể giúp bạn: Tư vấn dinh dưỡng dựa trên tình trạng sức khỏe, Gợi ý thực phẩm/món ăn phù hợp, Giải thích giá trị dinh dưỡng và lợi ích sức khỏe, Hướng dẫn chế độ ăn cho từng bệnh cụ thể, Trả lời câu hỏi về thực phẩm Việt Nam, Phân tích thành phần dinh dưỡng của món ăn, Hãy cho tôi biết bạn cần gì nhé!.	\N	\N	\N	2025-11-20 20:14:03.700355
4	1	bot	Tôi đã phân tích món: Phở Bò. Vui lòng xác nhận kết quả dinh dưỡng bên dưới.	\N	{"food_name": "Phở Bò", "nutrients": [{"unit": "kcal", "amount": 250, "nutrient_code": "ENERC_KCAL", "nutrient_name": "Calories"}, {"unit": "g", "amount": 20, "nutrient_code": "PROCNT", "nutrient_name": "Protein"}, {"unit": "g", "amount": 8, "nutrient_code": "FAT", "nutrient_name": "Total Fat"}, {"unit": "g", "amount": 25, "nutrient_code": "CHOCDF", "nutrient_name": "Total Carbohydrate"}, {"unit": "g", "amount": 1, "nutrient_code": "FIBTG", "nutrient_name": "Total Fiber"}, {"unit": "mg", "amount": 700, "nutrient_code": "MIN_NA", "nutrient_name": "Sodium"}, {"unit": "mg", "amount": 2, "nutrient_code": "MIN_FE", "nutrient_name": "Iron"}, {"unit": "µg", "amount": 1, "nutrient_code": "VITB12", "nutrient_name": "Vitamin B12"}, {"unit": "g", "amount": 0.05, "nutrient_code": "ALA", "nutrient_name": "Alpha-linolenic Acid (Omega-3)"}], "confidence": 0.95}	t	2025-11-20 04:46:40.792613
7	3	user	Xin chao	\N	\N	\N	2025-12-03 22:26:42.331841
8	3	bot	Chào bạn! Bạn có câu hỏi nào về dinh dưỡng, sức khỏe hay chế độ ăn uống mà tôi có thể giúp đỡ không?	\N	\N	\N	2025-12-03 22:26:46.267902
\.


--
-- TOC entry 6668 (class 0 OID 24508)
-- Dependencies: 398
-- Data for Name: communitymessage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.communitymessage (message_id, user_id, message_text, image_url, created_at, updated_at, is_deleted, deleted_at) FROM stdin;
1	1	Chào mọi người	\N	2025-11-23 20:40:08.810223	2025-11-23 20:40:08.810223	f	\N
2	2	Chào bạn	\N	2025-11-23 22:04:53.788448	2025-11-23 22:04:53.788448	f	\N
3	1	\N	/uploads/community/community_1763990202528_1763990202705.png	2025-11-24 05:16:42.743018	2025-11-24 05:16:42.743018	f	\N
4	1	trái này là trái gì thế	\N	2025-11-24 05:16:57.80768	2025-11-24 05:16:57.80768	f	\N
5	1	mình không biết trái này là trái gì	\N	2025-11-24 05:18:55.640006	2025-11-24 05:18:55.640006	f	\N
6	3	\N	/uploads/community/community_1763990858300_1763990858309.jpeg	2025-11-24 05:27:38.359857	2025-11-24 05:27:38.359857	f	\N
7	1	oh ai đồ vờ mờ cờ	\N	2025-11-24 06:27:10.019203	2025-11-24 06:27:10.019203	f	\N
8	3	chào các em trẻ trâu	\N	2025-11-24 06:28:13.633195	2025-11-24 06:28:13.633195	f	\N
9	1	\N	/uploads/community/community_1764205016031_1764205016443.png	2025-11-26 16:56:56.493098	2025-11-26 16:56:56.493098	f	\N
10	1	ok	\N	2025-11-27 20:39:18.294409	2025-11-27 20:39:18.294409	f	\N
\.


--
-- TOC entry 6686 (class 0 OID 29236)
-- Dependencies: 417
-- Data for Name: conditiondishrecommendation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conditiondishrecommendation (recommendation_id, condition_id, dish_id, recommendation_type, reason, created_at) FROM stdin;
1	1	64	recommend	Phở bò: Protein cao, ít đường	2025-12-05 05:52:33.810188
2	1	71	recommend	Bún bò Huế: Protein tốt, kiểm soát portion	2025-12-05 05:52:33.818956
3	1	75	recommend	Gỏi cuốn: Ít calo, nhiều rau	2025-12-05 05:52:33.819867
4	1	77	recommend	Rau muống xào tỏi: Ít tinh bột, nhiều chất xơ	2025-12-05 05:52:33.820464
5	1	93	recommend	Cá hấp: Protein không dầu mỡ	2025-12-05 05:52:33.821073
6	1	100	avoid	Xôi: Chỉ số đường huyết cao	2025-12-05 05:52:33.82204
7	1	109	avoid	Chè đậu xanh: Nhiều đường	2025-12-05 05:52:33.822917
8	1	110	avoid	Bánh flan: Nhiều đường, carbs cao	2025-12-05 05:52:33.823477
9	2	75	recommend	Gỏi cuốn: Ít muối, nhiều rau tươi	2025-12-05 05:52:33.824168
10	2	77	recommend	Rau muống xào tỏi: Kali cao, ít natri	2025-12-05 05:52:33.824733
11	2	93	recommend	Cá hấp: Không muối nhiều	2025-12-05 05:52:33.825168
12	2	94	recommend	Gà hấp: Protein không muối	2025-12-05 05:52:33.825624
13	2	76	avoid	Canh chua cá: Muối và nước mắm cao	2025-12-05 05:52:33.826129
14	2	78	avoid	Cá kho tộ: Nước mắm và muối cao	2025-12-05 05:52:33.82654
15	2	114	avoid	Thịt kho tàu: Nước mắm và natri cao	2025-12-05 05:52:33.826905
16	3	75	recommend	Gỏi cuốn: Ít dầu mỡ	2025-12-05 05:52:33.827293
17	3	77	recommend	Rau muống xào tỏi: Ít cholesterol	2025-12-05 05:52:33.827664
18	3	93	recommend	Cá hấp: Omega-3 tốt cho tim mạch	2025-12-05 05:52:33.828108
19	3	94	recommend	Gà hấp: Protein nạc	2025-12-05 05:52:33.828541
21	3	78	avoid	Cá kho tộ: Dầu mỡ cao	2025-12-05 05:52:33.8292
22	3	79	avoid	Thịt kho trứng: Cholesterol và mỡ cao	2025-12-05 05:52:33.829489
23	3	111	avoid	Bò lúc lắc: Dầu chiên nhiều	2025-12-05 05:52:33.829825
24	4	75	recommend	Gỏi cuốn: Ít calo, nhiều rau	2025-12-05 05:52:33.83042
25	4	77	recommend	Rau muống xào tỏi: Ít calo	2025-12-05 05:52:33.83107
26	4	93	recommend	Cá hấp: Protein không dầu	2025-12-05 05:52:33.831734
27	4	94	recommend	Gà hấp: Ít calo, protein cao	2025-12-05 05:52:33.832194
28	4	76	recommend	Canh chua cá: Ít calo, nhiều rau	2025-12-05 05:52:33.832608
29	4	100	avoid	Xôi: Calo cao từ carbs	2025-12-05 05:52:33.833036
30	4	102	avoid	Bánh xèo: Dầu chiên nhiều	2025-12-05 05:52:33.833428
31	4	103	avoid	Chả giò: Chiên nhiều dầu	2025-12-05 05:52:33.833804
32	4	109	avoid	Chè đậu xanh: Đường và calo cao	2025-12-05 05:52:33.834608
33	5	77	recommend	Rau muống xào tỏi: Ít purin	2025-12-05 05:52:33.835151
35	5	94	recommend	Gà hấp: Protein ít purin hơn thịt đỏ	2025-12-05 05:52:33.835831
36	5	64	avoid	Phở bò: Nước dùng purin cao	2025-12-05 05:52:33.836192
37	5	71	avoid	Bún bò Huế: Thịt bò purin cao	2025-12-05 05:52:33.836867
38	5	78	avoid	Cá kho tộ: Cá purin cao	2025-12-05 05:52:33.83799
39	5	93	avoid	Cá hấp: Hải sản purin cao	2025-12-05 05:52:33.838729
40	6	75	recommend	Gỏi cuốn: Ít dầu mỡ, nhiều rau	2025-12-05 05:52:33.839172
41	6	77	recommend	Rau muống xào tỏi: Chất xơ cao	2025-12-05 05:52:33.839579
42	6	93	recommend	Cá hấp: Omega-3 tốt cho gan	2025-12-05 05:52:33.840001
43	6	94	recommend	Gà hấp: Protein nạc	2025-12-05 05:52:33.840398
44	6	78	avoid	Cá kho tộ: Dầu mỡ cao	2025-12-05 05:52:33.840773
45	6	79	avoid	Thịt kho trứng: Mỡ động vật cao	2025-12-05 05:52:33.841191
46	6	102	avoid	Bánh xèo: Chiên nhiều dầu	2025-12-05 05:52:33.841651
47	7	94	recommend	Gà hấp: Dễ tiêu, nhẹ dạ dày	2025-12-05 05:52:33.84213
48	7	93	recommend	Cá hấp: Nhẹ, dễ tiêu hóa	2025-12-05 05:52:33.842523
50	7	76	avoid	Canh chua cá: Chua gây kích ứng dạ dày	2025-12-05 05:52:33.843309
51	7	102	avoid	Bánh xèo: Chiên dầu kích thích dạ dày	2025-12-05 05:52:33.8437
52	7	103	avoid	Chả giò: Chiên giòn khó tiêu	2025-12-05 05:52:33.844072
53	8	64	recommend	Phở bò: Thịt bò giàu sắt	2025-12-05 05:52:33.844497
54	8	71	recommend	Bún bò Huế: Thịt bò sắt cao	2025-12-05 05:52:33.844925
55	8	79	recommend	Thịt kho trứng: Sắt từ thịt và trứng	2025-12-05 05:52:33.845303
56	8	77	recommend	Rau muống xào tỏi: Sắt từ rau	2025-12-05 05:52:33.845746
57	14	64	recommend	Phở bò: Thịt bò sắt heme cao	2025-12-05 05:52:33.846184
58	14	71	recommend	Bún bò Huế: Thịt bò giàu sắt	2025-12-05 05:52:33.846532
59	14	79	recommend	Thịt kho trứng: Sắt từ thịt	2025-12-05 05:52:33.846865
60	14	111	recommend	Bò lúc lắc: Thịt bò sắt cao	2025-12-05 05:52:33.847294
62	15	93	recommend	Cá hấp: Canxi và vitamin D	2025-12-05 05:52:33.848629
63	15	77	recommend	Rau muống xào tỏi: Canxi từ rau	2025-12-05 05:52:33.849236
64	17	94	recommend	Gà hấp: Protein vừa phải	2025-12-05 05:52:33.84993
65	17	75	recommend	Gỏi cuốn: Ít muối, protein vừa	2025-12-05 05:52:33.850374
66	17	64	avoid	Phở bò: Natri và protein cao	2025-12-05 05:52:33.850807
67	17	78	avoid	Cá kho tộ: Muối và nước mắm cao	2025-12-05 05:52:33.851262
68	17	79	avoid	Thịt kho trứng: Protein và phospho cao	2025-12-05 05:52:33.851736
69	18	94	recommend	Gà hấp: Ít dầu mỡ	2025-12-05 05:52:33.852129
70	18	93	recommend	Cá hấp: Nhẹ, không kích ứng	2025-12-05 05:52:33.852719
71	18	76	avoid	Canh chua cá: Chua kích thích	2025-12-05 05:52:33.853153
72	18	102	avoid	Bánh xèo: Chiên dầu gây trào ngược	2025-12-05 05:52:33.853613
73	18	103	avoid	Chả giò: Dầu mỡ gây trào ngược	2025-12-05 05:52:33.854325
74	9	64	recommend	Phở bò: Protein và calo cao	2025-12-05 05:57:53.894659
75	9	71	recommend	Bún bò Huế: Dinh dưỡng toàn diện	2025-12-05 05:57:53.902594
76	9	79	recommend	Thịt kho trứng: Protein và chất béo	2025-12-05 05:57:53.90349
77	9	111	recommend	Bò lúc lắc: Protein và năng lượng cao	2025-12-05 05:57:53.904176
78	9	100	recommend	Xôi: Năng lượng từ carbs	2025-12-05 05:57:53.904905
79	10	75	recommend	Gỏi cuốn: Ít allergen, tươi sạch	2025-12-05 05:57:53.905814
80	10	77	recommend	Rau muống xào tỏi: Rau xanh ít dị ứng	2025-12-05 05:57:53.907059
81	10	94	recommend	Gà hấp: Protein dễ dung nạp	2025-12-05 05:57:53.907816
82	10	103	avoid	Chả giò: Nhiều thành phần có thể gây dị ứng	2025-12-05 05:57:53.908367
83	10	93	avoid	Cá hấp: Hải sản dễ gây dị ứng	2025-12-05 05:57:53.909048
84	11	75	recommend	Gỏi cuốn: Ít đường, chất xơ cao	2025-12-05 05:57:53.909621
85	11	77	recommend	Rau muống xào tỏi: Ít carbs	2025-12-05 05:57:53.910795
86	11	93	recommend	Cá hấp: Protein không đường	2025-12-05 05:57:53.911204
87	11	94	recommend	Gà hấp: Protein nạc	2025-12-05 05:57:53.911738
88	11	100	avoid	Xôi: Chỉ số đường huyết cao	2025-12-05 05:57:53.912217
89	11	109	avoid	Chè đậu xanh: Đường cao	2025-12-05 05:57:53.912673
90	11	110	avoid	Bánh flan: Đường và carbs cao	2025-12-05 05:57:53.913079
91	12	75	recommend	Gỏi cuốn: Ít muối	2025-12-05 05:57:53.913483
92	12	77	recommend	Rau muống xào tỏi: Kali cao	2025-12-05 05:57:53.913964
93	12	93	recommend	Cá hấp: Omega-3, ít natri	2025-12-05 05:57:53.914399
94	12	94	recommend	Gà hấp: Protein không muối	2025-12-05 05:57:53.914941
95	12	78	avoid	Cá kho tộ: Nước mắm cao	2025-12-05 05:57:53.915468
96	12	114	avoid	Thịt kho tàu: Muối và nước mắm	2025-12-05 05:57:53.915892
97	13	77	recommend	Rau muống xào tỏi: Vitamin K cân bằng	2025-12-05 05:57:53.916455
98	13	93	recommend	Cá hấp: Omega-3 chống viêm	2025-12-05 05:57:53.91696
99	13	94	recommend	Gà hấp: Protein ổn định	2025-12-05 05:57:53.917476
100	13	75	avoid	Gỏi cuốn: Vitamin K cao (nếu dùng Warfarin)	2025-12-05 05:57:53.918046
101	16	77	recommend	Rau muống xào tỏi: Ít purin	2025-12-05 05:57:53.918544
103	16	94	recommend	Gà hấp: Ít purin hơn thịt đỏ	2025-12-05 05:57:53.919339
104	16	64	avoid	Phở bò: Nước dùng purin cao	2025-12-05 05:57:53.91971
105	16	71	avoid	Bún bò Huế: Thịt bò purin cao	2025-12-05 05:57:53.920453
106	16	111	avoid	Bò lúc lắc: Thịt đỏ purin cao	2025-12-05 05:57:53.920851
107	19	75	recommend	Gỏi cuốn: Ít cholesterol	2025-12-05 05:57:53.921234
108	19	77	recommend	Rau muống xào tỏi: Chất xơ hòa tan	2025-12-05 05:57:53.92168
109	19	93	recommend	Cá hấp: Omega-3 giảm LDL	2025-12-05 05:57:53.922063
111	19	79	avoid	Thịt kho trứng: Cholesterol cao	2025-12-05 05:57:53.923923
112	19	111	avoid	Bò lúc lắc: Dầu mỡ cao	2025-12-05 05:57:53.924852
113	20	94	recommend	Gà hấp: Dễ tiêu, bổ sung protein	2025-12-05 05:57:53.925361
114	20	100	recommend	Xôi: Năng lượng dễ hấp thu	2025-12-05 05:57:53.925836
115	20	103	avoid	Chả giò: Chiên dầu khó tiêu	2025-12-05 05:57:53.926399
116	20	102	avoid	Bánh xèo: Dầu mỡ kích thích ruột	2025-12-05 05:57:53.926973
117	21	94	recommend	Gà hấp: Protein dễ tiêu	2025-12-05 05:57:53.927559
118	21	100	recommend	Xôi: Năng lượng nhẹ	2025-12-05 05:57:53.928063
119	21	103	avoid	Chả giò: Chiên dầu nặng dạ dày	2025-12-05 05:57:53.928585
120	22	93	recommend	Cá hấp: Omega-3 tốt tim mạch	2025-12-05 05:57:53.929045
121	22	75	recommend	Gỏi cuốn: Ít chất béo bão hòa	2025-12-05 05:57:53.929473
122	22	77	recommend	Rau muống xào tỏi: Chất xơ giảm cholesterol	2025-12-05 05:57:53.92997
124	22	79	avoid	Thịt kho trứng: Mỡ bão hòa cao	2025-12-05 05:57:53.930908
125	22	111	avoid	Bò lúc lắc: Cholesterol cao	2025-12-05 05:57:53.931335
126	23	93	recommend	Cá hấp: Omega-3 ổn định nhịp tim	2025-12-05 05:57:53.931757
127	23	77	recommend	Rau muống xào tỏi: Magie tốt cho tim	2025-12-05 05:57:53.93216
128	23	78	avoid	Cá kho tộ: Natri cao ảnh hưởng nhịp tim	2025-12-05 05:57:53.932682
129	24	93	recommend	Cá hấp: Protein nhẹ, ít natri	2025-12-05 05:57:53.933091
130	24	94	recommend	Gà hấp: Protein không muối	2025-12-05 05:57:53.933531
131	24	75	recommend	Gỏi cuốn: Ít muối, nhiều rau	2025-12-05 05:57:53.934073
132	24	78	avoid	Cá kho tộ: Muối cao	2025-12-05 05:57:53.934661
133	24	114	avoid	Thịt kho tàu: Nước mắm và muối	2025-12-05 05:57:53.93513
134	25	94	recommend	Gà hấp: Dễ tiêu, bổ sung protein	2025-12-05 05:57:53.93554
135	25	100	recommend	Xôi: Dễ tiêu hóa	2025-12-05 05:57:53.935975
136	25	103	avoid	Chả giò: Dầu mỡ kích thích ruột	2025-12-05 05:57:53.936449
137	26	94	recommend	Gà hấp: Protein tăng miễn dịch	2025-12-05 05:57:53.936958
138	26	64	recommend	Phở bò: Dinh dưỡng toàn diện	2025-12-05 05:57:53.937511
139	26	103	avoid	Chả giò: Chiên dầu giảm miễn dịch	2025-12-05 05:57:53.937909
140	27	93	recommend	Cá hấp: Omega-3 chống viêm	2025-12-05 05:57:53.938286
141	27	77	recommend	Rau muống xào tỏi: Chống oxy hóa	2025-12-05 05:57:53.938658
142	27	103	avoid	Chả giò: Chiên dầu gây viêm	2025-12-05 05:57:53.939164
143	27	102	avoid	Bánh xèo: Dầu mỡ kích ứng	2025-12-05 05:57:53.94018
144	28	93	recommend	Cá hấp: Protein dễ tiêu	2025-12-05 05:57:53.941192
145	28	94	recommend	Gà hấp: Năng lượng ổn định	2025-12-05 05:57:53.941753
146	28	103	avoid	Chả giò: Dầu mỡ gây khó thở	2025-12-05 05:57:53.942146
147	29	94	recommend	Gà hấp: Nhẹ dạ dày	2025-12-05 05:57:53.942557
148	29	93	recommend	Cá hấp: Dễ tiêu hóa	2025-12-05 05:57:53.942958
149	29	76	avoid	Canh chua cá: Chua kích ứng loét	2025-12-05 05:57:53.943465
150	29	103	avoid	Chả giò: Chiên dầu kích thích	2025-12-05 05:57:53.944017
151	30	75	recommend	Gỏi cuốn: Ít dầu mỡ	2025-12-05 05:57:53.944766
152	30	77	recommend	Rau muống xào tỏi: Chất xơ giải độc	2025-12-05 05:57:53.945328
153	30	93	recommend	Cá hấp: Omega-3 giảm mỡ gan	2025-12-05 05:57:53.945862
154	30	79	avoid	Thịt kho trứng: Mỡ động vật	2025-12-05 05:57:53.946365
155	30	102	avoid	Bánh xèo: Dầu chiên nhiều	2025-12-05 05:57:53.946837
156	31	93	recommend	Cá hấp: Omega-3 chống viêm	2025-12-05 05:57:53.947336
157	31	77	recommend	Rau muống xào tỏi: Chống oxy hóa	2025-12-05 05:57:53.947845
159	31	79	avoid	Thịt kho trứng: Mỡ bão hòa gây viêm	2025-12-05 05:57:53.948669
160	32	93	recommend	Cá hấp: Selenium tốt cho tuyến giáp	2025-12-05 05:57:53.948978
161	32	94	recommend	Gà hấp: Protein hỗ trợ chuyển hóa	2025-12-05 05:57:53.949335
162	32	77	avoid	Rau muống xào tỏi: Goitrogen ức chế giáp	2025-12-05 05:57:53.949773
163	33	77	recommend	Rau muống xào tỏi: Goitrogen giảm hoạt động giáp	2025-12-05 05:57:53.950232
164	33	93	avoid	Cá hấp: Iốt có thể tăng cường giáp	2025-12-05 05:57:53.950635
165	34	94	recommend	Gà hấp: Magie giảm đau đầu	2025-12-05 05:57:53.950986
166	34	77	recommend	Rau muống xào tỏi: Magie cao	2025-12-05 05:57:53.951355
167	34	79	avoid	Thịt kho trứng: Tyramine gây đau đầu	2025-12-05 05:57:53.951735
168	35	94	recommend	Gà hấp: Protein hỗ trợ phục hồi	2025-12-05 05:57:53.952253
169	35	100	recommend	Xôi: Dễ tiêu, bổ sung năng lượng	2025-12-05 05:57:53.952674
170	35	103	avoid	Chả giò: Dầu mỡ kích thích ruột	2025-12-05 05:57:53.953047
171	36	94	recommend	Gà hấp: Nhẹ, dễ tiêu	2025-12-05 05:57:53.953475
172	36	100	recommend	Xôi: Dễ hấp thu	2025-12-05 05:57:53.953954
173	36	103	avoid	Chả giò: Chiên dầu nặng ruột	2025-12-05 05:57:53.95443
174	37	94	recommend	Gà hấp: Dễ tiêu hóa	2025-12-05 05:57:53.954935
175	37	100	recommend	Xôi: Nhẹ dạ dày	2025-12-05 05:57:53.955554
176	37	103	avoid	Chả giò: Dầu mỡ kích thích	2025-12-05 05:57:53.957029
177	38	64	recommend	Phở bò: Protein tăng sức đề kháng	2025-12-05 05:57:53.958181
178	38	94	recommend	Gà hấp: Dinh dưỡng dễ hấp thu	2025-12-05 05:57:53.95898
179	38	79	recommend	Thịt kho trứng: Năng lượng và protein	2025-12-05 05:57:53.95958
180	39	64	recommend	Phở bò: Dinh dưỡng toàn diện	2025-12-05 05:57:53.960145
181	39	94	recommend	Gà hấp: Protein hỗ trợ điều trị	2025-12-05 05:57:53.960648
182	39	79	recommend	Thịt kho trứng: Năng lượng cao	2025-12-05 05:57:53.961148
\.


--
-- TOC entry 6604 (class 0 OID 22361)
-- Dependencies: 327
-- Data for Name: conditioneffectlog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conditioneffectlog (log_id, user_id, condition_id, nutrient_id, effect_type, adjustment_percent, original_rda, adjusted_rda, applied_at) FROM stdin;
\.


--
-- TOC entry 6602 (class 0 OID 22337)
-- Dependencies: 325
-- Data for Name: conditionfoodrecommendation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conditionfoodrecommendation (recommendation_id, condition_id, food_id, recommendation_type, notes) FROM stdin;
325	1	49	avoid	\N
326	1	111	avoid	\N
327	1	58	avoid	\N
25	2	40	avoid	Nước mắm chứa nhiều muối, làm tăng huyết áp
26	2	41	avoid	Đường tinh luyện nên hạn chế
328	1	100	avoid	\N
329	1	3009	recommend	\N
29	2	43	recommend	Rau củ giàu chất xơ và khoáng chất
30	1	41	avoid	Đường làm tăng đường huyết nhanh
330	1	50	recommend	\N
331	1	61	recommend	\N
33	1	43	recommend	Rau củ giàu chất xơ, chỉ số đường huyết thấp
332	1	66	recommend	\N
35	11	41	avoid	Đường làm tăng đường huyết nhanh
333	1	106	recommend	\N
334	2	84	avoid	\N
38	11	43	recommend	Rau củ tốt cho người tiểu đường
39	3	40	avoid	Nước mắm chứa nhiều natri
40	3	41	avoid	Đường nên hạn chế
335	2	3009	recommend	\N
42	3	38	recommend	Nấm tốt cho sức khỏe tim mạch
43	3	43	recommend	Rau củ giàu chất xơ, giảm cholesterol
44	4	41	avoid	Đường gây tăng cân
336	2	50	recommend	\N
46	4	43	recommend	Rau củ ít calo, giàu chất xơ
337	2	57	recommend	\N
338	2	58	recommend	\N
49	5	40	avoid	Nước mắm nên hạn chế
339	2	100	recommend	\N
51	5	43	recommend	Rau củ ít purin, an toàn cho người gout
340	3	65	avoid	\N
341	3	84	avoid	\N
28	2	12	recommend	Đậu xanh tốt cho tim mạch
32	1	12	recommend	Đậu xanh giàu chất xơ, ổn định đường huyết
37	11	12	recommend	Đậu xanh giàu chất xơ
41	3	12	recommend	Đậu xanh giúp giảm cholesterol
47	4	12	recommend	Đậu xanh giàu protein thực vật
50	5	12	avoid	Đậu xanh chứa purin trung bình, ăn vừa phải
27	2	11	recommend	Dứa giàu kali, giúp kiểm soát huyết áp
53	5	11	recommend	Dứa có enzyme bromelain, chống viêm
48	4	9	recommend	Dưa leo ít calo, nhiều nước
52	5	9	recommend	Dưa leo giúp thải độc
31	1	1	avoid	Gạo trắng có chỉ số đường huyết cao, nên thay bằng gạo lứt
36	11	1	avoid	Gạo trắng nên hạn chế
45	4	1	avoid	Gạo trắng nhiều calo, nên ăn vừa phải
34	1	6	recommend	Ngô giàu chất xơ, tốt cho người tiểu đường
54	6	1	avoid	Tránh đường và tinh bột tinh luyện
55	6	41	avoid	Hạn chế đường
56	6	43	recommend	Rau củ giàu chất xơ tốt cho gan
57	6	9	recommend	Protein nạc giúp phục hồi gan
58	6	11	recommend	Cá giàu omega-3 giảm mỡ gan
59	7	40	avoid	Tránh thức ăn cay nồng
60	7	41	avoid	Hạn chế đồ ngọt
61	7	12	recommend	Cháo gạo lứt dễ tiêu hóa
62	7	43	recommend	Rau luộc nhạt
63	8	41	avoid	Hạn chế đường tinh luyện
64	8	9	recommend	Thịt đỏ giàu sắt
65	8	43	recommend	Rau lá xanh giàu folate
66	8	11	recommend	Gan động vật giàu sắt
67	9	41	avoid	Tránh đồ ăn vặt không dinh dưỡng
68	9	9	recommend	Protein chất lượng cao
69	9	12	recommend	Ngũ cốc nguyên hạt
70	9	43	recommend	Rau củ đa dạng
71	9	6	recommend	Trái cây giàu vitamin
72	10	1	avoid	Tùy vào loại dị ứng cụ thể
73	10	43	recommend	Rau củ ít gây dị ứng
74	10	12	recommend	Gạo lứt an toàn
75	12	40	avoid	Giảm muối
76	12	41	avoid	Hạn chế đường
77	12	43	recommend	Rau củ giàu kali
78	12	9	recommend	Protein nạc
79	12	11	recommend	Cá giàu omega-3
80	14	41	avoid	Hạn chế đường
81	14	9	recommend	Thịt đỏ giàu sắt heme
82	14	43	recommend	Rau lá xanh
83	14	6	recommend	Vitamin C giúp hấp thu sắt
84	15	40	avoid	Giảm muối làm mất canxi
85	15	41	avoid	Hạn chế đường
86	15	12	recommend	Đậu nành giàu canxi
87	15	9	recommend	Protein xây dựng xương
88	15	43	recommend	Rau xanh giàu canxi
89	17	40	avoid	Hạn chế muối nghiêm ngặt
90	17	9	avoid	Giảm protein
91	17	43	recommend	Rau củ hạn chế kali
92	17	12	recommend	Ngũ cốc tinh chế
93	18	40	avoid	Tránh đồ cay
94	18	41	avoid	Hạn chế đồ ngọt
95	18	12	recommend	Cháo nhạt
96	18	43	recommend	Rau luộc
97	22	1	avoid	Tránh mỡ bão hòa
98	22	40	avoid	Giảm muối
99	22	11	recommend	Cá giàu omega-3
100	22	43	recommend	Rau củ giàu chất chống oxy hóa
101	22	6	recommend	Trái cây tươi
342	3	3009	recommend	\N
343	3	66	recommend	\N
344	3	106	recommend	\N
345	3	50	recommend	\N
346	3	57	recommend	\N
347	4	111	avoid	\N
348	4	3009	recommend	\N
349	4	50	recommend	\N
350	4	52	recommend	\N
351	4	61	recommend	\N
352	4	66	recommend	\N
353	4	106	recommend	\N
354	4	57	recommend	\N
355	5	106	avoid	\N
356	5	3009	recommend	\N
102	24	40	avoid	Hạn chế muối
103	24	41	avoid	Giảm đường
104	24	43	recommend	Rau củ giàu kali
105	24	11	recommend	Protein nạc
357	5	50	recommend	\N
358	5	52	recommend	\N
359	5	53	recommend	\N
360	5	61	recommend	\N
361	5	66	recommend	\N
362	5	57	recommend	\N
363	5	100	recommend	\N
364	5	3006	recommend	\N
365	6	3009	recommend	\N
366	6	61	recommend	\N
367	6	65	recommend	\N
368	6	50	recommend	\N
369	6	3006	recommend	\N
370	7	3009	recommend	\N
371	7	65	recommend	\N
372	7	3006	recommend	\N
373	7	84	recommend	\N
374	7	66	recommend	\N
375	7	50	recommend	\N
376	7	57	recommend	\N
377	8	106	avoid	\N
378	8	61	recommend	\N
379	8	66	recommend	\N
380	8	57	recommend	\N
381	8	3006	recommend	\N
382	9	52	avoid	\N
383	9	57	avoid	\N
384	9	3009	recommend	\N
385	9	61	recommend	\N
386	9	66	recommend	\N
387	9	3006	recommend	\N
388	10	52	avoid	\N
389	10	3009	recommend	\N
390	10	61	recommend	\N
391	10	66	recommend	\N
392	10	3006	recommend	\N
393	11	52	avoid	\N
394	11	3009	recommend	\N
395	11	61	recommend	\N
396	11	66	recommend	\N
397	11	3006	recommend	\N
398	12	46	avoid	\N
399	12	66	recommend	\N
400	12	106	recommend	\N
401	12	50	recommend	\N
402	12	57	recommend	\N
403	13	65	avoid	\N
404	13	106	avoid	\N
405	13	84	avoid	\N
406	13	3009	recommend	\N
407	13	53	recommend	\N
408	13	61	recommend	\N
409	13	57	recommend	\N
410	13	100	recommend	\N
411	14	49	avoid	\N
412	14	111	avoid	\N
413	14	3009	recommend	\N
414	14	50	recommend	\N
415	14	52	recommend	\N
416	14	53	recommend	\N
417	14	61	recommend	\N
418	14	66	recommend	\N
419	15	61	recommend	\N
420	15	65	recommend	\N
421	15	66	recommend	\N
422	15	106	recommend	\N
423	15	111	recommend	\N
424	16	84	avoid	\N
425	16	3009	recommend	\N
426	16	50	recommend	\N
427	16	61	recommend	\N
428	16	66	recommend	\N
429	16	57	recommend	\N
430	17	65	avoid	\N
431	17	84	avoid	\N
432	17	3009	recommend	\N
433	17	66	recommend	\N
434	17	106	recommend	\N
435	17	50	recommend	\N
436	17	57	recommend	\N
437	18	65	avoid	\N
438	18	84	avoid	\N
439	18	3009	recommend	\N
440	18	66	recommend	\N
441	18	106	recommend	\N
442	18	50	recommend	\N
443	18	57	recommend	\N
444	19	3009	recommend	\N
445	19	50	recommend	\N
446	19	57	recommend	\N
447	20	3009	recommend	\N
448	20	50	recommend	\N
449	20	61	recommend	\N
450	20	57	recommend	\N
451	21	3009	avoid	\N
452	21	106	avoid	\N
453	21	50	recommend	\N
454	21	61	recommend	\N
455	22	3009	recommend	\N
456	22	50	recommend	\N
457	22	61	recommend	\N
458	22	66	recommend	\N
459	22	57	recommend	\N
460	23	3009	recommend	\N
461	23	50	recommend	\N
462	23	66	recommend	\N
463	23	57	recommend	\N
464	24	3009	recommend	\N
465	24	50	recommend	\N
466	24	66	recommend	\N
467	24	57	recommend	\N
468	25	3009	avoid	\N
469	25	50	avoid	\N
470	25	106	avoid	\N
471	25	61	recommend	\N
472	25	66	recommend	\N
473	25	3006	recommend	\N
474	26	3009	avoid	\N
475	26	50	avoid	\N
476	26	106	avoid	\N
477	26	61	recommend	\N
478	26	66	recommend	\N
479	26	3006	recommend	\N
480	27	3006	avoid	\N
481	27	84	avoid	\N
482	27	66	recommend	\N
483	27	106	recommend	\N
484	27	50	recommend	\N
485	27	57	recommend	\N
486	28	106	avoid	\N
487	28	61	recommend	\N
488	28	50	recommend	\N
489	28	57	recommend	\N
490	29	61	recommend	\N
491	29	66	recommend	\N
492	29	3006	recommend	\N
493	30	65	avoid	\N
494	30	3009	recommend	\N
495	30	50	recommend	\N
496	30	61	recommend	\N
497	30	66	recommend	\N
498	30	57	recommend	\N
499	31	111	avoid	\N
500	31	3009	recommend	\N
501	31	50	recommend	\N
502	31	61	recommend	\N
503	31	66	recommend	\N
504	31	106	recommend	\N
505	31	57	recommend	\N
506	32	111	avoid	\N
507	32	3009	recommend	\N
508	32	50	recommend	\N
509	32	61	recommend	\N
510	32	66	recommend	\N
511	32	106	recommend	\N
512	32	57	recommend	\N
513	33	52	avoid	\N
514	33	100	recommend	\N
515	33	3006	recommend	\N
516	34	52	avoid	\N
517	34	100	recommend	\N
518	34	3006	recommend	\N
519	35	61	recommend	\N
520	35	65	recommend	\N
521	35	66	recommend	\N
522	35	106	recommend	\N
523	35	111	recommend	\N
524	36	61	recommend	\N
525	36	65	recommend	\N
526	36	66	recommend	\N
527	36	106	recommend	\N
528	36	111	recommend	\N
529	37	61	recommend	\N
530	37	65	recommend	\N
531	37	66	recommend	\N
532	37	106	recommend	\N
533	37	111	recommend	\N
534	38	52	avoid	\N
535	38	100	recommend	\N
536	38	3006	recommend	\N
537	38	61	recommend	\N
538	39	61	recommend	\N
539	39	65	recommend	\N
540	39	66	recommend	\N
541	39	106	recommend	\N
542	39	111	recommend	\N
\.


--
-- TOC entry 6600 (class 0 OID 22313)
-- Dependencies: 323
-- Data for Name: conditionnutrienteffect; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conditionnutrienteffect (effect_id, condition_id, nutrient_id, effect_type, adjustment_percent, notes) FROM stdin;
\.


--
-- TOC entry 6688 (class 0 OID 29267)
-- Dependencies: 419
-- Data for Name: daily_reset_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daily_reset_history (reset_id, reset_type, reset_date, reset_timestamp, created_at) FROM stdin;
\.


--
-- TOC entry 6527 (class 0 OID 21334)
-- Dependencies: 246
-- Data for Name: dailysummary; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dailysummary (summary_id, user_id, date, total_calories, total_protein, total_fiber, total_carbs, total_fat, total_water) FROM stdin;
57	1	2025-11-22	0.00	0.00	0.00	0.00	0.00	500.00
56	1	2025-11-23	265.00	9.00	0.00	49.00	3.20	500.00
65	1	2025-11-24	3295.00	1117.00	0.00	1267.00	1069.60	0.00
70	3	2025-11-27	1000.00	1000.00	0.00	1000.00	1000.00	0.00
71	3	2025-11-29	1000.00	1000.00	0.00	1000.00	1000.00	0.00
77	3	2025-12-03	0.00	0.00	0.00	0.00	0.00	1000.00
72	3	2025-12-04	20000.00	597.92	0.00	2574.00	734.00	2500.00
85	4	2025-12-04	0.00	0.00	0.00	0.00	0.00	1000.00
35	1	2025-11-18	0.00	0.00	0.00	0.00	0.00	300.00
89	1	2025-12-04	0.00	0.00	0.00	0.00	0.00	1350.00
88	1	2025-12-05	20000.00	500.00	0.00	2500.00	700.00	0.00
1	1	2025-11-19	608.90	25.40	0.00	112.60	6.82	1300.00
23	1	2025-11-20	6693.90	401.40	0.00	583.60	253.62	5500.00
48	1	2025-11-21	4765.00	279.00	0.00	409.00	183.20	1250.00
\.


--
-- TOC entry 6678 (class 0 OID 29027)
-- Dependencies: 409
-- Data for Name: dailysummaryhistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dailysummaryhistory (history_id, user_id, date, total_calories, total_protein, total_fat, total_carbs, total_fiber, total_water, archived_at) FROM stdin;
\.


--
-- TOC entry 6624 (class 0 OID 22682)
-- Dependencies: 350
-- Data for Name: dish; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dish (dish_id, name, vietnamese_name, description, category, serving_size_g, image_url, is_template, is_public, created_by_user, created_by_admin, created_at, updated_at, image_urls) FROM stdin;
68	Bún riêu cua	Bún riêu cua	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
69	Cơm tấm sườn	Cơm tấm sườn	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
70	Cơm gà xối mỡ	Cơm gà xối mỡ	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
71	Cơm chiên dương châu	Cơm chiên dương châu	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
72	Cơm gà Hải Nam	Cơm gà Hải Nam	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
73	Cơm lam	Cơm lam	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
74	Thịt bò xào rau muống	Thịt bò xào rau muống	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
75	Gà xào sả ớt	Gà xào sả ớt	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
76	Rau muống xào tỏi	Rau muống xào tỏi	\N	side_dish	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
77	Cải bắp xào tỏi	Cải bắp xào tỏi	\N	side_dish	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
78	Đậu phụ xào cà chua	Đậu phụ xào cà chua	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
79	Thịt heo xào củ hành	Thịt heo xào củ hành	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
80	Mực xào chua ngọt	Mực xào chua ngọt	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
31	Beef Noodle Soup (Nam Dinh)	Phở Nam Định	Phở bò kiểu Nam Định với thịt bò chín	Breakfast	700.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.200961	[]
32	Vietnamese Savory Pancake	Bánh Khọt	Bánh khọt tôm, ăn kèm rau sống	Snack	200.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.200961	[]
33	Quang Noodle	Mì Quảng	Mì Quảng với tôm, thịt, đậu phộng, bánh tráng	Lunch	500.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.200961	[]
35	Stir-fried Chicken with Lemongrass	Gà Xào Sả Ớt	Gà xào sả ớt thơm cay	Dinner	300.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.200961	[]
36	Fish Ball Noodle Soup	Bún Cá	Bún cá với chả cá, cà chua, mắm tôm	Lunch	550.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.200961	[]
37	Fried Tofu with Lemongrass Chili	Đậu Hũ Chiên Sả Ớt	Đậu hũ chiên giòn sốt sả ớt	Vegetarian	250.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.200961	[]
38	Pork Skewers	Nem Nướng	Nem nướng Nha Trang, ăn kèm bánh tráng	Snack	200.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.200961	[]
1	Vietnamese Beef Pho	Phở Bò Hà Nội	Món phở truyền thống với nước dùng hầm xương bò, thịt bò tái, và rau thơm	Breakfast	700.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
10	Sour Fish Soup	Canh Chua Cá	Canh chua với cá, thơm, cà chua, rau muống, đậu bắp	Soup	400.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
1024	Canh cá nấu cải	Canh cá nấu cải	\N	Soup	300.00	\N	t	t	\N	1	2025-12-05 04:49:18.498641	2025-12-05 04:49:18.791894	[]
1025	Đậu hũ non hấp	Đậu hũ non hấp	\N	Vegetarian	200.00	\N	t	t	\N	1	2025-12-05 04:49:18.499813	2025-12-05 04:49:18.797175	[]
1026	Sữa đậu nành hạt điều	Sữa đậu nành hạt điều	\N	Breakfast	250.00	\N	t	t	\N	1	2025-12-05 04:49:18.500486	2025-12-05 04:49:18.802476	[]
1028	Ức gà hấp	Ức gà hấp	\N	Lunch	150.00	\N	t	t	\N	1	2025-12-05 04:49:18.502865	2025-12-05 04:49:18.813602	[]
1029	Trứng trắng luộc	Trứng trắng luộc	\N	Breakfast	100.00	\N	t	t	\N	1	2025-12-05 04:49:18.504057	2025-12-05 04:49:18.819225	[]
11	Vegetarian Pho	Phở Chay	Phở với nước dùng nấm, đậu hũ, rau củ	Vegetarian	650.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-05 00:10:04.969401	[]
2	Broken Rice with Grilled Pork	Cơm Tấm Sườn Bì Chả	Cơm tấm với sườn nướng, bì, chả trứng, và nước mắm pha	Breakfast	400.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
13	Tofu with Tomato Sauce	Đậu Hũ Sốt Cà Chua	Đậu hũ chiên giòn, sốt cà chua chua ngọt	Vegetarian	250.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-05 00:10:04.969401	[]
3	Banh Mi Vietnamese Sandwich	Bánh Mì Thịt Nguội	Bánh mì giòn với pate, thịt nguội, dưa chua, rau thơm	Breakfast	250.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
4	Sticky Rice with Chicken	Xôi Gà	Xôi nếp với gà xé phay, hành phi, nước mắm gừng	Breakfast	300.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
5	Bun Cha Hanoi	Bún Chả Hà Nội	Bún với chả nướng, thịt nướng, nước mắm chua ngọt, rau sống	Lunch	500.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
6	Vietnamese Spring Rolls	Gỏi Cuốn Tôm Thịt	Bánh tráng cuốn tôm, thịt, bún, rau sống, chấm nước mắm	Lunch	200.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
7	Grilled Fish in Banana Leaf	Cá Nướng Lá Chuối	Cá nướng với sả ớt, gói lá chuối, ăn kèm bún và rau	Dinner	350.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
8	Caramelized Pork Belly	Thịt Kho Tàu	Thịt ba chỉ kho với nước dừa, trứng, đường caramel	Dinner	250.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
9	Braised Fish in Clay Pot	Cá Kho Tộ	Cá kho với nước mắm, đường, ớt, ăn với cơm trắng	Dinner	300.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
12	Stir-fried Morning Glory	Rau Muống Xào Tỏi	Rau muống xào với tỏi, nước mắm hoặc muối	Vegetarian	200.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
14	Vietnamese Crepe	Bánh Xèo	Bánh xèo giòn với tôm, thịt, giá đỗ, ăn kèm rau sống	Snack	300.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
15	Grilled Rice Paper	Bánh Tráng Nướng	Bánh tráng nướng với trứng, hành khô, tương ớt	Snack	100.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
16	Chicken Congee	Cháo Gà	Cháo gạo với gà xé, gừng, hành, ăn nhẹ dễ tiêu	Light Meal	400.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
17	Fish Porridge	Cháo Cá	Cháo cá với rau thơm, dầu hành, dễ tiêu hóa	Light Meal	400.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
18	Steamed Vegetables Mix	Rau Củ Luộc	Rau củ luộc: bông cải, cà rốt, súp lơ, ít dầu	Light Meal	300.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
19	Grilled Pork Rice Vermicelli	Bún Thịt Nướng	Bún tươi với thịt heo nướng, rau sống, nước mắm	Lunch	450.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
20	Hue Beef Noodle Soup	Bún Bò Huế	Bún bò cay với chả, giò heo, rau thơm	Lunch	650.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
21	Vietnamese Fried Spring Rolls	Chả Giò (Nem Rán)	Chả giò chiên giòn với nhân thịt, miến, rau củ	Snack	150.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
22	Grilled Beef in La Lot Leaves	Bò Lá Lốt	Thịt bò cuộn lá lốt nướng than	Dinner	200.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
23	Stir-fried Beef with Vegetables	Bò Xào Rau Củ	Thịt bò xào với súp lơ, cà rốt, đậu Hà Lan	Dinner	300.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
24	Vietnamese Chicken Salad	Gỏi Gà	Gỏi gà với bắp cải, cà rốt, rau răm	Salad	250.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
25	Steamed Rice Rolls	Bánh Cuốn	Bánh cuốn nhân thịt, nấm mèo, hành phi	Breakfast	300.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
26	Chicken Curry with Bread	Cà Ri Gà với Bánh Mì	Cà ri gà kiểu Việt, ăn kèm bánh mì	Lunch	400.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
64	Phở bò tái	Phở bò tái	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
28	Duck with Bamboo Shoots	Vịt Nấu Măng	Vịt nấu măng chua, rau thơm	Dinner	350.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
29	Pork Ribs Soup	Canh Sườn Hầm	Canh sườn heo ninh với củ cải, cà rốt	Soup	400.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
30	Stir-fried Mixed Vegetables	Rau Củ Xào Thập Cẩm	Rau củ xào chay: bông cải, cà rốt, nấm	Vegetarian	250.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-01 00:23:21.209028	[]
65	Bún bò Huế	Bún bò Huế	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
1000	Canh rau ngót nấu tôm	Canh rau ngót nấu tôm	\N	Soup	300.00	\N	t	t	\N	1	2025-12-05 04:49:18.45294	2025-12-05 04:49:18.561341	[]
59	Ultra Dish Complete	Sieu Thuc Pham	(1000g serving)	Test/Reference	1000.00	\N	f	t	\N	1	2025-12-03 22:58:24.374682	2025-12-03 23:25:12.469901	[]
27	Shrimp Paste Rice Vermicelli	Bún Đậu Mắm Tôm	Bún với đậu hũ chiên, chả cốm, mắm tôm	Lunch	450.00	\N	t	t	\N	1	2025-12-01 00:23:21.200961	2025-12-05 00:10:04.969401	[]
60	Test Dish - Restricted	Món Test - Hạn Chế	Contains restricted ingredient	Lunch	200.00	\N	f	t	\N	1	2025-12-05 00:17:36.745743	2025-12-05 00:17:36.745743	[]
61	Test Dish - Recommended	Món Test - Khuyến Nghị	Contains recommended ingredient	Lunch	200.00	\N	f	t	\N	1	2025-12-05 00:17:36.745743	2025-12-05 00:17:36.745743	[]
1009	Salad ức gà	Salad ức gà	\N	Lunch	250.00	\N	t	t	\N	1	2025-12-05 04:49:18.479607	2025-12-05 04:49:18.650937	[]
62	Test Dish - Mixed	Món Test - Hỗn Hợp	Contains both types	Lunch	200.00	\N	f	t	\N	1	2025-12-05 00:17:36.745743	2025-12-05 00:17:36.745743	[]
66	Bún chả Hà Nội	Bún chả Hà Nội	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
67	Phở gà	Phở gà	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
1001	Gà luộc chấm nước mắm	Gà luộc chấm nước mắm	\N	Lunch	200.00	\N	t	t	\N	1	2025-12-05 04:49:18.46901	2025-12-05 04:49:18.575331	[]
1018	Cháo gà nhạt	Cháo gà nhạt	\N	Light Meal	300.00	\N	t	t	\N	1	2025-12-05 04:49:18.487195	2025-12-05 04:49:18.734384	[]
1002	Cá hấp nấm	Cá hấp nấm	\N	Dinner	250.00	\N	t	t	\N	1	2025-12-05 04:49:18.470126	2025-12-05 04:49:18.588993	[]
1010	Canh rau củ thanh đạm	Canh rau củ thanh đạm	\N	Soup	300.00	\N	t	t	\N	1	2025-12-05 04:49:18.480819	2025-12-05 04:49:18.662171	[]
1003	Canh cải thảo nấu thịt nạc	Canh cải thảo nấu thịt nạc	\N	Soup	300.00	\N	t	t	\N	1	2025-12-05 04:49:18.470849	2025-12-05 04:49:18.600758	[]
1004	Bông cải xanh luộc	Bông cải xanh luộc	\N	Vegetarian	150.00	\N	t	t	\N	1	2025-12-05 04:49:18.471475	2025-12-05 04:49:18.605997	[]
1019	Canh bí đao nấu tôm	Canh bí đao nấu tôm	\N	Soup	250.00	\N	t	t	\N	1	2025-12-05 04:49:18.488517	2025-12-05 04:49:18.743543	[]
1005	Salad rau trộn dầu oliu	Salad rau trộn dầu oliu	\N	Salad	200.00	\N	t	t	\N	1	2025-12-05 04:49:18.472059	2025-12-05 04:49:18.617328	[]
1006	Cá hồi nướng	Cá hồi nướng	\N	Dinner	200.00	\N	t	t	\N	1	2025-12-05 04:49:18.472654	2025-12-05 04:49:18.622236	[]
1007	Cháo yến mạch hạt hạnh nhân	Cháo yến mạch hạt hạnh nhân	\N	Breakfast	250.00	\N	t	t	\N	1	2025-12-05 04:49:18.47327	2025-12-05 04:49:18.628216	[]
1011	Cá nướng rau củ	Cá nướng rau củ	\N	Dinner	250.00	\N	t	t	\N	1	2025-12-05 04:49:18.481594	2025-12-05 04:49:18.672315	[]
1008	Rau củ hấp	Rau củ hấp	\N	Vegetarian	200.00	\N	t	t	\N	1	2025-12-05 04:49:18.475731	2025-12-05 04:49:18.63883	[]
1013	Canh bí đỏ	Canh bí đỏ	\N	Soup	250.00	\N	t	t	\N	1	2025-12-05 04:49:18.483558	2025-12-05 04:49:18.687882	[]
1021	Gan gà xào nấm	Gan gà xào nấm	\N	Lunch	150.00	\N	t	t	\N	1	2025-12-05 04:49:18.494231	2025-12-05 04:49:18.755947	[]
1014	Trứng luộc rau xào	Trứng luộc rau xào	\N	Lunch	200.00	\N	t	t	\N	1	2025-12-05 04:49:18.484433	2025-12-05 04:49:18.699376	[]
1015	Canh cải xanh nấu đậu hũ	Canh cải xanh nấu đậu hũ	\N	Soup	300.00	\N	t	t	\N	1	2025-12-05 04:49:18.485066	2025-12-05 04:49:18.710227	[]
1016	Cá diêu hồng hấp gừng	Cá diêu hồng hấp gừng	\N	Dinner	200.00	\N	t	t	\N	1	2025-12-05 04:49:18.48565	2025-12-05 04:49:18.715163	[]
1017	Rau chân vịt luộc	Rau chân vịt luộc	\N	Vegetarian	150.00	\N	t	t	\N	1	2025-12-05 04:49:18.486288	2025-12-05 04:49:18.72283	[]
1022	Thịt bò xào rau củ	Thịt bò xào rau củ	\N	Dinner	250.00	\N	t	t	\N	1	2025-12-05 04:49:18.496226	2025-12-05 04:49:18.768039	[]
81	Tôm rim mặn	Tôm rim mặn	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
82	Canh chua cá	Canh chua cá	\N	soup	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
1027	Canh bí đỏ	Canh bí đỏ	\N	Soup	250.00	\N	t	t	\N	1	2025-12-05 04:49:18.501365	2025-12-05 05:32:39.556754	[]
83	Canh cải thảo nấu thịt	Canh cải thảo nấu thịt	\N	soup	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
1023	Canh rau dền nấu tôm	Canh rau dền nấu tôm	\N	Soup	300.00	\N	t	t	\N	1	2025-12-05 04:49:18.497559	2025-12-05 05:32:39.556754	[]
84	Canh khổ qua nhồi thịt	Canh khổ qua nhồi thịt	\N	soup	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
85	Canh nghêu	Canh nghêu	\N	soup	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
86	Canh cá rô	Canh cá rô	\N	soup	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
87	Cháo gà	Cháo gà	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
88	Cháo cá	Cháo cá	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
89	Cháo lươn	Cháo lươn	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
90	Cháo yến mạch	Cháo yến mạch	\N	breakfast	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
91	Gỏi gà bắp cải	Gỏi gà bắp cải	\N	salad	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
92	Gỏi ngó sen tôm thịt	Gỏi ngó sen tôm thịt	\N	salad	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
93	Gỏi đu đủ	Gỏi đu đủ	\N	salad	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
94	Salad rau củ	Salad rau củ	\N	salad	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
95	Cá thu nướng	Cá thu nướng	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
96	Gà nướng mật ong	Gà nướng mật ong	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
97	Sườn nướng	Sườn nướng	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
98	Tôm nướng	Tôm nướng	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
1012	Cháo gạo lứt rau củ	Cháo gạo lứt rau củ	\N	Breakfast	300.00	\N	t	t	\N	1	2025-12-05 04:49:18.48245	2025-12-05 05:32:39.556754	[]
99	Mực nướng sa tế	Mực nướng sa tế	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
100	Cá hấp xì dầu	Cá hấp xì dầu	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
101	Gà hấp lá chanh	Gà hấp lá chanh	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
102	Trứng hấp	Trứng hấp	\N	side_dish	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
103	Đậu phụ hấp nấm	Đậu phụ hấp nấm	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
104	Gà luộc	Gà luộc	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
105	Tôm luộc	Tôm luộc	\N	appetizer	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
106	Trứng luộc	Trứng luộc	\N	side_dish	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
1020	Khoai lang luộc	Khoai lang luộc	\N	Snack	200.00	\N	t	t	\N	1	2025-12-05 04:49:18.490145	2025-12-05 05:32:39.556754	[]
107	Rau luộc	Rau luộc	\N	side_dish	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
108	Khoai tây luộc	Khoai tây luộc	\N	snack	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
109	Ngô luộc	Ngô luộc	\N	snack	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
110	Cá kho tộ	Cá kho tộ	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
111	Thịt kho tàu	Thịt kho tàu	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
112	Gà kho gừng	Gà kho gừng	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
113	Đậu phụ kho	Đậu phụ kho	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
114	Cá chép kho riềng	Cá chép kho riềng	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
116	Chè bí đỏ	Chè bí đỏ	\N	dessert	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
118	Sinh tố chuối	Sinh tố chuối	\N	beverage	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
121	Nước ép ổi	Nước ép ổi	\N	beverage	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
122	Trái cây trộn	Trái cây trộn	\N	dessert	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
123	Đậu phụ sốt cà chua	Đậu phụ sốt cà chua	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
124	Rau củ xào chay	Rau củ xào chay	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
125	Cơm chiên chay	Cơm chiên chay	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
126	Canh rau củ chay	Canh rau củ chay	\N	soup	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
127	Bánh mì trứng	Bánh mì trứng	\N	breakfast	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
128	Xôi gà	Xôi gà	\N	breakfast	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
129	Xôi đậu xanh	Xôi đậu xanh	\N	breakfast	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
130	Sữa chua hoa quả	Sữa chua hoa quả	\N	breakfast	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
131	Miến xào hải sản	Miến xào hải sản	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
132	Nem rán	Nem rán	\N	appetizer	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
133	Chả giò	Chả giò	\N	appetizer	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
134	Bánh xèo	Bánh xèo	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
135	Bánh cuốn	Bánh cuốn	\N	breakfast	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
136	Hủ tiếu Nam Vang	Hủ tiếu Nam Vang	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
137	Mì Quảng	Mì Quảng	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
138	Cao lầu Hội An	Cao lầu Hội An	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
139	Bánh bèo	Bánh bèo	\N	snack	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
140	Bánh bột lọc	Bánh bột lọc	\N	snack	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
141	Bánh ít trần	Bánh ít trần	\N	snack	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
142	Chả cá Lã Vọng	Chả cá Lã Vọng	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
143	Bún thịt nướng	Bún thịt nướng	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
144	Bún cá	Bún cá	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
145	Súp bí đỏ	Súp bí đỏ	\N	soup	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
146	Súp gà nấm	Súp gà nấm	\N	soup	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
147	Lẩu thái	Lẩu thái	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
148	Lẩu gà lá é	Lẩu gà lá é	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
149	Bò nhúng dấm	Bò nhúng dấm	\N	main_course	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
150	Gỏi cuốn tôm thịt	Gỏi cuốn tôm thịt	\N	appetizer	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
151	Nem nướng	Nem nướng	\N	appetizer	100.00	\N	f	t	\N	1	2025-12-05 05:32:39.556754	2025-12-05 05:32:39.556754	[]
\.


--
-- TOC entry 6628 (class 0 OID 22746)
-- Dependencies: 354
-- Data for Name: dishimage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dishimage (dish_image_id, dish_id, image_url, image_type, is_primary, display_order, caption, uploaded_at) FROM stdin;
\.


--
-- TOC entry 6626 (class 0 OID 22716)
-- Dependencies: 352
-- Data for Name: dishingredient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dishingredient (dish_ingredient_id, dish_id, food_id, weight_g, notes, display_order) FROM stdin;
417	1	3008	250.00	Bánh phở tươi	1
418	1	3003	150.00	Thịt bò tái	2
419	1	3017	50.00	Rau thơm: hành, ngò	3
420	1	90	30.00	Giá đỗ	4
421	2	3013	200.00	Cơm tấm nấu chín	1
422	2	3019	100.00	Sườn heo nướng	2
423	2	3004	20.00	Dưa leo cắt lát	3
424	3	3014	150.00	Bánh mì que	1
425	3	3003	50.00	Pate gan	2
426	3	3017	30.00	Rau thơm, dưa chua	3
427	4	3020	200.00	Xôi nếp	1
428	4	3007	80.00	Gà luộc xé	2
429	5	3012	150.00	Bún tươi	1
430	5	3019	120.00	Chả/thịt nướng	2
431	5	3017	80.00	Rau sống: xà lách, húng	3
432	6	3015	120.00	Bánh tráng, bún, tôm	1
433	6	3017	40.00	Rau sống	2
434	7	3018	200.00	Cá nướng lá chuối	1
435	7	3017	50.00	Rau thơm	2
436	8	3019	200.00	Thịt ba chỉ kho trứng	1
437	9	3018	250.00	Cá kho	1
438	10	3016	400.00	Canh chua cá nấu sẵn	1
439	11	3008	250.00	Bánh phở	1
441	11	3017	50.00	Rau thơm	3
442	12	3017	200.00	Rau muống xào tỏi	1
444	13	3016	80.00	Sốt cà chua	2
445	14	3014	150.00	Vỏ bánh xèo	1
446	14	3019	50.00	Thịt heo	2
447	14	90	40.00	Giá đỗ	3
448	15	3015	100.00	Bánh tráng nướng	1
449	16	3008	250.00	Cơm/gạo nấu cháo	1
450	16	3007	80.00	Gà xé	2
451	17	3008	250.00	Gạo nấu cháo	1
452	17	3018	80.00	Cá	2
453	18	3009	100.00	Súp lơ xanh	1
454	18	3001	100.00	Rau bina	2
455	18	3017	100.00	Rau muống	3
456	19	3012	150.00	Bún tươi	1
457	19	3019	100.00	Thịt heo nướng	2
458	19	3017	50.00	Rau sống	3
459	20	3012	200.00	Bún bò	1
460	20	3003	120.00	Thịt bò chín	2
461	21	3015	100.00	Bánh tráng cuốn	1
462	21	3019	50.00	Thịt heo xay	2
463	22	3003	150.00	Thịt bò cuộn lá lốt	1
464	23	3003	120.00	Thịt bò	1
465	23	3009	80.00	Súp lơ xanh	2
466	24	3007	100.00	Gà xé	1
467	24	3017	100.00	Bắp cải, cà rốt	2
468	25	3014	200.00	Bánh cuốn	1
469	25	3019	50.00	Nhân thịt	2
470	26	3007	150.00	Gà	1
471	26	3014	100.00	Bánh mì	2
472	27	3012	150.00	Bún	1
474	28	3007	150.00	Vịt	1
475	28	3017	100.00	Măng, rau	2
476	29	3019	150.00	Sườn heo	1
477	29	3017	100.00	Củ cải, cà rốt	2
478	30	3009	80.00	Súp lơ	1
479	30	3017	80.00	Rau củ khác	2
480	59	3041	1000.00	\N	0
440	11	38	100.00	Đậu hũ	2
443	13	38	150.00	Đậu hũ chiên	1
473	27	38	100.00	Đậu hũ chiên	2
481	60	1	100.00	\N	0
482	61	6	100.00	\N	0
483	62	1	50.00	\N	0
484	62	6	50.00	\N	0
485	1000	9	150.00	\N	0
486	1000	43	150.00	\N	1
487	1001	9	100.00	\N	0
488	1001	11	100.00	\N	1
489	1002	9	125.00	\N	0
490	1002	38	125.00	\N	1
491	1003	43	150.00	\N	0
492	1003	9	150.00	\N	1
493	1004	43	150.00	\N	0
494	1005	9	100.00	\N	0
495	1005	43	100.00	\N	1
496	1006	11	200.00	\N	0
497	1007	12	250.00	\N	0
498	1008	43	100.00	\N	0
499	1008	9	100.00	\N	1
500	1009	9	125.00	\N	0
501	1009	43	125.00	\N	1
502	1010	43	150.00	\N	0
503	1010	9	150.00	\N	1
504	1011	11	125.00	\N	0
505	1011	43	125.00	\N	1
508	1013	43	250.00	\N	0
509	1014	9	100.00	\N	0
510	1014	43	100.00	\N	1
511	1015	43	150.00	\N	0
512	1015	9	150.00	\N	1
513	1016	11	200.00	\N	0
514	1017	43	150.00	\N	0
515	1018	12	150.00	\N	0
516	1018	9	150.00	\N	1
517	1019	43	250.00	\N	0
519	1021	38	150.00	\N	0
520	1022	9	125.00	\N	0
521	1022	43	125.00	\N	1
524	1024	11	150.00	\N	0
525	1024	43	150.00	\N	1
526	1025	12	200.00	\N	0
527	1026	12	250.00	\N	0
529	1028	9	150.00	\N	0
530	1029	9	100.00	\N	0
531	64	3088	200.00	\N	0
532	64	3043	100.00	\N	0
533	64	3092	20.00	\N	0
534	64	3094	5.00	\N	0
535	64	50	30.00	\N	0
536	65	3087	200.00	\N	0
537	65	3043	80.00	\N	0
538	65	3042	50.00	\N	0
539	65	3092	20.00	\N	0
540	65	3094	5.00	\N	0
541	66	3087	200.00	\N	0
542	66	3042	120.00	\N	0
543	66	50	50.00	\N	0
544	66	3056	30.00	\N	0
545	67	3088	200.00	\N	0
546	67	3092	20.00	\N	0
547	67	3094	5.00	\N	0
548	67	50	30.00	\N	0
549	68	3087	200.00	\N	0
550	68	3105	50.00	\N	0
551	68	3068	100.00	\N	0
552	68	50	40.00	\N	0
553	69	3106	150.00	\N	0
554	69	3042	100.00	\N	0
555	69	3056	30.00	\N	0
556	70	3106	150.00	\N	0
557	70	3094	5.00	\N	0
558	70	3092	15.00	\N	0
559	71	3106	150.00	\N	0
560	71	3049	60.00	\N	0
561	71	3042	40.00	\N	0
562	71	3056	30.00	\N	0
563	72	3106	150.00	\N	0
564	72	3094	8.00	\N	0
565	72	3092	15.00	\N	0
566	73	3083	150.00	\N	0
567	74	3043	120.00	\N	0
568	74	50	150.00	\N	0
569	74	3093	10.00	\N	0
570	74	3092	30.00	\N	0
571	75	3092	40.00	\N	0
572	75	3093	10.00	\N	0
573	75	3065	30.00	\N	0
574	76	50	200.00	\N	0
575	76	3093	15.00	\N	0
576	77	3059	200.00	\N	0
577	77	3093	10.00	\N	0
578	78	3068	200.00	\N	0
579	78	3092	30.00	\N	0
580	78	3093	10.00	\N	0
581	79	3042	150.00	\N	0
582	79	3092	80.00	\N	0
583	79	3093	10.00	\N	0
584	80	3051	150.00	\N	0
585	80	3065	50.00	\N	0
586	80	3092	40.00	\N	0
587	81	3049	150.00	\N	0
588	81	3093	10.00	\N	0
589	81	3094	5.00	\N	0
590	82	3046	120.00	\N	0
591	82	3055	100.00	\N	0
592	82	50	50.00	\N	0
593	1027	3054	200.00	\N	0
594	1027	3092	30.00	\N	0
595	1023	3053	150.00	\N	0
596	1023	3050	80.00	\N	0
597	1023	3093	5.00	\N	0
598	83	3059	150.00	\N	0
599	83	3042	80.00	\N	0
600	83	3092	20.00	\N	0
601	84	3064	150.00	\N	0
602	84	3042	100.00	\N	0
603	84	3092	20.00	\N	0
604	85	3052	150.00	\N	0
605	85	50	80.00	\N	0
606	85	3094	5.00	\N	0
607	86	3045	120.00	\N	0
608	86	3092	30.00	\N	0
609	86	50	50.00	\N	0
610	87	3106	60.00	\N	0
611	87	3094	5.00	\N	0
612	88	3106	60.00	\N	0
613	88	3046	80.00	\N	0
614	88	3094	5.00	\N	0
615	89	3106	60.00	\N	0
616	89	3094	8.00	\N	0
617	89	3092	15.00	\N	0
618	90	3084	80.00	\N	0
619	90	3099	100.00	\N	0
620	90	3072	50.00	\N	0
621	1012	3082	60.00	\N	0
622	1012	3056	50.00	\N	0
623	1012	3054	50.00	\N	0
624	91	3059	100.00	\N	0
625	91	3056	50.00	\N	0
626	91	3092	30.00	\N	0
627	92	3049	80.00	\N	0
628	92	3042	60.00	\N	0
629	92	3056	50.00	\N	0
630	93	3074	150.00	\N	0
631	93	3056	50.00	\N	0
632	93	3050	60.00	\N	0
633	94	3059	80.00	\N	0
634	94	3056	50.00	\N	0
635	94	3065	40.00	\N	0
636	94	3092	20.00	\N	0
637	95	3048	150.00	\N	0
638	95	3094	5.00	\N	0
639	96	3093	10.00	\N	0
640	96	3094	5.00	\N	0
641	97	3042	150.00	\N	0
642	97	3093	10.00	\N	0
643	97	3092	20.00	\N	0
644	98	3049	150.00	\N	0
645	98	3093	5.00	\N	0
646	99	3051	150.00	\N	0
647	99	3093	10.00	\N	0
648	99	3065	30.00	\N	0
649	100	3045	150.00	\N	0
650	100	3094	8.00	\N	0
651	100	3092	20.00	\N	0
652	101	3094	5.00	\N	0
653	102	3092	10.00	\N	0
654	103	3068	200.00	\N	0
655	103	3095	80.00	\N	0
656	103	3093	5.00	\N	0
657	104	3094	5.00	\N	0
658	105	3049	150.00	\N	0
659	107	3059	100.00	\N	0
660	107	3056	50.00	\N	0
661	107	3054	50.00	\N	0
662	1020	3057	200.00	\N	0
663	108	3058	200.00	\N	0
664	109	3089	200.00	\N	0
665	110	3046	150.00	\N	0
666	110	3092	30.00	\N	0
667	110	3093	10.00	\N	0
668	111	3042	150.00	\N	0
669	111	3105	100.00	\N	0
670	111	3093	10.00	\N	0
671	112	3094	15.00	\N	0
672	112	3092	30.00	\N	0
673	113	3068	200.00	\N	0
674	113	3092	30.00	\N	0
675	114	3047	150.00	\N	0
676	114	3094	15.00	\N	0
677	114	3092	30.00	\N	0
680	116	3054	150.00	\N	0
681	116	3099	100.00	\N	0
683	118	3072	150.00	\N	0
684	118	3099	150.00	\N	0
686	121	3075	200.00	\N	0
687	122	3074	80.00	\N	0
688	122	3072	80.00	\N	0
689	122	3075	80.00	\N	0
690	123	3068	200.00	\N	0
691	123	3092	40.00	\N	0
692	123	3093	10.00	\N	0
693	124	3059	100.00	\N	0
694	124	3056	80.00	\N	0
695	124	3054	80.00	\N	0
696	124	3095	60.00	\N	0
697	125	3082	150.00	\N	0
698	125	3056	50.00	\N	0
699	125	3066	50.00	\N	0
700	125	3089	50.00	\N	0
701	126	3054	100.00	\N	0
702	126	3056	80.00	\N	0
703	126	3063	80.00	\N	0
704	126	3095	50.00	\N	0
705	127	3056	30.00	\N	0
706	128	3083	150.00	\N	0
707	128	3092	20.00	\N	0
708	129	3083	150.00	\N	0
709	129	3069	80.00	\N	0
710	130	3072	50.00	\N	0
711	130	3075	50.00	\N	0
712	131	3049	80.00	\N	0
713	131	3051	80.00	\N	0
714	131	3056	50.00	\N	0
715	131	3059	50.00	\N	0
716	132	3042	100.00	\N	0
717	132	3056	50.00	\N	0
718	132	3095	40.00	\N	0
719	133	3042	80.00	\N	0
720	133	3050	60.00	\N	0
721	133	3056	40.00	\N	0
722	133	3095	30.00	\N	0
723	134	3086	100.00	\N	0
724	134	3049	60.00	\N	0
725	134	3042	50.00	\N	0
726	134	50	50.00	\N	0
727	135	3086	100.00	\N	0
728	135	3042	60.00	\N	0
729	135	3095	40.00	\N	0
730	136	3087	200.00	\N	0
731	136	3042	80.00	\N	0
732	136	3050	60.00	\N	0
733	136	3051	40.00	\N	0
734	137	3042	80.00	\N	0
735	137	3049	60.00	\N	0
736	137	50	40.00	\N	0
737	138	3042	100.00	\N	0
738	138	50	60.00	\N	0
739	138	3092	30.00	\N	0
740	139	3086	80.00	\N	0
741	139	3050	40.00	\N	0
742	140	3049	60.00	\N	0
743	140	3042	40.00	\N	0
744	141	3083	100.00	\N	0
745	141	3069	60.00	\N	0
746	142	3046	150.00	\N	0
747	142	50	80.00	\N	0
748	142	3092	30.00	\N	0
749	142	3093	10.00	\N	0
750	143	3087	200.00	\N	0
751	143	3042	120.00	\N	0
752	143	50	50.00	\N	0
753	143	3056	30.00	\N	0
754	144	3087	200.00	\N	0
755	144	3046	100.00	\N	0
756	144	50	50.00	\N	0
757	145	3054	200.00	\N	0
758	145	3099	100.00	\N	0
759	145	3092	30.00	\N	0
760	146	3095	80.00	\N	0
761	146	3056	50.00	\N	0
762	147	3049	100.00	\N	0
763	147	3051	80.00	\N	0
764	147	3095	60.00	\N	0
765	147	50	50.00	\N	0
766	148	3095	80.00	\N	0
767	148	50	60.00	\N	0
768	149	3043	150.00	\N	0
769	149	50	80.00	\N	0
770	149	3059	60.00	\N	0
771	150	3049	80.00	\N	0
772	150	3042	60.00	\N	0
773	150	3087	50.00	\N	0
774	150	50	40.00	\N	0
775	151	3042	120.00	\N	0
776	151	3093	10.00	\N	0
\.


--
-- TOC entry 6634 (class 0 OID 22843)
-- Dependencies: 362
-- Data for Name: dishnotification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dishnotification (notification_id, user_id, dish_id, notification_type, title, message, is_read, created_at, read_at) FROM stdin;
\.


--
-- TOC entry 6632 (class 0 OID 22797)
-- Dependencies: 358
-- Data for Name: dishnutrient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dishnutrient (dish_nutrient_id, dish_id, nutrient_id, amount_per_100g, calculated_at) FROM stdin;
6695	1	29	1.955833	2025-12-05 05:43:22.118523
6696	1	4	14.947917	2025-12-05 05:43:22.118523
6697	1	30	1.250000	2025-12-05 05:43:22.118523
6698	1	14	34.406250	2025-12-05 05:43:22.118523
6699	1	2	8.270208	2025-12-05 05:43:22.118523
6700	1	15	6.241667	2025-12-05 05:43:22.118523
6701	1	26	6.250000	2025-12-05 05:43:22.118523
6702	1	23	25.968750	2025-12-05 05:43:22.118523
6703	1	24	13.875000	2025-12-05 05:43:22.118523
6704	2	29	0.687500	2025-12-05 05:43:22.118523
6705	2	4	21.737500	2025-12-05 05:43:22.118523
6706	2	3	7.156250	2025-12-05 05:43:22.118523
6707	2	28	462.500000	2025-12-05 05:43:22.118523
6708	2	2	9.187500	2025-12-05 05:43:22.118523
6709	2	15	0.543750	2025-12-05 05:43:22.118523
6710	2	26	1.687500	2025-12-05 05:43:22.118523
6711	2	27	22.375000	2025-12-05 05:43:22.118523
6712	2	24	10.937500	2025-12-05 05:43:22.118523
6713	3	29	2.173913	2025-12-05 05:43:22.118523
6714	3	4	16.826087	2025-12-05 05:43:22.118523
6715	3	30	0.869565	2025-12-05 05:43:22.118523
6716	3	14	40.695652	2025-12-05 05:43:22.118523
6717	3	3	4.891304	2025-12-05 05:43:22.118523
6718	3	2	10.100000	2025-12-05 05:43:22.118523
6719	3	15	7.173913	2025-12-05 05:43:22.118523
6720	3	23	18.065217	2025-12-05 05:43:22.118523
6721	3	24	43.347826	2025-12-05 05:43:22.118523
6722	4	29	0.228571	2025-12-05 05:43:22.118523
6723	4	2	8.428571	2025-12-05 05:43:22.118523
6724	4	4	25.142857	2025-12-05 05:43:22.118523
6725	4	12	150.285714	2025-12-05 05:43:22.118523
6726	4	26	12.857143	2025-12-05 05:43:22.118523
6727	4	27	103.714286	2025-12-05 05:43:22.118523
6728	4	3	1.071429	2025-12-05 05:43:22.118523
6729	4	23	0.914286	2025-12-05 05:43:22.118523
6730	5	29	2.097143	2025-12-05 05:43:22.118523
6731	5	4	7.928571	2025-12-05 05:43:22.118523
6732	5	14	71.314286	2025-12-05 05:43:22.118523
6733	5	3	7.928571	2025-12-05 05:43:22.118523
6734	5	28	469.714286	2025-12-05 05:43:22.118523
6735	5	2	11.282857	2025-12-05 05:43:22.118523
6736	5	15	12.571429	2025-12-05 05:43:22.118523
6737	5	24	34.628571	2025-12-05 05:43:22.118523
6738	6	29	0.625000	2025-12-05 05:43:22.118523
6739	6	5	2.100000	2025-12-05 05:43:22.118523
6740	6	4	9.225000	2025-12-05 05:43:22.118523
6741	6	2	4.775000	2025-12-05 05:43:22.118523
6742	6	15	25.000000	2025-12-05 05:43:22.118523
6743	6	14	78.000000	2025-12-05 05:43:22.118523
6744	6	3	1.575000	2025-12-05 05:43:22.118523
6745	6	24	24.750000	2025-12-05 05:43:22.118523
6746	7	29	0.500000	2025-12-05 05:43:22.118523
6747	7	2	15.320000	2025-12-05 05:43:22.118523
6748	7	15	11.000000	2025-12-05 05:43:22.118523
6749	7	14	62.400000	2025-12-05 05:43:22.118523
6750	7	3	5.200000	2025-12-05 05:43:22.118523
6751	7	27	256.000000	2025-12-05 05:43:22.118523
6752	7	23	2.000000	2025-12-05 05:43:22.118523
6753	7	28	680.000000	2025-12-05 05:43:22.118523
6754	7	24	19.800000	2025-12-05 05:43:22.118523
6755	8	2	15.800000	2025-12-05 05:43:22.118523
6756	8	3	12.500000	2025-12-05 05:43:22.118523
6757	8	24	35.000000	2025-12-05 05:43:22.118523
6758	8	28	720.000000	2025-12-05 05:43:22.118523
6759	8	29	2.200000	2025-12-05 05:43:22.118523
6760	9	2	18.500000	2025-12-05 05:43:22.118523
6761	9	3	6.500000	2025-12-05 05:43:22.118523
6762	9	23	2.500000	2025-12-05 05:43:22.118523
6763	9	27	320.000000	2025-12-05 05:43:22.118523
6764	9	28	850.000000	2025-12-05 05:43:22.118523
6765	10	2	6.500000	2025-12-05 05:43:22.118523
6766	10	15	25.000000	2025-12-05 05:43:22.118523
6767	10	27	280.000000	2025-12-05 05:43:22.118523
6768	10	28	420.000000	2025-12-05 05:43:22.118523
6769	11	29	0.437500	2025-12-05 05:43:22.118523
6770	11	4	17.937500	2025-12-05 05:43:22.118523
6771	11	14	39.000000	2025-12-05 05:43:22.118523
6772	11	28	0.445000	2025-12-05 05:43:22.118523
6773	11	2	2.012500	2025-12-05 05:43:22.118523
6774	11	15	10.857500	2025-12-05 05:43:22.118523
6775	11	26	15.827500	2025-12-05 05:43:22.118523
6776	11	27	0.472500	2025-12-05 05:43:22.118523
6777	11	24	12.375000	2025-12-05 05:43:22.118523
6778	12	2	2.600000	2025-12-05 05:43:22.118523
6779	12	14	312.000000	2025-12-05 05:43:22.118523
6780	12	15	55.000000	2025-12-05 05:43:22.118523
6781	12	24	99.000000	2025-12-05 05:43:22.118523
6782	12	29	2.500000	2025-12-05 05:43:22.118523
6783	13	2	2.260870	2025-12-05 05:43:22.118523
6784	13	15	19.084783	2025-12-05 05:43:22.118523
6785	13	26	21.723913	2025-12-05 05:43:22.118523
6786	13	27	98.623913	2025-12-05 05:43:22.118523
4154	31	1	88.000000	2025-12-01 00:23:21.524376
4155	31	2	9.000000	2025-12-01 00:23:21.524376
4156	31	3	2.800000	2025-12-01 00:23:21.524376
4157	31	4	13.500000	2025-12-01 00:23:21.524376
4158	31	28	450.000000	2025-12-01 00:23:21.524376
4159	31	29	1.500000	2025-12-01 00:23:21.524376
4160	32	1	155.000000	2025-12-01 00:23:21.524376
4161	32	2	8.500000	2025-12-01 00:23:21.524376
4162	32	3	7.500000	2025-12-01 00:23:21.524376
4163	32	4	18.000000	2025-12-01 00:23:21.524376
4164	32	28	380.000000	2025-12-01 00:23:21.524376
4165	33	1	175.000000	2025-12-01 00:23:21.524376
4166	33	2	13.000000	2025-12-01 00:23:21.524376
4167	33	3	8.000000	2025-12-01 00:23:21.524376
4168	33	4	22.500000	2025-12-01 00:23:21.524376
4169	33	27	320.000000	2025-12-01 00:23:21.524376
4170	33	28	520.000000	2025-12-01 00:23:21.524376
6787	13	28	147.247826	2025-12-05 05:43:22.118523
6788	14	29	1.368333	2025-12-05 05:43:22.118523
6789	14	4	16.125000	2025-12-05 05:43:22.118523
6790	14	14	5.083333	2025-12-05 05:43:22.118523
6791	14	3	7.291667	2025-12-05 05:43:22.118523
4176	35	1	165.000000	2025-12-01 00:23:21.524376
4177	35	2	19.500000	2025-12-01 00:23:21.524376
4178	35	3	8.500000	2025-12-01 00:23:21.524376
4179	35	4	5.500000	2025-12-01 00:23:21.524376
4180	35	29	1.800000	2025-12-01 00:23:21.524376
4181	36	1	135.000000	2025-12-01 00:23:21.524376
4182	36	2	12.000000	2025-12-01 00:23:21.524376
4183	36	3	5.500000	2025-12-01 00:23:21.524376
4184	36	4	18.000000	2025-12-01 00:23:21.524376
4185	36	23	1.500000	2025-12-01 00:23:21.524376
4186	36	28	550.000000	2025-12-01 00:23:21.524376
4187	37	1	155.000000	2025-12-01 00:23:21.524376
4188	37	2	9.500000	2025-12-01 00:23:21.524376
4189	37	3	10.500000	2025-12-01 00:23:21.524376
4190	37	4	8.000000	2025-12-01 00:23:21.524376
4191	37	24	120.000000	2025-12-01 00:23:21.524376
4192	38	1	185.000000	2025-12-01 00:23:21.524376
4193	38	2	16.500000	2025-12-01 00:23:21.524376
4194	38	3	11.000000	2025-12-01 00:23:21.524376
4195	38	4	9.500000	2025-12-01 00:23:21.524376
4196	38	28	480.000000	2025-12-01 00:23:21.524376
6792	14	28	150.000000	2025-12-05 05:43:22.118523
6793	14	2	9.081667	2025-12-05 05:43:22.118523
6794	14	15	1.366667	2025-12-05 05:43:22.118523
6795	14	24	40.750000	2025-12-05 05:43:22.118523
6796	15	2	5.500000	2025-12-05 05:43:22.118523
6797	15	3	2.100000	2025-12-05 05:43:22.118523
6798	15	4	12.300000	2025-12-05 05:43:22.118523
6799	15	5	2.800000	2025-12-05 05:43:22.118523
6800	15	15	15.000000	2025-12-05 05:43:22.118523
6801	16	29	0.345455	2025-12-05 05:43:22.118523
6802	16	4	21.742424	2025-12-05 05:43:22.118523
6803	16	2	6.893939	2025-12-05 05:43:22.118523
6804	16	26	9.090909	2025-12-05 05:43:22.118523
6805	16	12	127.515152	2025-12-05 05:43:22.118523
6806	16	27	88.000000	2025-12-05 05:43:22.118523
6807	16	23	0.775758	2025-12-05 05:43:22.118523
6808	17	29	0.151515	2025-12-05 05:43:22.118523
6809	17	4	21.742424	2025-12-05 05:43:22.118523
6810	17	2	6.530303	2025-12-05 05:43:22.118523
6811	17	26	9.090909	2025-12-05 05:43:22.118523
6812	17	3	1.575758	2025-12-05 05:43:22.118523
6813	17	27	77.575758	2025-12-05 05:43:22.118523
6814	17	23	0.606061	2025-12-05 05:43:22.118523
6815	17	28	206.060606	2025-12-05 05:43:22.118523
6816	18	29	2.266667	2025-12-05 05:43:22.118523
6817	18	14	302.200000	2025-12-05 05:43:22.118523
6818	18	2	1.856667	2025-12-05 05:43:22.118523
6819	18	15	48.066667	2025-12-05 05:43:22.118523
6820	18	26	36.000000	2025-12-05 05:43:22.118523
6821	18	27	155.333333	2025-12-05 05:43:22.118523
6822	18	24	94.000000	2025-12-05 05:43:22.118523
6823	19	29	2.050000	2025-12-05 05:43:22.118523
6824	19	4	9.250000	2025-12-05 05:43:22.118523
6825	19	14	52.000000	2025-12-05 05:43:22.118523
6826	19	3	8.416667	2025-12-05 05:43:22.118523
6827	19	28	500.000000	2025-12-05 05:43:22.118523
6828	19	2	11.850000	2025-12-05 05:43:22.118523
6829	19	15	9.166667	2025-12-05 05:43:22.118523
6830	19	24	28.166667	2025-12-05 05:43:22.118523
6831	20	29	2.962500	2025-12-05 05:43:22.118523
6832	20	4	11.562500	2025-12-05 05:43:22.118523
6833	20	2	15.300000	2025-12-05 05:43:22.118523
6834	20	30	1.500000	2025-12-05 05:43:22.118523
6835	20	3	5.312500	2025-12-05 05:43:22.118523
6836	20	23	31.162500	2025-12-05 05:43:22.118523
6837	20	28	325.000000	2025-12-05 05:43:22.118523
6838	20	24	1.875000	2025-12-05 05:43:22.118523
6839	21	29	0.733333	2025-12-05 05:43:22.118523
6840	21	5	1.866667	2025-12-05 05:43:22.118523
6841	21	4	8.200000	2025-12-05 05:43:22.118523
6842	21	2	8.933333	2025-12-05 05:43:22.118523
6843	21	15	10.000000	2025-12-05 05:43:22.118523
6844	21	3	5.566667	2025-12-05 05:43:22.118523
6845	21	28	240.000000	2025-12-05 05:43:22.118523
6846	21	24	11.666667	2025-12-05 05:43:22.118523
6847	22	2	20.300000	2025-12-05 05:43:22.118523
6848	22	23	83.100000	2025-12-05 05:43:22.118523
6849	22	24	5.000000	2025-12-05 05:43:22.118523
6850	22	29	4.900000	2025-12-05 05:43:22.118523
6851	22	30	4.000000	2025-12-05 05:43:22.118523
6852	23	29	3.232000	2025-12-05 05:43:22.118523
6853	23	2	12.180000	2025-12-05 05:43:22.118523
6854	23	15	35.680000	2025-12-05 05:43:22.118523
6855	23	30	2.400000	2025-12-05 05:43:22.118523
6856	23	26	8.400000	2025-12-05 05:43:22.118523
6857	23	14	40.640000	2025-12-05 05:43:22.118523
6858	23	23	49.860000	2025-12-05 05:43:22.118523
6859	23	24	21.800000	2025-12-05 05:43:22.118523
6860	24	29	1.650000	2025-12-05 05:43:22.118523
6861	24	2	11.300000	2025-12-05 05:43:22.118523
6862	24	15	27.500000	2025-12-05 05:43:22.118523
6863	24	12	263.000000	2025-12-05 05:43:22.118523
6864	24	14	156.000000	2025-12-05 05:43:22.118523
6865	24	27	181.500000	2025-12-05 05:43:22.118523
6866	24	23	1.600000	2025-12-05 05:43:22.118523
6867	24	24	49.500000	2025-12-05 05:43:22.118523
6868	25	29	1.400000	2025-12-05 05:43:22.118523
6869	25	2	9.720000	2025-12-05 05:43:22.118523
6870	25	4	20.640000	2025-12-05 05:43:22.118523
6871	25	3	8.500000	2025-12-05 05:43:22.118523
6872	25	28	144.000000	2025-12-05 05:43:22.118523
6873	25	24	43.000000	2025-12-05 05:43:22.118523
6874	26	29	0.960000	2025-12-05 05:43:22.118523
6875	26	2	15.280000	2025-12-05 05:43:22.118523
6876	26	4	10.320000	2025-12-05 05:43:22.118523
6877	26	12	315.600000	2025-12-05 05:43:22.118523
6878	26	27	217.800000	2025-12-05 05:43:22.118523
6879	26	3	3.000000	2025-12-05 05:43:22.118523
6880	26	23	1.920000	2025-12-05 05:43:22.118523
6881	26	24	18.000000	2025-12-05 05:43:22.118523
6882	27	29	1.080000	2025-12-05 05:43:22.118523
6883	27	4	11.100000	2025-12-05 05:43:22.118523
6884	27	2	7.380000	2025-12-05 05:43:22.118523
6885	27	15	6.372000	2025-12-05 05:43:22.118523
6886	27	26	13.324000	2025-12-05 05:43:22.118523
6887	27	3	5.100000	2025-12-05 05:43:22.118523
6888	27	27	0.756000	2025-12-05 05:43:22.118523
6889	27	28	312.712000	2025-12-05 05:43:22.118523
6890	28	29	1.480000	2025-12-05 05:43:22.118523
6891	28	2	13.040000	2025-12-05 05:43:22.118523
6892	28	15	22.000000	2025-12-05 05:43:22.118523
6893	28	12	315.600000	2025-12-05 05:43:22.118523
6894	28	14	124.800000	2025-12-05 05:43:22.118523
6895	28	27	217.800000	2025-12-05 05:43:22.118523
6896	28	23	1.920000	2025-12-05 05:43:22.118523
6897	28	24	39.600000	2025-12-05 05:43:22.118523
6898	29	29	2.320000	2025-12-05 05:43:22.118523
6899	29	2	10.520000	2025-12-05 05:43:22.118523
6900	29	15	22.000000	2025-12-05 05:43:22.118523
6901	29	14	124.800000	2025-12-05 05:43:22.118523
6902	29	3	7.500000	2025-12-05 05:43:22.118523
6903	29	28	432.000000	2025-12-05 05:43:22.118523
6904	29	24	60.600000	2025-12-05 05:43:22.118523
6905	30	29	1.615000	2025-12-05 05:43:22.118523
6906	30	2	1.300000	2025-12-05 05:43:22.118523
6907	30	15	72.100000	2025-12-05 05:43:22.118523
6908	30	26	10.500000	2025-12-05 05:43:22.118523
6909	30	14	206.800000	2025-12-05 05:43:22.118523
6910	30	24	73.000000	2025-12-05 05:43:22.118523
6911	59	1	2000.000000	2025-12-05 05:43:22.118523
6912	59	2	50.000000	2025-12-05 05:43:22.118523
6913	59	3	70.000000	2025-12-05 05:43:22.118523
6914	59	4	250.000000	2025-12-05 05:43:22.118523
6915	59	5	200.000000	2025-12-05 05:43:22.118523
6916	59	6	56.000000	2025-12-05 05:43:22.118523
6917	59	7	120.000000	2025-12-05 05:43:22.118523
6918	59	8	80.000000	2025-12-05 05:43:22.118523
6919	59	9	24.000000	2025-12-05 05:43:22.118523
6920	59	11	8100.000000	2025-12-05 05:43:22.118523
6921	59	12	800.000000	2025-12-05 05:43:22.118523
6922	59	13	120.000000	2025-12-05 05:43:22.118523
6923	59	14	1080.000000	2025-12-05 05:43:22.118523
6924	59	15	720.000000	2025-12-05 05:43:22.118523
6925	59	16	10.000000	2025-12-05 05:43:22.118523
6926	59	17	11.700000	2025-12-05 05:43:22.118523
6927	59	18	128.000000	2025-12-05 05:43:22.118523
6928	59	19	41.800000	2025-12-05 05:43:22.118523
6929	59	20	10.900000	2025-12-05 05:43:22.118523
6930	59	21	251.000000	2025-12-05 05:43:22.118523
6931	59	22	3344.000000	2025-12-05 05:43:22.118523
6932	59	23	20.100000	2025-12-05 05:43:22.118523
6933	59	24	8216.000000	2025-12-05 05:43:22.118523
6934	59	25	5600.000000	2025-12-05 05:43:22.118523
6935	59	26	2547.000000	2025-12-05 05:43:22.118523
6936	59	27	28000.000000	2025-12-05 05:43:22.118523
6937	59	28	18400.000000	2025-12-05 05:43:22.118523
6938	59	29	147.900000	2025-12-05 05:43:22.118523
6939	59	30	99.000000	2025-12-05 05:43:22.118523
6940	59	31	7.390000	2025-12-05 05:43:22.118523
6941	59	32	18.900000	2025-12-05 05:43:22.118523
6942	59	33	1350.000000	2025-12-05 05:43:22.118523
6943	59	34	440.000000	2025-12-05 05:43:22.118523
6944	59	35	287.600000	2025-12-05 05:43:22.118523
6945	59	36	405.000000	2025-12-05 05:43:22.118523
6946	59	37	24.600000	2025-12-05 05:43:22.118523
6947	59	38	22.200000	2025-12-05 05:43:22.118523
6948	59	39	13.300000	2025-12-05 05:43:22.118523
6949	59	40	17.800000	2025-12-05 05:43:22.118523
6950	59	41	0.000000	2025-12-05 05:43:22.118523
6951	59	42	1.600000	2025-12-05 05:43:22.118523
6952	59	43	1.600000	2025-12-05 05:43:22.118523
6953	59	44	3.200000	2025-12-05 05:43:22.118523
6954	59	45	8.900000	2025-12-05 05:43:22.118523
6955	59	46	1.600000	2025-12-05 05:43:22.118523
6956	59	47	1.120000	2025-12-05 05:43:22.118523
6957	59	48	1.520000	2025-12-05 05:43:22.118523
6958	59	49	3.360000	2025-12-05 05:43:22.118523
6959	59	50	2.400000	2025-12-05 05:43:22.118523
6960	59	51	1.200000	2025-12-05 05:43:22.118523
6961	59	52	2.000000	2025-12-05 05:43:22.118523
6962	59	53	1.200000	2025-12-05 05:43:22.118523
6963	59	54	0.320000	2025-12-05 05:43:22.118523
6964	59	55	2.080000	2025-12-05 05:43:22.118523
6965	60	2	20.300000	2025-12-05 05:43:22.118523
6966	60	3	21.770000	2025-12-05 05:43:22.118523
6967	60	5	22.830000	2025-12-05 05:43:22.118523
6968	60	14	41.920000	2025-12-05 05:43:22.118523
6969	60	24	21.830000	2025-12-05 05:43:22.118523
6970	60	28	47.000000	2025-12-05 05:43:22.118523
6971	60	29	29.850000	2025-12-05 05:43:22.118523
6972	60	30	26.860000	2025-12-05 05:43:22.118523
6973	61	2	33.650000	2025-12-05 05:43:22.118523
6974	61	4	7.540000	2025-12-05 05:43:22.118523
6975	61	14	33.190000	2025-12-05 05:43:22.118523
6976	61	30	34.350000	2025-12-05 05:43:22.118523
6977	62	29	14.925000	2025-12-05 05:43:22.118523
6978	62	5	11.415000	2025-12-05 05:43:22.118523
6979	62	2	26.975000	2025-12-05 05:43:22.118523
6980	62	4	3.770000	2025-12-05 05:43:22.118523
6981	62	30	30.605000	2025-12-05 05:43:22.118523
6982	62	14	37.555000	2025-12-05 05:43:22.118523
6983	62	3	10.885000	2025-12-05 05:43:22.118523
6984	62	28	23.500000	2025-12-05 05:43:22.118523
6985	62	24	10.915000	2025-12-05 05:43:22.118523
6986	64	29	0.732394	2025-12-05 05:43:22.118523
6987	64	4	15.366197	2025-12-05 05:43:22.118523
6988	64	10	17.464789	2025-12-05 05:43:22.118523
6989	64	15	0.487324	2025-12-05 05:43:22.118523
6990	64	26	3.380282	2025-12-05 05:43:22.118523
6991	64	25	21.408451	2025-12-05 05:43:22.118523
6992	64	30	1.267606	2025-12-05 05:43:22.118523
6993	64	3	2.946479	2025-12-05 05:43:22.118523
6994	64	1	114.647887	2025-12-05 05:43:22.118523
6995	64	5	0.405634	2025-12-05 05:43:22.118523
6996	64	2	6.622535	2025-12-05 05:43:22.118523
6997	64	27	14.070423	2025-12-05 05:43:22.118523
6998	64	23	0.732394	2025-12-05 05:43:22.118523
6999	65	29	0.712676	2025-12-05 05:43:22.118523
7000	65	4	14.859155	2025-12-05 05:43:22.118523
7001	65	10	22.422535	2025-12-05 05:43:22.118523
7002	65	15	0.487324	2025-12-05 05:43:22.118523
7003	65	26	3.943662	2025-12-05 05:43:22.118523
7004	65	25	24.225352	2025-12-05 05:43:22.118523
7005	65	30	1.295775	2025-12-05 05:43:22.118523
7006	65	3	3.315493	2025-12-05 05:43:22.118523
7007	65	1	124.816901	2025-12-05 05:43:22.118523
7008	65	5	0.518310	2025-12-05 05:43:22.118523
7009	65	2	8.495775	2025-12-05 05:43:22.118523
7010	65	27	14.070423	2025-12-05 05:43:22.118523
7011	65	23	0.585915	2025-12-05 05:43:22.118523
7012	66	25	21.500000	2025-12-05 05:43:22.118523
7013	66	29	0.270000	2025-12-05 05:43:22.118523
7014	66	4	13.220000	2025-12-05 05:43:22.118523
7015	66	30	0.600000	2025-12-05 05:43:22.118523
7016	66	3	2.005000	2025-12-05 05:43:22.118523
7017	66	10	18.000000	2025-12-05 05:43:22.118523
7018	66	1	100.475000	2025-12-05 05:43:22.118523
7019	66	5	0.560000	2025-12-05 05:43:22.118523
7020	66	2	7.117500	2025-12-05 05:43:22.118523
7021	66	15	0.442500	2025-12-05 05:43:22.118523
7022	66	26	3.500000	2025-12-05 05:43:22.118523
7023	66	27	24.000000	2025-12-05 05:43:22.118523
7024	66	24	2.475000	2025-12-05 05:43:22.118523
7025	66	11	1252.950000	2025-12-05 05:43:22.118523
7026	67	25	29.803922	2025-12-05 05:43:22.118523
7027	67	4	21.392157	2025-12-05 05:43:22.118523
7028	67	3	0.101961	2025-12-05 05:43:22.118523
7029	67	1	90.196078	2025-12-05 05:43:22.118523
7030	67	5	0.564706	2025-12-05 05:43:22.118523
7031	67	2	1.376471	2025-12-05 05:43:22.118523
7032	67	15	0.678431	2025-12-05 05:43:22.118523
7033	67	26	4.705882	2025-12-05 05:43:22.118523
7034	67	27	19.588235	2025-12-05 05:43:22.118523
7035	68	25	22.051282	2025-12-05 05:43:22.118523
7036	68	29	1.051282	2025-12-05 05:43:22.118523
7037	68	4	13.756410	2025-12-05 05:43:22.118523
7038	68	3	2.564103	2025-12-05 05:43:22.118523
7039	68	10	113.333333	2025-12-05 05:43:22.118523
7040	68	1	93.717949	2025-12-05 05:43:22.118523
7041	68	5	0.358974	2025-12-05 05:43:22.118523
7042	68	2	3.948718	2025-12-05 05:43:22.118523
7043	68	26	3.589744	2025-12-05 05:43:22.118523
7044	68	23	0.487179	2025-12-05 05:43:22.118523
7045	68	24	59.487179	2025-12-05 05:43:22.118523
7046	69	25	61.607143	2025-12-05 05:43:22.118523
7047	69	29	0.321429	2025-12-05 05:43:22.118523
7048	69	4	16.135714	2025-12-05 05:43:22.118523
7049	69	30	0.714286	2025-12-05 05:43:22.118523
7050	69	3	2.432143	2025-12-05 05:43:22.118523
7051	69	10	21.428571	2025-12-05 05:43:22.118523
7052	69	1	125.107143	2025-12-05 05:43:22.118523
7053	69	5	0.514286	2025-12-05 05:43:22.118523
7054	69	2	8.864286	2025-12-05 05:43:22.118523
7055	69	15	0.632143	2025-12-05 05:43:22.118523
7056	69	26	13.392857	2025-12-05 05:43:22.118523
7057	69	27	34.285714	2025-12-05 05:43:22.118523
7058	69	24	3.535714	2025-12-05 05:43:22.118523
7059	69	11	1789.928571	2025-12-05 05:43:22.118523
7060	70	25	101.470588	2025-12-05 05:43:22.118523
7061	70	4	26.226471	2025-12-05 05:43:22.118523
7062	70	3	0.297059	2025-12-05 05:43:22.118523
7063	70	1	120.588235	2025-12-05 05:43:22.118523
7064	70	5	0.561765	2025-12-05 05:43:22.118523
7065	70	2	2.532353	2025-12-05 05:43:22.118523
7066	70	15	0.800000	2025-12-05 05:43:22.118523
7067	70	26	22.058824	2025-12-05 05:43:22.118523
7068	70	27	25.088235	2025-12-05 05:43:22.118523
7069	71	25	61.607143	2025-12-05 05:43:22.118523
7070	71	29	0.128571	2025-12-05 05:43:22.118523
7071	71	4	16.135714	2025-12-05 05:43:22.118523
7072	71	34	8.142857	2025-12-05 05:43:22.118523
7073	71	30	0.521429	2025-12-05 05:43:22.118523
7074	71	3	1.446429	2025-12-05 05:43:22.118523
7075	71	10	41.142857	2025-12-05 05:43:22.118523
7076	71	1	117.178571	2025-12-05 05:43:22.118523
7077	71	5	0.514286	2025-12-05 05:43:22.118523
7078	71	2	8.821429	2025-12-05 05:43:22.118523
7079	71	15	0.632143	2025-12-05 05:43:22.118523
7080	71	26	13.392857	2025-12-05 05:43:22.118523
7081	71	27	34.285714	2025-12-05 05:43:22.118523
7082	71	24	3.535714	2025-12-05 05:43:22.118523
7083	71	11	1789.928571	2025-12-05 05:43:22.118523
7084	72	25	99.710983	2025-12-05 05:43:22.118523
7085	72	4	26.080347	2025-12-05 05:43:22.118523
7086	72	3	0.305780	2025-12-05 05:43:22.118523
7087	72	1	119.884393	2025-12-05 05:43:22.118523
7088	72	5	0.586705	2025-12-05 05:43:22.118523
7089	72	2	2.519653	2025-12-05 05:43:22.118523
7090	72	15	0.872832	2025-12-05 05:43:22.118523
7091	72	26	21.676301	2025-12-05 05:43:22.118523
7092	72	27	31.849711	2025-12-05 05:43:22.118523
7093	73	1	97.000000	2025-12-05 05:43:22.118523
7094	73	2	2.000000	2025-12-05 05:43:22.118523
7095	73	3	0.200000	2025-12-05 05:43:22.118523
7096	73	4	21.100000	2025-12-05 05:43:22.118523
7097	73	5	0.900000	2025-12-05 05:43:22.118523
7098	73	25	26.000000	2025-12-05 05:43:22.118523
7099	73	26	3.000000	2025-12-05 05:43:22.118523
7100	74	29	1.006452	2025-12-05 05:43:22.118523
7101	74	4	1.967742	2025-12-05 05:43:22.118523
7102	74	30	1.741935	2025-12-05 05:43:22.118523
7103	74	3	3.974194	2025-12-05 05:43:22.118523
7104	74	10	24.000000	2025-12-05 05:43:22.118523
7105	74	1	77.193548	2025-12-05 05:43:22.118523
7106	74	5	0.232258	2025-12-05 05:43:22.118523
7107	74	2	8.054839	2025-12-05 05:43:22.118523
7108	74	15	1.722581	2025-12-05 05:43:22.118523
7109	74	27	27.064516	2025-12-05 05:43:22.118523
7110	74	23	1.006452	2025-12-05 05:43:22.118523
7111	74	24	5.838710	2025-12-05 05:43:22.118523
7112	75	4	11.037500	2025-12-05 05:43:22.118523
7113	75	3	0.225000	2025-12-05 05:43:22.118523
7114	75	1	50.250000	2025-12-05 05:43:22.118523
7115	75	5	1.900000	2025-12-05 05:43:22.118523
7116	75	2	1.725000	2025-12-05 05:43:22.118523
7117	75	15	55.487500	2025-12-05 05:43:22.118523
7118	75	27	202.250000	2025-12-05 05:43:22.118523
7119	75	24	22.625000	2025-12-05 05:43:22.118523
7120	75	11	1174.125000	2025-12-05 05:43:22.118523
7121	76	1	10.395349	2025-12-05 05:43:22.118523
7122	76	5	0.146512	2025-12-05 05:43:22.118523
7123	76	4	2.309302	2025-12-05 05:43:22.118523
7124	76	2	0.446512	2025-12-05 05:43:22.118523
7125	76	15	2.176744	2025-12-05 05:43:22.118523
7126	76	27	27.976744	2025-12-05 05:43:22.118523
7127	76	3	0.034884	2025-12-05 05:43:22.118523
7128	76	24	12.627907	2025-12-05 05:43:22.118523
7129	77	1	30.904762	2025-12-05 05:43:22.118523
7130	77	5	2.480952	2025-12-05 05:43:22.118523
7131	77	4	7.100000	2025-12-05 05:43:22.118523
7132	77	2	1.542857	2025-12-05 05:43:22.118523
7133	77	15	36.342857	2025-12-05 05:43:22.118523
7134	77	27	181.000000	2025-12-05 05:43:22.118523
7135	77	3	0.119048	2025-12-05 05:43:22.118523
7136	77	24	46.714286	2025-12-05 05:43:22.118523
7137	78	29	1.833333	2025-12-05 05:43:22.118523
7138	78	4	4.958333	2025-12-05 05:43:22.118523
7139	78	3	2.283333	2025-12-05 05:43:22.118523
7140	78	1	57.041667	2025-12-05 05:43:22.118523
7141	78	5	0.300000	2025-12-05 05:43:22.118523
7142	78	2	4.820833	2025-12-05 05:43:22.118523
7143	78	15	2.225000	2025-12-05 05:43:22.118523
7144	78	27	34.958333	2025-12-05 05:43:22.118523
7145	78	24	174.208333	2025-12-05 05:43:22.118523
7146	79	29	0.562500	2025-12-05 05:43:22.118523
7147	79	4	4.479167	2025-12-05 05:43:22.118523
7148	79	30	1.250000	2025-12-05 05:43:22.118523
7149	79	3	3.991667	2025-12-05 05:43:22.118523
7150	79	10	37.500000	2025-12-05 05:43:22.118523
7151	79	1	108.916667	2025-12-05 05:43:22.118523
7152	79	5	0.654167	2025-12-05 05:43:22.118523
7153	79	2	13.445833	2025-12-05 05:43:22.118523
7154	79	15	3.766667	2025-12-05 05:43:22.118523
7155	79	27	65.375000	2025-12-05 05:43:22.118523
7156	79	24	7.541667	2025-12-05 05:43:22.118523
7157	80	4	2.800000	2025-12-05 05:43:22.118523
7158	80	34	27.500000	2025-12-05 05:43:22.118523
7159	80	3	0.954167	2025-12-05 05:43:22.118523
7160	80	10	145.625000	2025-12-05 05:43:22.118523
7161	80	1	70.625000	2025-12-05 05:43:22.118523
7162	80	5	0.720833	2025-12-05 05:43:22.118523
7163	80	2	10.141667	2025-12-05 05:43:22.118523
7164	80	15	27.837500	2025-12-05 05:43:22.118523
7165	80	27	68.291667	2025-12-05 05:43:22.118523
7166	80	11	652.291667	2025-12-05 05:43:22.118523
7167	81	4	2.545455	2025-12-05 05:43:22.118523
7168	81	34	34.545455	2025-12-05 05:43:22.118523
7169	81	30	1.000000	2025-12-05 05:43:22.118523
7170	81	3	1.600000	2025-12-05 05:43:22.118523
7171	81	10	138.181818	2025-12-05 05:43:22.118523
7172	81	1	107.818182	2025-12-05 05:43:22.118523
7173	81	5	0.187879	2025-12-05 05:43:22.118523
7174	81	2	18.896970	2025-12-05 05:43:22.118523
7175	81	15	2.042424	2025-12-05 05:43:22.118523
7176	81	27	36.878788	2025-12-05 05:43:22.118523
7177	81	24	10.969697	2025-12-05 05:43:22.118523
7178	82	4	1.111111	2025-12-05 05:43:22.118523
7179	82	3	1.681481	2025-12-05 05:43:22.118523
7180	82	10	20.888889	2025-12-05 05:43:22.118523
7181	82	1	51.481481	2025-12-05 05:43:22.118523
7182	82	5	0.185185	2025-12-05 05:43:22.118523
7183	82	2	7.511111	2025-12-05 05:43:22.118523
7184	82	15	4.814815	2025-12-05 05:43:22.118523
7185	82	27	55.555556	2025-12-05 05:43:22.118523
7186	82	23	0.666667	2025-12-05 05:43:22.118523
7187	83	29	0.288000	2025-12-05 05:43:22.118523
7188	83	4	4.224000	2025-12-05 05:43:22.118523
7189	83	30	0.640000	2025-12-05 05:43:22.118523
7190	83	3	2.084000	2025-12-05 05:43:22.118523
7191	83	10	19.200000	2025-12-05 05:43:22.118523
7192	83	1	63.960000	2025-12-05 05:43:22.118523
7193	83	5	1.636000	2025-12-05 05:43:22.118523
7194	83	2	7.428000	2025-12-05 05:43:22.118523
7195	83	15	22.552000	2025-12-05 05:43:22.118523
7196	83	27	113.680000	2025-12-05 05:43:22.118523
7197	83	24	24.000000	2025-12-05 05:43:22.118523
7198	84	29	0.333333	2025-12-05 05:43:22.118523
7199	84	4	2.744444	2025-12-05 05:43:22.118523
7200	84	30	0.740741	2025-12-05 05:43:22.118523
7201	84	3	2.451852	2025-12-05 05:43:22.118523
7202	84	10	22.222222	2025-12-05 05:43:22.118523
7203	84	1	65.370370	2025-12-05 05:43:22.118523
7204	84	5	1.681481	2025-12-05 05:43:22.118523
7205	84	2	8.229630	2025-12-05 05:43:22.118523
7206	84	15	47.214815	2025-12-05 05:43:22.118523
7207	84	27	175.259259	2025-12-05 05:43:22.118523
7208	85	29	17.872340	2025-12-05 05:43:22.118523
7209	85	4	0.378723	2025-12-05 05:43:22.118523
7210	85	3	0.655319	2025-12-05 05:43:22.118523
7211	85	10	25.531915	2025-12-05 05:43:22.118523
7212	85	1	56.595745	2025-12-05 05:43:22.118523
7213	85	5	0.042553	2025-12-05 05:43:22.118523
7214	85	2	8.974468	2025-12-05 05:43:22.118523
7215	85	15	0.106383	2025-12-05 05:43:22.118523
7216	85	27	8.829787	2025-12-05 05:43:22.118523
7217	86	29	0.360000	2025-12-05 05:43:22.118523
7218	86	4	1.395000	2025-12-05 05:43:22.118523
7219	86	34	22.800000	2025-12-05 05:43:22.118523
7220	86	3	1.035000	2025-12-05 05:43:22.118523
7221	86	10	30.000000	2025-12-05 05:43:22.118523
7222	86	1	63.600000	2025-12-05 05:43:22.118523
7223	86	5	0.255000	2025-12-05 05:43:22.118523
7224	86	2	12.225000	2025-12-05 05:43:22.118523
7225	86	15	1.110000	2025-12-05 05:43:22.118523
7226	86	27	21.900000	2025-12-05 05:43:22.118523
7227	86	23	0.900000	2025-12-05 05:43:22.118523
7228	87	1	126.153846	2025-12-05 05:43:22.118523
7229	87	25	106.153846	2025-12-05 05:43:22.118523
7230	87	5	0.523077	2025-12-05 05:43:22.118523
7231	87	4	27.400000	2025-12-05 05:43:22.118523
7232	87	2	2.630769	2025-12-05 05:43:22.118523
7233	87	15	0.384615	2025-12-05 05:43:22.118523
7234	87	26	23.076923	2025-12-05 05:43:22.118523
7235	87	27	31.923077	2025-12-05 05:43:22.118523
7236	87	3	0.338462	2025-12-05 05:43:22.118523
7237	88	25	47.586207	2025-12-05 05:43:22.118523
7238	88	4	12.282759	2025-12-05 05:43:22.118523
7239	88	3	2.193103	2025-12-05 05:43:22.118523
7240	88	10	25.931034	2025-12-05 05:43:22.118523
7241	88	1	114.482759	2025-12-05 05:43:22.118523
7242	88	5	0.234483	2025-12-05 05:43:22.118523
7243	88	2	10.227586	2025-12-05 05:43:22.118523
7244	88	15	0.172414	2025-12-05 05:43:22.118523
7245	88	26	10.344828	2025-12-05 05:43:22.118523
7246	88	27	14.310345	2025-12-05 05:43:22.118523
7247	88	23	0.827586	2025-12-05 05:43:22.118523
7248	89	25	83.132530	2025-12-05 05:43:22.118523
7249	89	4	23.781928	2025-12-05 05:43:22.118523
7250	89	3	0.312048	2025-12-05 05:43:22.118523
7251	89	1	108.915663	2025-12-05 05:43:22.118523
7252	89	5	0.789157	2025-12-05 05:43:22.118523
7253	89	2	2.324096	2025-12-05 05:43:22.118523
7254	89	15	1.819277	2025-12-05 05:43:22.118523
7255	89	26	18.072289	2025-12-05 05:43:22.118523
7256	89	27	66.385542	2025-12-05 05:43:22.118523
7257	90	25	63.304348	2025-12-05 05:43:22.118523
7258	90	4	11.217391	2025-12-05 05:43:22.118523
7259	90	3	1.986957	2025-12-05 05:43:22.118523
7260	90	1	69.521739	2025-12-05 05:43:22.118523
7261	90	5	1.156522	2025-12-05 05:43:22.118523
7262	90	2	2.465217	2025-12-05 05:43:22.118523
7263	90	15	1.891304	2025-12-05 05:43:22.118523
7264	90	26	3.478261	2025-12-05 05:43:22.118523
7265	90	27	140.000000	2025-12-05 05:43:22.118523
7266	90	24	49.130435	2025-12-05 05:43:22.118523
7267	91	4	7.438889	2025-12-05 05:43:22.118523
7268	91	3	0.127778	2025-12-05 05:43:22.118523
7269	91	1	31.944444	2025-12-05 05:43:22.118523
7270	91	5	2.450000	2025-12-05 05:43:22.118523
7271	91	2	1.155556	2025-12-05 05:43:22.118523
7272	91	15	23.205556	2025-12-05 05:43:22.118523
7273	91	27	207.666667	2025-12-05 05:43:22.118523
7274	91	24	31.388889	2025-12-05 05:43:22.118523
7275	91	11	4640.555556	2025-12-05 05:43:22.118523
7276	92	29	0.284211	2025-12-05 05:43:22.118523
7277	92	4	2.526316	2025-12-05 05:43:22.118523
7278	92	34	16.000000	2025-12-05 05:43:22.118523
7279	92	30	1.094737	2025-12-05 05:43:22.118523
7280	92	3	2.757895	2025-12-05 05:43:22.118523
7281	92	10	82.947368	2025-12-05 05:43:22.118523
7282	92	1	100.578947	2025-12-05 05:43:22.118523
7283	92	5	0.736842	2025-12-05 05:43:22.118523
7284	92	2	15.257895	2025-12-05 05:43:22.118523
7285	92	15	1.552632	2025-12-05 05:43:22.118523
7286	92	27	84.210526	2025-12-05 05:43:22.118523
7287	92	24	8.684211	2025-12-05 05:43:22.118523
7288	92	11	4396.315789	2025-12-05 05:43:22.118523
7289	93	4	8.192308	2025-12-05 05:43:22.118523
7290	93	34	7.615385	2025-12-05 05:43:22.118523
7291	93	3	0.465385	2025-12-05 05:43:22.118523
7292	93	10	37.153846	2025-12-05 05:43:22.118523
7293	93	1	55.538462	2025-12-05 05:43:22.118523
7294	93	5	1.519231	2025-12-05 05:43:22.118523
7295	93	2	5.284615	2025-12-05 05:43:22.118523
7296	93	15	36.269231	2025-12-05 05:43:22.118523
7297	93	27	166.538462	2025-12-05 05:43:22.118523
7298	93	24	6.346154	2025-12-05 05:43:22.118523
7299	93	11	3760.769231	2025-12-05 05:43:22.118523
7300	94	4	7.210526	2025-12-05 05:43:22.118523
7301	94	3	0.168421	2025-12-05 05:43:22.118523
7302	94	1	32.052632	2025-12-05 05:43:22.118523
7303	94	5	2.410526	2025-12-05 05:43:22.118523
7304	94	2	1.110526	2025-12-05 05:43:22.118523
7305	94	15	44.626316	2025-12-05 05:43:22.118523
7306	94	27	215.578947	2025-12-05 05:43:22.118523
7307	94	24	25.526316	2025-12-05 05:43:22.118523
7308	94	11	5055.473684	2025-12-05 05:43:22.118523
7309	95	10	51.290323	2025-12-05 05:43:22.118523
7310	95	1	137.096774	2025-12-05 05:43:22.118523
7311	95	5	0.064516	2025-12-05 05:43:22.118523
7312	95	4	0.574194	2025-12-05 05:43:22.118523
7313	95	2	18.058065	2025-12-05 05:43:22.118523
7314	95	15	0.161290	2025-12-05 05:43:22.118523
7315	95	27	13.387097	2025-12-05 05:43:22.118523
7316	95	3	6.122581	2025-12-05 05:43:22.118523
7317	95	23	8.516129	2025-12-05 05:43:22.118523
7318	96	1	126.000000	2025-12-05 05:43:22.118523
7319	96	5	2.066667	2025-12-05 05:43:22.118523
7320	96	4	28.000000	2025-12-05 05:43:22.118523
7321	96	2	4.866667	2025-12-05 05:43:22.118523
7322	96	15	22.466667	2025-12-05 05:43:22.118523
7323	96	27	405.666667	2025-12-05 05:43:22.118523
7324	96	3	0.600000	2025-12-05 05:43:22.118523
7325	96	24	120.666667	2025-12-05 05:43:22.118523
7326	97	29	0.750000	2025-12-05 05:43:22.118523
7327	97	4	2.872222	2025-12-05 05:43:22.118523
7328	97	30	1.666667	2025-12-05 05:43:22.118523
7329	97	3	5.288889	2025-12-05 05:43:22.118523
7330	97	10	50.000000	2025-12-05 05:43:22.118523
7331	97	1	131.888889	2025-12-05 05:43:22.118523
7332	97	5	0.305556	2025-12-05 05:43:22.118523
7333	97	2	17.561111	2025-12-05 05:43:22.118523
7334	97	15	2.555556	2025-12-05 05:43:22.118523
7335	97	27	38.500000	2025-12-05 05:43:22.118523
7336	97	24	10.055556	2025-12-05 05:43:22.118523
7337	98	24	5.838710	2025-12-05 05:43:22.118523
7338	98	10	147.096774	2025-12-05 05:43:22.118523
7339	98	1	107.387097	2025-12-05 05:43:22.118523
7340	98	5	0.067742	2025-12-05 05:43:22.118523
7341	98	4	1.067742	2025-12-05 05:43:22.118523
7342	98	2	19.851613	2025-12-05 05:43:22.118523
7343	98	15	1.006452	2025-12-05 05:43:22.118523
7344	98	34	36.774194	2025-12-05 05:43:22.118523
7345	98	30	1.064516	2025-12-05 05:43:22.118523
7346	98	27	12.935484	2025-12-05 05:43:22.118523
7347	98	3	1.661290	2025-12-05 05:43:22.118523
7348	99	4	2.689474	2025-12-05 05:43:22.118523
7349	99	34	34.736842	2025-12-05 05:43:22.118523
7350	99	3	1.178947	2025-12-05 05:43:22.118523
7351	99	10	183.947368	2025-12-05 05:43:22.118523
7352	99	1	85.368421	2025-12-05 05:43:22.118523
7353	99	5	0.442105	2025-12-05 05:43:22.118523
7354	99	2	12.810526	2025-12-05 05:43:22.118523
7355	99	15	21.805263	2025-12-05 05:43:22.118523
7356	99	27	54.421053	2025-12-05 05:43:22.118523
7357	99	24	9.526316	2025-12-05 05:43:22.118523
7358	99	11	494.368421	2025-12-05 05:43:22.118523
7359	100	29	0.505618	2025-12-05 05:43:22.118523
7360	100	4	1.844944	2025-12-05 05:43:22.118523
7361	100	34	32.022472	2025-12-05 05:43:22.118523
7362	100	3	1.479775	2025-12-05 05:43:22.118523
7363	100	10	42.134831	2025-12-05 05:43:22.118523
7364	100	1	88.988764	2025-12-05 05:43:22.118523
7365	100	5	0.280899	2025-12-05 05:43:22.118523
7366	100	2	17.142697	2025-12-05 05:43:22.118523
7367	100	15	1.056180	2025-12-05 05:43:22.118523
7368	100	27	35.056180	2025-12-05 05:43:22.118523
7369	100	23	1.264045	2025-12-05 05:43:22.118523
7370	101	1	80.000000	2025-12-05 05:43:22.118523
7371	101	2	1.800000	2025-12-05 05:43:22.118523
7372	101	3	0.800000	2025-12-05 05:43:22.118523
7373	101	4	17.800000	2025-12-05 05:43:22.118523
7374	101	5	2.000000	2025-12-05 05:43:22.118523
7375	101	15	5.000000	2025-12-05 05:43:22.118523
7376	101	27	415.000000	2025-12-05 05:43:22.118523
7377	102	1	40.000000	2025-12-05 05:43:22.118523
7378	102	2	1.100000	2025-12-05 05:43:22.118523
7379	102	3	0.100000	2025-12-05 05:43:22.118523
7380	102	4	9.300000	2025-12-05 05:43:22.118523
7381	102	5	1.700000	2025-12-05 05:43:22.118523
7382	102	15	7.400000	2025-12-05 05:43:22.118523
7383	102	27	146.000000	2025-12-05 05:43:22.118523
7384	103	25	24.140351	2025-12-05 05:43:22.118523
7385	103	29	1.543860	2025-12-05 05:43:22.118523
7386	103	4	4.440351	2025-12-05 05:43:22.118523
7387	103	3	1.987719	2025-12-05 05:43:22.118523
7388	103	1	51.035088	2025-12-05 05:43:22.118523
7389	103	5	0.682456	2025-12-05 05:43:22.118523
7390	103	2	4.701754	2025-12-05 05:43:22.118523
7391	103	15	0.547368	2025-12-05 05:43:22.118523
7392	103	27	106.964912	2025-12-05 05:43:22.118523
7393	103	24	143.526316	2025-12-05 05:43:22.118523
7394	104	1	80.000000	2025-12-05 05:43:22.118523
7395	104	2	1.800000	2025-12-05 05:43:22.118523
7396	104	3	0.800000	2025-12-05 05:43:22.118523
7397	104	4	17.800000	2025-12-05 05:43:22.118523
7398	104	5	2.000000	2025-12-05 05:43:22.118523
7399	104	15	5.000000	2025-12-05 05:43:22.118523
7400	104	27	415.000000	2025-12-05 05:43:22.118523
7401	105	1	106.000000	2025-12-05 05:43:22.118523
7402	105	2	20.300000	2025-12-05 05:43:22.118523
7403	105	3	1.700000	2025-12-05 05:43:22.118523
7404	105	10	152.000000	2025-12-05 05:43:22.118523
7405	105	30	1.100000	2025-12-05 05:43:22.118523
7406	105	34	38.000000	2025-12-05 05:43:22.118523
7407	107	4	6.925000	2025-12-05 05:43:22.118523
7408	107	3	0.125000	2025-12-05 05:43:22.118523
7409	107	1	29.250000	2025-12-05 05:43:22.118523
7410	107	5	2.075000	2025-12-05 05:43:22.118523
7411	107	2	1.125000	2025-12-05 05:43:22.118523
7412	107	15	22.025000	2025-12-05 05:43:22.118523
7413	107	27	250.000000	2025-12-05 05:43:22.118523
7414	107	24	28.250000	2025-12-05 05:43:22.118523
7415	107	11	6304.000000	2025-12-05 05:43:22.118523
7416	108	1	77.000000	2025-12-05 05:43:22.118523
7417	108	2	2.000000	2025-12-05 05:43:22.118523
7418	108	3	0.100000	2025-12-05 05:43:22.118523
7419	108	4	17.500000	2025-12-05 05:43:22.118523
7420	108	5	2.100000	2025-12-05 05:43:22.118523
7421	108	15	19.700000	2025-12-05 05:43:22.118523
7422	108	27	421.000000	2025-12-05 05:43:22.118523
7423	109	1	86.000000	2025-12-05 05:43:22.118523
7424	109	2	3.300000	2025-12-05 05:43:22.118523
7425	109	3	1.400000	2025-12-05 05:43:22.118523
7426	109	4	18.700000	2025-12-05 05:43:22.118523
7427	109	5	2.000000	2025-12-05 05:43:22.118523
7428	109	25	89.000000	2025-12-05 05:43:22.118523
7429	109	26	37.000000	2025-12-05 05:43:22.118523
7430	110	4	3.210526	2025-12-05 05:43:22.118523
7431	110	3	2.963158	2025-12-05 05:43:22.118523
7432	110	10	37.105263	2025-12-05 05:43:22.118523
7433	110	1	97.052632	2025-12-05 05:43:22.118523
7434	110	5	0.378947	2025-12-05 05:43:22.118523
7435	110	2	13.457895	2025-12-05 05:43:22.118523
7436	110	15	2.810526	2025-12-05 05:43:22.118523
7437	110	27	44.157895	2025-12-05 05:43:22.118523
7438	110	23	1.184211	2025-12-05 05:43:22.118523
7439	110	24	9.526316	2025-12-05 05:43:22.118523
7440	111	29	1.980769	2025-12-05 05:43:22.118523
7441	111	4	1.850000	2025-12-05 05:43:22.118523
7442	111	30	1.153846	2025-12-05 05:43:22.118523
7443	111	3	8.961538	2025-12-05 05:43:22.118523
7444	111	10	374.615385	2025-12-05 05:43:22.118523
7445	111	1	159.384615	2025-12-05 05:43:22.118523
7446	111	5	0.080769	2025-12-05 05:43:22.118523
7447	111	2	17.073077	2025-12-05 05:43:22.118523
7448	111	15	1.200000	2025-12-05 05:43:22.118523
7449	111	27	15.423077	2025-12-05 05:43:22.118523
7450	111	23	1.461538	2025-12-05 05:43:22.118523
7451	111	24	31.576923	2025-12-05 05:43:22.118523
7452	112	1	53.333333	2025-12-05 05:43:22.118523
7453	112	5	1.800000	2025-12-05 05:43:22.118523
7454	112	4	12.133333	2025-12-05 05:43:22.118523
7455	112	2	1.333333	2025-12-05 05:43:22.118523
7456	112	15	6.600000	2025-12-05 05:43:22.118523
7457	112	27	235.666667	2025-12-05 05:43:22.118523
7458	112	3	0.333333	2025-12-05 05:43:22.118523
7459	113	1	53.043478	2025-12-05 05:43:22.118523
7460	113	5	0.221739	2025-12-05 05:43:22.118523
7461	113	29	1.913043	2025-12-05 05:43:22.118523
7462	113	4	3.734783	2025-12-05 05:43:22.118523
7463	113	2	4.752174	2025-12-05 05:43:22.118523
7464	113	15	0.965217	2025-12-05 05:43:22.118523
7465	113	27	19.043478	2025-12-05 05:43:22.118523
7466	113	3	2.360870	2025-12-05 05:43:22.118523
7467	113	24	173.913043	2025-12-05 05:43:22.118523
7468	114	29	0.923077	2025-12-05 05:43:22.118523
7469	114	4	2.800000	2025-12-05 05:43:22.118523
7470	114	3	4.384615	2025-12-05 05:43:22.118523
7471	114	10	50.769231	2025-12-05 05:43:22.118523
7472	114	1	110.000000	2025-12-05 05:43:22.118523
7473	114	5	0.415385	2025-12-05 05:43:22.118523
7474	114	2	14.000000	2025-12-05 05:43:22.118523
7475	114	15	1.523077	2025-12-05 05:43:22.118523
7476	114	27	54.384615	2025-12-05 05:43:22.118523
7477	114	23	1.153846	2025-12-05 05:43:22.118523
7486	116	1	40.000000	2025-12-05 05:43:22.118523
7487	116	25	33.600000	2025-12-05 05:43:22.118523
7488	116	5	0.300000	2025-12-05 05:43:22.118523
7489	116	4	5.820000	2025-12-05 05:43:22.118523
7490	116	2	1.880000	2025-12-05 05:43:22.118523
7491	116	15	5.400000	2025-12-05 05:43:22.118523
7492	116	27	261.200000	2025-12-05 05:43:22.118523
7493	116	3	1.380000	2025-12-05 05:43:22.118523
7494	116	24	45.200000	2025-12-05 05:43:22.118523
7495	116	11	5106.000000	2025-12-05 05:43:22.118523
7503	118	1	75.000000	2025-12-05 05:43:22.118523
7504	118	25	42.000000	2025-12-05 05:43:22.118523
7505	118	5	1.300000	2025-12-05 05:43:22.118523
7506	118	4	13.800000	2025-12-05 05:43:22.118523
7507	118	2	2.150000	2025-12-05 05:43:22.118523
7508	118	15	4.350000	2025-12-05 05:43:22.118523
7509	118	27	250.500000	2025-12-05 05:43:22.118523
7510	118	3	1.800000	2025-12-05 05:43:22.118523
7511	118	24	56.500000	2025-12-05 05:43:22.118523
7519	121	1	68.000000	2025-12-05 05:43:22.118523
7520	121	2	2.600000	2025-12-05 05:43:22.118523
7521	121	3	1.000000	2025-12-05 05:43:22.118523
7522	121	4	14.300000	2025-12-05 05:43:22.118523
7523	121	5	5.400000	2025-12-05 05:43:22.118523
7524	121	15	228.300000	2025-12-05 05:43:22.118523
7525	121	24	18.000000	2025-12-05 05:43:22.118523
7526	121	27	417.000000	2025-12-05 05:43:22.118523
7527	122	4	16.033333	2025-12-05 05:43:22.118523
7528	122	3	0.533333	2025-12-05 05:43:22.118523
7529	122	1	66.666667	2025-12-05 05:43:22.118523
7530	122	5	3.233333	2025-12-05 05:43:22.118523
7531	122	2	1.400000	2025-12-05 05:43:22.118523
7532	122	15	99.300000	2025-12-05 05:43:22.118523
7533	122	27	319.000000	2025-12-05 05:43:22.118523
7534	122	24	6.000000	2025-12-05 05:43:22.118523
7535	122	11	316.666667	2025-12-05 05:43:22.118523
7536	123	29	1.760000	2025-12-05 05:43:22.118523
7537	123	4	5.132000	2025-12-05 05:43:22.118523
7538	123	3	2.196000	2025-12-05 05:43:22.118523
7539	123	1	56.360000	2025-12-05 05:43:22.118523
7540	123	5	0.356000	2025-12-05 05:43:22.118523
7541	123	2	4.672000	2025-12-05 05:43:22.118523
7542	123	15	2.432000	2025-12-05 05:43:22.118523
7543	123	27	39.400000	2025-12-05 05:43:22.118523
7544	123	24	167.240000	2025-12-05 05:43:22.118523
7545	124	25	16.125000	2025-12-05 05:43:22.118523
7546	124	4	7.056250	2025-12-05 05:43:22.118523
7547	124	3	0.162500	2025-12-05 05:43:22.118523
7548	124	1	31.125000	2025-12-05 05:43:22.118523
7549	124	5	2.037500	2025-12-05 05:43:22.118523
7550	124	2	1.462500	2025-12-05 05:43:22.118523
7551	124	15	15.162500	2025-12-05 05:43:22.118523
7552	124	27	284.875000	2025-12-05 05:43:22.118523
7553	124	24	20.750000	2025-12-05 05:43:22.118523
7554	124	11	6304.000000	2025-12-05 05:43:22.118523
7555	125	25	95.833333	2025-12-05 05:43:22.118523
7556	125	4	17.166667	2025-12-05 05:43:22.118523
7557	125	3	0.750000	2025-12-05 05:43:22.118523
7558	125	1	81.833333	2025-12-05 05:43:22.118523
7559	125	5	2.133333	2025-12-05 05:43:22.118523
7560	125	2	2.466667	2025-12-05 05:43:22.118523
7561	125	15	3.016667	2025-12-05 05:43:22.118523
7562	125	26	27.666667	2025-12-05 05:43:22.118523
7563	125	27	96.666667	2025-12-05 05:43:22.118523
7564	125	24	5.500000	2025-12-05 05:43:22.118523
7565	125	11	2784.333333	2025-12-05 05:43:22.118523
7566	126	25	13.870968	2025-12-05 05:43:22.118523
7567	126	4	6.783871	2025-12-05 05:43:22.118523
7568	126	3	0.158065	2025-12-05 05:43:22.118523
7569	126	1	29.516129	2025-12-05 05:43:22.118523
7570	126	5	1.693548	2025-12-05 05:43:22.118523
7571	126	2	1.261290	2025-12-05 05:43:22.118523
7572	126	15	6.412903	2025-12-05 05:43:22.118523
7573	126	27	281.935484	2025-12-05 05:43:22.118523
7574	126	24	8.516129	2025-12-05 05:43:22.118523
7575	126	11	7056.387097	2025-12-05 05:43:22.118523
7576	127	1	41.000000	2025-12-05 05:43:22.118523
7577	127	2	0.900000	2025-12-05 05:43:22.118523
7578	127	3	0.200000	2025-12-05 05:43:22.118523
7579	127	4	9.600000	2025-12-05 05:43:22.118523
7580	127	5	2.800000	2025-12-05 05:43:22.118523
7581	127	11	16706.000000	2025-12-05 05:43:22.118523
7582	127	15	5.900000	2025-12-05 05:43:22.118523
7583	127	24	33.000000	2025-12-05 05:43:22.118523
7584	127	27	320.000000	2025-12-05 05:43:22.118523
7585	128	1	90.294118	2025-12-05 05:43:22.118523
7586	128	25	22.941176	2025-12-05 05:43:22.118523
7587	128	5	0.994118	2025-12-05 05:43:22.118523
7588	128	4	19.711765	2025-12-05 05:43:22.118523
7589	128	2	1.894118	2025-12-05 05:43:22.118523
7590	128	15	0.870588	2025-12-05 05:43:22.118523
7591	128	26	2.647059	2025-12-05 05:43:22.118523
7592	128	27	17.176471	2025-12-05 05:43:22.118523
7593	128	3	0.188235	2025-12-05 05:43:22.118523
7594	129	1	99.782609	2025-12-05 05:43:22.118523
7595	129	25	16.956522	2025-12-05 05:43:22.118523
7596	129	29	0.486957	2025-12-05 05:43:22.118523
7597	129	5	3.230435	2025-12-05 05:43:22.118523
7598	129	4	20.369565	2025-12-05 05:43:22.118523
7599	129	2	3.739130	2025-12-05 05:43:22.118523
7600	129	26	1.956522	2025-12-05 05:43:22.118523
7601	129	3	0.269565	2025-12-05 05:43:22.118523
7602	129	22	55.304348	2025-12-05 05:43:22.118523
7603	130	1	78.500000	2025-12-05 05:43:22.118523
7604	130	5	4.000000	2025-12-05 05:43:22.118523
7605	130	4	18.550000	2025-12-05 05:43:22.118523
7606	130	2	1.850000	2025-12-05 05:43:22.118523
7607	130	15	118.500000	2025-12-05 05:43:22.118523
7608	130	27	387.500000	2025-12-05 05:43:22.118523
7609	130	3	0.650000	2025-12-05 05:43:22.118523
7610	130	24	9.000000	2025-12-05 05:43:22.118523
7611	131	4	2.961538	2025-12-05 05:43:22.118523
7612	131	34	25.230769	2025-12-05 05:43:22.118523
7613	131	30	0.338462	2025-12-05 05:43:22.118523
7614	131	3	1.011538	2025-12-05 05:43:22.118523
7615	131	10	118.461538	2025-12-05 05:43:22.118523
7616	131	1	73.615385	2025-12-05 05:43:22.118523
7617	131	5	1.019231	2025-12-05 05:43:22.118523
7618	131	2	11.469231	2025-12-05 05:43:22.118523
7619	131	15	8.173077	2025-12-05 05:43:22.118523
7620	131	27	94.230769	2025-12-05 05:43:22.118523
7621	131	24	14.038462	2025-12-05 05:43:22.118523
7622	131	11	3212.692308	2025-12-05 05:43:22.118523
7623	132	25	18.105263	2025-12-05 05:43:22.118523
7624	132	29	0.473684	2025-12-05 05:43:22.118523
7625	132	4	3.894737	2025-12-05 05:43:22.118523
7626	132	30	1.052632	2025-12-05 05:43:22.118523
7627	132	3	3.431579	2025-12-05 05:43:22.118523
7628	132	10	31.578947	2025-12-05 05:43:22.118523
7629	132	1	93.421053	2025-12-05 05:43:22.118523
7630	132	5	1.221053	2025-12-05 05:43:22.118523
7631	132	2	11.678947	2025-12-05 05:43:22.118523
7632	132	15	1.552632	2025-12-05 05:43:22.118523
7633	132	27	159.157895	2025-12-05 05:43:22.118523
7634	132	24	8.684211	2025-12-05 05:43:22.118523
7635	132	11	4396.315789	2025-12-05 05:43:22.118523
7636	133	25	12.285714	2025-12-05 05:43:22.118523
7637	133	29	0.342857	2025-12-05 05:43:22.118523
7638	133	4	2.757143	2025-12-05 05:43:22.118523
7639	133	34	9.428571	2025-12-05 05:43:22.118523
7640	133	30	0.761905	2025-12-05 05:43:22.118523
7641	133	3	2.795238	2025-12-05 05:43:22.118523
7642	133	10	68.857143	2025-12-05 05:43:22.118523
7643	133	1	95.571429	2025-12-05 05:43:22.118523
7644	133	5	0.861905	2025-12-05 05:43:22.118523
7645	133	2	14.395238	2025-12-05 05:43:22.118523
7646	133	15	1.123810	2025-12-05 05:43:22.118523
7647	133	27	111.809524	2025-12-05 05:43:22.118523
7648	133	24	6.285714	2025-12-05 05:43:22.118523
7649	133	11	3182.095238	2025-12-05 05:43:22.118523
7650	134	25	37.692308	2025-12-05 05:43:22.118523
7651	134	29	0.173077	2025-12-05 05:43:22.118523
7652	134	4	30.807692	2025-12-05 05:43:22.118523
7653	134	34	8.769231	2025-12-05 05:43:22.118523
7654	134	30	0.638462	2025-12-05 05:43:22.118523
7655	134	3	2.142308	2025-12-05 05:43:22.118523
7656	134	10	46.615385	2025-12-05 05:43:22.118523
7657	134	1	192.730769	2025-12-05 05:43:22.118523
7658	134	5	0.923077	2025-12-05 05:43:22.118523
7659	134	2	10.934615	2025-12-05 05:43:22.118523
7660	134	26	3.846154	2025-12-05 05:43:22.118523
7661	135	25	66.200000	2025-12-05 05:43:22.118523
7662	135	29	0.270000	2025-12-05 05:43:22.118523
7663	135	4	41.350000	2025-12-05 05:43:22.118523
7664	135	30	0.600000	2025-12-05 05:43:22.118523
7665	135	3	2.650000	2025-12-05 05:43:22.118523
7666	135	10	18.000000	2025-12-05 05:43:22.118523
7667	135	1	232.900000	2025-12-05 05:43:22.118523
7668	135	5	1.660000	2025-12-05 05:43:22.118523
7669	135	2	9.770000	2025-12-05 05:43:22.118523
7670	135	26	5.000000	2025-12-05 05:43:22.118523
7671	135	27	71.200000	2025-12-05 05:43:22.118523
7672	136	25	22.631579	2025-12-05 05:43:22.118523
7673	136	29	0.189474	2025-12-05 05:43:22.118523
7674	136	4	13.157895	2025-12-05 05:43:22.118523
7675	136	34	9.842105	2025-12-05 05:43:22.118523
7676	136	30	0.421053	2025-12-05 05:43:22.118523
7677	136	3	1.752632	2025-12-05 05:43:22.118523
7678	136	10	62.578947	2025-12-05 05:43:22.118523
7679	136	1	112.789474	2025-12-05 05:43:22.118523
7680	136	5	0.368421	2025-12-05 05:43:22.118523
7681	136	2	10.205263	2025-12-05 05:43:22.118523
7682	136	26	3.684211	2025-12-05 05:43:22.118523
7683	137	29	0.400000	2025-12-05 05:43:22.118523
7684	137	34	12.666667	2025-12-05 05:43:22.118523
7685	137	30	1.255556	2025-12-05 05:43:22.118523
7686	137	3	3.366667	2025-12-05 05:43:22.118523
7687	137	10	77.333333	2025-12-05 05:43:22.118523
7688	137	1	98.888889	2025-12-05 05:43:22.118523
7689	137	2	15.877778	2025-12-05 05:43:22.118523
7690	138	29	0.473684	2025-12-05 05:43:22.118523
7691	138	4	1.468421	2025-12-05 05:43:22.118523
7692	138	30	1.052632	2025-12-05 05:43:22.118523
7693	138	3	3.331579	2025-12-05 05:43:22.118523
7694	138	10	31.578947	2025-12-05 05:43:22.118523
7695	138	1	81.578947	2025-12-05 05:43:22.118523
7696	138	5	0.268421	2025-12-05 05:43:22.118523
7697	138	2	10.963158	2025-12-05 05:43:22.118523
7698	138	15	1.168421	2025-12-05 05:43:22.118523
7699	138	27	23.052632	2025-12-05 05:43:22.118523
7700	139	10	53.666667	2025-12-05 05:43:22.118523
7701	139	1	277.000000	2025-12-05 05:43:22.118523
7702	139	25	65.333333	2025-12-05 05:43:22.118523
7703	139	5	1.600000	2025-12-05 05:43:22.118523
7704	139	4	53.400000	2025-12-05 05:43:22.118523
7705	139	2	10.966667	2025-12-05 05:43:22.118523
7706	139	34	11.000000	2025-12-05 05:43:22.118523
7707	139	26	6.666667	2025-12-05 05:43:22.118523
7708	139	3	1.300000	2025-12-05 05:43:22.118523
7709	140	10	115.200000	2025-12-05 05:43:22.118523
7710	140	1	120.800000	2025-12-05 05:43:22.118523
7711	140	29	0.360000	2025-12-05 05:43:22.118523
7712	140	2	20.380000	2025-12-05 05:43:22.118523
7713	140	34	22.800000	2025-12-05 05:43:22.118523
7714	140	30	1.460000	2025-12-05 05:43:22.118523
7715	140	3	3.540000	2025-12-05 05:43:22.118523
7716	141	1	100.000000	2025-12-05 05:43:22.118523
7717	141	25	16.250000	2025-12-05 05:43:22.118523
7718	141	29	0.525000	2025-12-05 05:43:22.118523
7719	141	5	3.412500	2025-12-05 05:43:22.118523
7720	141	4	20.312500	2025-12-05 05:43:22.118523
7721	141	2	3.875000	2025-12-05 05:43:22.118523
7722	141	26	1.875000	2025-12-05 05:43:22.118523
7723	141	3	0.275000	2025-12-05 05:43:22.118523
7724	141	22	59.625000	2025-12-05 05:43:22.118523
7725	142	4	2.259259	2025-12-05 05:43:22.118523
7726	142	3	2.085185	2025-12-05 05:43:22.118523
7727	142	10	26.111111	2025-12-05 05:43:22.118523
7728	142	1	68.296296	2025-12-05 05:43:22.118523
7729	142	5	0.266667	2025-12-05 05:43:22.118523
7730	142	2	9.470370	2025-12-05 05:43:22.118523
7731	142	15	1.977778	2025-12-05 05:43:22.118523
7732	142	27	31.074074	2025-12-05 05:43:22.118523
7733	142	23	0.833333	2025-12-05 05:43:22.118523
7734	142	24	6.703704	2025-12-05 05:43:22.118523
7735	143	25	21.500000	2025-12-05 05:43:22.118523
7736	143	29	0.270000	2025-12-05 05:43:22.118523
7737	143	4	13.220000	2025-12-05 05:43:22.118523
7738	143	30	0.600000	2025-12-05 05:43:22.118523
7739	143	3	2.005000	2025-12-05 05:43:22.118523
7740	143	10	18.000000	2025-12-05 05:43:22.118523
7741	143	1	100.475000	2025-12-05 05:43:22.118523
7742	143	5	0.560000	2025-12-05 05:43:22.118523
7743	143	2	7.117500	2025-12-05 05:43:22.118523
7744	143	15	0.442500	2025-12-05 05:43:22.118523
7745	143	26	3.500000	2025-12-05 05:43:22.118523
7746	143	27	24.000000	2025-12-05 05:43:22.118523
7747	143	24	2.475000	2025-12-05 05:43:22.118523
7748	143	11	1252.950000	2025-12-05 05:43:22.118523
7749	144	25	24.571429	2025-12-05 05:43:22.118523
7750	144	4	14.285714	2025-12-05 05:43:22.118523
7751	144	3	1.171429	2025-12-05 05:43:22.118523
7752	144	10	13.428571	2025-12-05 05:43:22.118523
7753	144	1	92.285714	2025-12-05 05:43:22.118523
7754	144	5	0.400000	2025-12-05 05:43:22.118523
7755	144	2	5.714286	2025-12-05 05:43:22.118523
7756	144	26	4.000000	2025-12-05 05:43:22.118523
7757	144	23	0.428571	2025-12-05 05:43:22.118523
7758	145	25	25.454545	2025-12-05 05:43:22.118523
7759	145	4	6.239394	2025-12-05 05:43:22.118523
7760	145	3	1.069697	2025-12-05 05:43:22.118523
7761	145	1	37.878788	2025-12-05 05:43:22.118523
7762	145	5	0.457576	2025-12-05 05:43:22.118523
7763	145	2	1.675758	2025-12-05 05:43:22.118523
7764	145	15	6.127273	2025-12-05 05:43:22.118523
7765	145	27	262.666667	2025-12-05 05:43:22.118523
7766	145	24	34.242424	2025-12-05 05:43:22.118523
7767	145	11	5157.575758	2025-12-05 05:43:22.118523
7768	146	1	37.307692	2025-12-05 05:43:22.118523
7769	146	25	52.923077	2025-12-05 05:43:22.118523
7770	146	5	2.492308	2025-12-05 05:43:22.118523
7771	146	4	7.692308	2025-12-05 05:43:22.118523
7772	146	2	2.253846	2025-12-05 05:43:22.118523
7773	146	15	2.269231	2025-12-05 05:43:22.118523
7774	146	27	342.153846	2025-12-05 05:43:22.118523
7775	146	3	0.261538	2025-12-05 05:43:22.118523
7776	146	24	12.692308	2025-12-05 05:43:22.118523
7777	146	11	6425.384615	2025-12-05 05:43:22.118523
7778	147	25	17.793103	2025-12-05 05:43:22.118523
7779	147	4	1.344828	2025-12-05 05:43:22.118523
7780	147	34	25.241379	2025-12-05 05:43:22.118523
7781	147	30	0.379310	2025-12-05 05:43:22.118523
7782	147	3	1.034483	2025-12-05 05:43:22.118523
7783	147	10	116.689655	2025-12-05 05:43:22.118523
7784	147	1	69.172414	2025-12-05 05:43:22.118523
7785	147	5	0.475862	2025-12-05 05:43:22.118523
7786	147	2	11.944828	2025-12-05 05:43:22.118523
7787	147	27	73.655172	2025-12-05 05:43:22.118523
7788	148	1	20.000000	2025-12-05 05:43:22.118523
7789	148	2	1.771429	2025-12-05 05:43:22.118523
7790	148	3	0.171429	2025-12-05 05:43:22.118523
7791	148	4	3.714286	2025-12-05 05:43:22.118523
7792	148	5	1.314286	2025-12-05 05:43:22.118523
7793	148	25	49.142857	2025-12-05 05:43:22.118523
7794	148	27	203.428571	2025-12-05 05:43:22.118523
7795	149	29	1.344828	2025-12-05 05:43:22.118523
7796	149	4	1.200000	2025-12-05 05:43:22.118523
7797	149	30	2.327586	2025-12-05 05:43:22.118523
7798	149	3	5.296552	2025-12-05 05:43:22.118523
7799	149	10	32.068966	2025-12-05 05:43:22.118523
7800	149	1	96.724138	2025-12-05 05:43:22.118523
7801	149	5	0.517241	2025-12-05 05:43:22.118523
7802	149	2	10.613793	2025-12-05 05:43:22.118523
7803	149	15	7.572414	2025-12-05 05:43:22.118523
7804	149	27	35.172414	2025-12-05 05:43:22.118523
7805	149	23	1.344828	2025-12-05 05:43:22.118523
7806	149	24	8.275862	2025-12-05 05:43:22.118523
7807	150	25	9.347826	2025-12-05 05:43:22.118523
7808	150	29	0.234783	2025-12-05 05:43:22.118523
7809	150	4	5.434783	2025-12-05 05:43:22.118523
7810	150	34	13.217391	2025-12-05 05:43:22.118523
7811	150	30	0.904348	2025-12-05 05:43:22.118523
7812	150	3	2.278261	2025-12-05 05:43:22.118523
7813	150	10	68.521739	2025-12-05 05:43:22.118523
7814	150	1	97.869565	2025-12-05 05:43:22.118523
7815	150	5	0.152174	2025-12-05 05:43:22.118523
7816	150	2	12.800000	2025-12-05 05:43:22.118523
7817	150	26	1.521739	2025-12-05 05:43:22.118523
7818	151	1	143.461538	2025-12-05 05:43:22.118523
7819	151	2	19.415385	2025-12-05 05:43:22.118523
7820	151	3	5.853846	2025-12-05 05:43:22.118523
7821	151	4	2.546154	2025-12-05 05:43:22.118523
7822	151	5	0.161538	2025-12-05 05:43:22.118523
7823	151	10	55.384615	2025-12-05 05:43:22.118523
7824	151	15	2.400000	2025-12-05 05:43:22.118523
7825	151	24	13.923077	2025-12-05 05:43:22.118523
7826	151	27	30.846154	2025-12-05 05:43:22.118523
7827	151	29	0.830769	2025-12-05 05:43:22.118523
7828	151	30	1.846154	2025-12-05 05:43:22.118523
7829	1000	2	13.415000	2025-12-05 05:43:22.118523
7830	1000	3	17.865000	2025-12-05 05:43:22.118523
7831	1000	4	16.075000	2025-12-05 05:43:22.118523
7832	1000	14	17.655000	2025-12-05 05:43:22.118523
7833	1000	15	11.100000	2025-12-05 05:43:22.118523
7834	1000	24	23.700000	2025-12-05 05:43:22.118523
7835	1000	29	14.810000	2025-12-05 05:43:22.118523
7836	1000	30	21.535000	2025-12-05 05:43:22.118523
7837	1001	2	13.415000	2025-12-05 05:43:22.118523
7838	1001	3	17.865000	2025-12-05 05:43:22.118523
7839	1001	4	20.940000	2025-12-05 05:43:22.118523
7840	1001	14	37.210000	2025-12-05 05:43:22.118523
7841	1001	15	11.100000	2025-12-05 05:43:22.118523
7842	1001	24	23.700000	2025-12-05 05:43:22.118523
7843	1001	26	17.200000	2025-12-05 05:43:22.118523
7844	1001	28	18.620000	2025-12-05 05:43:22.118523
7845	1001	29	14.810000	2025-12-05 05:43:22.118523
7846	1001	30	21.535000	2025-12-05 05:43:22.118523
7847	1002	2	13.415000	2025-12-05 05:43:22.118523
7848	1002	3	17.865000	2025-12-05 05:43:22.118523
7849	1002	4	16.075000	2025-12-05 05:43:22.118523
7850	1002	14	17.655000	2025-12-05 05:43:22.118523
7851	1002	15	19.065000	2025-12-05 05:43:22.118523
7852	1002	24	23.700000	2025-12-05 05:43:22.118523
7853	1002	26	16.655000	2025-12-05 05:43:22.118523
7854	1002	27	0.945000	2025-12-05 05:43:22.118523
7855	1002	28	0.890000	2025-12-05 05:43:22.118523
7856	1002	29	14.810000	2025-12-05 05:43:22.118523
7857	1002	30	21.535000	2025-12-05 05:43:22.118523
7858	1003	2	13.415000	2025-12-05 05:43:22.118523
7859	1003	3	17.865000	2025-12-05 05:43:22.118523
7860	1003	4	16.075000	2025-12-05 05:43:22.118523
7861	1003	14	17.655000	2025-12-05 05:43:22.118523
7862	1003	15	11.100000	2025-12-05 05:43:22.118523
7863	1003	24	23.700000	2025-12-05 05:43:22.118523
7864	1003	29	14.810000	2025-12-05 05:43:22.118523
7865	1003	30	21.535000	2025-12-05 05:43:22.118523
7866	1005	2	13.415000	2025-12-05 05:43:22.118523
7867	1005	3	17.865000	2025-12-05 05:43:22.118523
7868	1005	4	16.075000	2025-12-05 05:43:22.118523
7869	1005	14	17.655000	2025-12-05 05:43:22.118523
7870	1005	15	11.100000	2025-12-05 05:43:22.118523
7871	1005	24	23.700000	2025-12-05 05:43:22.118523
7872	1005	29	14.810000	2025-12-05 05:43:22.118523
7873	1005	30	21.535000	2025-12-05 05:43:22.118523
7874	1006	4	9.730000	2025-12-05 05:43:22.118523
7875	1006	14	39.110000	2025-12-05 05:43:22.118523
7876	1006	26	34.400000	2025-12-05 05:43:22.118523
7877	1006	28	37.240000	2025-12-05 05:43:22.118523
7878	1007	4	40.810000	2025-12-05 05:43:22.118523
7879	1007	5	2.480000	2025-12-05 05:43:22.118523
7880	1007	24	47.010000	2025-12-05 05:43:22.118523
7881	1007	26	45.720000	2025-12-05 05:43:22.118523
7882	1007	27	35.120000	2025-12-05 05:43:22.118523
7883	1007	28	42.620000	2025-12-05 05:43:22.118523
7884	1008	2	13.415000	2025-12-05 05:43:22.118523
7885	1008	3	17.865000	2025-12-05 05:43:22.118523
7886	1008	4	16.075000	2025-12-05 05:43:22.118523
7887	1008	14	17.655000	2025-12-05 05:43:22.118523
7888	1008	15	11.100000	2025-12-05 05:43:22.118523
7889	1008	24	23.700000	2025-12-05 05:43:22.118523
7890	1008	29	14.810000	2025-12-05 05:43:22.118523
7891	1008	30	21.535000	2025-12-05 05:43:22.118523
7892	1009	2	13.415000	2025-12-05 05:43:22.118523
7893	1009	3	17.865000	2025-12-05 05:43:22.118523
7894	1009	4	16.075000	2025-12-05 05:43:22.118523
7895	1009	14	17.655000	2025-12-05 05:43:22.118523
7896	1009	15	11.100000	2025-12-05 05:43:22.118523
7897	1009	24	23.700000	2025-12-05 05:43:22.118523
7898	1009	29	14.810000	2025-12-05 05:43:22.118523
7899	1009	30	21.535000	2025-12-05 05:43:22.118523
7900	1010	2	13.415000	2025-12-05 05:43:22.118523
7901	1010	3	17.865000	2025-12-05 05:43:22.118523
7902	1010	4	16.075000	2025-12-05 05:43:22.118523
7903	1010	14	17.655000	2025-12-05 05:43:22.118523
7904	1010	15	11.100000	2025-12-05 05:43:22.118523
7905	1010	24	23.700000	2025-12-05 05:43:22.118523
7906	1010	29	14.810000	2025-12-05 05:43:22.118523
7907	1010	30	21.535000	2025-12-05 05:43:22.118523
7908	1011	4	4.865000	2025-12-05 05:43:22.118523
7909	1011	14	19.555000	2025-12-05 05:43:22.118523
7910	1011	26	17.200000	2025-12-05 05:43:22.118523
7911	1011	28	18.620000	2025-12-05 05:43:22.118523
7912	1012	25	60.750000	2025-12-05 05:43:22.118523
7913	1012	4	13.656250	2025-12-05 05:43:22.118523
7914	1012	3	0.431250	2025-12-05 05:43:22.118523
7915	1012	1	62.562500	2025-12-05 05:43:22.118523
7916	1012	5	1.706250	2025-12-05 05:43:22.118523
7917	1012	2	1.568750	2025-12-05 05:43:22.118523
7918	1012	15	4.656250	2025-12-05 05:43:22.118523
7919	1012	26	16.125000	2025-12-05 05:43:22.118523
7920	1012	27	206.250000	2025-12-05 05:43:22.118523
7921	1012	24	10.312500	2025-12-05 05:43:22.118523
7922	1012	11	7880.000000	2025-12-05 05:43:22.118523
7923	1014	2	13.415000	2025-12-05 05:43:22.118523
7924	1014	3	17.865000	2025-12-05 05:43:22.118523
7925	1014	4	16.075000	2025-12-05 05:43:22.118523
7926	1014	14	17.655000	2025-12-05 05:43:22.118523
7927	1014	15	11.100000	2025-12-05 05:43:22.118523
7928	1014	24	23.700000	2025-12-05 05:43:22.118523
7929	1014	29	14.810000	2025-12-05 05:43:22.118523
7930	1014	30	21.535000	2025-12-05 05:43:22.118523
7931	1015	2	13.415000	2025-12-05 05:43:22.118523
7932	1015	3	17.865000	2025-12-05 05:43:22.118523
7933	1015	4	16.075000	2025-12-05 05:43:22.118523
7934	1015	14	17.655000	2025-12-05 05:43:22.118523
7935	1015	15	11.100000	2025-12-05 05:43:22.118523
7936	1015	24	23.700000	2025-12-05 05:43:22.118523
7937	1015	29	14.810000	2025-12-05 05:43:22.118523
7938	1015	30	21.535000	2025-12-05 05:43:22.118523
7939	1016	4	9.730000	2025-12-05 05:43:22.118523
7940	1016	14	39.110000	2025-12-05 05:43:22.118523
7941	1016	26	34.400000	2025-12-05 05:43:22.118523
7942	1016	28	37.240000	2025-12-05 05:43:22.118523
7943	1018	2	13.415000	2025-12-05 05:43:22.118523
7944	1018	3	17.865000	2025-12-05 05:43:22.118523
7945	1018	4	36.480000	2025-12-05 05:43:22.118523
7946	1018	5	1.240000	2025-12-05 05:43:22.118523
7947	1018	14	17.655000	2025-12-05 05:43:22.118523
7948	1018	15	11.100000	2025-12-05 05:43:22.118523
7949	1018	24	47.205000	2025-12-05 05:43:22.118523
7950	1018	26	22.860000	2025-12-05 05:43:22.118523
7951	1018	27	17.560000	2025-12-05 05:43:22.118523
7952	1018	28	21.310000	2025-12-05 05:43:22.118523
7953	1018	29	14.810000	2025-12-05 05:43:22.118523
7954	1018	30	21.535000	2025-12-05 05:43:22.118523
7955	1020	1	86.000000	2025-12-05 05:43:22.118523
7956	1020	2	1.600000	2025-12-05 05:43:22.118523
7957	1020	3	0.100000	2025-12-05 05:43:22.118523
7958	1020	4	20.100000	2025-12-05 05:43:22.118523
7959	1020	5	3.000000	2025-12-05 05:43:22.118523
7960	1020	11	14187.000000	2025-12-05 05:43:22.118523
7961	1020	15	2.400000	2025-12-05 05:43:22.118523
7962	1020	27	337.000000	2025-12-05 05:43:22.118523
7963	1021	15	15.930000	2025-12-05 05:43:22.118523
7964	1021	26	33.310000	2025-12-05 05:43:22.118523
7965	1021	27	1.890000	2025-12-05 05:43:22.118523
7966	1021	28	1.780000	2025-12-05 05:43:22.118523
7967	1022	2	13.415000	2025-12-05 05:43:22.118523
7968	1022	3	17.865000	2025-12-05 05:43:22.118523
7969	1022	4	16.075000	2025-12-05 05:43:22.118523
7970	1022	14	17.655000	2025-12-05 05:43:22.118523
7971	1022	15	11.100000	2025-12-05 05:43:22.118523
7972	1022	24	23.700000	2025-12-05 05:43:22.118523
7973	1022	29	14.810000	2025-12-05 05:43:22.118523
7974	1022	30	21.535000	2025-12-05 05:43:22.118523
7975	1023	29	1.468085	2025-12-05 05:43:22.118523
7976	1023	4	3.257447	2025-12-05 05:43:22.118523
7977	1023	34	11.234043	2025-12-05 05:43:22.118523
7978	1023	3	0.576596	2025-12-05 05:43:22.118523
7979	1023	10	54.808511	2025-12-05 05:43:22.118523
7980	1023	1	51.553191	2025-12-05 05:43:22.118523
7981	1023	5	1.321277	2025-12-05 05:43:22.118523
7982	1023	2	8.719149	2025-12-05 05:43:22.118523
7983	1023	15	28.110638	2025-12-05 05:43:22.118523
7984	1023	27	8.531915	2025-12-05 05:43:22.118523
7985	1023	24	141.085106	2025-12-05 05:43:22.118523
7986	1023	11	1861.914894	2025-12-05 05:43:22.118523
7987	1024	4	4.865000	2025-12-05 05:43:22.118523
7988	1024	14	19.555000	2025-12-05 05:43:22.118523
7989	1024	26	17.200000	2025-12-05 05:43:22.118523
7990	1024	28	18.620000	2025-12-05 05:43:22.118523
7991	1025	4	40.810000	2025-12-05 05:43:22.118523
7992	1025	5	2.480000	2025-12-05 05:43:22.118523
7993	1025	24	47.010000	2025-12-05 05:43:22.118523
7994	1025	26	45.720000	2025-12-05 05:43:22.118523
7995	1025	27	35.120000	2025-12-05 05:43:22.118523
7996	1025	28	42.620000	2025-12-05 05:43:22.118523
7997	1026	4	40.810000	2025-12-05 05:43:22.118523
7998	1026	5	2.480000	2025-12-05 05:43:22.118523
7999	1026	24	47.010000	2025-12-05 05:43:22.118523
8000	1026	26	45.720000	2025-12-05 05:43:22.118523
8001	1026	27	35.120000	2025-12-05 05:43:22.118523
8002	1026	28	42.620000	2025-12-05 05:43:22.118523
8003	1027	1	27.826087	2025-12-05 05:43:22.118523
8004	1027	2	1.013043	2025-12-05 05:43:22.118523
8005	1027	3	0.100000	2025-12-05 05:43:22.118523
8006	1027	4	6.865217	2025-12-05 05:43:22.118523
8007	1027	5	0.656522	2025-12-05 05:43:22.118523
8008	1027	11	7400.000000	2025-12-05 05:43:22.118523
8009	1027	15	8.791304	2025-12-05 05:43:22.118523
8010	1027	27	314.695652	2025-12-05 05:43:22.118523
8011	1028	2	26.830000	2025-12-05 05:43:22.118523
8012	1028	3	35.730000	2025-12-05 05:43:22.118523
8013	1028	4	32.150000	2025-12-05 05:43:22.118523
8014	1028	14	35.310000	2025-12-05 05:43:22.118523
8015	1028	15	22.200000	2025-12-05 05:43:22.118523
8016	1028	24	47.400000	2025-12-05 05:43:22.118523
8017	1028	29	29.620000	2025-12-05 05:43:22.118523
8018	1028	30	43.070000	2025-12-05 05:43:22.118523
8019	1029	2	26.830000	2025-12-05 05:43:22.118523
8020	1029	3	35.730000	2025-12-05 05:43:22.118523
8021	1029	4	32.150000	2025-12-05 05:43:22.118523
8022	1029	14	35.310000	2025-12-05 05:43:22.118523
8023	1029	15	22.200000	2025-12-05 05:43:22.118523
8024	1029	24	47.400000	2025-12-05 05:43:22.118523
8025	1029	29	29.620000	2025-12-05 05:43:22.118523
8026	1029	30	43.070000	2025-12-05 05:43:22.118523
\.


--
-- TOC entry 6630 (class 0 OID 22776)
-- Dependencies: 356
-- Data for Name: dishstatistics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dishstatistics (stat_id, dish_id, total_times_logged, unique_users_count, avg_rating, last_logged_at, updated_at) FROM stdin;
\.


--
-- TOC entry 6650 (class 0 OID 23793)
-- Dependencies: 379
-- Data for Name: drink; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drink (drink_id, name, vietnamese_name, slug, description, category, base_liquid, default_volume_ml, default_temperature, default_sweetness, hydration_ratio, caffeine_mg, sugar_free, is_template, is_public, image_url, created_by_user, created_by_admin, created_at, updated_at) FROM stdin;
1	Fresh Orange Juice	Nước Cam Vắt	\N	Nước cam tươi vắt, giàu vitamin C	Juice	Water	250.00	Cold	normal	0.95	0.00	t	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
2	Sugarcane Juice	Nước Mía	\N	Nước mía ép tươi, ngọt mát	Juice	Water	300.00	Cold	normal	0.92	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
3	Coconut Water	Nước Dừa Tươi	\N	Nước dừa tươi, bổ sung điện giải	Juice	Water	350.00	Cold	normal	0.98	0.00	t	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
4	Lemon Tea	Trà Chanh	\N	Trà đen pha chanh, ít đường	Tea	Water	300.00	Cold	normal	0.96	25.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
5	Vietnamese Black Coffee	Cà Phê Đen	\N	Cà phê phin truyền thống, đắng	Coffee	Water	100.00	Hot	normal	0.99	95.00	t	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
6	Vietnamese Milk Coffee	Cà Phê Sữa	\N	Cà phê phin với sữa đặc	Coffee	Milk	150.00	Hot	normal	0.94	85.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
7	Iced Milk Coffee	Cà Phê Sữa Đá	\N	Cà phê sữa pha đá	Coffee	Milk	200.00	Cold	normal	0.92	80.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
8	Green Tea	Trà Xanh	\N	Trà xanh không đường	Tea	Water	250.00	Hot	normal	0.99	30.00	t	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
9	Lotus Tea	Trà Sen	\N	Trà sen thơm dịu	Tea	Water	250.00	Hot	normal	0.99	20.00	t	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
10	Jasmine Tea	Trà Nhài	\N	Trà hoa nhài thơm	Tea	Water	250.00	Hot	normal	0.99	22.00	t	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
11	Avocado Smoothie	Sinh Tố Bơ	\N	Sinh tố bơ với sữa đặc	Smoothie	Milk	350.00	Cold	normal	0.88	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
12	Banana Smoothie	Sinh Tố Chuối	\N	Sinh tố chuối với sữa tươi	Smoothie	Milk	350.00	Cold	normal	0.90	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
13	Mango Smoothie	Sinh Tố Xoài	\N	Sinh tố xoài tươi	Smoothie	Milk	350.00	Cold	normal	0.89	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
14	Soy Milk	Sữa Đậu Nành	\N	Sữa đậu nành tươi, giàu protein	Milk	Water	250.00	Warm	normal	0.93	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
15	Ginger Tea	Trà Gừng	\N	Trà gừng ấm bụng	Tea	Water	200.00	Hot	normal	0.98	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
16	Chrysanthemum Tea	Trà Hoa Cúc	\N	Trà hoa cúc mát gan	Tea	Water	250.00	Cold	normal	0.99	0.00	t	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
17	Barley Water	Nước Lúa Mạch	\N	Nước lúa mạch mát, giải nhiệt	Healthy	Water	300.00	Cold	normal	0.97	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
18	Artichoke Tea	Trà Atiso	\N	Trà atiso giải độc gan	Healthy	Water	250.00	Warm	normal	0.98	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
19	Pennywort Juice	Nước Rau Má	\N	Nước rau má thanh mát	Healthy	Water	250.00	Cold	normal	0.96	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
20	Plain Water	Nước Lọc	\N	Nước lọc tinh khiết	Water	Water	250.00	Room	normal	1.00	0.00	t	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
21	Egg Coffee	Cà Phê Trứng	\N	Cà phê đen pha với kem trứng gà	Coffee	Milk	150.00	Hot	normal	0.90	85.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
22	Coconut Coffee	Cà Phê Cốt Dừa	\N	Cà phê pha với cốt dừa	Coffee	Milk	200.00	Cold	normal	0.88	75.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
23	Fresh Lemon Juice	Nước Chanh Tươi	\N	Nước chanh vắt tươi với mật ong	Juice	Water	250.00	Cold	normal	0.97	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
24	Passion Fruit Juice	Nước Chanh Dây	\N	Nước chanh leo tươi mát	Juice	Water	250.00	Cold	normal	0.95	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
25	Tamarind Juice	Nước Me	\N	Nước me chua ngọt	Juice	Water	250.00	Cold	normal	0.94	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
26	Soursop Smoothie	Sinh Tố Mãng Cầu	\N	Sinh tố mãng cầu xiêm với sữa	Smoothie	Milk	350.00	Cold	normal	0.89	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
27	Dragon Fruit Smoothie	Sinh Tố Thanh Long	\N	Sinh tố thanh long ruột đỏ	Smoothie	Milk	350.00	Cold	normal	0.91	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
28	Papaya Smoothie	Sinh Tố Đu Đủ	\N	Sinh tố đu đủ chín với sữa tươi	Smoothie	Milk	350.00	Cold	normal	0.90	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
29	Watermelon Juice	Nước Dưa Hấu	\N	Nước dưa hấu ép tươi	Juice	Water	300.00	Cold	normal	0.97	0.00	t	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
30	Sugarcane with Kumquat	Nước Mía Tắc	\N	Nước mía pha với tắc	Juice	Water	300.00	Cold	normal	0.93	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
31	Iced Tea with Lemon	Trà Đá Chanh	\N	Trà đen pha đá với chanh	Tea	Water	300.00	Cold	normal	0.98	20.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
32	Peach Tea	Trà Đào	\N	Trà đào ngọt mát	Tea	Water	300.00	Cold	normal	0.96	15.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
33	Kumquat Honey Tea	Trà Tắc Mật Ong	\N	Trà tắc pha mật ong ấm	Tea	Water	250.00	Warm	normal	0.97	18.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
34	Young Rice Milk	Nước Cốm	\N	Nước uống từ cốm xanh	Healthy	Water	250.00	Cold	normal	0.95	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
35	Herbal Tea	Trà Thảo Mộc	\N	Trà các loại thảo mộc Việt Nam	Healthy	Water	250.00	Warm	normal	0.99	0.00	t	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
36	Wintermelon Tea	Trà Bí Đao	\N	Trà bí đao mát gan	Healthy	Water	250.00	Cold	normal	0.97	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
37	Black Sesame Milk	Sữa Mè Đen	\N	Sữa mè đen bổ dưỡng	Milk	Water	250.00	Warm	normal	0.92	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
38	Peanut Milk	Sữa Đậu Phộng	\N	Sữa đậu phộng thơm béo	Milk	Water	250.00	Warm	normal	0.93	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
39	Three-bean Sweet Soup	Chè Ba Màu	\N	Chè đậu xanh, đậu đỏ, đậu đen	Dessert	Milk	300.00	Cold	normal	0.85	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
40	Grass Jelly Drink	Sương Sáo	\N	Thạch sương sáo với đường phèn	Dessert	Water	250.00	Cold	normal	0.96	0.00	f	t	t	\N	\N	1	2025-12-01 00:23:21.454085-08	2025-12-01 00:23:21.454085-08
\.


--
-- TOC entry 6652 (class 0 OID 23831)
-- Dependencies: 381
-- Data for Name: drinkingredient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drinkingredient (drink_ingredient_id, drink_id, food_id, amount_g, unit, display_order, notes) FROM stdin;
130	1	3005	200.00	ml	1	Nước cam ép tươi
131	3	3	300.00	ml	1	Nước dừa tươi
132	6	3010	50.00	ml	1	Sữa đặc ngọt
133	11	99	80.00	g	1	Bơ tươi
134	11	3010	150.00	ml	2	Sữa tươi
135	12	3004	100.00	g	1	Chuối chín
136	12	3010	150.00	ml	2	Sữa tươi
137	14	2	50.00	g	1	Đậu nành
138	19	3017	80.00	g	1	Rau má tươi
\.


--
-- TOC entry 6654 (class 0 OID 23861)
-- Dependencies: 383
-- Data for Name: drinknutrient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drinknutrient (drink_nutrient_id, drink_id, nutrient_id, amount_per_100ml) FROM stdin;
2121	3	14	19.294286
2122	3	15	23.228571
2125	3	29	31.817143
2127	6	23	0.150000
2129	6	27	50.000000
2139	11	23	0.192857
2141	11	26	63.771429
2143	11	29	0.797714
2153	12	15	2.485714
2154	12	23	0.192857
2156	12	26	7.714286
2161	14	5	8.024000
2163	14	26	4.838000
2164	14	28	8.310000
2166	19	2	0.832000
2167	19	14	99.840000
2170	19	29	0.800000
2171	1	1	45.000000
2117	1	4	10.400000
2118	1	15	50.000000
2120	1	27	200.000000
2119	1	24	11.000000
2175	2	1	72.000000
2176	2	4	18.000000
2225	2	15	8.000000
2178	2	24	18.000000
2227	2	26	12.000000
2177	2	27	142.000000
2179	3	1	19.000000
2180	3	4	3.700000
2123	3	24	24.000000
2183	3	26	25.000000
2124	3	27	250.000000
2182	3	28	105.000000
2184	4	1	28.000000
2185	4	4	7.000000
2186	4	15	15.000000
2187	5	1	2.000000
2188	5	4	0.000000
2189	5	27	115.000000
2190	6	1	85.000000
2126	6	2	2.800000
2243	6	3	3.500000
2191	6	4	12.500000
2128	6	24	45.000000
2194	7	1	68.000000
2196	7	2	2.200000
2248	7	3	2.800000
2195	7	4	10.000000
2197	7	24	36.000000
2251	21	1	145.000000
2252	21	2	4.500000
2253	21	3	9.500000
2254	21	4	12.000000
2255	21	24	55.000000
2256	21	23	0.350000
2257	22	1	125.000000
2258	22	2	1.800000
2259	22	3	8.500000
2260	22	4	14.000000
2261	22	26	18.000000
2198	8	1	0.000000
2199	8	4	0.000000
2200	8	27	8.000000
2265	9	1	1.000000
2266	9	4	0.200000
2267	10	1	1.000000
2268	10	4	0.200000
2269	31	1	22.000000
2270	31	4	5.500000
2271	31	15	12.000000
2272	32	1	38.000000
2273	32	4	9.500000
2274	32	15	8.500000
2275	33	1	52.000000
2276	33	4	13.000000
2277	33	15	42.000000
2278	35	1	2.000000
2279	35	4	0.500000
2280	36	1	25.000000
2281	36	4	6.000000
2201	11	1	165.000000
2137	11	2	2.800000
2138	11	3	12.500000
2204	11	4	11.200000
2286	11	5	2.500000
2140	11	24	85.000000
2142	11	27	180.000000
2206	12	1	95.000000
2151	12	2	3.500000
2291	12	3	2.500000
2152	12	4	18.500000
2293	12	5	2.000000
2155	12	24	72.000000
2157	12	27	215.000000
2296	13	1	88.000000
2297	13	2	3.200000
2298	13	3	2.000000
2299	13	4	17.000000
2300	13	11	54.000000
2301	13	15	36.500000
2302	13	24	65.000000
2303	26	1	95.000000
2304	26	2	2.500000
2305	26	4	20.000000
2306	26	5	2.200000
2307	26	15	55.000000
2308	26	24	65.000000
2309	27	1	78.000000
2310	27	2	2.800000
2311	27	4	16.500000
2312	27	5	1.800000
2313	27	15	28.000000
2314	27	24	58.000000
2315	28	1	88.000000
2316	28	2	3.200000
2317	28	4	18.000000
2318	28	5	2.000000
2319	28	11	95.000000
2320	28	15	62.000000
2321	28	24	68.000000
2211	14	1	54.000000
2158	14	2	3.300000
2159	14	3	1.900000
2160	14	4	6.000000
2162	14	24	25.000000
2165	14	29	1.200000
2328	15	1	18.000000
2329	15	4	4.500000
2330	15	26	8.000000
2331	16	1	3.000000
2332	16	4	0.800000
2333	17	1	28.000000
2334	17	4	7.000000
2335	17	5	1.500000
2336	17	26	12.000000
2337	18	1	15.000000
2338	18	4	3.500000
2339	18	27	85.000000
2340	19	1	12.000000
2341	19	4	2.800000
2168	19	15	8.000000
2169	19	24	18.000000
2216	20	1	0.000000
2217	20	4	0.000000
2346	23	1	35.000000
2347	23	4	8.500000
2348	23	15	45.000000
2349	23	27	85.000000
2350	24	1	42.000000
2351	24	4	10.000000
2352	24	15	38.000000
2353	24	27	95.000000
2354	25	1	48.000000
2355	25	4	12.000000
2356	25	15	15.000000
2357	25	24	22.000000
2358	25	27	125.000000
2359	29	1	30.000000
2360	29	4	7.500000
2361	29	5	0.400000
2362	29	15	8.000000
2363	29	27	112.000000
2364	30	1	78.000000
2365	30	4	19.500000
2366	30	15	35.000000
2367	30	27	148.000000
2368	34	1	65.000000
2369	34	2	1.500000
2370	34	4	15.500000
2371	34	5	1.200000
2372	37	1	115.000000
2373	37	2	4.800000
2374	37	3	7.500000
2375	37	4	8.500000
2376	37	24	95.000000
2377	37	26	35.000000
2378	37	29	2.500000
2379	38	1	98.000000
2380	38	2	4.200000
2381	38	3	5.500000
2382	38	4	9.000000
2383	38	24	45.000000
2384	38	26	28.000000
2385	39	1	135.000000
2386	39	2	5.500000
2387	39	3	3.500000
2388	39	4	28.000000
2389	39	5	2.800000
2390	39	24	75.000000
2391	39	26	32.000000
2392	40	1	32.000000
2393	40	4	8.000000
2394	40	5	0.800000
2395	40	24	12.000000
\.


--
-- TOC entry 6656 (class 0 OID 23886)
-- Dependencies: 385
-- Data for Name: drinkstatistics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drinkstatistics (stat_id, drink_id, log_count, unique_users, last_logged_at, updated_at) FROM stdin;
\.


--
-- TOC entry 6658 (class 0 OID 23970)
-- Dependencies: 387
-- Data for Name: drug; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drug (drug_id, name_vi, name_en, generic_name, drug_class, description, image_url, source_link, dosage_form, is_active, created_by_admin, created_at, updated_at, description_vi, brand_name_vi, brand_name_en, active_ingredient, therapeutic_class, strength, packaging, indications_vi, indications_en, dosage_adult_vi, dosage_adult_en, dosage_pediatric_vi, dosage_pediatric_en, dosage_special_vi, dosage_special_en, contraindications_vi, contraindications_en, warnings_vi, warnings_en, black_box_warning_vi, black_box_warning_en, common_side_effects_vi, common_side_effects_en, serious_side_effects_vi, serious_side_effects_en, mechanism_of_action_vi, mechanism_of_action_en, pharmacokinetics_vi, pharmacokinetics_en, overdose_symptoms_vi, overdose_symptoms_en, overdose_treatment_vi, overdose_treatment_en, pregnancy_category, pregnancy_notes_vi, pregnancy_notes_en, lactation_notes_vi, lactation_notes_en, storage_conditions_vi, storage_conditions_en, article_link_vi, article_link_en, reference_sources) FROM stdin;
25	Digoxin	Digoxin	Digoxin	Thuốc tim mạch	Thuốc tăng sức co bóp tim, điều trị suy tim và rung nhĩ	\N	\N	Viên nén, dung dịch tiêm	t	\N	2025-12-04 20:03:55.583462	2025-12-04 23:17:50.462674	\N	Lanoxin	Lanoxin	\N	Cardiac Glycoside - Tăng co bóp tim	0.25mg (viên); 0.25mg/ml (tiêm)	Hộp 10 vỉ x 10 viên hoặc ống tiêm 2ml	Suy tim mạn tính với rung nhĩ. Rung nhĩ mạn tính (kiểm soát nhịp thất). Cuồng nhĩ.	Chronic heart failure with atrial fibrillation. Chronic atrial fibrillation (rate control). Atrial flutter.	Liều nạp: 0.75-1.5mg chia nhiều lần trong 24h. Liều duy trì: 0.125-0.25mg/ngày. Người cao tuổi: 0.0625-0.125mg/ngày.	Loading: 0.75-1.5mg divided over 24h. Maintenance: 0.125-0.25mg/day. Elderly: 0.0625-0.125mg/day.	Trẻ sơ sinh: Liều nạp 20-30 mcg/kg, duy trì 5-10 mcg/kg/ngày. Trẻ > 10 tuổi: Như người lớn.	\N	Suy thận: Giảm liều. CrCl 10-50: Giảm 25-75%. CrCl <10: Giảm 50-75% hoặc tăng khoảng cách liều.	\N	Block nhĩ thất độ 2-3, hội chứng suy nút xoang, rối loạn nhịp thất, ngộ độc digitalis, WPW syndrome kèm rung nhĩ.	AV block 2nd-3rd degree, sick sinus syndrome, ventricular arrhythmias, digitalis toxicity, WPW with AF.	Cửa sổ điều trị hẹp. Theo dõi nồng độ digoxin máu, điện giải (K, Mg, Ca), ECG, chức năng thận. Hạ kali tăng nguy cơ độc tính.	Narrow therapeutic window. Monitor digoxin levels, electrolytes (K, Mg, Ca), ECG, renal function. Hypokalemia increases toxicity.	Nguy cơ ngộ độc digitalis cao, đặc biệt ở người cao tuổi, suy thận, mất điện giải. Theo dõi chặt chẽ.	\N	Buồn nôn, nôn, tiêu chảy, chán ăn, mệt mỏi, nhìn vàng/xanh (triệu chứng ngộ độc)	Nausea, vomiting, diarrhea, anorexia, fatigue, yellow/green vision (toxicity)	Rối loạn nhịp tim (block nhĩ thất, ngoại tâm thu thất, nhịp nhanh thất), ngộ độc digitalis, rối loạn tâm thần	Arrhythmias (AV block, ventricular ectopy, VT), digitalis toxicity, mental disturbances	Ức chế Na-K ATPase, tăng Ca nội bào, tăng co bóp cơ tim. Tác dụng phó giao cảm: chậm dẫn truyền nhĩ thất.	Inhibits Na-K ATPase, increases intracellular Ca, increases cardiac contractility. Parasympathetic effects: slows AV conduction.	Sinh khả dụng 70-80% (viên). Khởi phát: 0.5-2h (uống), 5-30 phút (IV). Thời gian tác dụng: 6-8 ngày. T1/2 = 36-48h (bình thường), dài hơn khi suy thận.	Bioavailability 70-80% (tablets). Onset: 0.5-2h (oral), 5-30min (IV). Duration: 6-8 days. T1/2 = 36-48h (normal), longer in renal impairment.	Buồn nôn/nôn nặng, rối loạn nhịp tim (bradycardia, block, arrhythmia), nhìn vàng, lú lẫn, hạ kali máu.	\N	Ngừng digoxin. Atropine cho bradycardia. Kháng thể kháng digoxin (Digibind) cho ngộ độc nặng. Bù kali (nếu hạ kali).	\N	C	Dùng khi cần thiết. Vượt qua nhau thai. Theo dõi nồng độ digoxin.	\N	Bài tiết vào sữa mẹ với nồng độ tương tự máu mẹ. Thận trọng.	\N	Bảo quản dưới 25°C, tránh ánh sáng và ẩm.	\N	https://www.vinmec.com/vie/benh/suy-tim/	https://www.ncbi.nlm.nih.gov/books/NBK556025/	\N
45	Canxi và Vitamin D	Calcium and Vitamin D	\N	Bổ sung vitamin khoáng	Bổ sung canxi và vitamin D phòng ngừa loãng xương	\N	\N	\N	t	\N	2025-12-04 20:06:00.00764	2025-12-04 20:06:00.00764	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
46	ORS (Oral Rehydration Salts)	ORS	\N	Điều trị tiêu chảy	Dung dịch bù nước điện giải điều trị tiêu chảy	\N	\N	\N	t	\N	2025-12-04 20:06:00.00764	2025-12-04 20:06:00.00764	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
47	Loperamide	Loperamide	\N	Điều trị tiêu chảy	Thuốc chống tiêu chảy	\N	\N	\N	t	\N	2025-12-04 20:06:00.00764	2025-12-04 20:06:00.00764	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
5	Amlodipine	Amlodipine	Amlodipine Besylate	Thuốc tim mạch	Thuốc chẹn kênh canxi, điều trị tăng huyết áp	\N	\N	Viên nén	t	\N	2025-12-04 20:03:55.583462	2025-12-04 23:08:02.584235	\N	Norvasc, Amlostad	\N	\N	Calcium Channel Blocker - Hạ huyết áp	5mg, 10mg	Hộp 3 vỉ x 10 viên	Điều trị tăng huyết áp, đau thắt ngực ổn định, đau thắt ngực Prinzmetal.	\N	Tăng huyết áp: Bắt đầu 5mg/ngày, có thể tăng lên 10mg/ngày. Đau thắt ngực: 5-10mg/ngày.	\N	Trẻ 6-17 tuổi: 2.5-5mg/ngày.	\N	Suy gan: Bắt đầu 2.5mg/ngày. Người cao tuổi: Bắt đầu 2.5mg/ngày.	\N	Quá mẫn amlodipine, hạ huyết áp nặng (<90/60 mmHg), sốc tim.	\N	Theo dõi huyết áp. Tăng tần suất đau thắt ngực khi bắt đầu điều trị (hiếm). Thận trọng ở bệnh nhân suy tim.	\N	\N	\N	Phù mắt cá chân, đau đầu, mệt mỏi, đỏ mặt, hồi hộp	\N	Phù nặng, hạ huyết áp nặng, nhồi máu cơ tim (rất hiếm)	\N	Ức chế dòng canxi vào tế bào cơ trơn mạch máu và cơ tim, gây giãn mạch, giảm sức cản ngoại vi, hạ huyết áp.	\N	Hấp thu chậm, đạt đỉnh sau 6-12h. Sinh khả dụng 64-90%. Liên kết protein 93%. Chuyển hóa gan. T1/2 = 30-50h.	\N	\N	\N	\N	\N	C	Dùng khi lợi ích > nguy cơ. Ưu tiên methyldopa, labetalol trong thai kỳ.	\N	Bài tiết vào sữa mẹ. Thận trọng khi cho con bú.	\N	Bảo quản dưới 30°C, nơi khô mát.	\N	https://www.vinmec.com/vie/benh/tang-huyet-ap/	https://www.ncbi.nlm.nih.gov/books/NBK519508/	\N
6	Losartan	Losartan	Losartan Potassium	Thuốc tim mạch	Thuốc chẹn thụ thể angiotensin II, điều trị tăng huyết áp	\N	\N	Viên nén bao phim	t	\N	2025-12-04 20:03:55.583462	2025-12-04 23:08:02.584235	\N	Cozaar, Losar	\N	\N	ARB (Angiotensin Receptor Blocker) - Hạ huyết áp	50mg, 100mg	Hộp 3 vỉ x 10 viên	Tăng huyết áp, suy tim, bảo vệ thận ở bệnh nhân đái tháo đường type 2 có protein niệu, giảm nguy cơ đột quỵ ở bệnh nhân tăng huyết áp có phì đại thất trái.	\N	Tăng huyết áp: 50mg/ngày, có thể tăng lên 100mg/ngày. Suy tim: Bắt đầu 12.5mg/ngày, tăng dần.	\N	Trẻ ≥6 tuổi: 0.7mg/kg/ngày (tối đa 50mg/ngày).	\N	Suy gan: Giảm liều khởi đầu xuống 25mg/ngày.	\N	Quá mẫn, thai kỳ (trimester 2-3), dùng kết hợp aliskiren ở bệnh nhân đái tháo đường.	\N	Nguy cơ hạ huyết áp, tăng kali máu, suy giảm chức năng thận. Theo dõi kali và creatinine.	\N	Chống chỉ định ở thai kỳ từ tháng thứ 4. Gây tổn thương thai nhi và tử vong.	\N	Chóng mặt, mệt mỏi, hạ huyết áp tư thế, tăng kali máu nhẹ	\N	Tăng kali máu nặng, suy thận cấp, phù mạch (hiếm)	\N	Chặn thụ thể angiotensin II type 1 (AT1), giảm co mạch và tiết aldosterone, hạ huyết áp.	\N	Hấp thu nhanh, sinh khả dụng 33%. Chuyển hóa gan thành chất chuyển hóa hoạt tính. T1/2 = 2h (losartan), 6-9h (chất chuyển hóa).	\N	\N	\N	\N	\N	D	Chống chỉ định từ trimester 2. Ngừng ngay khi phát hiện mang thai.	\N	Không rõ bài tiết vào sữa mẹ. Cân nhắc ngừng thuốc hoặc ngừng cho con bú.	\N	Bảo quản dưới 30°C, tránh ẩm.	\N	https://www.vinmec.com/vie/thuoc/losartan/	https://www.ncbi.nlm.nih.gov/books/NBK526065/	\N
7	Enalapril	Enalapril	Enalapril Maleate	Thuốc tim mạch	Thuốc ức chế men chuyển, điều trị tăng huyết áp và suy tim	\N	\N	Viên nén	t	\N	2025-12-04 20:03:55.583462	2025-12-04 23:08:02.584235	\N	Renitec, Envas	\N	\N	ACE Inhibitor - Hạ huyết áp	5mg, 10mg, 20mg	Hộp 3 vỉ x 10 viên	Tăng huyết áp, suy tim, rối loạn chức năng thất trái không triệu chứng.	\N	Tăng huyết áp: 5-10mg/ngày, tối đa 40mg/ngày. Suy tim: Bắt đầu 2.5mg/ngày, tăng dần lên 10-20mg/ngày chia 2 lần.	\N	\N	\N	Suy thận: Giảm liều. CrCl 30-80: Bắt đầu 5mg/ngày. CrCl <30: Bắt đầu 2.5mg/ngày.	\N	Quá mẫn, tiền sử phù mạch do ACE inhibitor, thai kỳ, dùng kết hợp aliskiren ở bệnh nhân đái tháo đường.	\N	Nguy cơ hạ huyết áp lần đầu, tăng kali máu, suy thận, ho khan. Theo dõi kali, creatinine. Phù mạch cần ngừng thuốc ngay.	\N	Chống chỉ định trong thai kỳ. Gây tổn thương thai nhi và tử vong.	\N	Ho khan (5-10%), chóng mặt, hạ huyết áp, mệt mỏi, đau đầu	\N	Phù mạch (0.1-0.2%), tăng kali máu nặng, suy thận cấp, giảm bạch cầu (hiếm)	\N	Ức chế enzyme chuyển angiotensin (ACE), giảm angiotensin II, giảm co mạch và tiết aldosterone. Tăng bradykinin (gây ho).	\N	Tiền chất, chuyển thành enalaprilat (hoạt tính) sau hấp thu. Sinh khả dụng 60%. T1/2 = 11h (enalaprilat).	\N	\N	\N	\N	\N	D	Chống chỉ định. Ngừng ngay khi mang thai.	\N	Bài tiết vào sữa mẹ với nồng độ thấp. Sử dụng thận trọng.	\N	Bảo quản dưới 30°C, nơi khô mát.	\N	https://www.vinmec.com/vie/thuoc/enalapril/	https://www.ncbi.nlm.nih.gov/books/NBK482398/	\N
11	Allopurinol	Allopurinol	\N	Thuốc gout	Thuốc giảm acid uric trong máu, phòng ngừa cơn gout	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
12	Colchicine	Colchicine	\N	Thuốc gout	Thuốc giảm viêm, điều trị cơn gout cấp	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
13	Sắt sulfat	Ferrous Sulfate	\N	Bổ sung vitamin khoáng	Bổ sung sắt điều trị thiếu máu do thiếu sắt	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
14	Acid folic	Folic Acid	\N	Bổ sung vitamin khoáng	Vitamin B9, điều trị thiếu máu do thiếu folate	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
15	Vitamin B12	Cyanocobalamin	\N	Bổ sung vitamin khoáng	Điều trị thiếu máu do thiếu vitamin B12	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
16	Canxi + Vitamin D	Calcium + Vitamin D	\N	Bổ sung vitamin khoáng	Bổ sung canxi và vitamin D phòng ngừa loãng xương	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
17	Alendronate	Alendronate	\N	Thuốc xương khớp	Thuốc bisphosphonate, điều trị loãng xương	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
18	Omeprazole	Omeprazole	\N	Thuốc tiêu hóa	Thuốc ức chế bơm proton, điều trị trào ngược dạ dày thực quản	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
19	Esomeprazole	Esomeprazole	\N	Thuốc tiêu hóa	Thuốc ức chế bơm proton, điều trị GERD và loét dạ dày	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
20	Ranitidine	Ranitidine	\N	Thuốc tiêu hóa	Thuốc kháng H2, giảm tiết acid dạ dày	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
21	Salbutamol	Salbutamol	\N	Thuốc hô hấp	Thuốc giãn phế quản, điều trị hen phế quản và COPD	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
22	Budesonide	Budesonide	\N	Thuốc hô hấp	Corticosteroid dạng hít, điều trị hen phế quản	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
23	Theophylline	Theophylline	\N	Thuốc hô hấp	Thuốc giãn phế quản, điều trị hen và COPD	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
24	Furosemide	Furosemide	Furosemide	Thuốc tim mạch	Thuốc lợi tiểu, điều trị suy tim và phù	\N	\N	Viên nén, dung dịch tiêm	t	\N	2025-12-04 20:03:55.583462	2025-12-04 23:17:50.462674	\N	Lasix	Lasix	\N	Thuốc lợi tiểu quai - Diuretic	20mg, 40mg (viên); 10mg/ml (tiêm)	Hộp 10 vỉ x 10 viên hoặc ống tiêm 2ml	Phù do suy tim, xơ gan, bệnh thận. Tăng huyết áp. Phù phổi cấp.	Edema due to heart failure, cirrhosis, renal disease. Hypertension. Acute pulmonary edema.	Phù: 20-80mg/ngày buổi sáng, có thể tăng lên 600mg/ngày. Tăng huyết áp: 40mg x 2 lần/ngày. Phù phổi cấp: 40-80mg tiêm tĩnh mạch chậm.	Edema: 20-80mg/day in morning, up to 600mg/day. Hypertension: 40mg twice daily. Acute pulmonary edema: 40-80mg IV slow push.	Trẻ em: 1-2mg/kg/lần, 1-2 lần/ngày. Tối đa 6mg/kg/ngày.	\N	Suy thận nặng: Cần liều cao hơn. Suy gan: Thận trọng, nguy cơ hôn mê gan.	\N	Thiểu niệu/vô niệu, suy thận cấp không đáp ứng furosemide, hôn mê gan, mất nước/điện giải nặng, quá mẫn sulfonamide.	Anuria, acute renal failure unresponsive to furosemide, hepatic coma, severe dehydration/electrolyte depletion.	Theo dõi điện giải (K, Na, Mg), thể tích tuần hoàn, chức năng thận. Nguy cơ mất kali, natri, hạ huyết áp. Có thể gây điếc tai tạm thời với liều cao tiêm tĩnh mạch nhanh.	Monitor electrolytes (K, Na, Mg), volume status, renal function. Risk of hypokalemia, hyponatremia, hypotension. May cause temporary deafness with rapid high-dose IV.	\N	\N	Hạ kali máu, hạ natri máu, mất nước, hạ huyết áp tư thế, chóng mặt, đau đầu	Hypokalemia, hyponatremia, dehydration, orthostatic hypotension, dizziness, headache	Mất điện giải nghiêm trọng, suy thận, điếc tai (với liều cao IV), phản ứng dị ứng nghiêm trọng	Severe electrolyte depletion, renal failure, ototoxicity (high IV doses), severe allergic reactions	Ức chế tái hấp thu Na-K-2Cl ở quai Henle dày lên, tăng bài tiết nước, natri, kali, clo, magie.	Inhibits Na-K-2Cl cotransporter in thick ascending loop of Henle, increasing excretion of water, sodium, potassium, chloride, magnesium.	Hấp thu 60-70% (uống). Khởi phát: 30-60 phút (uống), 5 phút (IV). Thời gian tác dụng: 6-8h (uống), 2h (IV). T1/2 = 1.5-2h.	Absorption 60-70% (oral). Onset: 30-60min (oral), 5min (IV). Duration: 6-8h (oral), 2h (IV). T1/2 = 1.5-2h.	Mất nước nặng, hạ huyết áp, suy tuần hoàn, mất điện giải nghiêm trọng, rối loạn nhịp tim.	\N	Bù dịch, điện giải. Theo dõi huyết động, điện giải. Không có thuốc giải độc đặc hiệu.	\N	C	Dùng khi lợi ích > nguy cơ. Có thể giảm thể tích tuần hoàn thai nhi. Ưu tiên thiazide liều thấp.	\N	Bài tiết vào sữa mẹ với nồng độ thấp. Có thể ức chế tiết sữa.	\N	Viên: Bảo quản dưới 30°C, tránh ánh sáng. Tiêm: 2-8°C, tránh ánh sáng.	\N	https://www.vinmec.com/vie/thuoc/furosemide/	https://www.ncbi.nlm.nih.gov/books/NBK499921/	\N
8	Atorvastatin	Atorvastatin	\N	Thuốc mỡ máu	Thuốc nhóm statin, giảm cholesterol và nguy cơ tim mạch	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
9	Simvastatin	Simvastatin	\N	Thuốc mỡ máu	Thuốc giảm cholesterol, phòng ngừa bệnh tim mạch	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
10	Fenofibrate	Fenofibrate	\N	Thuốc mỡ máu	Thuốc giảm triglyceride và tăng HDL-cholesterol	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
29	Ciprofloxacin	Ciprofloxacin	\N	Kháng sinh	Kháng sinh nhóm quinolone, điều trị nhiễm khuẩn đường ruột	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
30	Azithromycin	Azithromycin	\N	Kháng sinh	Kháng sinh nhóm macrolide, điều trị nhiễm khuẩn đường hô hấp	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
31	Amoxicillin	Amoxicillin	\N	Kháng sinh	Kháng sinh nhóm penicillin, điều trị nhiễm khuẩn	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
32	Isoniazid	Isoniazid	\N	Thuốc lao	Thuốc điều trị lao phổi và lao màng não	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
33	Rifampicin	Rifampicin	\N	Thuốc lao	Thuốc kháng sinh điều trị lao	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
3	Glibenclamide	Glibenclamide	Glibenclamide	Thuốc đái tháo đường	Thuốc kích thích tụy tiết insulin, điều trị đái tháo đường type 2	\N	\N	Viên nén	t	\N	2025-12-04 20:03:55.583462	2025-12-04 23:08:02.584235	\N	Daonil, Euglucon	\N	\N	Sulfonylurea - Hạ đường huyết	2.5mg, 5mg	Hộp 10 vỉ x 10 viên	Điều trị đái tháo đường type 2 khi chế độ ăn uống và metformin đơn độc không đủ hiệu quả.	\N	Liều khởi đầu: 2.5-5mg/ngày, uống trước bữa sáng. Tăng dần 2.5mg mỗi tuần. Liều tối đa: 15-20mg/ngày chia 2 lần.	\N	\N	\N	Suy thận/gan nặng: Chống chỉ định. Người cao tuổi: Bắt đầu với liều thấp 1.25-2.5mg/ngày.	\N	Đái tháo đường type 1, hôn mê đái tháo đường, nhiễm toan ceton, suy gan/thận nặng, quá mẫn sulfonylurea.	\N	Nguy cơ hạ đường huyết cao, đặc biệt ở người cao tuổi. Tránh bỏ bữa ăn. Theo dõi đường huyết thường xuyên.	\N	\N	\N	Hạ đường huyết, tăng cân, buồn nôn, đau bụng	\N	Hạ đường huyết nặng, rối loạn máu (hiếm), phản ứng dị ứng	\N	Kích thích tuyến tụy tiết insulin bằng cách đóng kênh kali phụ thuộc ATP trên tế bào beta.	\N	Hấp thu nhanh, đạt đỉnh sau 2-4h. Liên kết protein 99%. Chuyển hóa gan. T1/2 = 10h.	\N	\N	\N	\N	\N	C	Chống chỉ định trong thai kỳ. Chuyển sang insulin khi mang thai.	\N	Chống chỉ định khi cho con bú. Có thể gây hạ đường huyết cho trẻ.	\N	Bảo quản nơi khô mát, dưới 25°C. Tránh ẩm.	\N	https://www.vinmec.com/vie/thuoc/glibenclamide/	https://www.ncbi.nlm.nih.gov/books/NBK519051/	\N
4	Insulin	Insulin	Insulin Human/Analog	Thuốc đái tháo đường	Hormone điều trị đái tháo đường, giúp kiểm soát đường huyết	\N	\N	Dung dịch tiêm	t	\N	2025-12-04 20:03:55.583462	2025-12-04 23:08:02.584235	\N	Lantus, Novorapid, Humalog	\N	\N	Insulin - Hạ đường huyết	100 IU/ml	Lọ 10ml hoặc bút tiêm	Điều trị đái tháo đường type 1, type 2 không kiểm soát được bằng thuốc uống, đái tháo đường thai kỳ, tình trạng cấp cứu (hôn mê, nhiễm toan ceton).	\N	Liều cá thể hóa dựa trên đường huyết. Thường 0.5-1 UI/kg/ngày. Insulin nền (basal): 1-2 lần/ngày. Insulin tác dụng nhanh: trước mỗi bữa ăn.	\N	Trẻ em type 1: 0.5-1 UI/kg/ngày. Thanh thiếu niên đang phát triển: có thể cần 1-1.5 UI/kg/ngày.	\N	\N	\N	Hạ đường huyết, quá mẫn với insulin hoặc tá dược.	\N	Nguy cơ hạ đường huyết. Không được tiêm tĩnh mạch (trừ insulin regular trong cấp cứu). Xoay vị trí tiêm để tránh loạn dưỡng mô mỡ. Bảo quản đúng cách.	\N	Hạ đường huyết có thể đe dọa tính mạng. Giáo dục bệnh nhân nhận biết và xử lý hạ đường huyết.	\N	Hạ đường huyết, phản ứng tại chỗ tiêm (đau, đỏ), tăng cân nhẹ	\N	Hạ đường huyết nặng (co giật, hôn mê), phù mạch, sốc phản vệ (rất hiếm), hạ kali máu	\N	Thúc đẩy hấp thu glucose vào tế bào, ức chế phân giải glycogen, giảm sản xuất glucose ở gan, thúc đẩy tổng hợp protein và lipid.	\N	Khởi phát và thời gian tác dụng phụ thuộc loại insulin: Rapid (15 phút-4h), Short (30 phút-6-8h), Intermediate (1-2h, 12-18h), Long-acting (1-2h, 24h+).	\N	Hạ đường huyết: đói, run, vã mồ hôi, hồi hộp, rối loạn ý thức, co giật, hôn mê.	\N	Glucose đường uống nếu tỉnh. Tiêm glucose 10-25% tĩnh mạch hoặc glucagon 1mg tiêm bắp nếu bất tỉnh.	\N	B	An toàn, là thuốc ưu tiên cho đái tháo đường thai kỳ. Nhu cầu insulin thay đổi trong thai kỳ.	\N	An toàn khi cho con bú. Insulin không qua sữa mẹ đáng kể.	\N	Lọ chưa mở: Bảo quản tủ lạnh 2-8°C. Đang sử dụng: Nhiệt độ phòng <30°C, dùng trong 28 ngày. Không đông lạnh. Tránh ánh sáng.	\N	https://www.vinmec.com/vie/benh/dai-thao-duong-type-1/	https://www.ncbi.nlm.nih.gov/books/NBK557815/	\N
34	Ethambutol	Ethambutol	\N	Thuốc lao	Thuốc điều trị lao, phối hợp với các thuốc khác	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
35	Pyrazinamide	Pyrazinamide	\N	Thuốc lao	Thuốc điều trị lao trong giai đoạn đầu	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
36	Levothyroxine	Levothyroxine	\N	Thuốc nội tiết	Hormone tuyến giáp, điều trị suy giáp	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
37	Propylthiouracil	Propylthiouracil	\N	Thuốc nội tiết	Thuốc điều trị cường giáp	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
38	Methimazole	Methimazole	\N	Thuốc nội tiết	Thuốc giảm hoạt động tuyến giáp, điều trị cường giáp	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
39	Methotrexate	Methotrexate	\N	Thuốc xương khớp	Thuốc điều trị viêm khớp dạng thấp	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
40	Hydroxychloroquine	Hydroxychloroquine	\N	Thuốc xương khớp	Thuốc chống thấp khớp, điều trị viêm khớp dạng thấp	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
41	Sumatriptan	Sumatriptan	\N	Thuốc thần kinh	Thuốc điều trị cơn đau nửa đầu migraine	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
42	Propranolol	Propranolol	\N	Thuốc thần kinh	Thuốc chẹn beta, phòng ngừa migraine	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
43	Aspirin	Aspirin	\N	Thuốc giảm đau	Thuốc giảm đau, hạ sốt, chống viêm và chống kết tập tiểu cầu	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
44	Paracetamol	Paracetamol	\N	Thuốc giảm đau	Thuốc giảm đau, hạ sốt	\N	\N	\N	t	\N	2025-12-04 20:03:55.583462	2025-12-04 20:03:55.583462	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
2	Metformin	Metformin	Metformin Hydrochloride	Thuốc đái tháo đường	Thuốc điều trị đái tháo đường type 2, giúp giảm đường huyết	\N	\N	Viên nén bao phim	t	\N	2025-12-04 20:03:55.583462	2025-12-04 23:08:02.584235	\N	Glucophage, Gluformin	Glucophage	Metformin HCl	Biguanide - Hạ đường huyết	500mg, 850mg, 1000mg	Hộp 3 vỉ x 10 viên nén bao phim	Điều trị đái tháo đường type 2, đặc biệt ở bệnh nhân thừa cân/béo phì khi chế độ ăn và tập luyện không đủ hiệu quả. Phòng ngừa biến chứng tim mạch ở bệnh nhân đái tháo đường.	Treatment of type 2 diabetes mellitus, especially in overweight patients when diet and exercise alone are insufficient.	Liều khởi đầu: 500mg, 1-2 lần/ngày sau ăn. Tăng dần 500mg mỗi tuần. Liều tối đa: 2000-2550mg/ngày, chia 2-3 lần.	Initial: 500mg once or twice daily with meals. Increase by 500mg weekly. Maximum: 2000-2550mg/day in 2-3 divided doses.	Trẻ ≥10 tuổi: Bắt đầu 500mg/ngày, tối đa 2000mg/ngày chia 2 lần.	Children ≥10 years: Start 500mg/day, max 2000mg/day in 2 divided doses.	Suy thận eGFR 30-60: Giảm liều 50%. eGFR <30: Chống chỉ định. Suy gan: Tránh dùng.	Renal impairment eGFR 30-60: Reduce 50%. eGFR <30: Contraindicated. Hepatic impairment: Avoid.	Suy thận nặng (eGFR <30), nhiễm toan chuyển hóa, suy tim nặng, sốc, suy gan, nghiện rượu, quá mẫn với metformin.	Severe renal impairment (eGFR <30), metabolic acidosis, severe heart failure, shock, hepatic impairment, alcoholism.	Nguy cơ nhiễm toan lactic (hiếm nhưng nghiêm trọng). Ngừng thuốc trước phẫu thuật hoặc tiêm thuốc cản quang có iod 48h. Theo dõi chức năng thận định kỳ. Có thể thiếu vitamin B12 khi dùng lâu dài.	Risk of lactic acidosis (rare but serious). Discontinue 48h before surgery or contrast procedures. Monitor renal function regularly.	\N	\N	Buồn nôn, tiêu chảy, đau bụng, chướng hơi, giảm ngon miệng (thường tự hết sau 1-2 tuần)	Nausea, diarrhea, abdominal pain, bloating, decreased appetite	Nhiễm toan lactic (hiếm), thiếu vitamin B12, hạ đường huyết khi dùng kết hợp insulin/sulfonylurea	Lactic acidosis (rare), vitamin B12 deficiency, hypoglycemia when combined with insulin	Giảm sản xuất glucose ở gan, tăng độ nhạy insulin ở mô ngoại vi, giảm hấp thu glucose ở ruột.	Decreases hepatic glucose production, increases insulin sensitivity, reduces intestinal glucose absorption.	Hấp thu: 50-60%, đạt nồng độ đỉnh sau 2-3h. Không liên kết protein. Không chuyển hóa gan. Thải trừ qua thận (90%), T1/2 = 4-8.7h.	Absorption: 50-60%, peak 2-3h. No protein binding. Not metabolized. Renal excretion (90%), T1/2 = 4-8.7h.	Hạ đường huyết, buồn nôn/nôn, tiêu chảy, đau bụng. Nguy cơ nhiễm toan lactic với liều rất cao.	Hypoglycemia, nausea/vomiting, diarrhea, abdominal pain. Risk of lactic acidosis with very high doses.	Điều trị triệu chứng. Glucose nếu hạ đường huyết. Lọc máu nếu nhiễm toan lactic.	Symptomatic treatment. Glucose for hypoglycemia. Hemodialysis for lactic acidosis.	B	Có thể dùng trong thai kỳ nếu lợi ích > nguy cơ. Insulin vẫn là lựa chọn ưu tiên.	May be used during pregnancy if benefits outweigh risks. Insulin remains preferred choice.	Bài tiết vào sữa mẹ với nồng độ thấp. Cân nhắc lợi ích/nguy cơ khi cho con bú.	Excreted in breast milk at low levels. Weigh benefits/risks when breastfeeding.	Bảo quản nơi khô mát, nhiệt độ dưới 30°C. Tránh ánh sáng trực tiếp. Để xa tầm tay trẻ em.	Store in a cool, dry place below 30°C. Protect from light. Keep out of reach of children.	https://www.vinmec.com/vie/benh/dai-thao-duong-type-2/	https://www.ncbi.nlm.nih.gov/books/NBK518983/	["American Diabetes Association Guidelines 2024","WHO Essential Medicines List","Vietnam National Drug Information 2024"]
26	Spironolactone	Spironolactone	Spironolactone	Thuốc tim mạch	Thuốc lợi tiểu giữ kali, điều trị suy tim	\N	\N	Viên nén	t	\N	2025-12-04 20:03:55.583462	2025-12-04 23:17:50.462674	\N	Aldactone	Aldactone	\N	Thuốc lợi tiểu giữ kali - Aldosterone Antagonist	25mg, 50mg, 100mg	Hộp 10 vỉ x 10 viên	Suy tim mạn tính (NYHA III-IV). Tăng huyết áp. Phù do xơ gan, hội chứng thận hư. Tăng aldosterone nguyên phát.	Chronic heart failure (NYHA III-IV). Hypertension. Edema from cirrhosis, nephrotic syndrome. Primary hyperaldosteronism.	Suy tim: 12.5-25mg/ngày, tăng dần lên 25-50mg/ngày. Tăng huyết áp: 25-100mg/ngày. Phù: 100-400mg/ngày.	Heart failure: 12.5-25mg/day, increase to 25-50mg/day. Hypertension: 25-100mg/day. Edema: 100-400mg/day.	Trẻ em: 1-3.3mg/kg/ngày chia 1-2 lần.	\N	Suy thận: Tránh nếu CrCl <30. Theo dõi kali chặt chẽ.	\N	Tăng kali máu (>5.5 mmol/L), suy thận cấp, bệnh Addison, dùng eplerenone hoặc bổ sung kali.	Hyperkalemia (>5.5 mmol/L), acute renal failure, Addison disease, concurrent eplerenone or potassium supplements.	Nguy cơ tăng kali máu, đặc biệt khi dùng với ACE inhibitor/ARB. Theo dõi kali, creatinine thường xuyên. Có thể gây nữ hóa tuyến vú ở nam.	Risk of hyperkalemia, especially with ACE inhibitors/ARBs. Monitor potassium, creatinine regularly. May cause gynecomastia in males.	Có khả năng gây ung thư ở động vật thí nghiệm với liều cao. Chỉ dùng khi có chỉ định rõ ràng.	\N	Tăng kali máu nhẹ, chóng mặt, đau đầu, buồn nôn, tiêu chảy, nữ hóa tuyến vú (nam), rối loạn kinh nguyệt (nữ)	Mild hyperkalemia, dizziness, headache, nausea, diarrhea, gynecomastia (males), menstrual irregularities (females)	Tăng kali máu nặng (rối loạn nhịp tim nguy hiểm), suy thận cấp, phản ứng dị ứng	Severe hyperkalemia (life-threatening arrhythmias), acute renal failure, allergic reactions	Đối kháng cạnh tranh với aldosterone tại thụ thể khoáng corticoid ở ống thận xa, giảm bài tiết kali, tăng bài tiết natri và nước.	Competitive aldosterone antagonist at mineralocorticoid receptor in distal tubule, reduces potassium excretion, increases sodium and water excretion.	Hấp thu >90%. Chuyển hóa gan thành canrenone (hoạt tính). Khởi phát: 2-3 ngày. Thời gian tác dụng: 2-3 ngày sau ngừng thuốc. T1/2 = 1.4h (spironolactone), 13-24h (canrenone).	Absorption >90%. Hepatic metabolism to canrenone (active). Onset: 2-3 days. Duration: 2-3 days after discontinuation. T1/2 = 1.4h (spironolactone), 13-24h (canrenone).	Mất nước, mất điện giải, tăng kali máu, hạ natri máu, buồn ngủ.	\N	Ngừng thuốc. Điều trị triệu chứng. Bù dịch, điện giải. Xử lý tăng kali máu (glucose-insulin, calcium, resin trao đổi ion).	\N	C	Tránh dùng trong thai kỳ trừ khi thực sự cần thiết. Có tác dụng kháng androgen.	\N	Chất chuyển hóa canrenone bài tiết vào sữa mẹ. Tránh cho con bú.	\N	Bảo quản dưới 25°C, tránh ẩm.	\N	https://www.vinmec.com/vie/thuoc/spironolactone/	https://www.ncbi.nlm.nih.gov/books/NBK554421/	\N
27	Warfarin	Warfarin	Warfarin Sodium	Thuốc tim mạch	Thuốc chống đông máu, phòng ngừa huyết khối và rung nhĩ	\N	\N	Viên nén	t	\N	2025-12-04 20:03:55.583462	2025-12-04 23:17:50.462674	\N	Coumadin, Marevan	Coumadin	\N	Thuốc chống đông máu - Vitamin K Antagonist	1mg, 2mg, 5mg	Hộp 10 vỉ x 10 viên (màu sắc khác nhau theo hàm lượng)	Phòng ngừa/điều trị huyết khối tĩnh mạch sâu, th栓 tắc phổi. Phòng ngừa tai biến mạch máu não ở bệnh nhân rung nhĩ. Van tim nhân tạo. Sau nhồi máu cơ tim.	Prevention/treatment of deep vein thrombosis, pulmonary embolism. Stroke prevention in atrial fibrillation. Mechanical heart valves. Post-myocardial infarction.	Liều khởi đầu: 2-5mg/ngày. Điều chỉnh theo INR mục tiêu (thường 2-3). Liều duy trì thường 2-10mg/ngày. Kiểm tra INR thường xuyên.	Initial: 2-5mg/day. Adjust based on target INR (usually 2-3). Maintenance typically 2-10mg/day. Monitor INR regularly.	Trẻ em: 0.1-0.2mg/kg/ngày (tối đa 10mg), điều chỉnh theo INR.	\N	Người cao tuổi, suy gan: Bắt đầu liều thấp (1-2mg). Theo dõi INR chặt chẽ hơn.	\N	Chảy máu nội tạng đang diễn ra, phẫu thuật não/mắt/tủy sống gần đây, thai kỳ, tăng huyết áp nặng không kiểm soát, rối loạn đông máu nặng.	Active internal bleeding, recent brain/eye/spinal surgery, pregnancy, severe uncontrolled hypertension, severe coagulation disorders.	Cửa sổ điều trị hẹp. Nguy cơ chảy máu cao. Tương tác thuốc-thuốc, thuốc-thức ăn nhiều. Theo dõi INR thường xuyên (ban đầu mỗi 2-3 ngày, sau đó mỗi 4-8 tuần). Tránh ăn bưởi, rau xanh đậm (vitamin K cao) không đều.	Narrow therapeutic window. High bleeding risk. Many drug-drug, drug-food interactions. Monitor INR regularly (initially every 2-3 days, then every 4-8 weeks). Avoid inconsistent intake of grapefruit, dark green vegetables (high vitamin K).	Có thể gây chảy máu nghiêm trọng hoặc tử vong. Chảy máu có thể xảy ra ở bất kỳ vị trí nào. Nguy cơ cao hơn ở người cao tuổi. Theo dõi INR thường xuyên.	\N	Chảy máu nhẹ (chảy máu cam, chảy máu nướu răng, bầm tím da), đau bụng, buồn nôn	Minor bleeding (nosebleeds, gum bleeding, bruising), abdominal pain, nausea	Chảy máu nặng (tiêu hóa, não, tiết niệu), hoại tử da, hội chứng ngón chân tím (purple toe syndrome)	Major bleeding (GI, intracranial, urinary), skin necrosis, purple toe syndrome	Ức chế vitamin K epoxide reductase, làm giảm tổng hợp các yếu tố đông máu phụ thuộc vitamin K (II, VII, IX, X) và protein C, S.	Inhibits vitamin K epoxide reductase, reducing synthesis of vitamin K-dependent clotting factors (II, VII, IX, X) and proteins C, S.	Hấp thu nhanh, hoàn toàn. Liên kết protein 99%. Chuyển hóa gan qua CYP2C9. Khởi phát: 24-72h. Thời gian tác dụng: 2-5 ngày. T1/2 = 20-60h (trung bình 40h).	Rapid, complete absorption. Protein binding 99%. Hepatic metabolism via CYP2C9. Onset: 24-72h. Duration: 2-5 days. T1/2 = 20-60h (mean 40h).	INR tăng cao, chảy máu (chảy máu nội tạng, chảy máu não, chảy máu tiêu hóa).	\N	Ngừng warfarin. Vitamin K (phytomenadione): 2.5-10mg uống hoặc IV chậm. FFP hoặc PCC cho chảy máu nặng. Theo dõi INR.	\N	X	Chống chỉ định tuyệt đối. Gây dị tật thai nhi (warfarin embryopathy), chảy máu thai nhi. Chuyển sang heparin khi có thai.	\N	Bài tiết rất ít vào sữa mẹ. Được coi là tương thích với cho con bú (AAP).	\N	Bảo quản dưới 25°C, tránh ánh sáng, ẩm. Để xa tầm tay trẻ em.	\N	https://www.vinmec.com/vie/thuoc/warfarin/	https://www.ncbi.nlm.nih.gov/books/NBK470313/	\N
28	Rivaroxaban	Rivaroxaban	Rivaroxaban	Thuốc tim mạch	Thuốc chống đông máu thế hệ mới, điều trị huyết khối	\N	\N	Viên nén bao phim	t	\N	2025-12-04 20:03:55.583462	2025-12-04 23:17:50.462674	\N	Xarelto	Xarelto	\N	Thuốc chống đông máu - DOAC (Direct Oral Anticoagulant)	10mg, 15mg, 20mg	Hộp 1-3 vỉ x 10 viên bao phim	Phòng ngừa huyết khối tĩnh mạch sau phẫu thuật thay khớp háng/đầu gối. Phòng ngừa đột quỵ ở bệnh nhân rung nhĩ không do bệnh van tim. Điều trị huyết khối tĩnh mạch sâu, thuyên tắc phổi.	Prevention of VTE after hip/knee replacement surgery. Stroke prevention in non-valvular atrial fibrillation. Treatment of DVT, pulmonary embolism.	Rung nhĩ: 20mg/ngày với bữa tối. Huyết khối tĩnh mạch sâu: 15mg x 2 lần/ngày x 3 tuần, sau đó 20mg/ngày. Phòng ngừa sau phẫu thuật: 10mg/ngày.	Atrial fibrillation: 20mg once daily with evening meal. DVT: 15mg twice daily x 3 weeks, then 20mg once daily. Post-surgical prophylaxis: 10mg once daily.	\N	\N	Suy thận CrCl 15-49: Giảm liều (AF: 15mg/ngày). CrCl <15: Tránh dùng. Suy gan Child-Pugh B-C: Chống chỉ định.	\N	Chảy máu đang diễn ra có ý nghĩa lâm sàng, suy gan Child-Pugh B-C, thai kỳ.	Active clinically significant bleeding, hepatic disease Child-Pugh B-C, pregnancy.	Nguy cơ chảy máu. Không cần theo dõi INR nhưng không có thuốc giải độc đặc hiệu (chỉ có andexanet alfa, giá rất đắt). Ngừng thuốc trước phẫu thuật 24-48h. Dùng với bữa ăn để tăng hấp thu.	Bleeding risk. No INR monitoring needed but no specific antidote (only andexanet alfa, very expensive). Discontinue 24-48h before surgery. Take with food to increase absorption.	\N	\N	Chảy máu nhẹ (chảy máu cam, bầm tím), buồn nôn, đau bụng, chóng mặt	Minor bleeding (epistaxis, bruising), nausea, abdominal pain, dizziness	Chảy máu nặng (não, tiêu hóa, tiết niệu), chèn ép tủy sống/ngoài màng cứng (nếu gây tê tủy sống)	Major bleeding (intracranial, GI, urinary), spinal/epidural hematoma (with neuraxial anesthesia)	Ức chế trực tiếp yếu tố Xa, ngăn chặn chuyển prothrombin thành thrombin, làm gián đoạn quá trình đông máu.	Direct factor Xa inhibitor, blocks conversion of prothrombin to thrombin, interrupting coagulation cascade.	Sinh khả dụng 80-100% (với thức ăn). Đạt đỉnh sau 2-4h. Liên kết protein 92-95%. Chuyển hóa gan CYP3A4/5, CYP2J2. T1/2 = 5-9h (trẻ), 11-13h (người cao tuổi).	Bioavailability 80-100% (with food). Peak 2-4h. Protein binding 92-95%. Hepatic metabolism CYP3A4/5, CYP2J2. T1/2 = 5-9h (young), 11-13h (elderly).	Chảy máu (từ nhẹ đến nghiêm trọng).	\N	Ngừng thuốc. Than hoạt tính nếu uống gần đây. Andexanet alfa (thuốc giải độc, rất đắt) cho chảy máu nặng. PCC có thể cân nhắc.	\N	C	Chống chỉ định. Gây chảy máu thai nhi và mẹ. Chuyển sang heparin nếu cần.	\N	Không rõ bài tiết vào sữa mẹ. Tránh cho con bú.	\N	Bảo quản dưới 30°C. Viên 15mg và 20mg: uống với thức ăn.	\N	https://www.vinmec.com/vie/thuoc/rivaroxaban/	https://www.ncbi.nlm.nih.gov/books/NBK493731/	\N
\.


--
-- TOC entry 6682 (class 0 OID 29102)
-- Dependencies: 413
-- Data for Name: drug_interaction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drug_interaction (interaction_id, drug_id, interaction_type, interacts_with, severity, description_vi, description_en, clinical_effects_vi, clinical_effects_en, management_vi, management_en, created_at, updated_at) FROM stdin;
4	2	food	Rượu / Alcohol	major	Rượu làm tăng nguy cơ nhiễm toan lactic khi dùng metformin	\N	Nguy cơ nhiễm toan lactic, hạ đường huyết	\N	Tránh uống rượu. Nếu uống, chỉ lượng nhỏ với thức ăn.	\N	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
5	2	drug	Thuốc cản quang có iod	major	Thuốc cản quang có thể gây suy thận cấp, tăng nguy cơ nhiễm toan lactic	\N	Suy thận cấp, nhiễm toan lactic	\N	Ngừng metformin trước 48h khi chụp có cản quang. Chỉ dùng lại sau 48h nếu chức năng thận bình thường.	\N	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
6	2	drug	Insulin, Sulfonylurea	moderate	Tăng nguy cơ hạ đường huyết khi phối hợp	\N	Hạ đường huyết	\N	Theo dõi đường huyết thường xuyên. Có thể cần giảm liều insulin/sulfonylurea.	\N	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
7	3	drug	Beta-blocker (Propranolol)	moderate	Che dấu triệu chứng hạ đường huyết (run, hồi hộp)	\N	Khó phát hiện hạ đường huyết	\N	Theo dõi đường huyết kỹ lưỡng. Giáo dục bệnh nhân nhận biết triệu chứng khác (đói, vã mồ hôi).	\N	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
8	3	food	Rượu	major	Rượu tăng nguy cơ hạ đường huyết	\N	Hạ đường huyết nặng, có thể kéo dài	\N	Tránh uống rượu, đặc biệt khi đói.	\N	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
9	4	drug	Corticosteroid	moderate	Tăng đường huyết, đối kháng tác dụng insulin	\N	Tăng nhu cầu insulin	\N	Tăng liều insulin. Theo dõi đường huyết chặt chẽ.	\N	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
10	4	drug	Salicylate liều cao (Aspirin)	moderate	Tăng tác dụng hạ đường huyết của insulin	\N	Hạ đường huyết	\N	Giảm liều insulin có thể cần thiết. Theo dõi đường huyết.	\N	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
11	5	food	Bưởi / Grapefruit	moderate	Bưởi ức chế CYP3A4, tăng nồng độ amlodipine trong máu	\N	Tăng nguy cơ hạ huyết áp, phù mạch	\N	Tránh ăn bưởi hoặc uống nước bưởi trong khi điều trị.	\N	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
12	5	drug	Simvastatin liều cao	moderate	Amlodipine tăng nồng độ simvastatin	\N	Tăng nguy cơ tổn thương cơ (myopathy)	\N	Giới hạn simvastatin ≤20mg/ngày khi dùng với amlodipine.	\N	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
13	6	drug	Thuốc lợi tiểu giữ kali, Bổ sung kali	major	Tăng nguy cơ tăng kali máu	\N	Tăng kali máu nặng, rối loạn nhịp tim	\N	Tránh dùng kết hợp. Nếu cần, theo dõi kali máu thường xuyên.	\N	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
14	6	drug	NSAID (Ibuprofen, Naproxen)	moderate	Giảm tác dụng hạ huyết áp, tăng nguy cơ suy thận	\N	Giảm hiệu quả hạ áp, suy thận	\N	Theo dõi huyết áp và chức năng thận. Sử dụng NSAID liều thấp nhất, thời gian ngắn nhất.	\N	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
15	7	drug	Bổ sung kali, Thuốc lợi tiểu giữ kali	major	Tăng nguy cơ tăng kali máu nghiêm trọng	\N	Tăng kali máu, rối loạn nhịp tim nguy hiểm	\N	Tránh dùng kết hợp. Nếu cần thiết, theo dõi kali máu chặt chẽ.	\N	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
16	7	drug	Lithium	moderate	Tăng nồng độ lithium trong máu	\N	Ngộ độc lithium (run, lú lẫn, buồn nôn)	\N	Theo dõi nồng độ lithium máu khi bắt đầu/ngừng enalapril.	\N	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
17	24	drug	Aminoglycoside (Gentamicin)	major	Tăng nguy cơ độc tai và độc thận	\N	Điếc tai vĩnh viễn, suy thận	\N	Theo dõi chức năng thận, thính lực. Tránh dùng kết hợp nếu có thể.	\N	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
18	24	drug	Digoxin	moderate	Hạ kali do furosemide tăng độc tính digoxin	\N	Ngộ độc digitalis, rối loạn nhịp tim	\N	Theo dõi kali máu, bổ sung kali nếu cần. Theo dõi triệu chứng ngộ độc digoxin.	\N	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
19	24	drug	Lithium	major	Giảm thải trừ lithium, tăng nồng độ lithium máu	\N	Ngộ độc lithium (run, buồn nôn, lú lẫn)	\N	Theo dõi nồng độ lithium. Có thể cần giảm liều lithium.	\N	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
20	25	drug	Amiodarone	major	Tăng nồng độ digoxin 70-100%	\N	Ngộ độc digitalis	\N	Giảm liều digoxin 50% khi bắt đầu amiodarone. Theo dõi nồng độ digoxin.	\N	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
21	25	drug	Verapamil, Diltiazem	moderate	Tăng nồng độ digoxin, chậm nhịp tim cộng gộp	\N	Ngộ độc digoxin, bradycardia nặng, block nhĩ thất	\N	Giảm liều digoxin. Theo dõi nhịp tim, ECG.	\N	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
22	25	drug	Thuốc lợi tiểu (Furosemide, Hydrochlorothiazide)	moderate	Hạ kali tăng độc tính digoxin	\N	Tăng nguy cơ rối loạn nhịp tim	\N	Theo dõi kali, bổ sung kali nếu cần.	\N	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
23	26	drug	ACE inhibitor (Enalapril)	major	Tăng nguy cơ tăng kali máu nghiêm trọng	\N	Tăng kali máu, rối loạn nhịp tim nguy hiểm	\N	Dùng liều thấp spironolactone (12.5-25mg). Theo dõi kali máu thường xuyên (sau 1 tuần, sau 1 tháng, sau đó mỗi 3 tháng).	\N	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
24	26	drug	ARB (Losartan)	major	Tăng nguy cơ tăng kali máu	\N	Tăng kali máu, rối loạn nhịp tim	\N	Giống ACE inhibitor. Theo dõi kali chặt chẽ.	\N	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
25	26	drug	NSAID (Ibuprofen)	moderate	Giảm tác dụng lợi tiểu, tăng nguy cơ tăng kali và suy thận	\N	Giảm hiệu quả, tăng kali, suy thận	\N	Tránh dùng NSAID. Nếu cần, dùng liều thấp nhất, thời gian ngắn nhất. Theo dõi chức năng thận, kali.	\N	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
26	27	drug	Aspirin, NSAID	major	Tăng nguy cơ chảy máu nghiêm trọng	\N	Chảy máu tiêu hóa, chảy máu não	\N	Tránh dùng kết hợp. Nếu thực sự cần aspirin, dùng liều thấp (≤100mg) và theo dõi chặt chẽ. Cân nhắc bảo vệ dạ dày (PPI).	\N	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
27	27	drug	Kháng sinh (Metronidazole, Cotrimoxazole)	major	Tăng tác dụng warfarin, tăng INR	\N	INR tăng cao, nguy cơ chảy máu	\N	Theo dõi INR chặt chẽ khi bắt đầu/ngừng kháng sinh. Có thể cần giảm liều warfarin tạm thời.	\N	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
28	27	food	Rau xanh đậm (cải xoăn, rau bina, súp lơ xanh)	moderate	Vitamin K trong rau làm giảm tác dụng warfarin	\N	INR giảm, giảm hiệu quả chống đông	\N	Ăn rau xanh đều đặn, không thay đổi đột ngột lượng ăn. Không cần kiêng hoàn toàn.	\N	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
29	27	food	Bưởi, nước ép bưởi	moderate	Ức chế CYP3A4, có thể tăng/giảm tác dụng warfarin không dự đoán	\N	INR không ổn định	\N	Tránh ăn bưởi, uống nước bưởi.	\N	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
30	28	drug	Aspirin, NSAID, Clopidogrel	major	Tăng nguy cơ chảy máu nghiêm trọng	\N	Chảy máu nặng (tiêu hóa, não)	\N	Tránh dùng kết hợp trừ khi lợi ích > nguy cơ (ví dụ: stent động mạch vành). Theo dõi chặt chẽ.	\N	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
31	28	drug	Ketoconazole, Itraconazole (kháng nấm)	major	Ức chế CYP3A4 và P-gp mạnh, tăng nồng độ rivaroxaban 160%	\N	Tăng nguy cơ chảy máu nghiêm trọng	\N	Chống chỉ định dùng kết hợp. Tránh tuyệt đối.	\N	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
32	28	drug	Rifampicin, Carbamazepine	major	Tăng cường CYP3A4 và P-gp, giảm nồng độ rivaroxaban 50%	\N	Giảm hiệu quả chống đông, tăng nguy cơ huyết khối	\N	Tránh dùng kết hợp. Nếu cần, cân nhắc thuốc chống đông khác.	\N	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
\.


--
-- TOC entry 6684 (class 0 OID 29124)
-- Dependencies: 415
-- Data for Name: drug_side_effect; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drug_side_effect (side_effect_id, drug_id, effect_name_vi, effect_name_en, frequency, severity, description_vi, description_en, is_serious, created_at, updated_at) FROM stdin;
5	2	Tiêu chảy	\N	very_common	mild	Phân lỏng, đi ngoài nhiều lần. Thường giảm sau 1-2 tuần.	\N	f	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
6	2	Buồn nôn	\N	very_common	mild	Cảm giác khó chịu ở dạ dày. Uống thuốc sau ăn để giảm.	\N	f	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
7	2	Nhiễm toan lactic	\N	rare	severe	Tích tụ acid lactic trong máu. Triệu chứng: mệt, khó thở, đau bụng, rối loạn nhịp tim.	\N	t	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
8	2	Thiếu Vitamin B12	\N	common	moderate	Dùng lâu dài giảm hấp thu B12. Triệu chứng: mệt, thiếu máu, tê bì.	\N	f	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
9	3	Hạ đường huyết	\N	common	moderate	Đói, run, vã mồ hôi, hồi hộp, chóng mặt. Cần ăn ngay thức ăn có đường.	\N	f	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
10	3	Tăng cân	\N	common	mild	Tăng cân 1-2kg trong vài tháng đầu.	\N	f	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
11	3	Hạ đường huyết nặng	\N	uncommon	severe	Co giật, lú lẫn, hôn mê. Cần cấp cứu ngay.	\N	t	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
12	4	Hạ đường huyết	\N	very_common	moderate	Phụ thuộc liều và chế độ ăn. Đói, run, vã mồ hôi.	\N	f	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
13	4	Phản ứng tại chỗ tiêm	\N	common	mild	Đau, đỏ, ngứa tại vị trí tiêm. Xoay vị trí tiêm.	\N	f	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
14	4	Loạn dưỡng mô mỡ	\N	common	mild	Khối u mỡ hoặc hủy mô mỡ tại chỗ tiêm. Do tiêm cùng chỗ nhiều lần.	\N	f	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
15	4	Hạ đường huyết nặng	\N	uncommon	severe	Co giật, hôn mê, có thể tử vong nếu không điều trị kịp thời.	\N	t	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
16	5	Phù mắt cá chân	\N	very_common	mild	Sưng ở chân, mắt cá. Giảm khi nâng chân cao.	\N	f	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
17	5	Đau đầu	\N	common	mild	Đau đầu nhẹ, thường giảm sau vài ngày.	\N	f	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
18	5	Đỏ mặt	\N	common	mild	Cảm giác nóng, đỏ mặt. Do giãn mạch.	\N	f	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
19	6	Chóng mặt	\N	common	mild	Chóng mặt khi đứng dậy đột ngột (hạ huyết áp tư thế).	\N	f	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
20	6	Tăng kali máu	\N	common	moderate	Tăng kali nhẹ. Cần theo dõi xét nghiệm.	\N	f	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
21	6	Phù mạch	\N	rare	severe	Sưng mặt, môi, lưỡi, thanh quản. Cấp cứu ngay.	\N	t	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
22	7	Ho khan	\N	common	mild	Ho khan, không đờm. Do tích tụ bradykinin. Có thể cần đổi thuốc.	\N	f	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
23	7	Chóng mặt	\N	common	mild	Chóng mặt, đặc biệt lần đầu dùng thuốc.	\N	f	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
24	7	Phù mạch	\N	rare	severe	Sưng mặt, môi, lưỡi. Ngừng thuốc ngay và cấp cứu.	\N	t	2025-12-04 23:08:02.584235	2025-12-04 23:08:02.584235
25	24	Hạ kali máu	\N	very_common	moderate	Kali máu <3.5 mmol/L. Triệu chứng: mệt, yếu cơ, táo bón, rối loạn nhịp tim.	\N	f	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
26	24	Hạ huyết áp tư thế	\N	common	mild	Chóng mặt khi đứng dậy. Do mất nước, giảm thể tích tuần hoàn.	\N	f	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
27	24	Điếc tai	\N	rare	severe	Thường với liều cao IV nhanh. Có thể vĩnh viễn. Ù tai, giảm thính lực.	\N	t	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
28	24	Suy thận cấp	\N	uncommon	severe	Do mất nước nặng hoặc giảm tưới máu thận. Creatinine tăng, giảm lượng nước tiểu.	\N	t	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
29	25	Buồn nôn, nôn	\N	common	mild	Triệu chứng sớm của ngộ độc digitalis. Chán ăn, khó chịu bụng.	\N	f	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
30	25	Nhìn vàng/xanh	\N	uncommon	moderate	Rối loạn thị giác màu sắc. Dấu hiệu ngộ độc digitalis.	\N	f	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
31	25	Bradycardia	\N	common	moderate	Nhịp tim chậm <60 lần/phút. Có thể tiến triển thành block nhĩ thất.	\N	f	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
32	25	Rối loạn nhịp thất	\N	uncommon	severe	Ngoại tâm thu thất, nhịp nhanh thất. Nguy hiểm tính mạng. Dấu hiệu ngộ độc nặng.	\N	t	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
33	26	Tăng kali máu nhẹ	\N	common	mild	Kali 5.0-5.5 mmol/L. Thường không có triệu chứng. Cần theo dõi.	\N	f	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
34	26	Nữ hóa tuyến vú (nam)	\N	common	mild	Phì đại tuyến vú, đau tuyến vú ở nam giới. Do tác dụng kháng androgen.	\N	f	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
35	26	Rối loạn kinh nguyệt	\N	common	mild	Kinh không đều, rong kinh ở phụ nữ.	\N	f	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
36	26	Tăng kali máu nặng	\N	uncommon	severe	Kali >6.0 mmol/L. Yếu cơ, rối loạn nhịp tim nguy hiểm. Cấp cứu ngay.	\N	t	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
37	27	Bầm tím da	\N	very_common	mild	Bầm tím dễ dàng sau va chạm nhẹ. Dấu hiệu thuốc đang có tác dụng.	\N	f	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
38	27	Chảy máu nướu răng	\N	common	mild	Chảy máu khi đánh răng. Cần vệ sinh răng miệng nhẹ nhàng.	\N	f	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
39	27	Chảy máu não	\N	rare	severe	Đau đầu dữ dội, yếu liệt, lú lẫn, hôn mê. Nguy hiểm tính mạng. Cấp cứu ngay.	\N	t	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
40	27	Chảy máu tiêu hóa	\N	uncommon	severe	Phân đen hoặc có máu tươi, nôn máu. Cấp cứu ngay.	\N	t	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
41	28	Bầm tím	\N	common	mild	Bầm tím dưới da sau va chạm nhẹ.	\N	f	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
42	28	Chảy máu nướu	\N	common	mild	Chảy máu khi đánh răng, nhai thức ăn cứng.	\N	f	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
43	28	Chảy máu não	\N	rare	severe	Đột ngột đau đầu, yếu, rối loạn ý thức. Nguy hiểm tính mạng.	\N	t	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
44	28	Chèn ép tủy sống	\N	rare	severe	Sau gây tê tủy sống/ngoài màng cứng. Yếu chân, tiểu/đại tiện không kiểm soát. Phẫu thuật khẩn cấp.	\N	t	2025-12-04 23:17:50.462674	2025-12-04 23:17:50.462674
\.


--
-- TOC entry 6660 (class 0 OID 23991)
-- Dependencies: 389
-- Data for Name: drughealthcondition; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drughealthcondition (drug_condition_id, drug_id, condition_id, treatment_notes, is_primary, created_at, treatment_notes_vi) FROM stdin;
216	7	12	Ức chế men chuyển, tốt cho bệnh nhân có bệnh thận	f	2025-12-04 20:03:55.583462	Ức chế men chuyển, tốt cho bệnh nhân có bệnh thận
217	8	3	Thuốc statin mạnh, giảm LDL-cholesterol hiệu quả	t	2025-12-04 20:03:55.583462	Thuốc statin mạnh, giảm LDL-cholesterol hiệu quả
218	8	19	Thuốc statin mạnh, giảm LDL-cholesterol hiệu quả	t	2025-12-04 20:03:55.583462	Thuốc statin mạnh, giảm LDL-cholesterol hiệu quả
219	9	3	Giảm cholesterol, phòng ngừa biến cố tim mạch	t	2025-12-04 20:03:55.583462	Giảm cholesterol, phòng ngừa biến cố tim mạch
220	9	19	Giảm cholesterol, phòng ngừa biến cố tim mạch	t	2025-12-04 20:03:55.583462	Giảm cholesterol, phòng ngừa biến cố tim mạch
221	10	3	Dùng khi triglyceride cao, có thể phối hợp statin	f	2025-12-04 20:03:55.583462	Dùng khi triglyceride cao, có thể phối hợp statin
222	10	19	Dùng khi triglyceride cao, có thể phối hợp statin	f	2025-12-04 20:03:55.583462	Dùng khi triglyceride cao, có thể phối hợp statin
223	11	5	Dùng dài hạn phòng ngừa cơn gout tái phát	t	2025-12-04 20:03:55.583462	Dùng dài hạn phòng ngừa cơn gout tái phát
224	11	16	Dùng dài hạn phòng ngừa cơn gout tái phát	t	2025-12-04 20:03:55.583462	Dùng dài hạn phòng ngừa cơn gout tái phát
225	12	5	Điều trị cơn gout cấp, giảm viêm	t	2025-12-04 20:03:55.583462	Điều trị cơn gout cấp, giảm viêm
226	12	16	Điều trị cơn gout cấp, giảm viêm	t	2025-12-04 20:03:55.583462	Điều trị cơn gout cấp, giảm viêm
227	17	15	Thuốc điều trị loãng xương, uống 1 lần/tuần	t	2025-12-04 20:03:55.583462	Thuốc điều trị loãng xương, uống 1 lần/tuần
228	18	18	Giảm tiết acid dạ dày, uống trước ăn	t	2025-12-04 20:03:55.583462	Giảm tiết acid dạ dày, uống trước ăn
229	19	18	Ức chế bơm proton hiệu quả hơn omeprazole	t	2025-12-04 20:03:55.583462	Ức chế bơm proton hiệu quả hơn omeprazole
230	20	18	Thay thế PPI khi không dung nạp	f	2025-12-04 20:03:55.583462	Thay thế PPI khi không dung nạp
231	18	29	Điều trị loét dạ dày tá tràng	t	2025-12-04 20:03:55.583462	Điều trị loét dạ dày tá tràng
232	19	29	Chữa lành loét, phòng ngừa tái phát	t	2025-12-04 20:03:55.583462	Chữa lành loét, phòng ngừa tái phát
233	31	29	Diệt H.pylori gây loét, phối hợp PPI	t	2025-12-04 20:03:55.583462	Diệt H.pylori gây loét, phối hợp PPI
234	21	27	Thuốc giãn phế quản dùng khi cấp cứu	t	2025-12-04 20:03:55.583462	Thuốc giãn phế quản dùng khi cấp cứu
235	22	27	Thuốc kiểm soát hen dài hạn, dạng hít	t	2025-12-04 20:03:55.583462	Thuốc kiểm soát hen dài hạn, dạng hít
236	23	27	Phối hợp khi hen nặng	f	2025-12-04 20:03:55.583462	Phối hợp khi hen nặng
205	2	1	Thuốc đầu tay điều trị đái tháo đường type 2	t	2025-12-04 20:03:55.583462	Thuốc đầu tay điều trị đái tháo đường type 2
206	2	11	Thuốc đầu tay điều trị đái tháo đường type 2	t	2025-12-04 20:03:55.583462	Thuốc đầu tay điều trị đái tháo đường type 2
207	3	1	Dùng khi metformin không đủ hiệu quả	f	2025-12-04 20:03:55.583462	Dùng khi metformin không đủ hiệu quả
208	3	11	Dùng khi metformin không đủ hiệu quả	f	2025-12-04 20:03:55.583462	Dùng khi metformin không đủ hiệu quả
209	4	1	Dùng khi thuốc uống không kiểm soát được đường huyết	f	2025-12-04 20:03:55.583462	Dùng khi thuốc uống không kiểm soát được đường huyết
210	4	11	Dùng khi thuốc uống không kiểm soát được đường huyết	f	2025-12-04 20:03:55.583462	Dùng khi thuốc uống không kiểm soát được đường huyết
211	5	2	Thuốc hạ huyết áp nhóm chẹn kênh canxi	t	2025-12-04 20:03:55.583462	Thuốc hạ huyết áp nhóm chẹn kênh canxi
212	5	12	Thuốc hạ huyết áp nhóm chẹn kênh canxi	t	2025-12-04 20:03:55.583462	Thuốc hạ huyết áp nhóm chẹn kênh canxi
213	6	2	Chẹn thụ thể angiotensin, bảo vệ thận	t	2025-12-04 20:03:55.583462	Chẹn thụ thể angiotensin, bảo vệ thận
214	6	12	Chẹn thụ thể angiotensin, bảo vệ thận	t	2025-12-04 20:03:55.583462	Chẹn thụ thể angiotensin, bảo vệ thận
215	7	2	Ức chế men chuyển, tốt cho bệnh nhân có bệnh thận	f	2025-12-04 20:03:55.583462	Ức chế men chuyển, tốt cho bệnh nhân có bệnh thận
237	21	28	Giãn phế quản, giảm khó thở	t	2025-12-04 20:03:55.583462	Giãn phế quản, giảm khó thở
238	22	28	Giảm viêm đường thở mãn tính	t	2025-12-04 20:03:55.583462	Giảm viêm đường thở mãn tính
239	23	28	Hỗ trợ giãn phế quản	f	2025-12-04 20:03:55.583462	Hỗ trợ giãn phế quản
240	24	24	Lợi tiểu giảm phù, giảm gánh nặng tim	t	2025-12-04 20:03:55.583462	Lợi tiểu giảm phù, giảm gánh nặng tim
241	7	24	Giảm hậu gánh, cải thiện tiên lượng	t	2025-12-04 20:03:55.583462	Giảm hậu gánh, cải thiện tiên lượng
242	25	24	Tăng co bóp tim, điều trị suy tim mãn	f	2025-12-04 20:03:55.583462	Tăng co bóp tim, điều trị suy tim mãn
243	26	24	Lợi tiểu giữ kali, giảm tử vong	t	2025-12-04 20:03:55.583462	Lợi tiểu giữ kali, giảm tử vong
244	27	13	Chống đông máu, phòng huyết khối tái phát	t	2025-12-04 20:03:55.583462	Chống đông máu, phòng huyết khối tái phát
245	27	23	Phòng ngừa đột quỵ do rung nhĩ	t	2025-12-04 20:03:55.583462	Phòng ngừa đột quỵ do rung nhĩ
246	28	13	Thuốc chống đông mới, tiện dùng hơn warfarin	t	2025-12-04 20:03:55.583462	Thuốc chống đông mới, tiện dùng hơn warfarin
247	28	23	Chống đông không cần theo dõi INR	t	2025-12-04 20:03:55.583462	Chống đông không cần theo dõi INR
248	29	25	Kháng sinh điều trị nhiễm Salmonella	t	2025-12-04 20:03:55.583462	Kháng sinh điều trị nhiễm Salmonella
249	29	26	Điều trị nhiễm trùng huyết Salmonella	t	2025-12-04 20:03:55.583462	Điều trị nhiễm trùng huyết Salmonella
250	29	35	Điều trị nhiễm E.coli đường ruột	t	2025-12-04 20:03:55.583462	Điều trị nhiễm E.coli đường ruột
251	29	36	Điều trị viêm ruột Campylobacter	t	2025-12-04 20:03:55.583462	Điều trị viêm ruột Campylobacter
252	29	37	Kháng sinh phổ rộng điều trị viêm dạ dày ruột	t	2025-12-04 20:03:55.583462	Kháng sinh phổ rộng điều trị viêm dạ dày ruột
253	30	36	Thay thế ciprofloxacin khi kháng thuốc	f	2025-12-04 20:03:55.583462	Thay thế ciprofloxacin khi kháng thuốc
254	30	37	Kháng sinh macrolide điều trị tiêu chảy	f	2025-12-04 20:03:55.583462	Kháng sinh macrolide điều trị tiêu chảy
255	32	38	Thuốc lao hàng đầu, phối hợp 4 thuốc	t	2025-12-04 20:03:55.583462	Thuốc lao hàng đầu, phối hợp 4 thuốc
256	32	39	Điều trị lao màng não, phối hợp rifampicin	t	2025-12-04 20:03:55.583462	Điều trị lao màng não, phối hợp rifampicin
257	33	38	Kháng sinh lao mạnh, làm đỏ nước tiểu	t	2025-12-04 20:03:55.583462	Kháng sinh lao mạnh, làm đỏ nước tiểu
258	33	39	Thuốc lao thiết yếu cho lao màng não	t	2025-12-04 20:03:55.583462	Thuốc lao thiết yếu cho lao màng não
259	34	38	Phối hợp điều trị lao giai đoạn đầu	t	2025-12-04 20:03:55.583462	Phối hợp điều trị lao giai đoạn đầu
260	34	39	Thuốc lao phối hợp, theo dõi thị lực	f	2025-12-04 20:03:55.583462	Thuốc lao phối hợp, theo dõi thị lực
261	35	38	Dùng 2 tháng đầu điều trị lao	t	2025-12-04 20:03:55.583462	Dùng 2 tháng đầu điều trị lao
262	35	39	Giai đoạn đầu điều trị lao màng não	t	2025-12-04 20:03:55.583462	Giai đoạn đầu điều trị lao màng não
263	36	32	Hormone tuyến giáp điều trị suy giáp suốt đời	t	2025-12-04 20:03:55.583462	Hormone tuyến giáp điều trị suy giáp suốt đời
264	37	33	Giảm hormone giáp, điều trị cường giáp	t	2025-12-04 20:03:55.583462	Giảm hormone giáp, điều trị cường giáp
265	38	33	Thuốc cường giáp ít tác dụng phụ hơn PTU	t	2025-12-04 20:03:55.583462	Thuốc cường giáp ít tác dụng phụ hơn PTU
266	39	31	Thuốc đầu tay điều trị viêm khớp dạng thấp	t	2025-12-04 20:03:55.583462	Thuốc đầu tay điều trị viêm khớp dạng thấp
267	40	31	Chống thấp, ít tác dụng phụ	t	2025-12-04 20:03:55.583462	Chống thấp, ít tác dụng phụ
268	41	34	Điều trị cơn migraine cấp	t	2025-12-04 20:03:55.583462	Điều trị cơn migraine cấp
269	42	34	Phòng ngừa migraine dài hạn	t	2025-12-04 20:03:55.583462	Phòng ngừa migraine dài hạn
270	43	22	Chống kết tập tiểu cầu, phòng nhồi máu cơ tim	t	2025-12-04 20:03:55.583462	Chống kết tập tiểu cầu, phòng nhồi máu cơ tim
271	8	22	Giảm cholesterol, ổn định mảng xơ vữa	t	2025-12-04 20:03:55.583462	Giảm cholesterol, ổn định mảng xơ vữa
272	5	22	Giảm đau thắt ngực, giãn mạch vành	f	2025-12-04 20:03:55.583462	Giảm đau thắt ngực, giãn mạch vành
273	7	17	Bảo vệ thận, giảm protein niệu	t	2025-12-04 20:03:55.583462	Bảo vệ thận, giảm protein niệu
274	6	17	Chậm tiến triển suy thận	t	2025-12-04 20:03:55.583462	Chậm tiến triển suy thận
275	2	6	Cải thiện gan nhiễm mỡ ở bệnh nhân tiểu đường	f	2025-12-04 20:03:55.583462	Cải thiện gan nhiễm mỡ ở bệnh nhân tiểu đường
276	2	30	Giảm mỡ gan, cải thiện chức năng gan	f	2025-12-04 20:03:55.583462	Giảm mỡ gan, cải thiện chức năng gan
277	8	6	Giảm mỡ máu, cải thiện gan nhiễm mỡ	f	2025-12-04 20:03:55.583462	Giảm mỡ máu, cải thiện gan nhiễm mỡ
278	8	30	Điều trị rối loạn lipid kèm gan nhiễm mỡ	f	2025-12-04 20:03:55.583462	Điều trị rối loạn lipid kèm gan nhiễm mỡ
279	18	7	Giảm acid dạ dày, giảm viêm niêm mạc	t	2025-12-04 20:03:55.583462	Giảm acid dạ dày, giảm viêm niêm mạc
280	20	7	Điều trị viêm dạ dày nhẹ	f	2025-12-04 20:03:55.583462	Điều trị viêm dạ dày nhẹ
281	13	8	Bổ sung sắt điều trị thiếu máu	t	2025-12-04 20:06:00.00764	Bổ sung sắt điều trị thiếu máu
282	13	14	Điều trị thiếu máu do thiếu sắt	t	2025-12-04 20:06:00.00764	Điều trị thiếu máu do thiếu sắt
283	14	8	Điều trị thiếu máu do thiếu acid folic	t	2025-12-04 20:06:00.00764	Điều trị thiếu máu do thiếu acid folic
284	15	8	Điều trị thiếu máu do thiếu B12	f	2025-12-04 20:06:00.00764	Điều trị thiếu máu do thiếu B12
285	15	14	Phối hợp sắt nếu thiếu B12	f	2025-12-04 20:06:00.00764	Phối hợp sắt nếu thiếu B12
286	45	15	Bổ sung canxi và vitamin D hàng ngày	t	2025-12-04 20:06:00.00764	Bổ sung canxi và vitamin D hàng ngày
287	2	4	Hỗ trợ giảm cân ở bệnh nhân béo phì có kháng insulin	f	2025-12-04 20:06:00.00764	Hỗ trợ giảm cân ở bệnh nhân béo phì có kháng insulin
288	46	20	Bù nước điện giải điều trị bệnh tả	t	2025-12-04 20:06:00.00764	Bù nước điện giải điều trị bệnh tả
289	29	20	Kháng sinh điều trị bệnh tả nặng	t	2025-12-04 20:06:00.00764	Kháng sinh điều trị bệnh tả nặng
290	29	21	Kháng sinh đầu tay điều trị sốt thương hàn	t	2025-12-04 20:06:00.00764	Kháng sinh đầu tay điều trị sốt thương hàn
291	30	21	Kháng sinh thay thế khi kháng ciprofloxacin	t	2025-12-04 20:06:00.00764	Kháng sinh thay thế khi kháng ciprofloxacin
292	14	9	Bổ sung vitamin trong suy dinh dưỡng	f	2025-12-04 20:06:00.00764	Bổ sung vitamin trong suy dinh dưỡng
293	15	9	Bổ sung vitamin B12	f	2025-12-04 20:06:00.00764	Bổ sung vitamin B12
294	44	10	Giảm triệu chứng sốt, đau do dị ứng nhẹ	f	2025-12-04 20:06:00.00764	Giảm triệu chứng sốt, đau do dị ứng nhẹ
\.


--
-- TOC entry 6662 (class 0 OID 24019)
-- Dependencies: 391
-- Data for Name: drugnutrientcontraindication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drugnutrientcontraindication (contra_id, drug_id, nutrient_id, avoid_hours_before, avoid_hours_after, warning_message_vi, warning_message_en, severity, created_at) FROM stdin;
179	27	14	0.00	0.00	Vitamin K có thể làm giảm hiệu quả của thuốc chống đông máu. Tránh thay đổi đột ngột lượng rau xanh trong chế độ ăn.	Vitamin K can reduce anticoagulant effectiveness. Avoid sudden changes in green vegetable intake.	high	2025-12-05 05:40:08.572331
180	8	15	2.00	2.00	Bưởi có thể tăng nồng độ thuốc trong máu. Tránh bưởi và nước ép bưởi.	Grapefruit can increase drug levels. Avoid grapefruit and grapefruit juice.	medium	2025-12-05 05:40:08.572331
181	9	15	2.00	2.00	Bưởi có thể tăng nguy cơ tác dụng phụ. Hoàn toàn tránh bưởi.	Grapefruit can increase side effect risk. Completely avoid grapefruit.	high	2025-12-05 05:40:08.572331
201	19	23	0.00	0.00	Sử dụng lâu dài có thể giảm hấp thu Vitamin B12.	Long-term use may reduce B12 absorption.	low	2025-12-05 05:42:27.397366
202	19	26	0.00	0.00	Sử dụng lâu dài có thể làm giảm magie.	Long-term use may reduce magnesium.	low	2025-12-05 05:42:27.397366
203	33	12	0.00	0.00	Có thể làm giảm Vitamin D. Xem xét bổ sung Vitamin D.	May reduce Vitamin D. Consider Vitamin D supplementation.	low	2025-12-05 05:42:27.397366
204	30	26	2.00	2.00	Magie có thể làm giảm hấp thu kháng sinh. Uống cách xa 2 giờ.	Magnesium may reduce antibiotic absorption. Take 2 hours apart.	low	2025-12-05 05:42:27.397366
205	31	14	0.00	0.00	Kháng sinh có thể giảm vi khuẩn đường ruột sản xuất Vitamin K.	Antibiotic may reduce gut bacteria producing Vitamin K.	low	2025-12-05 05:42:27.397366
182	36	24	4.00	4.00	Canxi làm giảm hấp thu hormone tuyến giáp. Uống thuốc cách xa sữa, phô mai 4 giờ.	Calcium reduces thyroid hormone absorption. Take medication 4 hours away from dairy.	high	2025-12-05 05:42:27.397366
183	36	29	4.00	4.00	Sắt làm giảm hấp thu hormone tuyến giáp. Uống thuốc cách xa thực phẩm giàu sắt 4 giờ.	Iron reduces thyroid hormone absorption. Take medication 4 hours away from iron-rich foods.	high	2025-12-05 05:42:27.397366
184	32	20	0.00	0.00	Isoniazid làm giảm Vitamin B6. Bác sĩ có thể kê bổ sung Vitamin B6.	Isoniazid depletes Vitamin B6. Doctor may prescribe B6 supplement.	low	2025-12-05 05:42:27.397366
185	2	23	0.00	0.00	Sử dụng lâu dài có thể làm giảm Vitamin B12. Kiểm tra định kỳ.	Long-term use may reduce Vitamin B12. Regular monitoring recommended.	low	2025-12-05 05:42:27.397366
186	7	27	0.00	0.00	Có thể làm tăng kali máu. Hạn chế thực phẩm giàu kali như chuối, khoai tây.	May increase blood potassium. Limit potassium-rich foods like bananas, potatoes.	medium	2025-12-05 05:42:27.397366
187	6	27	0.00	0.00	Có thể làm tăng kali máu. Hạn chế thực phẩm giàu kali.	May increase blood potassium. Limit potassium-rich foods.	medium	2025-12-05 05:42:27.397366
188	26	27	0.00	0.00	Thuốc giữ kali. Tránh bổ sung kali và hạn chế thực phẩm giàu kali.	Potassium-sparing diuretic. Avoid potassium supplements and limit potassium-rich foods.	high	2025-12-05 05:42:27.397366
189	25	24	2.00	2.00	Canxi cao có thể gây rối loạn nhịp tim. Tránh bổ sung canxi liều cao.	High calcium may cause heart rhythm problems. Avoid high-dose calcium supplements.	high	2025-12-05 05:42:27.397366
190	25	26	2.00	2.00	Magie thấp có thể tăng độc tính digoxin. Duy trì mức magie bình thường.	Low magnesium may increase digoxin toxicity. Maintain normal magnesium levels.	medium	2025-12-05 05:42:27.397366
191	29	24	2.00	6.00	Canxi làm giảm mạnh hấp thu kháng sinh. Tránh sữa 2 giờ trước, 6 giờ sau uống thuốc.	Calcium significantly reduces antibiotic absorption. Avoid dairy 2h before, 6h after.	high	2025-12-05 05:42:27.397366
192	29	29	2.00	6.00	Sắt làm giảm hấp thu kháng sinh. Tránh thực phẩm giàu sắt 2-6 giờ.	Iron reduces antibiotic absorption. Avoid iron-rich foods 2-6 hours.	high	2025-12-05 05:42:27.397366
193	29	30	2.00	6.00	Kẽm làm giảm hấp thu kháng sinh. Tránh bổ sung kẽm 2-6 giờ.	Zinc reduces antibiotic absorption. Avoid zinc supplements 2-6 hours.	medium	2025-12-05 05:42:27.397366
194	17	24	0.50	2.00	Uống thuốc lúc đói, 30 phút trước ăn sáng. Tránh canxi 2 giờ sau uống thuốc.	Take on empty stomach, 30 min before breakfast. Avoid calcium 2 hours after.	high	2025-12-05 05:42:27.397366
195	13	24	2.00	2.00	Canxi cản trở hấp thu sắt. Uống thuốc sắt cách xa sữa 2 giờ.	Calcium interferes with iron absorption. Take iron 2 hours away from dairy.	medium	2025-12-05 05:42:27.397366
196	39	22	0.00	0.00	Thuốc làm giảm folate. Bác sĩ thường kê bổ sung acid folic.	Drug depletes folate. Doctor usually prescribes folic acid supplement.	low	2025-12-05 05:42:27.397366
197	24	27	0.00	0.00	Thuốc lợi tiểu làm mất kali. Ăn nhiều thực phẩm giàu kali hoặc bổ sung theo chỉ định.	Diuretic causes potassium loss. Eat potassium-rich foods or supplement as directed.	medium	2025-12-05 05:42:27.397366
198	24	26	0.00	0.00	Có thể làm giảm magie. Xem xét bổ sung nếu có triệu chứng.	May reduce magnesium. Consider supplement if symptoms occur.	low	2025-12-05 05:42:27.397366
199	18	23	0.00	0.00	Sử dụng lâu dài có thể giảm hấp thu Vitamin B12. Kiểm tra định kỳ.	Long-term use may reduce B12 absorption. Regular monitoring recommended.	low	2025-12-05 05:42:27.397366
200	18	26	0.00	0.00	Sử dụng lâu dài có thể làm giảm magie. Xét nghiệm nếu có triệu chứng.	Long-term use may reduce magnesium. Test if symptoms occur.	low	2025-12-05 05:42:27.397366
\.


--
-- TOC entry 6545 (class 0 OID 21624)
-- Dependencies: 264
-- Data for Name: fattyacid; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fattyacid (fatty_acid_id, code, name, description, unit, hex_color, home_display, is_user_editable, created_at) FROM stdin;
1	ALA	ALA (Alpha-Linolenic Acid)	Plant-based omega-3 fatty acid	g	#00CED1	t	f	2025-11-19 07:13:01.565164
2	EPA	EPA (Eicosapentaenoic Acid)	Marine omega-3 fatty acid	g	#1E90FF	t	f	2025-11-19 07:13:01.565164
3	DHA	DHA (Docosahexaenoic Acid)	Marine omega-3 fatty acid	g	#4169E1	t	f	2025-11-19 07:13:01.565164
4	EPA_DHA	EPA + DHA Combined	Combined EPA and DHA	g	#0000CD	t	f	2025-11-19 07:13:01.565164
5	LA	LA (Linoleic Acid)	Omega-6 fatty acid	g	#FFA500	f	f	2025-11-19 07:13:01.565164
6	CHOLESTEROL	Cholesterol	Dietary cholesterol	mg	#8B0000	f	f	2025-11-19 07:13:01.565164
7	TOTAL_FAT	Total Fat	Total fat content	g	#DC143C	t	f	2025-11-19 07:13:01.565164
15	PUFA	Polyunsaturated Fat (PUFA)	Polyunsaturated fatty acids	g	#1ABC9C	f	f	2025-11-20 19:35:46.721858
16	TRANS_FAT	Trans Fat (total)	Trans fatty acids	g	#7F8C8D	f	f	2025-11-20 19:35:46.721858
17	MUFA	Monounsaturated Fat (MUFA)	Monounsaturated fatty acids	g	#27AE60	f	f	2025-11-20 19:35:46.721858
18	SFA	Saturated Fat (SFA)	Saturated fatty acids	g	#E74C3C	f	f	2025-11-20 19:35:46.721858
\.


--
-- TOC entry 6549 (class 0 OID 21660)
-- Dependencies: 268
-- Data for Name: fattyacidrequirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fattyacidrequirement (fa_req_id, fatty_acid_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes) FROM stdin;
1	7	\N	\N	\N	\N	g	f	t	30.0000	Total fat: default 30% of energy (range 25-35%)
2	18	\N	\N	\N	\N	g	f	t	10.0000	Saturated fat: limit to <10% energy
3	17	\N	\N	\N	\N	g	f	t	12.5000	MUFA: recommended ~10-15% energy (use 12.5%)
4	15	\N	\N	\N	\N	g	f	t	7.5000	PUFA: recommended ~5-10% energy (use 7.5%)
5	4	\N	\N	\N	250.000000	mg	f	f	\N	EPA+DHA baseline: 250 mg/day (adjusted by gender)
6	5	\N	\N	\N	\N	g	f	t	5.0000	Omega-6 (LA): recommended ~4-6% energy (use 5%)
7	16	\N	\N	\N	\N	g	f	t	1.0000	Trans fat: target ≤1% energy
8	6	\N	\N	\N	300.000000	mg	f	f	\N	Cholesterol: default 300 mg/day, reduced for older adults
\.


--
-- TOC entry 6543 (class 0 OID 21606)
-- Dependencies: 262
-- Data for Name: fiber; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fiber (fiber_id, code, name, description, unit, hex_color, home_display, is_user_editable, created_at) FROM stdin;
1	RESISTANT_STARCH	Resistant Starch	Starch that resists digestion	g	#8B6914	f	f	2025-11-19 07:13:01.565164
2	BETA_GLUCAN	Beta-Glucan	Soluble fiber found in oats and barley	g	#CD853F	f	f	2025-11-19 07:13:01.565164
5	INSOLUBLE_FIBER	Insoluble Fiber	Adds bulk and supports bowel regularity	g	#8D6E63	f	f	2025-11-20 19:35:46.721858
6	TOTAL_FIBER	Total Dietary Fiber	Sum of soluble and insoluble fiber	g	#4CAF50	t	f	2025-11-20 19:35:46.721858
7	SOLUBLE_FIBER	Soluble Fiber	Viscous fiber; aids cholesterol and glycemic control	g	#42A5F5	t	f	2025-11-20 19:35:46.721858
\.


--
-- TOC entry 6547 (class 0 OID 21642)
-- Dependencies: 266
-- Data for Name: fiberrequirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fiberrequirement (fiber_req_id, fiber_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes) FROM stdin;
1	6	\N	\N	\N	25.000000	g	f	f	\N	WHO/FAO recommended total dietary fiber (general adult guidance ~25 g/day)
2	7	\N	\N	\N	7.000000	g	f	f	\N	Soluble fiber guidance (approximate)
3	5	\N	\N	\N	15.000000	g	f	f	\N	Insoluble fiber guidance (approximate)
4	1	\N	\N	\N	10.000000	g	f	f	\N	Resistant starch guidance (approximate)
5	2	\N	\N	\N	3.000000	g	f	f	\N	Beta-glucan guidance (oats/barley soluble fiber)
6	6	\N	1	3	19.000000	g	f	f	\N	AI for children 1-3 years
7	6	\N	4	8	25.000000	g	f	f	\N	AI for children 4-8 years
8	6	male	9	13	31.000000	g	f	f	\N	AI for males 9-13 years
9	6	male	14	18	38.000000	g	f	f	\N	AI for males 14-18 years
10	6	male	19	50	38.000000	g	f	f	\N	AI for adult males 19-50
11	6	male	51	120	30.000000	g	f	f	\N	AI for males 51+
12	6	female	9	13	26.000000	g	f	f	\N	AI for females 9-13 years
13	6	female	14	18	26.000000	g	f	f	\N	AI for females 14-18 years
14	6	female	19	50	25.000000	g	f	f	\N	AI for adult females 19-50
15	6	female	51	120	21.000000	g	f	f	\N	AI for females 51+
\.


--
-- TOC entry 6512 (class 0 OID 21203)
-- Dependencies: 231
-- Data for Name: food; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.food (food_id, name, category, image_url, created_at, created_by_admin, description, serving_size_g, is_verified, is_active, updated_at, created_by_user, name_vi) FROM stdin;
3036	Goi Ga (Chicken Salad)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.894283	\N	Gỏi gà bắp cải
3037	Chao Tom (Shrimp on Sugarcane)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.895051	\N	Chạo tôm
1	Gao	grains	\N	2025-11-19 07:13:01.565164	\N	White rice grains	100.00	t	t	2025-12-01 00:30:31.863845	\N	Mật ong phân tích thành phần
2	Gao nep	grains	\N	2025-11-19 07:13:01.565164	\N	Sticky rice grains	100.00	t	t	2025-12-01 00:30:31.863845	\N	Rau họ cải phân tích glucosinolate
3081	Chanh	fruits	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Chanh
3082	Gạo lứt	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Gạo lứt
3	Banh pho	grains	\N	2025-11-19 07:13:01.565164	\N	Rice noodle sheets	100.00	t	t	2025-12-01 00:30:31.863845	\N	Sữa bò tươi ít tinh bột nhiều chất xơ
4	Banh trang	grains	\N	2025-11-19 07:13:01.565164	\N	Rice paper	10.00	t	t	2025-12-01 00:30:31.863845	\N	Bào ngư
10	Hanh tay	vegetables	\N	2025-11-19 07:13:01.565164	\N	Onion	50.00	t	t	2025-12-01 00:30:31.863845	\N	Adobo với mì
3069	Đậu xanh	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Đậu xanh
3070	Đậu đen	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Đậu đen
3071	Đậu đỏ	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Đậu đỏ (Đậu ván)
3072	Chuối tiêu	fruits	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Chuối tiêu
3073	Quýt	fruits	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Quýt
3074	Đu đủ	fruits	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Đu đủ (Papaya)
3075	Ổi	fruits	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Ổi
3076	Bưởi	fruits	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Bưởi
3077	Nhãn	fruits	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Nhãn
3078	Vải thiều	fruits	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Vải
3079	Măng cụt	fruits	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Măng cụt
3080	Chôm chôm	fruits	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Chôm chôm
3083	Gạo nếp	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Gạo nếp
3084	Yến mạch	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Yến mạch
3085	Bột mì nguyên cám	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Bột mì nguyên cám
3086	Bột gạo	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Bột gạo
3087	Bún tươi	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Bún
3088	Bánh phở	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Bánh phở
3089	Ngô	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Ngô (Bắp)
3090	Khoai mì	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Khoai mì (Sắn)
3091	Khoai môn	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Khoai môn
3092	Hành tây	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Hành tây
3093	Tỏi	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Tỏi
3094	Gừng	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Gừng
3095	Nấm rơm	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Nấm rơm
3096	Mè rang	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Mè (Vừng)
3097	Hạt điều	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Hạt điều
3098	Đậu phộng	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Đậu phộng (Lạc)
3099	Sữa bò	dairy	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Sữa tươi nguyên chất
3100	Sữa dê	dairy	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Sữa dê
3101	Sữa đậu nành	dairy	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Sữa đậu nành
3102	Bơ thực vật	oils	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Bơ thực vật
3103	Dầu ô liu	oils	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Dầu ô liu
3104	Dầu đậu nành	oils	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Dầu đậu nành
3105	Trứng vịt	protein	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Trứng vịt
19	Alcoholic beverage, beer, light	Beverages	\N	2025-12-01 00:30:31.863845	\N	\N	100.00	t	t	2025-12-05 05:49:29.862211	\N	Bia nhẹ
3038	Nem Nuong (Grilled Pork Sausage)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.895713	\N	Nem nướng
3039	Dau Hu Sot Ca Chua	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.896444	\N	Đậu hũ sốt cà chua
3040	Canh Suon Ham (Pork Rib Soup)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.897141	\N	Canh sườn hầm củ cải
90	Nước có gas	Beverages	\N	2025-11-25 19:21:40.853343	\N	Nước có gas cacbonic	100.00	t	t	2025-12-01 00:30:31.863845	\N	Giá cải bông sống
99	Chanh tươi	Fruits	\N	2025-11-25 19:21:40.853343	\N	Quả chanh vàng/xanh tươi	100.00	t	t	2025-12-01 00:30:31.863845	\N	Bơ hạnh nhân
100	Dưa hấu	Fruits	\N	2025-11-25 19:21:40.853343	\N	Dưa hấu đỏ tươi	100.00	t	t	2025-12-01 00:30:31.863845	\N	Bánh mì bơ hạnh nhân và mứt
3042	Thịt heo nạc	protein	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Thịt heo nạc
3043	Thịt bò nạc	protein	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Thịt bò nạc
3044	Thịt vịt	protein	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Thịt vịt
8	Rau thom	vegetables	\N	2025-11-19 07:13:01.565164	\N	Mixed aromatic herbs	20.00	t	t	2025-12-01 00:30:31.863845	\N	Súp hạt sồi kiểu Apache
9	Dua leo	vegetables	\N	2025-11-19 07:13:01.565164	\N	Cucumber	100.00	t	t	2025-12-01 00:30:31.863845	\N	Thực phẩm chay giàu B12 và Folate
11	Dua	fruits	\N	2025-11-19 07:13:01.565164	\N	Pineapple	100.00	t	t	2025-12-01 00:30:31.863845	\N	Adobo với cơm
12	Dau xanh	legumes	\N	2025-11-19 07:13:01.565164	\N	Mung beans	50.00	t	t	2025-12-01 00:30:31.863845	\N	Chất ngọt từ cây thùa
14	Hanh phi	condiments	\N	2025-11-19 07:13:01.565164	\N	Fried shallots	10.00	t	t	2025-12-01 00:30:31.863845	\N	Thùa sấy khô
17	Tieu	condiments	\N	2025-11-19 07:13:01.565164	\N	Black pepper	5.00	t	t	2025-12-01 00:30:31.863845	\N	Kem cá berry Alaska
3045	Cá rô phi	protein	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Cá rô phi
3046	Cá tra	protein	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Cá tra
3047	Cá chép	protein	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Cá chép
3048	Cá thu	protein	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Cá thu
3049	Tôm sú	protein	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Tôm sú
3050	Tôm thẻ	protein	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Tôm thẻ
3051	Mực ống	protein	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Mực ống
3052	Nghêu	protein	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Nghêu
3053	Rau dền	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Rau dền
3054	Bí đỏ	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Bí đỏ
3055	Bí đao	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Bí đao
3056	Cà rốt	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Cà rốt
3057	Khoai lang	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Khoai lang
3058	Khoai tây	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Khoai tây
3059	Cải bắp	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Cải bắp
3060	Bắp cải tím	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Bắp cải tím
3061	Cải ngọt	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Cải ngọt
3062	Cải xanh	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Cải xanh
3063	Su su	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Su su
3064	Mướp đắng	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Mướp đắng (Khổ qua)
3065	Ớt chuông	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Ớt chuông
3066	Đậu cove	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Đậu cove
3067	Đậu đũa	vegetables	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Đậu đũa
3068	Đậu phụ non	protein	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Đậu phụ non (Tàu hủ)
3001	Spinach, cooked	Vegetables	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.87523	\N	Rau bina (Cải bó xôi) nấu chín
3002	Kale, raw	Vegetables	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.875998	\N	Cải xoăn (Kale) sống
3003	Beef Liver	Meats	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.876772	\N	Gan bò
3004	Banana	Fruits	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.877342	\N	Chuối
3005	Orange Juice	Fruits	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.877834	\N	Nước cam ép
3026	Bun Rieu (Crab Noodle Soup)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.887172	\N	Bún riêu
3027	Hu Tieu (Pork Noodle Soup)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.887483	\N	Hủ tiếu Nam Vang
3028	Banh Cuon (Steamed Rice Rolls)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.887912	\N	Bánh cuốn
3006	Yogurt, plain	Dairy	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.878419	\N	Sữa chua không đường
3007	Salmon	Fish & Seafood	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.879041	\N	Cá hồi
3008	White Rice, cooked	Grains	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.879566	\N	Cơm trắng
3009	Broccoli	Vegetables	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.880125	\N	Súp lơ xanh
3010	Milk, whole	Dairy	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.880669	\N	Sữa tươi nguyên kem
3011	Pho Bo (Beef Pho)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.881181	\N	Phở bò
3012	Bun Cha (Grilled Pork with Noodles)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.881672	\N	Bún chả
3013	Com Tam (Broken Rice)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.882057	\N	Cơm tấm
3014	Banh Mi (Vietnamese Sandwich)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.882423	\N	Bánh mì Việt Nam
3015	Goi Cuon (Fresh Spring Rolls)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.882789	\N	Gỏi cuốn
3016	Canh Chua (Sour Soup)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.883164	\N	Canh chua cá
3017	Rau Muong Xao Toi (Water Spinach)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.883555	\N	Rau muống xào tỏi
3018	Ca Kho To (Caramelized Fish)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.883915	\N	Cá kho tộ
3019	Thit Kho Trung (Braised Pork with Eggs)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.88431	\N	Thịt kho trứng
3020	Xoi (Sticky Rice)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.884766	\N	Xôi
3021	Bun Bo Hue	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.885141	\N	Bún bò Huế
3022	Banh Xeo (Sizzling Pancake)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.885546	\N	Bánh xèo
3023	Cha Gio (Spring Rolls)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.885907	\N	Chả giò
3024	Mi Quang	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.886359	\N	Mì Quảng
3025	Cao Lau	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.886808	\N	Cao lầu Hội An
3029	Che (Sweet Soup)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.888753	\N	Chè đậu xanh
3030	Banh Flan (Caramel Custard)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.889975	\N	Bánh flan
3031	Bo Luc Lac (Shaking Beef)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.89068	\N	Bò lúc lắc
3032	Ga Kho Gung (Braised Chicken)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.891328	\N	Gà kho gừng
3033	Canh Khổ Qua (Bitter Melon Soup)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.892062	\N	Canh khổ qua nhồi thịt
3034	Thit Kho Tau (Braised Pork)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.89276	\N	Thịt kho tàu
3035	Ca Ri Ga (Chicken Curry)	Vietnamese Cuisine	\N	2025-12-01 00:09:51.290414	\N	\N	100.00	t	t	2025-12-05 05:49:29.893545	\N	Cà ri gà
5	Hanh la	vegetables	\N	2025-11-19 07:13:01.565164	\N	Green onion/scallion	20.00	t	t	2025-12-01 00:30:31.863845	\N	Abiyuch sống
6	Ngo	vegetables	\N	2025-11-19 07:13:01.565164	\N	Cilantro/coriander	10.00	t	t	2025-12-01 00:30:31.863845	\N	Nước ép acerola
7	Rau song	vegetables	\N	2025-11-19 07:13:01.565164	\N	Fresh vegetables mix	50.00	t	t	2025-12-01 00:30:31.863845	\N	Cherry Tây Ấn (Acerola) sống
3106	Gạo tẻ trắng	grains	\N	2025-12-05 05:25:41.893994	\N	\N	100.00	f	t	2025-12-05 05:25:41.893994	\N	Gạo trắng
3107	Chicken breast	protein	\N	2025-12-05 05:35:04.640777	\N	\N	100.00	f	t	2025-12-05 05:35:04.640777	\N	Ức gà
3108	Eggs	protein	\N	2025-12-05 05:35:04.640777	\N	\N	100.00	f	t	2025-12-05 05:35:04.640777	\N	Trứng gà
3109	Tomatoes	vegetables	\N	2025-12-05 05:35:04.640777	\N	\N	100.00	f	t	2025-12-05 05:35:04.640777	\N	Cà chua
3110	Avocado	fruits	\N	2025-12-05 05:35:04.640777	\N	\N	100.00	f	t	2025-12-05 05:35:04.640777	\N	Bơ
3111	Strawberries	fruits	\N	2025-12-05 05:35:04.640777	\N	\N	100.00	f	t	2025-12-05 05:35:04.640777	\N	Dâu tây
3112	Orange	fruits	\N	2025-12-05 05:35:04.640777	\N	\N	100.00	f	t	2025-12-05 05:35:04.640777	\N	Cam
3113	Bread	grains	\N	2025-12-05 05:35:04.640777	\N	\N	100.00	f	t	2025-12-05 05:35:04.640777	\N	Bánh mì
3114	Greek yogurt	dairy	\N	2025-12-05 05:35:04.640777	\N	\N	100.00	f	t	2025-12-05 05:35:04.640777	\N	Sữa chua Hy Lạp
3115	Sesame seeds	grains	\N	2025-12-05 05:35:04.640777	\N	\N	100.00	f	t	2025-12-05 05:35:04.640777	\N	Hạt mè
38	Nam	vegetables	\N	2025-11-19 17:05:28.915881	\N	Mushrooms	50.00	f	t	2025-12-05 05:45:58.438493	\N	Nam
40	Nuoc mam	condiments	\N	2025-11-19 17:05:28.915881	\N	Fish sauce	15.00	f	t	2025-12-05 05:45:58.438493	\N	Nuoc mam
41	Duong	condiments	\N	2025-11-19 17:05:28.915881	\N	Sugar	10.00	f	t	2025-12-05 05:45:58.438493	\N	Duong
43	Rau cu	vegetables	\N	2025-11-19 17:05:28.915881	\N	Mixed vegetables	100.00	f	t	2025-12-05 05:45:58.438493	\N	Rau cu
44	SuperFood Complete™ (Test Food)	Test Foods	https://images.unsplash.com/photo-1610348725531-843dff563e2c?w=400	2025-11-19 17:07:01.619202	1	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	SuperFood Complete™ (Test Food)
45	Cơm trắng	Ngũ cốc	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Cơm trắng
46	Bánh mì	Ngũ cốc	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Bánh mì
47	Phở	Ngũ cốc	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Phở
48	Bún	Ngũ cốc	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Bún
49	Miến	Ngũ cốc	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Miến
50	Rau muống	Rau củ	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Rau muống
51	Cải thảo	Rau củ	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Cải thảo
52	Cà chua	Rau củ	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Cà chua
53	Dưa chuột	Rau củ	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Dưa chuột
54	Rau cải	Rau củ	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Rau cải
55	Chuối	Trái cây	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Chuối
56	Táo	Trái cây	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Táo
57	Cam	Trái cây	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Cam
58	Xoài	Trái cây	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Xoài
60	Thịt lợn	Thịt	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Thịt lợn
61	Thịt gà	Thịt	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Thịt gà
62	Thịt bò	Thịt	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Thịt bò
63	Cá	Hải sản	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Cá
64	Tôm	Hải sản	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Tôm
65	Trứng gà	Trứng	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Trứng gà
66	Đậu hũ	Đậu	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Đậu hũ
67	Sữa tươi	Sữa	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Sữa tươi
68	Sữa chua	Sữa	\N	2025-11-19 17:11:14.097879	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Sữa chua
69	Ultra Food - Complete Nutrition	Test/Reference	\N	2025-11-19 22:16:40.041203	1	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Ultra Food - Complete Nutrition
70	Trà đen khô	drink_ingredient	\N	2025-11-21 01:07:08.078525	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Trà đen khô
71	Syrup đường	drink_ingredient	\N	2025-11-21 01:07:08.078525	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Syrup đường
73	Sữa tươi thanh trùng	drink_ingredient	\N	2025-11-21 01:07:08.078525	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Sữa tươi thanh trùng
74	Nước cốt dừa	drink_ingredient	\N	2025-11-21 01:07:08.078525	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Nước cốt dừa
75	Nước cam cô đặc	drink_ingredient	\N	2025-11-21 01:07:08.078525	\N	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Nước cam cô đặc
84	Phô mai	Sữa	https://example.com/cheese.jpg	2025-11-22 19:10:42.614303	1	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Phô mai
85	Cá mòi	Hải sản	https://example.com/sardine.jpg	2025-11-22 19:10:42.614303	1	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Cá mòi
86	Hạnh nhân	Hạt	https://example.com/almond.jpg	2025-11-22 19:10:42.614303	1	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Hạnh nhân
87	SuperFood Complete™ - Complete Nutrition (100% All Nutrients)	Test/Reference	https://images.unsplash.com/photo-1610348725531-843dff563e2c?w=400	2025-11-22 21:58:31.22252	1	Super food chứa 100% tất cả các chất dinh dưỡng cần thiết. Dùng để test và đảm bảo tất cả nutrient được cập nhật đúng. Khẩu phần chuẩn: 100g	100.00	f	t	2025-12-05 05:45:58.438493	\N	SuperFood Complete™ - Complete Nutrition (100% All Nutrients)
3041	Ultra Food Complete	Test Foods	\N	2025-12-03 22:58:24.374682	1	\N	100.00	f	t	2025-12-05 05:45:58.438493	\N	Ultra Food Complete
88	Nước lọc	Beverages	\N	2025-11-25 19:21:40.853343	\N	Nước tinh lọc không có tạp chất	100.00	f	t	2025-12-05 05:45:58.438493	\N	Nước lọc
89	Nước khoáng	Beverages	\N	2025-11-25 19:21:40.853343	\N	Nước khoáng thiên nhiên chứa các khoáng chất	100.00	f	t	2025-12-05 05:45:58.438493	\N	Nước khoáng
91	Nước dừa tươi	Beverages	\N	2025-11-25 19:21:40.853343	\N	Nước dừa xiêm tươi tự nhiên	100.00	f	t	2025-12-05 05:45:58.438493	\N	Nước dừa tươi
92	Nước mía	Beverages	\N	2025-11-25 19:21:40.853343	\N	Nước ép từ cây mía tươi	100.00	f	t	2025-12-05 05:45:58.438493	\N	Nước mía
93	Lá trà xanh	Beverages	\N	2025-11-25 19:21:40.853343	\N	Lá trà xanh khô dùng để pha	100.00	f	t	2025-12-05 05:45:58.438493	\N	Lá trà xanh
94	Lá trà đen	Beverages	\N	2025-11-25 19:21:40.853343	\N	Lá trà đen khô	100.00	f	t	2025-12-05 05:45:58.438493	\N	Lá trà đen
95	Cà phê bột	Beverages	\N	2025-11-25 19:21:40.853343	\N	Hạt cà phê rang xay	100.00	f	t	2025-12-05 05:45:58.438493	\N	Cà phê bột
96	Sữa tươi nguyên kem	Dairy	\N	2025-11-25 19:21:40.853343	\N	Sữa bò tươi nguyên chất	100.00	f	t	2025-12-05 05:45:58.438493	\N	Sữa tươi nguyên kem
98	Cam tươi	Fruits	\N	2025-11-25 19:21:40.853343	\N	Quả cam canh tươi	100.00	f	t	2025-12-05 05:45:58.438493	\N	Cam tươi
101	Xoài chín	Fruits	\N	2025-11-25 19:21:40.853343	\N	Xoài cát Hòa Lộc chín	100.00	f	t	2025-12-05 05:45:58.438493	\N	Xoài chín
102	Bơ (Quả)	Fruits	\N	2025-11-25 19:21:40.853343	\N	Quả bơ booth chín	100.00	f	t	2025-12-05 05:45:58.438493	\N	Bơ (Quả)
103	Trân châu đen	Ingredients	\N	2025-11-25 19:21:40.853343	\N	Trân châu bột sắn nấu chín	100.00	f	t	2025-12-05 05:45:58.438493	\N	Trân châu đen
104	Sữa chua không đường	Dairy	\N	2025-11-25 19:21:40.853343	\N	Sữa chua nguyên chất	100.00	f	t	2025-12-05 05:45:58.438493	\N	Sữa chua không đường
105	Rau má	Vegetables	\N	2025-11-25 19:21:40.853343	\N	Rau má tươi	100.00	f	t	2025-12-05 05:45:58.438493	\N	Rau má
106	Đậu nành	Legumes	\N	2025-11-25 19:21:40.853343	\N	Đậu nành hạt luộc chín	100.00	f	t	2025-12-05 05:45:58.438493	\N	Đậu nành
107	Hạnh nhân sống	Nuts	\N	2025-11-25 19:21:40.853343	\N	Hạt hạnh nhân nguyên vỏ	100.00	f	t	2025-12-05 05:45:58.438493	\N	Hạnh nhân sống
108	Thịt dừa	Fruits	\N	2025-11-25 19:21:40.853343	\N	Thịt dừa tươi cạo nhuyễn	100.00	f	t	2025-12-05 05:45:58.438493	\N	Thịt dừa
109	Đường trắng	Sweeteners	\N	2025-11-25 19:21:40.853343	\N	Đường mía tinh luyện	100.00	f	t	2025-12-05 05:45:58.438493	\N	Đường trắng
110	Đá lạnh	Ingredients	\N	2025-11-25 19:21:40.853343	\N	Nước đá đông lạnh	100.00	f	t	2025-12-05 05:45:58.438493	\N	Đá lạnh
111	Mật ong	Sweeteners	\N	2025-11-25 19:21:40.853343	\N	Mật ong nguyên chất	100.00	f	t	2025-12-05 05:45:58.438493	\N	Mật ong
112	Bột trà sữa	Ingredients	\N	2025-11-25 19:21:40.853343	\N	Hỗn hợp bột pha trà sữa	100.00	f	t	2025-12-05 05:45:58.438493	\N	Bột trà sữa
\.


--
-- TOC entry 6590 (class 0 OID 22192)
-- Dependencies: 313
-- Data for Name: foodcategory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.foodcategory (category_id, category_name, description, icon, created_at) FROM stdin;
1	Vegetables	All types of vegetables	🥦	2025-11-19 06:55:28.635343
2	Fruits	Fresh and dried fruits	🍎	2025-11-19 06:55:28.635343
3	Grains	Rice, bread, pasta, cereals	🌾	2025-11-19 06:55:28.635343
4	Protein Foods	Meat, poultry, fish, eggs, beans	🥩	2025-11-19 06:55:28.635343
5	Dairy	Milk, cheese, yogurt	🥛	2025-11-19 06:55:28.635343
6	Oils & Fats	Cooking oils, butter, margarine	🧈	2025-11-19 06:55:28.635343
7	Beverages	Drinks and liquids	🥤	2025-11-19 06:55:28.635343
8	Snacks	Chips, crackers, sweets	🍿	2025-11-19 06:55:28.635343
9	Mixed Dishes	Combined food items	🍱	2025-11-19 06:55:28.635343
10	Others	Miscellaneous food items	🍽️	2025-11-19 06:55:28.635343
\.


--
-- TOC entry 6516 (class 0 OID 21236)
-- Dependencies: 235
-- Data for Name: foodnutrient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.foodnutrient (food_nutrient_id, food_id, nutrient_id, amount_per_100g) FROM stdin;
1035	2	26	24.19
1036	2	2	3.70
1037	2	4	26.21
1038	2	5	40.12
1039	2	29	30.12
1040	2	28	41.55
1041	2	24	38.58
1042	2	3	37.13
1043	3	14	22.51
1044	3	15	27.10
1045	3	24	45.48
1046	3	29	37.12
1047	3	27	12.20
1048	4	26	33.50
1049	4	2	25.93
1050	4	28	48.17
1051	4	27	32.74
1052	4	29	14.28
1053	4	5	25.93
1054	5	28	23.43
1055	5	3	39.04
1056	5	5	16.17
1057	5	14	1.04
1058	5	30	29.39
1059	5	24	40.62
1060	5	27	9.17
1061	6	4	7.54
1062	6	30	34.35
1063	6	2	33.65
1064	6	14	33.19
1065	7	28	44.51
1066	7	26	19.39
1067	7	14	17.61
1068	7	30	26.89
1069	7	4	5.48
1070	7	5	42.24
1071	7	2	24.82
1072	8	27	42.94
1073	8	5	17.50
1074	8	2	0.69
1075	8	3	41.70
1076	9	2	26.83
1077	9	15	22.20
1078	9	29	29.62
1079	9	30	43.07
1080	9	4	32.15
1081	9	14	35.31
1140	3001	14	493.00
1141	3001	27	466.00
1142	3001	29	3.57
1143	3001	24	136.00
3475	3041	1	2000.00
3476	3041	2	50.00
3477	3041	3	70.00
3478	3041	4	250.00
3479	3041	11	8100.00
3480	3041	12	800.00
3481	3041	13	120.00
3482	3041	14	1080.00
3483	3041	15	720.00
3484	3041	16	10.00
3485	3041	17	11.70
3486	3041	18	128.00
3487	3041	19	41.80
3488	3041	20	10.90
3489	3041	21	251.00
3490	3041	22	3344.00
3491	3041	23	20.10
3492	3041	24	8216.00
3493	3041	25	5600.00
3494	3041	26	2547.00
3495	3041	27	28000.00
3496	3041	28	18400.00
3497	3041	29	147.90
3498	3041	30	99.00
3499	3041	31	7.39
3500	3041	32	18.90
3501	3041	33	1350.00
3502	3041	34	440.00
3503	3041	35	287.60
3504	3041	36	405.00
3505	3041	37	24.60
3506	3041	47	1.12
3507	3041	48	1.52
3508	3041	49	3.36
1197	3013	2	6.80
1198	3013	3	5.20
1199	3013	28	380.00
1200	3014	4	25.80
1201	3014	2	8.20
1202	3014	3	7.50
1203	3014	24	45.00
1204	3014	29	1.20
1205	3015	2	5.50
1206	3015	4	12.30
1207	3015	3	2.10
1208	3015	5	2.80
1209	3015	15	15.00
1210	3016	15	25.00
1211	3016	2	6.50
1212	3016	27	280.00
1213	3016	28	420.00
1214	3017	14	312.00
1215	3017	29	2.50
1216	3017	24	99.00
1217	3017	15	55.00
1218	3017	2	2.60
1219	3018	2	18.50
1220	3018	23	2.50
1221	3018	28	850.00
1222	3018	27	320.00
1223	3018	3	6.50
1224	3019	2	15.80
1225	3019	3	12.50
1226	3019	29	2.20
1227	3019	28	720.00
1228	3019	24	35.00
1229	3020	4	35.20
1230	3020	2	3.80
1231	3020	3	1.50
1232	3020	26	18.00
1233	3021	2	9.50
1234	3021	3	6.80
1235	3021	4	16.50
1296	3033	15	84.00
1297	3033	28	450.00
1298	3034	2	14.50
1299	3034	3	18.50
1300	3034	4	8.50
1301	3034	28	850.00
1302	3034	29	2.50
3509	3041	50	2.40
3510	3041	51	1.20
3511	3041	52	2.00
3512	3041	53	1.20
3513	3041	54	0.32
3514	3041	55	2.08
3515	3041	5	200.00
3516	3041	6	56.00
3517	3041	7	120.00
3518	3041	8	80.00
3519	3041	9	24.00
3520	3041	40	17.80
3521	3041	38	22.20
3522	3041	39	13.30
3523	3041	46	1.60
3524	3041	42	1.60
3525	3041	43	1.60
3526	3041	44	3.20
3527	3041	45	8.90
3528	3041	41	0.00
1102	38	26	33.31
1103	38	28	1.78
1104	38	15	15.93
1105	38	27	1.89
1119	41	27	36.09
1120	41	3	32.39
1027	1	2	20.30
1028	1	24	21.83
1029	1	28	47.00
1030	1	5	22.83
1031	1	29	29.85
1032	1	30	26.86
1033	1	3	21.77
1034	1	14	41.92
1082	9	24	47.40
1083	9	3	35.73
1084	10	15	29.99
1085	10	30	44.46
1086	10	14	46.01
1121	41	14	16.04
1122	41	28	13.13
1123	41	24	9.40
1124	41	4	6.98
1113	40	28	17.57
1114	40	5	23.39
1115	40	24	36.59
1116	40	15	31.14
1117	40	3	45.34
1118	40	26	7.16
3790	3079	4	17.90
3791	3079	5	1.80
3792	3079	15	2.90
3793	3079	27	48.00
3794	3080	1	82.00
3795	3080	2	0.70
3796	3080	3	0.20
3797	3080	4	20.90
3798	3080	5	0.90
3799	3080	15	4.90
3800	3080	27	42.00
3801	3081	1	29.00
3802	3081	2	1.10
3803	3081	3	0.30
3804	3081	4	9.30
3805	3081	5	2.80
3806	3081	15	53.00
3807	3081	24	26.00
3808	3081	27	138.00
3809	3082	1	111.00
3810	3082	2	2.60
3811	3082	3	0.90
3812	3082	4	23.00
3813	3082	5	1.80
3814	3082	25	162.00
3815	3082	26	43.00
3816	3083	1	97.00
3817	3083	2	2.00
3818	3083	3	0.20
3819	3083	4	21.10
3820	3083	5	0.90
3821	3083	25	26.00
3822	3083	26	3.00
3823	3084	1	68.00
3824	3084	2	2.40
3825	3084	3	1.40
3826	3084	4	12.00
3827	3084	5	1.70
3828	3084	25	77.00
3829	3084	26	10.00
3830	3085	1	340.00
3831	3085	2	13.20
3832	3085	3	2.50
3833	3085	4	72.00
3834	3085	5	10.70
3835	3085	25	346.00
1087	10	2	30.82
1088	10	4	23.29
1089	10	27	21.45
1090	10	5	16.74
1091	10	28	5.67
1092	11	28	37.24
1093	11	4	9.73
1094	11	14	39.11
1095	11	26	34.40
1096	12	4	40.81
1097	12	28	42.62
1098	12	27	35.12
1099	12	5	2.48
1100	12	26	45.72
1101	12	24	47.01
3836	3085	26	137.00
3837	3085	29	3.60
1106	14	26	19.81
1107	14	29	27.10
1108	14	3	44.89
1109	14	5	47.29
1110	14	28	28.96
1111	14	2	32.33
1112	14	27	46.52
1125	17	26	6.67
1126	17	3	35.17
1127	90	2	3.99
1128	90	24	32.00
1129	90	29	0.96
1130	90	14	30.50
1131	90	15	8.20
1132	99	2	20.96
1144	3001	26	87.00
1145	3001	2	2.97
1146	3002	14	817.00
1147	3002	24	150.00
1148	3002	15	120.00
1149	3002	26	47.00
1150	3002	29	1.47
1151	3003	23	83.10
1152	3003	29	4.90
1153	3003	2	20.30
1154	3003	24	5.00
1155	3003	30	4.00
1156	3004	27	358.00
3838	3086	1	366.00
3839	3086	2	6.00
3840	3086	3	1.40
3841	3086	4	80.10
3842	3086	5	2.40
3843	3086	25	98.00
3844	3086	26	10.00
3845	3087	1	109.00
3846	3087	2	1.80
3847	3087	3	0.20
3848	3087	4	25.00
3849	3087	5	0.70
3850	3087	25	43.00
1133	99	3	55.50
1134	99	24	347.00
1135	99	26	279.00
1136	99	29	3.49
1137	100	4	38.50
1138	100	2	10.20
1139	100	3	18.70
1157	3004	4	22.80
1158	3004	26	27.00
1159	3004	15	8.70
1160	3005	27	200.00
1161	3005	15	50.00
1162	3005	24	11.00
1163	3005	4	10.40
1164	3006	24	183.00
1165	3006	2	9.00
1166	3006	27	234.00
1167	3006	23	0.75
1168	3007	23	3.20
1169	3007	2	20.00
1170	3007	27	363.00
1171	3007	29	0.80
1172	3007	12	526.00
1173	3008	4	28.70
1174	3008	2	2.70
1175	3008	29	0.20
1176	3008	26	12.00
1177	3009	14	101.60
1178	3009	15	89.20
1179	3009	24	47.00
1180	3009	26	21.00
1181	3009	29	0.73
1182	3010	24	125.00
1183	3010	2	3.40
1184	3010	27	150.00
1185	3010	23	0.45
1186	3011	2	8.50
1187	3011	4	15.20
1188	3011	3	3.20
1189	3011	28	450.00
1190	3011	29	1.50
1191	3012	2	12.30
1192	3012	3	8.50
1193	3012	4	18.50
1194	3012	28	520.00
1195	3012	29	1.80
1196	3013	4	32.50
3529	3042	1	143.00
3530	3042	2	20.50
3531	3042	3	6.30
3532	3042	10	60.00
3533	3042	29	0.90
3534	3042	30	2.00
3535	3043	1	177.00
3536	3043	2	20.00
3537	3043	3	10.20
3538	3043	10	62.00
3539	3043	23	2.60
3540	3043	29	2.60
3541	3043	30	4.50
3542	3044	1	132.00
3543	3044	2	18.30
3544	3044	3	5.90
3545	3044	10	84.00
3546	3044	23	0.90
3547	3044	29	2.30
3548	3045	1	96.00
3549	3045	2	20.10
3550	3045	3	1.70
3551	3045	10	50.00
3552	3045	23	1.50
3553	3045	29	0.60
3554	3045	34	38.00
3555	3046	1	105.00
3556	3046	2	16.40
3557	3046	3	3.70
3558	3046	10	47.00
3559	3046	23	1.50
3560	3047	1	127.00
3561	3047	2	17.80
3562	3047	3	5.60
3563	3047	10	66.00
3564	3047	23	1.50
3565	3047	29	1.20
3566	3048	1	139.00
3567	3048	2	18.60
3568	3048	3	6.30
3569	3048	10	53.00
3570	3048	23	8.80
3571	3049	1	106.00
3572	3049	2	20.30
3573	3049	3	1.70
3574	3049	10	152.00
3575	3049	30	1.10
3576	3049	34	38.00
3577	3050	1	99.00
3578	3050	2	20.90
3579	3050	3	1.10
3580	3050	10	161.00
3581	3050	34	33.00
3582	3051	1	92.00
3583	3051	2	15.60
3584	3051	3	1.40
3585	3051	10	233.00
3586	3051	34	44.00
1236	3021	28	650.00
1237	3021	29	2.20
1238	3022	2	8.20
1239	3022	3	12.50
1240	3022	4	22.80
1241	3022	28	480.00
1242	3022	24	38.00
1243	3023	2	10.50
1244	3023	3	15.80
1245	3023	4	18.50
1246	3023	28	520.00
1247	3023	29	1.50
1248	3024	2	11.20
1249	3024	3	7.50
1250	3024	4	25.50
1251	3024	28	580.00
1252	3024	27	320.00
1253	3025	2	9.80
1254	3025	3	6.20
1255	3025	4	28.50
1256	3025	28	550.00
1257	3025	29	1.80
1258	3026	2	10.50
1259	3026	3	5.50
1260	3026	4	17.20
1261	3026	24	85.00
1262	3026	28	620.00
1263	3027	2	8.50
1264	3027	3	4.80
1265	3027	4	20.50
1266	3027	28	480.00
1267	3027	27	280.00
1268	3028	2	6.50
1269	3028	3	3.20
1270	3028	4	24.50
1271	3028	28	380.00
1272	3028	5	1.50
3587	3052	1	86.00
3588	3052	2	14.00
3589	3052	3	1.00
3590	3052	10	40.00
3591	3052	29	28.00
3592	3053	1	23.00
3593	3053	2	2.30
3594	3053	3	0.30
3595	3053	4	4.00
3596	3053	5	2.00
3597	3053	11	2917.00
3598	3053	15	43.00
3599	3053	24	215.00
3600	3053	29	2.30
3601	3054	1	26.00
3602	3054	2	1.00
3603	3054	3	0.10
3604	3054	4	6.50
3605	3054	5	0.50
3606	3054	11	8510.00
3607	3054	15	9.00
3608	3054	27	340.00
3609	3055	1	13.00
3610	3055	2	0.60
3611	3055	3	0.10
3612	3055	4	3.00
3613	3055	5	0.50
3614	3055	15	13.00
3615	3055	27	150.00
3616	3056	1	41.00
3617	3056	2	0.90
3618	3056	3	0.20
3619	3056	4	9.60
3620	3056	5	2.80
3621	3056	11	16706.00
3622	3056	15	5.90
3623	3056	24	33.00
3624	3056	27	320.00
3625	3057	1	86.00
3626	3057	2	1.60
3627	3057	3	0.10
3628	3057	4	20.10
3629	3057	5	3.00
3630	3057	11	14187.00
3631	3057	15	2.40
3632	3057	27	337.00
3633	3058	1	77.00
3634	3058	2	2.00
3635	3058	3	0.10
3636	3058	4	17.50
3637	3058	5	2.10
3638	3058	15	19.70
3639	3058	27	421.00
3640	3059	1	25.00
3641	3059	2	1.30
3642	3059	3	0.10
3643	3059	4	5.80
3644	3059	5	2.50
3645	3059	15	36.60
3646	3059	24	40.00
1273	3029	2	5.80
1274	3029	4	32.50
1275	3029	3	2.50
1276	3029	24	45.00
1277	3029	26	38.00
1278	3030	2	7.50
1279	3030	3	8.50
1280	3030	4	28.50
1281	3030	24	95.00
1282	3030	23	0.65
1283	3031	2	18.50
1284	3031	3	12.50
1285	3031	4	8.50
1286	3031	29	3.20
1287	3031	30	4.80
1288	3032	2	16.80
1289	3032	3	9.50
1290	3032	4	6.50
1291	3032	28	680.00
1292	3032	29	1.50
1293	3033	2	7.50
1294	3033	3	3.50
1295	3033	4	5.50
1317	3037	30	1.80
3647	3059	27	170.00
3648	3060	1	31.00
3649	3060	2	1.40
3650	3060	3	0.20
3651	3060	4	7.40
3652	3060	5	2.10
3653	3060	15	57.00
3654	3060	24	45.00
3655	3060	27	243.00
3656	3061	1	20.00
3657	3061	2	2.00
3658	3061	3	0.30
3659	3061	4	3.20
3660	3061	5	1.80
3661	3061	11	3500.00
1318	3038	2	15.80
1319	3038	3	12.50
1320	3038	4	8.50
1321	3038	28	580.00
1322	3038	29	1.50
1323	3039	2	10.50
1324	3039	3	6.50
1325	3039	4	9.50
1326	3039	24	180.00
1327	3039	15	28.00
1328	3040	2	12.50
1329	3040	3	8.50
1330	3040	4	6.50
1331	3040	24	65.00
3662	3061	15	30.00
1303	3035	2	15.20
1304	3035	3	11.50
1305	3035	4	12.50
1306	3035	27	380.00
1307	3035	26	42.00
1308	3036	2	14.50
1309	3036	3	3.80
1310	3036	4	8.50
1311	3036	15	45.00
1312	3036	5	3.50
1313	3037	2	16.50
1314	3037	3	5.50
1315	3037	4	12.50
1316	3037	28	520.00
1332	3040	27	350.00
3663	3061	24	100.00
3664	3061	29	1.50
3665	3062	1	13.00
3666	3062	2	1.50
3667	3062	3	0.20
3668	3062	4	2.20
3669	3062	5	1.00
3670	3062	11	4000.00
3671	3062	15	45.00
3672	3062	24	105.00
3673	3063	1	19.00
3674	3063	2	0.80
3675	3063	3	0.10
3676	3063	4	4.50
3677	3063	5	1.70
3678	3063	15	7.70
3679	3063	27	125.00
3680	3064	1	17.00
3681	3064	2	1.00
3682	3064	3	0.20
3683	3064	4	3.70
3684	3064	5	2.80
3685	3064	15	84.00
3686	3064	27	296.00
3687	3065	1	31.00
3688	3065	2	1.00
3689	3065	3	0.30
3690	3065	4	6.00
3691	3065	5	2.10
3692	3065	11	3131.00
3693	3065	15	127.70
3694	3065	27	211.00
3695	3066	1	31.00
3696	3066	2	2.80
3697	3066	3	0.20
3698	3066	4	5.70
3699	3066	5	2.60
3700	3066	15	12.20
3701	3066	27	260.00
3702	3067	1	31.00
3703	3067	2	1.80
3704	3067	3	0.10
3705	3067	4	7.10
3706	3067	5	2.70
3707	3067	15	16.30
3708	3067	27	209.00
3709	3068	1	55.00
3710	3068	2	5.30
3711	3068	3	2.70
3712	3068	4	2.90
3713	3068	24	200.00
3714	3068	29	2.20
3715	3069	1	105.00
3716	3069	2	7.00
3717	3069	3	0.40
3718	3069	4	19.00
3719	3069	5	7.60
3720	3069	22	159.00
3721	3069	29	1.40
3722	3070	1	132.00
3723	3070	2	8.90
3724	3070	3	0.50
3725	3070	4	23.70
3726	3070	5	8.70
3727	3070	22	149.00
3728	3070	29	2.10
3729	3071	1	127.00
3730	3071	2	8.70
3731	3071	3	0.50
3732	3071	4	22.80
3733	3071	5	7.40
3734	3071	22	230.00
3735	3071	29	2.90
3736	3072	1	89.00
3737	3072	2	1.10
3738	3072	3	0.30
3739	3072	4	22.80
3740	3072	5	2.60
3741	3072	15	8.70
3742	3072	27	358.00
3743	3073	1	53.00
3744	3073	2	0.80
3745	3073	3	0.30
3746	3073	4	13.30
3747	3073	5	1.80
3748	3073	15	26.70
3749	3073	27	166.00
3750	3074	1	43.00
3751	3074	2	0.50
3752	3074	3	0.30
3753	3074	4	11.00
3754	3074	5	1.70
3755	3074	11	950.00
3756	3074	15	60.90
3757	3074	27	182.00
3758	3075	1	68.00
3759	3075	2	2.60
3760	3075	3	1.00
3761	3075	4	14.30
3762	3075	5	5.40
3763	3075	15	228.30
3764	3075	24	18.00
3765	3075	27	417.00
3766	3076	1	42.00
3767	3076	2	0.80
3768	3076	3	0.04
3769	3076	4	10.70
3770	3076	5	1.00
3771	3076	15	61.00
3772	3076	27	135.00
3773	3077	1	60.00
3774	3077	2	1.30
3775	3077	3	0.10
3776	3077	4	15.10
3777	3077	5	1.10
3778	3077	15	84.00
3779	3077	27	266.00
3780	3078	1	66.00
3781	3078	2	0.80
3782	3078	3	0.40
3783	3078	4	16.50
3784	3078	5	1.30
3785	3078	15	71.50
3786	3078	27	171.00
3787	3079	1	73.00
3788	3079	2	0.40
3789	3079	3	0.60
3851	3087	26	7.00
3852	3088	1	109.00
3853	3088	2	1.60
3854	3088	3	0.10
3855	3088	4	25.90
3856	3088	5	0.50
3857	3088	25	38.00
3858	3088	26	6.00
3859	3089	1	86.00
3860	3089	2	3.30
3861	3089	3	1.40
3862	3089	4	18.70
3863	3089	5	2.00
3864	3089	25	89.00
3865	3089	26	37.00
3866	3090	1	160.00
3867	3090	2	1.40
3868	3090	3	0.30
3869	3090	4	38.10
3870	3090	5	1.80
3871	3090	26	21.00
3872	3090	27	271.00
3873	3091	1	112.00
3874	3091	2	1.50
3875	3091	3	0.20
3876	3091	4	26.50
3877	3091	5	4.10
3878	3091	24	43.00
3879	3091	26	33.00
3880	3091	27	591.00
3881	3092	1	40.00
3882	3092	2	1.10
3883	3092	3	0.10
3884	3092	4	9.30
3885	3092	5	1.70
3886	3092	15	7.40
3887	3092	27	146.00
3888	3093	1	149.00
3889	3093	2	6.40
3890	3093	3	0.50
3891	3093	4	33.10
3892	3093	5	2.10
3893	3093	15	31.20
3894	3093	24	181.00
3895	3093	27	401.00
3896	3094	1	80.00
3897	3094	2	1.80
3898	3094	3	0.80
3899	3094	4	17.80
3900	3094	5	2.00
3901	3094	15	5.00
3902	3094	27	415.00
3903	3095	1	35.00
3904	3095	2	3.10
3905	3095	3	0.30
3906	3095	4	6.50
3907	3095	5	2.30
3908	3095	25	86.00
3909	3095	27	356.00
3910	3096	1	573.00
3911	3096	2	17.70
3912	3096	3	49.70
3913	3096	4	23.40
3914	3096	5	11.80
3915	3096	24	975.00
3916	3096	29	14.60
3917	3097	1	553.00
3918	3097	2	18.20
3919	3097	3	43.80
3920	3097	4	30.20
3921	3097	5	3.30
3922	3097	26	292.00
3923	3097	30	5.80
3924	3098	1	567.00
3925	3098	2	25.80
3926	3098	3	49.20
3927	3098	4	16.10
3928	3098	5	8.50
3929	3098	26	168.00
3930	3098	29	4.60
3931	3099	1	61.00
3932	3099	2	3.20
3933	3099	3	3.30
3934	3099	4	4.80
3935	3099	24	113.00
3936	3099	25	84.00
3937	3099	27	143.00
3938	3100	1	69.00
3939	3100	2	3.60
3940	3100	3	4.10
3941	3100	4	4.50
3942	3100	24	134.00
3943	3100	25	111.00
3944	3100	27	204.00
3945	3101	1	33.00
3946	3101	2	2.90
3947	3101	3	1.60
3948	3101	4	1.70
3949	3101	24	25.00
3950	3101	29	0.50
3951	3102	1	717.00
3952	3102	2	0.90
3953	3102	3	81.00
3954	3102	4	0.10
3955	3102	11	819.00
3956	3103	1	884.00
3957	3103	2	0.00
3958	3103	3	100.00
3959	3103	4	0.00
3960	3103	38	73.00
3961	3103	39	10.50
3962	3104	1	884.00
3963	3104	2	0.00
3964	3104	3	100.00
3965	3104	4	0.00
3966	3104	38	23.30
3967	3104	39	57.70
3968	3104	40	15.60
3969	3105	1	185.00
3970	3105	2	13.00
3971	3105	3	13.80
3972	3105	4	1.50
3973	3105	10	884.00
3974	3105	23	3.80
3975	3105	24	64.00
3976	3105	29	3.80
3977	3106	1	130.00
3978	3106	2	2.70
3979	3106	3	0.30
3980	3106	4	28.20
3981	3106	5	0.40
3982	3106	25	115.00
3983	3106	26	25.00
3987	3107	10	85.00
3988	3107	23	0.40
3989	3107	29	0.90
3990	3107	30	1.50
3991	3108	1	155.00
3992	3108	2	13.00
3993	3108	3	11.00
3994	3108	4	1.10
3995	3108	10	373.00
3996	3108	23	1.80
3997	3108	24	56.00
3998	3108	29	2.70
3999	3109	1	18.00
4000	3109	2	0.90
4001	3109	3	0.20
4002	3109	4	3.90
4003	3109	5	1.20
4004	3109	11	833.00
4005	3109	15	13.70
4006	3109	27	237.00
4007	3110	1	160.00
4008	3110	2	2.00
4009	3110	3	14.70
4010	3110	4	8.50
4011	3110	5	6.70
4012	3110	11	146.00
4013	3110	15	10.00
4014	3110	27	485.00
4015	3111	1	32.00
4016	3111	2	0.70
4017	3111	3	0.30
4018	3111	4	7.70
4019	3111	5	2.00
4020	3111	11	12.00
4021	3111	15	58.80
4022	3111	27	153.00
4023	3112	1	47.00
4024	3112	2	0.90
4025	3112	3	0.10
4026	3112	4	11.80
4027	3112	5	2.40
4028	3112	15	53.20
4029	3112	24	40.00
4030	3112	27	181.00
4031	3113	1	265.00
4032	3113	2	9.00
4033	3113	3	3.20
4034	3113	4	49.00
4035	3113	5	2.70
4036	3113	25	115.00
4037	3113	26	43.00
4038	3114	1	59.00
4039	3114	2	10.00
4040	3114	3	0.40
4041	3114	4	3.60
4042	3114	24	110.00
4043	3114	25	141.00
4044	3115	1	573.00
4045	3115	2	17.70
4046	3115	3	49.70
4047	3115	4	23.40
4048	3115	5	11.80
4049	3115	24	975.00
4050	3115	29	14.60
3984	3107	1	165.00
3985	3107	2	31.00
3986	3107	3	3.60
\.


--
-- TOC entry 6518 (class 0 OID 21256)
-- Dependencies: 237
-- Data for Name: foodtag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.foodtag (tag_id, tag_name) FROM stdin;
\.


--
-- TOC entry 6519 (class 0 OID 21264)
-- Dependencies: 238
-- Data for Name: foodtagmapping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.foodtagmapping (food_id, tag_id) FROM stdin;
\.


--
-- TOC entry 6664 (class 0 OID 24449)
-- Dependencies: 394
-- Data for Name: friendrequest; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.friendrequest (request_id, sender_id, receiver_id, status, created_at, updated_at) FROM stdin;
1	2	1	accepted	2025-11-23 22:04:38.429358	2025-11-24 05:13:42.72614
2	3	1	rejected	2025-11-24 05:28:25.996759	2025-11-24 06:25:36.921093
3	1	3	accepted	2025-11-24 06:26:33.35418	2025-11-24 06:47:24.985891
4	3	2	accepted	2025-11-26 16:55:52.514366	2025-11-26 16:58:48.81072
5	4	1	pending	2025-11-27 04:52:49.710415	2025-11-27 04:52:49.710415
\.


--
-- TOC entry 6666 (class 0 OID 24479)
-- Dependencies: 396
-- Data for Name: friendship; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.friendship (friendship_id, user1_id, user2_id, created_at) FROM stdin;
1	1	2	2025-11-24 05:13:42.72614
2	1	3	2025-11-24 06:47:24.985891
3	2	3	2025-11-26 16:58:48.81072
\.


--
-- TOC entry 6592 (class 0 OID 22226)
-- Dependencies: 315
-- Data for Name: healthcondition; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.healthcondition (condition_id, name_vi, name_en, category, description, causes, image_url, treatment_duration_reference, created_at, updated_at, condition_code, condition_name, description_vi, article_link_vi, article_link_en, prevention_tips, prevention_tips_vi, severity_level, is_chronic) FROM stdin;
6	Gan nhiễm mỡ	Fatty Liver	Gan	Mỡ tích tụ trong gan.	Dư đường, chất béo bão hòa, béo phì.	\N	2–6 tháng	2025-11-19 06:56:08.695007	2025-11-19 06:56:08.695007	\N	\N	\N	\N	\N	\N	\N	moderate	f
7	Viêm dạ dày	Gastritis	Tiêu hóa	Viêm niêm mạc dạ dày.	HP, stress, đồ chua và dầu mỡ.	\N	2–8 tuần	2025-11-19 06:56:08.695007	2025-11-19 06:56:08.695007	\N	\N	\N	\N	\N	\N	\N	moderate	f
12	Tăng huyết áp (Cao huyết áp)	Essential Hypertension	I10	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
13	Huyết khối tĩnh mạch sâu (Cục máu đông)	Deep Vein Thrombosis (DVT)	I82	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
14	Thiếu máu do thiếu sắt	Iron Deficiency Anemia	D50	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
15	Loãng xương	Osteoporosis	M81	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
16	Gút (Gout)	Gout	M10	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
17	Bệnh thận mãn tính	Chronic Kidney Disease	N18	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
18	Trào ngược dạ dày thực quản	Gastroesophageal Reflux Disease (GERD)	K21	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
20	Bệnh tả không đặc hiệu	Cholera, unspecified	A009	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
21	Sốt thương hàn không đặc hiệu	Typhoid fever, unspecified	A0100	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
25	Viêm ruột Salmonella	Salmonella enteritis	A020	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
26	Nhiễm trùng huyết Salmonella	Salmonella sepsis	A021	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
35	Nhiễm E. coli gây bệnh đường ruột	Enteropathogenic Escherichia coli infection	A040	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
36	Viêm ruột Campylobacter	Campylobacter enteritis	A045	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
37	Viêm dạ dày ruột nhiễm trùng	Infectious gastroenteritis and colitis, unspecified	A09	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
38	Lao phổi	Tuberculosis of lung	A150	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
39	Viêm màng não do lao	Tuberculous meningitis	A170	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
19	Rối loạn lipid máu (Mỡ máu cao)	Hyperlipidemia	E78	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
22	Bệnh động mạch vành	Coronary Artery Disease	I25	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
23	Rung nhĩ	Atrial Fibrillation	I48	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
24	Suy tim	Heart Failure	I50	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
28	Bệnh phổi tắc nghẽn mãn tính	Chronic Obstructive Pulmonary Disease (COPD)	J44	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
29	Loét dạ dày tá tràng	Peptic Ulcer	K27	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
30	Gan nhiễm mỡ (Fatty Liver)	Fatty Liver Disease	K76	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
31	Viêm khớp dạng thấp	Rheumatoid Arthritis	M06	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
32	Suy giáp	Hypothyroidism	E03	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
33	Cường giáp	Hyperthyroidism	E05	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
34	Đau nửa đầu (Migraine)	Migraine	G43	\N	\N	\N	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	\N	\N	\N	\N	moderate	f
27	Hen phế quản	Asthma	J45	\N	\N	https://cdn.tgdd.vn/Files/2021/09/15/1382574/hen-suyen-nguyen-nhan-trieu-chung-va-cach-dieu-tri-202109151425421867.jpg	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	https://vinmec.com/vie/benh/hen-suyen-6340	https://www.mayoclinic.org/diseases-conditions/asthma/symptoms-causes/syc-20369653	Avoid triggers, no smoking, appropriate exercise.	TrÃ¡nh cÃ¡c yáº¿u tá»‘ kÃ­ch thÃ­ch, khÃ´ng hÃºt thuá»‘c, táº­p luyá»‡n thÃ­ch há»£p.	moderate	t
2	Cao huyết áp	Hypertension	Tim mạch	Huyết áp tăng cao mạn tính.	Ăn mặn, ít kali, stress, di truyền.	https://cdn.tgdd.vn/Files/2021/06/15/1358975/cao-huyet-ap-nguyen-nhan-trieu-chung-dieu-tri-va-phong-ngua-202106151442072634.jpg	Dài hạn	2025-11-19 06:56:08.695007	2025-11-19 06:56:08.695007	\N	\N	\N	https://vinmec.com/vie/benh/cao-huyet-ap-6314	https://www.mayoclinic.org/diseases-conditions/high-blood-pressure/symptoms-causes/syc-20373410	Limit salt intake, increase potassium, regular exercise, reduce stress, avoid alcohol.	Hạn chế muối, tăng cường kali, tập thể dục đều đặn, giảm stress, tránh rượu bia.	moderate	t
1	Tiểu đường type 2	Type 2 Diabetes	Chuyển hóa	Cơ thể kháng insulin làm đường huyết tăng cao.	Thừa cân, ít vận động, ăn nhiều tinh bột tinh chế.	https://cdn.tgdd.vn/Files/2022/02/01/1414070/tieu-duong-type-2-la-gi-nguyen-nhan-va-cach-phong-ngua-202202011434196274.jpg	Dài hạn	2025-11-19 06:56:08.695007	2025-11-19 06:56:08.695007	\N	\N	\N	https://vinmec.com/vie/benh/dai-thao-duong-type-2-6521	https://www.mayoclinic.org/diseases-conditions/type-2-diabetes/symptoms-causes/syc-20351193	Maintain healthy weight, regular exercise, limit sugar and refined carbs, increase fiber.	Duy trì cân nặng hợp lý, tập thể dục, ăn ít đường và tinh bột tinh chế, tăng chất xơ.	moderate	t
11	Đái tháo đường tuýp 2	Type 2 Diabetes Mellitus	E11	\N	\N	https://cdn.tgdd.vn/Files/2022/02/01/1414070/tieu-duong-type-2-la-gi-nguyen-nhan-va-cach-phong-ngua-202202011434196274.jpg	\N	2025-12-01 00:29:28.788236	2025-12-01 00:29:28.788236	\N	\N	\N	https://vinmec.com/vie/benh/dai-thao-duong-type-2-6521	https://www.mayoclinic.org/diseases-conditions/type-2-diabetes/symptoms-causes/syc-20351193	Maintain healthy weight, regular exercise, limit sugar and refined carbs, increase fiber.	Duy trì cân nặng hợp lý, tập thể dục, ăn ít đường và tinh bột tinh chế, tăng chất xơ.	moderate	t
8	Thiếu máu	Anemia	Huyết học	Thiếu hồng cầu do thiếu sắt, B12 hoặc folate.	Ăn thiếu sắt, thiếu vitamin B12 hoặc B9.	https://cdn.tgdd.vn/Files/2021/10/12/1389456/thieu-mau-la-gi-nguyen-nhan-trieu-chung-va-cach-dieu-tri-202110121105076789.jpg	1–3 tháng	2025-11-19 06:56:08.695007	2025-12-04 20:06:00.00764	\N	\N	\N	https://vinmec.com/vie/benh/thieu-mau-6365	https://www.mayoclinic.org/diseases-conditions/anemia/symptoms-causes/syc-20351360	Ăn thực phẩm giàu sắt, vitamin B12, acid folic	Ăn thực phẩm giàu sắt, vitamin B12, acid folic	moderate	f
9	Suy dinh dưỡng	Malnutrition	Dinh dưỡng	Thiếu năng lượng và đạm.	Ăn không đủ protein và năng lượng.	https://cdn.tgdd.vn/Files/2021/11/15/1399123/suy-dinh-duong-la-gi-nguyen-nhan-trieu-chung-va-cach-dieu-tri-202111151428099999.jpg	1–3 tháng	2025-11-19 06:56:08.695007	2025-12-04 20:06:00.00764	\N	\N	\N	https://vinmec.com/vie/benh/suy-dinh-duong-6370	https://www.mayoclinic.org/diseases-conditions/malnutrition/symptoms-causes/syc-20374428	Chế độ ăn đa dạng, đầy đủ dinh dưỡng, theo dõi cân nặng	Chế độ ăn đa dạng, đầy đủ dinh dưỡng, theo dõi cân nặng	moderate	f
3	Mỡ máu cao	High Cholesterol	Tim mạch	LDL và Cholesterol cao dẫn đến xơ vữa mạch.	Ăn nhiều mỡ bão hòa, trans fat, ít vận động.	https://cdn.tgdd.vn/Files/2021/07/21/1367511/mo-mau-cao-nguyen-nhan-trieu-chung-va-cach-dieu-tri-202107211537588654.jpg	3–6 tháng	2025-11-19 06:56:08.695007	2025-11-19 06:56:08.695007	\N	\N	\N	https://vinmec.com/vie/benh/cholesterol-6325	https://www.mayoclinic.org/diseases-conditions/high-blood-cholesterol/symptoms-causes/syc-20350800	Reduce saturated fats, increase omega-3, exercise regularly, lose weight if overweight.	Ăn ít chất béo bão hòa, tăng omega-3, tập thể dục, giảm cân nếu thừa cân.	moderate	t
5	Gout	Gout	Chuyển hóa	Acid uric cao gây viêm khớp.	Ăn nhiều purine: thịt đỏ, hải sản.	https://cdn.tgdd.vn/Files/2021/08/11/1374175/benh-gout-la-gi-nguyen-nhan-trieu-chung-va-cach-dieu-tri-202108111051177484.jpg	1–3 tháng (duy trì lâu dài)	2025-11-19 06:56:08.695007	2025-11-19 06:56:08.695007	\N	\N	\N	https://vinmec.com/vie/benh/gout-6336	https://www.mayoclinic.org/diseases-conditions/gout/symptoms-causes/syc-20372897	Limit purine-rich foods (organ meats, seafood), drink plenty of water, reduce alcohol.	Hạn chế thực phẩm giàu purin (nội tạng, hải sản), uống nhiều nước, giảm rượu bia.	moderate	t
4	Béo phì	Obesity	Chuyển hóa	Tích lũy mỡ thừa do thừa năng lượng.	Ăn nhiều tinh bột tinh chế, chất béo, ít hoạt động.	https://cdn.tgdd.vn/Files/2022/03/15/1418986/beo-phi-la-gi-nguyen-nhan-va-cach-phong-ngua-202203151420581234.jpg	3–12 tháng	2025-11-19 06:56:08.695007	2025-12-04 20:06:00.00764	\N	\N	\N	https://vinmec.com/vie/benh/beo-phi-6350	https://www.mayoclinic.org/diseases-conditions/obesity/symptoms-causes/syc-20375742	Healthy eating, regular exercise, adequate sleep, stress management.	Ăn uống lành mạnh, tập thể dục đều đặn, ngủ đủ giấc, quản lý stress.	moderate	t
10	Dị ứng thực phẩm	Food Allergy	Miễn dịch	Phản ứng miễn dịch với protein thực phẩm.	Cơ địa dị ứng, di truyền.	https://cdn.tgdd.vn/Files/2021/09/20/1383678/di-ung-thuc-pham-nguyen-nhan-trieu-chung-va-cach-phong-ngua-202109201039277777.jpg	Lâu dài	2025-11-19 06:56:08.695007	2025-12-04 20:06:00.00764	\N	\N	\N	https://vinmec.com/vie/benh/di-ung-thuc-pham-6375	https://www.mayoclinic.org/diseases-conditions/food-allergy/symptoms-causes/syc-20355095	Tránh tiếp xúc thực phẩm gây dị ứng, đọc nhãn thực phẩm kỹ	Tránh tiếp xúc thực phẩm gây dị ứng, đọc nhãn thực phẩm kỹ	moderate	f
\.


--
-- TOC entry 6521 (class 0 OID 21282)
-- Dependencies: 240
-- Data for Name: meal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meal (meal_id, user_id, meal_type, meal_date, created_at, is_favorite, notes, photo_url, photo_recognition_data) FROM stdin;
1	1	breakfast	2025-11-19	2025-11-19 17:15:20.526323	f	\N	\N	\N
2	1	breakfast	2025-11-19	2025-11-19 17:22:51.742888	f	\N	\N	\N
3	1	breakfast	2025-11-19	2025-11-19 17:23:02.029974	f	\N	\N	\N
4	1	breakfast	2025-11-19	2025-11-19 18:28:37.682973	f	\N	\N	\N
5	1	breakfast	2025-11-19	2025-11-19 18:35:23.343518	f	\N	\N	\N
6	1	breakfast	2025-11-19	2025-11-19 18:35:28.798292	f	\N	\N	\N
7	1	breakfast	2025-11-19	2025-11-19 19:04:28.355553	f	\N	\N	\N
8	1	breakfast	2025-11-20	2025-11-19 20:40:13.511318	f	\N	\N	\N
9	1	lunch	2025-11-20	2025-11-19 22:47:25.727935	f	\N	\N	\N
10	1	breakfast	2025-11-20	2025-11-20 06:10:01.273567	f	\N	\N	\N
11	1	breakfast	2025-11-20	2025-11-20 06:19:06.56877	f	\N	\N	\N
12	1	breakfast	2025-11-20	2025-11-20 06:23:49.676052	f	\N	\N	\N
13	1	dinner	2025-11-20	2025-11-20 06:31:08.301478	f	\N	\N	\N
14	1	breakfast	2025-11-21	2025-11-20 17:38:24.726029	f	\N	\N	\N
15	1	breakfast	2025-11-21	2025-11-20 17:48:32.300224	f	\N	\N	\N
16	1	snack	2025-11-21	2025-11-20 17:53:14.213624	f	\N	\N	\N
17	1	breakfast	2025-11-21	2025-11-20 17:58:45.604753	f	\N	\N	\N
18	1	lunch	2025-11-23	2025-11-22 21:15:52.896061	f	\N	\N	\N
24	1	snack	2025-11-23	2025-11-23 01:26:13.380954	f	\N	\N	\N
25	1	breakfast	2025-11-24	2025-11-23 17:45:03.153128	f	\N	\N	\N
26	1	breakfast	2025-11-24	2025-11-23 18:14:23.196177	f	\N	\N	\N
27	1	breakfast	2025-11-24	2025-11-23 18:14:35.826821	f	\N	\N	\N
28	3	lunch	2025-12-04	2025-12-03 21:58:34.396778	f	\N	\N	\N
\.


--
-- TOC entry 6568 (class 0 OID 21890)
-- Dependencies: 287
-- Data for Name: meal_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meal_entries (id, user_id, entry_date, meal_type, food_id, weight_g, kcal, carbs, protein, fat, created_at) FROM stdin;
1	1	2025-11-21	dinner	69	300.00	1500.00	120.00	90.00	60.00	2025-11-20 17:58:12.16041-08
2	1	2025-11-21	breakfast	6	100.00	19.00	3.10	2.60	0.20	2025-11-20 17:59:45.088649-08
3	1	2025-11-21	breakfast	7	80.00	20.00	4.64	1.04	0.08	2025-11-20 17:59:45.099982-08
4	1	2025-11-21	breakfast	10	70.00	22.40	5.11	1.26	0.14	2025-11-20 17:59:45.102092-08
5	1	2025-11-21	breakfast	22	50.00	17.50	1.75	2.50	0.00	2025-11-20 17:59:45.103949-08
6	1	2025-11-23	lunch	69	300.00	1500.00	120.00	90.00	60.00	2025-11-22 22:20:56.760024-08
7	1	2025-11-23	snack	69	300.00	1500.00	120.00	90.00	60.00	2025-11-23 00:45:36.192525-08
8	1	2025-11-23	snack	69	300.00	1500.00	120.00	90.00	60.00	2025-11-23 01:04:38.379562-08
9	1	2025-11-23	snack	8	100.00	23.00	3.70	2.10	0.50	2025-11-23 01:26:02.805836-08
10	1	2025-11-23	snack	22	200.00	70.00	7.00	10.00	0.00	2025-11-23 01:26:02.838469-08
11	1	2025-11-24	breakfast	69	300.00	1500.00	120.00	90.00	60.00	2025-11-23 17:43:52.211841-08
12	1	2025-11-24	breakfast	69	300.00	1500.00	120.00	90.00	60.00	2025-11-23 18:13:53.445821-08
13	1	2025-11-24	breakfast	87	100.00	1000.00	1000.00	1000.00	1000.00	2025-11-23 19:37:18.223167-08
14	3	2025-11-27	dinner	87	100.00	1000.00	1000.00	1000.00	1000.00	2025-11-27 05:51:50.476636-08
15	3	2025-11-29	snack	87	100.00	1000.00	1000.00	1000.00	1000.00	2025-11-29 01:34:58.874873-08
16	3	2025-12-04	lunch	3003	120.00	0.00	0.00	24.36	0.00	2025-12-03 21:58:46.112837-08
17	3	2025-12-04	lunch	3012	200.00	0.00	37.00	24.60	17.00	2025-12-03 21:58:46.125383-08
18	3	2025-12-04	lunch	3003	120.00	0.00	0.00	24.36	0.00	2025-12-03 22:30:39.891367-08
19	3	2025-12-04	lunch	3012	200.00	0.00	37.00	24.60	17.00	2025-12-03 22:30:39.919864-08
20	3	2025-12-04	snack	3041	1000.00	20000.00	2500.00	500.00	700.00	2025-12-03 23:22:26.840869-08
21	1	2025-12-05	snack	3041	1000.00	20000.00	2500.00	500.00	700.00	2025-12-05 00:06:26.313578-08
\.


--
-- TOC entry 6523 (class 0 OID 21298)
-- Dependencies: 242
-- Data for Name: mealitem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mealitem (meal_item_id, meal_id, food_id, weight_g, calories, protein, fat, carbs, quick_add_count, last_eaten_at, dish_id) FROM stdin;
46	28	19	100.00	0.00	0.00	0.00	0.00	0	\N	\N
\.


--
-- TOC entry 6525 (class 0 OID 21318)
-- Dependencies: 244
-- Data for Name: mealnote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mealnote (note_id, meal_id, note, created_at) FROM stdin;
\.


--
-- TOC entry 6612 (class 0 OID 22467)
-- Dependencies: 335
-- Data for Name: mealtemplate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mealtemplate (template_id, user_id, template_name, description, meal_type, is_favorite, usage_count, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 6614 (class 0 OID 22488)
-- Dependencies: 337
-- Data for Name: mealtemplateitem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mealtemplateitem (template_item_id, template_id, food_id, weight_g, item_order) FROM stdin;
\.


--
-- TOC entry 6598 (class 0 OID 22289)
-- Dependencies: 321
-- Data for Name: medicationlog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medicationlog (log_id, user_condition_id, user_id, medication_date, medication_time, taken_at, status, created_at, drug_id, user_medication_id) FROM stdin;
1	2	1	2025-11-23	12:00:00	2025-11-22 21:15:30.821333	taken	2025-11-22 21:15:30.821333	\N	\N
\.


--
-- TOC entry 6596 (class 0 OID 22268)
-- Dependencies: 319
-- Data for Name: medicationschedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medicationschedule (medication_id, user_condition_id, user_id, medication_times, notes, created_at, medication_details, drug_id) FROM stdin;
1	2	1	{07:00,12:00,19:00}	\N	2025-11-22 17:22:00.803486	{"07:00": {"notes": "", "period": "morning"}, "12:00": {"notes": "", "period": "afternoon"}, "19:00": {"notes": "", "period": "evening"}}	\N
2	3	3	{07:00}	\N	2025-11-24 06:27:45.058226	{"07:00": {"notes": "", "period": "morning"}}	\N
\.


--
-- TOC entry 6670 (class 0 OID 24530)
-- Dependencies: 400
-- Data for Name: messagereaction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messagereaction (reaction_id, message_type, message_id, user_id, reaction_type, created_at) FROM stdin;
\.


--
-- TOC entry 6538 (class 0 OID 21541)
-- Dependencies: 257
-- Data for Name: mineral; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mineral (mineral_id, code, name, description, unit, recommended_daily, created_at, created_by_admin) FROM stdin;
1	MIN_CA	Calcium (Ca)	Calcium for bones and teeth	mg	1000.000	2025-11-19 06:57:52.829613	\N
2	MIN_P	Phosphorus (P)	Phosphorus for bone and energy metabolism	mg	700.000	2025-11-19 06:57:52.829613	\N
3	MIN_MG	Magnesium (Mg)	Magnesium for muscle and nerve function	mg	310.000	2025-11-19 06:57:52.829613	\N
4	MIN_K	Potassium (K)	Potassium electrolyte	mg	4700.000	2025-11-19 06:57:52.829613	\N
5	MIN_NA	Sodium (Na)	Sodium electrolyte	mg	1500.000	2025-11-19 06:57:52.829613	\N
6	MIN_FE	Iron (Fe)	Iron for hemoglobin	mg	18.000	2025-11-19 06:57:52.829613	\N
7	MIN_ZN	Zinc (Zn)	Zinc for immune function	mg	11.000	2025-11-19 06:57:52.829613	\N
8	MIN_CU	Copper (Cu)	Copper cofactor	mg	0.900	2025-11-19 06:57:52.829613	\N
9	MIN_MN	Manganese (Mn)	Manganese cofactor	mg	2.300	2025-11-19 06:57:52.829613	\N
10	MIN_I	Iodine (I)	Iodine for thyroid	µg	150.000	2025-11-19 06:57:52.829613	\N
11	MIN_SE	Selenium (Se)	Selenium antioxidant	µg	55.000	2025-11-19 06:57:52.829613	\N
12	MIN_CR	Chromium (Cr)	Chromium for metabolism	µg	35.000	2025-11-19 06:57:52.829613	\N
13	MIN_MO	Molybdenum (Mo)	Molybdenum enzyme cofactor	µg	45.000	2025-11-19 06:57:52.829613	\N
14	MIN_F	Fluoride (F)	Fluoride for dental health	mg	3.000	2025-11-19 06:57:52.829613	\N
\.


--
-- TOC entry 6646 (class 0 OID 23152)
-- Dependencies: 375
-- Data for Name: mineralnutrient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mineralnutrient (mineral_nutrient_id, mineral_id, nutrient_id, amount, factor, notes, created_at) FROM stdin;
31	1	24	0.000	1.000000	Direct mapping: CA -> MIN_CA	2025-11-19 17:33:13.520883
32	2	25	0.000	1.000000	Direct mapping: P -> MIN_P	2025-11-19 17:33:13.52465
33	3	26	0.000	1.000000	Direct mapping: MG -> MIN_MG	2025-11-19 17:33:13.525838
34	4	27	0.000	1.000000	Direct mapping: K -> MIN_K	2025-11-19 17:33:13.527468
35	5	28	0.000	1.000000	Direct mapping: NA -> MIN_NA	2025-11-19 17:33:13.528719
36	6	29	0.000	1.000000	Direct mapping: FE -> MIN_FE	2025-11-19 17:33:13.529723
37	7	30	0.000	1.000000	Direct mapping: ZN -> MIN_ZN	2025-11-19 17:33:13.531096
38	8	31	0.000	1.000000	Direct mapping: CU -> MIN_CU	2025-11-19 17:33:13.532452
39	9	32	0.000	1.000000	Direct mapping: MN -> MIN_MN	2025-11-19 17:33:13.533671
40	11	34	0.000	1.000000	Direct mapping: SE -> MIN_SE	2025-11-19 17:33:13.534674
41	10	33	0.000	1.000000	Direct mapping: I -> MIN_I	2025-11-19 17:33:13.535539
42	12	35	0.000	1.000000	Direct mapping: CR -> MIN_CR	2025-11-19 17:33:13.536369
43	13	36	0.000	1.000000	Direct mapping: MO -> MIN_MO	2025-11-19 17:33:13.537167
44	14	37	0.000	1.000000	Direct mapping: F -> MIN_F	2025-11-19 17:33:13.537977
\.


--
-- TOC entry 6540 (class 0 OID 21562)
-- Dependencies: 259
-- Data for Name: mineralrda; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mineralrda (mineral_rda_id, mineral_id, sex, age_min, age_max, rda_value, unit, notes) FROM stdin;
1	1	\N	0	0	200.000	mg	AI for infants 0-6 months
2	1	\N	1	1	260.000	mg	AI for infants 7-12 months
3	1	\N	1	3	700.000	mg	RDA for children 1-3 years
4	1	\N	4	8	1000.000	mg	RDA for children 4-8 years
5	1	\N	9	18	1300.000	mg	RDA for adolescents (peak bone growth)
6	1	\N	19	50	1000.000	mg	RDA for adults 19-50
7	1	male	51	70	1000.000	mg	RDA for males 51-70
8	1	female	51	120	1200.000	mg	RDA for females 51+ (postmenopausal)
9	1	male	71	120	1200.000	mg	RDA for males 71+
10	6	\N	0	0	0.270	mg	AI for infants 0-6 months
11	6	\N	1	1	11.000	mg	RDA for infants 7-12 months
12	6	\N	1	3	7.000	mg	RDA for children 1-3 years
13	6	\N	4	8	10.000	mg	RDA for children 4-8 years
14	6	\N	9	13	8.000	mg	RDA for children 9-13 years
15	6	male	14	18	11.000	mg	RDA for males 14-18 years
16	6	male	19	120	8.000	mg	RDA for adult males
17	6	female	14	18	15.000	mg	RDA for females 14-18 years (menstruating)
18	6	female	19	50	18.000	mg	RDA for females 19-50 (menstruating)
19	6	female	51	120	8.000	mg	RDA for postmenopausal females
20	3	male	19	30	400.000	mg	RDA for males 19-30
21	3	male	31	120	420.000	mg	RDA for males 31+
22	3	female	19	30	310.000	mg	RDA for females 19-30
23	3	female	31	120	320.000	mg	RDA for females 31+
24	7	male	19	120	11.000	mg	RDA for adult males
25	7	female	19	120	8.000	mg	RDA for adult females
26	4	male	19	120	3400.000	mg	AI for adult males
27	4	female	19	120	2600.000	mg	AI for adult females
28	5	\N	19	50	1500.000	mg	AI for adults 19-50
29	5	\N	51	70	1300.000	mg	AI for adults 51-70
30	5	\N	71	120	1200.000	mg	AI for adults 71+
31	11	\N	19	120	55.000	µg	RDA for adults
32	10	\N	19	120	150.000	µg	RDA for adults
33	2	\N	19	70	700.000	mg	RDA for adults
34	8	\N	19	120	900.000	µg	RDA for adults
35	9	male	19	120	2.300	mg	AI for adult males
36	9	female	19	120	1.800	mg	AI for adult females
73	1	any	19	50	1000.000	mg	\N
74	2	any	19	50	700.000	mg	\N
75	3	any	19	50	310.000	mg	\N
76	4	any	19	50	4700.000	mg	\N
77	5	any	19	50	1500.000	mg	\N
78	6	any	19	50	18.000	mg	\N
79	7	any	19	50	11.000	mg	\N
80	8	any	19	50	0.900	mg	\N
81	9	any	19	50	2.300	mg	\N
82	10	any	19	50	150.000	µg	\N
83	11	any	19	50	55.000	µg	\N
84	12	any	19	50	35.000	µg	\N
85	13	any	19	50	45.000	µg	\N
86	14	any	19	50	3.000	mg	\N
\.


--
-- TOC entry 6514 (class 0 OID 21220)
-- Dependencies: 233
-- Data for Name: nutrient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nutrient (nutrient_id, name, nutrient_code, unit, created_at, created_by_admin, group_name, image_url, benefits, name_vi) FROM stdin;
1	Energy (Calories)	ENERC_KCAL	kcal	2025-11-19 06:57:43.015764	\N	\N	\N	\N	\N
2	Protein	PROCNT	g	2025-11-19 06:57:43.015764	\N	\N	\N	\N	\N
4	Carbohydrate, by difference	CHOCDF	g	2025-11-19 06:57:43.015764	\N	\N	\N	\N	\N
72	ALA (Alpha-Linolenic Acid)	ALA	g	2025-11-19 07:14:21.419945	\N	\N	\N	\N	\N
75	EPA + DHA Combined	EPA_DHA	g	2025-11-19 07:14:21.419945	\N	\N	\N	\N	\N
76	LA (Linoleic Acid)	LA	g	2025-11-19 07:14:21.419945	\N	\N	\N	\N	\N
11	Vitamin A	VITA	µg	2025-11-19 06:57:43.015764	\N	Vitamins	\N	\N	\N
12	Vitamin D	VITD	IU	2025-11-19 06:57:43.015764	\N	Vitamins	\N	\N	\N
13	Vitamin E	VITE	mg	2025-11-19 06:57:43.015764	\N	Vitamins	\N	\N	\N
14	Vitamin K	VITK	µg	2025-11-19 06:57:43.015764	\N	Vitamins	\N	\N	\N
15	Vitamin C	VITC	mg	2025-11-19 06:57:43.015764	\N	Vitamins	\N	\N	\N
16	Vitamin B1 (Thiamine)	VITB1	mg	2025-11-19 06:57:43.015764	\N	Vitamins	\N	\N	\N
17	Vitamin B2 (Riboflavin)	VITB2	mg	2025-11-19 06:57:43.015764	\N	Vitamins	\N	\N	\N
18	Vitamin B3 (Niacin)	VITB3	mg	2025-11-19 06:57:43.015764	\N	Vitamins	\N	\N	\N
19	Vitamin B5 (Pantothenic acid)	VITB5	mg	2025-11-19 06:57:43.015764	\N	Vitamins	\N	\N	\N
20	Vitamin B6 (Pyridoxine)	VITB6	mg	2025-11-19 06:57:43.015764	\N	Vitamins	\N	\N	\N
21	Vitamin B7 (Biotin)	VITB7	µg	2025-11-19 06:57:43.015764	\N	Vitamins	\N	\N	\N
22	Vitamin B9 (Folate)	VITB9	µg	2025-11-19 06:57:43.015764	\N	Vitamins	\N	\N	\N
23	Vitamin B12 (Cobalamin)	VITB12	µg	2025-11-19 06:57:43.015764	\N	Vitamins	\N	\N	\N
24	Calcium (Ca)	CA	mg	2025-11-19 06:57:43.015764	\N	Minerals	\N	\N	\N
25	Phosphorus (P)	P	mg	2025-11-19 06:57:43.015764	\N	Minerals	\N	\N	\N
26	Magnesium (Mg)	MG	mg	2025-11-19 06:57:43.015764	\N	Minerals	\N	\N	\N
27	Potassium (K)	K	mg	2025-11-19 06:57:43.015764	\N	Minerals	\N	\N	\N
28	Sodium (Na)	NA	mg	2025-11-19 06:57:43.015764	\N	Minerals	\N	\N	\N
29	Iron (Fe)	FE	mg	2025-11-19 06:57:43.015764	\N	Minerals	\N	\N	\N
30	Zinc (Zn)	ZN	mg	2025-11-19 06:57:43.015764	\N	Minerals	\N	\N	\N
31	Copper (Cu)	CU	mg	2025-11-19 06:57:43.015764	\N	Minerals	\N	\N	\N
32	Manganese (Mn)	MN	mg	2025-11-19 06:57:43.015764	\N	Minerals	\N	\N	\N
33	Iodine (I)	I	µg	2025-11-19 06:57:43.015764	\N	Minerals	\N	\N	\N
34	Selenium (Se)	SE	µg	2025-11-19 06:57:43.015764	\N	Minerals	\N	\N	\N
35	Chromium (Cr)	CR	µg	2025-11-19 06:57:43.015764	\N	Minerals	\N	\N	\N
36	Molybdenum (Mo)	MO	µg	2025-11-19 06:57:43.015764	\N	Minerals	\N	\N	\N
37	Fluoride (F)	F	mg	2025-11-19 06:57:43.015764	\N	Minerals	\N	\N	\N
5	Dietary Fiber (total)	FIBTG	g	2025-11-19 06:57:43.015764	\N	Dietary Fiber	\N	\N	\N
6	Soluble Fiber	FIB_SOL	g	2025-11-19 06:57:43.015764	\N	Dietary Fiber	\N	\N	\N
7	Insoluble Fiber	FIB_INSOL	g	2025-11-19 06:57:43.015764	\N	Dietary Fiber	\N	\N	\N
8	Resistant Starch	FIB_RS	g	2025-11-19 06:57:43.015764	\N	Dietary Fiber	\N	\N	\N
9	Beta-Glucan	FIB_BGLU	g	2025-11-19 06:57:43.015764	\N	Dietary Fiber	\N	\N	\N
3	Total Fat	FAT	g	2025-11-19 06:57:43.015764	\N	Fat / Fatty acids	\N	\N	\N
10	Cholesterol	CHOLESTEROL	mg	2025-11-19 06:57:43.015764	\N	Fat / Fatty acids	\N	\N	\N
38	Monounsaturated Fat (MUFA)	FAMS	g	2025-11-19 06:57:43.015764	\N	Fat / Fatty acids	\N	\N	\N
39	Polyunsaturated Fat (PUFA)	FAPU	g	2025-11-19 06:57:43.015764	\N	Fat / Fatty acids	\N	\N	\N
40	Saturated Fat (SFA)	FASAT	g	2025-11-19 06:57:43.015764	\N	Fat / Fatty acids	\N	\N	\N
41	Trans Fat (total)	FATRN	g	2025-11-19 06:57:43.015764	\N	Fat / Fatty acids	\N	\N	\N
42	EPA (Eicosapentaenoic acid)	FAEPA	g	2025-11-19 06:57:43.015764	\N	Fat / Fatty acids	\N	\N	\N
43	DHA (Docosahexaenoic acid)	FADHA	g	2025-11-19 06:57:43.015764	\N	Fat / Fatty acids	\N	\N	\N
44	EPA + DHA (combined)	FAEPA_DHA	g	2025-11-19 06:57:43.015764	\N	Fat / Fatty acids	\N	\N	\N
45	Linoleic acid (LA) 18:2 n-6	FA18_2N6C	g	2025-11-19 06:57:43.015764	\N	Fat / Fatty acids	\N	\N	\N
46	Alpha-linolenic acid (ALA) 18:3 n-3	FA18_3N3	g	2025-11-19 06:57:43.015764	\N	Fat / Fatty acids	\N	\N	\N
47	Histidine	AMINO_HIS	g	2025-11-19 06:57:43.015764	\N	Amino acids	\N	\N	\N
48	Isoleucine	AMINO_ILE	g	2025-11-19 06:57:43.015764	\N	Amino acids	\N	\N	\N
49	Leucine	AMINO_LEU	g	2025-11-19 06:57:43.015764	\N	Amino acids	\N	\N	\N
50	Lysine	AMINO_LYS	g	2025-11-19 06:57:43.015764	\N	Amino acids	\N	\N	\N
51	Methionine	AMINO_MET	g	2025-11-19 06:57:43.015764	\N	Amino acids	\N	\N	\N
52	Phenylalanine	AMINO_PHE	g	2025-11-19 06:57:43.015764	\N	Amino acids	\N	\N	\N
53	Threonine	AMINO_THR	g	2025-11-19 06:57:43.015764	\N	Amino acids	\N	\N	\N
54	Tryptophan	AMINO_TRP	g	2025-11-19 06:57:43.015764	\N	Amino acids	\N	\N	\N
55	Valine	AMINO_VAL	g	2025-11-19 06:57:43.015764	\N	Amino acids	\N	\N	\N
\.


--
-- TOC entry 6572 (class 0 OID 21945)
-- Dependencies: 291
-- Data for Name: nutrientcontraindication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nutrientcontraindication (contra_id, nutrient_id, condition_name, note, created_at) FROM stdin;
\.


--
-- TOC entry 6680 (class 0 OID 29075)
-- Dependencies: 411
-- Data for Name: nutrienteffect; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nutrienteffect (effect_id, condition_id, nutrient_id, adjustment_percent, created_at, updated_at) FROM stdin;
1	1	5	20.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
2	1	6	20.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
3	1	7	20.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
4	2	28	-40.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
5	2	27	25.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
6	3	38	-35.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
7	3	39	-35.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
8	3	40	-35.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
9	3	75	30.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
10	3	42	30.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
11	3	43	30.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
12	3	44	30.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
13	8	29	40.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
14	8	23	35.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
15	8	22	35.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
16	15	24	50.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
17	15	12	45.00	2025-12-04 20:53:05.123907-08	2025-12-04 20:53:05.123907-08
\.


--
-- TOC entry 6557 (class 0 OID 21758)
-- Dependencies: 276
-- Data for Name: nutrientmapping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nutrientmapping (mapping_id, nutrient_id, fiber_id, fatty_acid_id, factor, notes, amino_acid_id) FROM stdin;
1	5	6	\N	1.000000	USDA FIBTG -> TOTAL_FIBER	\N
2	3	\N	7	1.000000	FAT -> TOTAL_FAT	\N
3	38	\N	17	1.000000	FAMS -> MUFA	\N
4	39	\N	15	1.000000	FAPU -> PUFA	\N
5	42	\N	4	1000.000000	FAEPA (g->mg) -> EPA_DHA	\N
6	43	\N	4	1000.000000	FADHA (g->mg) -> EPA_DHA	\N
7	45	\N	15	1.000000	FA18_2N6C -> PUFA (LA)	\N
8	46	\N	15	1.000000	FA18_3N3 -> PUFA (ALA)	\N
9	6	6	\N	1.000000	name contains fiber -> TOTAL_FIBER	\N
10	7	6	\N	1.000000	name contains fiber -> TOTAL_FIBER	\N
\.


--
-- TOC entry 6588 (class 0 OID 22141)
-- Dependencies: 309
-- Data for Name: nutritionanalysis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nutritionanalysis (analysis_id, user_id, image_url, food_name, confidence_score, nutrients, is_approved, approved_at, created_at) FROM stdin;
\.


--
-- TOC entry 6617 (class 0 OID 22581)
-- Dependencies: 342
-- Data for Name: passwordchangecode; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.passwordchangecode (id, user_id, code, created_at, used_at, expires_at) FROM stdin;
\.


--
-- TOC entry 6640 (class 0 OID 23082)
-- Dependencies: 369
-- Data for Name: permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permission (permission_id, name, description, resource, action, created_at) FROM stdin;
1	users.create	Tạo người dùng mới	users	create	2025-11-19 16:33:58.306697
2	users.read	Xem danh sách người dùng	users	read	2025-11-19 16:33:58.306697
3	users.update	Cập nhật thông tin người dùng	users	update	2025-11-19 16:33:58.306697
4	users.delete	Xóa người dùng	users	delete	2025-11-19 16:33:58.306697
5	users.manage	Quản lý toàn bộ người dùng	users	manage	2025-11-19 16:33:58.306697
6	foods.create	Thêm thực phẩm mới	foods	create	2025-11-19 16:33:58.306697
7	foods.read	Xem danh sách thực phẩm	foods	read	2025-11-19 16:33:58.306697
8	foods.update	Cập nhật thông tin thực phẩm	foods	update	2025-11-19 16:33:58.306697
9	foods.delete	Xóa thực phẩm	foods	delete	2025-11-19 16:33:58.306697
10	foods.manage	Quản lý toàn bộ thực phẩm	foods	manage	2025-11-19 16:33:58.306697
11	dishes.create	Tạo món ăn mới	dishes	create	2025-11-19 16:33:58.306697
12	dishes.read	Xem danh sách món ăn	dishes	read	2025-11-19 16:33:58.306697
13	dishes.update	Cập nhật thông tin món ăn	dishes	update	2025-11-19 16:33:58.306697
14	dishes.delete	Xóa món ăn	dishes	delete	2025-11-19 16:33:58.306697
15	dishes.manage	Quản lý toàn bộ món ăn	dishes	manage	2025-11-19 16:33:58.306697
16	dishes.approve	Phê duyệt món ăn từ user	dishes	approve	2025-11-19 16:33:58.306697
17	analytics.view	Xem báo cáo thống kê	analytics	read	2025-11-19 16:33:58.306697
18	analytics.export	Xuất báo cáo	analytics	export	2025-11-19 16:33:58.306697
19	logs.view	Xem nhật ký hoạt động	logs	read	2025-11-19 16:33:58.306697
20	logs.delete	Xóa nhật ký	logs	delete	2025-11-19 16:33:58.306697
21	roles.create	Tạo vai trò mới	roles	create	2025-11-19 16:33:58.306697
22	roles.update	Cập nhật vai trò	roles	update	2025-11-19 16:33:58.306697
23	roles.delete	Xóa vai trò	roles	delete	2025-11-19 16:33:58.306697
24	roles.assign	Gán vai trò cho admin	roles	assign	2025-11-19 16:33:58.306697
\.


--
-- TOC entry 6606 (class 0 OID 22400)
-- Dependencies: 329
-- Data for Name: portionsize; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.portionsize (portion_id, food_id, portion_name, portion_name_vi, weight_g, is_common, created_at) FROM stdin;
101	3011	1 large bowl	1 tô to	800.00	t	2025-12-01 00:23:21.543354
102	3011	1 medium bowl	1 tô vừa	700.00	t	2025-12-01 00:23:21.543354
103	3012	1 large plate	1 dĩa to	550.00	t	2025-12-01 00:23:21.543354
104	3013	1 medium plate	1 dĩa vừa	400.00	t	2025-12-01 00:23:21.543354
105	3013	1 small plate	1 dĩa nhỏ	300.00	t	2025-12-01 00:23:21.543354
106	3014	1 full sandwich	1 ổ đầy đủ	200.00	t	2025-12-01 00:23:21.543354
107	3014	Half sandwich	Nửa ổ	100.00	t	2025-12-01 00:23:21.543354
108	3015	3 rolls	3 cuốn	300.00	t	2025-12-01 00:23:21.543354
109	3015	2 rolls	2 cuốn	200.00	t	2025-12-01 00:23:21.543354
110	3016	1 large bowl soup	1 tô canh to	450.00	t	2025-12-01 00:23:21.543354
111	3016	1 medium bowl soup	1 tô canh vừa	350.00	t	2025-12-01 00:23:21.543354
112	3017	1 large plate	1 dĩa to	250.00	t	2025-12-01 00:23:21.543354
113	3018	1 piece fish	1 miếng cá	150.00	t	2025-12-01 00:23:21.543354
114	3018	1 small piece	1 miếng nhỏ	100.00	t	2025-12-01 00:23:21.543354
115	3019	2 pieces	2 miếng	200.00	t	2025-12-01 00:23:21.543354
116	3020	1 large plate	1 dĩa to	300.00	t	2025-12-01 00:23:21.543354
117	3004	2 bananas	2 quả chuối	240.00	t	2025-12-01 00:23:21.543354
118	3007	1 large fillet	1 phi lê to	200.00	t	2025-12-01 00:23:21.543354
119	3009	1 large cup	1 chén to	150.00	t	2025-12-01 00:23:21.543354
120	3010	1 large glass	1 ly to	300.00	t	2025-12-01 00:23:21.543354
\.


--
-- TOC entry 6672 (class 0 OID 24555)
-- Dependencies: 402
-- Data for Name: privateconversation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.privateconversation (conversation_id, user1_id, user2_id, created_at, updated_at) FROM stdin;
1	1	2	2025-11-24 05:13:47.156117	2025-11-25 00:43:15.048766
2	1	3	2025-11-24 06:49:29.098687	2025-11-26 16:57:18.025524
3	2	3	2025-12-02 01:36:43.697705	2025-12-02 01:36:43.697705
\.


--
-- TOC entry 6674 (class 0 OID 24582)
-- Dependencies: 404
-- Data for Name: privatemessage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.privatemessage (message_id, conversation_id, sender_id, message_text, image_url, is_read, read_at, created_at) FROM stdin;
1	1	1	123	\N	t	2025-11-25 00:36:59.726476	2025-11-25 00:36:29.885888
2	1	2	456	\N	f	\N	2025-11-25 00:43:15.048766
3	2	3	123	\N	t	2025-11-26 16:57:12.957054	2025-11-26 16:55:50.004164
4	2	1	456	\N	f	\N	2025-11-26 16:57:18.025524
\.


--
-- TOC entry 6608 (class 0 OID 22418)
-- Dependencies: 331
-- Data for Name: recipe; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.recipe (recipe_id, user_id, recipe_name, description, servings, prep_time_minutes, cook_time_minutes, instructions, image_url, is_public, created_at, updated_at) FROM stdin;
1	\N	Phở Bò Hà Nội	Công thức nấu phở bò truyền thống Hà Nội	4	30	180	Bước 1: Hầm xương bò 3-4 tiếng với hành, gừng nướng\r\nBước 2: Thêm gia vị: muối, đường, nước mắm, hạt nêm\r\nBước 3: Trụng bánh phở, cho vào tô\r\nBước 4: Thái thịt bò mỏng, xếp lên bánh phở\r\nBước 5: Chan nước dùng sôi, thêm hành, ngò rí, rau thơm\r\nBước 6: Ăn kèm chanh, ớt, tương ớt	\N	t	2025-12-01 00:23:21.519417	2025-12-01 00:23:21.519417
2	\N	Cơm Tấm Sườn Nướng	Cơm tấm sườn nướng sả ớt	2	20	30	Bước 1: Ướp sườn heo với sả, tỏi, đường, nước mắm, dầu ăn 2 tiếng\r\nBước 2: Nướng sườn trên than hồng hoặc lò nướng\r\nBước 3: Nấu cơm tấm\r\nBước 4: Chiên trứng ốp la\r\nBước 5: Pha nước mắm chua ngọt\r\nBước 6: Bày cơm, sườn, trứng, dưa leo, cà chua	\N	t	2025-12-01 00:23:21.519417	2025-12-01 00:23:21.519417
3	\N	Canh Chua Cá	Canh chua cá lóc miền Nam	4	15	25	Bước 1: Rửa sạch cá, cắt khúc vừa ăn\r\nBước 2: Nấu nước dùng với me, thơm, cà chua\r\nBước 3: Cho cá vào, nấu chín\r\nBước 4: Thêm đậu bắp, rau muống\r\nBước 5: Nêm nếm vừa ăn với muối, đường, nước mắm\r\nBước 6: Rắc hành, ngò, ớt	\N	t	2025-12-01 00:23:21.519417	2025-12-01 00:23:21.519417
4	\N	Gỏi Cuốn Tôm Thịt	Gỏi cuốn tươi mát	10	30	15	Bước 1: Luộc tôm, thịt heo\r\nBước 2: Thái rau sống: xà lách, húng, rau thơm\r\nBước 3: Trụng bánh tráng qua nước ấm\r\nBước 4: Cuốn tôm, thịt, bún, rau vào bánh tráng\r\nBước 5: Pha nước chấm: nước mắm, đường, tỏi, ớt\r\nBước 6: Ăn ngay khi mới cuốn	\N	t	2025-12-01 00:23:21.519417	2025-12-01 00:23:21.519417
5	\N	Cháo Gà Dinh Dưỡng	Cháo gà cho người ốm	2	10	40	Bước 1: Vo gạo, ngâm 30 phút\r\nBước 2: Luộc gà với gừng\r\nBước 3: Xé gà thành sợi\r\nBước 4: Nấu cháo với nước luộc gà\r\nBước 5: Nêm nếm vừa ăn\r\nBước 6: Cho gà xé vào, rắc hành, gừng	\N	t	2025-12-01 00:23:21.519417	2025-12-01 00:23:21.519417
21	\N	Bún Chả Hà Nội	Bún chả truyền thống Hà Nội	4	30	25	Bước 1: Ướp thịt heo với nước mắm, đường, hành băm, ớt băm trong 2 tiếng\r\nBước 2: Vo viên chả, nướng chả và thịt trên bếp than hồng\r\nBước 3: Pha nước mắm chua ngọt với chanh, đường, tỏi, ớt\r\nBước 4: Trụng bún tươi\r\nBước 5: Trình bày bún, rau sống, chả và thịt nướng riêng\r\nBước 6: Chan nước mắm pha vào ăn kèm	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
22	\N	Cà Ri Gà	Cà ri gà kiểu Việt Nam	3	25	45	Bước 1: Sơ chế gà, thái miếng vừa ăn\r\nBước 2: Phi thơm hành tím, tỏi với bột cà ri\r\nBước 3: Cho gà vào xào săn, thêm khoai tây, cà rốt\r\nBước 4: Đổ nước dừa hoặc nước lọc, nêm nếm\r\nBước 5: Nấu nhỏ lửa 30-40 phút đến khi gà và rau mềm\r\nBước 6: Ăn kèm cơm hoặc bánh mì	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
23	\N	Gỏi Gà	Gỏi gà bắp cải tím	4	35	20	Bước 1: Luộc gà chín, xé sợi\r\nBước 2: Thái mỏng bắp cải tím, cà rốt, ngâm nước đá\r\nBước 3: Rang đậu phộng, giã nhỏ\r\nBước 4: Trộn rau với rau răm, hành tây, gà xé\r\nBước 5: Pha nước mắm chanh đường\r\nBước 6: Trộn đều, rắc đậu phộng và hành phi lên trên	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
24	\N	Canh Chua Cá	Canh chua cá miền Nam	4	20	25	Bước 1: Sơ chế cá, ướp muối tiêu gừng\r\nBước 2: Nấu nước dùng với me, thơm, cà chua\r\nBước 3: Nêm nếm chua ngọt vừa ăn\r\nBước 4: Cho cá vào nấu chín\r\nBước 5: Thêm rau muống, đậu bắp, hành\r\nBước 6: Tắt bếp, rắc ngò rí	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
25	\N	Bánh Xèo	Bánh xèo giòn miền Nam	6	40	30	Bước 1: Pha bột bánh xèo với bột gạo, bột nghệ, nước cốt dừa\r\nBước 2: Ướp tôm, thịt với gia vị\r\nBước 3: Chiên bánh trên chảo nóng với dầu nhiều\r\nBước 4: Cho nhân tôm, thịt, giá đỗ vào rồi gấp đôi\r\nBước 5: Chiên đến khi vàng giòn 2 mặt\r\nBước 6: Ăn kèm rau sống, nước mắm pha	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
26	\N	Thịt Kho Tàu	Thịt kho trứng cút	4	20	60	Bước 1: Luộc sơ thịt ba chỉ, thái miếng vuông\r\nBước 2: Luộc chín trứng cút, bóc vỏ\r\nBước 3: Làm nước màu caramel\r\nBước 4: Cho thịt vào kho với nước dừa, nước mắm, đường\r\nBước 5: Thêm trứng vào kho cùng\r\nBước 6: Nấu lửa nhỏ 45-60 phút đến khi thịt mềm, nước sệt	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
27	\N	Chả Giò	Chả giò miền Nam giòn rụm	20	45	25	Bước 1: Làm nhân với thịt heo xay, tôm, mộc nhĩ, miến, rau củ\r\nBước 2: Nêm nếm nhân vừa ăn\r\nBước 3: Cuốn nhân vào bánh tráng, cuốn chặt\r\nBước 4: Chiên ngập dầu lửa vừa đến vàng đều\r\nBước 5: Vớt ra để ráo dầu\r\nBước 6: Ăn kèm rau sống, bún, nước mắm pha	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
28	\N	Bò Lúc Lắc	Bò lúc lắc sốt tiêu đen	2	20	10	Bước 1: Thịt bò thái hạt lựu, ướp tiêu, tỏi, nước mắm, dầu\r\nBước 2: Chuẩn bị salad rau trộn\r\nBước 3: Xào bò nhanh tay trên lửa lớn\r\nBước 4: Nêm thêm tiêu đen, bơ\r\nBước 5: Lắc đều để thịt chín vừa, mềm\r\nBước 6: Ăn kèm salad, cơm hoặc bánh mì	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
29	\N	Gà Kho Gừng	Gà kho gừng ấm bụng	4	25	50	Bước 1: Gà thái miếng, ướp với gừng, tỏi, nước mắm\r\nBước 2: Phi thơm gừng tỏi\r\nBước 3: Cho gà vào kho với nước mắm, đường, ớt\r\nBước 4: Nấu lửa vừa 40-50 phút\r\nBước 5: Nêm nếm lại, thu nhỏ lửa cho nước sệt\r\nBước 6: Rắc hành lá, tiêu	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
30	\N	Cháo Gà	Cháo gà dinh dưỡng dễ tiêu	4	15	40	Bước 1: Vo gạo, ngâm 30 phút\r\nBước 2: Luộc gà với gừng, đổ bỏ nước đầu\r\nBước 3: Luộc lại gà đến chín, vớt ra xé sợi\r\nBước 4: Nấu cháo với nước luộc gà\r\nBước 5: Khi cháo nhừ, nêm nếm vừa ăn\r\nBước 6: Múc cháo ra tô, cho gà xé, rắc hành, ngò, gừng	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
31	\N	Bún Bò Huế	Bún bò Huế cay nồng	4	30	120	Bước 1: Ninh xương bò 2-3 tiếng\r\nBước 2: Luộc chả, giò heo\r\nBước 3: Rang sả với mắm tôm, ớt, thêm vào nước dùng\r\nBước 4: Nêm nếm cay mặn vừa ăn\r\nBước 5: Trụng bún bò\r\nBước 6: Cho bún vào tô, xếp chả giò, chan nước dùng, thêm rau	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
32	\N	Bánh Cuốn	Bánh cuốn Thanh Trì	6	45	30	Bước 1: Pha bột bánh cuốn mỏng\r\nBước 2: Làm nhân thịt xay, mộc nhĩ xào\r\nBước 3: Hấp bánh mỏng trên vải\r\nBước 4: Phết nhân lên bánh, cuộn lại\r\nBước 5: Xếp bánh ra đĩa\r\nBước 6: Ăn kèm chả, nước mắm, hành phi	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
33	\N	Mì Quảng	Mì Quảng Đà Nẵng	4	35	45	Bước 1: Nấu nước dùng từ xương, thêm nghệ\r\nBước 2: Ướp tôm, thịt nướng\r\nBước 3: Luộc mì vàng\r\nBước 4: Rang đậu phộng giã nhỏ\r\nBước 5: Trình bày mì, tôm thịt, rau sống, trứng\r\nBước 6: Chan nước dùng vừa đủ, rắc đậu phộng, hành	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
34	\N	Bò Kho	Bò kho kiểu miền Nam	4	25	90	Bước 1: Bò thái to, ướp với gia vị, sả\r\nBước 2: Làm nước màu\r\nBước 3: Kho bò với nước dừa, cà rốt\r\nBước 4: Nấu lửa nhỏ 60-90 phút\r\nBước 5: Nêm nếm, thêm sả ớt\r\nBước 6: Ăn kèm bánh mì hoặc bún	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
35	\N	Canh Khổ Qua	Canh khổ qua nhồi thịt	4	30	25	Bước 1: Khổ qua bỏ ruột, ngâm nước muối\r\nBước 2: Làm nhân thịt xay với miến\r\nBước 3: Nhồi nhân vào khổ qua\r\nBước 4: Nấu nước dùng từ xương\r\nBước 5: Cho khổ qua vào nấu chín\r\nBước 6: Nêm nếm, rắc hành	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
36	\N	Gà Xào Sả Ớt	Gà xào sả ớt thơm cay	3	20	15	Bước 1: Gà thái miếng, ướp sả ớt tỏi\r\nBước 2: Phi thơm sả ớt\r\nBước 3: Cho gà vào xào săn\r\nBước 4: Nêm nước mắm, đường\r\nBước 5: Xào đến khi gà chín vàng\r\nBước 6: Rắc hành lá, tắt bếp	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
37	\N	Rau Muống Xào Tỏi	Rau muống xào tỏi giòn ngon	2	5	5	Bước 1: Nhặt rau muống sạch, tách ngọn\r\nBước 2: Đập dập tỏi\r\nBước 3: Phi thơm tỏi\r\nBước 4: Cho rau vào xào nhanh tay lửa to\r\nBước 5: Nêm muối hoặc nước mắm\r\nBước 6: Đảo đều, tắt bếp khi rau còn xanh giòn	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
38	\N	Đậu Hũ Sốt Cà Chua	Đậu hũ chiên sốt cà	3	15	20	Bước 1: Đậu hũ cắt miếng, chiên vàng\r\nBước 2: Phi hành tỏi\r\nBước 3: Xào cà chua với gia vị\r\nBước 4: Nêm chua ngọt vừa ăn\r\nBước 5: Cho đậu hũ vào đảo đều\r\nBước 6: Rắc hành lá, tắt bếp	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
39	\N	Canh Sườn Hầm	Canh sườn củ cải ngọt	4	20	90	Bước 1: Sườn chặt khúc, chần sơ\r\nBước 2: Ninh sườn với nước 60 phút\r\nBước 3: Thêm củ cải, cà rốt thái to\r\nBước 4: Nấu thêm 30 phút\r\nBước 5: Nêm muối vừa ăn\r\nBước 6: Rắc hành, ngò	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
40	\N	Xôi Xéo	Xôi xéo đậu xanh	4	15	40	Bước 1: Ngâm gạo nếp 4 tiếng\r\nBước 2: Vo đậu xanh, hấp chín\r\nBước 3: Rang đậu xanh với muối\r\nBước 4: Hấp xôi với lá dứa\r\nBước 5: Trộn xôi với đậu xanh\r\nBước 6: Ăn kèm mỡ hành, thịt nạc dăm	\N	t	2025-12-01 00:23:21.55821	2025-12-01 00:23:21.55821
\.


--
-- TOC entry 6610 (class 0 OID 22438)
-- Dependencies: 333
-- Data for Name: recipeingredient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.recipeingredient (recipe_ingredient_id, recipe_id, food_id, weight_g, ingredient_order, notes) FROM stdin;
17	21	3012	400.00	1	Bún tươi
18	21	3019	300.00	2	Thịt heo nướng, chả
19	21	3017	200.00	3	Rau sống
20	22	3007	400.00	1	Gà
21	22	3004	200.00	2	Khoai tây
22	22	3017	100.00	3	Cà rốt, hành
23	23	3007	300.00	1	Gà luộc xé
24	23	3017	400.00	2	Bắp cải, cà rốt, rau thơm
25	24	3018	400.00	1	Cá
26	24	3016	200.00	2	Cà chua, thơm
27	24	3017	150.00	3	Rau muống, đậu bắp
28	25	3014	300.00	1	Bột bánh xèo
29	25	3019	200.00	2	Thịt heo, tôm
30	25	90	150.00	3	Giá đỗ
\.


--
-- TOC entry 6509 (class 0 OID 21175)
-- Dependencies: 228
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role (role_id, role_name) FROM stdin;
1	super_admin
2	user_manager
3	content_manager
6	analytics_manager
7	support manager
\.


--
-- TOC entry 6642 (class 0 OID 23098)
-- Dependencies: 371
-- Data for Name: rolepermission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolepermission (role_permission_id, role_name, permission_id, granted_at) FROM stdin;
1	super_admin	1	2025-11-19 16:35:17.458479
2	super_admin	2	2025-11-19 16:35:17.458479
3	super_admin	3	2025-11-19 16:35:17.458479
4	super_admin	4	2025-11-19 16:35:17.458479
5	super_admin	5	2025-11-19 16:35:17.458479
6	super_admin	6	2025-11-19 16:35:17.458479
7	super_admin	7	2025-11-19 16:35:17.458479
8	super_admin	8	2025-11-19 16:35:17.458479
9	super_admin	9	2025-11-19 16:35:17.458479
10	super_admin	10	2025-11-19 16:35:17.458479
11	super_admin	11	2025-11-19 16:35:17.458479
12	super_admin	12	2025-11-19 16:35:17.458479
13	super_admin	13	2025-11-19 16:35:17.458479
14	super_admin	14	2025-11-19 16:35:17.458479
15	super_admin	15	2025-11-19 16:35:17.458479
16	super_admin	16	2025-11-19 16:35:17.458479
17	super_admin	17	2025-11-19 16:35:17.458479
18	super_admin	18	2025-11-19 16:35:17.458479
19	super_admin	19	2025-11-19 16:35:17.458479
20	super_admin	20	2025-11-19 16:35:17.458479
21	super_admin	21	2025-11-19 16:35:17.458479
22	super_admin	22	2025-11-19 16:35:17.458479
23	super_admin	23	2025-11-19 16:35:17.458479
24	super_admin	24	2025-11-19 16:35:17.458479
25	content_manager	6	2025-11-19 16:35:20.871476
26	content_manager	7	2025-11-19 16:35:20.871476
27	content_manager	8	2025-11-19 16:35:20.871476
28	content_manager	9	2025-11-19 16:35:20.871476
29	content_manager	10	2025-11-19 16:35:20.871476
30	content_manager	11	2025-11-19 16:35:20.871476
31	content_manager	12	2025-11-19 16:35:20.871476
32	content_manager	13	2025-11-19 16:35:20.871476
33	content_manager	14	2025-11-19 16:35:20.871476
34	content_manager	15	2025-11-19 16:35:20.871476
35	content_manager	16	2025-11-19 16:35:20.871476
39	user_manager	1	2025-11-19 16:35:40.061795
40	user_manager	2	2025-11-19 16:35:40.061795
41	user_manager	3	2025-11-19 16:35:40.061795
42	user_manager	4	2025-11-19 16:35:40.061795
43	user_manager	5	2025-11-19 16:35:40.061795
68	analytics_manager	17	2025-11-19 16:44:59.417767
69	analytics_manager	18	2025-11-19 16:44:59.417767
70	analytics_manager	19	2025-11-19 16:44:59.417767
\.


--
-- TOC entry 6529 (class 0 OID 21353)
-- Dependencies: 248
-- Data for Name: suggestion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.suggestion (suggestion_id, user_id, date, nutrient_id, deficiency_amount, suggested_food_id, note) FROM stdin;
\.


--
-- TOC entry 6618 (class 0 OID 22602)
-- Dependencies: 343
-- Data for Name: user_account_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_account_status (user_id, is_blocked, blocked_reason, blocked_at, blocked_by_admin, updated_at) FROM stdin;
\.


--
-- TOC entry 6620 (class 0 OID 22625)
-- Dependencies: 345
-- Data for Name: user_block_event; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_block_event (block_event_id, user_id, event_type, reason, admin_id, created_at) FROM stdin;
\.


--
-- TOC entry 6570 (class 0 OID 21912)
-- Dependencies: 289
-- Data for Name: user_meal_summaries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_meal_summaries (id, user_id, summary_date, meal_type, consumed_kcal, consumed_carbs, consumed_protein, consumed_fat, updated_at) FROM stdin;
1	1	2025-11-21	dinner	1500.00	120.00	90.00	60.00	2025-11-20 17:58:12.16041-08
2	1	2025-11-21	breakfast	78.90	14.60	7.40	0.42	2025-11-20 17:59:45.103949-08
6	1	2025-11-23	lunch	1500.00	120.00	90.00	60.00	2025-11-22 22:20:56.760024-08
7	1	2025-11-23	snack	3093.00	250.70	192.10	120.50	2025-11-23 01:26:02.838469-08
11	1	2025-11-24	breakfast	4000.00	1240.00	1180.00	1120.00	2025-11-23 19:37:18.223167-08
14	3	2025-11-27	dinner	1000.00	1000.00	1000.00	1000.00	2025-11-27 05:51:50.476636-08
15	3	2025-11-29	snack	1000.00	1000.00	1000.00	1000.00	2025-11-29 01:34:58.874873-08
16	3	2025-12-04	lunch	0.00	74.00	97.92	34.00	2025-12-03 22:30:39.919864-08
20	3	2025-12-04	snack	20000.00	2500.00	500.00	700.00	2025-12-03 23:22:26.840869-08
21	1	2025-12-05	snack	20000.00	2500.00	500.00	700.00	2025-12-05 00:06:26.313578-08
\.


--
-- TOC entry 6566 (class 0 OID 21866)
-- Dependencies: 285
-- Data for Name: user_meal_targets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_meal_targets (id, user_id, target_date, meal_type, target_kcal, target_carbs, target_protein, target_fat, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 6622 (class 0 OID 22650)
-- Dependencies: 347
-- Data for Name: user_unblock_request; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_unblock_request (request_id, user_id, status, message, admin_response, decided_at, decided_by_admin, created_at) FROM stdin;
\.


--
-- TOC entry 6505 (class 0 OID 21144)
-- Dependencies: 224
-- Data for Name: useractivitylog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.useractivitylog (log_id, user_id, action, log_time) FROM stdin;
1	1	bmr_tdee_recomputed	2025-11-19 07:19:57.587871
2	1	daily_targets_recomputed	2025-11-19 07:19:59.88821
3	1	meal_entry_created	2025-11-23 19:37:18.223167
4	2	body_measurement_recorded	2025-11-23 20:44:04.627771
5	2	bmr_tdee_recomputed	2025-11-23 20:44:04.64067
6	2	daily_targets_recomputed	2025-11-23 20:44:07.120791
7	3	body_measurement_recorded	2025-11-24 05:24:39.709436
8	3	bmr_tdee_recomputed	2025-11-24 05:24:39.721753
9	3	daily_targets_recomputed	2025-11-24 05:24:49.524601
10	3	health_condition_added	2025-11-24 06:27:45.049044
11	1	body_measurement_recorded	2025-11-24 22:52:03.733412
12	1	bmr_tdee_recomputed	2025-11-24 22:52:03.758064
13	1	body_measurement_recorded	2025-11-24 22:52:15.989212
14	1	bmr_tdee_recomputed	2025-11-24 22:52:15.997088
15	1	daily_targets_recomputed	2025-11-24 23:03:34.235157
16	3	drink_created	2025-11-25 19:59:13.684712
17	3	dish_created	2025-11-25 20:26:45.476684
18	3	drink_created	2025-11-25 20:35:20.136881
19	3	dish_created	2025-11-26 16:48:14.437252
20	3	drink_created	2025-11-26 16:48:48.458853
21	3	meal_entry_created	2025-11-27 05:51:50.476636
22	3	body_measurement_recorded	2025-11-29 01:32:36.375268
23	3	bmr_tdee_recomputed	2025-11-29 01:32:36.407365
24	3	daily_targets_recomputed	2025-11-29 01:32:55.383183
25	3	meal_entry_created	2025-11-29 01:34:58.874873
26	3	health_condition_added	2025-12-03 21:56:00.398518
27	3	meal_created	2025-12-03 21:58:34.396778
28	3	meal_entry_created	2025-12-03 21:58:46.112837
29	3	meal_entry_created	2025-12-03 21:58:46.125383
30	3	health_condition_added	2025-12-03 22:27:41.424763
31	3	meal_entry_created	2025-12-03 22:30:39.891367
32	3	meal_entry_created	2025-12-03 22:30:39.919864
33	3	water_logged	2025-12-03 22:30:51.58499
34	3	meal_entry_created	2025-12-03 23:22:26.840869
35	3	water_logged	2025-12-03 23:23:11.878122
36	3	water_logged	2025-12-04 00:09:17.61489
37	3	water_logged	2025-12-04 00:15:43.072139
38	3	water_logged	2025-12-04 00:15:48.925759
39	3	health_condition_added	2025-12-04 00:42:28.094101
40	3	water_logged	2025-12-04 00:43:01.817406
41	3	water_logged	2025-12-04 00:52:42.630524
42	4	health_condition_added	2025-12-04 05:58:06.759562
43	4	water_logged	2025-12-04 06:03:05.450149
44	4	water_logged	2025-12-04 06:03:11.568318
45	4	body_measurement_recorded	2025-12-04 06:34:12.518714
46	4	bmr_tdee_recomputed	2025-12-04 06:34:12.550494
47	4	daily_targets_recomputed	2025-12-04 06:34:15.833736
48	1	health_condition_added	2025-12-04 18:07:29.397904
49	1	water_logged	2025-12-04 18:08:52.312987
50	1	water_logged	2025-12-04 18:24:25.696707
51	1	water_logged	2025-12-04 18:34:29.190217
52	4	health_condition_added	2025-12-04 23:34:36.331085
53	1	meal_entry_created	2025-12-05 00:06:26.313578
54	1	health_condition_added	2025-12-05 00:42:07.330706
\.


--
-- TOC entry 6564 (class 0 OID 21843)
-- Dependencies: 283
-- Data for Name: useraminointake; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.useraminointake (intake_id, user_id, amino_acid_id, amount, unit, source, recorded_at) FROM stdin;
\.


--
-- TOC entry 6562 (class 0 OID 21822)
-- Dependencies: 281
-- Data for Name: useraminorequirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.useraminorequirement (user_id, amino_acid_id, base, multiplier, recommended, unit, updated_at) FROM stdin;
2	1	19	1.036	826.728	mg	2025-11-23 20:44:04.63164
2	2	25	1.036	1087.800	mg	2025-11-23 20:44:04.63164
2	3	14	1.036	609.168	mg	2025-11-23 20:44:04.63164
2	4	30	1.036	1305.360	mg	2025-11-23 20:44:04.63164
2	5	15	1.036	652.680	mg	2025-11-23 20:44:04.63164
2	6	26	1.036	1131.312	mg	2025-11-23 20:44:04.63164
2	7	4	1.036	174.048	mg	2025-11-23 20:44:04.63164
2	8	15	1.036	652.680	mg	2025-11-23 20:44:04.63164
2	9	42	1.036	1827.504	mg	2025-11-23 20:44:04.63164
3	1	19	1.106	1260.840	mg	2025-11-29 01:32:36.387799
3	2	25	1.106	1659.000	mg	2025-11-29 01:32:36.387799
3	3	14	1.106	929.040	mg	2025-11-29 01:32:36.387799
3	4	30	1.106	1990.800	mg	2025-11-29 01:32:36.387799
3	5	15	1.106	995.400	mg	2025-11-29 01:32:36.387799
3	6	26	1.106	1725.360	mg	2025-11-29 01:32:36.387799
3	7	4	1.106	265.440	mg	2025-11-29 01:32:36.387799
3	8	15	1.106	995.400	mg	2025-11-29 01:32:36.387799
3	9	42	1.106	2787.120	mg	2025-11-29 01:32:36.387799
1	1	19	1.056	1203.840	mg	2025-11-24 22:52:15.990562
1	2	25	1.056	1584.000	mg	2025-11-24 22:52:15.990562
1	3	14	1.056	887.040	mg	2025-11-24 22:52:15.990562
1	4	30	1.056	1900.800	mg	2025-11-24 22:52:15.990562
1	5	15	1.056	950.400	mg	2025-11-24 22:52:15.990562
1	6	26	1.056	1647.360	mg	2025-11-24 22:52:15.990562
1	7	4	1.056	253.440	mg	2025-11-24 22:52:15.990562
1	8	15	1.056	950.400	mg	2025-11-24 22:52:15.990562
1	9	42	1.056	2661.120	mg	2025-11-24 22:52:15.990562
4	1	19	1.036	1181.040	mg	2025-12-04 06:34:12.534108
4	2	25	1.036	1554.000	mg	2025-12-04 06:34:12.534108
4	3	14	1.036	870.240	mg	2025-12-04 06:34:12.534108
4	4	30	1.036	1864.800	mg	2025-12-04 06:34:12.534108
4	5	15	1.036	932.400	mg	2025-12-04 06:34:12.534108
4	6	26	1.036	1616.160	mg	2025-12-04 06:34:12.534108
4	7	4	1.036	248.640	mg	2025-12-04 06:34:12.534108
4	8	15	1.036	932.400	mg	2025-12-04 06:34:12.534108
4	9	42	1.036	2610.720	mg	2025-12-04 06:34:12.534108
\.


--
-- TOC entry 6555 (class 0 OID 21738)
-- Dependencies: 274
-- Data for Name: userfattyacidintake; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.userfattyacidintake (intake_id, user_id, date, fatty_acid_id, amount) FROM stdin;
1	1	2025-11-23	7	3.2000
2	1	2025-11-24	7	1129.6000
3	1	2025-11-24	17	1048.0000
5	1	2025-11-24	4	2012000.0000
4	1	2025-11-24	15	3036.0000
26	3	2025-11-27	7	1000.0000
27	3	2025-11-27	17	1000.0000
29	3	2025-11-27	4	2000000.0000
28	3	2025-11-27	15	3000.0000
33	3	2025-11-29	7	1000.0000
34	3	2025-11-29	17	1000.0000
36	3	2025-11-29	4	2000000.0000
35	3	2025-11-29	15	3000.0000
40	3	2025-12-04	7	734.0000
43	3	2025-12-04	17	222.0000
46	3	2025-12-04	4	32000.0000
44	3	2025-12-04	15	238.0000
49	1	2025-12-05	7	700.0000
50	1	2025-12-05	17	222.0000
53	1	2025-12-05	4	32000.0000
51	1	2025-12-05	15	238.0000
\.


--
-- TOC entry 6551 (class 0 OID 21697)
-- Dependencies: 270
-- Data for Name: userfattyacidrequirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.userfattyacidrequirement (user_id, fatty_acid_id, base, multiplier, recommended, unit, updated_at) FROM stdin;
3	16	1.050000	1.0530	3.102	g	2025-11-29 01:32:36.387799
3	17	13.125000	1.0530	38.775	g	2025-11-29 01:32:36.387799
3	18	10.500000	1.0530	31.020	g	2025-11-29 01:32:36.387799
2	1	\N	\N	\N	\N	2025-11-23 20:44:04.63164
2	2	\N	\N	\N	\N	2025-11-23 20:44:04.63164
2	3	\N	\N	\N	\N	2025-11-23 20:44:04.63164
2	4	250.000000	1.0180	255	mg	2025-11-23 20:44:04.63164
2	5	5.0000	1.0180	9.055	g	2025-11-23 20:44:04.63164
2	6	300.000000	1.0180	305	mg	2025-11-23 20:44:04.63164
2	7	30.0000	1.0180	54.327	g	2025-11-23 20:44:04.63164
2	15	7.5000	1.0180	13.582	g	2025-11-23 20:44:04.63164
2	16	1.0000	1.0180	1.811	g	2025-11-23 20:44:04.63164
2	17	12.5000	1.0180	22.636	g	2025-11-23 20:44:04.63164
2	18	10.0000	1.0180	18.109	g	2025-11-23 20:44:04.63164
4	1	\N	\N	\N	\N	2025-12-04 06:34:12.534108
4	2	\N	\N	\N	\N	2025-12-04 06:34:12.534108
4	3	\N	\N	\N	\N	2025-12-04 06:34:12.534108
4	4	250.000000	1.0180	255	mg	2025-12-04 06:34:12.534108
4	5	5.0000	1.0180	11.345	g	2025-12-04 06:34:12.534108
4	6	300.000000	1.0180	305	mg	2025-12-04 06:34:12.534108
4	7	30.0000	1.0180	68.070	g	2025-12-04 06:34:12.534108
4	15	7.5000	1.0180	17.018	g	2025-12-04 06:34:12.534108
4	16	1.0000	1.0180	2.269	g	2025-12-04 06:34:12.534108
4	17	12.5000	1.0180	28.363	g	2025-12-04 06:34:12.534108
4	18	10.0000	1.0180	22.690	g	2025-12-04 06:34:12.534108
1	1	\N	\N	\N	\N	2025-11-24 22:52:15.990562
1	2	\N	\N	\N	\N	2025-11-24 22:52:15.990562
1	3	\N	\N	\N	\N	2025-11-24 22:52:15.990562
1	4	250.000000	1.0380	363	mg	2025-11-24 22:52:15.990562
1	5	5.500000	1.0380	13.892	g	2025-11-24 22:52:15.990562
1	6	300.000000	1.0380	311	mg	2025-11-24 22:52:15.990562
1	7	33.000000	1.0380	83.351	g	2025-11-24 22:52:15.990562
1	15	8.250000	1.0380	20.838	g	2025-11-24 22:52:15.990562
1	16	1.100000	1.0380	2.778	g	2025-11-24 22:52:15.990562
1	17	13.750000	1.0380	34.730	g	2025-11-24 22:52:15.990562
1	18	11.000000	1.0380	27.784	g	2025-11-24 22:52:15.990562
3	1	\N	\N	\N	\N	2025-11-29 01:32:36.387799
3	2	\N	\N	\N	\N	2025-11-29 01:32:36.387799
3	3	\N	\N	\N	\N	2025-11-29 01:32:36.387799
3	4	250.000000	1.0530	263	mg	2025-11-29 01:32:36.387799
3	5	5.250000	1.0530	15.510	g	2025-11-29 01:32:36.387799
3	6	300.000000	1.0530	316	mg	2025-11-29 01:32:36.387799
3	7	31.500000	1.0530	93.059	g	2025-11-29 01:32:36.387799
3	15	7.875000	1.0530	23.265	g	2025-11-29 01:32:36.387799
\.


--
-- TOC entry 6553 (class 0 OID 21718)
-- Dependencies: 272
-- Data for Name: userfiberintake; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.userfiberintake (intake_id, user_id, date, fiber_id, amount) FROM stdin;
1	1	2025-11-23	6	2.7000
2	1	2025-11-24	6	3104.1000
14	3	2025-11-27	6	3000.0000
17	3	2025-11-29	6	3000.0000
20	3	2025-12-04	6	3760.0000
23	1	2025-12-05	6	3760.0000
\.


--
-- TOC entry 6550 (class 0 OID 21677)
-- Dependencies: 269
-- Data for Name: userfiberrequirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.userfiberrequirement (user_id, fiber_id, base, multiplier, recommended, unit, updated_at) FROM stdin;
2	1	10.000000	1.0180	10.180	g	2025-11-23 20:44:04.63164
2	2	3.000000	1.0180	3.054	g	2025-11-23 20:44:04.63164
2	5	15.000000	1.0180	15.270	g	2025-11-23 20:44:04.63164
2	6	25.000000	1.0180	25.450	g	2025-11-23 20:44:04.63164
2	7	7.000000	1.0180	7.126	g	2025-11-23 20:44:04.63164
4	1	10.000000	1.0180	10.180	g	2025-12-04 06:34:12.534108
4	2	3.000000	1.0180	3.054	g	2025-12-04 06:34:12.534108
4	5	15.000000	1.0180	15.270	g	2025-12-04 06:34:12.534108
4	6	25.000000	1.0180	25.450	g	2025-12-04 06:34:12.534108
4	7	7.000000	1.0180	7.126	g	2025-12-04 06:34:12.534108
1	1	10.000000	1.0380	10.380	g	2025-11-24 22:52:15.990562
1	2	3.000000	1.0380	3.114	g	2025-11-24 22:52:15.990562
1	5	15.000000	1.0380	15.570	g	2025-11-24 22:52:15.990562
1	6	25.000000	1.0380	25.950	g	2025-11-24 22:52:15.990562
1	7	7.000000	1.0380	7.266	g	2025-11-24 22:52:15.990562
3	1	10.000000	1.0530	10.530	g	2025-11-29 01:32:36.387799
3	2	3.000000	1.0530	3.159	g	2025-11-29 01:32:36.387799
3	5	15.000000	1.0530	15.795	g	2025-11-29 01:32:36.387799
3	6	25.000000	1.0530	26.325	g	2025-11-29 01:32:36.387799
3	7	7.000000	1.0530	7.371	g	2025-11-29 01:32:36.387799
\.


--
-- TOC entry 6531 (class 0 OID 21393)
-- Dependencies: 250
-- Data for Name: usergoal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usergoal (goal_id, user_id, goal_type, goal_weight, activity_factor, bmr, tdee, daily_calorie_target, daily_protein_target, daily_fat_target, daily_carb_target, created_at) FROM stdin;
\.


--
-- TOC entry 6594 (class 0 OID 22242)
-- Dependencies: 317
-- Data for Name: userhealthcondition; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.userhealthcondition (user_condition_id, user_id, condition_id, diagnosed_date, treatment_start_date, treatment_end_date, treatment_duration_days, status, notes, created_at, medication_times) FROM stdin;
1	1	4	2025-11-19	2025-11-27	2025-11-29	2	recovered	\N	2025-11-19 17:23:17.583225	{07:00:00,12:00:00,19:00:00}
3	3	4	2025-11-24	2025-11-24	2025-12-01	7	active	\N	2025-11-24 06:27:45.049044	{07:00:00,12:00:00,19:00:00}
4	3	20	2025-12-04	2025-12-03	\N	\N	active	{"07:00"}	2025-12-03 21:56:00.398518	{07:00:00,12:00:00,19:00:00}
5	3	21	2025-12-04	2025-12-03	\N	\N	active	{"07:00"}	2025-12-03 22:27:41.424763	{07:00:00,12:00:00,19:00:00}
6	3	25	2025-12-04	2025-12-04	\N	\N	active	{"07:00","12:00","19:00"}	2025-12-04 00:42:28.094101	{07:00:00,12:00:00,19:00:00}
7	4	20	2025-12-04	2025-12-04	2025-12-11	7	active	\N	2025-12-04 05:58:06.759562	{07:00}
8	1	20	2025-12-04	2025-12-05	2025-12-12	7	active	\N	2025-12-04 18:07:29.397904	{07:00,12:00,19:00}
9	4	1	2025-12-04	2025-12-05	2025-12-12	7	active	\N	2025-12-04 23:34:36.331085	{07:00,12:00,19:00}
10	1	1	2025-12-05	2025-12-05	2025-12-12	7	active	\N	2025-12-05 00:42:07.330706	{07:00}
2	1	5	2025-11-22	2025-11-23	2025-12-12	19	active	\N	2025-11-22 17:22:00.781798	{}
\.


--
-- TOC entry 6676 (class 0 OID 29003)
-- Dependencies: 407
-- Data for Name: usermedication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usermedication (user_medication_id, user_id, medication_name, dosage, frequency, start_date, end_date, status, notes, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 6541 (class 0 OID 21579)
-- Dependencies: 260
-- Data for Name: usermineralrequirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usermineralrequirement (user_id, mineral_id, base, multiplier, recommended, unit, updated_at) FROM stdin;
1	1	1000.000	1.0470	1047.000	mg	2025-11-24 22:52:15.990562
1	2	700.000	1.0470	732.900	mg	2025-11-24 22:52:15.990562
1	3	400.000	1.0470	418.800	mg	2025-11-24 22:52:15.990562
1	4	3400.000	1.0470	3559.800	mg	2025-11-24 22:52:15.990562
1	5	1500.000	1.0470	1570.500	mg	2025-11-24 22:52:15.990562
1	6	8.000	1.0470	8.376	mg	2025-11-24 22:52:15.990562
1	7	11.000	1.0470	11.517	mg	2025-11-24 22:52:15.990562
1	8	900.000	1.0470	942.300	µg	2025-11-24 22:52:15.990562
1	9	2.300	1.0470	2.408	mg	2025-11-24 22:52:15.990562
1	10	150.000	1.0470	157.050	µg	2025-11-24 22:52:15.990562
1	11	55.000	1.0470	57.585	µg	2025-11-24 22:52:15.990562
1	12	35.000	1.0470	36.645	µg	2025-11-24 22:52:15.990562
1	13	45.000	1.0470	47.115	µg	2025-11-24 22:52:15.990562
1	14	3.000	1.0470	3.141	mg	2025-11-24 22:52:15.990562
2	1	1000.000	1.0270	1027.000	mg	2025-11-23 20:44:04.63164
2	2	700.000	1.0270	718.900	mg	2025-11-23 20:44:04.63164
2	3	310.000	1.0270	318.370	mg	2025-11-23 20:44:04.63164
2	4	2600.000	1.0270	2670.200	mg	2025-11-23 20:44:04.63164
2	5	1500.000	1.0270	1540.500	mg	2025-11-23 20:44:04.63164
2	6	18.000	1.0270	18.486	mg	2025-11-23 20:44:04.63164
2	7	8.000	1.0270	8.216	mg	2025-11-23 20:44:04.63164
2	8	900.000	1.0270	924.300	µg	2025-11-23 20:44:04.63164
2	9	1.800	1.0270	1.849	mg	2025-11-23 20:44:04.63164
2	10	150.000	1.0270	154.050	µg	2025-11-23 20:44:04.63164
2	11	55.000	1.0270	56.485	µg	2025-11-23 20:44:04.63164
2	12	35.000	1.0270	35.945	µg	2025-11-23 20:44:04.63164
2	13	45.000	1.0270	46.215	µg	2025-11-23 20:44:04.63164
2	14	3.000	1.0270	3.081	mg	2025-11-23 20:44:04.63164
4	1	1000.000	1.0270	1027.000	mg	2025-12-04 06:34:12.534108
4	2	700.000	1.0270	718.900	mg	2025-12-04 06:34:12.534108
4	3	310.000	1.0270	318.370	mg	2025-12-04 06:34:12.534108
4	4	2600.000	1.0270	2670.200	mg	2025-12-04 06:34:12.534108
4	5	1500.000	1.0270	1540.500	mg	2025-12-04 06:34:12.534108
4	6	18.000	1.0270	18.486	mg	2025-12-04 06:34:12.534108
4	7	8.000	1.0270	8.216	mg	2025-12-04 06:34:12.534108
4	8	900.000	1.0270	924.300	µg	2025-12-04 06:34:12.534108
4	9	1.800	1.0270	1.849	mg	2025-12-04 06:34:12.534108
3	1	1000.000	1.0795	1079.500	mg	2025-11-29 01:32:36.387799
3	2	700.000	1.0795	755.650	mg	2025-11-29 01:32:36.387799
3	3	310.000	1.0795	334.645	mg	2025-11-29 01:32:36.387799
3	4	2600.000	1.0795	2806.700	mg	2025-11-29 01:32:36.387799
3	5	1500.000	1.0795	1619.250	mg	2025-11-29 01:32:36.387799
3	6	18.000	1.0795	19.431	mg	2025-11-29 01:32:36.387799
3	7	8.000	1.0795	8.636	mg	2025-11-29 01:32:36.387799
3	8	900.000	1.0795	971.550	µg	2025-11-29 01:32:36.387799
3	9	1.800	1.0795	1.943	mg	2025-11-29 01:32:36.387799
3	10	150.000	1.0795	161.925	µg	2025-11-29 01:32:36.387799
3	11	55.000	1.0795	59.373	µg	2025-11-29 01:32:36.387799
3	12	35.000	1.0795	37.783	µg	2025-11-29 01:32:36.387799
3	13	45.000	1.0795	48.578	µg	2025-11-29 01:32:36.387799
3	14	3.000	1.0795	3.239	mg	2025-11-29 01:32:36.387799
4	10	150.000	1.0270	154.050	µg	2025-12-04 06:34:12.534108
4	11	55.000	1.0270	56.485	µg	2025-12-04 06:34:12.534108
4	12	35.000	1.0270	35.945	µg	2025-12-04 06:34:12.534108
4	13	45.000	1.0270	46.215	µg	2025-12-04 06:34:12.534108
4	14	3.000	1.0270	3.081	mg	2025-12-04 06:34:12.534108
\.


--
-- TOC entry 6648 (class 0 OID 23753)
-- Dependencies: 377
-- Data for Name: usernutrientmanuallog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usernutrientmanuallog (log_id, user_id, log_date, nutrient_id, nutrient_type, nutrient_code, nutrient_name, unit, amount, source, source_ref, metadata, created_at, updated_at) FROM stdin;
2	1	2025-11-20	2	macro	PROCNT	Protein	g	25.0000	scan	\N	{"source": "scan", "food_name": "Phá» bÃ²", "confidence": null}	2025-11-20 04:47:31.387243-08	2025-11-20 04:47:31.387243-08
4	1	2025-11-20	3	macro	FAT	Total Fat	g	10.0000	scan	\N	{"source": "scan", "food_name": "Phá» bÃ²", "confidence": null}	2025-11-20 04:47:31.390469-08	2025-11-20 04:47:31.390469-08
5	1	2025-11-20	5	macro	FIBTG	Dietary Fiber (total)	g	2.0000	scan	\N	{"source": "scan", "food_name": "Phá» bÃ²", "confidence": null}	2025-11-20 04:47:31.392796-08	2025-11-20 04:47:31.392796-08
6	1	2025-11-20	6	mineral	MIN_FE	Iron (Fe)	mg	3.0000	scan	\N	{"source": "scan", "food_name": "Phá» bÃ²", "confidence": null}	2025-11-20 04:47:31.395516-08	2025-11-20 04:47:31.395516-08
1	1	2025-11-20	1	macro	ENERC_KCAL	Energy (Calories)	kcal	400.0000	scan	\N	{"source": "scan", "food_name": "Phá» bÃ²", "confidence": null}	2025-11-20 04:47:31.382769-08	2025-11-20 04:47:31.396853-08
3	1	2025-11-20	4	macro	CHOCDF	Carbohydrate, by difference	g	340.0000	scan	\N	{"source": "scan", "food_name": "Phá» bÃ²", "confidence": null}	2025-11-20 04:47:31.388612-08	2025-11-20 04:47:31.398213-08
9	1	2025-11-20	8	vitamin	VITB3	Vitamin B3 (Niacin)	mg	5.0000	scan	\N	{"source": "scan", "food_name": "Phá» bÃ²", "confidence": null}	2025-11-20 04:47:31.399401-08	2025-11-20 04:47:31.399401-08
10	1	2025-11-20	13	vitamin	VITB12	Vitamin B12 (Cobalamin)	µg	1.5000	scan	\N	{"source": "scan", "food_name": "Phá» bÃ²", "confidence": null}	2025-11-20 04:47:31.401022-08	2025-11-20 04:47:31.401022-08
\.


--
-- TOC entry 6576 (class 0 OID 21994)
-- Dependencies: 296
-- Data for Name: usernutrientnotification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usernutrientnotification (notification_id, user_id, nutrient_type, nutrient_id, nutrient_name, notification_type, title, message, severity, is_read, metadata, created_at) FROM stdin;
\.


--
-- TOC entry 6574 (class 0 OID 21972)
-- Dependencies: 294
-- Data for Name: usernutrienttracking; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usernutrienttracking (tracking_id, user_id, date, nutrient_type, nutrient_id, target_amount, current_amount, unit, last_updated) FROM stdin;
1	1	2025-11-19	vitamin	11	31.950	\N	µg	2025-11-19 19:04:28.389863-08
2	1	2025-11-19	vitamin	9	5.325	\N	mg	2025-11-19 19:04:28.404138-08
3	1	2025-11-19	vitamin	8	17.040	\N	mg	2025-11-19 19:04:28.404704-08
4	1	2025-11-19	vitamin	3	15.975	\N	mg	2025-11-19 19:04:28.405345-08
5	1	2025-11-19	vitamin	10	1.385	\N	mg	2025-11-19 19:04:28.40585-08
6	1	2025-11-19	vitamin	13	2.556	\N	µg	2025-11-19 19:04:28.40639-08
7	1	2025-11-19	vitamin	5	95.850	\N	mg	2025-11-19 19:04:28.406916-08
8	1	2025-11-19	vitamin	2	639.000	\N	IU	2025-11-19 19:04:28.407355-08
9	1	2025-11-19	vitamin	12	426.000	\N	µg	2025-11-19 19:04:28.407742-08
10	1	2025-11-19	vitamin	4	127.800	\N	µg	2025-11-19 19:04:28.40815-08
11	1	2025-11-19	vitamin	7	1.385	\N	mg	2025-11-19 19:04:28.408533-08
12	1	2025-11-19	vitamin	6	1.278	\N	mg	2025-11-19 19:04:28.408976-08
13	1	2025-11-19	vitamin	1	958.500	\N	µg	2025-11-19 19:04:28.409344-08
14	1	2025-11-19	mineral	1	1047.000	\N	mg	2025-11-19 19:04:28.409739-08
15	1	2025-11-19	mineral	9	2.408	\N	mg	2025-11-19 19:04:28.410187-08
16	1	2025-11-19	mineral	10	157.050	\N	µg	2025-11-19 19:04:28.410637-08
17	1	2025-11-19	mineral	11	57.585	\N	µg	2025-11-19 19:04:28.411186-08
18	1	2025-11-19	mineral	3	418.800	\N	mg	2025-11-19 19:04:28.411689-08
19	1	2025-11-19	mineral	6	8.376	\N	mg	2025-11-19 19:04:28.412233-08
20	1	2025-11-19	mineral	12	36.645	\N	µg	2025-11-19 19:04:28.412692-08
21	1	2025-11-19	mineral	13	47.115	\N	µg	2025-11-19 19:04:28.413236-08
22	1	2025-11-19	mineral	8	942.300	\N	mg	2025-11-19 19:04:28.413719-08
23	1	2025-11-19	mineral	5	1570.500	\N	mg	2025-11-19 19:04:28.41418-08
24	1	2025-11-19	mineral	14	3.141	\N	mg	2025-11-19 19:04:28.414721-08
25	1	2025-11-19	mineral	7	11.517	\N	mg	2025-11-19 19:04:28.415238-08
26	1	2025-11-19	mineral	2	732.900	\N	mg	2025-11-19 19:04:28.415611-08
27	1	2025-11-19	mineral	4	3559.800	\N	mg	2025-11-19 19:04:28.41608-08
135	1	2025-11-20	mineral	4	3559.800	180.000	mg	2025-11-20 06:31:08.346912-08
136	1	2025-11-20	fiber	1	0.000	0.000	g	2025-11-20 06:31:08.347202-08
137	1	2025-11-20	fiber	2	0.000	0.000	g	2025-11-20 06:31:08.347486-08
138	1	2025-11-20	fatty_acid	7	0.000	0.000	g	2025-11-20 06:31:08.347738-08
139	1	2025-11-20	fatty_acid	5	0.000	60.000	g	2025-11-20 06:31:08.347962-08
140	1	2025-11-20	fatty_acid	3	0.000	0.000	g	2025-11-20 06:31:08.348176-08
141	1	2025-11-20	fatty_acid	4	0.000	60.000	g	2025-11-20 06:31:08.34843-08
142	1	2025-11-20	fatty_acid	6	0.000	600.000	mg	2025-11-20 06:31:08.348755-08
143	1	2025-11-20	fatty_acid	1	0.000	60.000	g	2025-11-20 06:31:08.349098-08
144	1	2025-11-20	fatty_acid	2	0.000	0.000	g	2025-11-20 06:31:08.349487-08
327	1	2025-11-21	vitamin	7	1.385	90.000	mg	2025-11-20 17:58:45.635008-08
328	1	2025-11-21	vitamin	11	31.950	900.000	µg	2025-11-20 17:58:45.635498-08
109	1	2025-11-20	vitamin	9	5.325	120.000	mg	2025-11-20 06:31:08.329629-08
110	1	2025-11-20	vitamin	2	639.000	12000.000	IU	2025-11-20 06:31:08.336148-08
111	1	2025-11-20	vitamin	7	1.385	120.000	mg	2025-11-20 06:31:08.336753-08
112	1	2025-11-20	vitamin	11	31.950	1200.000	µg	2025-11-20 06:31:08.337327-08
113	1	2025-11-20	vitamin	4	127.800	1200.000	µg	2025-11-20 06:31:08.337767-08
114	1	2025-11-20	vitamin	3	15.975	120.000	mg	2025-11-20 06:31:08.338223-08
115	1	2025-11-20	vitamin	1	958.500	1200.000	µg	2025-11-20 06:31:08.33873-08
116	1	2025-11-20	vitamin	8	17.040	120.000	mg	2025-11-20 06:31:08.339192-08
117	1	2025-11-20	vitamin	10	1.385	120.000	mg	2025-11-20 06:31:08.339719-08
118	1	2025-11-20	vitamin	13	2.556	1200.000	µg	2025-11-20 06:31:08.340194-08
119	1	2025-11-20	vitamin	5	95.850	217.900	mg	2025-11-20 06:31:08.340623-08
120	1	2025-11-20	vitamin	12	426.000	1200.000	µg	2025-11-20 06:31:08.341476-08
121	1	2025-11-20	vitamin	6	1.278	120.000	mg	2025-11-20 06:31:08.341912-08
122	1	2025-11-20	mineral	13	47.115	600.000	µg	2025-11-20 06:31:08.342252-08
123	1	2025-11-20	mineral	5	1570.500	3568.600	mg	2025-11-20 06:31:08.342812-08
124	1	2025-11-20	mineral	1	1047.000	346.900	mg	2025-11-20 06:31:08.343257-08
125	1	2025-11-20	mineral	9	2.408	180.000	mg	2025-11-20 06:31:08.343581-08
126	1	2025-11-20	mineral	6	8.376	184.200	mg	2025-11-20 06:31:08.343925-08
127	1	2025-11-20	mineral	3	418.800	180.000	mg	2025-11-20 06:31:08.344308-08
128	1	2025-11-20	mineral	12	36.645	600.000	µg	2025-11-20 06:31:08.344727-08
329	1	2025-11-21	vitamin	4	127.800	900.000	µg	2025-11-20 17:58:45.63597-08
330	1	2025-11-21	vitamin	3	15.975	90.000	mg	2025-11-20 17:58:45.636484-08
331	1	2025-11-21	vitamin	1	958.500	900.000	µg	2025-11-20 17:58:45.636848-08
332	1	2025-11-21	vitamin	8	17.040	90.000	mg	2025-11-20 17:58:45.637232-08
333	1	2025-11-21	vitamin	10	1.385	90.000	mg	2025-11-20 17:58:45.637595-08
334	1	2025-11-21	vitamin	13	2.556	900.000	µg	2025-11-20 17:58:45.637984-08
335	1	2025-11-21	vitamin	5	95.850	90.000	mg	2025-11-20 17:58:45.638834-08
336	1	2025-11-21	vitamin	12	426.000	900.000	µg	2025-11-20 17:58:45.639417-08
129	1	2025-11-20	mineral	10	157.050	600.000	µg	2025-11-20 06:31:08.345073-08
130	1	2025-11-20	mineral	8	942.300	180.000	mg	2025-11-20 06:31:08.345492-08
131	1	2025-11-20	mineral	7	11.517	180.000	mg	2025-11-20 06:31:08.345783-08
132	1	2025-11-20	mineral	11	57.585	600.000	µg	2025-11-20 06:31:08.346127-08
133	1	2025-11-20	mineral	2	732.900	180.000	mg	2025-11-20 06:31:08.346405-08
134	1	2025-11-20	mineral	14	3.141	180.000	mg	2025-11-20 06:31:08.34665-08
337	1	2025-11-21	vitamin	6	1.278	90.000	mg	2025-11-20 17:58:45.639914-08
338	1	2025-11-21	mineral	13	47.115	450.000	µg	2025-11-20 17:58:45.640419-08
339	1	2025-11-21	mineral	5	1570.500	135.000	mg	2025-11-20 17:58:45.641189-08
340	1	2025-11-21	mineral	1	1047.000	135.000	mg	2025-11-20 17:58:45.641793-08
341	1	2025-11-21	mineral	9	2.408	135.000	mg	2025-11-20 17:58:45.642299-08
342	1	2025-11-21	mineral	6	8.376	135.000	mg	2025-11-20 17:58:45.642735-08
343	1	2025-11-21	mineral	3	418.800	135.000	mg	2025-11-20 17:58:45.643138-08
344	1	2025-11-21	mineral	12	36.645	450.000	µg	2025-11-20 17:58:45.643509-08
345	1	2025-11-21	mineral	10	157.050	450.000	µg	2025-11-20 17:58:45.643952-08
346	1	2025-11-21	mineral	8	942.300	135.000	mg	2025-11-20 17:58:45.644456-08
347	1	2025-11-21	mineral	7	11.517	135.000	mg	2025-11-20 17:58:45.64517-08
348	1	2025-11-21	mineral	11	57.585	450.000	µg	2025-11-20 17:58:45.645711-08
349	1	2025-11-21	mineral	2	732.900	135.000	mg	2025-11-20 17:58:45.64622-08
350	1	2025-11-21	mineral	14	3.141	135.000	mg	2025-11-20 17:58:45.647009-08
351	1	2025-11-21	mineral	4	3559.800	135.000	mg	2025-11-20 17:58:45.64744-08
352	1	2025-11-21	fiber	1	0.000	0.000	g	2025-11-20 17:58:45.647943-08
325	1	2025-11-21	vitamin	9	5.325	90.000	mg	2025-11-20 17:58:45.633088-08
326	1	2025-11-21	vitamin	2	639.000	9000.000	IU	2025-11-20 17:58:45.634365-08
515	1	2025-11-23	fatty_acid	6	311.000	450.000	mg	2025-11-23 01:26:13.458707-08
516	1	2025-11-23	fatty_acid	17	34.730	72.000	g	2025-11-23 01:26:13.459503-08
517	1	2025-11-23	fatty_acid	16	2.778	9.000	g	2025-11-23 01:26:13.460315-08
518	1	2025-11-23	fatty_acid	15	20.838	36.000	g	2025-11-23 01:26:13.460729-08
519	1	2025-11-23	fatty_acid	7	83.351	183.700	g	2025-11-23 01:26:13.461065-08
520	1	2025-11-23	fatty_acid	2	0.000	9.000	g	2025-11-23 01:26:13.461354-08
482	1	2025-11-23	mineral	13	47.115	450.000	µg	2025-11-23 01:26:13.446048-08
483	1	2025-11-23	mineral	5	1570.500	13191.000	mg	2025-11-23 01:26:13.446622-08
484	1	2025-11-23	mineral	1	1047.000	932.000	mg	2025-11-23 01:26:13.44711-08
353	1	2025-11-21	fiber	2	0.000	0.000	g	2025-11-20 17:58:45.648304-08
354	1	2025-11-21	fatty_acid	7	0.000	0.000	g	2025-11-20 17:58:45.64914-08
355	1	2025-11-21	fatty_acid	5	0.000	45.000	g	2025-11-20 17:58:45.649816-08
356	1	2025-11-21	fatty_acid	3	0.000	0.000	g	2025-11-20 17:58:45.650287-08
357	1	2025-11-21	fatty_acid	4	0.000	45.000	g	2025-11-20 17:58:45.650714-08
358	1	2025-11-21	fatty_acid	6	0.000	450.000	mg	2025-11-20 17:58:45.651199-08
359	1	2025-11-21	fatty_acid	1	0.000	45.000	g	2025-11-20 17:58:45.651582-08
360	1	2025-11-21	fatty_acid	2	0.000	0.000	g	2025-11-20 17:58:45.652053-08
485	1	2025-11-23	mineral	9	2.408	135.000	mg	2025-11-23 01:26:13.447615-08
486	1	2025-11-23	mineral	6	8.376	142.200	mg	2025-11-23 01:26:13.448059-08
487	1	2025-11-23	mineral	3	418.800	135.000	mg	2025-11-23 01:26:13.448495-08
488	1	2025-11-23	mineral	12	36.645	450.000	µg	2025-11-23 01:26:13.448921-08
489	1	2025-11-23	mineral	10	157.050	450.000	µg	2025-11-23 01:26:13.449272-08
490	1	2025-11-23	mineral	8	942.300	135.000	mg	2025-11-23 01:26:13.449629-08
491	1	2025-11-23	mineral	7	11.517	135.000	mg	2025-11-23 01:26:13.45002-08
492	1	2025-11-23	mineral	11	57.585	450.000	µg	2025-11-23 01:26:13.450404-08
493	1	2025-11-23	mineral	2	732.900	135.000	mg	2025-11-23 01:26:13.450843-08
494	1	2025-11-23	mineral	14	3.141	135.000	mg	2025-11-23 01:26:13.451189-08
944	1	2025-11-24	vitamin	8	17.040	1060.000	mg	2025-11-23 19:37:18.24795-08
945	1	2025-11-24	vitamin	10	1.385	1060.000	mg	2025-11-23 19:37:18.248306-08
495	1	2025-11-23	mineral	4	3559.800	135.000	mg	2025-11-23 01:26:13.451518-08
496	1	2025-11-23	amino_acid	5	0.000	0.000	mg	2025-11-23 01:26:13.451808-08
497	1	2025-11-23	amino_acid	3	0.000	0.000	mg	2025-11-23 01:26:13.452092-08
498	1	2025-11-23	amino_acid	6	0.000	0.000	mg	2025-11-23 01:26:13.452378-08
499	1	2025-11-23	amino_acid	9	0.000	0.000	mg	2025-11-23 01:26:13.452664-08
500	1	2025-11-23	amino_acid	7	0.000	0.000	mg	2025-11-23 01:26:13.452955-08
501	1	2025-11-23	amino_acid	1	0.000	0.000	mg	2025-11-23 01:26:13.453224-08
502	1	2025-11-23	amino_acid	8	0.000	0.000	mg	2025-11-23 01:26:13.453489-08
503	1	2025-11-23	amino_acid	4	0.000	0.000	mg	2025-11-23 01:26:13.453765-08
504	1	2025-11-23	amino_acid	2	0.000	0.000	mg	2025-11-23 01:26:13.454063-08
505	1	2025-11-23	fiber	2	3.114	27.000	g	2025-11-23 01:26:13.454388-08
506	1	2025-11-23	fiber	1	10.380	27.000	g	2025-11-23 01:26:13.454674-08
507	1	2025-11-23	fiber	5	15.570	27.000	g	2025-11-23 01:26:13.455033-08
508	1	2025-11-23	fiber	6	25.950	96.000	g	2025-11-23 01:26:13.455602-08
509	1	2025-11-23	fiber	7	7.266	27.000	g	2025-11-23 01:26:13.456007-08
510	1	2025-11-23	fatty_acid	3	0.000	9.000	g	2025-11-23 01:26:13.456506-08
511	1	2025-11-23	fatty_acid	4	363.000	9.000	g	2025-11-23 01:26:13.456857-08
946	1	2025-11-24	vitamin	13	2.556	1600.000	µg	2025-11-23 19:37:18.248807-08
947	1	2025-11-24	vitamin	5	95.850	1060.000	mg	2025-11-23 19:37:18.249342-08
948	1	2025-11-24	vitamin	12	426.000	1600.000	µg	2025-11-23 19:37:18.249849-08
949	1	2025-11-24	vitamin	6	1.278	1060.000	mg	2025-11-23 19:37:18.250289-08
469	1	2025-11-23	vitamin	9	5.325	90.000	mg	2025-11-23 01:26:13.440027-08
470	1	2025-11-23	vitamin	2	639.000	9000.000	IU	2025-11-23 01:26:13.440721-08
471	1	2025-11-23	vitamin	7	1.385	90.000	mg	2025-11-23 01:26:13.441135-08
472	1	2025-11-23	vitamin	11	31.950	900.000	µg	2025-11-23 01:26:13.44153-08
473	1	2025-11-23	vitamin	4	127.800	900.000	µg	2025-11-23 01:26:13.441946-08
474	1	2025-11-23	vitamin	3	15.975	90.000	mg	2025-11-23 01:26:13.442358-08
475	1	2025-11-23	vitamin	1	958.500	900.000	µg	2025-11-23 01:26:13.442768-08
476	1	2025-11-23	vitamin	8	17.040	90.000	mg	2025-11-23 01:26:13.443184-08
477	1	2025-11-23	vitamin	10	1.385	90.000	mg	2025-11-23 01:26:13.443698-08
478	1	2025-11-23	vitamin	13	2.556	900.000	µg	2025-11-23 01:26:13.44427-08
479	1	2025-11-23	vitamin	5	95.850	117.000	mg	2025-11-23 01:26:13.444755-08
480	1	2025-11-23	vitamin	12	426.000	900.000	µg	2025-11-23 01:26:13.445175-08
481	1	2025-11-23	vitamin	6	1.278	90.000	mg	2025-11-23 01:26:13.44558-08
512	1	2025-11-23	fatty_acid	5	13.892	9.000	g	2025-11-23 01:26:13.457204-08
513	1	2025-11-23	fatty_acid	1	0.000	9.000	g	2025-11-23 01:26:13.457618-08
514	1	2025-11-23	fatty_acid	18	27.784	45.000	g	2025-11-23 01:26:13.458233-08
950	1	2025-11-24	mineral	13	47.115	1300.000	µg	2025-11-23 19:37:18.250633-08
951	1	2025-11-24	mineral	5	1570.500	1090.000	mg	2025-11-23 19:37:18.251047-08
952	1	2025-11-24	mineral	1	1047.000	1090.000	mg	2025-11-23 19:37:18.251654-08
953	1	2025-11-24	mineral	9	2.408	1090.000	mg	2025-11-23 19:37:18.252099-08
954	1	2025-11-24	mineral	6	8.376	1090.000	mg	2025-11-23 19:37:18.252523-08
955	1	2025-11-24	mineral	3	418.800	1090.000	mg	2025-11-23 19:37:18.252872-08
956	1	2025-11-24	mineral	12	36.645	1300.000	µg	2025-11-23 19:37:18.25319-08
957	1	2025-11-24	mineral	10	157.050	1300.000	µg	2025-11-23 19:37:18.253573-08
958	1	2025-11-24	mineral	8	942.300	1090.000	mg	2025-11-23 19:37:18.254121-08
959	1	2025-11-24	mineral	7	11.517	1090.000	mg	2025-11-23 19:37:18.254632-08
960	1	2025-11-24	mineral	11	57.585	1300.000	µg	2025-11-23 19:37:18.255132-08
961	1	2025-11-24	mineral	2	732.900	1090.000	mg	2025-11-23 19:37:18.255495-08
962	1	2025-11-24	mineral	14	3.141	1090.000	mg	2025-11-23 19:37:18.255846-08
963	1	2025-11-24	mineral	4	3559.800	1090.000	mg	2025-11-23 19:37:18.256285-08
964	1	2025-11-24	amino_acid	5	0.000	1015.000	mg	2025-11-23 19:37:18.256767-08
965	1	2025-11-24	amino_acid	3	0.000	1015.000	mg	2025-11-23 19:37:18.257154-08
966	1	2025-11-24	amino_acid	6	0.000	1015.000	mg	2025-11-23 19:37:18.257543-08
967	1	2025-11-24	amino_acid	9	0.000	1015.000	mg	2025-11-23 19:37:18.257841-08
968	1	2025-11-24	amino_acid	7	0.000	1015.000	mg	2025-11-23 19:37:18.258097-08
969	1	2025-11-24	amino_acid	1	0.000	1015.000	mg	2025-11-23 19:37:18.258356-08
970	1	2025-11-24	amino_acid	8	0.000	1015.000	mg	2025-11-23 19:37:18.25869-08
971	1	2025-11-24	amino_acid	4	0.000	1015.000	mg	2025-11-23 19:37:18.258971-08
972	1	2025-11-24	amino_acid	2	0.000	1015.000	mg	2025-11-23 19:37:18.25923-08
937	1	2025-11-24	vitamin	9	5.325	1060.000	mg	2025-11-23 19:37:18.243928-08
938	1	2025-11-24	vitamin	2	639.000	7000.000	IU	2025-11-23 19:37:18.244892-08
939	1	2025-11-24	vitamin	7	1.385	1060.000	mg	2025-11-23 19:37:18.245378-08
940	1	2025-11-24	vitamin	11	31.950	1600.000	µg	2025-11-23 19:37:18.246092-08
941	1	2025-11-24	vitamin	4	127.800	1600.000	µg	2025-11-23 19:37:18.246699-08
942	1	2025-11-24	vitamin	3	15.975	1060.000	mg	2025-11-23 19:37:18.247171-08
943	1	2025-11-24	vitamin	1	958.500	1600.000	µg	2025-11-23 19:37:18.247572-08
973	1	2025-11-24	fiber	1	10.380	0.000	g	2025-11-23 19:37:18.259596-08
974	1	2025-11-24	fiber	2	3.114	0.000	g	2025-11-23 19:37:18.25991-08
975	1	2025-11-24	fiber	5	15.570	0.000	g	2025-11-23 19:37:18.260195-08
976	1	2025-11-24	fiber	6	25.950	3104.100	g	2025-11-23 19:37:18.260444-08
977	1	2025-11-24	fiber	7	7.266	0.000	g	2025-11-23 19:37:18.260679-08
978	1	2025-11-24	fatty_acid	1	0.000	0.000	g	2025-11-23 19:37:18.260916-08
979	1	2025-11-24	fatty_acid	2	0.000	0.000	g	2025-11-23 19:37:18.261178-08
980	1	2025-11-24	fatty_acid	3	0.000	0.000	g	2025-11-23 19:37:18.261418-08
981	1	2025-11-24	fatty_acid	4	363.000	2012000.000	g	2025-11-23 19:37:18.261649-08
982	1	2025-11-24	fatty_acid	5	13.892	0.000	g	2025-11-23 19:37:18.261882-08
983	1	2025-11-24	fatty_acid	6	311.000	0.000	mg	2025-11-23 19:37:18.262165-08
984	1	2025-11-24	fatty_acid	7	83.351	1129.600	g	2025-11-23 19:37:18.262834-08
985	1	2025-11-24	fatty_acid	15	20.838	3036.000	g	2025-11-23 19:37:18.263209-08
986	1	2025-11-24	fatty_acid	16	2.778	0.000	g	2025-11-23 19:37:18.263648-08
987	1	2025-11-24	fatty_acid	17	34.730	1048.000	g	2025-11-23 19:37:18.264081-08
988	1	2025-11-24	fatty_acid	18	27.784	0.000	g	2025-11-23 19:37:18.264467-08
1405	3	2025-11-27	vitamin	3	17.288	1000.000	mg	2025-11-27 05:51:50.515458-08
1406	3	2025-11-27	vitamin	11	34.575	1000.000	µg	2025-11-27 05:51:50.519026-08
1407	3	2025-11-27	vitamin	4	138.300	1000.000	µg	2025-11-27 05:51:50.519613-08
1408	3	2025-11-27	vitamin	6	1.383	1000.000	mg	2025-11-27 05:51:50.520221-08
1409	3	2025-11-27	vitamin	8	18.440	1000.000	mg	2025-11-27 05:51:50.520746-08
1410	3	2025-11-27	vitamin	10	1.498	1000.000	mg	2025-11-27 05:51:50.521297-08
1411	3	2025-11-27	vitamin	13	2.766	1000.000	µg	2025-11-27 05:51:50.521827-08
1412	3	2025-11-27	vitamin	2	691.500	1000.000	IU	2025-11-27 05:51:50.522428-08
1413	3	2025-11-27	vitamin	7	1.498	1000.000	mg	2025-11-27 05:51:50.5232-08
1414	3	2025-11-27	vitamin	5	103.725	1000.000	mg	2025-11-27 05:51:50.523836-08
1415	3	2025-11-27	vitamin	1	1037.250	1000.000	µg	2025-11-27 05:51:50.524374-08
1416	3	2025-11-27	vitamin	9	5.763	1000.000	mg	2025-11-27 05:51:50.52501-08
1417	3	2025-11-27	vitamin	12	461.000	1000.000	µg	2025-11-27 05:51:50.525891-08
1418	3	2025-11-27	mineral	5	1649.250	1000.000	mg	2025-11-27 05:51:50.526438-08
1419	3	2025-11-27	mineral	9	2.529	1000.000	mg	2025-11-27 05:51:50.526915-08
1420	3	2025-11-27	mineral	6	8.796	1000.000	mg	2025-11-27 05:51:50.527385-08
1421	3	2025-11-27	mineral	14	3.299	1000.000	mg	2025-11-27 05:51:50.527866-08
1422	3	2025-11-27	mineral	2	769.650	1000.000	mg	2025-11-27 05:51:50.528343-08
1423	3	2025-11-27	mineral	1	1099.500	1000.000	mg	2025-11-27 05:51:50.528782-08
1424	3	2025-11-27	mineral	13	49.478	1000.000	µg	2025-11-27 05:51:50.529156-08
1425	3	2025-11-27	mineral	10	164.925	1000.000	µg	2025-11-27 05:51:50.529519-08
1426	3	2025-11-27	mineral	4	3738.300	1000.000	mg	2025-11-27 05:51:50.529907-08
1427	3	2025-11-27	mineral	7	12.095	1000.000	mg	2025-11-27 05:51:50.530266-08
1428	3	2025-11-27	mineral	11	60.473	1000.000	µg	2025-11-27 05:51:50.530618-08
1429	3	2025-11-27	mineral	3	439.800	1000.000	mg	2025-11-27 05:51:50.533334-08
1430	3	2025-11-27	mineral	8	989.550	1000.000	mg	2025-11-27 05:51:50.533938-08
1431	3	2025-11-27	mineral	12	38.483	1000.000	µg	2025-11-27 05:51:50.534461-08
1432	3	2025-11-27	amino_acid	6	1756.560	1000.000	mg	2025-11-27 05:51:50.53497-08
1433	3	2025-11-27	amino_acid	8	1013.400	1000.000	mg	2025-11-27 05:51:50.535431-08
1434	3	2025-11-27	amino_acid	7	270.240	1000.000	mg	2025-11-27 05:51:50.535951-08
1435	3	2025-11-27	amino_acid	2	1689.000	1000.000	mg	2025-11-27 05:51:50.536394-08
1436	3	2025-11-27	amino_acid	4	2026.800	1000.000	mg	2025-11-27 05:51:50.5369-08
1437	3	2025-11-27	amino_acid	1	1283.640	1000.000	mg	2025-11-27 05:51:50.53746-08
1438	3	2025-11-27	amino_acid	3	945.840	1000.000	mg	2025-11-27 05:51:50.538111-08
1439	3	2025-11-27	amino_acid	9	2837.520	1000.000	mg	2025-11-27 05:51:50.538665-08
1440	3	2025-11-27	amino_acid	5	1013.400	1000.000	mg	2025-11-27 05:51:50.539146-08
1441	3	2025-11-27	fiber	1	10.730	0.000	g	2025-11-27 05:51:50.539671-08
1442	3	2025-11-27	fiber	2	3.219	0.000	g	2025-11-27 05:51:50.540191-08
1443	3	2025-11-27	fiber	5	16.095	0.000	g	2025-11-27 05:51:50.540747-08
1444	3	2025-11-27	fiber	6	26.825	3000.000	g	2025-11-27 05:51:50.541884-08
1445	3	2025-11-27	fiber	7	7.511	0.000	g	2025-11-27 05:51:50.543493-08
1446	3	2025-11-27	fatty_acid	1	0.000	0.000	g	2025-11-27 05:51:50.544183-08
1447	3	2025-11-27	fatty_acid	2	0.000	0.000	g	2025-11-27 05:51:50.544667-08
1448	3	2025-11-27	fatty_acid	3	0.000	0.000	g	2025-11-27 05:51:50.545051-08
1449	3	2025-11-27	fatty_acid	4	376.000	2000000.000	g	2025-11-27 05:51:50.545407-08
1450	3	2025-11-27	fatty_acid	5	19.244	0.000	g	2025-11-27 05:51:50.546051-08
1451	3	2025-11-27	fatty_acid	6	322.000	0.000	mg	2025-11-27 05:51:50.54668-08
1452	3	2025-11-27	fatty_acid	7	115.463	1000.000	g	2025-11-27 05:51:50.547571-08
1453	3	2025-11-27	fatty_acid	15	28.866	3000.000	g	2025-11-27 05:51:50.549786-08
1454	3	2025-11-27	fatty_acid	16	3.849	0.000	g	2025-11-27 05:51:50.550576-08
1455	3	2025-11-27	fatty_acid	17	48.110	1000.000	g	2025-11-27 05:51:50.551164-08
1456	3	2025-11-27	fatty_acid	18	38.488	0.000	g	2025-11-27 05:51:50.551721-08
1457	3	2025-11-29	vitamin	7	1.246	1000.000	mg	2025-11-29 01:34:58.961691-08
1458	3	2025-11-29	vitamin	6	1.246	1000.000	mg	2025-11-29 01:34:58.968099-08
1459	3	2025-11-29	vitamin	9	5.663	1000.000	mg	2025-11-29 01:34:58.970682-08
1460	3	2025-11-29	vitamin	3	16.988	1000.000	mg	2025-11-29 01:34:58.971636-08
1461	3	2025-11-29	vitamin	4	101.925	1000.000	µg	2025-11-29 01:34:58.972335-08
1462	3	2025-11-29	vitamin	5	84.938	1000.000	mg	2025-11-29 01:34:58.972899-08
1463	3	2025-11-29	vitamin	1	792.750	1000.000	µg	2025-11-29 01:34:58.973473-08
1464	3	2025-11-29	vitamin	13	2.718	1000.000	µg	2025-11-29 01:34:58.974256-08
1465	3	2025-11-29	vitamin	11	33.975	1000.000	µg	2025-11-29 01:34:58.975319-08
1466	3	2025-11-29	vitamin	2	679.500	1000.000	IU	2025-11-29 01:34:58.976808-08
1467	3	2025-11-29	vitamin	12	453.000	1000.000	µg	2025-11-29 01:34:58.978493-08
1468	3	2025-11-29	vitamin	8	15.855	1000.000	mg	2025-11-29 01:34:58.979407-08
1469	3	2025-11-29	vitamin	10	1.472	1000.000	mg	2025-11-29 01:34:58.980392-08
1470	3	2025-11-29	mineral	2	755.650	1000.000	mg	2025-11-29 01:34:58.98185-08
1471	3	2025-11-29	mineral	3	334.645	1000.000	mg	2025-11-29 01:34:58.98417-08
1472	3	2025-11-29	mineral	9	1.943	1000.000	mg	2025-11-29 01:34:58.987862-08
1473	3	2025-11-29	mineral	14	3.239	1000.000	mg	2025-11-29 01:34:58.989897-08
1474	3	2025-11-29	mineral	7	8.636	1000.000	mg	2025-11-29 01:34:58.99068-08
1475	3	2025-11-29	mineral	6	19.431	1000.000	mg	2025-11-29 01:34:58.991296-08
1476	3	2025-11-29	mineral	8	971.550	1000.000	mg	2025-11-29 01:34:58.992048-08
1477	3	2025-11-29	mineral	4	2806.700	1000.000	mg	2025-11-29 01:34:58.992733-08
1478	3	2025-11-29	mineral	10	161.925	1000.000	µg	2025-11-29 01:34:58.99382-08
1479	3	2025-11-29	mineral	1	1079.500	1000.000	mg	2025-11-29 01:34:58.994489-08
1480	3	2025-11-29	mineral	5	1619.250	1000.000	mg	2025-11-29 01:34:58.995071-08
1481	3	2025-11-29	mineral	11	59.373	1000.000	µg	2025-11-29 01:34:58.995711-08
1482	3	2025-11-29	mineral	12	37.783	1000.000	µg	2025-11-29 01:34:58.996363-08
1483	3	2025-11-29	mineral	13	48.578	1000.000	µg	2025-11-29 01:34:58.997309-08
1484	3	2025-11-29	amino_acid	5	995.400	1000.000	mg	2025-11-29 01:34:58.999456-08
1485	3	2025-11-29	amino_acid	3	929.040	1000.000	mg	2025-11-29 01:34:59.000059-08
1486	3	2025-11-29	amino_acid	2	1659.000	1000.000	mg	2025-11-29 01:34:59.000522-08
1487	3	2025-11-29	amino_acid	6	1725.360	1000.000	mg	2025-11-29 01:34:59.001102-08
1488	3	2025-11-29	amino_acid	8	995.400	1000.000	mg	2025-11-29 01:34:59.001589-08
1489	3	2025-11-29	amino_acid	1	1260.840	1000.000	mg	2025-11-29 01:34:59.002076-08
1490	3	2025-11-29	amino_acid	9	2787.120	1000.000	mg	2025-11-29 01:34:59.002494-08
1491	3	2025-11-29	amino_acid	7	265.440	1000.000	mg	2025-11-29 01:34:59.0029-08
1492	3	2025-11-29	amino_acid	4	1990.800	1000.000	mg	2025-11-29 01:34:59.003289-08
1493	3	2025-11-29	fiber	1	10.530	0.000	g	2025-11-29 01:34:59.003656-08
1494	3	2025-11-29	fiber	2	3.159	0.000	g	2025-11-29 01:34:59.004038-08
1495	3	2025-11-29	fiber	5	15.795	0.000	g	2025-11-29 01:34:59.004443-08
1496	3	2025-11-29	fiber	6	26.325	3000.000	g	2025-11-29 01:34:59.00493-08
1497	3	2025-11-29	fiber	7	7.371	0.000	g	2025-11-29 01:34:59.005425-08
1498	3	2025-11-29	fatty_acid	1	0.000	0.000	g	2025-11-29 01:34:59.005819-08
1499	3	2025-11-29	fatty_acid	2	0.000	0.000	g	2025-11-29 01:34:59.006229-08
1500	3	2025-11-29	fatty_acid	3	0.000	0.000	g	2025-11-29 01:34:59.006591-08
1501	3	2025-11-29	fatty_acid	4	263.000	2000000.000	g	2025-11-29 01:34:59.006955-08
1502	3	2025-11-29	fatty_acid	5	15.510	0.000	g	2025-11-29 01:34:59.007309-08
1503	3	2025-11-29	fatty_acid	6	316.000	0.000	mg	2025-11-29 01:34:59.00766-08
1504	3	2025-11-29	fatty_acid	7	93.059	1000.000	g	2025-11-29 01:34:59.008019-08
1505	3	2025-11-29	fatty_acid	15	23.265	3000.000	g	2025-11-29 01:34:59.008425-08
1506	3	2025-11-29	fatty_acid	16	3.102	0.000	g	2025-11-29 01:34:59.008958-08
1507	3	2025-11-29	fatty_acid	17	38.775	1000.000	g	2025-11-29 01:34:59.009478-08
1508	3	2025-11-29	fatty_acid	18	31.020	0.000	g	2025-11-29 01:34:59.009893-08
1509	3	2025-12-03	vitamin	1	792.750	0.000	µg	2025-12-03 21:12:48.293305-08
1510	3	2025-12-03	vitamin	7	1.246	0.000	mg	2025-12-03 21:12:48.303921-08
1511	3	2025-12-03	vitamin	6	1.246	0.000	mg	2025-12-03 21:12:48.304876-08
1512	3	2025-12-03	vitamin	13	2.718	0.000	µg	2025-12-03 21:12:48.305692-08
1513	3	2025-12-03	vitamin	9	5.663	0.000	mg	2025-12-03 21:12:48.306647-08
1514	3	2025-12-03	vitamin	3	16.988	0.000	mg	2025-12-03 21:12:48.307687-08
1515	3	2025-12-03	vitamin	10	1.472	0.000	mg	2025-12-03 21:12:48.308559-08
1516	3	2025-12-03	vitamin	8	15.855	0.000	mg	2025-12-03 21:12:48.309677-08
1517	3	2025-12-03	vitamin	11	33.975	0.000	µg	2025-12-03 21:12:48.310325-08
1518	3	2025-12-03	vitamin	2	679.500	0.000	IU	2025-12-03 21:12:48.311237-08
1519	3	2025-12-03	vitamin	4	101.925	0.000	µg	2025-12-03 21:12:48.311985-08
1520	3	2025-12-03	vitamin	5	84.938	0.000	mg	2025-12-03 21:12:48.312717-08
1521	3	2025-12-03	vitamin	12	453.000	0.000	µg	2025-12-03 21:12:48.313559-08
1522	3	2025-12-03	mineral	14	3.239	0.000	mg	2025-12-03 21:12:48.314305-08
1523	3	2025-12-03	mineral	2	755.650	0.000	mg	2025-12-03 21:12:48.316123-08
1524	3	2025-12-03	mineral	7	8.636	0.000	mg	2025-12-03 21:12:48.318627-08
1525	3	2025-12-03	mineral	4	2806.700	0.000	mg	2025-12-03 21:12:48.319874-08
1526	3	2025-12-03	mineral	3	334.645	0.000	mg	2025-12-03 21:12:48.321087-08
1527	3	2025-12-03	mineral	10	161.925	0.000	µg	2025-12-03 21:12:48.32237-08
1528	3	2025-12-03	mineral	11	59.373	0.000	µg	2025-12-03 21:12:48.323113-08
1529	3	2025-12-03	mineral	6	19.431	0.000	mg	2025-12-03 21:12:48.324428-08
1530	3	2025-12-03	mineral	12	37.783	0.000	µg	2025-12-03 21:12:48.32532-08
1531	3	2025-12-03	mineral	13	48.578	0.000	µg	2025-12-03 21:12:48.326117-08
1532	3	2025-12-03	mineral	9	1.943	0.000	mg	2025-12-03 21:12:48.326865-08
1533	3	2025-12-03	mineral	1	1079.500	0.000	mg	2025-12-03 21:12:48.327521-08
1534	3	2025-12-03	mineral	8	971.550	0.000	mg	2025-12-03 21:12:48.328344-08
1535	3	2025-12-03	mineral	5	1619.250	0.000	mg	2025-12-03 21:12:48.329531-08
1536	3	2025-12-03	amino_acid	5	995.400	0.000	mg	2025-12-03 21:12:48.330259-08
1537	3	2025-12-03	amino_acid	3	929.040	0.000	mg	2025-12-03 21:12:48.331016-08
1538	3	2025-12-03	amino_acid	2	1659.000	0.000	mg	2025-12-03 21:12:48.331731-08
1539	3	2025-12-03	amino_acid	6	1725.360	0.000	mg	2025-12-03 21:12:48.332902-08
1540	3	2025-12-03	amino_acid	8	995.400	0.000	mg	2025-12-03 21:12:48.3341-08
1541	3	2025-12-03	amino_acid	1	1260.840	0.000	mg	2025-12-03 21:12:48.335616-08
1542	3	2025-12-03	amino_acid	9	2787.120	0.000	mg	2025-12-03 21:12:48.336552-08
1543	3	2025-12-03	amino_acid	7	265.440	0.000	mg	2025-12-03 21:12:48.337258-08
1544	3	2025-12-03	amino_acid	4	1990.800	0.000	mg	2025-12-03 21:12:48.337808-08
1545	3	2025-12-03	fiber	1	10.530	0.000	g	2025-12-03 21:12:48.338368-08
1546	3	2025-12-03	fiber	2	3.159	0.000	g	2025-12-03 21:12:48.339038-08
1547	3	2025-12-03	fiber	5	15.795	0.000	g	2025-12-03 21:12:48.339804-08
1548	3	2025-12-03	fiber	6	26.325	0.000	g	2025-12-03 21:12:48.340436-08
1549	3	2025-12-03	fiber	7	7.371	0.000	g	2025-12-03 21:12:48.341135-08
1550	3	2025-12-03	fatty_acid	1	0.000	0.000	g	2025-12-03 21:12:48.344975-08
1551	3	2025-12-03	fatty_acid	2	0.000	0.000	g	2025-12-03 21:12:48.345773-08
1552	3	2025-12-03	fatty_acid	3	0.000	0.000	g	2025-12-03 21:12:48.346434-08
1553	3	2025-12-03	fatty_acid	4	263.000	0.000	g	2025-12-03 21:12:48.347182-08
1554	3	2025-12-03	fatty_acid	5	15.510	0.000	g	2025-12-03 21:12:48.347776-08
1555	3	2025-12-03	fatty_acid	6	316.000	0.000	mg	2025-12-03 21:12:48.348715-08
1556	3	2025-12-03	fatty_acid	7	93.059	0.000	g	2025-12-03 21:12:48.349716-08
1557	3	2025-12-03	fatty_acid	15	23.265	0.000	g	2025-12-03 21:12:48.350692-08
1558	3	2025-12-03	fatty_acid	16	3.102	0.000	g	2025-12-03 21:12:48.351456-08
1559	3	2025-12-03	fatty_acid	17	38.775	0.000	g	2025-12-03 21:12:48.352185-08
1560	3	2025-12-03	fatty_acid	18	31.020	0.000	g	2025-12-03 21:12:48.352781-08
1580	3	2025-12-04	mineral	11	59.373	4400.000	µg	2025-12-03 23:22:26.935884-08
1581	3	2025-12-04	mineral	6	19.431	1497.960	mg	2025-12-03 23:22:26.936323-08
1582	3	2025-12-04	mineral	12	37.783	2876.000	µg	2025-12-03 23:22:26.936905-08
1583	3	2025-12-04	mineral	13	48.578	4050.000	µg	2025-12-03 23:22:26.93739-08
1607	3	2025-12-04	fatty_acid	6	316.000	0.000	mg	2025-12-03 23:22:26.9549-08
1608	3	2025-12-04	fatty_acid	7	93.059	734.000	g	2025-12-03 23:22:26.955514-08
1609	3	2025-12-04	fatty_acid	15	23.265	238.000	g	2025-12-03 23:22:26.956326-08
1610	3	2025-12-04	fatty_acid	16	3.102	0.000	g	2025-12-03 23:22:26.957005-08
1561	3	2025-12-04	vitamin	1	792.750	81000.000	µg	2025-12-03 23:22:26.921563-08
1584	3	2025-12-04	mineral	9	1.943	189.000	mg	2025-12-03 23:22:26.937996-08
1585	3	2025-12-04	mineral	1	1079.500	82172.000	mg	2025-12-03 23:22:26.938606-08
1586	3	2025-12-04	mineral	8	971.550	73.900	mg	2025-12-03 23:22:26.939193-08
1587	3	2025-12-04	mineral	5	1619.250	186080.000	mg	2025-12-03 23:22:26.939822-08
1588	3	2025-12-04	amino_acid	5	995.400	12.000	mg	2025-12-03 23:22:26.940314-08
1589	3	2025-12-04	amino_acid	3	929.040	11.200	mg	2025-12-03 23:22:26.940895-08
1590	3	2025-12-04	amino_acid	2	1659.000	20.000	mg	2025-12-03 23:22:26.941497-08
1591	3	2025-12-04	amino_acid	6	1725.360	20.800	mg	2025-12-03 23:22:26.942087-08
1592	3	2025-12-04	amino_acid	8	995.400	12.000	mg	2025-12-03 23:22:26.942669-08
1593	3	2025-12-04	amino_acid	1	1260.840	15.200	mg	2025-12-03 23:22:26.943379-08
1594	3	2025-12-04	amino_acid	9	2787.120	33.600	mg	2025-12-03 23:22:26.944025-08
1595	3	2025-12-04	amino_acid	7	265.440	3.200	mg	2025-12-03 23:22:26.944763-08
1596	3	2025-12-04	amino_acid	4	1990.800	24.000	mg	2025-12-03 23:22:26.945517-08
1597	3	2025-12-04	fiber	1	10.530	0.000	g	2025-12-03 23:22:26.94703-08
1598	3	2025-12-04	fiber	2	3.159	0.000	g	2025-12-03 23:22:26.94768-08
1599	3	2025-12-04	fiber	5	15.795	0.000	g	2025-12-03 23:22:26.94825-08
1600	3	2025-12-04	fiber	6	26.325	3760.000	g	2025-12-03 23:22:26.948957-08
1601	3	2025-12-04	fiber	7	7.371	0.000	g	2025-12-03 23:22:26.949571-08
1602	3	2025-12-04	fatty_acid	1	0.000	0.000	g	2025-12-03 23:22:26.950201-08
1603	3	2025-12-04	fatty_acid	2	0.000	0.000	g	2025-12-03 23:22:26.950943-08
1604	3	2025-12-04	fatty_acid	3	0.000	0.000	g	2025-12-03 23:22:26.951865-08
1605	3	2025-12-04	fatty_acid	4	263.000	32000.000	g	2025-12-03 23:22:26.953409-08
1606	3	2025-12-04	fatty_acid	5	15.510	0.000	g	2025-12-03 23:22:26.954227-08
1611	3	2025-12-04	fatty_acid	17	38.775	222.000	g	2025-12-03 23:22:26.957737-08
1612	3	2025-12-04	fatty_acid	18	31.020	0.000	g	2025-12-03 23:22:26.958785-08
1821	1	2025-12-05	vitamin	7	1.385	117.000	mg	2025-12-05 00:06:26.415062-08
1822	1	2025-12-05	vitamin	11	31.950	2510.000	µg	2025-12-05 00:06:26.422621-08
1823	1	2025-12-05	vitamin	3	15.975	1200.000	mg	2025-12-05 00:06:26.423759-08
1824	1	2025-12-05	vitamin	1	958.500	81000.000	µg	2025-12-05 00:06:26.425526-08
1825	1	2025-12-05	vitamin	10	1.385	109.000	mg	2025-12-05 00:06:26.426522-08
1826	1	2025-12-05	vitamin	5	95.850	7200.000	mg	2025-12-05 00:06:26.428822-08
1827	1	2025-12-05	vitamin	12	426.000	33440.000	µg	2025-12-05 00:06:26.429816-08
1828	1	2025-12-05	vitamin	9	5.325	418.000	mg	2025-12-05 00:06:26.432167-08
1829	1	2025-12-05	vitamin	2	639.000	8000.000	IU	2025-12-05 00:06:26.433108-08
1830	1	2025-12-05	vitamin	4	127.800	10800.000	µg	2025-12-05 00:06:26.43452-08
1831	1	2025-12-05	vitamin	8	17.040	1280.000	mg	2025-12-05 00:06:26.435906-08
1832	1	2025-12-05	vitamin	13	2.556	201.000	µg	2025-12-05 00:06:26.439527-08
1833	1	2025-12-05	vitamin	6	1.278	100.000	mg	2025-12-05 00:06:26.440887-08
1834	1	2025-12-05	mineral	1	1047.000	82160.000	mg	2025-12-05 00:06:26.441798-08
1835	1	2025-12-05	mineral	9	2.408	189.000	mg	2025-12-05 00:06:26.442752-08
1836	1	2025-12-05	mineral	10	157.050	13500.000	µg	2025-12-05 00:06:26.443636-08
1837	1	2025-12-05	mineral	8	942.300	73.900	mg	2025-12-05 00:06:26.444716-08
1838	1	2025-12-05	mineral	14	3.141	246.000	mg	2025-12-05 00:06:26.445678-08
1839	1	2025-12-05	mineral	13	47.115	4050.000	µg	2025-12-05 00:06:26.446548-08
1840	1	2025-12-05	mineral	5	1570.500	184000.000	mg	2025-12-05 00:06:26.447361-08
1841	1	2025-12-05	mineral	6	8.376	1479.000	mg	2025-12-05 00:06:26.448269-08
1562	3	2025-12-04	vitamin	7	1.246	117.000	mg	2025-12-03 23:22:26.923668-08
1563	3	2025-12-04	vitamin	6	1.246	100.000	mg	2025-12-03 23:22:26.924528-08
1564	3	2025-12-04	vitamin	13	2.718	400.440	µg	2025-12-03 23:22:26.92561-08
1565	3	2025-12-04	vitamin	9	5.663	418.000	mg	2025-12-03 23:22:26.926379-08
1566	3	2025-12-04	vitamin	3	16.988	1200.000	mg	2025-12-03 23:22:26.926958-08
1567	3	2025-12-04	vitamin	10	1.472	109.000	mg	2025-12-03 23:22:26.927552-08
1568	3	2025-12-04	vitamin	8	15.855	1280.000	mg	2025-12-03 23:22:26.928182-08
1569	3	2025-12-04	vitamin	11	33.975	2510.000	µg	2025-12-03 23:22:26.928785-08
1570	3	2025-12-04	vitamin	2	679.500	8000.000	IU	2025-12-03 23:22:26.929615-08
1571	3	2025-12-04	vitamin	4	101.925	10800.000	µg	2025-12-03 23:22:26.930242-08
1572	3	2025-12-04	vitamin	5	84.938	7200.000	mg	2025-12-03 23:22:26.930733-08
1573	3	2025-12-04	vitamin	12	453.000	33440.000	µg	2025-12-03 23:22:26.931214-08
1574	3	2025-12-04	mineral	14	3.239	246.000	mg	2025-12-03 23:22:26.931675-08
1575	3	2025-12-04	mineral	2	755.650	56000.000	mg	2025-12-03 23:22:26.932473-08
1576	3	2025-12-04	mineral	7	8.636	999.600	mg	2025-12-03 23:22:26.933224-08
1577	3	2025-12-04	mineral	4	2806.700	280000.000	mg	2025-12-03 23:22:26.934009-08
1578	3	2025-12-04	mineral	3	334.645	25470.000	mg	2025-12-03 23:22:26.934729-08
1579	3	2025-12-04	mineral	10	161.925	13500.000	µg	2025-12-03 23:22:26.935306-08
1842	1	2025-12-05	mineral	3	418.800	25470.000	mg	2025-12-05 00:06:26.449185-08
1843	1	2025-12-05	mineral	12	36.645	2876.000	µg	2025-12-05 00:06:26.450367-08
1844	1	2025-12-05	mineral	7	11.517	990.000	mg	2025-12-05 00:06:26.460418-08
1845	1	2025-12-05	mineral	11	57.585	4400.000	µg	2025-12-05 00:06:26.461538-08
1846	1	2025-12-05	mineral	2	732.900	56000.000	mg	2025-12-05 00:06:26.462657-08
1847	1	2025-12-05	mineral	4	3559.800	280000.000	mg	2025-12-05 00:06:26.463532-08
1848	1	2025-12-05	amino_acid	9	2661.120	33.600	mg	2025-12-05 00:06:26.464358-08
1849	1	2025-12-05	amino_acid	7	253.440	3.200	mg	2025-12-05 00:06:26.465111-08
1850	1	2025-12-05	amino_acid	6	1647.360	20.800	mg	2025-12-05 00:06:26.465814-08
1851	1	2025-12-05	amino_acid	8	950.400	12.000	mg	2025-12-05 00:06:26.466744-08
1852	1	2025-12-05	amino_acid	4	1900.800	24.000	mg	2025-12-05 00:06:26.469981-08
1853	1	2025-12-05	amino_acid	2	1584.000	20.000	mg	2025-12-05 00:06:26.477755-08
1854	1	2025-12-05	amino_acid	3	887.040	11.200	mg	2025-12-05 00:06:26.478784-08
1855	1	2025-12-05	amino_acid	5	950.400	12.000	mg	2025-12-05 00:06:26.479615-08
1856	1	2025-12-05	amino_acid	1	1203.840	15.200	mg	2025-12-05 00:06:26.48042-08
1857	1	2025-12-05	fiber	1	10.380	0.000	g	2025-12-05 00:06:26.481224-08
1858	1	2025-12-05	fiber	2	3.114	0.000	g	2025-12-05 00:06:26.482014-08
1859	1	2025-12-05	fiber	5	15.570	0.000	g	2025-12-05 00:06:26.48281-08
1860	1	2025-12-05	fiber	6	25.950	3760.000	g	2025-12-05 00:06:26.483662-08
1861	1	2025-12-05	fiber	7	7.266	0.000	g	2025-12-05 00:06:26.484433-08
1862	1	2025-12-05	fatty_acid	1	0.000	0.000	g	2025-12-05 00:06:26.485454-08
1863	1	2025-12-05	fatty_acid	2	0.000	0.000	g	2025-12-05 00:06:26.489054-08
1864	1	2025-12-05	fatty_acid	3	0.000	0.000	g	2025-12-05 00:06:26.490472-08
1865	1	2025-12-05	fatty_acid	4	363.000	32000.000	g	2025-12-05 00:06:26.491533-08
1866	1	2025-12-05	fatty_acid	5	13.892	0.000	g	2025-12-05 00:06:26.492375-08
1867	1	2025-12-05	fatty_acid	6	311.000	0.000	mg	2025-12-05 00:06:26.493172-08
1868	1	2025-12-05	fatty_acid	7	83.351	700.000	g	2025-12-05 00:06:26.494025-08
1869	1	2025-12-05	fatty_acid	15	20.838	238.000	g	2025-12-05 00:06:26.494861-08
1870	1	2025-12-05	fatty_acid	16	2.778	0.000	g	2025-12-05 00:06:26.495624-08
1871	1	2025-12-05	fatty_acid	17	34.730	222.000	g	2025-12-05 00:06:26.49665-08
1872	1	2025-12-05	fatty_acid	18	27.784	0.000	g	2025-12-05 00:06:26.498039-08
\.


--
-- TOC entry 6502 (class 0 OID 21107)
-- Dependencies: 221
-- Data for Name: userprofile; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.userprofile (user_id, activity_level, diet_type, allergies, health_goals, goal_type, goal_weight, activity_factor, bmr, tdee, daily_calorie_target, daily_protein_target, daily_fat_target, daily_carb_target, daily_water_target, today_calories, today_protein, today_fat, today_carbs) FROM stdin;
2	vận động nhẹ	chay	Sữa bò	Duy trì	\N	42.00	1.38	1164.00	1601.00	1601.00	100.00	44.00	200.00	1638.80	0.00	0.00	0.00	0.00
1	vận động nhẹ	clean	Sữa bò	Duy trì	\N	60.00	1.38	1593.00	2190.00	2190.00	137.00	61.00	274.00	2244.00	0.00	0.00	0.00	0.00
3	rất năng động	clean	Sữa bò	Duy trì	\N	60.00	1.73	1464.00	2525.00	2525.00	158.00	70.00	316.00	2684.00	0.00	0.00	0.00	0.00
4	vận động nhẹ	keto	\N	Duy trì	\N	60.00	1.38	1459.00	2006.00	2006.00	125.00	56.00	251.00	2060.00	0.00	0.00	0.00	0.00
\.


--
-- TOC entry 6615 (class 0 OID 22559)
-- Dependencies: 340
-- Data for Name: usersecurity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usersecurity (user_id, twofa_enabled, twofa_secret, lock_threshold, failed_attempts, updated_at) FROM stdin;
3	f	\N	5	0	2025-11-24 05:24:16.617351-08
4	f	\N	5	0	2025-11-27 04:52:30.283885-08
1	f	\N	5	0	2025-11-19 07:19:23.784325-08
2	f	\N	5	0	2025-11-23 20:43:44.66746-08
\.


--
-- TOC entry 6503 (class 0 OID 21120)
-- Dependencies: 222
-- Data for Name: usersetting; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usersetting (user_id, theme, language, font_size, unit_system, seasonal_ui_enabled, seasonal_mode, seasonal_custom_bg, falling_leaves_enabled, weather_enabled, weather_city, weather_last_update, weather_last_data, background_image_url, calorie_multiplier, macro_protein_pct, macro_fat_pct, macro_carb_pct, wind_direction, weather_effects_enabled, effect_intensity, meal_pct_breakfast, meal_pct_lunch, meal_pct_snack, meal_pct_dinner, background_image_enabled, meal_time_breakfast, meal_time_lunch, meal_time_snack, meal_time_dinner) FROM stdin;
2	light	vi	medium	metric	f	auto	\N	t	f	\N	\N	\N	\N	\N	\N	\N	\N	0	t	medium	25.00	35.00	10.00	30.00	f	07:00:00	11:00:00	13:00:00	18:00:00
1	light	vi	medium	metric	f	auto	\N	f	f	Cà Mau	2025-11-21 08:53:34.988	{"dt": 1763689835, "id": 1586443, "cod": 200, "sys": {"sunset": 1763721335, "country": "VN", "sunrise": 1763679313}, "base": "stations", "main": {"temp": 24.68, "humidity": 81, "pressure": 1013, "temp_max": 24.68, "temp_min": 24.68, "sea_level": 1013, "feels_like": 25.32, "grnd_level": 1013}, "name": "Ca Mau", "wind": {"deg": 28, "gust": 8.01, "speed": 4}, "coord": {"lat": 9.1792, "lon": 105.1458}, "clouds": {"all": 100}, "weather": [{"id": 804, "icon": "04d", "main": "Clouds", "description": "mây đen u ám"}], "timezone": 25200, "visibility": 10000}	\N	\N	\N	\N	\N	0	f	medium	25.00	35.00	10.00	30.00	f	07:00:00	11:00:00	13:00:00	18:00:00
4	light	vi	medium	metric	f	auto	\N	t	f	\N	\N	\N	\N	\N	\N	\N	\N	0	t	medium	25.00	35.00	10.00	30.00	f	07:00:00	11:00:00	13:00:00	18:00:00
3	light	vi	medium	metric	f	auto	\N	f	f	Cà Mau	2025-11-29 16:37:16.806	{"dt": 1764408921, "id": 1586443, "cod": 200, "sys": {"sunset": 1764412614, "country": "VN", "sunrise": 1764370727}, "base": "stations", "main": {"temp": 26.26, "humidity": 67, "pressure": 1008, "temp_max": 26.26, "temp_min": 26.26, "sea_level": 1008, "feels_like": 26.26, "grnd_level": 1008}, "name": "Ca Mau", "wind": {"deg": 307, "gust": 5.99, "speed": 3.27}, "coord": {"lat": 9.1792, "lon": 105.1458}, "clouds": {"all": 85}, "weather": [{"id": 804, "icon": "04d", "main": "Clouds", "description": "mây đen u ám"}], "timezone": 25200, "visibility": 10000}	\N	\N	\N	\N	\N	0	f	low	25.00	35.00	10.00	30.00	f	07:00:00	11:00:00	13:00:00	18:00:00
\.


--
-- TOC entry 6534 (class 0 OID 21499)
-- Dependencies: 253
-- Data for Name: uservitaminrequirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.uservitaminrequirement (user_id, vitamin_id, base, multiplier, recommended, unit, updated_at) FROM stdin;
4	1	700.000	1.0450	731.500	µg	2025-12-04 06:34:12.534108
4	2	600.000	1.0450	627.000	IU	2025-12-04 06:34:12.534108
4	3	15.000	1.0450	15.675	mg	2025-12-04 06:34:12.534108
4	4	90.000	1.0450	94.050	µg	2025-12-04 06:34:12.534108
4	5	75.000	1.0450	78.375	mg	2025-12-04 06:34:12.534108
4	6	1.100	1.0450	1.150	mg	2025-12-04 06:34:12.534108
4	7	1.100	1.0450	1.150	mg	2025-12-04 06:34:12.534108
4	8	14.000	1.0450	14.630	mg	2025-12-04 06:34:12.534108
4	9	5.000	1.0450	5.225	mg	2025-12-04 06:34:12.534108
4	10	1.300	1.0450	1.359	mg	2025-12-04 06:34:12.534108
4	11	30.000	1.0450	31.350	µg	2025-12-04 06:34:12.534108
4	12	400.000	1.0450	418.000	µg	2025-12-04 06:34:12.534108
4	13	2.400	1.0450	2.508	µg	2025-12-04 06:34:12.534108
2	1	700.000	1.0450	731.500	µg	2025-11-23 20:44:04.63164
2	2	600.000	1.0450	627.000	IU	2025-11-23 20:44:04.63164
2	3	15.000	1.0450	15.675	mg	2025-11-23 20:44:04.63164
2	4	90.000	1.0450	94.050	µg	2025-11-23 20:44:04.63164
2	5	75.000	1.0450	78.375	mg	2025-11-23 20:44:04.63164
2	6	1.100	1.0450	1.150	mg	2025-11-23 20:44:04.63164
2	7	1.100	1.0450	1.150	mg	2025-11-23 20:44:04.63164
2	8	14.000	1.0450	14.630	mg	2025-11-23 20:44:04.63164
2	9	5.000	1.0450	5.225	mg	2025-11-23 20:44:04.63164
2	10	1.300	1.0450	1.359	mg	2025-11-23 20:44:04.63164
2	11	30.000	1.0450	31.350	µg	2025-11-23 20:44:04.63164
2	12	400.000	1.0450	418.000	µg	2025-11-23 20:44:04.63164
2	13	2.400	1.0450	2.508	µg	2025-11-23 20:44:04.63164
3	1	700.000	1.1325	792.750	µg	2025-11-29 01:32:36.387799
3	2	600.000	1.1325	679.500	IU	2025-11-29 01:32:36.387799
3	3	15.000	1.1325	16.988	mg	2025-11-29 01:32:36.387799
3	4	90.000	1.1325	101.925	µg	2025-11-29 01:32:36.387799
3	5	75.000	1.1325	84.938	mg	2025-11-29 01:32:36.387799
3	6	1.100	1.1325	1.246	mg	2025-11-29 01:32:36.387799
3	7	1.100	1.1325	1.246	mg	2025-11-29 01:32:36.387799
3	8	14.000	1.1325	15.855	mg	2025-11-29 01:32:36.387799
3	9	5.000	1.1325	5.663	mg	2025-11-29 01:32:36.387799
3	10	1.300	1.1325	1.472	mg	2025-11-29 01:32:36.387799
3	11	30.000	1.1325	33.975	µg	2025-11-29 01:32:36.387799
3	12	400.000	1.1325	453.000	µg	2025-11-29 01:32:36.387799
3	13	2.400	1.1325	2.718	µg	2025-11-29 01:32:36.387799
1	1	900.000	1.0650	958.500	µg	2025-11-24 22:52:15.990562
1	2	600.000	1.0650	639.000	IU	2025-11-24 22:52:15.990562
1	3	15.000	1.0650	15.975	mg	2025-11-24 22:52:15.990562
1	4	120.000	1.0650	127.800	µg	2025-11-24 22:52:15.990562
1	5	90.000	1.0650	95.850	mg	2025-11-24 22:52:15.990562
1	6	1.200	1.0650	1.278	mg	2025-11-24 22:52:15.990562
1	7	1.300	1.0650	1.385	mg	2025-11-24 22:52:15.990562
1	8	16.000	1.0650	17.040	mg	2025-11-24 22:52:15.990562
1	9	5.000	1.0650	5.325	mg	2025-11-24 22:52:15.990562
1	10	1.300	1.0650	1.385	mg	2025-11-24 22:52:15.990562
1	11	30.000	1.0650	31.950	µg	2025-11-24 22:52:15.990562
1	12	400.000	1.0650	426.000	µg	2025-11-24 22:52:15.990562
1	13	2.400	1.0650	2.556	µg	2025-11-24 22:52:15.990562
\.


--
-- TOC entry 6533 (class 0 OID 21475)
-- Dependencies: 252
-- Data for Name: vitamin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vitamin (vitamin_id, code, name, description, unit, recommended_daily, created_at, created_by_admin) FROM stdin;
1	VITA	Vitamin A	Retinol and provitamin A compounds	µg	700.000	2025-11-19 06:57:52.829613	\N
2	VITD	Vitamin D	Supports calcium metabolism and bone health	IU	600.000	2025-11-19 06:57:52.829613	\N
3	VITE	Vitamin E	Antioxidant (tocopherols)	mg	15.000	2025-11-19 06:57:52.829613	\N
4	VITK	Vitamin K	Needed for blood clotting (K1/K2)	µg	120.000	2025-11-19 06:57:52.829613	\N
5	VITC	Vitamin C	Ascorbic acid, antioxidant	mg	75.000	2025-11-19 06:57:52.829613	\N
6	VITB1	Vitamin B1 (Thiamine)	Supports energy metabolism	mg	1.200	2025-11-19 06:57:52.829613	\N
7	VITB2	Vitamin B2 (Riboflavin)	Important for energy production	mg	1.300	2025-11-19 06:57:52.829613	\N
8	VITB3	Vitamin B3 (Niacin)	Supports metabolism and skin health	mg	16.000	2025-11-19 06:57:52.829613	\N
9	VITB5	Vitamin B5 (Pantothenic acid)	Component of coenzyme A	mg	5.000	2025-11-19 06:57:52.829613	\N
10	VITB6	Vitamin B6 (Pyridoxine)	Supports metabolism and brain health	mg	1.300	2025-11-19 06:57:52.829613	\N
11	VITB7	Vitamin B7 (Biotin)	Plays a role in macronutrient metabolism	µg	30.000	2025-11-19 06:57:52.829613	\N
12	VITB9	Vitamin B9 (Folate)	Key for cell division and DNA synthesis	µg	400.000	2025-11-19 06:57:52.829613	\N
13	VITB12	Vitamin B12 (Cobalamin)	Important for nerve function and blood formation	µg	2.400	2025-11-19 06:57:52.829613	\N
\.


--
-- TOC entry 6644 (class 0 OID 23123)
-- Dependencies: 373
-- Data for Name: vitaminnutrient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vitaminnutrient (vitamin_nutrient_id, vitamin_id, nutrient_id, amount, factor, notes, created_at) FROM stdin;
1	2	12	0.000	1.000000	USDA VITD -> Vitamin D	2025-11-19 17:30:55.588284
2	3	13	0.000	1.000000	USDA VITE -> Vitamin E	2025-11-19 17:30:55.588284
3	4	14	0.000	1.000000	USDA VITK -> Vitamin K	2025-11-19 17:30:55.588284
4	5	15	0.000	1.000000	USDA VITC -> Vitamin C	2025-11-19 17:30:55.588284
5	6	16	0.000	1.000000	USDA VITB1 -> Vitamin B1	2025-11-19 17:30:55.588284
6	7	17	0.000	1.000000	USDA VITB2 -> Vitamin B2	2025-11-19 17:30:55.588284
7	8	18	0.000	1.000000	USDA VITB3 -> Vitamin B3	2025-11-19 17:30:55.588284
8	9	19	0.000	1.000000	USDA VITB5 -> Vitamin B5	2025-11-19 17:30:55.588284
9	10	20	0.000	1.000000	USDA VITB6 -> Vitamin B6	2025-11-19 17:30:55.588284
10	11	21	0.000	1.000000	USDA VITB7 -> Vitamin B7	2025-11-19 17:30:55.588284
11	13	23	0.000	1.000000	USDA VITB12 -> Vitamin B12	2025-11-19 17:30:55.588284
12	1	11	0.000	1.000000	Auto-mapped: VITA -> VITA	2025-11-19 17:31:39.643042
37	12	22	0.000	1.000000	Auto-mapped: VITB9 -> VITB9	2025-11-19 17:31:39.666002
\.


--
-- TOC entry 6536 (class 0 OID 21526)
-- Dependencies: 255
-- Data for Name: vitaminrda; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vitaminrda (vitamin_rda_id, vitamin_id, sex, age_min, age_max, rda_value, unit, notes) FROM stdin;
1	1	\N	0	0	400.000	µg	Adequate Intake (AI) for infants 0-6 months
2	1	\N	1	1	500.000	µg	AI for infants 7-12 months
3	1	\N	1	3	300.000	µg	RDA for children 1-3 years
4	1	\N	4	8	400.000	µg	RDA for children 4-8 years
5	1	male	9	13	600.000	µg	RDA for males 9-13 years
6	1	male	14	18	900.000	µg	RDA for males 14-18 years
7	1	male	19	50	900.000	µg	RDA for adult males
8	1	male	51	120	900.000	µg	RDA for males 51+ years
9	1	female	9	13	600.000	µg	RDA for females 9-13 years
10	1	female	14	18	700.000	µg	RDA for females 14-18 years
11	1	female	19	50	700.000	µg	RDA for adult females
12	1	female	51	120	700.000	µg	RDA for females 51+ years
13	2	\N	0	1	400.000	IU	AI for infants
14	2	\N	1	18	600.000	IU	RDA for children and adolescents
15	2	\N	19	70	600.000	IU	RDA for adults
16	2	\N	71	120	800.000	IU	RDA for elderly
17	3	\N	0	0	4.000	mg	AI for infants 0-6 months
18	3	\N	1	1	5.000	mg	AI for infants 7-12 months
19	3	\N	1	3	6.000	mg	RDA for children 1-3 years
20	3	\N	4	8	7.000	mg	RDA for children 4-8 years
21	3	\N	9	18	11.000	mg	RDA for adolescents
22	3	\N	19	120	15.000	mg	RDA for adults
23	4	\N	0	0	2.000	µg	AI for infants 0-6 months
24	4	\N	1	1	2.500	µg	AI for infants 7-12 months
25	4	\N	1	3	30.000	µg	AI for children 1-3 years
26	4	\N	4	8	55.000	µg	AI for children 4-8 years
27	4	male	9	13	60.000	µg	AI for males 9-13 years
28	4	male	14	18	75.000	µg	AI for males 14-18 years
29	4	male	19	120	120.000	µg	AI for adult males
30	4	female	9	13	60.000	µg	AI for females 9-13 years
31	4	female	14	18	75.000	µg	AI for females 14-18 years
32	4	female	19	120	90.000	µg	AI for adult females
33	5	\N	0	0	40.000	mg	AI for infants 0-6 months
34	5	\N	1	1	50.000	mg	AI for infants 7-12 months
35	5	\N	1	3	15.000	mg	RDA for children 1-3 years
36	5	\N	4	8	25.000	mg	RDA for children 4-8 years
37	5	\N	9	13	45.000	mg	RDA for children 9-13 years
38	5	male	14	18	75.000	mg	RDA for males 14-18 years
39	5	male	19	120	90.000	mg	RDA for adult males
40	5	female	14	18	65.000	mg	RDA for females 14-18 years
41	5	female	19	120	75.000	mg	RDA for adult females
42	6	male	19	120	1.200	mg	RDA for adult males
43	6	female	19	120	1.100	mg	RDA for adult females
44	7	male	19	120	1.300	mg	RDA for adult males
45	7	female	19	120	1.100	mg	RDA for adult females
46	8	male	19	120	16.000	mg	RDA for adult males
47	8	female	19	120	14.000	mg	RDA for adult females
48	10	male	19	50	1.300	mg	RDA for adult males 19-50
49	10	male	51	120	1.700	mg	RDA for males 51+
50	10	female	19	50	1.300	mg	RDA for adult females 19-50
51	10	female	51	120	1.500	mg	RDA for females 51+
52	12	\N	19	120	400.000	µg	RDA for adults
53	13	\N	19	120	2.400	µg	RDA for adults
107	1	any	19	50	700.000	µg	\N
108	2	any	19	50	600.000	IU	\N
109	3	any	19	50	15.000	mg	\N
110	4	any	19	50	120.000	µg	\N
111	5	any	19	50	75.000	mg	\N
112	6	any	19	50	1.200	mg	\N
113	7	any	19	50	1.300	mg	\N
114	8	any	19	50	16.000	mg	\N
115	9	any	19	50	5.000	mg	\N
116	10	any	19	50	1.300	mg	\N
117	11	any	19	50	30.000	µg	\N
118	12	any	19	50	400.000	µg	\N
119	13	any	19	50	2.400	µg	\N
\.


--
-- TOC entry 6638 (class 0 OID 22922)
-- Dependencies: 367
-- Data for Name: waterlog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.waterlog (water_log_id, user_id, amount_ml, log_date, created_at, drink_id, drink_name, hydration_ratio, notes) FROM stdin;
26	3	500	2025-12-03	2025-12-03 22:30:51.58499	\N	Nước lọc	1.00	\N
27	3	500	2025-12-03	2025-12-03 23:23:11.878122	\N	Nước lọc	1.00	\N
28	3	500	2025-12-04	2025-12-04 00:09:17.61489	\N	Nước lọc	1.00	\N
29	3	500	2025-12-04	2025-12-04 00:15:43.072139	\N	Nước lọc	1.00	\N
30	3	500	2025-12-04	2025-12-04 00:15:48.925759	\N	Nước lọc	1.00	\N
31	3	500	2025-12-04	2025-12-04 00:43:01.817406	\N	Nước lọc	1.00	\N
32	3	500	2025-12-04	2025-12-04 00:52:42.630524	\N	Nước lọc	1.00	\N
33	4	500	2025-12-04	2025-12-04 06:03:05.450149	\N	Nước lọc	1.00	\N
34	4	500	2025-12-04	2025-12-04 06:03:11.568318	\N	Nước lọc	1.00	\N
35	1	550	2025-12-04	2025-12-04 18:08:52.312987	\N	Nước lọc	1.00	\N
36	1	500	2025-12-04	2025-12-04 18:24:25.696707	\N	Nước lọc	1.00	\N
37	1	300	2025-12-04	2025-12-04 18:34:29.190217	\N	Nước lọc	1.00	\N
\.


--
-- TOC entry 6856 (class 0 OID 0)
-- Dependencies: 219
-- Name: User_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."User_user_id_seq"', 4, true);


--
-- TOC entry 6857 (class 0 OID 0)
-- Dependencies: 225
-- Name: admin_admin_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_admin_id_seq', 2, true);


--
-- TOC entry 6858 (class 0 OID 0)
-- Dependencies: 365
-- Name: admin_verification_verification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_verification_verification_id_seq', 2, true);


--
-- TOC entry 6859 (class 0 OID 0)
-- Dependencies: 304
-- Name: adminconversation_admin_conversation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adminconversation_admin_conversation_id_seq', 4, true);


--
-- TOC entry 6860 (class 0 OID 0)
-- Dependencies: 306
-- Name: adminmessage_admin_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adminmessage_admin_message_id_seq', 9, true);


--
-- TOC entry 6861 (class 0 OID 0)
-- Dependencies: 277
-- Name: aminoacid_amino_acid_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.aminoacid_amino_acid_id_seq', 9, true);


--
-- TOC entry 6862 (class 0 OID 0)
-- Dependencies: 279
-- Name: aminorequirement_amino_requirement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.aminorequirement_amino_requirement_id_seq', 54, true);


--
-- TOC entry 6863 (class 0 OID 0)
-- Dependencies: 298
-- Name: bodymeasurement_measurement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bodymeasurement_measurement_id_seq', 7, true);


--
-- TOC entry 6864 (class 0 OID 0)
-- Dependencies: 300
-- Name: chatbotconversation_conversation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chatbotconversation_conversation_id_seq', 4, true);


--
-- TOC entry 6865 (class 0 OID 0)
-- Dependencies: 302
-- Name: chatbotmessage_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chatbotmessage_message_id_seq', 8, true);


--
-- TOC entry 6866 (class 0 OID 0)
-- Dependencies: 397
-- Name: communitymessage_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.communitymessage_message_id_seq', 10, true);


--
-- TOC entry 6867 (class 0 OID 0)
-- Dependencies: 416
-- Name: conditiondishrecommendation_recommendation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conditiondishrecommendation_recommendation_id_seq', 182, true);


--
-- TOC entry 6868 (class 0 OID 0)
-- Dependencies: 326
-- Name: conditioneffectlog_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conditioneffectlog_log_id_seq', 1, false);


--
-- TOC entry 6869 (class 0 OID 0)
-- Dependencies: 324
-- Name: conditionfoodrecommendation_recommendation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conditionfoodrecommendation_recommendation_id_seq', 542, true);


--
-- TOC entry 6870 (class 0 OID 0)
-- Dependencies: 322
-- Name: conditionnutrienteffect_effect_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conditionnutrienteffect_effect_id_seq', 90, true);


--
-- TOC entry 6871 (class 0 OID 0)
-- Dependencies: 418
-- Name: daily_reset_history_reset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.daily_reset_history_reset_id_seq', 1, false);


--
-- TOC entry 6872 (class 0 OID 0)
-- Dependencies: 245
-- Name: dailysummary_summary_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dailysummary_summary_id_seq', 92, true);


--
-- TOC entry 6873 (class 0 OID 0)
-- Dependencies: 408
-- Name: dailysummaryhistory_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dailysummaryhistory_history_id_seq', 1, false);


--
-- TOC entry 6874 (class 0 OID 0)
-- Dependencies: 349
-- Name: dish_dish_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dish_dish_id_seq', 151, true);


--
-- TOC entry 6875 (class 0 OID 0)
-- Dependencies: 353
-- Name: dishimage_dish_image_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dishimage_dish_image_id_seq', 1, false);


--
-- TOC entry 6876 (class 0 OID 0)
-- Dependencies: 351
-- Name: dishingredient_dish_ingredient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dishingredient_dish_ingredient_id_seq', 776, true);


--
-- TOC entry 6877 (class 0 OID 0)
-- Dependencies: 361
-- Name: dishnotification_notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dishnotification_notification_id_seq', 2, true);


--
-- TOC entry 6878 (class 0 OID 0)
-- Dependencies: 357
-- Name: dishnutrient_dish_nutrient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dishnutrient_dish_nutrient_id_seq', 8026, true);


--
-- TOC entry 6879 (class 0 OID 0)
-- Dependencies: 355
-- Name: dishstatistics_stat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dishstatistics_stat_id_seq', 1, false);


--
-- TOC entry 6880 (class 0 OID 0)
-- Dependencies: 378
-- Name: drink_drink_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drink_drink_id_seq', 57, true);


--
-- TOC entry 6881 (class 0 OID 0)
-- Dependencies: 380
-- Name: drinkingredient_drink_ingredient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drinkingredient_drink_ingredient_id_seq', 138, true);


--
-- TOC entry 6882 (class 0 OID 0)
-- Dependencies: 382
-- Name: drinknutrient_drink_nutrient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drinknutrient_drink_nutrient_id_seq', 2396, true);


--
-- TOC entry 6883 (class 0 OID 0)
-- Dependencies: 384
-- Name: drinkstatistics_stat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drinkstatistics_stat_id_seq', 1, false);


--
-- TOC entry 6884 (class 0 OID 0)
-- Dependencies: 386
-- Name: drug_drug_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drug_drug_id_seq', 47, true);


--
-- TOC entry 6885 (class 0 OID 0)
-- Dependencies: 412
-- Name: drug_interaction_interaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drug_interaction_interaction_id_seq', 32, true);


--
-- TOC entry 6886 (class 0 OID 0)
-- Dependencies: 414
-- Name: drug_side_effect_side_effect_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drug_side_effect_side_effect_id_seq', 44, true);


--
-- TOC entry 6887 (class 0 OID 0)
-- Dependencies: 388
-- Name: drughealthcondition_drug_condition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drughealthcondition_drug_condition_id_seq', 294, true);


--
-- TOC entry 6888 (class 0 OID 0)
-- Dependencies: 390
-- Name: drugnutrientcontraindication_contra_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drugnutrientcontraindication_contra_id_seq', 205, true);


--
-- TOC entry 6889 (class 0 OID 0)
-- Dependencies: 263
-- Name: fattyacid_fatty_acid_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fattyacid_fatty_acid_id_seq', 18, true);


--
-- TOC entry 6890 (class 0 OID 0)
-- Dependencies: 267
-- Name: fattyacidrequirement_fa_req_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fattyacidrequirement_fa_req_id_seq', 8, true);


--
-- TOC entry 6891 (class 0 OID 0)
-- Dependencies: 261
-- Name: fiber_fiber_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fiber_fiber_id_seq', 7, true);


--
-- TOC entry 6892 (class 0 OID 0)
-- Dependencies: 265
-- Name: fiberrequirement_fiber_req_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fiberrequirement_fiber_req_id_seq', 15, true);


--
-- TOC entry 6893 (class 0 OID 0)
-- Dependencies: 230
-- Name: food_food_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.food_food_id_seq', 3115, true);


--
-- TOC entry 6894 (class 0 OID 0)
-- Dependencies: 312
-- Name: foodcategory_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.foodcategory_category_id_seq', 10, true);


--
-- TOC entry 6895 (class 0 OID 0)
-- Dependencies: 234
-- Name: foodnutrient_food_nutrient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.foodnutrient_food_nutrient_id_seq', 4452, true);


--
-- TOC entry 6896 (class 0 OID 0)
-- Dependencies: 236
-- Name: foodtag_tag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.foodtag_tag_id_seq', 1, false);


--
-- TOC entry 6897 (class 0 OID 0)
-- Dependencies: 393
-- Name: friendrequest_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.friendrequest_request_id_seq', 5, true);


--
-- TOC entry 6898 (class 0 OID 0)
-- Dependencies: 395
-- Name: friendship_friendship_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.friendship_friendship_id_seq', 3, true);


--
-- TOC entry 6899 (class 0 OID 0)
-- Dependencies: 314
-- Name: healthcondition_condition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.healthcondition_condition_id_seq', 1, false);


--
-- TOC entry 6900 (class 0 OID 0)
-- Dependencies: 286
-- Name: meal_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meal_entries_id_seq', 21, true);


--
-- TOC entry 6901 (class 0 OID 0)
-- Dependencies: 239
-- Name: meal_meal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meal_meal_id_seq', 28, true);


--
-- TOC entry 6902 (class 0 OID 0)
-- Dependencies: 241
-- Name: mealitem_meal_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mealitem_meal_item_id_seq', 46, true);


--
-- TOC entry 6903 (class 0 OID 0)
-- Dependencies: 243
-- Name: mealnote_note_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mealnote_note_id_seq', 1, false);


--
-- TOC entry 6904 (class 0 OID 0)
-- Dependencies: 334
-- Name: mealtemplate_template_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mealtemplate_template_id_seq', 1, false);


--
-- TOC entry 6905 (class 0 OID 0)
-- Dependencies: 336
-- Name: mealtemplateitem_template_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mealtemplateitem_template_item_id_seq', 1, false);


--
-- TOC entry 6906 (class 0 OID 0)
-- Dependencies: 320
-- Name: medicationlog_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.medicationlog_log_id_seq', 1, true);


--
-- TOC entry 6907 (class 0 OID 0)
-- Dependencies: 318
-- Name: medicationschedule_medication_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.medicationschedule_medication_id_seq', 2, true);


--
-- TOC entry 6908 (class 0 OID 0)
-- Dependencies: 399
-- Name: messagereaction_reaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.messagereaction_reaction_id_seq', 1, false);


--
-- TOC entry 6909 (class 0 OID 0)
-- Dependencies: 256
-- Name: mineral_mineral_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mineral_mineral_id_seq', 28, true);


--
-- TOC entry 6910 (class 0 OID 0)
-- Dependencies: 374
-- Name: mineralnutrient_mineral_nutrient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mineralnutrient_mineral_nutrient_id_seq', 44, true);


--
-- TOC entry 6911 (class 0 OID 0)
-- Dependencies: 258
-- Name: mineralrda_mineral_rda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mineralrda_mineral_rda_id_seq', 86, true);


--
-- TOC entry 6912 (class 0 OID 0)
-- Dependencies: 232
-- Name: nutrient_nutrient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nutrient_nutrient_id_seq', 77, true);


--
-- TOC entry 6913 (class 0 OID 0)
-- Dependencies: 290
-- Name: nutrientcontraindication_contra_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nutrientcontraindication_contra_id_seq', 1, false);


--
-- TOC entry 6914 (class 0 OID 0)
-- Dependencies: 410
-- Name: nutrienteffect_effect_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nutrienteffect_effect_id_seq', 17, true);


--
-- TOC entry 6915 (class 0 OID 0)
-- Dependencies: 275
-- Name: nutrientmapping_mapping_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nutrientmapping_mapping_id_seq', 10, true);


--
-- TOC entry 6916 (class 0 OID 0)
-- Dependencies: 308
-- Name: nutritionanalysis_analysis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nutritionanalysis_analysis_id_seq', 1, false);


--
-- TOC entry 6917 (class 0 OID 0)
-- Dependencies: 341
-- Name: passwordchangecode_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.passwordchangecode_id_seq', 1, false);


--
-- TOC entry 6918 (class 0 OID 0)
-- Dependencies: 368
-- Name: permission_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.permission_permission_id_seq', 27, true);


--
-- TOC entry 6919 (class 0 OID 0)
-- Dependencies: 328
-- Name: portionsize_portion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.portionsize_portion_id_seq', 71, true);


--
-- TOC entry 6920 (class 0 OID 0)
-- Dependencies: 401
-- Name: privateconversation_conversation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.privateconversation_conversation_id_seq', 3, true);


--
-- TOC entry 6921 (class 0 OID 0)
-- Dependencies: 403
-- Name: privatemessage_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.privatemessage_message_id_seq', 4, true);


--
-- TOC entry 6922 (class 0 OID 0)
-- Dependencies: 330
-- Name: recipe_recipe_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recipe_recipe_id_seq', 1, false);


--
-- TOC entry 6923 (class 0 OID 0)
-- Dependencies: 332
-- Name: recipeingredient_recipe_ingredient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recipeingredient_recipe_ingredient_id_seq', 30, true);


--
-- TOC entry 6924 (class 0 OID 0)
-- Dependencies: 227
-- Name: role_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.role_role_id_seq', 7, true);


--
-- TOC entry 6925 (class 0 OID 0)
-- Dependencies: 370
-- Name: rolepermission_role_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolepermission_role_permission_id_seq', 75, true);


--
-- TOC entry 6926 (class 0 OID 0)
-- Dependencies: 247
-- Name: suggestion_suggestion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.suggestion_suggestion_id_seq', 1, false);


--
-- TOC entry 6927 (class 0 OID 0)
-- Dependencies: 344
-- Name: user_block_event_block_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_block_event_block_event_id_seq', 1, false);


--
-- TOC entry 6928 (class 0 OID 0)
-- Dependencies: 288
-- Name: user_meal_summaries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_meal_summaries_id_seq', 21, true);


--
-- TOC entry 6929 (class 0 OID 0)
-- Dependencies: 284
-- Name: user_meal_targets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_meal_targets_id_seq', 1, false);


--
-- TOC entry 6930 (class 0 OID 0)
-- Dependencies: 346
-- Name: user_unblock_request_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_unblock_request_request_id_seq', 1, false);


--
-- TOC entry 6931 (class 0 OID 0)
-- Dependencies: 223
-- Name: useractivitylog_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.useractivitylog_log_id_seq', 54, true);


--
-- TOC entry 6932 (class 0 OID 0)
-- Dependencies: 282
-- Name: useraminointake_intake_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.useraminointake_intake_id_seq', 1, false);


--
-- TOC entry 6933 (class 0 OID 0)
-- Dependencies: 273
-- Name: userfattyacidintake_intake_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.userfattyacidintake_intake_id_seq', 55, true);


--
-- TOC entry 6934 (class 0 OID 0)
-- Dependencies: 271
-- Name: userfiberintake_intake_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.userfiberintake_intake_id_seq', 25, true);


--
-- TOC entry 6935 (class 0 OID 0)
-- Dependencies: 249
-- Name: usergoal_goal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usergoal_goal_id_seq', 1, false);


--
-- TOC entry 6936 (class 0 OID 0)
-- Dependencies: 316
-- Name: userhealthcondition_user_condition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.userhealthcondition_user_condition_id_seq', 10, true);


--
-- TOC entry 6937 (class 0 OID 0)
-- Dependencies: 406
-- Name: usermedication_user_medication_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usermedication_user_medication_id_seq', 1, false);


--
-- TOC entry 6938 (class 0 OID 0)
-- Dependencies: 376
-- Name: usernutrientmanuallog_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usernutrientmanuallog_log_id_seq', 10, true);


--
-- TOC entry 6939 (class 0 OID 0)
-- Dependencies: 295
-- Name: usernutrientnotification_notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usernutrientnotification_notification_id_seq', 1, false);


--
-- TOC entry 6940 (class 0 OID 0)
-- Dependencies: 293
-- Name: usernutrienttracking_tracking_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usernutrienttracking_tracking_id_seq', 1872, true);


--
-- TOC entry 6941 (class 0 OID 0)
-- Dependencies: 251
-- Name: vitamin_vitamin_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vitamin_vitamin_id_seq', 26, true);


--
-- TOC entry 6942 (class 0 OID 0)
-- Dependencies: 372
-- Name: vitaminnutrient_vitamin_nutrient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vitaminnutrient_vitamin_nutrient_id_seq', 71, true);


--
-- TOC entry 6943 (class 0 OID 0)
-- Dependencies: 254
-- Name: vitaminrda_vitamin_rda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vitaminrda_vitamin_rda_id_seq', 119, true);


--
-- TOC entry 6944 (class 0 OID 0)
-- Dependencies: 364
-- Name: waterlog_water_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.waterlog_water_log_id_seq', 37, true);


-- Completed on 2025-12-06 11:52:46

--
-- PostgreSQL database dump complete
--

\unrestrict p7pwFIzBBReIQA4UJ7hHq2n0nCo2rvy7tH8iFTfoNnVppNXx3EVjpi5CUWUHYeu

