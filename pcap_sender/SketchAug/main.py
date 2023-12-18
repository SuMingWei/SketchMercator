from pcap_sender.SketchAug.lib.com import turn_on_switch_cpp
from pcap_sender.SketchAug.lib.com import turn_on_switch_python
from pcap_sender.SketchAug.lib.com import turn_off_switch_python
from pcap_sender.SketchAug.lib.com import turn_off_switch_cpp
from pcap_sender.SketchAug.lib.com import send_msg_cpp_without_pcap, send_msg_cpp_with_pcap, send_msg_python
from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, convert_to_ether_path
from python_lib.hun_timer import hun_timer

import importlib
import datetime
from pcap_sender.SketchAug.configs.load import load_param_list
from data_helper.data_path_helper.tofino_dp_path_helper import get_date_list

from time import sleep
API="cpp"
count = 0

def test(sketch_name, mode, epoch, array_size):
    global count
    ret_list = get_pcap_list_by_date_and_count(20160121, "60s", 100)
    date = datetime.datetime.now().strftime("%y%m%d_%H%M%S")
    send_msg_python(mode, "clear", epoch, array_size, "temp", API, date)
    hun_timer("clear", 5)

    pcount = 0
    for (full_path, folder_path, file_name) in ret_list:
        # if (("univ" in file_name) or ("ccdc" in file_name)) == False:
        #     continue
        if (("univ" in file_name) or ("ccdc" in file_name)):
            continue

        pcount += 1
        if pcount > 10:
            continue
        date_list = get_date_list(sketch_name, mode, API, array_size, epoch, file_name)
        if len(date_list) != 0:
            print(date_list)
            continue
        # for i in range(0, 1):
        date = datetime.datetime.now().strftime("%y%m%d_%H%M%S")
        e_full_path, e_folder_path, e_file_name = convert_to_ether_path(full_path)
        count += 1
        print("count(%d) sketch_name(%s) mode(%s) epoch(%d) array_size(%d) pcap(%s)" % (count, sketch_name, mode, epoch, array_size, e_file_name))
        send_msg_cpp_with_pcap(mode, "read", epoch, array_size, e_full_path, date)
        # send_msg_cpp_without_pcap(mode, "read", epoch, array_size, e_full_path, date)
        sleep(70)

        send_msg_python(mode, "clear", epoch, array_size, e_full_path, API, date)
        hun_timer("clear", 5)
    # exit(1)

def check(sketch_name, mode, epoch, array_size):
    date = datetime.datetime.now().strftime("%y%m%d_%H%M%S")
    send_msg_cpp_without_pcap(mode, "read_test", epoch, array_size, "small.pcap", date)

# sketch_list = ["mrb", "hll", "cs", "cm", "univmon"]
# sketch_list = ["univmon"]
# sketch_list = ["univmon"]
sketch_list = ["cm"]


# mode_list = ["baseline", "noreset", "sol3cpp", "pingpong"]
# mode_list = ["pingpong"]
mode_list = ["baseline"]

def main():
    lcount = 0
    for sketch_name in sketch_list:
        for mode in mode_list:
            epoch_list, array_size_dict = load_param_list(sketch_name, mode)
            if len(epoch_list) == 0:
                continue
            
            for epoch in epoch_list:
                for array_size in array_size_dict[epoch]:
                    print(sketch_name, mode, epoch, array_size)

                    turn_on_switch_cpp(sketch_name, mode, array_size)
                    hun_timer("turn_on_switch", 15)

                    turn_on_switch_python(sketch_name, mode, array_size)
                    hun_timer("turn_on_python", 5)

                    lcount += 1
                    print("count(%d) sketch_name(%s) mode(%s) epoch(%d) array_size(%d)" % (lcount, sketch_name, mode, epoch, array_size))
                    test(sketch_name, mode, epoch, array_size)

                    turn_off_switch_python(sketch_name, mode)
                    hun_timer("turn_off_python", 3)

                    turn_off_switch_cpp(sketch_name, mode)
                    hun_timer("turn_off_switch", 5)
                    # exit(1)




    # for sketch_name in sketch_list:
    #     for mode in mode_list:
    #         epoch_list, array_size_list = load_param_list(sketch_name, mode)
    #         for epoch in epoch_list:
    #             for array_size in array_size_list:
    #                 print("sketch_name(%s) mode(%s) epoch(%d) array_size(%d)" % (sketch_name, mode, epoch, array_size))
    #                 check(sketch_name, mode, epoch, array_size)

if __name__=="__main__":
   main()
