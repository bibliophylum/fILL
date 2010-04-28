ALTER TABLE users RENAME TO libraries;
alter table libraries rename column uid to lid;
alter table user_target rename column uid to lid;
alter table ill_stats rename column uid to lid;
alter table user_authgroups rename column uid to lid;
