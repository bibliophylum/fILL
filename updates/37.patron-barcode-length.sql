-- Need to adjust request_group patron barcode length to match similar fields
-- DAVID NOTE: this has already been done on production!  This file is for future reference :-)

alter table request_group alter column patron_barcode type varchar(40);
