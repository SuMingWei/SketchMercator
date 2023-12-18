import os
import sys
import argparse
import signal
import traceback
# mrb = 'mrb'
# mrb_opt = 'mrb_opt'
# mrb_pingpong = 'mrb_pingpong'
cs = 'cs'
cm = 'cm'
hll = 'hll'
mrb = 'mrb'
univmon = 'univmon'
sketch_name_list = [cs, cm, hll, mrb, univmon]

# set up options
argparser = argparse.ArgumentParser(description="Tofino control plane main")
argparser.add_argument('--sketch_name', type=str, required=True, help='choose among ' + str(sketch_name_list))
argparser.add_argument('--mode', type=str, help='mode')
argparser.add_argument('--array_size', type=int, help='array_size')

argparser.add_argument('--str_args_1', type=str, help='str arg 1')
argparser.add_argument('--int_args_1', type=int, help='int arg 1')

argparser.add_argument('--tcp', action='store_true')
argparser.add_argument('--simulator', action='store_true')
argparser.add_argument('--ports', action='store_true')
argparser.add_argument('--configure', action='store_true')
argparser.add_argument('--read', action='store_true')

args = argparser.parse_args()

from tofino_control_plane.python.SketchAug.module.common.connection import Connection, tcp_start
from tofino_control_plane.python.SketchAug.module.sketches.SketchAug.cm.cm import CM
from tofino_control_plane.python.SketchAug.module.sketches.SketchAug.cs.cs import CS
from tofino_control_plane.python.SketchAug.module.sketches.SketchAug.mrb.mrb import MRB
from tofino_control_plane.python.SketchAug.module.sketches.SketchAug.hll.hll import HLL
from tofino_control_plane.python.SketchAug.module.sketches.SketchAug.univmon.univmon import UnivMon

try:
    if args.sketch_name == cs:
        connection = CS(args)

    if args.sketch_name == cm:
        connection = CM(args)

    if args.sketch_name == hll:
        connection = HLL(args)

    if args.sketch_name == mrb:
        connection = MRB(args)

    if args.sketch_name == univmon:
        connection = UnivMon(args)

    if args.tcp:
        tcp_start(connection, args)

    connection.teardown()

except Exception as e:
    traceback.print_exc()

