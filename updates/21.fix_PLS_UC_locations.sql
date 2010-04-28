--
-- This is a fix to handle PLS Union Cat holdings
-- 
DELETE FROM locations WHERE zid=1;
--
--
ALTER TABLE locations ALTER COLUMN location TYPE varchar(40);
--
-- 'location' is what the zServer returns as the holding location.
--
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Swan River (North-West)','North-West Regional Library - Main','nwrl@mts.net',202);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Holland (Victoria)','Victoria Municipal Library','pls@gov.mb.ca',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Lorette (Tache)','Bibliothèque Publique Tache Public Library - Main','btl@srsd.ca',129);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Deloraine','Bren Del Win Centennial Library','bdwlib@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Snow Lake','Snow Lake Community Library','dslibrary@hotmail.com',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Virden (Border)','Border Regional Library - Virden','borderlibraryvirden@rfnow.com',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Reston','Reston District Library','restonlb@yahoo.ca',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Beausejour','Brokenhead River Regional Library','brrlibr2@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Boissevain','Boissevain and Morton Regional Library','mbomill@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Gimli (Evergreen)','Evergreen Regional Library - Gimli','gimli.library@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Ste. Anne','Bibliothèque Ste. Anne','steannelib@steannemb.ca',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Leaf Rapids','Leaf Rapids Public Library','lrlibraryn@gmail.com',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Somerset','Bibliothèque Somerset','somlib@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Flin Flon','Flin Flon Public Library','ffplill@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Benito','North-West Regional Library - Benito','benlib@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Bibliotheque Tache Library','Bibliothèque Publique Tache Public Library - Main','btl@srsd.ca',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'St. Jean Baptiste (Montcalm)','Bibliothèque Montcalm','biblio@atrium.ca',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Ile des Chenes','Bibliothèque Ritchot - Main','ritchotlib@hotmail.com',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Rapid City','Rapid City Regional Library','rcreglib@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'St-Georges (Allard)','Bibliothèque Allard','allardill@hotmail.com',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Manitou','Manitou Public Library','manitoulibrary@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Morris (Valley)','Valley Regional Library','valleylib@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Churchill','Churchill Public Library','mchlibrary@yahoo.ca',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'MacGregor (North Norfolk)','North Norfolk-MacGregor Library','maclib@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Souris (Glenwood)','Glenwood & Souris Regional Library','gsrl@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Lac du Bonnet','Lac Du Bonnet Regional Library','mldb@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Headingley','Headingley Municipal Library','hml@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Lundar (Pauline Johnson)','Pauline Johnson Library','mlpj@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Pierson','Southwestern Manitoba Regional Library - Pierson','pcilibrary@goinet.ca',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'St. Rose','Ste. Rose Regional Library','sroselib@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Gillam (Bette Winner)','Bette Winner Public Library','bwinner@gillamnet.com',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'LaBroquerie (StJoachim)','Bibliothèque Saint-Joachim','bsjl@bsjl.ca',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Emerson','Emerson Library','library@townofemerson.com',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Elkhorn','Border Regional Library - Elkhorn','elkhornbrl@rfnow.com',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Arborg','Evergreen Regional Library - Arborg','arborglibrary@mts.net',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Peguis','Peguis First Nation Public Library','peguislibrary@yahoo.ca',NULL);
INSERT INTO locations (zid,location,name,email_address,ill_received) VALUES (1,'Russell','Russell & District Regional Library - Main','ruslib@mts.net',NULL);
