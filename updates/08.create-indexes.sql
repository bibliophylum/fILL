--

create index on requests_active (request_id);
create index on requests_active (msg_from);
create index on requests_active (msg_to);
create index on requests_history (request_id);
create index on requests_history (msg_from);
create index on requests_history (msg_to);
