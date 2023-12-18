#include "crc.h"

uint32_t reverseBits(uint32_t num)
{
    uint32_t reverse_num, i, temp;
    reverse_num = 0;

    for (i = 0; i < 32; i++)
    {
        temp = (num & (1 << i));
        if(temp)
            reverse_num |= (1 << (31 - i));
    }

    return reverse_num;
}

void generate_reverse_table(uint32_t table[256], uint32_t poly)
{
    uint32_t reverse_poly = reverseBits(poly);
    for (uint32_t i = 0; i < 256; i++)
    {
        uint32_t c = i;
        for (size_t j = 0; j < 8; j++)
        {
            if (c & 1) {
                c = reverse_poly ^ (c >> 1);
            }
            else {
                c >>= 1;
            }
        }
        table[i] = c;
    }
}

void generate_table(uint32_t table[256], uint32_t poly)
{
    for (uint32_t i = 0; i < 256; i++)
    {
        uint32_t c = (i << 24);
        uint32_t mask = 1 << (31);
        for (size_t j = 0; j < 8; j++)
        {
            if (c & mask) {
                c = (c << 1) ^ poly;
            }
            else {
                c <<= 1;
            }
        }
        table[i] = c;
    }
}

uint32_t update(uint32_t table[256], void* buf, size_t len, uint32_t initial, uint32_t x_out)
{
    uint32_t c = initial ^ x_out;
    uint8_t* u = (uint8_t*)(buf);
    for (size_t i = 0; i < len; i++)
    {
        c = table[u[i] ^ ((c>>24) & 0xFF)] ^ ((c << 8) & 0xFFFFFF00);
    }
    return c ^ x_out;
}

uint32_t reverse_update(uint32_t table[256], void* buf, size_t len, uint32_t initial, uint32_t x_out)
{
    uint32_t c = initial ^ x_out;
    uint8_t* u = (uint8_t*)(buf);
    for (size_t i = 0; i < len; i++)
    {
        c = table[u[i] ^ (c & 0xFF)] ^ (c >> 8);
    }
    return c ^ x_out;
}

unordered_map <uint32_t, void*> crcTableMap;

uint32_t crc_general(void* buf, int len, uint32_t poly, uint32_t init, uint32_t x_out)
{
    uint32_t crc;

    if (crcTableMap.find(poly) == crcTableMap.end()) {
        crcTableMap[poly] = malloc(256 * sizeof(uint32_t));
        generate_reverse_table((uint32_t *)crcTableMap[poly], poly);
    }

    crc = reverse_update((uint32_t *)crcTableMap[poly], buf, len, init, x_out);
//    printf("reverse: key(0x%x) key(%u) poly(0x1%08x) init(0x%08x) xout(0x%08x) = %u(0x%08x)\n", key, key, poly, init, x_out, crc, crc);
//    printf("%d\n", crc&65535);
//    exit(1);
//    crcCache[key] = crc;
    return crc;
}
