-- add a table to hold zerocirc (CDT) info
create sequence zerocirc_id_seq;

create table zerocirc (
    id integer not null default nextval('zerocirc_id_seq'),
    collection character varying(20),
    pubdate character varying(10),
    callno character varying(40),
    title character varying(1024),
    author character varying(1024),
    claimed_by character varying(15),
    claimed_timestamp timestamp without time zone
);
