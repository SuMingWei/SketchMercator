from sketch_formats.sketch_instance import *
from sketch_formats.sketch import *
from workload_manage.spec import *

def o1a_case1():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(HLL, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key7, FLOW_SIZE_TYPE_PACKET, 30, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key7, FLOW_SIZE_TYPE_PACKET, 40, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 4096, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 30, 1, 4096, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 40, 1, 4096, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRB, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/32, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRB, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 16384/32, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRB, Key7, FLOW_SIZE_TYPE_PACKET, 30, 1, 16384/32, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRB, Key7, FLOW_SIZE_TYPE_PACKET, 40, 1, 16384/32, 16)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)


def o1a_case2():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(HLL, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key7, FLOW_SIZE_TYPE_PACKET, 30, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 4096, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 30, 1, 4096, 1)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)


def o1a_case3():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(HLL, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 4096, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRB, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/32, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRB, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 16384/32, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRB, Key7, FLOW_SIZE_TYPE_PACKET, 30, 1, 16384/32, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 2048, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key7, FLOW_SIZE_TYPE_PACKET, 20, 1, 1024, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key7, FLOW_SIZE_TYPE_PACKET, 30, 1, 2048, 16)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)


def o1a_case4():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(HLL, Key1, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key2, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096, 1)
    set_sketch_instances += [inst]


    inst = SketchInstance()
    inst.testcase_init(MRB, Key3, FLOW_SIZE_TYPE_PACKET, 30, 1, 16384/32, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key4, FLOW_SIZE_TYPE_PACKET, 10, 1, 2048, 8)
    set_sketch_instances += [inst]


    inst = SketchInstance()
    inst.testcase_init(UnivMon, Key5, FLOW_SIZE_TYPE_BYTE, 10, 5, 1024, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(BloomFilter, Key6, FLOW_SIZE_TYPE_PACKET, 20, 1, 131072/32, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(LinearCounting, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 131072*4/32, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key8, FLOW_SIZE_TYPE_BYTE, 10, 1, 4096*4, 1)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)
