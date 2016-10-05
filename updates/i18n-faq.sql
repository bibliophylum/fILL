-- i18n-faq.sql

insert into i18n (page,lang,category,id,stage,text) values
('public/faq.tmpl','en','tparm','lang',null,'en'),
('public/faq.tmpl','en','tparm','pagetitle',null,'FAQ'),
('public/faq.tmpl','en','js_lang_data','faq-header',null,'FAQs'),
('public/faq.tmpl','en','js_lang_data','q-how-long',null,'How long does it take to get something delivered?'),
('public/faq.tmpl','en','js_lang_data','a-how-long',null,'Typically it takes between a week and two weeks for an item to be delivered. Every request is unique and items with limited copies and those already on loan may take longer.'),
('public/faq.tmpl','en','js_lang_data','q-where-from',null,'Where does the requested item come from?'),
('public/faq.tmpl','en','js_lang_data','a-where-from',null,'The item that you have requested could come from any public library in Manitoba.'),
('public/faq.tmpl','en','js_lang_data','q-sent-home',null,'Why can’t it just get sent to my home?'),
('public/faq.tmpl','en','js_lang_data','a-sent-home',null,'Interlibrary loan is a transaction between two different library systems; it does not facilitate a loan between a local library patron and another library system directly. Interlibrary loan provides local access to library materials from all over the province and once a requested item arrives from the lending library it will need to be processed and your local library will notify you when it is ready to pick-up.'),
('public/faq.tmpl','en','js_lang_data','q-why-fill',null,'Why is it called fILL?'),
('public/faq.tmpl','en','js_lang_data','a-why-fill',null,'ILL stands for interlibrary loan, and the "f" stands for free and open-source software (FOSS). It is also called fILL as it enables your local library to easily fill your interlibrary loan request online.'),
('public/faq.tmpl','en','js_lang_data','q-renew',null,'Can I renew my items?'),
('public/faq.tmpl','en','js_lang_data','a-renew',null,'While library patrons are not able to renew the item directly, you can make a renewal request through your local library. Your library staff will make the request to the lending library and notify you of the result. It is the decision of the lending library whether to allow inter-library loan items to be renewed.'),
('public/faq.tmpl','en','js_lang_data','q-how-many',null,'How many items can I request?'),
('public/faq.tmpl','en','js_lang_data','a-how-many',null,'The maximum number of items you can borrow at one time is a matter of local policy at your library.'),
('public/faq.tmpl','en','js_lang_data','q-on-loan',null,'What happens if the item I want is already on loan?'),
('public/faq.tmpl','en','js_lang_data','a-on-loan',null,'Your local library can request a hold on the item, after it is returned the ILL request will be processed.'),
('public/faq.tmpl','en','js_lang_data','q-late',null,'Do I pay late fines to my local public library or to the lending library?'),
('public/faq.tmpl','en','js_lang_data','a-late',null,'If your item is late, you will pay late fees to your local public library. Library patrons should always try to return any borrowed items by the due date to ensure service is not disrupted for other library patrons.');

insert into i18n (page,lang,category,id,stage,text) values
('public/faq.tmpl','fr','tparm','lang',null,'fr'),
('public/faq.tmpl','fr','tparm','pagetitle',null,'FAQ'),
('public/faq.tmpl','fr','js_lang_data','faq-header',null,'FAQs'),
('public/faq.tmpl','fr','js_lang_data','q-how-long',null,'Combien de temps faut-il pour faire livrer un article?'),
('public/faq.tmpl','fr','js_lang_data','a-how-long',null,'Généralement, il faut entre une et deux semaines pour livrer un article. Chaque demande est unique et les articles dont le nombre d’exemplaires est limité et ceux qui sont déjà prêtés peuvent nécessiter un délai de livraison plus long.'),
('public/faq.tmpl','fr','js_lang_data','q-where-from',null,'D’où provient l’article demandé?'),
('public/faq.tmpl','fr','js_lang_data','a-where-from',null,'L’article que vous avez demandé peut provenir de n’importe quelle bibliothèque publique du Manitoba.'),
('public/faq.tmpl','fr','js_lang_data','q-sent-home',null,'Pourquoi l’article ne peut-il pas simplement être livré à mon domicile?'),
('public/faq.tmpl','fr','js_lang_data','a-sent-home',null,'Le prêt entre bibliothèques est une opération effectuée entre deux différents systèmes de bibliothèque; il ne facilite pas un prêt direct entre l’usager d’une bibliothèque locale et un autre système de bibliothèque. Le prêt entre bibliothèques offre un accès local aux documents de bibliothèque provenant de toutes les régions de la province. Une fois que l’article est reçu de la bibliothèque de prêt, il doit être traité et votre bibliothèque locale vous informe lorsque vous pouvez le recueillir.'),
('public/faq.tmpl','fr','js_lang_data','q-why-fill',null,'Pourquoi appelle-t-on le système fILL?'),
('public/faq.tmpl','fr','js_lang_data','a-why-fill',null,'« ILL » signifie « interlibrary loan » (prêt entre bibliothèques) et « f » est la première lettre de « free and open-source software (FOSS) » (logiciel libre et ouvert). On l’appelle aussi fILL parce qu’il permet à votre bibliothèque locale de remplir (en anglais, fill) facilement votre demande de prêt entre bibliothèques en ligne.'),
('public/faq.tmpl','fr','js_lang_data','q-renew',null,'Puis-je renouveler mes articles?'),
('public/faq.tmpl','fr','js_lang_data','a-renew',null,'Même si les usagers de la bibliothèque ne sont pas en mesure de renouveler l’article directement, vous pouvez présenter une demande de renouvellement auprès de votre bibliothèque locale. Le personnel de votre bibliothèque fera la demande à la bibliothèque de prêt et vous informera du résultat. Il incombe au personnel de la bibliothèque de prêt de décider si les articles prêtés entre bibliothèques peuvent être renouvelés.'),
('public/faq.tmpl','fr','js_lang_data','q-how-many',null,'Combien d’articles puis-je demander?'),
('public/faq.tmpl','fr','js_lang_data','a-how-many',null,'Le nombre maximal d’articles que vous pouvez emprunter en une seule fois est établi par la politique locale de votre bibliothèque.'),
('public/faq.tmpl','fr','js_lang_data','q-on-loan',null,'Que se passe-t-il si l’article que je souhaite est déjà prêté?'),
('public/faq.tmpl','fr','js_lang_data','a-on-loan',null,'Votre bibliothèque locale peut demander qu’on retienne l’article. Lorsque l’article est retourné, la demande de prêt entre bibliothèques est traitée.'),
('public/faq.tmpl','fr','js_lang_data','q-late',null,'Est-ce que je paie des frais de retard à ma bibliothèque publique locale ou à la bibliothèque de prêt?'),
('public/faq.tmpl','fr','js_lang_data','a-late',null,'Si votre article est retourné en retard, vous payez des frais de retard à votre bibliothèque publique locale. Les usagers des bibliothèques doivent toujours tenter de retourner les articles empruntés à la date limite pour assurer que le service offert aux autres usagers n’est pas interrompu.');

