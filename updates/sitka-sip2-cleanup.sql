-- sitka-sip2-cleanup.sql

update library_sip2 set host='MSRN.sitka.sip2.libraries.coop' where oid=46;
update library_sip2 set host='MVBB.sitka.sip2.libraries.coop' where oid=136;
update library_sip2 set host='MBB.sitka.sip2.libraries.coop' where oid=47;
update library_sip2 set host='MSTGA.sitka.sip2.libraries.coop' where oid=10;
update library_sip2 set host='MHH.sitka.sip2.libraries.coop' where oid=35;

-- ...and a typo fix:
update org set org_name='South Interlake Regional Library - Stonewall' where oid=85;

