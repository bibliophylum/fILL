-- create rotations tables
create sequence rotations_id_seq;

create table rotations (
       id integer not null default nextval('rotations_id_seq'::regclass),
       barcode varchar(14),
       title varchar(1024),
       author varchar(256),
       callno varchar(50),
       current_library integer,
       previous_library integer,
       ts timestamp with time zone default now(),
       marc bytea
);

create index on rotations (barcode);

create table rotations_participants (
       lid integer not null
);

create table rotations_stats (
       barcode varchar(14),
       lid integer not null,
       ts_start timestamp with time zone,
       ts_end timestamp with time zone,
       circs integer default 0
);

create index on rotations_stats (barcode);
create index on rotations_stats (lid);
create index on rotations_stats (ts_start);
create index on rotations_stats (ts_end);

create table rotations_lib_holdings_fields (
       lid integer not null,
       holdings_field varchar(3) not null,
       barcode_subfield char(1) not null,
       callno_subfield char(1),
       library_subfield char(1),
       library_default varchar(50),
       location_subfield char(1),
       location_default varchar(50),
       collection_subfield char(1),
       collection_default varchar(50)
);

       