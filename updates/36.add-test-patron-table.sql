-- add-test-patron-table
create table library_test_patron (oid integer primary key, barcode varchar(14), pin varchar(20), last_tested timestamp with time zone, test_result varchar(100));

alter table library_test_patron add foreign key (oid) references org (oid);

