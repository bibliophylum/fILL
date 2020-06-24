-- 51.opt-in-returns-only.sql

alter table org add column opt_in_returns_only boolean;
update org set opt_in_returns_only=false;
