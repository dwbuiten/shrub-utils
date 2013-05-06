#!/usr/bin/env perl

# Copyright (c) 2009, Derek Buitenhuis <derek.buitenhuis at gmail.com>
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
use Cwd;

# User Set Variables

my $bin = "C:/bin";
my $presets_dir = "C:/bin/scripts/presets";
my $preset = "uty0"; # Dumped frim avs2avi
my $threads = 4;
my $maxmem = 512;

# Arguments

my $input = $ARGV[0];
my $output = $ARGV[1];
my $dir = getcwd();

# Check Arguments

if (scalar(@ARGV) < 2) {
    $0 =~ s/\\/\//g;
    my @path = split(/\//, $0);
    print("Usage: $path[-1] input.avs output.avs\n");
    exit();
} elsif (!-r $input) {
    print("$input does not exist, or is not readable!\n");
    exit();
} elsif (-e $output) {
    print("$output already exists!!\n");
    exit();
}

my $frames = `$bin/avs2yuv.exe $input -frames 1 -o NUL 2>&1`;
$frames =~ s/.* (\d+) frames.*/$1/;
chomp($frames);

print("Creating temp dir...\n");
`mkdir loss`;
`mkdir loss\\scripts`;

my $start = 0;
my $end = int($frames / $threads);

print("Creating avs scripts...\n");
open(my $outavs, ">", $output);
for(my $i = 0; $i < $threads; $i++) {
    open(my $avs, ">", "loss/scripts/$i.avs");
    print $avs "SetMemoryMax($maxmem)\nImport(\"..\\..\\$input\")\ntrim($start, $end)\n";
    print $outavs "avisource(\"loss\\$i.avi\")";
    if ($i != ($threads - 1)) {
        print $outavs "++";
    }
    close($avs);
    $start = $end + 1;
    $end = ($i == ($threads - 2)) ? $frames : $end + int($frames / $threads);
}
close($outavs);

my $cmdline = "";

print("Encoding...\n");
for(my $i = 0; $i < $threads; $i++) {
    $cmdline .= "start \"Thread #".($i+1)."\" /Wait /Low \"$bin/avs2avi.exe\" \"$dir/loss/scripts/$i.avs\" \"$dir/loss/$i.avi\" -l \"$presets_dir/$preset.preset\"";
    if ($i != ($threads - 1)) {
        $cmdline .= " | ";
    }
}
`$cmdline`;
print("Done!\n");