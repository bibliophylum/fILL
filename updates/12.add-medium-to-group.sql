--
--
alter table request_group add column medium varchar(80);
alter table history_group add column medium varchar(80);

alter table patron_request add column medium varchar(80);
