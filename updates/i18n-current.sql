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
('public/current.tmpl','fr','tparm','pagetitle',null,'Mes emprunts'),
('public/current.tmpl','fr','tabledef','datatable_borrowing-col-0',null,'cid'),
('public/current.tmpl','fr','tabledef','datatable_borrowing-col-1',null,'Titre'),
('public/current.tmpl','fr','tabledef','datatable_borrowing-col-2',null,'Auteur'),
('public/current.tmpl','fr','tabledef','datatable_borrowing-col-3',null,'Prêteur'),
('public/current.tmpl','fr','tabledef','datatable_borrowing-col-4',null,'Statut'),
('public/current.tmpl','fr','tabledef','datatable_borrowing-col-5',null,'Détails'),
('public/current.tmpl','fr','tabledef','datatable_borrowing-col-6',null,'Statut mis à jour'),
('public/current.tmpl','fr','tabledef','datatable_borrowing-col-7',null,'Mesure');

-- prep for status messages
alter table patron_requests_declined add column status varchar(20) default 'declined';
update patron_requests_declined set status='wish-list' where reason = 'Your librarian is considering this for purchase.';
update patron_requests_declined set reason='wish-list' where reason = 'Your librarian is considering this for purchase.';

-- status messages
insert into i18n (page,lang,category,id,stage,text) values
('public/current.tmpl','en','status','New request','status','New request'),
('public/current.tmpl','en','status','New request','detail','Your librarian has not yet seen this request.'),
('public/current.tmpl','en','status','ILL-Request','detail','Your library has requested it.'),
('public/current.tmpl','en','status','ILL-Answer|Will-Supply','detail','The lender will lend it.'),
('public/current.tmpl','en','status','ILL-Answer|Hold-Placed','detail','The lender has placed a hold for you.  They expect to have it for you by '),
('public/current.tmpl','en','status','ILL-Answer|Locations-provided','detail','The lender is forwarding your request to one of its branches.'),
('public/current.tmpl','en','status','ILL-Answer|Unfilled','detail','The lender cannot lend it. Your library will try another lender if possible.'),
('public/current.tmpl','en','status','Shipped','detail','The lender has shipped it to your library.'),
('public/current.tmpl','en','status','Received','detail','Your library has received it from the lender, and should be contacting you soon.'),
('public/current.tmpl','en','status','Returned','detail','Your library has returned it to the lender.'),
('public/current.tmpl','en','status','Checked-in','detail','The lender has received the returned book.'),
('public/current.tmpl','en','status','Cancelled','detail','Your library has cancelled the request to that lender.  They may try again with a different lender.'),
('public/current.tmpl','en','status','Renew','detail','Your library has asked the lender for a renewal of the loan, and is waiting for a reply.'),
('public/current.tmpl','en','status','Renew-Answer|No-renewal','detail','The lender cannot give you a renewal on the loan.  They need it back.'),
('public/current.tmpl','en','status','Renew-Answer|Ok','detail','The lender has given you a renewal on the loan.  The item is now due on '),
('public/current.tmpl','en','status','wish-list','status','Wish list'),
('public/current.tmpl','en','status','wish-list','detail','Your librarian is considering this for purchase.'),
('public/current.tmpl','en','status','declined','status','Declined'),
('public/current.tmpl','en','status','held-locally','detail','Your library has this locally.'),
('public/current.tmpl','en','status','blocked','detail','There is a problem with your library account.'),
('public/current.tmpl','en','status','on-order','detail','Your library is purchasing this title.'),
('public/current.tmpl','en','status','other','detail','Reason given: '),
('public/current.tmpl','en','status','Loan-requests to','detail','Loan requests have been made to'),
('public/current.tmpl','en','status','Loan-requests of','detail','of'),
('public/current.tmpl','en','status','Loan-requests libraries','detail','libraries.');

insert into i18n (page,lang,category,id,stage,text) values
('public/current.tmpl','fr','status','New request','status','Nouvelle demande'),
('public/current.tmpl','fr','status','New request','detail','Votre bibliothécaire n’a pas encore vu cette demande.'),
('public/current.tmpl','fr','status','ILL-Request','detail','Votre bibliothèque l’a demandé.'),
('public/current.tmpl','fr','status','ILL-Answer|Will-Supply','detail','La bibliothèque de prêt le prêtera.'),
('public/current.tmpl','fr','status','ILL-Answer|Hold-Placed','detail','La bibliothèque de prêt a mis le titre en attente à votre nom. Elle prévoit que vous l’aurez le '),
('public/current.tmpl','fr','status','ILL-Answer|Locations-provided','detail','La bibliothèque de prêt transmet votre demande à l''une de ses succursales.'),
('public/current.tmpl','fr','status','ILL-Answer|Unfilled','detail','La bibliothèque de prêt ne peut pas le prêter. Votre bibliothèque tentera de communiquer avec une autre bibliothèque, si possible.'),
('public/current.tmpl','fr','status','Shipped','detail','La bibliothèque de prêt l’a expédié à votre bibliothèque.'),
('public/current.tmpl','fr','status','Received','detail','Votre bibliothèque l’a reçu de la bibliothèque de prêt et devrait communiquer avec vous sous peu.'),
('public/current.tmpl','fr','status','Returned','detail','Votre bibliothèque l’a retourné à la bibliothèque de prêt.'),
('public/current.tmpl','fr','status','Checked-in','detail','La bibliothèque de prêt a reçu le livre retourné.'),
('public/current.tmpl','fr','status','Cancelled','detail','Votre bibliothèque a annulé la demande faite à cette bibliothèque de prêt. Elle tentera peut-être de communiquer avec une bibliothèque de prêt différente.'),
('public/current.tmpl','fr','status','Renew','detail','Votre bibliothèque a demandé un renouvellement du prêt à la bibliothèque de prêt et attend une réponse.'),
('public/current.tmpl','fr','status','Renew-Answer|No-renewal','detail','La bibliothèque de prêt ne peut pas renouveler le prêt. Elle doit récupérer l’article.'),
('public/current.tmpl','fr','status','Renew-Answer|Ok','detail','La bibliothèque de prêt a renouvelé le prêt. L’article doit maintenant être rendu le '),
('public/current.tmpl','fr','status','wish-list','status','Liste de souhait'),
('public/current.tmpl','fr','status','wish-list','detail','Votre bibliothécaire envisage d’acheter cet article.'),
('public/current.tmpl','fr','status','declined','status','Refusé'),
('public/current.tmpl','fr','status','held-locally','detail','Votre bibliothèque possède l’article.'),
('public/current.tmpl','fr','status','blocked','detail','Il y a un problème concernant votre compte de bibliothèque.'),
('public/current.tmpl','fr','status','on-order','detail','Votre bibliothèque est en voie d’acquérir ce titre.'),
('public/current.tmpl','fr','status','other','detail','Raison donnée: '),
('public/current.tmpl','fr','status','Loan-requests to','detail','Des demandes de prêt ont été faites à'),
('public/current.tmpl','fr','status','Loan-requests of','detail','des'),
('public/current.tmpl','fr','status','Loan-requests libraries','detail','bibliothèques.');

