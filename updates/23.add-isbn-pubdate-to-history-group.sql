-- add-isbn-pubdate-to-history-group
alter table history_group add column isbn varchar(40);
alter table history_group add column pubdate varchar(40);

