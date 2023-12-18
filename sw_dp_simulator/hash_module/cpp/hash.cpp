#include "hash.h"

HashSeedSet::HashSeedSet(uint32_t _size) {

    size = _size;

    for (uint32_t i = 0; i <= size; i++) {
        aParams.push_back(rand() % primeNumber);
        bParams.push_back(rand() % primeNumber);
        polyParams.push_back(rand());
        initParams.push_back(0x00000000);
        xoutParams.push_back(0xFFFFFFFF);
    }
}

void HashSeedSet::printParams() {
    printf("%15s %15s | %15s %15s %15s\n", "[aParams]", "[bParams]", "[polynomials]", "[init]", "[xout]");
    for (uint32_t i = 0; i <= size; i++) {
        printf("%15u %15u | %15u %15u %15u\n", aParams[i], bParams[i], polyParams[i], initParams[i], xoutParams[i]);
    }
    printf("\n");
}

void HashSeedSet::filePrintParams(FILE* fp, int i) {
    fprintf(fp, "%u %u %u %u %u\n", aParams[i], bParams[i], polyParams[i], initParams[i], xoutParams[i]);
}

uint32_t HashSeedSet::universal_hash(flowkey_t flowkey, uint32_t a, uint32_t b, int range) {
    uint64_t xored_flowkey =
            flowkey.src_addr ^
            flowkey.src_port ^
            flowkey.dst_addr ^
            flowkey.dst_port ^
            flowkey.proto;
    return ((a * xored_flowkey + b) % primeNumber ) % range;
}

uint32_t HashSeedSet::crc_hash(flowkey_t flowkey, flowkey_flags_t flowkey_flags, uint32_t poly, uint32_t init, uint32_t xout)
{
    char buf[100];
    int len = 0;
    if(flowkey_flags.srcIP == 1) {
        uint32_t temp = ntohl(flowkey.src_addr);
        uint8_t* u = (uint8_t*)(&temp);
        buf[len] = u[0];
        buf[len+1] = u[1];
        buf[len+2] = u[2];
        buf[len+3] = u[3];
        len += 4;
    }

    if(flowkey_flags.srcPort == 1) {
        uint16_t temp = ntohs(flowkey.src_port);
        uint8_t* u = (uint8_t*)(&temp);
        buf[len] = u[0];
        buf[len+1] = u[1];
        len += 2;
    }

    if(flowkey_flags.dstIP == 1) {
        uint32_t temp = ntohl(flowkey.dst_addr);
        uint8_t* u = (uint8_t*)(&temp);
        buf[len] = u[0];
        buf[len+1] = u[1];
        buf[len+2] = u[2];
        buf[len+3] = u[3];
        len += 4;
    }

    if(flowkey_flags.dstPort == 1) {
        uint16_t temp = ntohs(flowkey.dst_port);
        uint8_t* u = (uint8_t*)(&temp);
        buf[len] = u[0];
        buf[len+1] = u[1];
        len += 2;
    }

    if(flowkey_flags.proto == 1) {
        buf[len] = flowkey.proto;
        len += 1;
    }
    uint32_t crc = crc_general(buf, len, poly, init, xout);
    return crc;
}

uint32_t HashSeedSet::compute_hash(flowkey_t flowkey, flowkey_flags_t flowkey_flags, int index, int is_crc, int range) {
    if (is_crc == 1) {
        uint32_t crc = crc_hash(flowkey, flowkey_flags, polyParams[index], initParams[index], xoutParams[index]) % range;
        return crc;
    }
    else {
        return universal_hash(flowkey, aParams[index], bParams[index], range);
    }
}

uint32_t HashSeedSet::compute_hash_xor_type_two(flowkey_t flowkey, flowkey_flags_t flowkey_flags_1, flowkey_flags_t flowkey_flags_2, int index, int range) {
    uint32_t crc1 = crc_hash(flowkey, flowkey_flags_1, polyParams[index], initParams[index], xoutParams[index]) % range;
    uint32_t crc2 = crc_hash(flowkey, flowkey_flags_2, polyParams[2+index], initParams[2+index], xoutParams[2+index]) % range;
    return crc1 ^ crc2;
}

uint32_t HashSeedSet::compute_hash_xor_type_three(flowkey_t flowkey, flowkey_flags_t flowkey_flags_1, flowkey_flags_t flowkey_flags_2, flowkey_flags_t flowkey_flags_3, int index, int range) {
    uint32_t crc1 = crc_hash(flowkey, flowkey_flags_1, polyParams[index], initParams[index], xoutParams[index]) % range;
    uint32_t crc2 = crc_hash(flowkey, flowkey_flags_2, polyParams[2+index], initParams[2+index], xoutParams[2+index]) % range;
    uint32_t crc3 = crc_hash(flowkey, flowkey_flags_3, polyParams[4+index], initParams[4+index], xoutParams[4+index]) % range;
    return crc1 ^ crc2 ^ crc3;
}

uint32_t HashSeedSet::compute_hash_xor_type_four(flowkey_t flowkey, flowkey_flags_t flowkey_flags_1, flowkey_flags_t flowkey_flags_2, flowkey_flags_t flowkey_flags_3, flowkey_flags_t flowkey_flags_4, int index, int range) {
    uint32_t crc1 = crc_hash(flowkey, flowkey_flags_1, polyParams[index], initParams[index], xoutParams[index]) % range;
    uint32_t crc2 = crc_hash(flowkey, flowkey_flags_2, polyParams[2+index], initParams[2+index], xoutParams[2+index]) % range;
    uint32_t crc3 = crc_hash(flowkey, flowkey_flags_3, polyParams[4+index], initParams[4+index], xoutParams[4+index]) % range;
    uint32_t crc4 = crc_hash(flowkey, flowkey_flags_4, polyParams[6+index], initParams[6+index], xoutParams[6+index]) % range;
    return crc1 ^ crc2 ^ crc3 ^ crc4;
}

uint32_t HashSeedSet::compute_hash_xor_type(flowkey_t flowkey, flowkey_flags_t flowkey_flags, int index, int is_crc, int range, int xor_hash_type) {
    // cout << "row " << index << " xor hash type " << xor_hash_type << endl;
    flowkey_flags_t flowkey_flags_1;
    flowkey_flags_t flowkey_flags_2;
    flowkey_flags_t flowkey_flags_3;
    flowkey_flags_t flowkey_flags_4;
    int A, B;
    if(1 <= xor_hash_type && xor_hash_type <= 11) {

        if(xor_hash_type == 1) {
            return crc_hash(flowkey, flowkey_flags, polyParams[index], initParams[index], xoutParams[index]) % range;
        }
        if(xor_hash_type == 2) {
            flowkey_flags_1.srcIP =   1;
            flowkey_flags_1.srcPort = 0;
            flowkey_flags_1.dstIP =   0;
            flowkey_flags_1.dstPort = 0;
            flowkey_flags_1.proto =   0;

            flowkey_flags_2.srcIP =   0;
            flowkey_flags_2.srcPort = 1;
            flowkey_flags_2.dstIP =   1;
            flowkey_flags_2.dstPort = 1;
            flowkey_flags_2.proto =   0;
            return compute_hash_xor_type_two(flowkey, flowkey_flags_1, flowkey_flags_2, index, range);
        }

        if(xor_hash_type == 3) {
            flowkey_flags_1.srcIP =   1;
            flowkey_flags_1.srcPort = 1;
            flowkey_flags_1.dstIP =   0;
            flowkey_flags_1.dstPort = 0;
            flowkey_flags_1.proto =   0;

            flowkey_flags_2.srcIP =   0;
            flowkey_flags_2.srcPort = 0;
            flowkey_flags_2.dstIP =   1;
            flowkey_flags_2.dstPort = 1;
            flowkey_flags_2.proto =   0;
            return compute_hash_xor_type_two(flowkey, flowkey_flags_1, flowkey_flags_2, index, range);
        }

        if(xor_hash_type == 4) {
            flowkey_flags_1.srcIP =   1;
            flowkey_flags_1.srcPort = 1;
            flowkey_flags_1.dstIP =   1;
            flowkey_flags_1.dstPort = 0;
            flowkey_flags_1.proto =   0;

            flowkey_flags_2.srcIP =   0;
            flowkey_flags_2.srcPort = 0;
            flowkey_flags_2.dstIP =   0;
            flowkey_flags_2.dstPort = 1;
            flowkey_flags_2.proto =   0;
            return compute_hash_xor_type_two(flowkey, flowkey_flags_1, flowkey_flags_2, index, range);
        }

        if(xor_hash_type == 5) {
            flowkey_flags_1.srcIP =   1;
            flowkey_flags_1.srcPort = 0;
            flowkey_flags_1.dstIP =   0;
            flowkey_flags_1.dstPort = 0;
            flowkey_flags_1.proto =   0;

            flowkey_flags_2.srcIP =   0;
            flowkey_flags_2.srcPort = 1;
            flowkey_flags_2.dstIP =   0;
            flowkey_flags_2.dstPort = 0;
            flowkey_flags_2.proto =   0;

            flowkey_flags_3.srcIP =   0;
            flowkey_flags_3.srcPort = 0;
            flowkey_flags_3.dstIP =   1;
            flowkey_flags_3.dstPort = 1;
            flowkey_flags_3.proto =   0;
            return compute_hash_xor_type_three(flowkey, flowkey_flags_1, flowkey_flags_2, flowkey_flags_3, index, range);
        }

        if(xor_hash_type == 6) {
            flowkey_flags_1.srcIP =   1;
            flowkey_flags_1.srcPort = 0;
            flowkey_flags_1.dstIP =   0;
            flowkey_flags_1.dstPort = 0;
            flowkey_flags_1.proto =   0;

            flowkey_flags_2.srcIP =   0;
            flowkey_flags_2.srcPort = 1;
            flowkey_flags_2.dstIP =   1;
            flowkey_flags_2.dstPort = 0;
            flowkey_flags_2.proto =   0;

            flowkey_flags_3.srcIP =   0;
            flowkey_flags_3.srcPort = 0;
            flowkey_flags_3.dstIP =   0;
            flowkey_flags_3.dstPort = 1;
            flowkey_flags_3.proto =   0;
            return compute_hash_xor_type_three(flowkey, flowkey_flags_1, flowkey_flags_2, flowkey_flags_3, index, range);
        }

        if(xor_hash_type == 7) {
            flowkey_flags_1.srcIP =   1;
            flowkey_flags_1.srcPort = 0;
            flowkey_flags_1.dstIP =   0;
            flowkey_flags_1.dstPort = 0;
            flowkey_flags_1.proto =   0;

            flowkey_flags_2.srcIP =   0;
            flowkey_flags_2.srcPort = 1;
            flowkey_flags_2.dstIP =   0;
            flowkey_flags_2.dstPort = 0;
            flowkey_flags_2.proto =   0;

            flowkey_flags_3.srcIP =   0;
            flowkey_flags_3.srcPort = 0;
            flowkey_flags_3.dstIP =   1;
            flowkey_flags_3.dstPort = 0;
            flowkey_flags_3.proto =   0;

            flowkey_flags_4.srcIP =   0;
            flowkey_flags_4.srcPort = 0;
            flowkey_flags_4.dstIP =   0;
            flowkey_flags_4.dstPort = 1;
            flowkey_flags_4.proto =   0;
            return compute_hash_xor_type_four(flowkey, flowkey_flags_1, flowkey_flags_2, flowkey_flags_3, flowkey_flags_4, index, range);
        }

        if(xor_hash_type == 8) {
            flowkey_flags_1.srcIP =   1;
            flowkey_flags_1.srcPort = 1;
            flowkey_flags_1.dstIP =   0;
            flowkey_flags_1.dstPort = 0;
            flowkey_flags_1.proto =   0;

            flowkey_flags_2.srcIP =   0;
            flowkey_flags_2.srcPort = 1;
            flowkey_flags_2.dstIP =   1;
            flowkey_flags_2.dstPort = 1;
            flowkey_flags_2.proto =   0;
            return compute_hash_xor_type_two(flowkey, flowkey_flags_1, flowkey_flags_2, index, range);
        }

        if(xor_hash_type == 9) {
            flowkey_flags_1.srcIP =   1;
            flowkey_flags_1.srcPort = 1;
            flowkey_flags_1.dstIP =   1;
            flowkey_flags_1.dstPort = 0;
            flowkey_flags_1.proto =   0;

            flowkey_flags_2.srcIP =   0;
            flowkey_flags_2.srcPort = 0;
            flowkey_flags_2.dstIP =   1;
            flowkey_flags_2.dstPort = 1;
            flowkey_flags_2.proto =   0;
            return compute_hash_xor_type_two(flowkey, flowkey_flags_1, flowkey_flags_2, index, range);
        }

        if(xor_hash_type == 10) {
            flowkey_flags_1.srcIP =   1;
            flowkey_flags_1.srcPort = 1;
            flowkey_flags_1.dstIP =   0;
            flowkey_flags_1.dstPort = 0;
            flowkey_flags_1.proto =   0;

            flowkey_flags_2.srcIP =   0;
            flowkey_flags_2.srcPort = 1;
            flowkey_flags_2.dstIP =   1;
            flowkey_flags_2.dstPort = 0;
            flowkey_flags_2.proto =   0;

            flowkey_flags_3.srcIP =   0;
            flowkey_flags_3.srcPort = 0;
            flowkey_flags_3.dstIP =   0;
            flowkey_flags_3.dstPort = 1;
            flowkey_flags_3.proto =   0;
            return compute_hash_xor_type_three(flowkey, flowkey_flags_1, flowkey_flags_2, flowkey_flags_3, index, range);
        }

        if(xor_hash_type == 11) {
            flowkey_flags_1.srcIP =   1;
            flowkey_flags_1.srcPort = 1;
            flowkey_flags_1.dstIP =   0;
            flowkey_flags_1.dstPort = 0;
            flowkey_flags_1.proto =   0;

            flowkey_flags_2.srcIP =   1;
            flowkey_flags_2.srcPort = 0;
            flowkey_flags_2.dstIP =   1;
            flowkey_flags_2.dstPort = 0;
            flowkey_flags_2.proto =   0;

            flowkey_flags_3.srcIP =   0;
            flowkey_flags_3.srcPort = 1;
            flowkey_flags_3.dstIP =   0;
            flowkey_flags_3.dstPort = 1;
            flowkey_flags_3.proto =   0;
            return compute_hash_xor_type_three(flowkey, flowkey_flags_1, flowkey_flags_2, flowkey_flags_3, index, range);
        }
    }
    else if(12 <= xor_hash_type && xor_hash_type <= 17) {
        if (xor_hash_type == 12) {
            flowkey_flags_1.srcIP =   1;
            flowkey_flags_1.srcPort = 1;
            flowkey_flags_1.dstIP =   0;
            flowkey_flags_1.dstPort = 0;
            flowkey_flags_1.proto =   0;

            flowkey_flags_2.srcIP =   0;
            flowkey_flags_2.srcPort = 0;
            flowkey_flags_2.dstIP =   1;
            flowkey_flags_2.dstPort = 1;
            flowkey_flags_2.proto =   0;
            if(index == 0) {
                A = 0;
                B = 1;
            }
            else {
                A = 2;
                B = 3;
            }    
            uint32_t crc1 = crc_hash(flowkey, flowkey_flags_1, polyParams[A], initParams[A], xoutParams[A]) % range;
            uint32_t crc2 = crc_hash(flowkey, flowkey_flags_2, polyParams[B], initParams[B], xoutParams[B]) % range;
            return crc1 ^ crc2;
        }
        if (xor_hash_type == 13) {
            flowkey_flags_1.srcIP =   1;
            flowkey_flags_1.srcPort = 1;
            flowkey_flags_1.dstIP =   0;
            flowkey_flags_1.dstPort = 0;
            flowkey_flags_1.proto =   0;

            flowkey_flags_2.srcIP =   0;
            flowkey_flags_2.srcPort = 0;
            flowkey_flags_2.dstIP =   1;
            flowkey_flags_2.dstPort = 1;
            flowkey_flags_2.proto =   0;
            if(index == 0) {
                A = 0;
                B = 1;
            }
            else {
                A = 0;
                B = 1;
            }    
            uint32_t crc1 = crc_hash(flowkey, flowkey_flags_1, polyParams[A], initParams[A], xoutParams[A]) % range;
            uint32_t crc2 = crc_hash(flowkey, flowkey_flags_2, polyParams[B], initParams[B], xoutParams[B]) % range;
            return crc1 ^ crc2;
        }
        if (xor_hash_type == 14) {
            flowkey_flags_1.srcIP =   1;
            flowkey_flags_1.srcPort = 1;
            flowkey_flags_1.dstIP =   0;
            flowkey_flags_1.dstPort = 0;
            flowkey_flags_1.proto =   0;

            flowkey_flags_2.srcIP =   0;
            flowkey_flags_2.srcPort = 0;
            flowkey_flags_2.dstIP =   1;
            flowkey_flags_2.dstPort = 1;
            flowkey_flags_2.proto =   0;
            if(index == 0) {
                A = 0;
                B = 1;
            }
            else {
                A = 0;
                B = 3;
            }
            uint32_t crc1 = crc_hash(flowkey, flowkey_flags_1, polyParams[A], initParams[A], xoutParams[A]) % range;
            uint32_t crc2 = crc_hash(flowkey, flowkey_flags_2, polyParams[B], initParams[B], xoutParams[B]) % range;
            return crc1 ^ crc2;
        }
        if (xor_hash_type == 15) {
            flowkey_flags_1.srcIP =   1;
            flowkey_flags_1.srcPort = 1;
            flowkey_flags_1.dstIP =   1;
            flowkey_flags_1.dstPort = 0;
            flowkey_flags_1.proto =   0;

            flowkey_flags_2.srcIP =   0;
            flowkey_flags_2.srcPort = 0;
            flowkey_flags_2.dstIP =   0;
            flowkey_flags_2.dstPort = 1;
            flowkey_flags_2.proto =   0;
            if(index == 0) {
                A = 0;
                B = 1;
            }
            else {
                A = 0;
                B = 3;
            }
            uint32_t crc1 = crc_hash(flowkey, flowkey_flags_1, polyParams[A], initParams[A], xoutParams[A]) % range;
            uint32_t crc2 = crc_hash(flowkey, flowkey_flags_2, polyParams[B], initParams[B], xoutParams[B]) % range;
            return crc1 ^ crc2;
        }
        if (xor_hash_type == 16) {
            if(index == 0) {
                flowkey_flags_1.srcIP =   1;
                flowkey_flags_1.srcPort = 1;
                flowkey_flags_1.dstIP =   1;
                flowkey_flags_1.dstPort = 0;
                flowkey_flags_1.proto =   0;

                flowkey_flags_2.srcIP =   0;
                flowkey_flags_2.srcPort = 0;
                flowkey_flags_2.dstIP =   0;
                flowkey_flags_2.dstPort = 1;
                flowkey_flags_2.proto =   0;
                A = 0;
                B = 1;
            }
            else {
                flowkey_flags_1.srcIP =   1;
                flowkey_flags_1.srcPort = 1;
                flowkey_flags_1.dstIP =   1;
                flowkey_flags_1.dstPort = 0;
                flowkey_flags_1.proto =   0;

                flowkey_flags_2.srcIP =   0;
                flowkey_flags_2.srcPort = 0;
                flowkey_flags_2.dstIP =   1;
                flowkey_flags_2.dstPort = 1;
                flowkey_flags_2.proto =   0;
                A = 0;
                B = 3;
            }
            uint32_t crc1 = crc_hash(flowkey, flowkey_flags_1, polyParams[A], initParams[A], xoutParams[A]) % range;
            uint32_t crc2 = crc_hash(flowkey, flowkey_flags_2, polyParams[B], initParams[B], xoutParams[B]) % range;
            return crc1 ^ crc2;
        }
        if (xor_hash_type == 17) {
            if(index == 0) {
                flowkey_flags_1.srcIP =   1;
                flowkey_flags_1.srcPort = 1;
                flowkey_flags_1.dstIP =   1;
                flowkey_flags_1.dstPort = 0;
                flowkey_flags_1.proto =   0;

                flowkey_flags_2.srcIP =   0;
                flowkey_flags_2.srcPort = 1;
                flowkey_flags_2.dstIP =   0;
                flowkey_flags_2.dstPort = 1;
                flowkey_flags_2.proto =   0;
                A = 0;
                B = 1;
            }
            else {
                flowkey_flags_1.srcIP =   1;
                flowkey_flags_1.srcPort = 1;
                flowkey_flags_1.dstIP =   1;
                flowkey_flags_1.dstPort = 0;
                flowkey_flags_1.proto =   0;

                flowkey_flags_2.srcIP =   0;
                flowkey_flags_2.srcPort = 0;
                flowkey_flags_2.dstIP =   1;
                flowkey_flags_2.dstPort = 1;
                flowkey_flags_2.proto =   0;
                A = 0;
                B = 3;
            }
            uint32_t crc1 = crc_hash(flowkey, flowkey_flags_1, polyParams[A], initParams[A], xoutParams[A]) % range;
            uint32_t crc2 = crc_hash(flowkey, flowkey_flags_2, polyParams[B], initParams[B], xoutParams[B]) % range;
            return crc1 ^ crc2;
        }
    }
    else {
        cout << "ERROR, exit" << endl;
        exit(1);
    }
}
