#!/usr/bin/perl

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

####################
# Here be dragons. #
####################

use strict;
use POSIX;

my $o = "0000FF"; # Start color (top or left).
my $e = "FFFFFF"; # End color (bottom or right).
my $p1 = "0,280"; # Top left corner.
my $p2 = "158,433"; # Top right corner.
my $s = 1; # Number of pixels per color.
my $text = "{\\fnFansub Block\\fs300\\pos(124,517)}A"; # Text to be gradified.

sub round {
	my $int = $_[0] + 0.5;
	return floor($int);
}

sub diffs {
	my ($orig, $end, $step) = @_;
	return ($end - $orig) / $step;
}

sub newcols {
	my ($start, $end, $len) = @_;

	my $or = hex(substr($start,0,2));
	my $og = hex(substr($start,2,2));
	my $ob= hex(substr($start,4,2));
	my $er = hex(substr($end,0,2));
	my $eg = hex(substr($end,2,2));
	my $eb= hex(substr($end,4,2));
	
	my $cr = &diffs($or,$er,$len-1);
	my $cg = &diffs($og,$eg,$len-1);
	my $cb = &diffs($ob,$eb,$len-1);
	
	my @ret;
	
	for (my $i = 0; $i < $len; $i++) {
		my $r = &round($or + ($cr * $i));
		my $g = &round($og + ($cg * $i));
		my $b = &round($ob + ($cb * $i));

		$r = sprintf("%X",$r);
		$g = sprintf("%X",$g);
		$b = sprintf("%X",$b);

		if (length($r) == 1) {
			$r = "0".$r;
		}
		if (length($g) == 1) {
			$g = "0".$g;
		}
		if (length($b) == 1) {
			$b = "0".$b;
		}

		$ret[$i] = $r.$g.$b;
	}
	
	return @ret;
}

sub gradx {
	my ($n1,$n2,$spac,$col1,$col2,$text) = @_;
	
	my @pos1 = split(/,/,$n1);
	my @pos2 = split(/,/,$n2);
	my $num = &round(($pos2[0] - $pos1[0]) / $spac);
	my @cols = &newcols($col1,$col2,$num);
	
	for (my $i = 1; $i <= scalar(@cols); $i++) {
		print "{\\1c&H".$cols[$i-1]."&";
		print "\\clip(".($pos1[0]+($spac*$i)-$spac).",".$pos1[1].",".($pos1[0]+($spac*$i)).",".$pos2[1].")";
		print "}".$text."\n";
	}
}

sub grady {
	my ($n1,$n2,$spac,$col1,$col2,$text) = @_;
	
	my @pos1 = split(/,/,$n1);
	my @pos2 = split(/,/,$n2);
	my $num = &round(($pos2[0] - $pos1[0]) / $spac);
	my @cols = &newcols($col1,$col2,$num);
	
	for (my $i = 1; $i <= scalar(@cols); $i++) {
		print "{\\1c&H".$cols[$i-1]."&";
		print "\\clip(".$pos1[0].",".($pos1[1]+($spac*$i)-$spac).",".$pos2[0].",".($pos1[1]+($spac*$i)).")";
		print "}".$text."\n";
	}
}

grady($p1,$p2,$s,$o,$e,$text);