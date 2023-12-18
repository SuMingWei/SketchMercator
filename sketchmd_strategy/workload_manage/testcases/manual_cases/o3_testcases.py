from sketch_formats.sketch_instance import *
from sketch_formats.sketch import *
from workload_manage.spec import *

def o3_case1():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key1, FLOW_SIZE_TYPE_BYTE, 10, 1, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key2, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key3, FLOW_SIZE_TYPE_PACKET, 20, 1, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(Entropy, Key4, FLOW_SIZE_TYPE_BYTE, 20, 2, 4096, 1)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)


def o3_case2():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key1, FLOW_SIZE_TYPE_BYTE, 10, 1, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key2, FLOW_SIZE_TYPE_BYTE, 10, 1, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key2, FLOW_SIZE_TYPE_PACKET, 10, 1, 4096, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(PCSA, Key3, FLOW_SIZE_TYPE_PACKET, 20, 1, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(Entropy, Key4, FLOW_SIZE_TYPE_BYTE, 20, 2, 4096, 1)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)
