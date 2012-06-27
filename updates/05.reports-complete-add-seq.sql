create sequence reports_complete_seq;
drop table reports_complete;
create table reports_complete (
rcid integer not null default nextval('reports_complete_seq'::regclass),
lid integer not null,
rid integer not null,
range_start character(10),
range_end character(10),
report_file varchar(100)
);
