import os
import sys
import argparse
import signal
import traceback

cm_O6 = "cm_O6"
fcm_O6 = "fcm_O6"
fcm_topk = "fcm_topk"

sketch_name_list = [cm_O6, fcm_O6, fcm_topk]

# set up options
argparser = argparse.ArgumentParser(description="Tofino control plane main")
argparser.add_argument('--sketch_name', type=str, required=True, help='choose among ' + str(sketch_name_list))
argparser.add_argument('--ports', action='store_true')
argparser.add_argument('--configure', action='store_true')
argparser.add_argument('--simulator', action='store_true')
argparser.add_argument('--tcp', action='store_true')

args = argparser.parse_args()

from tofino_control_plane.python.SketchAug.SketchLib.common.connection import Connection, tcp_start
from tofino_control_plane.python.SketchAug.SketchLib.sketches.cm import CM
from tofino_control_plane.python.SketchAug.SketchLib.sketches.fcm import FCM_TOPK
from tofino_control_plane.python.SketchAug.SketchLib.sketches.fcm import FCM_O6

try:
    if args.sketch_name == cm_O6:
        connection = CM(args)

    if args.sketch_name == fcm_O6:
        connection = FCM_O6(args)

    if args.sketch_name == fcm_topk:
        connection = FCM_TOPK(args)

    if args.ports:
        connection.ports()
    
    if args.configure:
        connection.configure()

    if args.tcp:
        tcp_start(connection)

    connection.teardown()

except Exception as e:
    traceback.print_exc()

