-- need indexes on sources
create index on sources (group_id);
create index on sources (request_id);

-- create the history table
create table sources_history (request_id integer, sequence_number integer not null default 1, lid integer, call_number varchar(100), group_id integer, tried boolean default false);
create index on sources_history (group_id);
create index on sources_history (request_id);

