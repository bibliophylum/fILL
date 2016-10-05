-- i18n-about.sql

insert into i18n (page,lang,category,id,stage,text) values
('public/about.tmpl','en','tparm','lang',null,'en'),
('public/about.tmpl','en','tparm','pagetitle',null,'About fILL'),
('public/about.tmpl','en','js_lang_data','image-attribution',null,'Image care of '),
('public/about.tmpl','en','js_lang_data','about-heading',null,'About'),
('public/about.tmpl','en','js_lang_data','about-p1',null,'fILL is the interlibrary loan management system for all Manitoba public libraries. It connects your local library to the millions of items available in Manitoba''s libraries.'),
('public/about.tmpl','en','js_lang_data','about-p2',null,'If you are unable to find an item after searching your library&rsquo;s catalogue you can use fILL to find it online and have it delivered to your local public library.'),
('public/about.tmpl','en','js_lang_data','about-p3',null,'fILL enables library patrons to quickly and easily search the catalogues of many Manitoba public libraries at the same time. When you find the item that you''d like to request, fILL prepares the interlibrary loan request for your public library and the local library staff to try to borrow the item from the lending library  for you.'),
('public/about.tmpl','en','js_lang_data','about-privacy',null,'Privacy'),
('public/about.tmpl','en','js_lang_data','about-privacy-p1',null,'fILL does not keep a record of your search history nor  does it keep a record of request transactions after borrowed items are returned. Logging into your account is necessary in order for your library to validate the request; some non-identifying data may be retained for statistical purposes.');

insert into i18n (page,lang,category,id,stage,text) values
('public/about.tmpl','fr','tparm','lang',null,'fr'),
('public/about.tmpl','fr','tparm','pagetitle',null,'Au sujet de fILL'),
('public/about.tmpl','fr','js_lang_data','image-attribution',null,'Image de'),
('public/about.tmpl','fr','js_lang_data','about-heading',null,'Au sujet de fILL'),
('public/about.tmpl','fr','js_lang_data','about-p1',null,'fILL est le système de gestion des prêts entre bibliothèques utilisé pour toutes les bibliothèques publiques du Manitoba. Il relie votre bibliothèque locale aux millions d’articles accessibles dans les bibliothèques du Manitoba.'),
('public/about.tmpl','fr','js_lang_data','about-p2',null,'Si vous ne trouvez pas un article après avoir fait une recherche dans le catalogue de votre bibliothèque, vous pouvez utiliser fILL pour trouver l’article en ligne et le faire livrer à votre bibliothèque publique locale.'),
('public/about.tmpl','fr','js_lang_data','about-p3',null,'fILL permet aux usagers des bibliothèques de consulter rapidement et facilement les catalogues d’un grand nombre de bibliothèques publiques du Manitoba simultanément. Lorsque vous trouvez l’article que vous souhaitez demander, fILL prépare la demande de prêt entre bibliothèques pour votre bibliothèque publique et le personnel de la bibliothèque locale pour tenter d’emprunter l’article à la bibliothèque de prêt en votre nom.'),
('public/about.tmpl','fr','js_lang_data','about-privacy',null,'Protection des renseignements personnels'),
('public/about.tmpl','fr','js_lang_data','about-privacy-p1',null,'fILL ne conserve pas de dossier de votre  historique de recherche ni des opérations demandées après que les articles empruntés sont retournés. La connexion à votre compte est nécessaire pour permettre à votre bibliothèque de valider la demande. Certaines données non identificatoires peuvent être conservées à des fins statistiques');

