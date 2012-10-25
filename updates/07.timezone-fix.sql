-- server is UTC

alter table reports_queue alter column ts type timestamp with time zone;
alter table requests_active alter column ts type timestamp with time zone;
alter table requests_history alter column ts type timestamp with time zone;
alter table search_statistics alter column ts type timestamp with time zone;

