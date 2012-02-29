-- Each library will have, in its own ILS, all (or most) other libraries set up as patrons
-- (so the library can check out ILL items to them)
-- To make things easy on the lender, we'll let them enter all of those library-as-patron
-- barcodes here, and then print them on the pull list.
-- This way, with the pull list and the pulled items in hand, they can just get into their
-- ILS's checkout, scan the library barcode from the sheet, scan the barcode from the item, 
-- and be done with check-out (no need to look up (in their own ILS) each borrowing library.
create table library_barcodes (
       lid integer not null,
       borrower integer references libraries(lid),
       barcode varchar(15)
);