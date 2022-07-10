<?php

/*
 * eFa-learn.php
 * Copyright (C) 2022 eFa-Project (https://efa-project.org)
 *  
 * MailWatch for MailScanner
 * Copyright (C) 2003-2011  Steve Freegard (steve@freegard.name)
 * Copyright (C) 2011  Garrod Alwood (garrod.alwood@lorodoes.com)
 * Copyright (C) 2014-2018  MailWatch Team (https://github.com/mailwatch/1.2.0/graphs/contributors)
 *
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * In addition, as a special exception, the copyright holder gives permission to link the code of this program with
 * those files in the PEAR library that are licensed under the PHP License (or with modified versions of those files
 * that use the same license as those files), and distribute linked combinations including the two.
 * You must obey the GNU General Public License in all respects for all of the code used other than those files in the
 * PEAR library that are licensed under the PHP License. If you modify this program, you may extend this exception to
 * your version of the program, but you are not obligated to do so.
 * If you do not wish to do so, delete this exception statement from your version.
 *
 * You should have received a copy of the GNU General Public License along with this program; if not, write to the Free
 * Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

require_once __DIR__ . '/functions.php';

if (file_exists('conf.php')) {
    $output = array();
    if (isset($_GET['mid']) && isset($_GET['subm']) && (isset($_GET['r']) || isset($_GET['amp;r']))) {
        dbconn();
        $mid = deepSanitizeInput($_GET['mid'], 'url');
        if ($mid === false || !validateInput($mid, 'msgid')) {
            die();
        }
        $subm = deepSanitizeInput($_GET['subm'], 'url');
        if ($subm === false) {
            die();
        }
        if (isset($_GET['amp;r'])) {
            $token = deepSanitizeInput($_GET['amp;r'], 'url');
        } else {
            $token = deepSanitizeInput($_GET['r'], 'url');
        }
        if (!validateInput($token, 'releasetoken')) {
            header('Location: login.php?error=pagetimeout');
            die();
        }

        # Validate trusted networks, if present
        $remote_ip = $_SERVER['REMOTE_ADDR'];

        if (file_exists('/etc/sysconfig/eFa_trusted_networks') && filesize("/etc/sysconfig/eFa_trusted_networks") > 0) {
            $is_trusted_network = 0 ;
            $file = fopen('/etc/sysconfig/eFa_trusted_networks', 'r');
            if ($file) {
                while (($line = fgets($file, 80)) !== false) {
                    $line = rtrim($line);
                    if (!preg_match('/:/', $line)) { # assume ipv4 if it does not contain a colon
                        if(ipv4_in_range($remote_ip, $line)) {
                            $is_trusted_network = 1;
                        }
                    } elseif (preg_match('/:/', $line)) { # assume ipv6 if it contains a colon
                        if (ipv6_in_range($remote_ip,$line)) {
                            $is_trusted_network = 1;
                        }
                    }
                }
                if ($is_trusted_network === 0) {
                  header("Location: login.php?error=pagetimeout");
                  die();
                }
                fclose($file);
            }
        }

        $efa_config = preg_grep('/^EFASQLPWD/', file('/etc/eFa/eFa-Config'));
        foreach($efa_config as $num => $line) {
            if ($line) {
                $db_pass_tmp = chop(preg_replace('/^EFASQLPWD:(.*)/','$1', $line));
            }
        }
        $efadb = new mysqli('localhost', 'efa', $db_pass_tmp, 'efa');
        mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
        $sql = "SELECT id,token FROM tokens WHERE mid = '$mid'";
        $result = $efadb->query($sql);
        if (!$result) {
            dbg('Error fetching from database');
            $output[] = __('dberror59');
        }
        if ($result->num_rows === 0) {
            $output[] = __('msgnotfound159');
            $output[] = __('msgnotfound259') . htmlentities($mid);
        } else {
            $row = $result->fetch_assoc();
            if ($row['token'] === $token) {
                $list = quarantine_list_items($mid);
                $result = '';
                if (count($list) > 0) {
                    $output[] = quarantine_learn($list, array(0), 'spam');
                }
                //cleanup
                $learnID = $row['id'];
                $query = "DELETE FROM tokens WHERE id = '$learnID'";
                $result = $efadb->query($query);
                if (!$result) {
                    dbg('ERROR cleaning up database... ');
                }
            } else {
                $output[] = __('tokenmismatch59');
            }
            $efadb->close();
        }
    } elseif (isset($_GET['mid']) && (isset($_GET['r']) || isset($_GET['amp;r']))) {
        $mid = deepSanitizeInput($_GET['mid'], 'url');
        if ($mid === false || !validateInput($mid, 'msgid')) {
            die();
        }
        if (isset($_GET['amp;r'])) {
            $token = deepSanitizeInput($_GET['amp;r'], 'url');
        } else {
            $token = deepSanitizeInput($_GET['r'], 'url');
        }
        if (!validateInput($token, 'releasetoken')) {
            header('Location: login.php?error=pagetimeout');
            die();
        }
	$subm = true;
	$url = parse_url($_SERVER["REQUEST_URI"], PHP_URL_PATH);
        $output[] = 'Submit Message: ' . $mid . '.';
	$output[] = '<form method="get" action="' . $url . '">';
	$output[] = '<input type="hidden" name="mid" value="' . $mid . '" />';
        $output[] = '<input type="hidden" name="r" value="' . $token . '" />';
        $output[] = '<input type="hidden" name="subm" value="' . $subm . '" />';
	$output[] = '<p><input type="submit" value="Submit"></p>';
	$output[] = '</form>';
    } else {
        $output[] = __('notallowed59');
    }
    echo '
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>' . __('spam103') . __('learn03') . '</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="shortcut icon" href="images/favicon.png">
    <link rel="stylesheet" href="style.css" type="text/css">
    ' . (is_file(__DIR__ . '/skin.css') ? '<link rel="stylesheet" href="skin.css" type="text/css">' : '') . '
</head>
<body class="autorelease">
<div class="autorelease">
    <img src=".' . IMAGES_DIR . MW_LOGO . '" alt="' . __('mwlogo99') . '">
    <div class="border-rounded">
        <h1>' . __('spam103') . " " .  __('learn03') . '</h1>' . "\n";
    foreach ($output as $msg) {
        echo '<p>' . $msg . '</p>' . "\n";
    }
    echo '
    </div>
</div>
</body>
</html>';
} else {
    echo __('cannot_read_conf');
}

/*
 * ip_in_range.php - Function to determine if an IP is located in a
 *                   specific range as specified via several alternative
 *                   formats.
 *
 * Network ranges can be specified as:
 * 1. Wildcard format:     1.2.3.*
 * 2. CIDR format:         1.2.3/24  OR  1.2.3.4/255.255.255.0
 * 3. Start-End IP format: 1.2.3.0-1.2.3.255
 *
 * Return value BOOLEAN : ip_in_range($ip, $range);
 *
 * Copyright 2008: Paul Gregg <pgregg@pgregg.com>
 * 10 January 2008
 * Version: 1.2
 *
 * Source website: http://www.pgregg.com/projects/php/ip_in_range/
 * Version 1.2
 *
 * This software is Donationware - if you feel you have benefited from
 * the use of this tool then please consider a donation. The value of
 * which is entirely left up to your discretion.
 * http://www.pgregg.com/donate/
 *
 * Please do not remove this header, or source attibution from this file.
 */

/*
* Modified by James Greene <james@cloudflare.com> to include IPV6 support
* (original version only supported IPV4).
* 21 May 2012
*/


// decbin32
// In order to simplify working with IP addresses (in binary) and their
// netmasks, it is easier to ensure that the binary strings are padded
// with zeros out to 32 characters - IP addresses are 32 bit numbers
function decbin32 ($dec) {
    return str_pad(decbin($dec), 32, '0', STR_PAD_LEFT);
}

// ipv4_in_range
// This function takes 2 arguments, an IP address and a "range" in several
// different formats.
// Network ranges can be specified as:
// 1. Wildcard format:     1.2.3.*
// 2. CIDR format:         1.2.3/24  OR  1.2.3.4/255.255.255.0
// 3. Start-End IP format: 1.2.3.0-1.2.3.255
// The function will return true if the supplied IP is within the range.
// Note little validation is done on the range inputs - it expects you to
// use one of the above 3 formats.
function ipv4_in_range($ip, $range) {
    if (strpos($range, '/') !== false) {
        // $range is in IP/NETMASK format
        list($range, $netmask) = explode('/', $range, 2);
        if (strpos($netmask, '.') !== false) {
            // $netmask is a 255.255.0.0 format
            $netmask = str_replace('*', '0', $netmask);
            $netmask_dec = ip2long($netmask);
            return ( (ip2long($ip) & $netmask_dec) == (ip2long($range) & $netmask_dec) );
        } else {
            // $netmask is a CIDR size block
            // fix the range argument
            $x = explode('.', $range);
            while(count($x)<4) $x[] = '0';
            list($a,$b,$c,$d) = $x;
            $range = sprintf("%u.%u.%u.%u", empty($a)?'0':$a, empty($b)?'0':$b,empty($c)?'0':$c,empty($d)?'0':$d);
            $range_dec = ip2long($range);
            $ip_dec = ip2long($ip);

            # Strategy 1 - Create the netmask with 'netmask' 1s and then fill it to 32 with 0s
            #$netmask_dec = bindec(str_pad('', $netmask, '1') . str_pad('', 32-$netmask, '0'));

            # Strategy 2 - Use math to create it
            $wildcard_dec = pow(2, (32-$netmask)) - 1;
            $netmask_dec = ~ $wildcard_dec;

            return (($ip_dec & $netmask_dec) == ($range_dec & $netmask_dec));
        }
    } else {
        // range might be 255.255.*.* or 1.2.3.0-1.2.3.255
        if (strpos($range, '*') !==false) { // a.b.*.* format
            // Just convert to A-B format by setting * to 0 for A and 255 for B
            $lower = str_replace('*', '0', $range);
            $upper = str_replace('*', '255', $range);
            $range = "$lower-$upper";
        }

        if (strpos($range, '-')!==false) { // A-B format
            list($lower, $upper) = explode('-', $range, 2);
            $lower_dec = (float)sprintf("%u",ip2long($lower));
            $upper_dec = (float)sprintf("%u",ip2long($upper));
            $ip_dec = (float)sprintf("%u",ip2long($ip));
            return ( ($ip_dec>=$lower_dec) && ($ip_dec<=$upper_dec) );
        }
        return false;
    }
}

function ip2long6($ip) {
    if (substr_count($ip, '::')) {
        $ip = str_replace('::', str_repeat(':0000', 8 - substr_count($ip, ':')) . ':', $ip);
    }

    $ip = explode(':', $ip);
    $r_ip = '';

    foreach ($ip as $v) {
        $r_ip .= str_pad(base_convert($v, 16, 2), 16, 0, STR_PAD_LEFT);
    }

    return gmp_convert($r_ip, 2, 10);
}

// Get the ipv6 full format and return it as a decimal value.
function get_ipv6_full($ip)
{
    $pieces = explode ("/", $ip, 2);
    $left_piece = $pieces[0];
    $right_piece = $pieces[1];

    // Extract out the main IP pieces
    $ip_pieces = explode("::", $left_piece, 2);
    $main_ip_piece = $ip_pieces[0];
    $last_ip_piece = $ip_pieces[1];

    // Pad out the shorthand entries.
    $main_ip_pieces = explode(":", $main_ip_piece);
    foreach($main_ip_pieces as $key=>$val) {
        $main_ip_pieces[$key] = str_pad($main_ip_pieces[$key], 4, "0", STR_PAD_LEFT);
    }

    // Check to see if the last IP block (part after ::) is set
    $last_piece = "";
    $size = count($main_ip_pieces);
    if (trim($last_ip_piece) != "") {
        $last_piece = str_pad($last_ip_piece, 4, "0", STR_PAD_LEFT);

        // Build the full form of the IPV6 address considering the last IP block set
        for ($i = $size; $i < 7; $i++) {
            $main_ip_pieces[$i] = "0000";
        }
        $main_ip_pieces[7] = $last_piece;
    }
    else {
        // Build the full form of the IPV6 address
        for ($i = $size; $i < 8; $i++) {
            $main_ip_pieces[$i] = "0000";
        }
    }

    // Rebuild the final long form IPV6 address
    $final_ip = implode(":", $main_ip_pieces);

    return ip2long6($final_ip);
}


// Determine whether the IPV6 address is within range.
// $ip is the IPV6 address in decimal format to check if its within the IP range created by the cloudflare IPV6 address, $range_ip. 
// $ip and $range_ip are converted to full IPV6 format.
// Returns true if the IPV6 address, $ip,  is within the range from $range_ip.  False otherwise.
function ipv6_in_range($ip, $range_ip)
{
    $pieces = explode ("/", $range_ip, 2);
    $left_piece = $pieces[0];
    $right_piece = $pieces[1];

    // Extract out the main IP pieces
    $ip_pieces = explode("::", $left_piece, 2);
    $main_ip_piece = $ip_pieces[0];
    $last_ip_piece = $ip_pieces[1];

    // Pad out the shorthand entries.
    $main_ip_pieces = explode(":", $main_ip_piece);
    foreach($main_ip_pieces as $key=>$val) {
        $main_ip_pieces[$key] = str_pad($main_ip_pieces[$key], 4, "0", STR_PAD_LEFT);
    }

    // Create the first and last pieces that will denote the IPV6 range.
    $first = $main_ip_pieces;
    $last = $main_ip_pieces;

    // Check to see if the last IP block (part after ::) is set
    $last_piece = "";
    $size = count($main_ip_pieces);
    if (trim($last_ip_piece) != "") {
        $last_piece = str_pad($last_ip_piece, 4, "0", STR_PAD_LEFT);

        // Build the full form of the IPV6 address considering the last IP block set
        for ($i = $size; $i < 7; $i++) {
            $first[$i] = "0000";
            $last[$i] = "ffff";
        }
        $main_ip_pieces[7] = $last_piece;
    }
    else {
        // Build the full form of the IPV6 address
        for ($i = $size; $i < 8; $i++) {
            $first[$i] = "0000";
            $last[$i] = "ffff";
        }
    }

    // Pad out the shorthand entries.
    $ip = expandIPv6($ip);
    $ip_pieces = explode(":", $ip);
    foreach($ip_pieces as $key=>$val) {
        $ip_pieces[$key] = str_pad($ip_pieces[$key], 4, "0", STR_PAD_LEFT);
    }

    // Rebuild the final long form IPV6 address
    $first = ip2long6(implode(":", $first));
    $last = ip2long6(implode(":", $last));
    $ip = ip2long6(implode(":", $ip_pieces));
    $in_range = ($ip >= $first && $ip <= $last);

    return $in_range;
}

// base converter using gmp
function gmp_convert($num, $base_a, $base_b)
{
        return gmp_strval ( gmp_init($num, $base_a), $base_b );
}

// expand IPv6
function expandIPv6($ip) {
    $hex = bin2hex(inet_pton($ip));
    return implode(':', str_split($hex, 4));
}