-- 29.authentication-methods.sql

alter table libraries add column patron_authentication_method varchar(20);

update libraries set patron_authentication_method='sip2' where lid in (select lid from library_sip2 where enabled=true);
update libraries set patron_authentication_method='L4U' where name='MTP';

-- auth_type will determine which authentication module gets used.  Currently, only 'L4U' is a valid value.
create table library_nonsip2 (lid integer primary key, enabled boolean default false, auth_type varchar(20), url varchar(1024));
insert into library_nonsip2 (lid, enabled, auth_type, url) values (91, true, 'L4U', 'http://206.45.107.73/4dcgi/gen_2002/Lang=Def');

alter table patrons rename column is_sip2 to is_externally_authenticated;
