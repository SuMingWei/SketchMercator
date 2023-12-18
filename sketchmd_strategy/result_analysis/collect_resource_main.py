import os

run_dict = {}
run_dict["workload_1"] = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
run_dict["workload_2"] = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
run_dict["workload_3"] = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
run_dict["workload_4"] = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
run_dict["workload_5"] = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]


COMPILE_RESULT_SUCCESS = 0
COMPILE_RESULT_PHV_ERROR = 1
COMPILE_RESULT_OTHER_ERROR = 2
COMPILE_RESULT_NOT_COMPLETE = 3
COMPILE_RESULT_CROSSBAR_ERROR = 4
COMPILE_RESULT_STAGE_ERROR = 5
COMPILE_RESULT_COMPILER_ERROR = 6

def get_symbol(compile_result):
    if compile_result == COMPILE_RESULT_PHV_ERROR:
        return "P"
    elif compile_result == COMPILE_RESULT_CROSSBAR_ERROR:
        return "B"
    elif compile_result == COMPILE_RESULT_STAGE_ERROR:
        return "S"
    elif compile_result == COMPILE_RESULT_COMPILER_ERROR:
        return "C"
    elif compile_result == COMPILE_RESULT_OTHER_ERROR:
        return "."
    elif compile_result == COMPILE_RESULT_NOT_COMPLETE:
        return "x"


def get_compile_result(make_log_path, tofino):
    if not os.path.exists(make_log_path):
        return COMPILE_RESULT_NOT_COMPLETE
    f = open(make_log_path, "r")
    for line in f:
        if "error: PHV allocation was not successful" in line:
            return COMPILE_RESULT_PHV_ERROR
    f.close()

    f = open(make_log_path, "r")
    for line in f:
        if "could not fit within a single input crossbar in an MAU" in line:
            return COMPILE_RESULT_CROSSBAR_ERROR
    f.close()

    f = open(make_log_path, "r")
    for line in f:
        if "tofino supports up to 12 stages" in line:
            return COMPILE_RESULT_STAGE_ERROR
    f.close()

    f = open(make_log_path, "r")
    for line in f:
        if "CompilerBug" in line:
            return COMPILE_RESULT_COMPILER_ERROR
    f.close()

    if tofino == "tofino1":
        f = open(make_log_path, "r")
        for line in f:
            if "error" in line or "Error" in line:
                return COMPILE_RESULT_OTHER_ERROR
        f.close()

    return COMPILE_RESULT_SUCCESS

def sde_951(run_dict):
    print()
    print()
    # msg = "%18s | " % ("# of sketch insts")
    # for i in range(2, 21, 2):
    #     msg += "%3d" % i
    # print(msg)
    

    data_dict = {}
    for workload_name, v in run_dict.items():
        # print(workload_name)
        # if workload_name != "workload_4":
        #     continue
        for tofino in ["tofino1"]:
            data_dict[workload_name] = {}
            temp_workload_name = workload_name
            for bf in ["before", "after"]:
                data_dict[workload_name][bf] = {}
            # for bf in ["after"]:
                # temp_workload_name = ""

                print("-" * 96)
                for sketch_num in range(2, 21, 2):
                # for sketch_num in range(2, 15, 2):
                    msg = "%10s %7s %2d | " % (temp_workload_name, bf, sketch_num)
                    data_list = []
                    data_dict[workload_name][bf][sketch_num] = []
                    sketch_num_str = "%02d" % sketch_num
                    for sample_num in range(1, 11):
                    # for sample_num in range(1, 6):
                        sample_num_str = "%02d" % sample_num
                        folder_name = f"p416_{workload_name}_{sketch_num_str}_{sample_num_str}_{bf}_0_{tofino}"
                        make_log_path = os.path.join("/home/hnamkung/barefoot/bf-sde-9.5.1/logs/p4-build", folder_name, "make.log")
                        compile_result = get_compile_result(make_log_path, tofino)
                        # exit(1)
                        if compile_result == COMPILE_RESULT_SUCCESS:
                            import json
                            resource_json_path = os.path.join("/home/hnamkung/barefoot/bf-sde-9.5.1/build/p4-build/", folder_name, "tofino", folder_name, "pipe/logs/resources.json")
                            f = open(resource_json_path)
                            data = json.load(f)
                            number_of_stages = len(data["resources"]["mau"]["mau_stages"])
                            data_list.append(str(number_of_stages))
                            data_dict[workload_name][bf][sketch_num].append(number_of_stages)
                        else:
                            symbol = get_symbol(compile_result)
                            data_list.append(symbol)
                            data_dict[workload_name][bf][sketch_num].append(13)

                    for data in data_list:
                        msg += "%3s" % data
                    print(msg)
            # print()
        print("-" * 96)


    print()
    print()
    return data_dict


data_dict = sde_951(run_dict)
print(data_dict)
from python_lib.pkl_saver import PklSaver
out_saver = PklSaver(".", "data_epoch.pkl")
out_saver.save(data_dict)

#  # of sketch insts |   1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
# ------------------------------------------------------------------------------------------------
# workload_1  before |   5  6  7  8  9 11 11 12  P  P  P  P  P  P  P  P  P  P  P  P  P  P  P  P  P
#              after |   6  7  7  8  8  9  9 10 11  P  P  P  P  P  P  P  P  P  P  P  P  P  P  P  P
# ------------------------------------------------------------------------------------------------
# workload_2  before |   7  9  7  9  9  9 11 12 11 12 12  S  P  P  P  P  P  P  P  P  P  P  P  P  P
#              after |   8 10  9  9 10 10 11 11 11 12 12 12 12 12  P  P  P  P 11  P  P  P  P  P  P
# ------------------------------------------------------------------------------------------------
# workload_3  before |   7  6 10  9 10  9 12 10  S 11  S 11  S  S  P  P  P  P  P  P  P  P  P  P  P
#              after |   8  7 12 10 10 10 11 11 12 11 11 11 12 11  S  P  P  P  P  P  P  P  P  P  P
# ------------------------------------------------------------------------------------------------
# workload_4  before |   7  7  8  9 10 11 11 11 11  S  S  P  S  P  P  P  P  P  P  P  P  P  P  P  P
#              after |   8  8  8 10 10 11  B 12 11 12  S  S 12  S  P  S  P  P  S  S  P  P  P  P  P
# ------------------------------------------------------------------------------------------------
# workload_5  before |   7  6 10  9 11 11  9 10  S  S  S  P  S  S  P  P  P  P  P  P  P  P  P  P  P
#              after |   8  7 10 10 11 10 11 10 11 11 12  S  S 12  S  B  S  P  P  P  P  P  P  P  P
# ------------------------------------------------------------------------------------------------


