-- i18n-login.sql

-- THIS IS JUST A TEST, USING GOOGLE TRANSLATE!  DO NOT USE IN PRODUCTION!

insert into i18n (page,lang,category,id,stage,text) values
('public/login.tmpl','en','tparm','lang',null,'en'),
('public/login.tmpl','en','tparm','pagetitle',null,'fILL public login'),
('public/login.tmpl','en','js_lang_data','image-attribution',null,'Image care of '),
('public/login.tmpl','en','js_lang_data','menu_login',null,'Welcome'),
('public/login.tmpl','en','js_lang_data','menu_new',null,'New to fILL?'),
('public/login.tmpl','en','js_lang_data','welcome-text',null,'Welcome to the Manitoba public libraries interlibrary loan system'),
('public/login.tmpl','en','js_lang_data','cannot-remember',null,'If you cannot remember your user name or password, please contact your local public library.'),
('public/login.tmpl','en','js_lang_data','choose-region',null,'Which region of Manitoba do you live in?'),
('public/login.tmpl','en','js_lang_data','choose-town',null,'Where is your home library?'),
('public/login.tmpl','en','js_lang_data','startOver',null,'Start over')
;

insert into i18n (page,lang,category,id,stage,text) values
('public/login.tmpl','fr','tparm','lang',null,'fr'),
('public/login.tmpl','fr','tparm','pagetitle',null,'fILL public login'),
('public/login.tmpl','fr','js_lang_data','image-attribution',null,'Image de '),
('public/login.tmpl','fr','js_lang_data','menu_login',null,'Bienvenue'),
('public/login.tmpl','fr','js_lang_data','menu_new',null,'Etes-vous de nouveau à fILL'),
('public/login.tmpl','fr','js_lang_data','welcome-text',null,'Bienvenue au système de prêt entre bibliothèques des bibliothèques publiques du Manitoba.'),
('public/login.tmpl','fr','js_lang_data','cannot-remember',null,'Si vous ne vous rappelez pas de votre nom d’utilisateur ou de votre mot de passe, communiquez avec votre bibliothèque publique locale.'),
('public/login.tmpl','fr','js_lang_data','choose-region',null,'Quelle région du Manitoba habitez-vous?'),
('public/login.tmpl','fr','js_lang_data','choose-town',null,'Où se trouve votre bibliothèque habituelle?'),
('public/login.tmpl','fr','js_lang_data','startOver',null,'Recommencez')
;

