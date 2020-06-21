-- allard-to-spruce.sql

insert into org_members (oid,member_id) values ((select oid from org where symbol='SPRUCE'), (select oid from org where symbol='Allard'));

update org set z3950_location = 'St. Georges Branch' where oid=(select oid from org where symbol='MSTG');
update org set z3950_location = 'Victoria Beach Branch' where oid=(select oid from org where symbol='MVBB');

delete from library_z3950 where oid in (select oid from org where org_name like 'Bibliotheque Allard%');

update org set patron_authentication_method='sip2' where symbol in ('MSTG','MVBB');
delete from library_sip2 where oid in (select oid from org where symbol in ('MSTG','MVBB'));
-- copy SIP2 info from another Spruce library:                               
insert into
  library_sip2
  (oid,enabled,host,port,terminator,debug,sip_server_login,sip_server_password,validate_using_info)
  select
    (select oid from org where symbol='MSTG'),
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
insert into library_sip2 (oid,enabled,host,port,terminator,debug,sip_server_login,sip_server_password,validate_using_info) select (select oid from org where symbol='MVBB'), s.enabled, s.host, s.port, s.terminator, s.debug, s.sip_server_login, s.sip_server_password, s.validate_using_info from library_sip2 s where oid=(select oid from org where symbol='MSTOS');

-- also toast pazpar2/settings/Evergreen_Regional*.xml (and ditto ../settings-available/)
