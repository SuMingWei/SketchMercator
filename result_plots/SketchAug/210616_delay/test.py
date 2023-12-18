from statistics import median
import sys
import data
import bulkreset_data

count = 0

template_list = [
"readC1_%d",
"readD_%d",
"readC2_%d",
"read_total_%d",
"resetC1_%d",
"resetD_%d",
"resetC2_%d",
"reset_total_%d",
"dummy",
]

def get_med(template, array_size):
    attr_name = template % (array_size)
    value1 = getattr(data, attr_name)
    return median(value1)

def get_med_bulk(template, array_size):
    attr_name = template % (array_size)
    value1 = getattr(bulkreset_data, attr_name)
    return median(value1)

def read_total(array_size):
    global template_list
    attr_name = template_list[0] % (array_size)
    value1 = getattr(data, attr_name)
    attr_name = template_list[1] % (array_size)
    value2 = getattr(data, attr_name)
    attr_name = template_list[2] % (array_size)
    value3 = getattr(data, attr_name)
    return median(value1) + median(value2) + median(value3)

def bulk_reset_total(array_size):
    global template_list
    attr_name = template_list[4] % (array_size)
    value1 = getattr(bulkreset_data, attr_name)
    attr_name = template_list[5] % (array_size)
    value2 = getattr(bulkreset_data, attr_name)
    attr_name = template_list[6] % (array_size)
    value3 = getattr(bulkreset_data, attr_name)
    return median(value1) + median(value2) + median(value3)

def reset_total(array_size):
    global template_list
    attr_name = template_list[4] % (array_size)
    value1 = getattr(data, attr_name)
    attr_name = template_list[5] % (array_size)
    value2 = getattr(data, attr_name)
    attr_name = template_list[6] % (array_size)
    value3 = getattr(data, attr_name)
    return median(value1) + median(value2) + median(value3)

def total_total(array_size):
    global template_list
    attr_name = template_list[0] % (array_size)
    value1 = getattr(data, attr_name)
    attr_name = template_list[1] % (array_size)
    value2 = getattr(data, attr_name)
    attr_name = template_list[2] % (array_size)
    value3 = getattr(data, attr_name)
    attr_name = template_list[4] % (array_size)
    value4 = getattr(data, attr_name)
    attr_name = template_list[5] % (array_size)
    value5 = getattr(data, attr_name)
    attr_name = template_list[6] % (array_size)
    value6 = getattr(data, attr_name)
    return median(value1) + median(value2) + median(value3) + median(value4) + median(value5) + median(value6)

def callback(array_size):
    return get_med("callback_timer_%d", array_size)

def D1(array_size):
    return get_med("readC1_%d", array_size)

def D2(array_size):
    return get_med("readD_%d", array_size)

def D3(array_size):
    return read_total(array_size) + get_med("resetC1_%d", array_size)

def D4(array_size):
    return get_med("resetD_%d", array_size)

def D3P(array_size):
    return callback(array_size) + get_med_bulk("resetC1_%d", array_size)

def D4P(array_size):
    return get_med_bulk("resetD_%d", array_size)

# for array_size in [4096, 8192, 16384, 32768, 65536]:
#     print(array_size)
#     cb = callback(array_size) - D1(array_size) - D2(array_size)
#     c2 = get_med("readC2_%d", array_size)
#     print(cb)
#     print(c2)
#     print(100 - cb / c2 * 100)
#     # print(read_total(array_size))
#     print()


for array_size in [4096, 8192, 16384, 32768, 65536]:
    print(array_size)
    # c1 = get_med_bulk("resetC1_%d", array_size)
    # c2 = get_med("resetC1_%d", array_size)
    c1 = bulk_reset_total(array_size)
    c2 = reset_total(array_size)
    print(c1)
    print(c2)
    print(100 - c1 / c2 * 100)
    # print(read_total(array_size))
    print()

