-- 43.libraries-using-L4U_API-authentication.sql

update org set patron_authentication_method = 'L4U_API' where oid=(select oid from org where symbol='MSRN');
update library_nonsip2 set auth_type='L4U_API', url='http://216.36.186.16/4DACTION/Overdrive_Auth' where oid=(select oid from org where symbol='MSRN');

update org set patron_authentication_method = 'L4U_API' where oid=(select oid from org where symbol='MBB');
update library_nonsip2 set auth_type='L4U_API', url='http://ipac.benitolibrary.ca/4DACTION/Overdrive_Auth' where oid=(select oid from org where symbol='MBB');

update org set patron_authentication_method = 'L4U_API' where oid=(select oid from org where symbol='MGI');
update library_nonsip2 set auth_type='L4U_API', url='http://bettewinner.townofgillam.com/4DACTION/Overdrive_Auth' where oid=(select oid from org where symbol='MGI');

update org set patron_authentication_method = 'L4U_API' where oid=(select oid from org where symbol='MTP');
update library_nonsip2 set auth_type='L4U_API', url='http://206.45.107.73/4DACTION/Overdrive_Auth' where oid=(select oid from org where symbol='MTP');

