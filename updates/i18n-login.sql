-- i18n-login.sql

-- THIS IS JUST A TEST, USING GOOGLE TRANSLATE!  DO NOT USE IN PRODUCTION!

insert into i18n (page,lang,category,id,text) values
('public/login.tmpl','en','tparm','lang','en'),
('public/login.tmpl','en','tparm','pagetitle','fILL public login'),
('public/login.tmpl','en','js_lang_data','image-attribution','Image care of '),
('public/login.tmpl','en','js_lang_data','menu_login','Welcome'),
('public/login.tmpl','en','js_lang_data','menu_new','New to fILL?'),
('public/login.tmpl','en','js_lang_data','welcome-text','Welcome to the Manitoba public libraries interlibrary loan system')
;

insert into i18n (page,lang,category,id,text) values
('public/login.tmpl','fr','tparm','lang','fr'),
('public/login.tmpl','fr','tparm','pagetitle','fILL public login'),
('public/login.tmpl','fr','js_lang_data','image-attribution','Image de '),
('public/login.tmpl','fr','js_lang_data','menu_login','Bienvenue'),
('public/login.tmpl','fr','js_lang_data','menu_new','Etes-vous de nouveau à fILL'),
('public/login.tmpl','fr','js_lang_data','welcome-text','Bienvenue au système de prêt entre bibliothèques des bibliothèques publiques du Manitoba.')
;

