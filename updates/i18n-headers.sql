-- i18n-headers.sql

insert into i18n (page,lang,category,id,change,which,stage,text) values
('public','en','header','tagline-p','text',null,null,'connecting libraries, serving patrons.'),
('public','en','header','fill-button','text',null,null,'log out'),
('public','en','header','menu_search','text',null,null,'Home'),
('public','en','header','menu_myaccount','text',null,null,'My Account'),
('public','en','header','menu_current','text',null,null,'Current Borrowing'),
('public','en','header','menu_about','text',null,null,'About'),
('public','en','header','menu_help','text',null,null,'Help'),
('public','en','header','menu_faq','text',null,null,'FAQ'),
('public','en','header','menu_contact','text',null,null,'Contact'),
('public','en','header','menu_test','text',null,null,'Test'),
('public','en','header','query','attr','placeholder',null,'Search'),
('public','en','header','search-submit-button','prop','value',null,'Go');

insert into i18n (page,lang,category,id,change,which,stage,text) values
('public','fr','header','tagline-p','text',null,null,'Relier les bibliothèques, servir les usagers.'),
('public','fr','header','fill-button','text',null,null,'Déconnexion'),
('public','fr','header','menu_search','text',null,null,'Accueil'),
('public','fr','header','menu_myaccount','text',null,null,'Mon compte'),
('public','fr','header','menu_current','text',null,null,'Emprunts actuels'),
('public','fr','header','menu_about','text',null,null,'Au sujet de fILL'),
('public','fr','header','menu_help','text',null,null,'Aide'),
('public','fr','header','menu_faq','text',null,null,'Questions fréquentes'),
('public','fr','header','menu_contact','text',null,null,'Contact'),
('public','fr','header','menu_test','text',null,null,'Tester'),
('public','fr','header','query','attr','placeholder',null,'Chercher'),
('public','fr','header','search-submit-button','prop','value',null,'Aller');
