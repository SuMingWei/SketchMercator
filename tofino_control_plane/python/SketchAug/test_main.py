import os
import sys
import argparse
import signal
import traceback

test_read_delay = 'read_delay'
test_hw_behave = 'hw_behave'
test_reset = 'reset'
test_name_list = [test_read_delay, test_hw_behave, test_reset]

# set up options
argparser = argparse.ArgumentParser(description="Tofino control plane main")
argparser.add_argument('--test_name', type=str, required=True, help='choose among ' + str(test_name_list))
argparser.add_argument('--str_args_1', type=str, help='str arg 1')
argparser.add_argument('--int_args_1', type=int, help='int arg 1')

argparser.add_argument('--simulator', action='store_true')
argparser.add_argument('--ports', action='store_true')
argparser.add_argument('--configure', action='store_true')
argparser.add_argument('--test', action='store_true')

args = argparser.parse_args()

# from tofino_control_plane.python.SketchAug.module.common.connection import Connection
from tofino_control_plane.python.SketchAug.module.test.read_delay.read_delay import ReadDelay
from tofino_control_plane.python.SketchAug.module.test.hw_behave.hw_behave import HwBehave
# from tofino_control_plane.python.SketchAug.module.test.reset.reset import RESET

try:
    if args.test_name == test_read_delay:
        connection = ReadDelay(args)
    elif args.test_name == test_hw_behave:
        connection = HwBehave(args)
    # elif args.test_name == test_reset:
    #     connection = RESET(args)
    
    if args.ports:
        connection.ports()

    if args.test:
        connection.test(args)

    connection.teardown()

except Exception as e:
    traceback.print_exc()

