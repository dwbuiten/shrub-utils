#!/usr/bin/env perl

# Copyright (c) 2008, Derek Buitenhuis <derek.buitenhuis at gmail.com>
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

# Main Program
my ($template, $avs) = @ARGV;

my @names = &get_chapt_names($template);
my @chapt_times = &read_chapts($avs);

(scalar(@names) == scalar(@chapt_times)) or die("Not the same number of chapter names and actual chapters");

open(QPFILE, ">", "$avs.qp");
foreach (@chapt_times) {
    print QPFILE &fps_change($_)." I -1\n";
}
close(QPFILE);

open(CHFILE, ">", "$avs.txt");
for (1 .. scalar(@chapt_times)) {
    print CHFILE sprintf("CHAPTER%02d=", $_).&get_chapt_time($chapt_times[$_ - 1])."\n";
    print CHFILE sprintf("CHAPTER%02dNAME=", $_).$names[$_ - 1]."\n";
}
close(CHFILE);

print "Chapter File Created: $avs.txt\n";
print "QPFile Created: $avs.qp\n";

# Name is self-explanitory.
sub chomp_array {
    my @inp = @_;

    foreach (@inp) {
        chomp;
    }

    return @inp;
}

# Frame Number @ 30 FPS -> Frame Number @ 24 FPS
sub fps_change {
    my ($frame) = @_;

    return int(($frame * 4) / 5);
}

# 30fps Frame Number -> 24 FPS Chapter Time
sub get_chapt_time {
    my ($frame) = @_;

    $frame = &fps_change($frame);

    my $seconds = ($frame * 1001) / 24000;
    my $hours = int($seconds / 3600);
    $seconds -= $hours * 3600;
    my $minutes = int($seconds / 60);
    $seconds -= $minutes * 60;
    $seconds = floor($seconds * 1000) / 1000;

    return sprintf("%02d:%02d:%06.3f", $hours, $minutes, $seconds);
}

# Read in Chapters from Template
sub get_chapt_names {
    my ($template_file) = @_;

    open(my $t_handle, "<", $template_file) or die("Template file cannot be opened");
    my @ret = <$t_handle>;
    close($t_handle);

    return &chomp_array(@ret);
}

sub read_chapts {
    my ($avs_file) = @_;

    open(my $avs_handle, "<", $avs_file) or die("AVS file cannot be opened");

    my @trims;
    while (<$avs_handle>) {
        if (/trim\(\d+,\d+\)/i) {
            chomp;
            @trims = split(/\++/);
            last;
        }
    }

    close($avs_handle);

    {
        my @frms;
        my $frmstrt;
        my $cnt = 0;
        foreach (@trims) {
            s/.*trim\((\d+,\d+)\).*/$1/i;
            @frms = split(/,/);
            unless ($frmstrt) {
                $frmstrt = $frms[0];
            }
            else {
                $frmstrt += $frms[0] - 1;
            }
            my $tmp = $frms[0] - $frmstrt;
            s/.*/$tmp/;
            $cnt++;
            $frmstrt -= $frms[1];
        }
    }

    return @trims;
}