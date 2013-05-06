/*
 * Copyright (c) 2009, Derek Buitenhuis
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

var i;
var report;

report  = "# keyframe format v1\n";
report += "fps " + DInfo.FrameRate + "\n";

DInfo.ProgressMax = DInfo.ScenesCount;

for (i = 0; i < DInfo.ScenesCount && !DInfo.Abort; i++) {
    DInfo.ProgressPosition = i + 1;
    report += DInfo.ScenesStart(i) + "\n";
}

if (!DInfo.Abort) {
    DInfo.Report     = report;
    DInfo.ReportName = DInfo.DefaultReportName.slice(0,-4) + ".txt";
}