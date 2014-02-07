-- setup to allow branches of your regional system to take precedence in sources sort order
-- (i.e. try from other branches of your regional library before trying outside your system)

create sequence regional_libraries_rlid_seq;

create table regional_libraries (
  rlid integer not null default nextval('regional_libraries_rlid_seq'::regclass),
  name varchar(100)
);

create table regional_libraries_branches (
  rlid integer not null,
  lid integer not null
);

insert into regional_libraries (name) values ('Bibliotheque Allard Regional Library');
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Bibliotheque Allard Regional Library'), (select lid from libraries where name='MSTG'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Bibliotheque Allard Regional Library'), (select lid from libraries where name='MBBB'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Bibliotheque Allard Regional Library'), (select lid from libraries where name='MVBB'));

insert into regional_libraries (name) values ('Bibliotheque Ritchot');
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Bibliotheque Ritchot'), (select lid from libraries where name='MSAG'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Bibliotheque Ritchot'), (select lid from libraries where name='MSAD'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Bibliotheque Ritchot'), (select lid from libraries where name='MIBR'));

insert into regional_libraries (name) values ('Border Regional Library');
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Border Regional Library'), (select lid from libraries where name='MMCA'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Border Regional Library'), (select lid from libraries where name='MVE'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Border Regional Library'), (select lid from libraries where name='ME'));

insert into regional_libraries (name) values ('Bren Del Win Centennial Library');
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Bren Del Win Centennial Library'), (select lid from libraries where name='MDB'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Bren Del Win Centennial Library'), (select lid from libraries where name='TWAS'));

insert into regional_libraries (name) values ('Evergreen Regional Library');
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Evergreen Regional Library'), (select lid from libraries where name='MGE'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Evergreen Regional Library'), (select lid from libraries where name='MAB'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Evergreen Regional Library'), (select lid from libraries where name='MRB'));

insert into regional_libraries (name) values ('Jolys Regional Library');
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Jolys Regional Library'), (select lid from libraries where name='MSTP'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Jolys Regional Library'), (select lid from libraries where name='MSSM'));

insert into regional_libraries (name) values ('Lakeland Regional Library');
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Lakeland Regional Library'), (select lid from libraries where name='MKL'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Lakeland Regional Library'), (select lid from libraries where name='MCCB'));

insert into regional_libraries (name) values ('North West Regional Library');
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='North West Regional Library'), (select lid from libraries where name='MSRN'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='North West Regional Library'), (select lid from libraries where name='MBB'));

insert into regional_libraries (name) values ('Parkland Regional Library');
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPBR'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPBI'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPBO'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDA'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPER'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPFO'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPGL'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPGV'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPHA'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDP'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPLA'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPMC'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPMI'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPOR'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPSL'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPSI'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPSLA'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPST'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPWP'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPRO'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Parkland Regional Library'), (select lid from libraries where name='MDPGP'));

insert into regional_libraries (name) values ('Russell and District Regional Library');
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Russell and District Regional Library'), (select lid from libraries where name='MRD'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Russell and District Regional Library'), (select lid from libraries where name='MBI'));

insert into regional_libraries (name) values ('South Central Regional Library');
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='South Central Regional Library'), (select lid from libraries where name='MAOW'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='South Central Regional Library'), (select lid from libraries where name='MMIOW'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='South Central Regional Library'), (select lid from libraries where name='MMOW'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='South Central Regional Library'), (select lid from libraries where name='MWOW'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='South Central Regional Library'), (select lid from libraries where name='MWOWH'));

insert into regional_libraries (name) values ('South Interlake Regional Library');
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='South Interlake Regional Library'), (select lid from libraries where name='MSTOS'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='South Interlake Regional Library'), (select lid from libraries where name='MTSIR'));

insert into regional_libraries (name) values ('Southwestern Manitoba Regional Library');
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Southwestern Manitoba Regional Library'), (select lid from libraries where name='MESM'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Southwestern Manitoba Regional Library'), (select lid from libraries where name='MESP'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Southwestern Manitoba Regional Library'), (select lid from libraries where name='MESMN'));

insert into regional_libraries (name) values ('Western Manitoba Regional Library');
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Western Manitoba Regional Library'), (select lid from libraries where name='MHW'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Western Manitoba Regional Library'), (select lid from libraries where name='MBW'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Western Manitoba Regional Library'), (select lid from libraries where name='MCNC'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Western Manitoba Regional Library'), (select lid from libraries where name='MGW'));
insert into regional_libraries_branches (rlid, lid) values ((select rlid from regional_libraries where name='Western Manitoba Regional Library'), (select lid from libraries where name='MNW'));


