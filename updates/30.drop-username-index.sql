-- 30.drop-username-index

-- We're moving to external authentication for patrons (that is, patrons will
-- authenticate against their home library's ILS, using the barcode/pin with which
-- they log in to their library's catalogue).
-- fILL will create patron records on-the-fly for externally-authenticated patrons;
-- these records will use the patron's barcode in the username field.
-- It is possible that multiple libraries (against all recommendations) use the
-- same barcode ranges for their patrons.  The patron records would still be unique
-- (different home_library_id), but we need to remove the uniqueness constraint
-- on the username field.

alter table patrons drop constraint if exists patrons_username_key;
