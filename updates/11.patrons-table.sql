-- create patrons table for public fILL
create sequence patrons_id_seq;

create table patrons (
       pid integer not null default nextval('patrons_id_seq'::regclass),
       username varchar(80) not null,
       password varchar(80) not null,
       home_library_id integer not null,
       email_address varchar(200),
       is_enabled smallint default 1,
       is_verified smallint default 0,
       last_login timestamp with time zone,
       name varchar(80),
       card varchar(20),
       ill_requests integer default 0
);

create sequence patron_request_seq;

-- this will map to request_group when the library processes their patron's request
-- lid is the patron's home library id (also stored in patrons table, but here for convenience)
create table patron_request (
       prid integer not null default nextval('patron_request_seq'::regclass),
       title varchar(1024),
       author varchar(256),
       pid integer not null,
       lid integer,
       ts timestamp with time zone default now()
);

-- this will map to sources when the library processes their patron's request
-- lid is the library the item was found at
create table patron_request_sources (
       prid integer,
       sequence_number integer not null default 1,
       lid integer,
       call_number varchar(100) 
);
