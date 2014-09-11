-- 20.patron_requests_declined.sql

create table patron_requests_declined (
       prid integer,
       title varchar(1024),
       author varchar(256),
       pid integer,
       lid integer,
       ts timestamp with time zone default now(),
       medium varchar(80),
       reason varchar(80),
       message varchar(256)
);
create index on patron_requests_declined (pid);
create index on patron_requests_declined (lid);
