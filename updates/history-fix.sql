-- usage: psql -U mapapp -h localhost -d maplin -A -F , -f history-fix.sql >history-fix.txt
--select chain_id, max(id) from request where chain_id in (select distinct chain_id from request_closed) group by chain_id order by chain_id;
select 
  g.group_id,
  c.chain_id,
  rh.request_id, 
  g.title,
  g.requester,
  g.patron_barcode,
  g.note,
  rh.ts,
  rh.msg_from,
  l1.name,
  rh.msg_to,
  l2.name,
  rh.status,
  rh.message
from 
  history_group g
  left join history_chain c on c.group_id = g.group_id
  left join request_closed r on r.chain_id = c.chain_id
  left join requests_history rh on rh.request_id = r.id
  left join libraries l1 on l1.lid = rh.msg_from
  left join libraries l2 on l2.lid = rh.msg_to
where 
  rh.request_id in (select request_id from requests_history where request_id=rh.request_id and status='Shipped') 
  and rh.request_id not in (select request_id from requests_history where request_id=rh.request_id and status='Checked-in')
order by g.group_id, c.chain_id, rh.request_id, rh.ts;
