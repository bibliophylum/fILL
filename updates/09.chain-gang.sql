-- This will make it so that any given Request is the conversation between two libraries (borrower and potential lender) only.
-- It implements request "chains" - when a library gets an Unfilled response from a potential lender, a new Request to the
-- next available source is added to the chain.
-- A multi-copy request group (e.g. bookclub requests) will have one chain per copy requested (up to the number of sources available),
-- all of which share a sources list.
--
-- It can take some time to run....
--

BEGIN;

-- add the required fields from the request table to the request_group table
alter table request_group add column patron_barcode character(14);
alter table request_group add column note varchar(80);
update request_group set patron_barcode = r.patron_barcode, note = r.note from request r where request_group.group_id = r.group_id;

-- remove the duplicated fields from request
alter table request drop column title;
alter table request drop column author;
alter table request drop column patron_barcode;
alter table request drop column note;

-- create the chain structure and populate with initial data
create sequence request_chain_seq;
create table request_chain (chain_id integer not null default nextval('request_chain_seq'::regclass), group_id integer not null);
alter table request_chain add column request_id integer not null;
insert into request_chain (group_id, request_id) select group_id, id from request;
alter table request add column chain_id integer;
update request set chain_id=c.chain_id from request_chain c where c.group_id=request.group_id;

alter table requests_active add column chain_id integer;
update requests_active set chain_id=r.chain_id from request r where r.id=requests_active.request_id;
alter table requests_active add column conversation_with integer;
update requests_active set conversation_with=(case when msg_from=(select r.requester from request r where r.id=requests_active.request_id) then msg_to else msg_from end);
alter table requests_active add column requester integer;
update requests_active set requester=(case when msg_from=(select r.requester from request r where r.id=requests_active.request_id) then msg_from else msg_to end);

alter table request add column conversation_with integer;
update request set conversation_with=ra.conversation_with from requests_active ra where ra.request_id=request.id and ra.ts=(select min(ra2.ts) from requests_active ra2 where ra2.request_id=ra.request_id);

--select count(*) from request where id not in (select distinct request_id from requests_active);
--select count(*) from sources where request_id not in (select distinct request_id from requests_active);

delete from sources where request_id not in (select distinct request_id from requests_active);
delete from request where id not in (select distinct request_id from requests_active);

-- there are still some (210, actually, from back in the old days) where msg_to is null... which we'll deal with later.
--select r.id, r.requester, r.group_id, r.chain_id, ra.ts, ra.msg_from, ra.msg_to, ra.status from request r left join requests_active ra on ra.request_id=r.id where r.conversation_with is null;

alter table requests_active add column group_id integer;
update requests_active set group_id=r.group_id from request r where r.id=requests_active.request_id;

-- requests_active now contains everything we need to create the new requests

-- create the new requests for each separate conversation
insert into request (requester, group_id, chain_id, conversation_with) (select ra.requester, ra.group_id, ra.chain_id, ra.conversation_with from requests_active ra where ra.status='ILL-Request' and ra.conversation_with not in (select r.conversation_with from request r where r.id=ra.request_id));
-- move the separate-conversation parts to the newly created requests
update requests_active set request_id=r.id from request r where r.group_id=requests_active.group_id and r.chain_id=requests_active.chain_id and r.conversation_with=requests_active.conversation_with;


-- gives us:   ALMOST RIGHT! - the only fiddly bit left is where msg_from = msg_to ('Trying next source', 'No further sources').
--             Do we need these?  Should they be a part of the preceding ILL-Answer request?  Hmm.
-- The 'Trying next source' message to oneself isn't used anywhere except the reports, which is what we're setting this all up to work on.
-- The 'No further sources' is used in sanity-checking some overrides.

--maplin=# select * from request where chain_id=2913;
--  id   | requester | current_source_sequence_number | group_id | chain_id | conversation_with 
---------+-----------+--------------------------------+----------+----------+-------------------
--  3010 |        32 |                              4 |     3531 |     2913 |                78
-- 10440 |        32 |                              1 |     3531 |     2913 |                35
-- 10443 |        32 |                              1 |     3531 |     2913 |                82
-- 10450 |        32 |                              1 |     3531 |     2913 |                20
--(4 rows)
--
--maplin=# select request_id, ts, msg_from, msg_to, status, message from requests_active where chain_id=2913 order by ts;
-- request_id |              ts               | msg_from | msg_to |               status               |          message          
--------------+-------------------------------+----------+--------+------------------------------------+---------------------------
--       3010 | 2012-08-21 10:25:53.648481-05 |       32 |     78 | ILL-Request                        | 
--       3010 | 2012-08-21 13:30:13.479027-05 |       78 |     32 | ILL-Answer|Unfilled|in-use-on-loan | 
--       3010 | 2012-08-21 13:31:26.22424-05  |       32 |     32 | Message                            | Trying next source
--      10440 | 2012-08-21 13:31:26.231539-05 |       32 |     35 | ILL-Request                        | 
--      10440 | 2012-08-21 13:39:19.728364-05 |       35 |     32 | ILL-Answer|Unfilled|policy-problem | 
--       3010 | 2012-08-21 14:12:50.084-05    |       32 |     32 | Message                            | Trying next source
--      10443 | 2012-08-21 14:12:50.147001-05 |       32 |     82 | ILL-Request                        | 
--      10443 | 2012-08-21 15:28:12.616203-05 |       82 |     32 | ILL-Answer|Unfilled|in-use-on-loan | 
--       3010 | 2012-08-21 15:44:42.994254-05 |       32 |     32 | Message                            | Trying next source
--      10450 | 2012-08-21 15:44:43.008953-05 |       32 |     20 | ILL-Request                        | 
--      10450 | 2012-08-21 16:55:29.127463-05 |       20 |     32 | ILL-Answer|Unfilled|in-use-on-loan | 
--      10450 | 2012-08-22 15:59:29.362239-05 |       32 |     20 | Message                            | MFF is trying next lender
--      10450 | 2012-08-22 15:59:29.375005-05 |       32 |     20 | Cancelled                          | override by MFF
--      10450 | 2012-08-22 15:59:29.40995-05  |       20 |     32 | CancelReply|Ok                     | override by MFF
--       3010 | 2012-08-22 15:59:29.420778-05 |       32 |     32 | Message                            | No further sources
--(15 rows)

-- this bit will find the timestamp for the preceding ILL-Answer:
--select max(ts) from requests_active where chain_id=2913 and status like 'ILL-Answer%' and ts < '2012-08-21 15:44:42.994254-05';

--select ra.request_id, ra.ts, ra2.request_id, ra2.ts, ra2.status from requests_active ra join requests_active ra2 on ra2.chain_id=ra.chain_id where ra.chain_id=2913 and ra.status='Message' and ra.requester=ra.conversation_with and ra2.ts=(select max(ts) from requests_active where chain_id=ra.chain_id and status like 'ILL-Answer%' and ts<ra.ts);

-- create a table holding the request_active request_id and ts to be updated, and the new request_id to replace the existing one.
create table temp_ra_updates as (select ra.request_id, ra.ts, ra2.request_id as new_request_id, ra2.ts as prev_ts, ra2.status from requests_active ra join requests_active ra2 on ra2.chain_id=ra.chain_id where ra.status='Message' and ra.requester=ra.conversation_with and ra2.ts=(select max(ts) from requests_active where chain_id=ra.chain_id and status='ILL-Request' and ts<ra.ts));

-- number of rows added to that table should equal:
--select count(*) from requests_active where status='Message' and requester=conversation_with;

-- ok, let's fix those message-to-self ones
update requests_active set request_id=tru.new_request_id from temp_ra_updates tru where tru.request_id=requests_active.request_id and tru.ts=requests_active.ts;

-- now some clean-up
drop table temp_ra_updates;
alter table request_chain drop column request_id;
alter table request drop column group_id;
alter table request drop column conversation_with;
alter table requests_active drop column requester;
alter table requests_active drop column conversation_with;
alter table requests_active drop column chain_id;
alter table requests_active drop column group_id;
create index on requests_active (request_id);

--
--
-- Now, do the same thing to history
--
--

-- add the required fields from the request_closed table to the request_group table
-- As there is no history_group table yet, let's make it:
create sequence history_group_seq increment -1;
create table history_group (group_id integer not null default nextval('history_group_seq'::regclass), copies_requested integer default 1, title varchar(1024), author varchar(256), requester integer not null, patron_barcode character(14), note varchar(80));
alter table history_group add column request_id_temp integer;

insert into history_group (title, author, requester, request_id_temp) select title, author, requester, id from request_closed;
--alter table request_closed add column group_id integer;
update request_closed set group_id=rg.group_id from history_group rg where rg.request_id_temp=request_closed.id;

update history_group set patron_barcode = r.patron_barcode, note = r.note from request_closed r where history_group.group_id = r.group_id;

-- these will come from request_group as a request moves to history....
alter table history_group alter column group_id drop default;
drop sequence history_group_seq;

-- remove the duplicated fields from request_closed
alter table request_closed drop column title;
alter table request_closed drop column author;
alter table request_closed drop column patron_barcode;
alter table request_closed drop column note;

-- create the chain structure and populate with initial data
-- history_chain values, for existing (migrated) data, will be negative numbers so as not to conflict with
--   chain numbers from the active requests that will get moved to history later.
create sequence history_chain_seq increment -1;
create table history_chain (chain_id integer not null default nextval('history_chain_seq'::regclass), group_id integer not null);
alter table history_chain add column request_id integer not null;
insert into history_chain (group_id, request_id) select group_id, id from request_closed;
alter table request_closed add column chain_id integer;
update request_closed set chain_id=c.chain_id from history_chain c where c.group_id=request_closed.group_id;
alter table history_chain alter column chain_id drop default;
drop sequence history_chain_seq;

alter table requests_history add column chain_id integer;
update requests_history set chain_id=r.chain_id from request_closed r where r.id=requests_history.request_id;
alter table requests_history add column conversation_with integer;
update requests_history set conversation_with=(case when msg_from=(select r.requester from request_closed r where r.id=requests_history.request_id) then msg_to else msg_from end);
alter table requests_history add column requester integer;
update requests_history set requester=(case when msg_from=(select r.requester from request_closed r where r.id=requests_history.request_id) then msg_from else msg_to end);

alter table request_closed add column conversation_with integer;
update request_closed set conversation_with=ra.conversation_with from requests_history ra where ra.request_id=request_closed.id and ra.ts=(select min(ra2.ts) from requests_history ra2 where ra2.request_id=ra.request_id);

--select count(*) from request_closed where id not in (select distinct request_id from requests_history);
--select count(*) from sources where request_id not in (select distinct request_id from requests_history);

-- Don't care about sources list for history (and besides, we've already toasted them)
--delete from sources where request_id not in (select distinct request_id from requests_history);

-- Not necessary, as the only way for a request to make it to history involves having a requests_active that also makes it to history.
--delete from request_closed where id not in (select distinct request_id from requests_history);

alter table requests_history add column group_id integer;
update requests_history set group_id=r.group_id from request_closed r where r.id=requests_history.request_id;

-- requests_history now contains everything we need to create the new requests

-- create the new requests for each separate conversation
-- we need to create a temporary sequence to give new id numbers to newly-created history requests.  These id numbers will
--   be negative, so as not to conflict with current (active) requests that will be moved to history later.
create sequence request_closed_seq increment -1;
alter table request_closed alter column id set default nextval('request_closed_seq'::regclass);
insert into request_closed (requester, group_id, chain_id, conversation_with) (select ra.requester, ra.group_id, ra.chain_id, ra.conversation_with from requests_history ra where ra.status='ILL-Request' and ra.conversation_with not in (select r.conversation_with from request_closed r where r.id=ra.request_id));
alter table request_closed alter column id drop default;
drop sequence request_closed_seq;
-- move the separate-conversation parts to the newly created requests
update requests_history set request_id=r.id from request_closed r where r.group_id=requests_history.group_id and r.chain_id=requests_history.chain_id and r.conversation_with=requests_history.conversation_with;

-- create a table holding the requests_history request_id and ts to be updated, and the new request_id to replace the existing one.
create table temp_ra_updates as (select ra.request_id, ra.ts, ra2.request_id as new_request_id, ra2.ts as prev_ts, ra2.status from requests_history ra join requests_history ra2 on ra2.chain_id=ra.chain_id where ra.status='Message' and ra.requester=ra.conversation_with and ra2.ts=(select max(ts) from requests_history where chain_id=ra.chain_id and status='ILL-Request' and ts<ra.ts));

-- number of rows added to that table should equal:
--select count(*) from requests_history where status='Message' and requester=conversation_with;

-- ok, let's fix those message-to-self ones
update requests_history set request_id=tru.new_request_id from temp_ra_updates tru where tru.request_id=requests_history.request_id and tru.ts=requests_history.ts;

-- now some clean-up
drop table temp_ra_updates;
alter table history_group drop column request_id_temp;
alter table history_chain drop column request_id;
alter table request_closed drop column group_id;
alter table request_closed drop column conversation_with;
alter table requests_history drop column requester;
alter table requests_history drop column conversation_with;
alter table requests_history drop column chain_id;
alter table requests_history drop column group_id;
create index on requests_history (request_id);

COMMIT;
