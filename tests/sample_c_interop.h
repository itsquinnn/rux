#ifndef SAMPLE_C_INTEROP_H
#define SAMPLE_C_INTEROP_H

#define C_HEADER_VERSION 314
#define C_SCALE_MAC(v, s) ((v) * (s))

typedef uint64_t c_size_t;
typedef int32_t c_status_t;

typedef struct {
    uint32_t magic;
    uint64_t payload_len;
    int32_t status_code;
} CInteropPacket;

struct CPoint2D {
    int x;
    int y;
};

#endif
