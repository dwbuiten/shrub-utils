# shrub-utils #

Mostly useless one-offs over years of shrubbery.

## Description ##

These are mostly one-off hacked-together scripts I've written or acquired over the last 8 years of working with fan-made shrubs and related media. They're mostly archived here for historical reasons, though some may still be useful.

They are mostly very poorly written one-offs, or stuff I deemed "good enough" to get the job done, so expect the code to be terrible and non-idiomatic.

# How to use #

Whatever I remember about these is documented here.

## ancient/avs_tc.pl ##

**Author**: Me<br />
**Description**: Given a v1 timecodes file, it will generates an [Avisynth](http://avisynth.org/mediawiki/Main_Page) script which converts any non-24/30 fps sections to 30 fps via frame blending.<br />
**Use**: I used it to convert 60 fps sections of scrolling credits, from "120 fps" AVI files, after null frames had been removed. Very buggy, and the timecodes file had to be adjusted manually after.<br />

## ancient/tc_man.pl ##
**Author**: Me<br />
**Description**: Scales a given section in a v1 timecodes file to a different framerate, and adjusts all following sections.<br />
**Use**: Generally used to supplement *avs_tc.pl*, and update the timecodes file after.<br />

## ass/karaoke/ ##

**Author**: Rodrigo Braz Monteiro, Mohd. Hafizuddin B. M. Marzuki, Niels Martin Hansen<br />
**Description**: Random karaoke effects for [Aegisub](http://www.aegisub.org/) or [OverLua](https://github.com/Aegisub/OverLua) I've accrued.<br />
**Use**: Very little. Just interesting to use as examples.<br />

## ass/aegisub.js ##

**Author**: Me<br />
**Description**: A plugin script for [HandySaw DS](http://www.davisr.com/en/products/handysaw/description.htm) which will allow it to output a keyframes file [Aegisub](http://www.aegisub.org/) can chew on.<br />
**Use**: The generated keyframes tend to better represent scene changes than [Xvid](http://www.xvid.org/) or [x264](http://www.videolan.org/developers/x264.html) keyframe decisions. Used for assisted or automated scene timing.<br />

## ass/gradient.pl ##

**Author**: Me<br />
**Description**: Generates ASS tags for gradients. A lot of stuff is hardcoded, such as source tags / text.<br />
**Use**: Used for making text and objects with a multicolored gradient effects; used when typesetting signs.<br />

## ass/medusa_collisions.lua ##

**Author**: Me<br />
**Description**: Generates a list of colliding lines in an open script, in [Aegisub](http://www.aegisub.org/), using [Medusa](http://sourceforge.net/projects/medusa/)'s collision algorithm.<br />
**Use**: Easily know which lines to style as overlaps. To this day, I don't think [Aegisub](http://www.aegisub.org/) has a way to easily view this info in a column or summary; you have to select every line manually.<br />

## ass/mocha2ass.pl ##

**Author**: Me<br />
**Description**: Applies some simple [After Effects](http://www.adobe.com/ca/products/aftereffects.html) transform movement data to some hardcoded text and / or ASS tags.<br />
**Use**: Of little use nowadays. I used it to apply [Mocha](http://www.imagineersystems.com/products/mochapro) transform data to subtitles for sign typesetting. You should use [Aegisub-Motion](https://github.com/torque/Aegisub-Motion) instead.<br />

## media/chapt.pl ##

**Author**: Me<br />
**Description**: Given a set of frames ranges and a chapter naming template, it will generate a qpfile for [x264](http://www.videolan.org/developers/x264.html) and [Ogg-style](http://wiki.xiph.org/Chapter_Extension) chapters to be used with [MKVToolNix](http://www.bunkus.org/videotools/mkvtoolnix/).<br />
**Use**: Automating chapter creation. I still use it, but nowadays you should use *[vfr.py](https://github.com/wiiaboo/vfr)*.<br />

## media/conv.pl ##

**Author**: Me<br />
**Description**: Given a set of frame ranges, it will generate a batch file to trim sections out of an AAC file, which may or may not be in an MP4 container. Can be trivially extended to work with other audio formats that [MKVToolNix](http://www.bunkus.org/videotools/mkvtoolnix/) supports.<br />
**Use**: Exactly what it says on the tin. It is mostly here for archival purposes, since it was supposedly the inspiration for TheFluff to write his "famous" *split_aud.pl*. I still use it to this day, but nowadays, you should use *[vfr.py](https://github.com/wiiaboo/vfr)*.<br />

## media/ffcheck.pl ##

**Author**: Me<br />
**Description**: Prints out any [FreezeFrame](http://avisynth.org/mediawiki/FreezeFrame) invocations that are not one frame operations (that is, ranged), as well as any that are 1 frame, but have discontinuities (they don't freeze using the next or previous frame).<br />
**Use**: When you spend hours in [YATTA](http://ivtc.org/), you doing upwards of 10,000 freezeframes, you will likely screw up a few. This just helps finding them ahead of time.<br />

## media/frm.pl ##

**Author**: Me<br />
**Description**: Generates a frame range list given a [YATTA](http://ivtc.org/)-produced [Avisynth](http://avisynth.org/mediawiki/Main_Page) script.<br />
**Use**: Supplements *conv.pl*; generates frame ranges it takes as input. I was too lazy to combine scripts.<br />

## media/fu.c ##

**Author**: Me<br />
**Description**: Dumps the quantization matrices for luma and chroma from JPEG files. Probably buggy, very inefficient; written for a one-off experiment.<br />
**Use**: Can be used to dump matrices for large collections of JPEGs.<br />

## media/inv.pl ##

**Author**: Me<br />
**Description**: Takes a list of frame ranges that will be cut from a video, and generates a list of frame ranges that will be included.<br />
**Use**: I used it to generate frame ranges to cut audio with, using list of cuts in [YATTA](http://ivtc.org)'s cutting window, while YMC was still running. Purely for convenience.<br />

## media/mkvkeyframes.pl ##

**Author**: Me<br />
**Description**: One-liner to print all the keyframes from a matroska file.<br />
**Use**: No idea.<br />

## media/mp4keyframes.pl ##

**Author**: Me<br />
**Description**: One-liner to print all keyframes for an MP4 file, given its [NHML](http://gpac.wp.mines-telecom.fr/mp4box/media-import/nhml-format/) file as input.<br />
**Use**: No idea.<br />

## media/parallel.pl ##

**Auhtor**: Me<br />
**Description**: Encodes a given [Avisynth](http://avisynth.org/mediawiki/Main_Page) script in an arbitrary amount of chunks in parallel, and generates another script to to combine said chunks.<br />
**Use**: Easy parallel processing of slow scripts and encode automation.<br />

## media/ParalellEncoding.cmd ##

**Author**: Nicholi<br />
**Description**: Same as *parallel.pl*, though does some unnecessary things with the registry and [Xvid](http://www.xvid.org) and stuff. Does not require Perl.<br />
**Use**: Drag and drop parallel encoding for newbies.<br />

## media/vfrrender.coffee ##

**Author**: Me<br />
**Description**: Generates an [After Effects](http://www.adobe.com/ca/products/aftereffects.html) composition with timecodes applied from a v1 timecodes file. Allows one to render a time-based composition such as karaoke in such a way that it can be overlaid on a VFR video. CoffeeScript version written in 2013, but it has existed in some form since 2007. Has a known bug which requires the last section of the timecodes file to be explicit, rather than implicit.<br />
**Use**: I used it only for karaoke. Possibly has other uses.<br />

## misc/wv2aac.pl ##

**Author**: Me<br />
**Description**: Batch converts [WavPack](http://www.wavpack.com) files to AAC files, encoded by [Nero's AAC Encoder](http://www.nero.com/enu/company/about-nero/nero-aac-codec.php), while keeping metadata intact.<br />
**Use**: Exactly what it says on the tin.<br />

## misc/vdub.pl ##

**Author**: Me<br />
**Description**: Spams [VirtualDub](http://www.virtualdub.org/) encoding status to IRC, via [XChat](http://xchat.org/). Old and untested in years.<br />
**Use**: Allows you to be obnoxious.<br />

## misc/flac2aac.pl ##

**Author**: Me<br />
**Description**: Same as *wv2aac.pl*, but for [FLAC](http://flac.sourceforge.net/).<br />
**Use**: Exactly what it says on the tin.<br />
