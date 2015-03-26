-- the library_systems table associates branches with their HQ libraries in regional systems
insert into library_systems (parent_id, child_id) values ((select lid from libraries where name=''),(select lid from libraries where name=''));

insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MSTG'),(select lid from libraries where name='MBBB'));
insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MSTG'),(select lid from libraries where name='MVBB'));

insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MSTP'),(select lid from libraries where name='MSSM'));

insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MIBR'),(select lid from libraries where name='MSAD'));
insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MIBR'),(select lid from libraries where name='MSAG'));

insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MVE'),(select lid from libraries where name='ME'));
insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MVE'),(select lid from libraries where name='MMCA'));

insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MDB'),(select lid from libraries where name='TWAS'));

insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MGE'),(select lid from libraries where name='MAB'));
insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MGE'),(select lid from libraries where name='MRB'));

insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MKL'),(select lid from libraries where name='MCCB'));

insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MSRN'),(select lid from libraries where name='MBB'));

insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MWOWH'),(select lid from libraries where name='MAOW'));
insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MWOWH'),(select lid from libraries where name='MMOW'));
insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MWOWH'),(select lid from libraries where name='MMIOW'));
insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MWOWH'),(select lid from libraries where name='MWOW'));

insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MSTOS'),(select lid from libraries where name='MTSIR'));

insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MESM'),(select lid from libraries where name='MESP'));
insert into library_systems (parent_id, child_id) values ((select lid from libraries where name='MESM'),(select lid from libraries where name='MESMN'));

-- parkland and western manitoba regional are already there
