-- 14.holds.sql
--
alter table request_group add column place_on_hold varchar(14);
alter table history_group add column place_on_hold varchar(14);
