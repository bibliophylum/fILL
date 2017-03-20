-- fake up a cascade delete (should really set that on the foreign keys...)
-- note that there are no entries in the sources table for this request
-- (i.e. "0 of 0 tried" problem)
begin;
delete from requests_active where request_id=(
  select id from request where chain_id=(
    select chain_id from request_chain where group_id=(
      select group_id from request_group where group_id=134810
      and requester=(select oid from org where symbol='MMNN'))));

delete from request where chain_id=(
    select chain_id from request_chain where group_id=(
      select group_id from request_group where group_id=134810
      and requester=(select oid from org where symbol='MMNN')));

delete from request_chain where group_id=(
      select group_id from request_group where group_id=134810
      and requester=(select oid from org where symbol='MMNN'));

delete from request_group where group_id=134810
      and requester=(select oid from org where symbol='MMNN');

commit;
