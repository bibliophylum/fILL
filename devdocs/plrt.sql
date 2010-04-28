-- MySQL dump 10.11
--
-- Host: localhost    Database: maplin
-- ------------------------------------------------------
-- Server version	5.0.67-0ubuntu6

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `public_LibraryRegionAndTown`
--

DROP TABLE IF EXISTS `public_LibraryRegionAndTown`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `public_LibraryRegionAndTown` (
  `id` int(11) NOT NULL auto_increment,
  `library` varchar(50) default NULL,
  `town` varchar(50) default NULL,
  `region` varchar(15) default NULL,
  `libtype` varchar(15) default NULL,
  `email` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=98 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `public_LibraryRegionAndTown`
--

LOCK TABLES `public_LibraryRegionAndTown` WRITE;
/*!40000 ALTER TABLE `public_LibraryRegionAndTown` DISABLE KEYS */;
INSERT INTO `public_LibraryRegionAndTown` VALUES (1,'Bette Winner Public Library','Gillam','NORMAN','Established','bwinner@gillamnet.com\r'),(2,'Bibliotheque Allard','Traverse Bay','EASTMAN','Satellite','beacheslibrary@hotmail.com\r'),(3,'Bibliothèque Allard','St Georges','EASTMAN','Established','allardILL@hotmail.com\r'),(4,'Bibliothèque Montcalm','Saint-Jean-Baptiste','CENTRAL','Established','biblio@atrium.ca\r'),(5,'Bibliothèque Pere Champagne','Notre Dame de Lourdes','CENTRAL','Established','ndbiblio@yahoo.ca\r'),(6,'Bibliothèque Publique Tache Public Library','Lorette','EASTMAN','Established','btl@srsd.ca\r'),(7,'Bibliothèque Ritchot','Ile des Chenes','EASTMAN','Established','ritchotlib@hotmail.com\r'),(8,'Bibliothèque Ritchot','St. Adolphe','EASTMAN','Satellite','stadbranch@hotmail.com\r'),(9,'Bibliothèque Ritchot','Ste. Agathe','EASTMAN','Satellite','bibliosteagathe@atrium.ca\r'),(10,'Bibliothèque Saint-Claude','St. Claude','CENTRAL','Established','stclib@mts.net\r'),(11,'Bibliothèque Saint-Joachim','La Broquerie','EASTMAN','Established','bsjl@bsjl.ca\r'),(12,'Bibliothèque Somerset','Somerset','CENTRAL','Established','somlib@mts.net\r'),(13,'Bibliothèque Ste. Anne','Ste. Anne','EASTMAN','Established','steannelib@steannemb.ca\r'),(14,'Boissevain and Morton Regional Library','Boissevain','WESTMAN','Established','mbomill@mts.net\r'),(15,'Border Regional Library','Elkhorn','WESTMAN','Branch','brlelk@yahoo.ca\r'),(16,'Border Regional Library','Virden','WESTMAN','Established','borderlibraryvirden@rfnow.com\r'),(17,'Border Regional Library','McAuley','WESTMAN','Branch','library@mcauley-mb.com\r'),(18,'Boyne Regional Library','Carman','CENTRAL','Established','illbrl@hotmail.com\r'),(19,'Bren Del Win Centennial Library','Deloriane','WESTMAN','Established','bdwlib@mts.net\r'),(20,'Bren Del Win Centennial Library','Waskada','WESTMAN','Branch','bdwlib@mts.net\r'),(21,'Brokenhead River Regional Library','Beausejour','EASTMAN','Established','brrlibr2@mts.net\r'),(22,'Churchill Public Library','Churchill','NORMAN','Established','mchlibrary@yahoo.ca\r'),(23,'Emerson Library','Emerson','CENTRAL','Established','emlibrary@hotmail.com\r'),(24,'Eriksdale Public Library','Eriksdale','INTERLAKE','Established','epl1@mts.net\r'),(25,'Evergreen Regional Library','Arborg','INTERLAKE','Branch','arborlib@mts.net\r'),(26,'Evergreen Regional Library','Gimli','INTERLAKE','Established','exec@mts.net\r'),(27,'Evergreen Regional Library','Riverton','INTERLAKE','Branch','rlibrary@mts.net\r'),(28,'Flin Flon Public Library','Flin Flon','NORMAN','Established','ffplill@mts.net\r'),(29,'Glenwood and Souris Regional Library','Souris','WESTMAN','Established','gsrl@mts.net\r'),(30,'Headingley Municipal Library','Headingly','CENTRAL','Established','hml@mts.net\r'),(31,'Jake Epp Library','Steinbach','EASTMAN','Established','steinlib@rocketmail.com\r'),(32,'Jolys Regional Library','St. Pierre','EASTMAN','Established','stplibrary@jrlibrary.mb.ca\r'),(33,'Jolys Regional Library','St. Malo','EASTMAN','Branch','stmlibrary@jrlibrary.mb.ca\r'),(34,'Lac Du Bonnet Regional Library','Lac du Bonnet','EASTMAN','Established','mldb@mts.net\r'),(35,'Lakeland Regional Library','Cartwright','CENTRAL','Branch','cartlib@mts.net\r'),(36,'Lakeland Regional Library','Killarney','WESTMAN','Established','lrl@mts.net\r'),(37,'Leaf Rapids Public Library','Leaf Rapids','NORMAN','Established','lrlib@mts.net\r'),(38,'Lynn Lake Centennial Library','Lynn Lake','NORMAN','Established','curling99@hotmail.com\r'),(39,'Manitou Regional Library','Manitou','CENTRAL','Established','manitoulibrary@mts.net\r'),(40,'Minnedosa Regional Library','Minnedosa','WESTMAN','Established','mmr@mts.net\r'),(41,'North Norfolk-MacGregor Library','MacGregor','CENTRAL','Established','maclib@mts.net\r'),(42,'North-West Regional Library','Benito','PARKLAND','Branch','benlib@mts.net\r'),(43,'North-West Regional Library','Swan River','PARKLAND','Established','nwrl@mts.net\r'),(44,'Parkland Regional Library','Birch River','PARKLAND','Branch','briver@mts.net\r'),(45,'Parkland Regional Library','Birtle','WESTMAN','Branch','birtlib@mts.net\r'),(46,'Parkland Regional Library','Bowsman','PARKLAND','Branch','bows18@mts.net\r'),(47,'Parkland Regional Library','Dauphin','PARKLAND','Branch','DauphinLibrary@parklandlib.mb.ca\r'),(48,'Parkland Regional Library','Erickson','WESTMAN','Branch','erick11@mts.net\r'),(49,'Parkland Regional Library','Foxwarren','WESTMAN','Branch','foxlib@mts.net\r'),(50,'Parkland Regional Library','Gilbert Plains','PARKLAND','Branch','gilbert3@mts.net\r'),(51,'Parkland Regional Library','Gladstone','CENTRAL','Branch','gladstne@mts.net\r'),(52,'Parkland Regional Library','Grandview','PARKLAND','Branch','grandvw@mts.net\r'),(53,'Parkland Regional Library','Hamiota','WESTMAN','Branch','hamlib@mts.net\r'),(54,'Parkland Regional Library','Langruth','CENTRAL','Branch','langlib@mts.net\r'),(55,'Parkland Regional Library','McCreary','PARKLAND','Branch','mccrea16@mts.net\r'),(56,'Parkland Regional Library','Minitonas','PARKLAND','Branch','minitons@mts.net\r'),(57,'Parkland Regional Library','Ochre River','PARKLAND','Branch','orlibrary@inetlink.ca\r'),(58,'Parkland Regional Library','Roblin','PARKLAND','Branch','roblinli@mts.net\r'),(59,'Parkland Regional Library','Shoal Lake','WESTMAN','Branch','sllibrary@mts.net\r'),(60,'Parkland Regional Library','Siglunes','CENTRAL','Branch','siglun15@mts.net\r'),(61,'Parkland Regional Library','St. Lazare','WESTMAN','Branch','lazarelib@mts.net\r'),(62,'Parkland Regional Library','Strathclair','WESTMAN','Branch','stratlibrary@mts.net\r'),(63,'Parkland Regional Library','Winnipegosis','PARKLAND','Branch','wpgosis@mts.net\r'),(64,'Pauline Johnson Library','Lundar','INTERLAKE','Established','mlpj@mts.net\r'),(65,'Peguis Public','Peguis','INTERLAKE','Established','peguislibrary@yahoo.ca\r'),(66,'Pilot Mound Public Library','Pilot Mound','CENTRAL','Established','pmlibrary@mts.net\r'),(67,'Pinawa Public Library','Pinawa','EASTMAN','Established','email@pinawapubliclibrary.com\r'),(68,'Portage La Prairie Regional Library','Portage la Prairie','CENTRAL','Established','portlib@portagelibrary.com\r'),(69,'Prairie Crocus Regional Library','Rivers','WESTMAN','Established','pcrl@mts.net\r'),(70,'R.M. of Argyle Public Library','Baldur','WESTMAN','Established','rmargyle@gmail.com\r'),(71,'Rapid City Regional Library','Rapid City','WESTMAN','Established','rcreglib@mts.net\r'),(72,'Red River North Regional Library','Selkirk','INTERLAKE','Established','library@ssarl.org\r'),(73,'Reston District Library','Reston','WESTMAN','Established','restonlb@yahoo.ca\r'),(74,'Rossburn Regional Library','Rossburn','PARKLAND','Established','rrl@mts.net\r'),(75,'Russell and District Library','Binscarth','PARKLAND','Branch','binslb@mts.net\r'),(76,'Russell and District Regional Library','Russell','PARKLAND','Established','ruslib@mts.net\r'),(77,'Snow Lake Community Library','Snow Lake','NORMAN','Established','dslibrary@hotmail.com\r'),(78,'South Central Regional Library','Altona','CENTRAL','Branch','scrlilla@mts.net\r'),(79,'South Central Regional Library','Morden','CENTRAL','Branch','scrlillm@mts.net\r'),(80,'South Central Regional Library','Winkler','CENTRAL','Branch','scrlillw@mts.net\r'),(81,'South Interlake Library','Teulon','INTERLAKE','Branch','teulonbranchlibrary@yahoo.com\r'),(82,'South Interlake Regional Library','Stonewall','INTERLAKE','Established','circ@sirlibrary.com\r'),(83,'Southwestern Manitoba Regional Library','Melita','WESTMAN','Established','swmblib@mts.net\r'),(84,'Southwestern Manitoba Regional Library','Napinka','WESTMAN','Branch','smrl1nap@yahoo.ca\r'),(85,'Southwestern Manitoba Regional Library','Pierson','WESTMAN','Branch','pcilibrary@goinet.ca\r'),(86,'Springfield Municipal','Oakbank','EASTMAN','Established','\r'),(87,'Ste. Rose Regional Library','Ste. Rose du Lac','PARKLAND','Established','illstroselibrary@mts.net\r'),(88,'The Pas Regional Library','The Pas','NORMAN','Established','illthepas@mts.net\r'),(89,'Thompson Public Library','Thompson','NORMAN','Established','interlibraryloans@thompsonlibrary.com\r'),(90,'Thompson Public Library','Nelson House','NORMAN','Branch','NCNBranch@Thompsonlibrary.com\r'),(91,'Valley Regional Library','Morris','CENTRAL','Established','valleylib@mts.net\r'),(92,'Victoria Municipal Library','Holland','CENTRAL','Established','victlib@goinet.ca\r'),(93,'Western Manitoba Regional Library','Hartney','WESTMAN','Branch','hartney@wmrl.ca\r'),(94,'Western Manitoba Regional Library','Glenboro','WESTMAN','Branch','glenboro@wmrl.ca\r'),(95,'Western Manitoba Regional Library','Neepawa','WESTMAN','Branch','neepawa@wmrl.ca\r'),(96,'Western Manitoba Regional Library','Carberry','WESTMAN','Branch','carberry@wmrl.ca\r'),(97,'Western Manitoba Regional Library','Brandon','WESTMAN','Established','bdnill@wmrl.ca\r');
/*!40000 ALTER TABLE `public_LibraryRegionAndTown` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-01-30 20:30:19
