from sketch_formats.sketch_instance import *
from sketch_formats.sketch import *
from workload_manage.spec import *

def ensemble1():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(CountSketch, Key4, FLOW_SIZE_TYPE_PACKET, 30, 3, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key4, FLOW_SIZE_TYPE_PACKET, 30, 1, 8192, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key4, FLOW_SIZE_TYPE_PACKET, 30, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)


def ensemble2():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key4, FLOW_SIZE_TYPE_PACKET, 30, 2, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountSketch, Key4, FLOW_SIZE_TYPE_PACKET, 30, 2, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key4, FLOW_SIZE_TYPE_PACKET, 30, 1, 4096, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key4, FLOW_SIZE_TYPE_PACKET, 30, 1, 16384/4, 1)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)


def ensemble3():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key4, FLOW_SIZE_TYPE_PACKET, 30, 2, 8192, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountSketch, Key4, FLOW_SIZE_TYPE_PACKET, 30, 2, 16384, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key4, FLOW_SIZE_TYPE_PACKET, 30, 1, 2048, 8)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(HLL, Key4, FLOW_SIZE_TYPE_PACKET, 30, 1, 16384/4, 1)
    set_sketch_instances += [inst]


    return sort_and_setid(set_sketch_instances)


def ensemble4():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(UnivMon, Key4, FLOW_SIZE_TYPE_PACKET, 30, 2, 1024, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key4, FLOW_SIZE_TYPE_PACKET, 30, 2, 4096*4, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key4, FLOW_SIZE_TYPE_PACKET, 30, 1, 4096, 8)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)



def ensemble5():
    from workload_manage.testcases.workload_generator import sort_and_setid
    set_sketch_instances = []

    inst = SketchInstance()
    inst.testcase_init(UnivMon, Key4, FLOW_SIZE_TYPE_PACKET, 30, 2, 2048, 16)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(CountMin, Key4, FLOW_SIZE_TYPE_PACKET, 30, 2, 8192, 1)
    set_sketch_instances += [inst]

    inst = SketchInstance()
    inst.testcase_init(MRAC, Key4, FLOW_SIZE_TYPE_PACKET, 30, 1, 2048, 8)
    set_sketch_instances += [inst]

    return sort_and_setid(set_sketch_instances)
