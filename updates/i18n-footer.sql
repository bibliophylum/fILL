-- i18n-footer.sql

insert into i18n (page,lang,category,id,change,which,stage,text) values
('public','en','footer','envDisplay','text',null,null,'ENV display'),
('public','en','footer','clearCookies','text',null,null,'DEBUG: clear cookies');

insert into i18n (page,lang,category,id,change,which,stage,text) values
('public','fr','footer','envDisplay','text',null,null,'Affichage ENV'),
('public','fr','footer','clearCookies','text',null,null,'DÉBOGUER: retirer les témoins');
