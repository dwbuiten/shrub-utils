# Copyright (c) 2006, Derek Buitenhuis <derek.buitenhuis at gmail.com>
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
use Math::Round;

open file,"< orig_tc.txt";
my $afile = <file>;

my $line;
my $fps = 23.976;
my $credits = 1;

print "orig = #Fill me in!\n\n";

while ($afile) {
    if ($line >= 2) {
        my @t_var = split(/,/,$afile);
        if ((scalar($t_var[2])+1) < $fps && (scalar($t_var[1])-scalar($t_var[0])) < 2) {
            chomp($t_var[2]);
            print "o".($line-2)." = orig.trim(".$t_var[0].",".$t_var[1].").assumefps(".$t_var[2].").changefps(".$fps.")\n";
        }
        elsif ((scalar($t_var[2])-1) > $fps) {
            chomp($t_var[2]);
            print "o".($line-2)." = orig.trim(".$t_var[0].",".$t_var[1].").assumefps(".$t_var[2].")";
            if ($credits) {
                print ".converttoyuy2().convertfps(29.97,zone=80).converttoyv12().assumefps(".$fps.")\n";
            }
            else {
                print " #FIX ME!\n";
            }
        }
        elsif (nearest(.1,scalar($t_var[2])) == nearest(.1,$fps)) {
            print "o".($line-2)." = orig.trim(".$t_var[0].",".$t_var[1].").assumefps(".$fps.")\n";
        }
        else {
            print "LINE ERROR PLEASE FIX PROGRAM!";
        }
    }
    $afile = <file>;
    $line++;
}

close file;

print "\no0";

for (my $i=1; $i <= $line-3; $i++) {
    print "+o".$i;
}