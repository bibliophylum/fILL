-- 42.internal-notes-borrower.sql
create table internal_note_borrower (gid integer primary key, private_to integer, note varchar(100));
alter table internal_note_borrower add foreign key (gid) references request_group (group_id);
alter table internal_note_borrower add foreign key (private_to) references org (oid);

alter table org add column borrower_internal_notes_enabled boolean default true;
