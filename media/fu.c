/*
 * Copyright (c) 2013, Derek Buitenhuis
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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define MAX(x, y) (x > y ? x : y)

static const int zig[64] = {
     0,  1,  5,  6, 14, 15, 27, 28,
     2,  4,  7, 13, 16, 26, 29, 42,
     3,  8, 12, 17, 25, 30, 41, 43,
     9, 11, 18, 24, 31, 40, 44, 53,
    10, 19, 23, 32, 39, 45, 52, 54,
    20, 22, 33, 38, 46, 51, 55, 60,
    21, 34, 37, 47, 50, 56, 59, 61,
    35, 36, 48, 49, 57, 58, 62, 63
};

int main(int argc, char *argv[])
{
    FILE *fp;
    uint8_t b;
    uint8_t cqm[4][64];
    int loc = 0;
    int j, k, l;
    int max = 0;
    int len;
    int skip = 0;

    fp = fopen(argv[1], "rb");
    fseek(fp, 0, SEEK_END);
    len = ftell(fp);
    fseek(fp, 2, SEEK_SET);

    while (len - 2 > loc) {

        fread(&b, 1, 1, fp);
        loc++;

        if (b == 0xFF) {
            fread(&b, 1, 1, fp);
            loc++;

            if (b == 0xD8) {
                skip = 1;
            } else if (b == 0xDB) {
                uint8_t bytes[2];
                uint16_t bytesleft;

                if (skip) {
                    skip = 0;
                    continue;
                }

                fread(&bytes[1], 1, 1, fp);
                fread(&bytes[0], 1, 1, fp);
                loc += 2;

                bytesleft = (bytes[0] | bytes[1]) - 2;

                while (bytesleft) {
                    uint8_t entry, left, right;
                    int i;

                    fread(&entry, 1, 1, fp);
                    loc++;

                    left  = (entry & 0xF0) >> 4;
                    right =  entry & 0x0F;

                    bytesleft -= 1 + (left + 1) * 64;

                    max = MAX(max, right + 1);

                    for (i = 0; i < 64; i++)
                        fread(&cqm[right][i], 1, 1, fp);
                    loc += 64;
                }
            }
        }
    }

    for (l = 0; l < max; l++) {
        printf("cqm[%d][64] = {\n", l);

        for (j = 0; j < 8; j++) {
            printf("    ");

            for(k = 0; k < 8; k++) {
                if (j == 7 && k == 7)
                    printf("%3d ", cqm[l][zig[j * 8 + k]]);
                else
                    printf("%3d, ", cqm[l][zig[j * 8 + k]]);
            }

            printf("\n");
        }

        printf("};\n\n");
    }

    return 0;
}
