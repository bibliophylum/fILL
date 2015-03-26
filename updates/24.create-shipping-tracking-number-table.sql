-- create-shipping-tracking-number-table

create table shipping_tracking_number (
 lid integer not null,
 rid integer not null, -- request id
 tracking char(16)
);
create index on shipping_tracking_number(rid);
create index on shipping_tracking_number(lid);

