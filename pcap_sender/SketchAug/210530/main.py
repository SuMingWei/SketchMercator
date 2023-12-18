import os
import argparse

# name_sketch_lib = "SketchLib"
# name_cp_reporting = "CP_Reporting"

from sketch_names import sketch_name_list
from sketch_names import name_hll, name_cs, name_univmon

# set up options
argparser = argparse.ArgumentParser(description="pcap send script")

# common arguments
argparser.add_argument('--sketch', type=str, required=True, help='[common] choose among ' + str(sketch_name_list))

# # name_sketch_lib arguments
# # name_cp_reporting arguments
# argparser.add_argument('--date', type=str, default='20140320', help='[%s] choose dates among "20140320, 20140619, 20160121, 20180517, 20180816"' % (name_sketch_lib))
# argparser.add_argument('--use_predified_sampling', type=str, default='0', help='[%s] use predifined sampled set, choose among 1, 2, 3' % (name_sketch_lib))
# argparser.add_argument('--pcap_input_path', type=str, required=True, help='[%s] location of pcap files' % (name_cp_reporting))
# argparser.add_argument('--skip_if_exist', type=int, default=0, help='[common] skip sending packet if exists')
# argparser.add_argument('--mode', type=str, default='%s' % name_sketch_lib, help='choose among "%s" or "%s"' % (name_sketch_lib, name_cp_reporting))

args = argparser.parse_args()

if args.sketch not in sketch_name_list:
    print("Error! --sketch must be one of", sketch_name_list)
    exit(1)

from data_path_helper.pcap_path_helper import get_extension_pcap_list_by_date_and_count

pcap_path_list = get_extension_pcap_list_by_date_and_count(20140320, "1s", "4x", 1)
for i, (full_path, folder_path, file_name) in enumerate(pcap_path_list):
    print(i+1, file_name)

from sketch_sender.sketch import Sketch
from sketch_sender.hll import HLL
# from sketch_sender.univmon import UnivMon
# from sketch_sender.countsketch import CountSketch

if args.sketch == name_hll:
    sketch = HLL(name_hll)

# if args.sketch == name_cs:
#     sketch = CountSketch(name_cs)

# if args.sketch == name_univmon:
#     sketch = UnivMon(name_univmon)


def run_tcpreplay(full_path):
    # cmd = "sudo tcpreplay -t -i eth4 %s" % full_path
    cmd = "sudo tcpreplay -i eth4 %s" % full_path
    print(cmd)
    # os.system(cmd)

def send_pcaps(pcap_path_list):
    global sketch

    sketch.start_flowkey_monitor()
    for i, (full_path, folder_path, file_name) in enumerate(pcap_path_list):
        sketch.timer_signal()
        run_tcpreplay(full_path)


for hash_set_i in range(1, 6):
    sketch.set_hash_set(hash_set_i)

    sketch.turn_on_switch()
    sketch.configure()

    send_pcaps(pcap_path_list)

    sketch.turn_off_switch()
    break















