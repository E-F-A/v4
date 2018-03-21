CREATE TABLE awl (
  username varchar(100) NOT NULL default '',
  email varbinary(255) NOT NULL default '',
  ip varchar(40) NOT NULL default '',
  count int(11) NOT NULL default '0',
  totscore float NOT NULL default '0',
  ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (username,email,ip)
) ENGINE=InnoDB;