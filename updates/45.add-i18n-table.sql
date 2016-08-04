-- 45.add-i18n-table.sql

-- page is page template name, including path
-- lang is language code (e.g. "en", "fr")
-- category determines whether this is something that can be a template parameter (tparm),
--   or needs to be handled by jquery mucking with the DOM (js_lang_data)
-- id is the hash key / element ID
-- text is the translated text
create table i18n (
  page varchar(100) not null,
  lang varchar(10) not null,
  category varchar(100),
  id varchar(100) not null,
  text varchar(4096) not null
);

create index on i18n (page,lang);

insert into i18n (page,lang,category,id,text) values
('public/test.tmpl','en','tparm','lang','en'),
('public/test.tmpl','en','tparm','pagetitle','fILL test'),
('public/test.tmpl','en','js_lang_data','main-info-left-h2','HEADING TEST'),
('public/test.tmpl','en','js_lang_data','id-of-para','First paragraph'),
('public/test.tmpl','en','js_lang_data','id-of-second-para','Here is another paragraph');

insert into i18n (page,lang,category,id,text) values
('public','en','header','tagline-p','connecting libraries, serving patrons.'),
('public','en','header','fill-button','log out'),
('public','en','header','menu_search','Home'),
('public','en','header','menu_myaccount','My Account'),
('public','en','header','menu_current','Current Borrowing'),
('public','en','header','menu_about','About'),
('public','en','header','menu_help','Help'),
('public','en','header','menu_faq','FAQ'),
('public','en','header','menu_contact','Contact'),
('public','en','header','menu_test','Test');

insert into i18n (page,lang,category,id,text) values
('public','fr','header','tagline-p','Réseau de bibliothèques, au service des Manitobains'),
('public','fr','header','fill-button','Déconnexion'),
('public','fr','header','menu_search','Accueil'),
('public','fr','header','menu_myaccount','Mon compte'),
('public','fr','header','menu_current','Emprunt actuel'),
('public','fr','header','menu_about','À propos de fILL'),
('public','fr','header','menu_help','Aide'),
('public','fr','header','menu_faq','Questions fréquentes'),
('public','fr','header','menu_contact','Contact'),
('public','fr','header','menu_test','Test');

