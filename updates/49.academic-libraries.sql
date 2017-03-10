-- 49.academic-libraries.sql

insert into orgtype (otid,type) values (6,'academic');

alter table library_z3950 add column libtype varchar(40);
update library_z3950 set libtype='public';
