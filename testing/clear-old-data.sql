-- clear all existing ILL requests, history, etc, and reset the sequence
delete from requests_history;
delete from request_closed;
delete from requests_active;
delete from sources;
delete from request;
alter sequence request_seq restart with 1;
