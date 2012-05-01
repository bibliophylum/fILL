-- set up the reports table
create sequence reports_rid_seq start with 1 increment by 1 no minvalue no maxvalue cache 1;
-- rtype is one of 'Summary', 'Borrowing', 'Lending', or 'Narrative'
create table reports (
       rid integer DEFAULT nextval('reports_rid_seq'::regclass) NOT NULL,
       rtype varchar(15),
       name varchar(40),
       description varchar(1000),
       generator varchar(40)
);

insert into reports (name, rtype, description, generator) values ('Basic stats','Summary','Number of items borrowed and number of items loaned for the selected period.','report-basic-stats');
