-- 29.authentication-methods.sql

alter table libraries add column patron_authentication_method varchar(20);

update libraries set patron_authentication_method='sip2' where lid in (select lid from library_sip2 where enabled=true);
update libraries set patron_authentication_method='L4U' where name='MTP';
update libraries set patron_authentication_method='Biblionet' where name='MLB';
update libraries set patron_authentication_method='FollettDestiny' where name='MSTP';

-- auth_type will determine which authentication module gets used.  Currently, 'L4U','Biblionet', and 'FollettDestiny' are valid values.
create table library_nonsip2 (lid integer primary key, enabled boolean default false, auth_type varchar(20), url varchar(1024));
insert into library_nonsip2 (lid, enabled, auth_type, url) values (91, true, 'L4U', 'http://206.45.107.73/4dcgi/gen_2002/Lang=Def');
insert into library_nonsip2 (lid, enabled, auth_type, url) values (17, true, 'Biblionet', 'http://216.73.74.12/');
insert into library_nonsip2 (lid, enabled, auth_type, url) values (36, true, 'FollettDestiny', 'http://library.rrvsd.ca/common/welcome.jsp?site=201');

alter table patrons rename column is_sip2 to is_externally_authenticated;
