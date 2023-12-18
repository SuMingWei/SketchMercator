from sketch_formats.sketch_instance import *
from sketch_formats.sketch import *
from workload_manage.spec import *

def workload1_case():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key1, FLOW_SIZE_TYPE_PACKET, 40, 1, 8*1024, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key1, FLOW_SIZE_TYPE_BYTE, 10, 5, 16*1024, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key6, FLOW_SIZE_TYPE_BYTE, 30, 2, 16*1024, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key2, FLOW_SIZE_TYPE_BYTE, 30, 5, 8*1024, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key4, FLOW_SIZE_TYPE_BYTE, 20, 2, 4*1024, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key8, FLOW_SIZE_TYPE_PACKET, 40, 5, 8*1024, 1)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)





def workload2_case():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(BloomFilter, Key4, FLOW_SIZE_TYPE_PACKET, 30, 3, 128*1024 / 32, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRB, Key4, FLOW_SIZE_TYPE_PACKET, 20, 1, 16*1024/32, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRB, Key4, FLOW_SIZE_TYPE_PACKET, 30, 1, 16*1024/32, 16)
    set_sketch_instances += [inst]



    inst = SketchInstance()
    inst.testcase_init(Entropy, Key4, FLOW_SIZE_TYPE_PACKET, 10, 3, 16*1024, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountSketch, Key4, FLOW_SIZE_TYPE_PACKET, 10, 3, 16*1024, 1)
    set_sketch_instances += [inst]


    inst = SketchInstance()
    inst.testcase_init(Entropy, Key4, FLOW_SIZE_TYPE_PACKET, 30, 4, 4*1024, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key4, FLOW_SIZE_TYPE_BYTE, 30, 3, 4*1024, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(Kary, Key4, FLOW_SIZE_TYPE_BYTE, 30, 1, 4*1024, 1)
    set_sketch_instances += [inst]



    inst = SketchInstance()
    inst.testcase_init(MRAC, Key4, FLOW_SIZE_TYPE_PACKET, 20, 1, 2048, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key4, FLOW_SIZE_TYPE_PACKET, 40, 1, 2048, 8)
    set_sketch_instances += [inst]



    return sort_and_setid(set_sketch_instances)



def workload3_case():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []


    inst = SketchInstance()
    inst.testcase_init(UnivMon, Key6, FLOW_SIZE_TYPE_PACKET, 20, 3, 2048, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key6, FLOW_SIZE_TYPE_PACKET, 20, 1, 2048, 8)
    set_sketch_instances += [inst]


    inst = SketchInstance()
    inst.testcase_init(Entropy, Key4, FLOW_SIZE_TYPE_PACKET, 20, 2, 16*1024, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key4, FLOW_SIZE_TYPE_PACKET, 20, 1, 8*1024, 1)
    set_sketch_instances += [inst]




    inst = SketchInstance()
    inst.testcase_init(HLL, Key5, FLOW_SIZE_TYPE_PACKET, 20, 1, 4096/4, 1)
    set_sketch_instances += [inst]


    inst = SketchInstance()
    inst.testcase_init(HLL, Key1, FLOW_SIZE_TYPE_PACKET, 20, 1, 16384/4, 1)
    set_sketch_instances += [inst]


    inst = SketchInstance()
    inst.testcase_init(UnivMon, Key2, FLOW_SIZE_TYPE_PACKET, 20, 4, 2048, 16)
    set_sketch_instances += [inst]



    inst = SketchInstance()
    inst.testcase_init(BloomFilter, Key7, FLOW_SIZE_TYPE_PACKET, 20, 3, 128*1024/32, 1)
    set_sketch_instances += [inst]


    inst = SketchInstance()
    inst.testcase_init(LinearCounting, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 128*1024/32, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(Entropy, Key8, FLOW_SIZE_TYPE_PACKET, 20, 5, 4*1024, 1)
    set_sketch_instances += [inst]


    return sort_and_setid(set_sketch_instances)


def workload4_case():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(Entropy, Key7, FLOW_SIZE_TYPE_PACKET, 30, 5, 4*1024, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 40, 1, 16*1024, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountSketch, Key7, FLOW_SIZE_TYPE_PACKET, 30, 3, 8*1024, 1)
    set_sketch_instances += [inst]


    inst = SketchInstance()
    inst.testcase_init(MRAC, Key1, FLOW_SIZE_TYPE_PACKET, 20, 1, 2048, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRB, Key5, FLOW_SIZE_TYPE_PACKET, 30, 1, 16*1024/32, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRB, Key6, FLOW_SIZE_TYPE_PACKET, 20, 1, 32*1024/32, 8)
    set_sketch_instances += [inst]


    inst = SketchInstance()
    inst.testcase_init(Entropy, Key4, FLOW_SIZE_TYPE_PACKET, 30, 3, 8*1024, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key2, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key4, FLOW_SIZE_TYPE_PACKET, 20, 1, 16384, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key8, FLOW_SIZE_TYPE_PACKET, 30, 1, 8192/4, 1)
    set_sketch_instances += [inst]


    return sort_and_setid(set_sketch_instances)


