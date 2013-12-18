-- 
create table rotations_order (
 from_lid integer not null,
 to_lid integer not null
);

insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MWPL'), (select lid from libraries where name='MLB'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MLB'),  (select lid from libraries where name='MSTP'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MSTP'), (select lid from libraries where name='MSSM'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MSSM'), (select lid from libraries where name='MHH'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MHH'),  (select lid from libraries where name='MBBR'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MBBR'), (select lid from libraries where name='MLDB'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MLDB'), (select lid from libraries where name='MP'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MP'),   (select lid from libraries where name='MSTG'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MSTG'), (select lid from libraries where name='MVBB'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MVBB'), (select lid from libraries where name='MBBB'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MBBB'), (select lid from libraries where name='MWPL'));

insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MWPL'), (select lid from libraries where name='MNDP'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MNDP'), (select lid from libraries where name='MCB'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MCB'),  (select lid from libraries where name='MMIOW'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MMIOW'),(select lid from libraries where name='MMOW'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MMOW'), (select lid from libraries where name='MWOW'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MWOW'), (select lid from libraries where name='MAOW'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MAOW'), (select lid from libraries where name='MMVR'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MMVR'), (select lid from libraries where name='MRA'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MRA'),  (select lid from libraries where name='MMR'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MMR'),  (select lid from libraries where name='MMNN'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MMNN'), (select lid from libraries where name='MHP'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MHP'),  (select lid from libraries where name='MBA'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MBA'),  (select lid from libraries where name='MWPL'));

insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MWPL'), (select lid from libraries where name='ME'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='ME'),   (select lid from libraries where name='MVE'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MVE'),  (select lid from libraries where name='MRP'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MRP'),  (select lid from libraries where name='MESM'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MESM'), (select lid from libraries where name='MBOM'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MBOM'), (select lid from libraries where name='MKL'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MKL'),  (select lid from libraries where name='MCCB'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MCCB'), (select lid from libraries where name='MPM'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MPM'),  (select lid from libraries where name='MMA'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MMA'),  (select lid from libraries where name='MSOG'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MSOG'), (select lid from libraries where name='MWPL'));

insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MWPL'), (select lid from libraries where name='MSTR'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MSTR'), (select lid from libraries where name='MRO'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MRO'),  (select lid from libraries where name='MBI'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MBI'),  (select lid from libraries where name='MRD'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MRD'),  (select lid from libraries where name='MSRN'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MSRN'), (select lid from libraries where name='MGE'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MGE'),  (select lid from libraries where name='MLPJ'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MLPJ'), (select lid from libraries where name='MEL'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MEL'),  (select lid from libraries where name='MLR'));
insert into rotations_order (from_lid, to_lid) values ((select lid from libraries where name='MLR'),  (select lid from libraries where name='MWPL'));

--
delete from rotations_participants;
insert into rotations_participants (select distinct to_lid from rotations_order);
