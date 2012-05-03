create table reports_queue (ts timestamp without time zone default now(), rid integer not null, lid integer not null, range_start char(10), range_end char(10));
create table reports_complete (lid integer not null, rid integer not null, range_start char(10), range_end char(10), report_file varchar(100));
