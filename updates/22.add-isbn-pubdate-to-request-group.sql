-- add-isbn-pubdate-to-request-group
alter table request_group add column isbn varchar(40);
alter table request_group add column pubdate varchar(40);

-- and acq needs a default timestamp
alter table acquisitions alter ts set default now();
