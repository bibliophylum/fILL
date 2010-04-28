-- Move the necessary data from public_libraryregionandtown into libraries
-- and toast the old table
alter table libraries add column town varchar(50);
alter table libraries add column region varchar(15);
update libraries set town = (select town from public_libraryregionandtown where libraries.lid = public_libraryregionandtown.lid);
update libraries set region = (select region from public_libraryregionandtown where libraries.lid = public_libraryregionandtown.lid);
drop table public_libraryregionandtown;
