-- usage: psql -U mapapp -h localhost -d maplin -A -F , -f history-fix.sql >history-fix.txt
select chain_id, max(id) from request where chain_id in (select distinct chain_id from request_closed) group by chain_id order by chain_id;
