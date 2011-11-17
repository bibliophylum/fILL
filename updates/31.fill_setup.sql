--
-- Create fILL tables
--
create sequence request_seq;

-- generic request information
create table request (
  id INTEGER PRIMARY KEY DEFAULT NEXTVAL('request_seq'),
  title VARCHAR(1024),
  author VARCHAR(256),
  requester INTEGER NOT NULL,
  patron_barcode CHAR(14),
  current_target INTEGER default 1
);

-- on-going conversation
create table requests_active (
  request_id INTEGER REFERENCES request (id),
  ts TIMESTAMP DEFAULT now(),
  msg_from INTEGER REFERENCES libraries (lid),
  msg_to INTEGER REFERENCES libraries (lid),
  status VARCHAR(40),
  message VARCHAR(100)
);

-- lender-specific information, and lender sequence to reqest from
create table sources (
  request_id INTEGER REFERENCES request (id),
  sequence_number INTEGER NOT NULL default 1,
  library INTEGER REFERENCES libraries (lid),
  call_number VARCHAR(30)
);

-- request moved to here after end of life cycle
-- filled_by = NULL for ultimately unfilled request
create table request_closed (
  id INTEGER PRIMARY KEY,
  title VARCHAR(1024),
  author VARCHAR(256),
  requester INTEGER NOT NULL,
  patron_barcode CHAR(14),
  filled_by INTEGER REFERENCES libraries (lid)
);

-- requests_active moved to here after end of life cycle
create table requests_history (
  request_id INTEGER REFERENCES request_closed (id),
  ts TIMESTAMP,
  msg_from INTEGER REFERENCES libraries (lid),
  msg_to INTEGER REFERENCES libraries (lid),
  status VARCHAR(40),
  message VARCHAR(100)
);
