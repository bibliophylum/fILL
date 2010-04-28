create sequence patrons_id_seq;

create table patrons (
id integer not null default nextval('patrons_id_seq'),
username varchar(80),
password varchar(80),
home_library_id integer,
email_address varchar(200),
is_enabled smallint default 1
);

insert into patrons (username, password, home_library_id, email_address) values ('david', md5('maplin3db'), 101, 'david_a_christensen@hotmail.com');
