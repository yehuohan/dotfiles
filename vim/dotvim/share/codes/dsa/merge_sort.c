#include <string.h>

void merge(int* pdata, int* ptmp, int lo, int mi, int hi) {
    int* p = pdata + lo;
    memcpy(ptmp, p, sizeof(*pdata) * (mi - lo));
    int* pl = ptmp;
    int* pr = pdata + mi;

    int i = 0, j = 0, k = 0;
    while (i < mi - lo && j < hi - mi) {
        if (pl[i] < pr[j]) {
            p[k++] = pl[i++];
        } else {
            p[k++] = pr[j++];
        }
    }
    while (i < mi - lo) {
        p[k++] = pl[i++];
    }
    while (j < hi - mi) {
        p[k++] = pr[j++];
    }
}

void merge_sort(int* pdata, int* ptmp, int lo, int hi) {
    // assert(len(ptmp) >= len(pdata)/2);
    if (hi - lo < 2) {
        return;
    }
    int mi = (lo + hi) / 2;
    merge_sort(pdata, ptmp, lo, mi);
    merge_sort(pdata, ptmp, mi, hi);
    merge(pdata, ptmp, lo, mi, hi);
}
