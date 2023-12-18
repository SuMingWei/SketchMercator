from statistics import median
import sys
import data
# import bulkreset_data 
import cpp_bulkreset_data as bulkreset_data

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

for template in template_list:
    count += 1
    if count == 1:
        sys.stdout.write("\\multirow{4}{*}{\\Dreadi}  & \\Dreadico")
    if count == 2:
        sys.stdout.write("& \\Dreadid")
    if count == 3:
        sys.stdout.write("& \\Dreadict")
    if count == 4:
        sys.stdout.write("& \\textbf{Total}")
    if count == 5:
        sys.stdout.write("\\multirow{4}{*}{\\Dreseti} & \\Dresetico")
    if count == 6:
        sys.stdout.write("& \\Dresetid")
    if count == 7:
        sys.stdout.write("& \\Dresetict")
    if count == 8:
        sys.stdout.write("& \\textbf{Total}")
    if count == 9:
        sys.stdout.write("\\multicolumn{2}{|c|}{\\textbf{\\Dreadi $+$ \\Dreseti}}")



    for array_size in [4096, 16384, 65536]:

        if count == 4:
            med = read_total(array_size)
        elif count == 8:
            med = reset_total(array_size)
        elif count == 9:
            med = total_total(array_size)
        else:
            attr_name = template % (array_size)
            value1 = getattr(data, attr_name)
            med = median(value1)
        sys.stdout.write("& %.2f (%.2f\\%%)" % (med, med*100 / total_total(array_size)))
        # if count == 4 or count == 8 or count == 9:
        #     sys.stdout.write("& \\textbf{%.2f} " % (med))
        # else:
        #     sys.stdout.write("& %.2f " % (med))

    if count == 1:
        sys.stdout.write("\\\\ \\cline{2-2} ")
    if count == 2:
        sys.stdout.write("\\\\ \\cline{2-2} ")
    if count == 3:
        sys.stdout.write("\\\\ \\cline{2-5} ")
    if count == 4:
        sys.stdout.write("\\\\ \\hline")
    if count == 5:
        sys.stdout.write("\\\\ \\cline{2-2} ")
    if count == 6:
        sys.stdout.write("\\\\ \\cline{2-2} ")
    if count == 7:
        sys.stdout.write("\\\\ \\cline{2-5} ")
    if count == 8:
        sys.stdout.write("\\\\ \\hline")
    if count == 9:
        sys.stdout.write("\\\\ \\hline")

    print()

print()

sys.stdout.write("D1. Delay before read (\\Dreadioco) ")
for array_size in [4096, 16384, 65536]:
    sys.stdout.write("& %.2f " % D1(array_size))
print("\\\\ \\cline{1-1}")

sys.stdout.write("D2. Delay during read (\\Dreadiod) ")
for array_size in [4096, 16384, 65536]:
    sys.stdout.write("& %.2f " % D2(array_size))
print("\\\\ \\cline{1-1}")

sys.stdout.write("D3. Delay before reset(\\Dreadi + \\Dresetico) ")
for array_size in [4096, 16384, 65536]:
    sys.stdout.write("& %.2f " % D3(array_size))
print("\\\\ \\cline{1-1}")

sys.stdout.write("D4. Delay during reset (\\Dresetid) ")
for array_size in [4096, 16384, 65536]:
    sys.stdout.write("& %.2f " % D4(array_size))
print("\\\\ \\hline")

sys.stdout.write("Total Sum ")
for array_size in [4096, 16384, 65536]:
    total = D1(array_size) + D2(array_size) + D3(array_size) + D4(array_size)
    sys.stdout.write("& %.2f " % total)
print("\\\\ \\hline")

print()
print()

for count in range(0, 4):
    if count == 0:
        sys.stdout.write("\\textbf{baseline(D1+D2+D3+D4)} ")
    if count == 1:
        sys.stdout.write("Sol 1 (no delays)")
    if count == 2:
        sys.stdout.write("Sol 2 (D1+D2)")
    if count == 3:
        sys.stdout.write("Sol 3 (D1+D2+D3'+D4')")
    for array_size in [4096, 16384, 65536]:
    # for array_size in [4096, 8192, 16384, 32768, 65536]:
        total = (D1(array_size)+D2(array_size)+D3(array_size)+D4(array_size))
        sol2 = (D1(array_size)+D2(array_size))
        sol3 = (D1(array_size)+D2(array_size)+D3P(array_size)+D4P(array_size))
        # sol3 = callback(array_size) + get_med_bulk("resetC1_%d", array_size)
        if count == 0:
            sys.stdout.write("& \\textbf{%.2f} " % total)
        elif count == 1:
            sys.stdout.write("& 0 (100\\%) ")
        elif count == 2:
            sys.stdout.write("& %.2f (%.2f\\%%)" % (sol2, 100-sol2/total*100))
            # sys.stdout.write("& %.2f (%d\\%) " % (sol2, sol2/total*100))
        else:
            sys.stdout.write("& %.2f (%.2f\\%%)" % (sol3, 100-sol3/total*100))

    sys.stdout.write("\\\\ \\hline")
    print()
