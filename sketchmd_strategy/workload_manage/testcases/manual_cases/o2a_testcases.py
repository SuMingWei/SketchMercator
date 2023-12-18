from sketch_formats.sketch_instance import *
from sketch_formats.sketch import *
from workload_manage.spec import *

def o2a_case1():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(BloomFilter, Key1, FLOW_SIZE_TYPE_PACKET, 10, 5, 131072/32, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(LinearCounting, Key1, FLOW_SIZE_TYPE_PACKET, 10, 1, 131072*4/32, 1)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)


def o2a_case2():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(Entropy, Key7, FLOW_SIZE_TYPE_BYTE, 10, 3, 4096*2, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key7, FLOW_SIZE_TYPE_BYTE, 10, 5, 4096, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(Kary, Key7, FLOW_SIZE_TYPE_BYTE, 10, 1, 4096*4, 1)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)
