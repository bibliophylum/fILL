-- show relationships among libraries and branches
create table library_systems (
parent_id integer not null,
child_id integer not null
);

-- is library allowed to forward requests to branches?
alter table libraries add column can_forward_to_children boolean default false;
