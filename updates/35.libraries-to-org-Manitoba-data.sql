-- libraries-to-org-Manitoba-data.sql
insert into org (symbol, org_name, orgtype) values ('Allard','Bibliotheque Allard Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Allard'),(select oid from org where symbol='MSTG'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Allard'),(select oid from org where symbol='MVBB'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Allard'),(select oid from org where symbol='MBBB'));
update org set orgtype=1 where symbol in ('MSTG','MVBB','MBBB');

insert into org (symbol, org_name, orgtype) values ('Ritchot','Bibliotheque Ritchot Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Ritchot'),(select oid from org where symbol='MIBR'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Ritchot'),(select oid from org where symbol='MSAD'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Ritchot'),(select oid from org where symbol='MSAG'));
update org set orgtype=1 where symbol in ('MIBR','MSAD','MSAG');

insert into org (symbol, org_name, orgtype) values ('BrenDelWin','Bren Del Win Centennial Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='BrenDelWin'),(select oid from org where symbol='MDB'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='BrenDelWin'),(select oid from org where symbol='TWAS'));
update org set orgtype=1 where symbol in ('MDB','TWAS');

insert into org (symbol, org_name, orgtype) values ('Border','Border Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Border'),(select oid from org where symbol='MVE'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Border'),(select oid from org where symbol='ME'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Border'),(select oid from org where symbol='MMCA'));
update org set orgtype=1 where symbol in ('MVE','ME','MMCA');

insert into org (symbol, org_name, orgtype) values ('Evergreen Regional','Evergreen Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Evergreen Regional'),(select oid from org where symbol='MGE'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Evergreen Regional'),(select oid from org where symbol='MAB'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Evergreen Regional'),(select oid from org where symbol='MRB'));
update org set orgtype=1 where symbol in ('MGE','MAB','MRB');

insert into org (symbol, org_name, orgtype) values ('Jolys','Bibliotheque Jolys Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Jolys'),(select oid from org where symbol='MSTP'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Jolys'),(select oid from org where symbol='MSSM'));
update org set orgtype=1 where symbol in ('MSTP','MSSM');

insert into org (symbol, org_name, orgtype) values ('Lakeland','Lakeland Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Lakeland'),(select oid from org where symbol='MKL'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Lakeland'),(select oid from org where symbol='MCCB'));
update org set orgtype=1 where symbol in ('MKL','MCCB');

insert into org (symbol, org_name, orgtype) values ('NWRL','North-West Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='NWRL'),(select oid from org where symbol='MSRN'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='NWRL'),(select oid from org where symbol='MBB'));
update org set orgtype=1 where symbol in ('MSRN','MBB');

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
update org set orgtype=1 where symbol in ('MDA','MDP','MDPBR','MDPBI','MDPBO','MDPER','MDPFO','MDPGP','MDPGL','MDPGV','MDPHA','MDPLA','MDPMC','MDPMI','MDPRO','MDPSL','MDPSI','MDPST','MDPWP','MRO');

--insert into org (symbol, org_name, orgtype) values ('SCRL','South Central Regional Library',3);
update org set symbol='SCRL' where symbol='MWOWH';
update org set org_name='South Central Regional Library' where symbol='SCRL';
update org set orgtype=3 where symbol='SCRL';
insert into org_members (oid, member_id) values ((select oid from org where symbol='SCRL'),(select oid from org where symbol='MWOW'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='SCRL'),(select oid from org where symbol='MAOW'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='SCRL'),(select oid from org where symbol='MMOW'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='SCRL'),(select oid from org where symbol='MMIOW'));
update org set orgtype=1 where symbol in ('MWOW','MAOW','MMOW','MMIOW');

insert into org (symbol, org_name, orgtype) values ('SIRL','South Interlake Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='SIRL'),(select oid from org where symbol='MSTOS'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='SIRL'),(select oid from org where symbol='MTSIR'));
update org set orgtype=1 where symbol in ('MSTOS','MTSIR');

insert into org (symbol, org_name, orgtype) values ('Southwestern','Southwestern Manitoba Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Southwestern'),(select oid from org where symbol='MESM'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Southwestern'),(select oid from org where symbol='MESMN'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Southwestern'),(select oid from org where symbol='MESP'));
update org set orgtype=1 where symbol in ('MESM','MESMN','MESP');

insert into org (symbol, org_name, orgtype) values ('WMRL','Western Manitoba Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='WMRL'),(select oid from org where symbol='MBW'));
update org set can_forward_to_siblings=true where symbol='MBW';
insert into org_members (oid, member_id) values ((select oid from org where symbol='WMRL'),(select oid from org where symbol='MHW'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='WMRL'),(select oid from org where symbol='MCNC'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='WMRL'),(select oid from org where symbol='MGW'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='WMRL'),(select oid from org where symbol='MNW'));
update org set orgtype=1 where symbol in ('MBW','MHW','MCNC','MGW','MNW');

insert into org (symbol, org_name, orgtype) values ('Russell','Russell and District Regional Library',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='Russell'),(select oid from org where symbol='MRD'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='Russell'),(select oid from org where symbol='MBI'));
update org set orgtype=1 where symbol in ('MRD','MBI');

insert into org (symbol, org_name, orgtype) values ('UCN','University College of the North',3);
insert into org_members (oid, member_id) values ((select oid from org where symbol='UCN'),(select oid from org where symbol='MTK'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='UCN'),(select oid from org where symbol='MTPK'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='UCN'),(select oid from org where symbol='MEC'));
insert into org_members (oid, member_id) values ((select oid from org where symbol='UCN'),(select oid from org where symbol='MNH'));
update org set orgtype=1 where symbol in ('MTK','MTPK','MEC','MNH');

insert into org (symbol, org_name, orgtype) values ('Spruce','Spruce Libraries Cooperative',5);
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

update library_z3950 set oid=(select oid from org_members where member_id=10) where oid=10;
update library_z3950 set oid=(select oid from org_members where member_id=13) where oid=13;
update library_z3950 set oid=(select oid from org_members where member_id=36) where oid=36;
update library_z3950 set oid=(select oid from org_members where member_id=39) where oid=39;
update library_z3950 set oid=(select oid from org_members where member_id=53) where oid=53;
update library_z3950 set oid=(select oid from org_members where member_id=94) where oid=94;

insert into library_z3950 (
 oid,
 server_address,
 server_port,
 database_name,
 request_syntax, 
 elements, 
 nativesyntax, 
 xslt, 
 index_keyword,
 index_author,
 index_title,
 index_subject,
 index_isbn,
 index_issn,
 index_date
) values (
 (select oid from org where symbol='Spruce'),
 'catalogue.libraries.coop',
 210,
 'SPRUCE',
 'marc21',
 'F',
 'iso2709',
 'marc21.xsl',
 'u=1016 t=l,r s=al 2=102',
 'u=1003 s=al',
 'u=4 s=al 2=102',
 'u=21 s=al 2=102',
 'u=7 2=102',
 'u=8 2=102',
 'u=30 r=r 2=102'
);


-- Destiny libraries
-- Destiny z39.50 server doesn't understand relation attrubute "relevance" (2=102) in 'any' index (u=1016); use "equal" instead (2=3).
update library_z3950 set index_keyword='u=1016 t=l,r s=al 2=3' where oid in (select oid from org where symbol in ('MBBR','Allard','MHH','MSEL','MRP','MLDB','MDS','MEL','Jolys'));


-- Special processing
update library_z3950 set special_processing=E'  <!-- don\'t include records that don\'t have 852$b="JRL" -->\n  <set name="pz:recordfilter" value="holding-mstp-location=JRL"/>' where oid=(select oid from org where symbol='Jolys');
