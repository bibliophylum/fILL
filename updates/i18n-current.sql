-- i18n-current.sql

insert into i18n (page,lang,category,id,stage,text) values
('public/current.tmpl','en','tparm','lang',null,'en'),
('public/current.tmpl','en','tparm','pagetitle',null,'Current borrowing'),
('public/current.tmpl','en','tabledef','datatable_borrowing-col-0',null,'cid'),
('public/current.tmpl','en','tabledef','datatable_borrowing-col-1',null,'Title'),
('public/current.tmpl','en','tabledef','datatable_borrowing-col-2',null,'Author'),
('public/current.tmpl','en','tabledef','datatable_borrowing-col-3',null,'Lender'),
('public/current.tmpl','en','tabledef','datatable_borrowing-col-4',null,'Status'),
('public/current.tmpl','en','tabledef','datatable_borrowing-col-5',null,'Details'),
('public/current.tmpl','en','tabledef','datatable_borrowing-col-6',null,'Status Updated'),
('public/current.tmpl','en','tabledef','datatable_borrowing-col-7',null,'Action');

insert into i18n (page,lang,category,id,stage,text) values
('public/current.tmpl','fr','tparm','lang',null,'fr'),
('public/current.tmpl','fr','tparm','pagetitle',null,'Emprunts actuels'),
('public/current.tmpl','fr','tabledef','datatable_borrowing-col-0',null,'cid'),
('public/current.tmpl','fr','tabledef','datatable_borrowing-col-1',null,'Titre'),
('public/current.tmpl','fr','tabledef','datatable_borrowing-col-2',null,'Auteur'),
('public/current.tmpl','fr','tabledef','datatable_borrowing-col-3',null,'Prêteur'),
('public/current.tmpl','fr','tabledef','datatable_borrowing-col-4',null,'Statut'),
('public/current.tmpl','fr','tabledef','datatable_borrowing-col-5',null,'Détails'),
('public/current.tmpl','fr','tabledef','datatable_borrowing-col-6',null,'Statut mis à jour'),
('public/current.tmpl','fr','tabledef','datatable_borrowing-col-7',null,'Mesure');
