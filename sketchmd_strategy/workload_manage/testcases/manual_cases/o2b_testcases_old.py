
def o3_case1():
    set_sketch_instances = []

    i1 = SketchInstance()
    i1.testcase_init(UnivMon, Key7, FLOW_SIZE_TYPE_BYTE, 10, 5, 1024, 16)

    i2 = SketchInstance()
    i2.testcase_init(MRAC, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 1024, 8)

    i3 = SketchInstance()
    i3.testcase_init(MRAC, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 2048, 8)

    i4 = SketchInstance()
    i4.testcase_init(MRAC, Key7, FLOW_SIZE_TYPE_PACKET, 30, 1, 2048, 16)

    i5 = SketchInstance()
    i5.testcase_init(MRAC, Key7, FLOW_SIZE_TYPE_PACKET, 40, 1, 1024, 16)

    set_sketch_instances += [i1, i2, i3, i4, i5]
    
    return sort_and_setid(set_sketch_instances)


def o3_case2():
    set_sketch_instances = []

    i1 = SketchInstance()
    i1.testcase_init(UnivMon, Key7, FLOW_SIZE_TYPE_BYTE, 10, 1, 1024, 16)

    i2 = SketchInstance()
    i2.testcase_init(MRAC, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 1024, 8)

    i3 = SketchInstance()
    i3.testcase_init(MRAC, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 2048, 8)

    i4 = SketchInstance()
    i4.testcase_init(MRAC, Key7, FLOW_SIZE_TYPE_PACKET, 30, 1, 2048, 16)

    i5 = SketchInstance()
    i5.testcase_init(MRAC, Key7, FLOW_SIZE_TYPE_PACKET, 40, 1, 1024, 16)

    set_sketch_instances += [i1, i2, i3, i4, i5]
    
    return sort_and_setid(set_sketch_instances)


def o3_case3():

    set_sketch_instances = []

    i1 = SketchInstance()
    i1.testcase_init(BloomFilter, Key7, FLOW_SIZE_TYPE_PACKET, 10, 5, 131072/32, 1)

    i2 = SketchInstance()
    i2.testcase_init(LinearCounting, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 131072*4/32, 1)

    i3 = SketchInstance()
    i3.testcase_init(LinearCounting, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 131072*2/32, 1)

    i4 = SketchInstance()
    i4.testcase_init(LinearCounting, Key7, FLOW_SIZE_TYPE_PACKET, 30, 1, 131072/32, 1)

    i5 = SketchInstance()
    i5.testcase_init(LinearCounting, Key7, FLOW_SIZE_TYPE_PACKET, 40, 1, 131072*4/32, 1)

    set_sketch_instances += [i1, i2, i3, i4, i5]
    
    return sort_and_setid(set_sketch_instances)



def o3_case4():
    set_sketch_instances = []

    i1 = SketchInstance()
    i1.testcase_init(BloomFilter, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 131072/32, 1)

    i2 = SketchInstance()
    i2.testcase_init(LinearCounting, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 131072*4/32, 1)

    i3 = SketchInstance()
    i3.testcase_init(LinearCounting, Key7, FLOW_SIZE_TYPE_PACKET, 30, 1, 131072*4/32, 1)

    i4 = SketchInstance()
    i4.testcase_init(LinearCounting, Key7, FLOW_SIZE_TYPE_PACKET, 40, 1, 131072*2/32, 1)


    set_sketch_instances += [i1, i2, i3, i4]
    
    return sort_and_setid(set_sketch_instances)


def o3_case5():
    set_sketch_instances = []

    i1 = SketchInstance()
    i1.testcase_init(HLL, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/4, 1)

    i2 = SketchInstance()
    i2.testcase_init(HLL, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 16384*2/4, 1)

    i3 = SketchInstance()
    i3.testcase_init(HLL, Key7, FLOW_SIZE_TYPE_PACKET, 30, 1, 16384*4/4, 1)

    i4 = SketchInstance()
    i4.testcase_init(HLL, Key7, FLOW_SIZE_TYPE_PACKET, 40, 1, 16384/4, 1)


    set_sketch_instances += [i1, i2, i3, i4]
    
    return sort_and_setid(set_sketch_instances)


def o3_case6():
    set_sketch_instances = []

    i1 = SketchInstance()
    i1.testcase_init(CountMin, Key7, FLOW_SIZE_TYPE_BYTE, 10, 1, 4096*4, 1)

    i2 = SketchInstance()
    i2.testcase_init(Kary, Key7, FLOW_SIZE_TYPE_BYTE, 10, 3, 4096*2, 1)

    i3 = SketchInstance()
    i3.testcase_init(Entropy, Key7, FLOW_SIZE_TYPE_BYTE, 10, 5, 4096, 1)


    i4 = SketchInstance()
    i4.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096, 1)

    i5 = SketchInstance()
    i5.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 4096*4, 1)

    i6 = SketchInstance()
    i6.testcase_init(Entropy, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 4096*2, 1)

    i7 = SketchInstance()
    i7.testcase_init(Entropy, Key7, FLOW_SIZE_TYPE_BYTE, 20, 2, 4096, 1)

    set_sketch_instances += [i1, i2, i3, i4, i5, i6, i7]



    i8 = SketchInstance()
    i8.testcase_init(CountSketch, Key7, FLOW_SIZE_TYPE_BYTE, 30, 3, 4096*4, 1)

    # i9 = SketchInstance()
    # i9.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 30, 1, 4096, 1)

    i10 = SketchInstance()
    i10.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 40, 1, 4096*4, 1)

    # i11 = SketchInstance()
    # i11.testcase_init(Entropy, Key7, FLOW_SIZE_TYPE_PACKET, 40, 1, 4096*2, 1)

    i12 = SketchInstance()
    i12.testcase_init(Entropy, Key7, FLOW_SIZE_TYPE_BYTE, 40, 2, 4096, 1)


    # set_sketch_instances += [i1, i2, i3, i4, i5, i6, i7, i8, i10, i12]
    # set_sketch_instances += [i8, i5, i10, i6]
    




    # i8 = SketchInstance()
    # i8.testcase_init(CountSketch, Key7, FLOW_SIZE_TYPE_BYTE, 30, 2, 4096*4, 1)

    # i12 = SketchInstance()
    # i12.testcase_init(Entropy, Key7, FLOW_SIZE_TYPE_BYTE, 40, 1, 4096, 1)

    # set_sketch_instances += [i8, i12]

    return sort_and_setid(set_sketch_instances)


def o3_case7():
    set_sketch_instances = []

    i1 = SketchInstance()
    i1.testcase_init(Entropy, Key7, FLOW_SIZE_TYPE_BYTE, 10, 5, 4096, 1)

    i2 = SketchInstance()
    i2.testcase_init(CountMin, Key7, FLOW_SIZE_TYPE_BYTE, 20, 2, 4096*4, 1)

    i3 = SketchInstance()
    i3.testcase_init(Kary, Key7, FLOW_SIZE_TYPE_BYTE, 20, 2, 4096*2, 1)

    i4 = SketchInstance()
    i4.testcase_init(Entropy, Key7, FLOW_SIZE_TYPE_BYTE, 20, 2, 4096, 1)

    i5 = SketchInstance()
    i5.testcase_init(CountSketch, Key7, FLOW_SIZE_TYPE_BYTE, 30, 1, 4096*4, 1)

    i6 = SketchInstance()
    i6.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 40, 1, 4096*4, 1)


    i7 = SketchInstance()
    i7.testcase_init(PCSA, Key6, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096, 1)

    i8 = SketchInstance()
    i8.testcase_init(CountMin, Key6, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096*4, 1)

    i9 = SketchInstance()
    i9.testcase_init(Kary, Key6, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096*2, 1)

    i10 = SketchInstance()
    i10.testcase_init(Entropy, Key6, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096*2, 1)

    set_sketch_instances += [i1, i2, i3, i4, i5, i6, i7, i8, i9, i10]

    return sort_and_setid(set_sketch_instances)
