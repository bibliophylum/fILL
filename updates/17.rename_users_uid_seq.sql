-- oops, forgot to rename this sequence as part of the Great Renaming
--
alter table users_uid_seq rename to libraries_lid_seq;
alter table libraries alter column lid set default nextval('libraries_lid_seq');
-- and just to be sure we've got the right value for the sequence:
select setval('libraries_lid_seq', (select max(lid) from libraries));
