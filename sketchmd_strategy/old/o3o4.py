import pandas as pd

from sketch_formats.sketch_instance import *
from sketch_formats.sketch import *
from lib.obj_func import *

class O3O4MergedSketchInstance: # represents O2+O3+O4
    def __init__(self, o3inst1, o3inst2):
        if o3inst1.big_o2inst.get_max_r() != o3inst2.big_o2inst.get_max_r():
            print("o3o4inst error, different max_r!")
            exit(1)

        self.o3inst1 = o3inst1
        self.o3inst2 = o3inst2
        self.hashcall_instruction = "NULL"

    def get_all_inst_list(self):
        return self.o3inst1.get_all_inst_list() + self.o3inst2.get_all_inst_list()

    def get_resource_usage(self):
        max_r = self.o3inst1.big_o2inst.get_max_r()
        if self.o3inst1.flowkey == self.o3inst2.flowkey:
            hash_call = max_r*2
            O1_hashcall_reduction = max_r
            self.hashcall_instruction = f"same flowkey {str(self.o3inst1.flowkey)} x {max_r}"
        elif is_subset(self.o3inst1.flowkey, self.o3inst2.flowkey) or is_subset(self.o3inst2.flowkey, self.o3inst1.flowkey):
            hash_call = max_r*2+1
            O1_hashcall_reduction = max_r-1
            self.hashcall_instruction = f"subset flowkeys ({str(self.o3inst1.flowkey)}, {str(self.o3inst2.flowkey)}) x ({max_r}, 1)"
        else:
            hash_call = max_r*3
            O1_hashcall_reduction = 0
            self.hashcall_instruction = f"separate flowkeys {str(self.o3inst1.flowkey)} x {max_r}, {str(self.o3inst2.flowkey)} x {max_r}"

        # SRAM is still approximation but should be fine for now.
        # -> I don't think it is not approximation, but let's skip
        SALU = max_r
        SRAM_1, epoch_1 = self.o3inst1.getSRAM()
        SRAM_2, epoch_2 = self.o3inst2.getSRAM()
        SRAM = (SRAM_1 + SRAM_2) * 2
        epoch = epoch_1 + epoch_2
        return hash_call, SALU, SRAM, epoch, O1_hashcall_reduction

    def objective_function(self):
        # print("there is a O3/O4!! [objective_function]")
        hash_call, SALU, SRAM, epoch, O1_hashcall_reduction = self.get_resource_usage()

        ret = {}
        ret['overall'] = global_objective_function(hash_call, SALU, SRAM, epoch)
        ret['hashcall'] = global_objective_function(hash_call, 0, 0, 0)
        ret['salu'] = global_objective_function(0, SALU, 0, 0)
        ret['sram'] = global_objective_function(0, 0, SRAM, 0)

        return pd.Series(ret)

    def objective_function_breakdown(self):
        # print("there is a O3/O4!! [objective_function_breakdown]")
        before = compute_baseline(self.get_all_inst_list())

        hash_call, SALU, SRAM, epoch, O1_hashcall_reduction = self.get_resource_usage()

        df = self.o3inst1.objective_function_breakdown() + self.o3inst1.objective_function_breakdown()

        after = {}
        after['hashcall'] = global_objective_function(hash_call, 0, 0, 0)
        after['salu'] = global_objective_function(0, SALU, 0, 0)
        after['sram'] = global_objective_function(0, 0, SRAM, 0)

        # This is approximation, not sure if O3/O4 case even exists
        data = {}
        data['before'] = [before['hashcall'], before['salu'], before['sram']]
        data['after'] = [after['hashcall'], after['salu'], after['sram']]

        data['O1'] = [df["O1"]["hashcall"] + O1_hashcall_reduction, df["O1"]["salu"], df["O1"]["sram"]]
        data['O2'] = [df["O2"]["hashcall"], df["O2"]["salu"], df["O2"]["sram"]]
        data['O3'] = [df["O3"]["hashcall"], df["O3"]["salu"], df["O3"]["sram"]]
        data['O4'] = [before['hashcall'] - after['hashcall'] - (df["O1"]["hashcall"]+O1_hashcall_reduction+df["O2"]["hashcall"]+df["O3"]["hashcall"]), \
                        before['salu'] - after['salu'] - (df["O1"]["salu"]+df["O2"]["salu"]+df["O3"]["salu"]), \
                        before['sram'] - after['sram'] - (df["O1"]["sram"]+df["O2"]["sram"]+df["O3"]["sram"])]

        df = pd.DataFrame(data, index=["hashcall", "salu", "sram"])
        # print(df)
        return df

    def print(self):
        print("=*"*25 + "[O3/O4]" + "=*"*25)
        print("     [Hash Call Instruction Start]")
        print(self.hashcall_instruction)
        print("     [Hash Call Instruction Done]")

        self.o3inst1.print()
        self.o3inst2.print()
        print("=*"*50+"=")
        print()


def O3O4_merging_check(o2o3inst_list):
    if len(o2o3inst_list) != 2:
        return False

    inst1 = o2o3inst_list[0]
    inst2 = o2o3inst_list[1]

    if inst1.__class__.__name__ != inst2.__class__.__name__:
        return False

    if inst1.__class__.__name__ != "SALUMergeSketchInstance":
        return False

    if inst1.sampling_compatible() == False or inst2.sampling_compatible() == False:
        return False

    if inst1.big_o2inst.counter_update_type != inst2.big_o2inst.counter_update_type:
        return False

    if inst1.big_o2inst.get_max_r() != inst2.big_o2inst.get_max_r():
        return False

    counter_update_type = inst1.small_o2inst_list[0].counter_update_type
    counter_bit = inst1.small_o2inst_list[0].counter_bit

    for o2inst in inst1.small_o2inst_list:
        if o2inst.counter_update_type != counter_update_type:
            return False
        if o2inst.counter_bit != counter_bit:
            return False
        if o2inst.get_counter_dp_type() == True:
            return False
    for o2inst in inst2.small_o2inst_list:
        if o2inst.counter_update_type != counter_update_type:
            return False
        if o2inst.counter_bit != counter_bit:
            return False
        if o2inst.get_counter_dp_type() == True:
            return False
    return True
