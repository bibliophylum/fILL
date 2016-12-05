-- 49.z3950-reports-org-as.sql

alter table org add column z3950_location text;
update org set z3950_location = symbol;


update org set z3950_location = 'Manitoba PLS' where symbol = 'MWPL';
update org set z3950_location = 'Altona Library' where symbol = 'MAOW';  -- SCRL Altona
update org set z3950_location = 'Miami Library' where symbol = 'MMIOW'; -- SCRL Miami
update org set z3950_location = 'Morden Library' where symbol = 'MMOW';  -- SCRL Morden
update org set z3950_location = 'Winkler Library' where symbol = 'MWOW';  -- SCRL Winkler
update org set z3950_location = 'Boissevain-Morton Library' where symbol = 'MBOM';  -- Boissevain
update org set z3950_location = 'Manitou Regional Library' where symbol = 'MMA';   -- Manitou
update org set z3950_location = 'Ste Rose Library' where symbol = 'MSTR';  -- Ste. Rose
update org set z3950_location = 'AB' where symbol = 'MWP';   -- Legislative Library
update org set z3950_location = 'MWP' where symbol = 'MWP';   -- Legislative Library
update org set z3950_location = 'Stonewall Library' where symbol = 'MSTOS'; -- SIRL Stonewall
update org set z3950_location = 'Teulon Library' where symbol = 'MTSIR'; -- SIRL Teulon
update org set z3950_location = 'McAuley Branch - Border Regional Library' = 'MMCA';  -- MB McAuley
update org set z3950_location = 'Main Branch - Border Regional Library' where symbol = 'MVE';   -- MB Virden
update org set z3950_location = 'Elkhorn Branch - Border Regional Library' = 'ME';    -- MB Elkhorn
update org set z3950_location = 'Somerset Library' where symbol = 'MS';    -- Somerset
update org set z3950_location = 'Glenwood and Souris Regional Library' where symbol = 'MSOG';  -- Glenwood and Souris
update org set z3950_location = 'Bren Del Win Centennial Library' where symbol = 'MDB';   -- Bren Del Win
update org set z3950_location = 'Portage la Prairie Regional Library' where symbol = 'MPLP';  -- Portage
update org set z3950_location = 'Shilo Community Library' where symbol = 'MSSC';  -- Shilo
update org set z3950_location = 'Chemawawin Public Library at Easterville' = 'MEC';   -- UCN Chemawawin
update org set z3950_location = 'UCN/Norway House Public Library' where symbol = 'MNH';   -- UCN Norway House
update org set z3950_location = 'UCN Health at Swan River' where symbol = 'UCN';   -- UCN Health at Swan River
update org set z3950_location = 'Thompson Campus Library' where symbol = 'MTK';   -- UCN Thompson
update org set z3950_location = 'The Pas Campus Library' where symbol = 'MTPK';  -- UCN The Pas
update org set z3950_location = 'UCN Midwifery in Winnipeg' where symbol = 'UCN';   -- UCN Midwifery
update org set z3950_location = 'UCN/Pukatawagan Public Library' where symbol = 'MPPL';  -- UCN Pukatawagan
update org set z3950_location = 'UCN Health at Swan River' where symbol = 'MSRH';  -- UCN Health
update org set z3950_location = 'Russell Library' where symbol = 'MRD';   -- MRUS Russell
update org set z3950_location = 'Binscarth Library' where symbol = 'MBI';   -- MRUS Binscarth
update org set z3950_location = 'Bibliothèque St. Claude Library' where symbol = 'MSCL';  -- St.Claude
update org set z3950_location = 'Bibliothèque Pere Champagne Library' where symbol = 'MNDP';  -- Pere Champagne
update org set z3950_location = 'Louise Public Library' where symbol = 'MPM';   -- Pilot Mound
update org set z3950_location = 'Bibliothèque Ste-Anne Library' where symbol = 'MSA';   -- Ste Anne
update org set z3950_location = 'Parkland Regional' where symbol = 'MDPRS';   -- Parkland
update org set z3950_location = 'Dauphin Public' where symbol = 'MDA';
update org set z3950_location = 'Parkland' where symbol = 'MDP';
update org set z3950_location = 'Birch River' where symbol = 'MBRD';
update org set z3950_location = 'Birtle' where symbol = 'MBR';
update org set z3950_location = 'Bowsman' where symbol = 'MBO';
update org set z3950_location = 'Erickson' where symbol = 'MEDL';
update org set z3950_location = 'Eriksdale' where symbol = 'MEL';
update org set z3950_location = 'Foxwarren' where symbol = 'MFO';
update org set z3950_location = 'Gilbert Plains' where symbol = 'MGP';
update org set z3950_location = 'Gladstone' where symbol = 'MGD';
update org set z3950_location = 'Hamiota' where symbol = 'MHC';
update org set z3950_location = 'Langruth' where symbol = 'MLL';
update org set z3950_location = 'McCreary' where symbol = 'MMD';
update org set z3950_location = 'Minitonas' where symbol = 'MMM';
update org set z3950_location = 'Ochre River' where symbol = 'MOR';
update org set z3950_location = 'Roblin' where symbol = 'MRR';
update org set z3950_location = 'Rossburn' where symbol = 'MRO';
update org set z3950_location = 'Shoal Lake' where symbol = 'MSLC';
update org set z3950_location = 'Siglunes' where symbol = 'MAS';
update org set z3950_location = 'St. Lazare' where symbol = 'MDPSLA';
update org set z3950_location = 'Ste. Rose' where symbol = 'MSTR';
update org set z3950_location = 'Strathclair' where symbol = 'MSS';
update org set z3950_location = 'Winnipegosis' where symbol = 'MWWI';
