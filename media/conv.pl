#!/usr/bin/env perl

# Copyright (c) 2007, Derek Buitenhuis <derek.buitenhuis at gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for any purpose with
# or without fee is hereby granted, provided that the above copyright notice and this
# permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD
# TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN
# NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
# DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER
# IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
# CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

use strict;
use POSIX;

#Variables to Change
my $path = "C:\\Program Files (x86)\\MKVtoolnix\\";

#Don't edit under here
my $file = $ARGV[0];
my $filename = $ARGV[1];
my $delay = $ARGV[2];
my $f1 = substr($filename,-3,3) eq "mp4" ? 101 : 0;

if (!$delay) {
    print "USAGE: conv.pl <frames_file> <aac_or_mp4_file> <delay>\n\n";
    print "Ex:\nconv.pl frames.txt my.aac -122 > my.bat\n";
    print "or\n";
    print "conv.pl frames.txt my.mp4 -122 > my.bat\n";
    exit();
}

sub arg {
    return floor(($_[0]*1000)+0.5)/1000;
}

sub timeformat {
    my $tbase = $_[0];
    my $thours = floor(($tbase/3600));
    $tbase -= ($thours*3600);
    my $tmins = floor($tbase/60);
    $tbase -= ($tmins * 60);
    if ($tmins < 10) {
        $tmins = "0".$tmins;
    }
    my $tsecs = $tbase;
    $tbase -= $tsecs;
    if ($thours < 10) {
        $thours = "0".$thours;
    }
    if (length($tsecs) == 4) {
        $tsecs .= "0";
    }
    elsif (length($tsecs) == 2) {
        $tsecs .= ".00";
    }
    $tsecs = arg($tsecs);
    if ($tsecs < 10) {
        $tsecs = "0".$tsecs;
    }
    if ($tbase != 0) {
        print("ERROR: End time not zero.");
        return;
    }
    return $thours.":".$tmins.":".$tsecs
}

open(fass,"<:utf8",$file) or die("File cannot be opened.");

my $cnt;
my $odd;
my $rstring = "";
my $line = <fass>;
my $fps = eval($line);
$line = <fass>;

while ($line) {
    my @split = split(/,/,$line);
    my $s = timeformat(($split[0]/$fps) - ($delay/1000));
    my $e = timeformat(($split[1]/$fps) - ($delay/1000));
    if ($s eq "00:00:00") {
        $rstring .= $e.",";
        $odd = 1;
    }
    elsif ($e eq "00:00:00") {
        $rstring .= $s.",";
    }
    else {
        $rstring .= $s.",".$e.",";
    }
    $cnt++;
    $line = <fass>;
}

$cnt = ($cnt*2)+1;

chop($rstring);

print "\"".$path."mkvmerge\" -o \"tmp.mka\" -a ".$f1." -D -S \"".$filename."\" --track-order 0:".$f1." --split timecodes:".$rstring."\n";

for (my $i = 1; $i <= $cnt; $i++) {
    my $c = $i < 10 ? "0".$i : $i;
    if (!$odd) {
        unless ($i % 2) {
            print "\"".$path."mkvextract\" tracks \"tmp-0".$c.".mka\" 1:\"".($i/2).".aac\"\n";
        }
    }
    elsif ($odd) {
        if ($i % 2) {
            print "\"".$path."mkvextract\" tracks \"tmp-0".$c.".mka\" 1:\"".(($i+1)/2).".aac\"\n";
        }
    }
    print "del tmp-0".$c.".mka\n";
}

print "copy /b ";

$cnt = ($cnt-1)/2;

for (my $i = 1; $i <= $cnt; $i++) {
    if ($i == $cnt) {
        print $i.".aac";
    }
    else {
        print $i.".aac+";
    }
}

print " final.aac\n";

for (my $i = 1; $i <= $cnt; $i++) {
    print "del ".$i.".aac\n";
}