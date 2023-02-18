void insertion_sort(int* pdata, int lo, int hi) {
    for (int k = lo + 1; k < hi; k ++) {
        int n = k;
        int tmp = pdata[n];
        while (n > lo && tmp < pdata[n-1]) {
            pdata[n] = pdata[n-1];
            n--;
        }
        pdata[n] = tmp;
    }
}
