-- acquisitions-list.sql
alter table patron_request add column pubdate varchar(40);
alter table patron_request add column isbn varchar(40);

create table acquisitions (
       lid integer not null,
       title varchar(1024),
       author varchar(256),
       isbn varchar(40),
       pubdate varchar(40),
       ts timestamp with time zone,
       medium varchar(80),
       pid integer
);
create index on acquisitions (lid);
create index on acquisitions (ts);

       
