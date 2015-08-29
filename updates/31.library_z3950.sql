-- library_z3950
create table library_z3950 (
  lid integer primary key,
  server_address varchar(255),
  server_port integer,
  database_name varchar(40),
  enabled smallint default 1,
  request_syntax varchar(20),
  elements varchar(5),
  nativesyntax varchar(15),
  xslt varchar(40),
  index_keyword varchar(255),
  index_author varchar(255),
  index_title varchar(255),
  index_subject varchar(255),
  index_isbn varchar(255),
  index_issn varchar(255),
  index_date varchar(255),
  index_series varchar(255)
);

create table library_z3950_template (
  ils varchar(255) primary key,
  request_syntax varchar(20),
  elements varchar(5),
  nativesyntax varchar(15),
  xslt varchar(40),
  index_keyword varchar(255),
  index_author varchar(255),
  index_title varchar(255),
  index_subject varchar(255),
  index_isbn varchar(255),
  index_issn varchar(255),
  index_date varchar(255),
  index_series varchar(255)
);

insert into library_z3950_template (ils, request_syntax, elements, nativesyntax, xslt, index_keyword, index_author, index_title, index_subject, index_isbn, index_issn, index_date) values ('L4U','marc21','F','iso2709','marc21.xsl','u=1016 t=l,r s=al 2=3','u=1003 s=al','u=4 s=al 2=102','u=21 s=al 2=102','u=7 2=102','u=8 2=102','u=30 r=r 2=102');
