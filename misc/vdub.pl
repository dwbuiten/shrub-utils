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
use Math::Round;
use Win32::GuiTest qw/
    FindWindowLike
    GetWindowText
    /;

Xchat::register("VirtualDub Status ","0.01","Prints VirtualDub encode status to screen.");
IRC::add_command_handler("vdub","spam");
IRC::print("VirtualDub Status 0.01 by Derek Buitenhuis Loaded.");

sub set_stats {
    my @ar;

    my @vd = FindWindowLike(undef,"VirtualDub","#32770");
    if (scalar(@vd) < 1) {
        return 0;
    }
    my @a = FindWindowLike($vd[0],".","Static");
    my $count = 0;
    
    foreach (@a) {
        $ar[$count] = GetWindowText($_);
        $count++;
    }
    $ar[$count] = GetWindowText(@vd);
    return @ar;
}

sub perc_parse {
    my @frames = split(/\//,$_[0]);
    return nearest(.1,($frames[0]/$frames[1])*100);
}

sub bar {
    my $bar;
    my $num = nearest(10,$_[0]);
    for (my $i=10; $i <= 100; $i+=10) {
        if ($num >= $i) {
            $bar .= "\cC04|";
        }
        else {
            $bar .= "\cC15-";
        }
    }
    return $bar;
}

sub fsize {
    my @fs = split(/ /,$_[0]);
    return $fs[0];
}

sub filen {
    my $len = length($_[0]);
    return substr($_[0],21,$len-22);
}

sub spam {
    my @ar = set_stats();
    
    unless (scalar(@ar) > 1) {
        IRC::print "VirtualDub is not running!";
        return Xchat::EAT_ALL;
    }

    my $file = filen($ar[18]);
    my $perc = perc_parse($ar[4]);
    my $bar = bar($perc);
    my $fsize = fsize($ar[11]);

    Xchat::command "SAY \cC05[\cC15VirtualDub\cC05] [\cC15File: $file\cC05] [\cC15$perc%\cC05] [\cC15$bar\cC05] [\cC15$ar[4] frames encoded at $ar[14]\cC05] [\cC15Elapsed: $ar[7]\cC05] [\cC15Total Esitated: $ar[6]\cC05] [\cC15Filesize: $fsize\cC05] [\cC15Proj. Filesize: $ar[13]\cC05]";
    return Xchat::EAT_ALL;
}