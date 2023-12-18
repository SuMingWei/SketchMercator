from python_lib.pkl_saver import PklSaver
from workload_manage.new_generator import *
from workload_manage.spec import *
from lib.inst_list import print_inst_list, sort_inst_list
# from lib.logging import print_msg

# import os
# import sys

from sketch_formats.sketch_instance import *
from sketch_formats.sketch import *
from workload_manage.spec import *
import argparse

argparser = argparse.ArgumentParser(description="data generator")
argparser.add_argument('--folder', type=str)
argparser.add_argument('--filename', type=str)
argparser.add_argument('--data_count', type=int)
args = argparser.parse_args()

saver = PklSaver(args.folder, args.filename)

def sort_and_setid(data):
    j = 0
    for inst in sort_inst_list(data):
        j += 1
        inst.setid(j)
    return data


from workload_manage.querysketch.manual_cases.set1 import *

workload_dict = {}
if args.filename == "set1.pkl":
    workload_dict["ensemble1"] = [ensemble1()]
    workload_dict["ensemble2"] = [ensemble2()]
    workload_dict["ensemble3"] = [ensemble3()]
    workload_dict["ensemble4"] = [ensemble4()]
    workload_dict["ensemble5"] = [ensemble5()]


saver.save(workload_dict)
