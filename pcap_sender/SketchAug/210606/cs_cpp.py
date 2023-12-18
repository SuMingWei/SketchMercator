from lib import tofino2_execute_cpp, tofino2_execute_python

from time import sleep
import sys

# msg = sys.argv[1]
# execute(msg)

# msg_list = []
epoch = 1
size = 4096

for epoch in [1, 5, 10, 20, 30]:
    for size in [1024, 2048, 4096, 8192, 16384]:
        # if epoch != 1:
        #     continue
        # if size != 1024:
        #     continue
        msg = "%d_%d" % (epoch, size)
        # tofino2_execute_cpp(msg, False)

        # print(msg)
        # tofino2_execute_cpp(msg, True)
        # sleep(65)

        clear_msg = "clear_%d_%d" % (epoch, size)
        tofino2_execute_python(clear_msg, False)
        sleep(3)
        exit(1)

    #     break
    # break
