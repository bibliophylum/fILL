-- library-auth-fieldnames

alter table library_sip2 add column login_text text default 'Log in using your library barcode and PIN';
alter table library_sip2 add column barcode_label_text text default 'Library card number';
alter table library_sip2 add column pin_label_text text default 'PIN number';

alter table library_nonsip2 add column login_text text default 'Log in using your library barcode and PIN';
alter table library_nonsip2 add column barcode_label_text text default 'Library card number';
alter table library_nonsip2 add column pin_label_text text default 'PIN number';
