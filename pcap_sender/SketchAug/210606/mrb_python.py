from lib import tofino2_execute_python

from time import sleep
import sys

# msg = sys.argv[1]
# execute(msg)

delays = {}
delays[4096] = 1.722243
delays[8192] = 3.53519
delays[16384] = 7.345157
delays[32768] = 14.843539
delays[65536] = 30.30019

msg_list = []
for epoch in [1, 5, 10, 20, 30]:
    for size in [4096, 8192, 16384, 32768, 65536]:

        start_msg = "start_%d_%d" % (epoch, size)        
        if epoch <= delays[size]:
            continue
        print(start_msg)

        tofino2_execute_python(start_msg, True)
        sleep(70)
        exit(1)

        # # else:
        # #     print(start_msg + " no")
        # execute_python(start_msg)
        # sleep(85)
        # # sleep(7)
