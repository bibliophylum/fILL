-- properly specifying foreign keys, so SchemaSpy can create ER diagram
alter table request_group add primary key (group_id);
alter table request_chain add foreign key (group_id) references request_group (group_id);

alter table request_group add foreign key (requester) references libraries (lid);

alter table request_chain add primary key (chain_id);
alter table request add foreign key (chain_id) references request_chain (chain_id);

-- If history_group has duplicate rows (error!), do this:
--delete from history_group a where a.ctid <> (select min(b.ctid) from history_group b where a.group_id=b.group_id);
alter table history_group add primary key (group_id);
alter table history_chain add foreign key (group_id) references history_group (group_id);

alter table history_group add foreign key (requester) references libraries (lid);

-- If history_chain has duplicate rows (error!), do this:
--delete from history_chain a where a.ctid <> (select min(b.ctid) from history_chain b where a.chain_id=b.chain_id);
alter table history_chain add primary key (chain_id);
alter table request_closed add foreign key (chain_id) references history_chain (chain_id);

alter table libraries alter column name set not null;
alter table library_barcodes add primary key (lid,borrower);
alter table library_barcodes add foreign key (lid) references libraries (lid);
alter table libraries_untracked_ill add foreign key (lid) references libraries (lid);
alter table library_nonsip2 add foreign key (lid) references libraries (lid);
alter table library_sip2 add foreign key (lid) references libraries (lid);
alter table library_systems add foreign key (parent_id) references libraries (lid);
alter table library_systems add foreign key (child_id) references libraries (lid);
alter table library_z3950 add foreign key (lid) references libraries (lid);
alter table acquisitions add foreign key (lid) references libraries (lid);

alter table patrons add primary key (pid);
alter table patrons add foreign key (home_library_id) references libraries (lid);
alter table patron_request add foreign key (lid) references libraries (lid);
alter table patron_request add foreign key (pid) references patrons (pid);
alter table patron_request add primary key (prid);
alter table patron_request_sources add primary key (prid,sequence_number);
alter table patron_request_sources add foreign key (prid) references patron_request (prid);
alter table patron_request_sources add foreign key (lid) references libraries (lid);
alter table patron_requests_declined add primary key (prid);
alter table patron_requests_declined add foreign key (pid) references patrons (pid);
alter table patron_requests_declined add foreign key (lid) references libraries (lid);

alter table regional_libraries add primary key (rlid);
alter table regional_libraries_branches add foreign key (rlid) references regional_libraries (rlid);
alter table regional_libraries_branches add foreign key (lid) references libraries (lid);

alter table sources_history add foreign key (lid) references libraries (lid);
alter table sources_history add foreign key (request_id) references request_closed (id);

alter table users add primary key (uid);
-- If users has rows where lid doesn't exist in libraries table:
--delete from users where lid not in (select lid from libraries);
alter table users add foreign key (lid) references libraries (lid);

alter table shipping_tracking_number add primary key (rid);
alter table shipping_tracking_number add foreign key (lid) references libraries (lid);
