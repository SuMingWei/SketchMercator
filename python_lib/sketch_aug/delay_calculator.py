from python_lib.sketch_aug import data
from python_lib.sketch_aug import data2
from statistics import median
from sklearn.linear_model import LinearRegression

def get_data(attr_template, counter_size):
    result = []
    for array_size in [4096, 8192, 12288, 16384, 20480, 32768, 36864, 65536]:
        attr_name = attr_template % (array_size, counter_size)
        values = getattr(data, attr_name)
        result.append((array_size, median(values)))

    return result

def learn_line_fitter(attr_template, counter_size):
    line_fitter = LinearRegression()
    values = get_data(attr_template, counter_size)
    x = []
    y = []
    for k, v in values:
        # print(k, v)
        x.append([k])
        y.append([v])
    line_fitter.fit(x, y)
    return line_fitter


def get_line_fitter(op, counter_size):
    if op == 'read':
        attr_template = "cpp_delta_1_bulk_%d_%d"
    if op == 'write':
        attr_template = "cpp_delta_3_trans_%d_%d"
    line_fitter = learn_line_fitter(attr_template, counter_size)
    return line_fitter

# total_delay
def total_delay(array_size, counter_size):
    if counter_size == 1:
        line_fitter_read = get_line_fitter('read', 1)
        line_fitter_write = get_line_fitter('write', 1)
    elif counter_size == 64:
        line_fitter_read = get_line_fitter('read', 64)
        line_fitter_write = get_line_fitter('write', 64)
    else:
        line_fitter_read = get_line_fitter('read', 32)
        line_fitter_write = get_line_fitter('write', 32)
    delta1 = line_fitter_read.predict([[array_size]])
    delta3 = line_fitter_write.predict([[array_size]])
    return delta1[0][0] + delta3[0][0]

def read_total_delay(array_size, counter_size):
    if counter_size == 1:
        line_fitter_read = get_line_fitter('read', 1)
    elif counter_size == 64:
        line_fitter_read = get_line_fitter('read', 64)
    else:
        line_fitter_read = get_line_fitter('read', 32)
    delta1 = line_fitter_read.predict([[array_size]])
    return delta1[0][0]

def reset_total_delay(array_size, counter_size):
    if counter_size == 1:
        line_fitter_write = get_line_fitter('write', 1)
    elif counter_size == 64:
        line_fitter_write = get_line_fitter('write', 64)
    else:
        line_fitter_write = get_line_fitter('write', 32)
    delta3 = line_fitter_write.predict([[array_size]])
    return delta3[0][0]

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
