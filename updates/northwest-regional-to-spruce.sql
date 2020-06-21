-- northwest-regional-to-spruce.sql

insert into org_members (oid,member_id) values ((select oid from org where symbol='SPRUCE'), (select oid from org where symbol='NWRL'));

update org set z3950_location = 'Swan River Branch' where oid=(select oid from org where symbol='MSRN');
update org set z3950_location = 'Benito Branch' where oid=(select oid from org where symbol='MBB');

delete from library_z3950 where oid in (select oid from org where org_name like 'North-West Regional Library%');

update org set patron_authentication_method='sip2' where symbol in ('MSRN','MBB');
delete from library_nonsip2 where oid in (select oid from org where symbol in ('MSRN','MBB'));
-- copy SIP2 info from another Spruce library:                               
insert into
  library_sip2
  (oid,enabled,host,port,terminator,debug,sip_server_login,sip_server_password,validate_using_info)
  select
    (select oid from org where symbol='MSRN'),
    s.enabled,
    s.host,
    s.port,
    s.terminator,
    s.debug,
    s.sip_server_login,
    s.sip_server_password,
    s.validate_using_info
  from
    library_sip2 s
  where
    oid=(select oid from org where symbol='MSTOS')
;
insert into library_sip2 (oid,enabled,host,port,terminator,debug,sip_server_login,sip_server_password,validate_using_info) select (select oid from org where symbol='MBB'), s.enabled, s.host, s.port, s.terminator, s.debug, s.sip_server_login, s.sip_server_password, s.validate_using_info from library_sip2 s where oid=(select oid from org where symbol='MSTOS');
 

-- also toast pazpar2/settings/Evergreen_Regional*.xml (and ditto ../settings-available/)
