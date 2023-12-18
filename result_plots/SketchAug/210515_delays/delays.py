from python_lib.sketch_aug.delay_result import read_before_delay
from python_lib.sketch_aug.delay_result import read_during_delay
from python_lib.sketch_aug.delay_result import read_total_delay

# from python_lib.sketch_aug.delay_calculator import reset_before_delay
from python_lib.sketch_aug.delay_result import reset_during_delay
from python_lib.sketch_aug.delay_result import reset_c1
from python_lib.sketch_aug.delay_result import reset_total_delay


read_delay = []
for size in [4096, 8192, 16384, 32768, 65536]:
    a = read_before_delay(size)
    b = read_during_delay(size)
    d = read_total_delay(size, 32)
    c = d - a - b
    print("%.2f %.2f %.2f %.2f" % (a, b, c, d))

    read_delay.append([a, b, c, d])

print()

write_delay = []
for size in [4096, 8192, 16384, 32768, 65536]:
    a = reset_c1(size)
    b = reset_during_delay(size)
    d = reset_total_delay(size, 32)
    c = d - a - b
    print("%.2f %.2f %.2f %.2f" % (a, b, c, d))

    write_delay.append([a, b, c, d])

print()

print("%.2f %.2f %.2f" %(read_delay[0][0], read_delay[2][0], read_delay[4][0]))

print("%.2f %.2f %.2f" %(read_delay[0][1], read_delay[2][1], read_delay[4][1]))

print("%.2f %.2f %.2f" %(read_delay[0][3] + write_delay[0][0], read_delay[2][3] + write_delay[2][0], read_delay[4][3] + write_delay[4][0]))

print("%.2f %.2f %.2f" %(write_delay[0][1], write_delay[2][1], write_delay[4][1]))
