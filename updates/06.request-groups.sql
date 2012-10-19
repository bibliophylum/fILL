create sequence request_group_seq;
create table request_group (group_id integer not null default nextval('request_group_seq'::regclass), copies_requested integer default 1, title varchar(1024), author varchar(256), requester integer not null);
alter table request_group add column request_id_temp integer;

insert into request_group (copies_requested, title, author, requester, request_id_temp) select 1, title, author, requester, id from request;
alter table request add column group_id integer;
update request set group_id=rg.group_id from request_group rg where rg.request_id_temp=request.id;

alter table sources add column group_id integer;
update sources set group_id=rg.group_id from request_group rg where rg.request_id_temp=sources.request_id;
alter table sources add column tried boolean default false;

update sources set tried=true;
update sources set tried=false from request r where sources.request_id=r.id and r.current_source_sequence_number < sources.sequence_number;

alter table request_group drop column request_id_temp;

alter table request_closed add column group_id integer;

-- Some unrelated clean-up:
alter table request drop column canada_post_endpoint;
alter table request drop column canada_post_tracking_number;

