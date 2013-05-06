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

my $file = $ARGV[0]; 
my $p;
my $frm = "30000/1001";
my $t = 0;

open(avs,q{<},$file) or die("file not found");

my $ln = <avs>;
my $cont;

while ($ln) {
    if (($ln =~ m/^[Tt]rim\(\d+\,\d+\)\+\+/) || ($ln =~ m/^[Tt]rim\(\d+\,\d+\)$/)) {
        if ($t) {
            $frm = "24000/1001";
        }
        $p = $ln;
    }
    elsif (($ln =~ m/^[Tt]?[Dd]ecimate/) || ($ln =~ m/DClip/)) {
        $t = 1;
    }
    $ln = <avs>;
}

close(avs);

my @rng = split(/\+\+/,$p);

print $frm."\n";

for (my $i = 0; $i < scalar(@rng); $i++) {
    chomp($rng[$i]);
    $rng[$i] = substr($rng[$i],5,-1);
    print $rng[$i]."\n";
}