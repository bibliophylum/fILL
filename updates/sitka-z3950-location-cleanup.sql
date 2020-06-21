-- sitka-z3950-location-cleanup.sql

-- Sitka z3950 server used to return library names; now it returns symbols:
update org set z3950_location = symbol where oid in (select oid from library_sip2 where host like '%sitka.sip2%');

-- Sometimes, those symbols don't match our symbols:
update org set z3950_location = 'MSTGA' where symbol='MSTG';
update org set z3950_location = 'MSTL' where symbol='MDPSLA';
update org set z3950_location = 'MRUS' where symbol='Russell';
