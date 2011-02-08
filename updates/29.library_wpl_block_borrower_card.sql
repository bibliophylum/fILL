-- WPL requires a library to have an institutional borrower card to request multilingual blocks
alter table libraries add column wpl_institution_card varchar(40);

