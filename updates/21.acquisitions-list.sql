-- acquisitions-list.sql
alter table patron_request add column pubdate varchar(20);
alter table patron_request add column isbn varchar(20);

