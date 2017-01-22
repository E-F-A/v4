CREATE DATABASE /*32312 IF NOT EXISTS*/ efa;

USE efa;

--
-- Table structure for table `tokens`
--

CREATE TABLE tokens (
  token char(32) NOT NULL,
  datestamp datetime NOT NULL
) ENGINE=MyISAM;


