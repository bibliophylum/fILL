-- add zserver-alive flag 
-- ('available' is something the libraries determine,
--  'alive' is something Maplin determines)
alter table zservers add column alive smallint;

-- default it to being whatever the old value was
update zservers set alive = available;
