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

use strict;
use warnings;
use POSIX;

sub get_time {
    my ($frame) = @_;

    my $seconds = ($frame * 1001) / 30000;
    my $hours   = int($seconds / 3600);

    $seconds -= $hours * 3600;

    my $minutes = int($seconds / 60);

    $seconds -= $minutes * 60;
    $seconds  = (floor($seconds * 1000) / 1000);

    return sprintf("%02d:%02d:%05.2f", $hours, $minutes, $seconds);
}

my @x;
my @y;
my @diffx;
my @diffy;
my $i = -1;
my $a = "{\\bord0\\shad0\\1c&H525951&\\be1\\b1\\frz16.73\\pos("; #Opening Style tags.
my $b = ")}WHAM"; # Ending tag.
my $startx = 322000; # Start x pos.
my $starty = 318000; # start y pos.

open(FILE, "<", "data.txt"); # Data file exported from Mocha as transform data.
while(<FILE>) {
    chomp;

    my @ar = split(' ');

    $x[++$i] = $ar[1] * 1000;
    $y[$i]   = $ar[2] * 1000;
}
close(FILE);

for (0 .. $i) {
    $diffx[$_] = $x[0] - $x[$_];
    $diffy[$_] = $y[0] - $y[$_];
}

foreach(0 .. $i) { 
    printf("Dialogue: 0,%s,%s,Default,,0000,0000,0000,,%s%.3f,%.3f%s\n", get_time($_), get_time($_ + 1), $a, (($startx - $diffx[$_]) / 1000.0), (($starty - $diffy[$_]) / 1000), $b);
}