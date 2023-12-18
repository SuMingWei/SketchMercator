from sketch_formats.sketch_instance import *
from lib.inst_list import *
from opt.hash_reuse import *
from opt.hash_xor import *
from opt.salu_reuse import *
from opt.salu_merge import *

from main.o2.greedy_o2 import *

from lib.logging import *

def o2_greedy_main(inst_list, timeout_O2):
    print_msg("[o2_greedy_main start]", 4, "cyan")

    print_inst_list_msg(inst_list, 8)
    print_msg(f"[before greedy O2A] {len(inst_list)}", 5, "cyan")

    o2a_inst_list = apply_salu_reuse(inst_list)

    print_msg(f"[after greedy O2A] {len(o2a_inst_list)}", 5, "cyan")
    print_answer_list_msg(o2a_inst_list, 8)

    o2inst_list = greedy_O2B(o2a_inst_list, timeout_O2)

    print_msg(f"[after greedy O2B] {len(o2inst_list)}", 5, "cyan")
    print_answer_list_msg(o2inst_list, 8)

    print_msg("[o2_greedy_main end]", 4, "cyan")
    return o2inst_list
