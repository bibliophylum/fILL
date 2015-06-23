-- 32.public-featured.sql

create sequence featured_id_seq;

create table featured (
       fid integer primary key default nextval('featured_id_seq'::regclass),
       isbn varchar(20),
       title varchar(256),
       author varchar(100),
       cover varchar(1024),
       added timestamp with time zone default now()
);
       
