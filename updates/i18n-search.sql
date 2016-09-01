-- i18n-search.sql

insert into i18n (page,lang,category,id,stage,text) values
('public/search.tmpl','en','tparm','lang',null,'en'),
('public/search.tmpl','en','tparm','pagetitle',null,'fILL/Search'),
('public/search.tmpl','en','js_lang_data','status-header','initial','Searching all libraries'),
('public/search.tmpl','en','js_lang_data','status-header','search finished','Search complete'),
('public/search.tmpl','en','js_lang_data','status-note',null,'Your search will finish when either the timer runs out, or all libraries have responded.'),
('public/search.tmpl','en','js_lang_data','progress-header',null,'Finishing in:'),
('public/search.tmpl','en','js_lang_data','alternative-marker',null,'...or...'),
('public/search.tmpl','en','js_lang_data','percentage-header',null,'% of libraries:'),
('public/search.tmpl','en','js_lang_data','result-instructions','initial','Enter some keywords to begin searching.'),
('public/search.tmpl','en','js_lang_data','result-instructions','during search','You will be able to click on the titles when the search is done.'),
('public/search.tmpl','en','js_lang_data','result-instructions','after search','Click on a title for more information.'),
('public/search.tmpl','en','js_lang_data','all-libraries-finished',null,'All libraries responded to your search within'),
('public/search.tmpl','en','js_lang_data','time-units',null,'seconds.'),
('public/search.tmpl','en','js_lang_data','refinery',null,'Refine search by:'),
('public/search.tmpl','en','js_lang_data','subject-heading',null,'Subjects'),
('public/search.tmpl','en','js_lang_data','author-heading',null,'Authors');


insert into i18n (page,lang,category,id,stage,text) values
('public/search.tmpl','fr','tparm','lang',null,'fr'),
('public/search.tmpl','fr','tparm','pagetitle',null,'fILL/Search'),
('public/search.tmpl','fr','js_lang_data','status-header','initial','Chercher dans toutes les bibliothèques'),
('public/search.tmpl','fr','js_lang_data','status-header','search finished','Recherche terminée'),
('public/search.tmpl','fr','js_lang_data','status-note',null,'Votre recherche se termine lorsque le décompte est terminé ou lorsque toutes les bibliothèques ont répondu.'),
('public/search.tmpl','fr','js_lang_data','progress-header',null,'Fin dans'),
('public/search.tmpl','fr','js_lang_data','alternative-marker',null,'... ou'),
('public/search.tmpl','fr','js_lang_data','percentage-header',null,'% des bibliothèques'),
('public/search.tmpl','fr','js_lang_data','result-instructions','initial','Entrez des mots-clés pour commencer la recherche.'),
('public/search.tmpl','fr','js_lang_data','result-instructions','during search','Vous pourrez cliquer sur les titres lorsque la recherche sera terminée.'),
('public/search.tmpl','fr','js_lang_data','result-instructions','after search','Cliquez sur un titre pour obtenir de plus amples renseignements.'),
('public/search.tmpl','fr','js_lang_data','all-libraries-finished',null,'Toutes les bibliothèques ont répondu à votre demande de recherche dans un délai de'),
('public/search.tmpl','fr','js_lang_data','time-units',null,'secondes.'),
('public/search.tmpl','fr','js_lang_data','refinery',null,'Préciser la recherche par'),
('public/search.tmpl','fr','js_lang_data','subject-heading',null,'sujets'),
('public/search.tmpl','fr','js_lang_data','author-heading',null,'auteurs');

