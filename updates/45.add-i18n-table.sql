-- 45.add-i18n-table.sql

-- page is page template name, including path
-- lang is language code (e.g. "en", "fr")
-- category determines whether this is something that can be a template parameter (tparm),
--   or needs to be handled by jquery mucking with the DOM (js_lang_data)
-- id is the hash key / element ID
-- text is the translated text
create table i18n (
  page varchar(100) not null,
  lang varchar(10) not null,
  category varchar(100),
  id varchar(100) not null,
  text varchar(4096) not null
);

create index on i18n (page,lang);

insert into i18n (page,lang,category,id,text)
       values ('public/test.tmpl','en','tparm','lang','en');
insert into i18n (page,lang,category,id,text)
       values ('public/test.tmpl','en','tparm','pagetitle','fILL test');
insert into i18n (page,lang,category,id,text)
       values ('public/test.tmpl','en','js_lang_data','main-info-left-h2','HEADING TEST');
insert into i18n (page,lang,category,id,text)
       values ('public/test.tmpl','en','js_lang_data','id-of-para','First paragraph');
insert into i18n (page,lang,category,id,text)
       values ('public/test.tmpl','en','js_lang_data','id-of-second-para','Here is another paragraph');
