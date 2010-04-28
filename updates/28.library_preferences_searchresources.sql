-- allow libraries to specify which resources to search by default
alter table libraries add column use_standardresource boolean default true, add column use_databaseresource boolean default true, add column use_electronicresource boolean default true, add column use_webresource boolean default false;

