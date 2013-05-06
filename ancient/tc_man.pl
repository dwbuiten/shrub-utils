#!/usr/bin/env perl

# Copyright (c) 2010, Derek Buitenhuis <derek.buitenhuis at gmail.com>
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

# Name: tc_man.pl
# Version: 0.01
# Author: Daemon404
# Date: 2006-07-19
# Usage: tc_man.pl <timecodes> <line> <framerate>


use strict;
use Math::Round;

if (!$ARGV[0]) {
    print "tc_man 0.01 by Daemon404\n";
    print "Description: Modifies timecodes to change framerate of one\n".
        "section without messup up all others.\n\n";
    print "Usage: tc_man <timecodes> <line> <framerate>\n";
    print "Note: Check the line you changed the framerate of just in case.\n";
    exit();
}

if (!$ARGV[2]) {
    print "Not enough parameters.\n";
    exit();
}

open(f,"< $ARGV[0]") or die("Timecodes file could not be opened.");

my $n = 0;
my $l;

for (my $i = 0; $i < 2; $i++) {
    $l = <f>;
    print $l;
    $n++;
}

$n++;

for ($n; $n < $ARGV[1]; $n++) {
    $l = <f>;
    print $l;
}

$l = <f>;
my @a = split(/,/,$l);
my $diff = nearest(1,(($a[1] - $a[0]) / $a[2])*$ARGV[2]);

print $a[0] . "," . ($a[0] + $diff) . "," . $ARGV[2] . "\n";

while ($l = <f>) {
    my @a2 = split (/,/,$l);
    print $a2[0] - $diff . "," . ($a2[1] - $diff) . "," . $a2[2];
}

close f;