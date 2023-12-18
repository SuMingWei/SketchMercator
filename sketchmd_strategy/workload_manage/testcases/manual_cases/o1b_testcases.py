from sketch_formats.sketch_instance import *
from sketch_formats.sketch import *
from workload_manage.spec import *

# Key1 = [SRCIP]
# Key5 = [DSTIP]
# Key6 = [SRCIP, DSTIP]
# Key1 + Key5 = Key6

# Key2 = [SRCIP, SRCPORT]
# Key4 = [DSTIP, DSTPORT]
# Key7 = [SRCIP, DSTIP, SRCPORT, DSTPORT]
# Key2 + Key4 = Key7

def o1b_case1():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(HLL, Key1, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key5, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key6, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)


def o1b_case2():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(HLL, Key2, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key2, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key4, FLOW_SIZE_TYPE_PACKET, 20, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/4, 1)
    set_sketch_instances += [inst]


    inst = SketchInstance()
    inst.testcase_init(MRB, Key2, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/32, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRB, Key2, FLOW_SIZE_TYPE_PACKET, 20, 1, 16384/32, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key4, FLOW_SIZE_TYPE_PACKET, 10, 1, 2048, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 2048, 8)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)


def o1b_case3():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(HLL, Key2, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key2, FLOW_SIZE_TYPE_PACKET, 20, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key2, FLOW_SIZE_TYPE_PACKET, 30, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key4, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096, 1)
    set_sketch_instances += [inst]


    inst = SketchInstance()
    inst.testcase_init(MRB, Key2, FLOW_SIZE_TYPE_PACKET, 10, 1, 16384/32, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRB, Key2, FLOW_SIZE_TYPE_PACKET, 20, 1, 16384/32, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRB, Key4, FLOW_SIZE_TYPE_PACKET, 30, 1, 16384/32, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key4, FLOW_SIZE_TYPE_PACKET, 10, 1, 2048, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key7, FLOW_SIZE_TYPE_PACKET, 10, 1, 2048, 8)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)
