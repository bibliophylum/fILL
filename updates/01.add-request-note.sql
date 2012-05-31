-- Add a field so that requesting libraries can give potential lenders a note about their request
alter table request add column note varchar(80);
alter table request_closed add column note varchar(80);