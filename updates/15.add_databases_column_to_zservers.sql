alter table zservers add column isdatabase smallint default 0;
update zservers set isdatabase=1 where name like 'EBSCO%';
