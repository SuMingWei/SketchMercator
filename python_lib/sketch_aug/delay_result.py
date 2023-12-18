from python_lib.sketch_aug import data
from python_lib.sketch_aug import data2
from statistics import median

def get_data(attr_template, counter_size):
    result = []
    for array_size in [4096, 8192, 12288, 16384, 20480, 32768, 36864, 65536]:
        attr_name = attr_template % (array_size, counter_size)
        values = getattr(data, attr_name)
        result.append((array_size, median(values)))

    return result

def read_total_delay(array_size, counter_size):
    attr_name = "cpp_delta_1_bulk_%d_%d" % (array_size, counter_size)
    value1 = getattr(data, attr_name)
    # print(value1)
    # print(median(value1))
    return median(value1)


def reset_total_delay(array_size, counter_size):
    attr_name = "reset_total_timer_%d" % (array_size)
    value1 = getattr(data2, attr_name)

    attr_name = "reset_start_point_timer_%d" % (array_size)
    value2 = getattr(data2, attr_name)
    val = []
    for a, b in zip(value1, value2):
        val.append(a+b)

    # print(value1)
    # print(median(value1))
    return median(val)

def read_before_delay(array_size):
    attr_name = "dma_start_point_read_%d" % (array_size)
    value1 = getattr(data2, attr_name)

    attr_name = "dma_read_start_%d" % (array_size)
    value2 = getattr(data2, attr_name)

    v = []
    for a,b in zip(value1, value2):
        v.append(b - a)
    # print(v)
    # print(median(v)/100)
    return median(v)/100

def read_during_delay(array_size):
    attr_name = "dma_read_start_%d" % (array_size)
    value1 = getattr(data2, attr_name)

    attr_name = "dma_read_end_%d" % (array_size)
    value2 = getattr(data2, attr_name)

    v = []
    for a,b in zip(value1, value2):
        v.append(b - a)
    # # val = sum(v)/10
    val = median(v)
    # print(v)
    # print(val/100)
    return val/100


def reset_before_delay(array_size):
    delta1 = read_total_delay(array_size, 32)

    delta1 = round(delta1, 2)

    attr_name = "reset_start_point_read_%d" % (array_size)
    value1 = getattr(data2, attr_name)

    attr_name = "reset_read_start_%d" % (array_size)
    value2 = getattr(data2, attr_name)

    v = []
    for a,b in zip(value1, value2):
        v.append((200000 - b) - a)
    # print(v)
    # print(delta1)
    # print(median(v)/100)
    # print(delta1 + median(v)/100)
    return delta1 + median(v)/100


def reset_c1(array_size):
    attr_name = "reset_start_point_read_%d" % (array_size)
    value1 = getattr(data2, attr_name)

    attr_name = "reset_read_start_%d" % (array_size)
    value2 = getattr(data2, attr_name)

    v = []
    for a,b in zip(value1, value2):
        v.append((200000 - b) - a)
    return median(v)/100


def reset_during_delay(array_size):
    attr_name = "reset_read_start_%d" % (array_size)
    value1 = getattr(data2, attr_name)

    attr_name = "reset_read_end_%d" % (array_size)
    value2 = getattr(data2, attr_name)

    v = []
    for a,b in zip(value1, value2):
        v.append(a - b)
    # print(v)
    # val = sum(v)/10
    val = median(v)
    # print(val/100)
    return val/100
