CREATE DATABASE efa;

USE efa;

--
-- Table structure for table `tokens`
--

CREATE TABLE tokens (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `mid` mediumtext COLLATE utf8_unicode_ci,
  `token` char(40) NOT NULL,
  `datestamp` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


