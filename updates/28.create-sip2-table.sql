-- create-sip2-table
-- validate_using_info: Insignia SIP2 server returns incorrect information using the
--   standard Patron Status request.  Use the Patron Info request instead.
create table library_sip2 (
       lid integer primary key not null,
       enabled boolean default false,
       host varchar(1024),
       port integer,
       terminator varchar(5),
       debug integer default 0,
       sip_server_login varchar(255) default null,
       sip_server_password varchar(255) default null,
       validate_using_info boolean default false
);

alter table patrons add is_sip2 boolean default false;
