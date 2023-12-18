import os
import sys
import argparse
import signal
import traceback

sys.path.append(os.getenv('sketch_home'))
# set up options
argparser = argparse.ArgumentParser(description="Tofino control plane main")
argparser.add_argument('--workload_name', type=str, required=True)
argparser.add_argument('--program_name', type=str, required=True)
argparser.add_argument('--pcap_name', type=str)
argparser.add_argument('--date', type=str)
argparser.add_argument('--caida_date', type=str)

argparser.add_argument('--setup', action='store_true')
argparser.add_argument('--digest', action='store_true')
argparser.add_argument('--epoch', action='store_true')

argparser.add_argument('--simulator', action='store_true')
argparser.add_argument('--tcp', action='store_true')

args = argparser.parse_args()

from tofino_control_plane.python.querysketch.module.common.connection import Connection
from tofino_control_plane.python.querysketch.module.sketches.w1 import W1
from tofino_control_plane.python.querysketch.module.sketches.w2 import W2
from tofino_control_plane.python.querysketch.module.sketches.w3 import W3
from tofino_control_plane.python.querysketch.module.sketches.w4 import W4

try:
    if args.workload_name == "workload_1":
        connection = W1(args)
    elif args.workload_name == "workload_2":
        connection = W2(args)
    elif args.workload_name == "workload_3":
        connection = W3(args)
    elif args.workload_name == "workload_4":
        connection = W4(args)
    else:
        traceback.print_exc()
        exit(1)


    if args.setup:
        connection.ports()
        connection.table_init(args)
        connection.configure(args)
    
    if args.epoch:
        connection.table_init(args)
        connection.epoch(args)

    connection.teardown()

except Exception as e:
    traceback.print_exc()

