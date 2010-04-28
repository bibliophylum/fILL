-- This will toast any existing patrons!
-- (fortunately, we're not in use in the real world yet :-)
drop table if exists patrons;
drop sequence if exists patrons_id_seq;

create sequence patrons_id_seq;
create table patrons (
       pid integer not null default nextval('patrons_id_seq'),
       username varchar(80) unique not null,
       password varchar(80),
       home_library_id integer,
       email_address varchar(200),
       is_enabled smallint default 1,
       verified smallint default 0,
       last_login timestamp without time zone,
       name varchar(80),
       card varchar(20)
);

-- test data
insert into patrons (username, password, home_library_id, email_address, name, card) values ('david', md5('maplin3db'), 101, 'david_a_christensen@hotmail.com','David Christensen','0001');

alter table users add column unverified_patron_request_limit integer default 2;
update users set unverified_patron_request_limit=2 where unverified_patron_request_limit is null;

create table patron_unverified_request_count (pid integer, request_count integer);
