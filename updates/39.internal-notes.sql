create table internal_note( request_id integer, private_to integer, note varchar(100) );
alter table internal_note add primary key (request_id);
alter table internal_note add foreign key (request_id) references request (id);
alter table internal_note add foreign key (private_to) references org (oid);

alter table org add column lender_internal_notes_enabled boolean default true;

