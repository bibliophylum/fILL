-- i18n-myaccount.sql

insert into i18n (page,lang,category,id,stage,text) values
('public/myaccount.tmpl','en','tparm','lang',null,'en'),
('public/myaccount.tmpl','en','tparm','pagetitle',null,'fILL/My account'),
('public/myaccount.tmpl','en','js_lang_data','heading1',null,'My account'),
('public/myaccount.tmpl','en','js_lang_data','th-name',null,'Name'),
('public/myaccount.tmpl','en','js_lang_data','th-username',null,'Username'),
('public/myaccount.tmpl','en','js_lang_data','th-home-library',null,'Home library'),
('public/myaccount.tmpl','en','js_lang_data','th-account-status',null,'Account status'),
('public/myaccount.tmpl','en','js_lang_data','th-patron-id',null,'Patron ID number');

insert into i18n (page,lang,category,id,stage,text) values
('public/myaccount.tmpl','fr','tparm','lang',null,'fr'),
('public/myaccount.tmpl','fr','tparm','pagetitle',null,'fILL/My account'),
('public/myaccount.tmpl','fr','js_lang_data','heading1',null,'Mon compte'),
('public/myaccount.tmpl','fr','js_lang_data','th-name',null,'Nom'),
('public/myaccount.tmpl','fr','js_lang_data','th-username',null,'Nom d’utilisateur'),
('public/myaccount.tmpl','fr','js_lang_data','th-home-library',null,'Bibliothèque habituelle'),
('public/myaccount.tmpl','fr','js_lang_data','th-account-status',null,'Statut du compte'),
('public/myaccount.tmpl','fr','js_lang_data','th-patron-id',null,'Numéro d’identification de l’usager');
