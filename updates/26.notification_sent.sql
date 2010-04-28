-- flag for already-sent-a-notification when zserver down

alter table zservers add column notification_sent smallint default 0;
