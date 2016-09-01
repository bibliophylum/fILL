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
  stage varchar(100),
  text varchar(4096) not null
);

create index on i18n (page,lang);

insert into i18n (page,lang,category,id,stage,text) values
('public/test.tmpl','en','tparm','lang',null,'en'),
('public/test.tmpl','en','tparm','pagetitle',null,'fILL test'),
('public/test.tmpl','en','js_lang_data','main-info-left-h2',null,'HEADING TEST'),
('public/test.tmpl','en','js_lang_data','id-of-para',null,'First paragraph'),
('public/test.tmpl','en','js_lang_data','id-of-second-para',null,'Here is another paragraph');


-- most text will be constant during the life of a page (i.e. stage = null)
-- some text will change due to ajax events, etc
-- (e.g. stage = 'during search', stage = 'after search')... but any of these
-- non-constant texts MUST have a stage = 'initial' in order to get the correct
-- language text on page load.
