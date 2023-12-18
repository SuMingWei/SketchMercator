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


from workload_manage.testcases.manual_cases.o1a_testcases import *
from workload_manage.testcases.manual_cases.o1b_testcases import *
from workload_manage.testcases.manual_cases.o2a_testcases import *
from workload_manage.testcases.manual_cases.o2b_testcases import *
from workload_manage.testcases.manual_cases.o3_testcases import *
from workload_manage.testcases.manual_cases.workload_testcase import *

workload_dict = {}
if args.filename == "o1a_testcase.pkl":
    workload_dict["o1a_case1"] = [o1a_case1()]
    workload_dict["o1a_case2"] = [o1a_case2()]
    workload_dict["o1a_case3"] = [o1a_case3()]
    workload_dict["o1a_case4"] = [o1a_case4()]

if args.filename == "o1b_testcase.pkl":
    workload_dict["o1b_case1"] = [o1b_case1()]
    workload_dict["o1b_case2"] = [o1b_case2()]
    workload_dict["o1b_case3"] = [o1b_case3()]

if args.filename == "o2a_testcase.pkl":
    workload_dict["o2a_case1"] = [o2a_case1()]
    workload_dict["o2a_case2"] = [o2a_case2()]

if args.filename == "o2b_testcase.pkl":
    workload_dict["o2b_case1"] = [o2b_case1()]
    workload_dict["o2b_case2"] = [o2b_case2()]
    workload_dict["o2b_case3"] = [o2b_case3()]
    workload_dict["o2b_case4"] = [o2b_case4()]
    workload_dict["o2b_case5"] = [o2b_case5()]
    workload_dict["o2b_case6"] = [o2b_case6()]

if args.filename == "o3_testcase.pkl":
    workload_dict["o3_case1"] = [o3_case1()]
    workload_dict["o3_case2"] = [o3_case2()]


if args.filename == "workload_testcase.pkl":
    workload_dict["w1"] = [workload1_case()]
    workload_dict["w2"] = [workload2_case()]
    workload_dict["w3"] = [workload3_case()]
    workload_dict["w4"] = [workload4_case()]


saver.save(workload_dict)
