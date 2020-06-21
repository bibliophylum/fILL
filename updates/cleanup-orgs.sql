-- cleanup-orgs: toast unused orgs (i.e. previously used for testing)
--select o.oid,o.symbol,o.org_name,o.last_login::date,t.type from org o left join orgtype t on t.otid=o.orgtype where o.patron_authentication_method is null order by o.org_name;

delete from library_barcodes where oid=(select oid from org where symbol='UNC');
delete from library_barcodes where borrower=(select oid from org where symbol='UNC');
delete from org where symbol='UNC';

delete from library_barcodes where oid=(select oid from org where symbol='test');
delete from library_barcodes where borrower=(select oid from org where symbol='test');
delete from org where symbol='test';

delete from library_barcodes where oid=(select oid from org where symbol='TEST');
delete from library_barcodes where borrower=(select oid from org where symbol='TEST');
delete from org where symbol='TEST';

delete from library_barcodes where oid=(select oid from org where symbol='MSERC');
delete from library_barcodes where borrower=(select oid from org where symbol='MSERC');
delete from users where oid=(select oid from org where symbol='MSERC');
delete from org where symbol='MSERC';

delete from library_barcodes where oid=(select oid from org where symbol='CPL');
delete from library_barcodes where borrower=(select oid from org where symbol='CPL');
delete from users where oid=(select oid from org where symbol='CPL');
delete from org where symbol='CPL';

delete from library_barcodes where oid=(select oid from org where symbol='MWJ');
delete from library_barcodes where borrower=(select oid from org where symbol='MWJ');
delete from users where oid=(select oid from org where symbol='MWJ');
delete from org where symbol='MWJ';

delete from library_barcodes where oid=(select oid from org where symbol='MWHBCA');
delete from library_barcodes where borrower=(select oid from org where symbol='MWHBCA');
delete from users where oid=(select oid from org where symbol='MWHBCA');
delete from org where symbol='MWHBCA';

delete from library_barcodes where oid=(select oid from org where symbol='MWMRC');
delete from library_barcodes where borrower=(select oid from org where symbol='MWMRC');
delete from users where oid=(select oid from org where symbol='MWMRC');
delete from org where symbol='MWMRC';

delete from library_barcodes where oid=(select oid from org where symbol='OKE');
delete from library_barcodes where borrower=(select oid from org where symbol='OKE');
delete from users where oid=(select oid from org where symbol='OKE');
delete from org where symbol='OKE';

delete from library_barcodes where oid=(select oid from org where symbol='MWEMM');
delete from library_barcodes where borrower=(select oid from org where symbol='MWEMM');
delete from users where oid=(select oid from org where symbol='MWEMM');
delete from org where symbol='MWEMM';

delete from library_barcodes where oid=(select oid from org where symbol='MWTS');
delete from library_barcodes where borrower=(select oid from org where symbol='MWTS');
delete from users where oid=(select oid from org where symbol='MWTS');
delete from org where symbol='MWTS';

delete from library_barcodes where oid=(select oid from org where symbol='Caitlyn');
delete from library_barcodes where borrower=(select oid from org where symbol='Caitlyn');
delete from users where oid=(select oid from org where symbol='Caitlyn');
delete from org where symbol='Caitlyn';

delete from library_barcodes where oid=(select oid from org where symbol='Margo');
delete from library_barcodes where borrower=(select oid from org where symbol='Margo');
delete from users where oid=(select oid from org where symbol='Margo');
delete from org where symbol='Margo';

delete from library_barcodes where oid=(select oid from org where symbol='MWSC');
delete from library_barcodes where borrower=(select oid from org where symbol='MWSC');
delete from users where oid=(select oid from org where symbol='MWSC');
delete from org where symbol='MWSC';

delete from library_barcodes where oid=(select oid from org where symbol='ASGY');
delete from library_barcodes where borrower=(select oid from org where symbol='ASGY');
delete from users where oid=(select oid from org where symbol='ASGY');
delete from org where symbol='ASGY';

delete from library_barcodes where oid=(select oid from org where symbol='PLS1');
delete from library_barcodes where borrower=(select oid from org where symbol='PLS1');
delete from users where oid=(select oid from org where symbol='PLS1');
delete from org where symbol='PLS1';
delete from library_barcodes where oid=(select oid from org where symbol='PLS2');
delete from library_barcodes where borrower=(select oid from org where symbol='PLS2');
delete from users where oid=(select oid from org where symbol='PLS2');
delete from org where symbol='PLS2';
delete from library_barcodes where oid=(select oid from org where symbol='PLS3');
delete from library_barcodes where borrower=(select oid from org where symbol='PLS3');
delete from users where oid=(select oid from org where symbol='PLS3');
delete from org where symbol='PLS3';
delete from library_barcodes where oid=(select oid from org where symbol='PLS4');
delete from library_barcodes where borrower=(select oid from org where symbol='PLS4');
delete from users where oid=(select oid from org where symbol='PLS4');
delete from org where symbol='PLS4';
delete from library_barcodes where oid=(select oid from org where symbol='PLS5');
delete from library_barcodes where borrower=(select oid from org where symbol='PLS5');
delete from users where oid=(select oid from org where symbol='PLS5');
delete from org where symbol='PLS5';
delete from library_barcodes where oid=(select oid from org where symbol='PLS6');
delete from library_barcodes where borrower=(select oid from org where symbol='PLS6');
delete from users where oid=(select oid from org where symbol='PLS6');
delete from org where symbol='PLS6';
