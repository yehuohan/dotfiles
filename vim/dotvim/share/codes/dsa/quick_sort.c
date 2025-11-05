int partition(int* pdata, int lo, int hi) {
    int pivot = pdata[lo];
    while (lo < hi) {
        while (lo < hi && pdata[hi] >= pivot)
            hi--;
        pdata[lo] = pdata[hi];
        while (lo < hi && pdata[lo] <= pivot)
            lo++;
        pdata[hi] = pdata[lo];
    }
    pdata[lo] = pivot;
    return lo;
}

void quick_sort(int* pdata, int lo, int hi) {
    if (hi - lo < 2)
        return;
    int mi = partition(pdata, lo, hi - 1);
    quick_sort(pdata, lo, mi);
    quick_sort(pdata, mi + 1, hi);
}
