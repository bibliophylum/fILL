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

--alter table org add column parent_oid integer;
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

insert into org (symbol, org_name, orgtype) values ('Allard','Bibliotheque Allard Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Allard'),(select oid from org where symbol='MSTG'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Allard'),(select oid from org where symbol='MVBB'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Allard'),(select oid from org where symbol='MBBB'));

insert into org (symbol, org_name, orgtype) values ('Ritchot','Bibliotheque Ritchot Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Ritchot'),(select oid from org where symbol='MIBR'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Ritchot'),(select oid from org where symbol='MSAD'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Ritchot'),(select oid from org where symbol='MSAG'));

insert into org (symbol, org_name, orgtype) values ('BrenDelWin','Bren Del Win Centennial Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='BrenDelWin'),(select oid from org where symbol='MDB'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='BrenDelWin'),(select oid from org where symbol='TWAS'));

insert into org (symbol, org_name, orgtype) values ('Border','Border Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Border'),(select oid from org where symbol='MVE'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Border'),(select oid from org where symbol='ME'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Border'),(select oid from org where symbol='MMCA'));

insert into org (symbol, org_name, orgtype) values ('Evergreen Regional','Evergreen Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Evergreen Regional'),(select oid from org where symbol='MGE'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Evergreen Regional'),(select oid from org where symbol='MAB'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Evergreen Regional'),(select oid from org where symbol='MRB'));

insert into org (symbol, org_name, orgtype) values ('Jolys','Bibliotheque Jolys Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Jolys'),(select oid from org where symbol='MSTP'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Jolys'),(select oid from org where symbol='MSSM'));

insert into org (symbol, org_name, orgtype) values ('Lakeland','Lakeland Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Lakeland'),(select oid from org where symbol='MKL'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Lakeland'),(select oid from org where symbol='MCCB'));

insert into org (symbol, org_name, orgtype) values ('NWRL','North-West Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='NWRL'),(select oid from org where symbol='MSRN'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='NWRL'),(select oid from org where symbol='MBB'));

insert into org (symbol, org_name, orgtype) values ('Parkland','Parkland Regional Library',3);
alter table org add column can_forward_to_siblings boolean default false;  -- eg Dauphin can forward to Parkland siblings, Brandon can forward to WMRL siblings
--update org set orgtype=3 where symbol='MDP';
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDA'));
update org set can_forward_to_siblings=true where symbol='MDA';
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDP'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPBR'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPBI'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPBO'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPER'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPFO'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPGP'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPGL'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPGV'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPHA'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPLA'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPMC'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPMI'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPOR'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPRO'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPSL'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPSI'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPST'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MDPWP'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Parkland'),(select oid from org where symbol='MRO'));
update org set org_name='Parkland Regional Library - Rossburn' where symbol='MRO';

--insert into org (symbol, org_name, orgtype) values ('SCRL','South Central Regional Library',3);
update org set symbol='SCRL' where symbol='MWOWH';
update org set org_name='South Central Regional Library' where symbol='SCRL';
update org set orgtype=3 where symbol='SCRL';
insert into org_members (oid, member_id) values ((select oid from org where symbol='SCRL'),(select oid from org where symbol='MWOW'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='SCRL'),(select oid from org where symbol='MAOW'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='SCRL'),(select oid from org where symbol='MMOW'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='SCRL'),(select oid from org where symbol='MMIOW'));

insert into org (symbol, org_name, orgtype) values ('SIRL','South Interlake Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='SIRL'),(select oid from org where symbol='MSTOS'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='SIRL'),(select oid from org where symbol='MTSIR'));

insert into org (symbol, org_name, orgtype) values ('Southwestern','Southwestern Manitoba Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Southwestern'),(select oid from org where symbol='MESM'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Southwestern'),(select oid from org where symbol='MESMN'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Southwestern'),(select oid from org where symbol='MESP'));

insert into org (symbol, org_name, orgtype) values ('WMRL','Western Manitoba Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='WMRL'),(select oid from org where symbol='MBW'));
update org set can_forward_to_siblings=true where symbol='MBW';
insert into org_members (oid, member_id) values ((select oid from org where symbol='WMRL'),(select oid from org where symbol='MHW'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='WMRL'),(select oid from org where symbol='MCNC'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='WMRL'),(select oid from org where symbol='MGW'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='WMRL'),(select oid from org where symbol='MNW'));

insert into org (symbol, org_name, orgtype) values ('Russell','Russell and District Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Russell'),(select oid from org where symbol='MRD'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Russell'),(select oid from org where symbol='MBI'));

insert into org (symbol, org_name, orgtype) values ('UCN','University College of the North',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='UCN'),(select oid from org where symbol='MTK'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='UCN'),(select oid from org where symbol='MTPK'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='UCN'),(select oid from org where symbol='MEC'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='UCN'),(select oid from org where symbol='MNH'));

insert into org (symbol, org_name, orgtype) values ('Spruce','Spruce Libraries Cooperative',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Spruce'),(select oid from org where symbol='MWPL'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Spruce'),(select oid from org where symbol='Border'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Spruce'),(select oid from org where symbol='MBOM'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Spruce'),(select oid from org where symbol='BrenDelWin'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Spruce'),(select oid from org where symbol='MMA'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Spruce'),(select oid from org where symbol='MNDP'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Spruce'),(select oid from org where symbol='MPLP'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Spruce'),(select oid from org where symbol='Russell'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Spruce'),(select oid from org where symbol='MS'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Spruce'),(select oid from org where symbol='MSCL'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Spruce'),(select oid from org where symbol='MSOG'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Spruce'),(select oid from org where symbol='MSSC'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Spruce'),(select oid from org where symbol='SCRL'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Spruce'),(select oid from org where symbol='SIRL'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Spruce'),(select oid from org where symbol='UCN'));


alter table library_z3950 rename lid to oid;
alter table libraries_untracked_ill rename lid to oid;
alter table library_sip2 rename lid to oid;
alter table library_nonsip2 rename lid to oid;
alter table acquisitions rename lid to oid;
alter table patron_request rename lid to oid;
alter table patron_requests_declined rename lid to oid;
alter table shipping_tracking_number rename lid to oid;
alter table rotations_stats rename lid to oid;
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
