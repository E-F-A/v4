#
# CustomAction.pm
# Version 20210130
# +--------------------------------------------------------------------+
# Copyright (C) 2012~2022 http://www.efa-project.org
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

package MailScanner::CustomConfig;

use strict 'vars';
use strict 'refs';
no  strict 'subs'; # Allow bare words for parameter %'s

use vars qw($VERSION);

# The package version, both in 1.23 style *and* usable by MakeMaker:
$VERSION = substr q$Revision: 1.0 $, 10;

use DBI;

#
# CustomAction for EFA Token Generation
#
sub CustomAction {
 my($message,$yes_or_no,$param) = @_;
 if ($param =~ /^spam$/ ) {
   return EFASpamNotify($message);
 }
 if ($param =~ /^nonspam$/ ) {
   return EFANonSpam($message);
 }
}

#
# EFA Non Spam Modification Token Generation,
#
sub EFANonSpam {
  my($message) = @_;
  my($token);
  my($file);
  my($spamwhitelisted);

  # Generate Token/Sign unless message is originates from localhost or is inbound and whitelisted
  my($clientip) = $message->{clientip};

  if ($clientip =~ /^127/) {
    return $message;
  } else {
    $message->MailScanner::Message::IsAReply();
	# Is inbound or outbound signature being applied?
	$file = MailScanner::Config::Value("inlinetextsig", $message);
	$spamwhitelisted = $message->{spamwhitelisted};
    if($message->{isreply}) {
      # Message is a reply, do not sign
      return $message;
    } elsif ($file =~ /inline.sig.in.txt/ && $spamwhitelisted eq "1") {
	  # Message is inbound and whitelisted, do not sign
	  return $message;
    } else {
      $token = EFACreateToken($message);

      $message->{token} = $token;

      return SignNonSpam($message);
    }
  }
}

#
# EFA Token Creation
#
sub EFACreateToken {
  my ($message) = @_;
  my($dbh, $sth, $sql);
  my($db_name) = 'efa';
  my($db_host) = 'localhost';
  my($db_user) = 'efa';
  my($fh);
  my($pw_config) = '/etc/eFa/eFa-Config';
  open($fh, "<", $pw_config);
  if(!$fh) {
    MailScanner::Log::WarnLog("Unable to open %s to retrieve password", $pw_config);
	return;
  }
  my($db_pass) = grep(/^EFASQLPWD/,<$fh>);
  $db_pass =~ s/EFASQLPWD://;
  $db_pass =~ s/\n//;
  close($fh);
  # Connect to the database
  $dbh = DBI->connect("DBI:mysql:database=$db_name;host=$db_host",
                      $db_user, $db_pass,
                      {PrintError => 0});

  # Check if connection was successfull - if it isn't
  # then generate a warning and continue processing.
  if (!$dbh) {
   MailScanner::Log::WarnLog("Unable to initialise database connection: %s", $DBI::errstr);
   return;
  }

  # Generate a new token
  my($token) = randomtoken($message);

  $sql = "INSERT INTO tokens (mid, token, datestamp) VALUES ('$message->{id}','$token', NOW())";
  $sth = $dbh->prepare($sql);
  $sth->execute;

  # Close connections
  $sth->finish();
  $dbh->disconnect();

  # Return $token
  return $token;
}

#
#  EFA Spam Token Generation and Notification
#
sub EFASpamNotify {
  my($message) = @_;
  my($token);

  $token = EFACreateToken($message);
  #if (!$token) { return; }

  $message->{token} = $token;

  # Notify user
  HandleSpamNotify($message);

  return 0;
}

# +---------------------------------------------------+
# # Function to create a pseudorandom 32 char token
# # +---------------------------------------------------+
sub randomtoken {
  my ($message) = @_;
  my ($token, $sha1);
  $sha1 = Digest::SHA->new(1);
  my ($timestamp) = localtime();
  $sha1->add($message->{id}, $timestamp, $message->{size}, $message->{headers});
  $token = $sha1->hexdigest;
  return substr($token, 0, 20);
}
# +---------------------------------------------------+

# Code borrowed from Messages.pm and modified for use with EFA
#
# We want to send a message to the recipient saying that their spam
# mail has not been delivered.
# Send a message to the recipients which has the local postmaster as
# the sender.
sub HandleSpamNotify {
  my($message) = @_;
  my($from,$to,$subject,$date,$spamreport,$hostname,$day,$month,$year);
  my($emailmsg, $line, $messagefh, $filename, $localpostmaster, $id);
  my($postmastername);
  my($token);

  $from = $message->{from};

  # Don't ever send a message to "" or "<>"
  return if $from eq "" || $from eq "<>";

  # Do we want to send the sender a warning at all?
  # If nosenderprecedence is set to non-blank and contains this
  # message precedence header, then just return.
  my(@preclist, $prec, $precedence, $header);
  @preclist = split(" ",
                  lc(MailScanner::Config::Value('nosenderprecedence', $message)));
  $precedence = "";
  foreach $header (@{$message->{headers}}) {
    $precedence = lc($1) if $header =~ /^precedence:\s+(\S+)/i;
  }
  if (@preclist && $precedence ne "") {
    foreach $prec (@preclist) {
      if ($precedence eq $prec) {
        MailScanner::Log::InfoLog("Skipping sender of precedence %s",
                                  $precedence);
        return;
      }
    }
  }

  # Setup other variables they can use in the message template
  $id = $message->{id};
  $localpostmaster = MailScanner::Config::Value('localpostmaster', $message);
  $postmastername  = MailScanner::Config::LanguageValue($message, 'mailscanner');
  $hostname = MailScanner::Config::Value('hostname', $message);
  $subject = $message->{subject};
  $date = $message->{datestring}; # scalar localtime;
  $spamreport = $message->{spamreport};
  $token = $message->{token};
  # And let them put the date number in there too
  #($day, $month, $year) = (localtime)[3,4,5];
  #$month++;
  #$year += 1900;
  #my $datenumber = sprintf("%04d%02d%02d", $year, $month, $day);
  my $datenumber = $message->{datenumber};


  my($to, %tolist);
  foreach $to (@{$message->{to}}) {
    $tolist{$to} = 1;
  }
  $to = join(', ', sort keys %tolist);

  # Delete everything in brackets after the SA report, if it exists
  $spamreport =~ s/(spamassassin)[^(]*\([^)]*\)/$1/i;

  # Work out which of the 3 spam reports to send them.
  $filename = MailScanner::Config::Value('recipientspamreport', $message);
  MailScanner::Log::NoticeLog("Spam Actions: Notify %s", $to)
    if MailScanner::Config::Value('logspam');

  $messagefh = new FileHandle;
  $messagefh->open($filename)
    or MailScanner::Log::WarnLog("Cannot open message file %s, %s",
                                 $filename, $!);
  $emailmsg = "";
  while(<$messagefh>) {
    chomp;
    s#"#\\"#g;
    s#@#\\@#g;
    # Boring untainting again...
    /(.*)/;
    $line = eval "\"$1\"";
    $emailmsg .= MailScanner::Config::DoPercentVars($line) . "\n";
  }
  $messagefh->close();

  # Send the message to the spam sender, but ensure the envelope
  # sender address is "<>" so that it can't be bounced.
  $global::MS->{mta}->SendMessageString($message, $emailmsg, $localpostmaster)
    or MailScanner::Log::WarnLog("Could not send sender spam notify, %s", $!);
}

#
# Code borrowed from Message.pm modified for use with EFA
#
sub SignNonSpam {
  my($message) = @_;
  my($from);
  return if $message->{infected}; # Double-check!

  $from = $message->{from};

  # Don't ever send a message to "" or "<>"
  return if $from eq "" || $from eq "<>";

  my($entity, $scannerheader, $clientip);

  # Use the presence of an X-MailScanner: header to decide if the
  # message will have already been signed by another MailScanner server.
  $scannerheader = MailScanner::Config::Value('mailheader', $message);
  $scannerheader =~ tr/://d;

  # EFA
  # Change Signing Behavior do not sign messages from localhost
  $clientip = $message->{clientip};
  if ($clientip =~ /^127/) { return $message; }

  # Want to sign the bottom of the highest-level MIME entity
  $entity = $message->{entity};
  if (MailScanner::Config::Value('signalreadyscanned', $message) ||
      (defined($entity) && !$entity->head->count($scannerheader))) {
      AppendSignCleanEntity($message, $entity, 0);
    if ($entity && $entity->head) {
      $entity->head->add('MIME-Version', '1.0')
        unless $entity->head->get('mime-version');
    }
    $message->{bodymodified} = 1;
  }
  return $message;
}
#
# Code borrowed from Messages.pm modified for use with EFA
# Code is identical execpt message is passed as parameter instead of
# being called from method
#
sub AppendSignCleanEntity {
  my($message, $top, $parent) = @_;

  my($MimeType, $signature, @signature);

  return unless $top;

  #print STDERR "In AppendSignCleanEntity, signing $top\n";

  # If multipart, try to sign our first part
  if ($top->is_multipart) {
    my $sigcounter = 0;
    # JKF Signed and encrypted multiparts must not be touched.
    # JKF Instead put the sig in the epilogue. Breaks the RFC
    # JKF but in a harmless way.
    if ($top->effective_type =~ /multipart\/(signed|encrypted)/i) {
      # Read the sig and put it in the epilogue, which may be ignored
      $signature = ReadVirusWarning($message,'inlinetextsig');
      @signature = map { "$_\n" } split(/\n/, $signature);
      unshift @signature, "\n";
      $top->epilogue(\@signature);
      return 1;
    }
    # If the ASCE(0) returned -1 then we found something we could sign but
    # chose not to, so set $sigcounter so we won't try to sign anything else.
    my $result0 = AppendSignCleanEntity($message, $top->parts(0), $top);
    if ($result0 >= 0) {
      $sigcounter += $result0;
    } else {
      $sigcounter = -1;
    }
    # If the ASCE(1) returned -1 then we found something we could sign but
    # chose not to, so set $sigcounter so we won't try to sign anything else.
    if ($top->head and $top->effective_type =~ /multipart\/alternative/i) {
      my $result1 = AppendSignCleanEntity($message, $top->parts(1), $top);
      if ($result1 >= 0) {
        $sigcounter += $result1;
      } else {
        $sigcounter = -1;
      }
    }

    if ($sigcounter == 0) {
      # If we haven't signed anything by now, it must be a multipart
      # message containing only things we can't sign. So add a text/plain
      # section on the front and sign that.
      my $text = ReadVirusWarning($message, 'inlinetextsig') . "\n\n";
      my $newpart = build MIME::Entity
                          Type => 'text/plain',
                          Charset =>
                    MailScanner::Config::Value('attachmentcharset', $message),
                          Disposition => 'inline',
                          Data => $text,
                          Encoding => 'quoted-printable',
                          Top => 0;
      $top->add_part($newpart, 0);
      $sigcounter = 1;
    }
    return $sigcounter;
  }

  $MimeType = $top->head->mime_type if $top->head;
  return 0 unless $MimeType =~ m{text/(html|plain)}i; # Won't sign non-text message.
  # Won't sign attachments.
  return 0 if $top->head->mime_attr('content-disposition') =~ /attachment/i;
  # Won't sign HTML parts when we already have a sig and don't allow duplicates
  # Or we are a reply and we don't sign replies.
  # We return -1 as a special token indicating that there was something we
  # could sign but chose not to. If I pick up a -1 when called then don't
  # try to sign anything else.
  return -1 if ($message->{sigimagepresent} &&
                $MimeType =~ /text\/html/i &&
                MailScanner::Config::Value('allowmultsigs', $message) !~ /1/) ||
               ($message->{isreply} &&
                MailScanner::Config::Value('isareply', $message));

  # Get body data as array of newline-terminated lines
  $top->bodyhandle or return undef;
  my @body = $top->bodyhandle->as_lines;

  # Output original data back into body, followed by message
  my($line, $io, $FoundHTMLEnd, $FoundBodyEnd, $FoundSigMark, $html);
  $FoundHTMLEnd = 0; # If there is no </html> tag, still append the signature
  $FoundBodyEnd = 0; # If there is no </body> tag, still append the signature
  $FoundSigMark = 0; # Try to replace _SIGNATURE_ with the sig if it's there
  $html = 0;
  $io = $top->open("w");
  if ($MimeType =~ /text\/html/i) {
    $signature = ReadVirusWarning($message, 'inlinehtmlsig');
    foreach $line (@body) {
      # Try to insert the signature where they want it.
      $FoundSigMark = 1 if $line =~ s/_SIGNATURE_/$signature/;
      $FoundBodyEnd = 1 if !$FoundSigMark && $line =~ s/\<\/body\>/$signature$&/i;
      $FoundHTMLEnd = 1 if !$FoundSigMark && !$FoundBodyEnd && $line =~ s/\<\/x?html\>/$signature$&/i;
      $io->print($line);
    }
    $io->print($signature . "\n")
      unless $FoundBodyEnd || $FoundHTMLEnd || $FoundSigMark;
    (($body[-1]||'') =~ /\n\Z/) or $io->print("\n"); # Ensure final newline
    $html = 1;
  } else {
    $signature = ReadVirusWarning($message, 'inlinetextsig');
    foreach $line (@body) {
      # Replace _SIGNATURE_ with the inline sig, if it's present.
      $FoundSigMark = 1 if $line =~ s/_SIGNATURE_/$signature/;
      $io->print($line); # Original body data
    }
    # Else just tack the sig on the end.
    $io->print("\n$signature\n") unless $FoundSigMark;
  }
  $io->close;

  # Add Image Attachment from Mail Scanner, unless there already is one
  if (MailScanner::Config::Value('attachimage', $message) =~ /1/ && !$message->{sigimagepresent}) {
    #print STDERR "Adding image signature\n";
    my $attach = MailScanner::Config::Value('attachimagetohtmlonly', $message);
    if (($html && $attach =~ /1/) || $attach =~ /0/) {
      my $filename = MailScanner::Config::Value('attachimagename', $message);
      my $ext = 'unknown';
      $ext = $1 if $filename =~ /\.([a-z]{3,4})$/;
      $ext = 'jpeg' if $ext =~ /jpg/i;
      my $internalname =  MailScanner::Config::Value('attachimageinternalname', $message);
      if (length($filename) && -f $filename) {
        my $newentity = MIME::Entity->build(Path => $filename,
                                            Top => 0,
                                            Type => "image/$ext",
                                            Encoding => "base64",
                                            Filename => $internalname,
                                            Disposition => "inline",
                                            'Content-Id:' => '<' . $internalname . '>');
        if ($parent && $parent->effective_type =~ /multipart\/related/i) {
          # It's already been signed once, so don't nest the MIME structure more
          $parent->add_part($newentity);
        } else {
          # It's a first-time sig, so next it into a multipart/related
          $top->make_multipart('related');
          $top->add_part($newentity);
        }
      }
    }
  }

  # We signed something
  return $message;
}

# Code borrowed from Messages.pm modified for use with EFA
# Modified to add token to signature line
#
# Read the appropriate warning message to sign the top of cleaned messages.
# Passed in the name of the config variable that points to the filename.
# This is also used to read the inline signature added to the bottom of
# clean messages.
# Substitutions allowed in the message are
#     $viruswarningfilename -- by default VirusWarning.txt
#     $from
#     $subject
# and $filename -- comma-separated list of infected attachments
sub ReadVirusWarning {
  my($message, $option) = @_;

  my $file = MailScanner::Config::Value($option, $message);
  my $viruswarningname = MailScanner::Config::Value('attachmentwarningfilename',
                                                    $message);
  my($line);

  #print STDERR "Reading virus warning message from $filename\n";
  my $fh = new FileHandle;
  $fh->open($file)
    or (MailScanner::Log::WarnLog("Could not open inline file %s, %s",
                                  $file, $!),
        return undef);

  # Work out the list of all the infected attachments, including
  # reports applying to the whole message
  my($typedattach, $attach, $text, %infected, $filename, $from, $subject, $id, $token);
  while (($typedattach, $text) = each %{$message->{allreports}}) {
    # It affects the entire message if the entity of this file matches
    # the entity of the entire message.
    $attach = substr($typedattach,1);
    my $entity = $message->{file2entity}{"$attach"};
    #if ($attach eq "") {
    if ($message->{entity} eq $entity) {
      $infected{MailScanner::Config::LanguageValue($message, "theentiremessage")}
        = 1;
    } else {
      $infected{"$attach"} = 1;
    }
  }
  # And don't forget the external bodies which are just entity reports
  while (($typedattach, $text) = each %{$message->{entityreports}}) {
    $infected{MailScanner::Config::LanguageValue($message, 'notnamed')} = 1;
  }
  $attach = substr($typedattach,1);
  $filename = join(', ', keys %infected);
  $id = $message->{id};
  $from = $message->{from};
  $subject = $message->{subject};
  my($token) = $message->{token};
  my($hostname) = MailScanner::Config::Value('hostname', $message);

  my $result = "";
  while (<$fh>) {
    chomp;
    s#"#\\"#g;
    s#@#\\@#g;
    # Boring untainting again...
    /(.*)/;
    $line = eval "\"$1\"";
    $result .= MailScanner::Config::DoPercentVars($line) . "\n";
  }
  $fh->close();
  $result;
}

1;
