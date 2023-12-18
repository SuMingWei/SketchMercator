from sketch_formats.sketch_instance import *
from sketch_formats.sketch import *
from workload_manage.spec import *

# UnivMon - MRAC case
def o2b_case1():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(UnivMon, Key1, FLOW_SIZE_TYPE_BYTE, 10, 5, 1024, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key1, FLOW_SIZE_TYPE_PACKET, 10, 1, 1024, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key1, FLOW_SIZE_TYPE_PACKET, 20, 1, 2048, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key1, FLOW_SIZE_TYPE_PACKET, 30, 1, 2048, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key1, FLOW_SIZE_TYPE_PACKET, 40, 1, 1024, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(UnivMon, Key2, FLOW_SIZE_TYPE_BYTE, 10, 1, 1024, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key2, FLOW_SIZE_TYPE_PACKET, 10, 1, 1024, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key2, FLOW_SIZE_TYPE_PACKET, 20, 1, 2048, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key2, FLOW_SIZE_TYPE_PACKET, 30, 1, 2048, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key2, FLOW_SIZE_TYPE_PACKET, 40, 1, 1024, 16)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)


# BF - LC case
def o2b_case2():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(BloomFilter, Key1, FLOW_SIZE_TYPE_PACKET, 10, 5, 131072/32, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(LinearCounting, Key1, FLOW_SIZE_TYPE_PACKET, 10, 1, 131072*4/32, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(LinearCounting, Key1, FLOW_SIZE_TYPE_PACKET, 20, 1, 131072*2/32, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(LinearCounting, Key1, FLOW_SIZE_TYPE_PACKET, 30, 1, 131072/32, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(LinearCounting, Key1, FLOW_SIZE_TYPE_PACKET, 40, 1, 131072*4/32, 1)
    set_sketch_instances += [inst]
    
    inst = SketchInstance()
    inst.testcase_init(BloomFilter, Key2, FLOW_SIZE_TYPE_PACKET, 20, 1, 131072/32, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(LinearCounting, Key2, FLOW_SIZE_TYPE_PACKET, 10, 1, 131072*4/32, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(LinearCounting, Key2, FLOW_SIZE_TYPE_PACKET, 30, 1, 131072*4/32, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(LinearCounting, Key2, FLOW_SIZE_TYPE_PACKET, 40, 1, 131072*2/32, 1)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)


# MRB case
def o2b_case3():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(MRB, Key3, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/32, 8)
    set_sketch_instances += [inst]
    
    inst = SketchInstance()
    inst.testcase_init(MRB, Key3, FLOW_SIZE_TYPE_PACKET, 20, 1, 16384/32, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRB, Key3, FLOW_SIZE_TYPE_PACKET, 30, 1, 16384/32, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRB, Key3, FLOW_SIZE_TYPE_PACKET, 40, 1, 16384/32, 16)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)


# HLL case
def o2b_case4():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(HLL, Key4, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key4, FLOW_SIZE_TYPE_PACKET, 20, 1, 16384*2/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key4, FLOW_SIZE_TYPE_PACKET, 30, 1, 16384*4/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key4, FLOW_SIZE_TYPE_PACKET, 40, 1, 16384/4, 1)
    set_sketch_instances += [inst]
    
    return sort_and_setid(set_sketch_instances)


# CM/Kary/Ent | CS | PCSA case
def o2b_case5():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    #### CM/Kary/Ent - ENT/PCSA

    # O2A
    inst = SketchInstance()
    inst.testcase_init(CountMin, Key5, FLOW_SIZE_TYPE_BYTE, 10, 1, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(Kary, Key5, FLOW_SIZE_TYPE_BYTE, 10, 3, 4096*2, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(Entropy, Key5, FLOW_SIZE_TYPE_BYTE, 10, 5, 4096, 1)
    set_sketch_instances += [inst]    
    # O2A done

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key5, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key5, FLOW_SIZE_TYPE_PACKET, 20, 1, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(Entropy, Key5, FLOW_SIZE_TYPE_BYTE, 20, 2, 4096, 1)
    set_sketch_instances += [inst]

    ####


    #### CS - ENT/PCSA 

    inst = SketchInstance()
    inst.testcase_init(CountSketch, Key6, FLOW_SIZE_TYPE_PACKET, 30, 5, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key6, FLOW_SIZE_TYPE_PACKET, 40, 1, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(Entropy, Key6, FLOW_SIZE_TYPE_BYTE, 40, 2, 4096, 1)
    set_sketch_instances += [inst]

    ####


    #### CS - ENT/PCSA 
    inst = SketchInstance()
    inst.testcase_init(CountSketch, Key7, FLOW_SIZE_TYPE_BYTE, 30, 5, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 40, 1, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(Entropy, Key7, FLOW_SIZE_TYPE_BYTE, 40, 2, 4096, 1)
    set_sketch_instances += [inst]
    ####

    return sort_and_setid(set_sketch_instances)


def o2b_case6():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    #### ENT - CM/Kary/Ent, CS, PCSA case

    inst = SketchInstance()
    inst.testcase_init(Entropy, Key1, FLOW_SIZE_TYPE_BYTE, 10, 5, 4096, 1)
    set_sketch_instances += [inst]

    ### O2A
    inst = SketchInstance()
    inst.testcase_init(CountMin, Key1, FLOW_SIZE_TYPE_BYTE, 20, 2, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(Kary, Key1, FLOW_SIZE_TYPE_BYTE, 20, 2, 4096*2, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(Entropy, Key1, FLOW_SIZE_TYPE_BYTE, 20, 2, 4096, 1)
    set_sketch_instances += [inst]
    ###


    inst = SketchInstance()
    inst.testcase_init(CountSketch, Key1, FLOW_SIZE_TYPE_BYTE, 30, 1, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountSketch, Key1, FLOW_SIZE_TYPE_PACKET, 30, 1, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key1, FLOW_SIZE_TYPE_PACKET, 40, 1, 4096*4, 1)
    set_sketch_instances += [inst]

    ####


    inst = SketchInstance()
    inst.testcase_init(PCSA, Key6, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key6, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(Kary, Key6, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096*2, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(Entropy, Key6, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096*2, 1)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)
