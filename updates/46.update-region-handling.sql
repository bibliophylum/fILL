-- 46.update-region-handling.sql

create table i18n_regions (
    id integer not null,
    lang varchar(10) not null default 'en',
    region varchar(100),
    PRIMARY KEY(id,lang)
);


-- only physical branches are tagged with region values
-- (this is so the login can pull the correct towns for those regions)
-- Regional HQ's, etc, get region id 0.
insert into i18n_regions (id,lang,region) values
(0,'en',null),
(1,'en','CENTRAL'),
(2,'en','EASTMAN'),
(3,'en','INTERLAKE'),
(4,'en','NORMAN'),
(5,'en','PARKLAND'),
(6,'en','WESTMAN'),
(7,'en','WINNIPEG'),
(8,'en','PLS Testing'),
(0,'fr',null),
(1,'fr','CENTRE'),
(2,'fr','EST'),
(3,'fr','ENTRE-LES-LAKES'),
(4,'fr','NORD'),
(5,'fr','PARCS'),
(6,'fr','OUEST'),
(7,'fr','WINNIPEG'),
(8,'fr','PLS Testing');

-- just in case:
alter table org add column region_temp varchar(15);
update org set region_temp=region;
-- change the region column to be an integer matching the table above:
update org set region='0' where region is null;
update org set region='1' where region='CENTRAL';
update org set region='2' where region='EASTMAN';
update org set region='3' where region='INTERLAKE';
update org set region='4' where region='NORMAN';
update org set region='5' where region='PARKLAND';
update org set region='6' where region='WESTMAN';
update org set region='7' where region='WINNIPEG';
update org set region='8' where region='PLS Testing';
alter table org alter column region type integer using region::integer;
-- done with just-in-case :-)
alter table org drop column region_temp;
