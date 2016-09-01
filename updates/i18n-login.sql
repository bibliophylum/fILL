-- i18n-login.sql

-- THIS IS JUST A TEST, USING GOOGLE TRANSLATE!  DO NOT USE IN PRODUCTION!

insert into i18n (page,lang,category,id,stage,text) values
('public/login.tmpl','en','tparm','lang',null,'en'),
('public/login.tmpl','en','tparm','pagetitle',null,'fILL public login'),
('public/login.tmpl','en','js_lang_data','image-attribution',null,'Image care of '),
('public/login.tmpl','en','js_lang_data','menu_login',null,'Welcome'),
('public/login.tmpl','en','js_lang_data','menu_new',null,'New to fILL?'),
('public/login.tmpl','en','js_lang_data','welcome-text',null,'Welcome to the Manitoba public libraries interlibrary loan system')
;

insert into i18n (page,lang,category,id,stage,text) values
('public/login.tmpl','fr','tparm','lang',null,'fr'),
('public/login.tmpl','fr','tparm','pagetitle',null,'fILL public login'),
('public/login.tmpl','fr','js_lang_data','image-attribution',null,'Image de '),
('public/login.tmpl','fr','js_lang_data','menu_login',null,'Bienvenue'),
('public/login.tmpl','fr','js_lang_data','menu_new',null,'Etes-vous de nouveau à fILL'),
('public/login.tmpl','fr','js_lang_data','welcome-text',null,'Bienvenue au système de prêt entre bibliothèques des bibliothèques publiques du Manitoba.')
;

