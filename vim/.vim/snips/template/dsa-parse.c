#include <stdint.h>
#include <string.h>
#include <assert.h>

typedef struct parser_s {
    const int32_t   max; // large than max-size of protocol packet
    const int32_t   min; // min-size of protocol packet
    uint8_t* const  buf; // buf size must large than max
    int32_t         len; // cached data in buf
    int32_t         idx; // index of first byte of protocol packet
    uint8_t         stt; // parse state
    void (*cb)(const uint8_t*, const int32_t); // callback for packet
} parser_t;

void parse(parser_t* const ps, const uint8_t* data, const int32_t data_len) {
    assert(data != NULL);
    assert(data_len > 0);
    const uint8_t* p = NULL;
    int32_t rest = data_len, size = 0;
    do {
        // copy data to ps.buf
        if (ps->len < ps->max) {
            size = ps->max - ps->len;
            if (rest < size) size = rest;
            memcpy(&(ps->buf[ps->len]), data + data_len - rest, size);
            ps->len += size;
            rest -= size;
        }
        // parse packet, ex: Head(2bytes), Len(1byte), data(Len bytes), Tail(2bytes)
        while ((int32_t)(ps->len - ps->idx) >= (int32_t)(ps->min)) {
            p = ps->buf + ps->idx;
            size = p[2] + 5;
            if (0 == ps->stt) {
                ps->stt = (p[0] == 0xff && p[1] == 0xee) ? 1 : 0;
            }
            if (1 == ps->stt) {
                if (ps->len - ps->idx < size) // buf is not enough for a packet
                    break;
                ps->stt = (size <= ps->max) ? 2 : 0;
            }
            if (2 == ps->stt) {
                if (p[size - 2] == 0xee && p[size - 1] == 0xff)
                    ps->cb(p, size);
                ps->idx += size;
                ps->stt = 0;
                continue; // parse next packet
            }
            if (ps->stt > 2) ps->stt = 0; // avoid wrong state
            ps->idx ++; // check byte one by one
        }
        // drop parsed buf
        if (ps->idx > 0) {
            if (ps->len > ps->idx) {
                memcpy(ps->buf, ps->buf + ps->idx, ps->len - ps->idx);
                ps->len -= ps->idx;
            } else
                ps->len = 0;
            ps->idx = 0;
        }
    } while (rest > 0);
}
