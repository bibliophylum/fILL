-- patron-request-indicator.sql
alter table request_group add column patron_generated boolean default false;
alter table history_group add column patron_generated boolean default false;
