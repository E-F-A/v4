#!/usr/bin/perl
# +--------------------------------------------------------------------+
# EFA learn spam message script version 20140105
# This script is an modification of the previous ESVA learn-msg.cgi
# +--------------------------------------------------------------------+
# Copyright (C) 2013~2017 http://www.efa-project.org
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# +--------------------------------------------------------------------+

use CGI::Carp qw(fatalsToBrowser);
use CGI qw(:standard);
use DBI;
use Net::Netmask;
print "Content-type: text/html \n\n";

$query = new CGI;
$salearn = "/usr/bin/sa-learn --spam";
$id = param("id");
$token = param("token");
$db_name = "efa";
$db_host = "localhost";
$db_user = "efa";
open(FILE, '/etc/EFA-Config');
#Do not read in entire file at once for better security
while ($line = <FILE>) {
  if ($line =~ /^EFASQLPWD/) {
    $db_pass = $line;
    $db_pass =~ s/^EFASQLPWD://;
    $db_pass =~ s/\n//;
    break;
  }
}
close (FILE);

open(FILE, '/etc/sysconfig/EFA_trusted_networks') or die ("Trusted Networks File Missing");
@trustednetworks = <FILE>;
close (FILE);

if ($id eq "" ){
  die "Error variable is empty";
}
if ($token eq "" ){
  die "Error variable is empty";
}

if ($id =~ /^[A-F0-9]{8}\.[A-F0-9]{5}|[A-F0-9]{9}\.[A-F0-9]{5}|[A-F0-9]{10}\.[A-F0-9]{5}|[A-F0-9]{11}\.[A-F0-9]{5}$/ && $token =~/^[0-9a-zA-Z]{32}$/){
  # Is the array empty or not...
  $flag=0;
  # TODO:  May need to test for whitepace in the array
  if(@trustednetworks) {
    foreach (@trustednetworks) {
      @items = split(/ /);
      $ip = @items[0];
      $mask = @items[1];
      $block = new Net::Netmask($ip,$mask);
      if ($block->match($ENV{REMOTE_ADDR})) {
        $flag=1;
      }
    }
  } else {
    $flag=1;
  }

  if ($flag) {
    $dbh = DBI->connect("DBI:mysql:database=$db_name;host=$db_host",
       $db_user, $db_pass,
       {PrintError => 0});

    if (!$dbh) { die "Error connecting to database" }

    $sql = "SELECT token from tokens WHERE token=\"$token\"";
    $sth = $dbh->prepare($sql);
    $sth->execute;
    @results = $sth->fetchrow;
    if (!$results[0]) {

      $sth->finish();
      $dbh->disconnect();

      # redirect to failure page
      print "<meta http-equiv=\"refresh\" content=\"0;URL=/notlearned.html\">";
    } else {

      $msgtolearn = `find /var/spool/MailScanner/quarantine/ -name $id`;

      print "$msgtolearn";
      open(MAIL, "|$salearn $msgtolearn") or die "Cannot open $salearn: $!";
      close(MAIL);

      # Remove token from db after release
      $sql = "DELETE from tokens WHERE token=\"$token\"";
      $sth = $dbh->prepare($sql);
      $sth->execute;

      $sth->finish();
      $dbh->disconnect();

      # redirect to success page
      print "<meta http-equiv=\"refresh\" content=\"0;URL=/learned.html\">";
    }
  } else {
      # redirect to denial page
      print "<meta http-equiv=\"refresh\" content=\"0;URL=/denylearned.html\">";
  }
}else{
    die "Error in id or token syntax";
}
