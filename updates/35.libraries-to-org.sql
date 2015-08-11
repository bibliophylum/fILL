-- libraries-to-org.sql

alter sequence libraries_lid_seq rename to org_oid_seq;
alter table libraries rename to org;

create sequence orgtype_otid_seq;
create table orgtype (otid integer not null default nextval('orgtype_otid_seq'), type varchar(40));
alter table orgtype add primary key (otid);
insert into orgtype (type) values ('branch');
insert into orgtype (type) values ('municipal library');
insert into orgtype (type) values ('regional headquarters');
insert into orgtype (type) values ('federation');
insert into orgtype (type) values ('cooperative');

alter table org add column orgtype integer default 2; -- municipal library
alter table org add foreign key (orgtype) references orgtype (otid);

alter table org rename lid to oid;
alter table org rename name to symbol;
alter table org rename library to org_name;
alter table org drop column password;

create table org_members (oid integer, member_id integer not null);
create index on org_members (oid);
create index on org_members (member_id);
alter table org_members add foreign key (oid) references org (oid);
alter table org_members add foreign key (member_id) references org (oid);


alter table library_z3950 rename lid to oid;
alter table libraries_untracked_ill rename lid to oid;
alter table library_sip2 rename lid to oid;
alter table library_nonsip2 rename lid to oid;
alter table acquisitions rename lid to oid;
alter table patron_request rename lid to oid;
alter table patron_requests_declined rename lid to oid;
alter table shipping_tracking_number rename lid to oid;
alter table rotations_stats rename lid to oid;
alter table rotations_participants rename lid to oid;
alter table library_barcodes rename lid to oid;
alter table patron_request_sources rename lid to oid;
alter table sources rename lid to oid;
alter table reports_queue rename lid to oid;
alter table reports_complete rename lid to oid;
alter table sources_history rename lid to oid;
alter table rotations_lib_holdings_fields rename lid to oid;
alter table users rename lid to oid;
alter table regional_libraries_branches rename lid to oid;
alter table rotations_order rename from_lid to from_oid;
alter table rotations_order rename to_lid to to_oid;


-- Special processing
alter table library_z3950 add column special_processing varchar(2048);

