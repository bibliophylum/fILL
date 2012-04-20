-- Some libraries wish to be notified, by email, the moment that another library makes a request of them.
alter table libraries add column request_email_notification boolean default false;
