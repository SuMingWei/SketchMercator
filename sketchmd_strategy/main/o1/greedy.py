from sketch_formats.sketch_instance import *
from lib.inst_list import *
from opt.hash_reuse import *
from opt.hash_xor import *
from opt.salu_reuse import *
from opt.salu_merge import *

from main.o1.greedy_o1 import *
from lib.logging import *

def o1_greedy_main(inst_list, timeout_O1, o2_result):
    print_msg("[o1_greedy_main start]", 4, "cyan")

    # print_inst_list_msg(inst_list, 2)
    o1a_list = convert_o2_result_to_o1a_list(o2_result)
    print_answer_list_msg(o1a_list, 8)

    o1inst_list = greedy_O1(o1a_list, timeout_O1)
    return o1inst_list
