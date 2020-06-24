-- 50.opt-in.sql

alter table org add column opt_in boolean;
update org set opt_in=false;
