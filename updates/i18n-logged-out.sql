-- i18n-logged-out.sql

insert into i18n (page,lang,category,id,stage,text) values
('public/logged_out.tmpl','en','tparm','lang',null,'en'),
('public/logged_out.tmpl','en','tparm','pagetitle',null,'fILL public logged out'),
('public/logged_out.tmpl','en','tparm','logged-out-header',null,'Logged out'),
('public/logged_out.tmpl','en','tparm','thanks',null,'Thanks for using fILL!'),
('public/logged_out.tmpl','en','tparm','login-button-text',null,'Log in')
;

insert into i18n (page,lang,category,id,stage,text) values
('public/logged_out.tmpl','fr','tparm','lang',null,'en'),
('public/logged_out.tmpl','fr','tparm','pagetitle',null,'fILL public logged out'),
('public/logged_out.tmpl','fr','tparm','logged-out-header',null,'Déconnecté'),
('public/logged_out.tmpl','fr','tparm','thanks',null,'Merci d''avoir utilisé fILL'),
('public/logged_out.tmpl','fr','tparm','login-button-text',null,'Connexion')
;

