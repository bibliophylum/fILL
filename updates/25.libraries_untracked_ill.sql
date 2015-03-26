-- libraries_untracked_ill
-- need a way of incorporating untracked ILLs (eg Spruce internal ILL) into
-- net-borrower/net-lender counts
create table libraries_untracked_ill (lid integer primary key, borrowed integer, loaned integer);
