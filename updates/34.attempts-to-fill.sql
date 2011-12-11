-- I was confusing 'filled_by' (the library id) with 'filled_by' (the sequence number)
alter table request_closed add column attempts integer;