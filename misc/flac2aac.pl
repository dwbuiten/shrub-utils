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
use Cwd;

# User variables
my $bin = "C:\\bin";
my $in = getcwd();
$in =~ s/\//\\/g;
my $out = "C:\\out";
my @tmp = split(/\\/, $in);
$out .= "\\".$tmp[scalar(@tmp)-1]."";

my @files = `dir /b "$in\\*.flac"`;

print "Making Output directory in $out ...";
`mkdir "$out"`;

foreach(@files) {

    chomp;

    my $file = $_;

    my @info = `$bin\\metaflac --show-tag=tracknumber --show-tag=title --show-tag=artist --show-tag=album "$file"`;
    my $artist;
    my $track;
    my $album;
    my $title;

    foreach(@info) {
        chomp;
        my @info2 = split(/=/);
        if (uc($info2[0]) eq "TRACKNUMBER") {
            if ($info2[1] =~ /\//) {
                my @sp = split(/\//, $info2[1]);
                $track  = $sp[0];
            } else {
                $track = $info2[1];
            }
        } elsif (uc($info2[0]) eq "TITLE") {
            $title = $info2[1];
        } elsif (uc($info2[0]) eq "ARTIST") {
            $artist = $info2[1];
        } elsif (uc($info2[0]) eq "ALBUM") {
            $album = $info2[1];
        }
    }

    print "\nUnpacking $track $artist - $title...\n\n";
    `$bin\\flac -d "$in\\$file" -o "$out\\$track $artist - $title.wav"`;
    print "\nEncoding $track $artist - $title...\n\n";
    `$bin\\neroaacenc -lc -q 0.5 -if "$out\\$track $artist - $title.wav" -of "$out\\$track $artist - $title.mp4"`;
    print "\nTagging $track $artist - $title...\n\n";
    `$bin\\neroaactag "$out\\$track $artist - $title.mp4" -meta:track=$track -meta:artist="$artist" -meta:title="$title" -meta:album="$album"`;
    print "\nDeleting wav file for $track $artist - $title...\n\n";
    `del "$out\\$track $artist - $title.wav"`;

}