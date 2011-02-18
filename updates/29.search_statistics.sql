-- add a search statistics table
create table search_statistics (sessionid varchar(50) PRIMARY KEY, 
       ts timestamp without time zone DEFAULT now() NOT NULL,
       pqf varchar(1024), 
       duration integer default 0, 
       records integer default 0);



