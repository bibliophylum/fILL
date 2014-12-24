-- add-isbn-pubdate-to-request-group
alter table request_group add column isbn varchar(40);
alter table request_group add column pubdate varchar(40);

-- and acq needs a default timestamp and a 'medium' column
alter table acquisitions alter ts set default now();
alter table acquisitions add column medium varchar(80);
alter table acquisitions add column pid integer;
