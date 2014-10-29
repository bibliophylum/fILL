-- create-sip2-table
create table library_sip2 (
       lid integer primary key not null,
       enabled boolean default false,
       host varchar(1024),
       port integer,
       terminator varchar(5),
       debug integer default 0,
       sip_server_login varchar(255) default null,
       sip_server_password varchar(255) default null
);
