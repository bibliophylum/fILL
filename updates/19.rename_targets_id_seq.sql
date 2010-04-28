-- oops, forgot to rename this sequence as part of the Great Renaming
--
alter table targets_id_seq rename to zservers_id_seq;
alter table zservers alter column id set default nextval('zservers_id_seq');
-- and just to be sure we've got the right value for the sequence:
select setval('zservers_id_seq', (select max(id) from zservers));
