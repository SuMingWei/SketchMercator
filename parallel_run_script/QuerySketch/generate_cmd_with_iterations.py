import json
import argparse
import datetime
import os

def get_solution_mapping_table():
    algos = ["cm", "cs", "mrac", "lc", "mrb", "hll", 'll', 'univmon']
    metrics = ['hh', 'fsd', 'entropy', 'card', 'change_det']
    return {'algos': algos, 'metrics': metrics}

def generate_dp_cmd(algo, row, width, level=1):
    cmd = f"time python run_parallel_dp_main.py --sketch {algo} " \
            f"--row {row} --width {width} --level {level}"
    return cmd

def generate_cp_cmd(algo, row, width, level=1):
    cmd = f"time python run_parallel_cp_main.py --sketch {algo} " \
            f"--row {row} --width {width} --level {level}"
    return cmd

def get_counter_size(algo = 'cm'):
    counter_size = 4
    if algo == 'hll' or algo == 'll':
        # int8
        counter_size = 1
    elif algo == 'lc' or algo == 'mrb':
        # 1 bit
        counter_size = 1/8
    return counter_size

def make_get_result_from_pkl_cmd(name):
    tmp = "ret = get_result_from_pkl(algos, rows, widths, level, seeds, count, measure_list, flowkeys, epochs, datasets)\n"
    tmp += "for m in measure_list:\n"
    tmp += "\ttmp = {}\n"
    tmp += "\ttmp[m] = ret[m][rows[0]][widths[0]]\n"
    tmp += f"\t{name} = {{**{name}, **tmp}}\n\n"

    return tmp

###################

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--file', help='filename', default='inputs/test.json', required=False)
    parser.add_argument('-o', '--output', help='output directory', default="outputs/", required=False)
    args = parser.parse_args()

    filename = args.file

    table = get_solution_mapping_table()
    result = "Filename = " + filename.split('/')[-1] + "\n"
    jupyter_cmd = f"\n# ========== {filename.split('/')[-1]} ==========\n"

    with open(filename, 'r') as f:
        file = json.load(f)
        mem_list = []

        print("len of file:", len(file))
        runs = int((len(file) - 1)/4) # (length - 1 bruteforce) / 4 strawman
        print("num of run:",runs)
        ret_list = ["ret_us"]
        for i in range(runs):
            ret_list.append("ret_sol1")
        for i in range(runs):
            ret_list.append("ret_sol2")
        for i in range(runs):
            ret_list.append("ret_sol3")
        for i in range(runs):
            ret_list.append("ret_sol4")
        
        # iterate different methods (strawmen, brute force)
        for idx, data in enumerate(file):
            # print(data)
            mem_usage = 0
            ret_str = ret_list[idx]
            jupyter_cmd += "\n#############################\n"
            jupyter_cmd += f"{ret_str} = {{}} \n\n"

            for i, s in enumerate(data['solutions']):
                
                mem_usage += s['row'] * s['width'] * s['level']

                # convert memory size to number of columns
                counter_size = get_counter_size(table['algos'][int(s['algo'])])
                s['width'] = int(int(s['width']) / counter_size)

                tmp = f"----------------- data plane: {i}, {data['name']} -----------------"
                result += tmp + '\n'

                tmp = generate_dp_cmd(table['algos'][int(s['algo'])], s['row'], s['width'], s['level'])
                result += tmp + '\n'

                tmp = f"----------------- control plane: {i}, {data['name']} -----------------"
                result += tmp + '\n'

                tmp = generate_cp_cmd(table['algos'][int(s['algo'])], s['row'], s['width'], s['level'])
                result += tmp + '\n'


                tmp = f"----------------- jupyter: {i}, {data['name']} -----------------"
                result += tmp + '\n'
                
                tmp = "measure_list = ["
                for m in s['metric']:
                    tmp += f"\'{table['metrics'][int(m)]}\', "
                tmp += "]"
                result += tmp + '\n'
                jupyter_cmd += tmp + '\n'

                tmp = 'algos = [\'' + table['algos'][int(s['algo'])] + '\']'
                result += tmp + '\n'
                jupyter_cmd += tmp + '\n'

                # # customize univmon
                # if table['algos'][int(s['algo'])] == 'univmon' and s['width'] >= 1024 and s['row'] == 1:
                #     s['width'] = int(1024/4)
                #     s['row'] = 4
                # customize hll
                if table['algos'][int(s['algo'])] == 'hll' and s['width'] > 65536:
                    s['width'] = 65536

                tmp = 'widths = [' + str(s['width']) + ']'
                result += tmp + '\n'
                jupyter_cmd += tmp + '\n'
                
                tmp = 'rows = [' + str(s['row']) + ']'
                result += tmp + '\n'
                jupyter_cmd += tmp + '\n'
                
                tmp = 'level = ' + str(s['level'])
                result += tmp + '\n'
                jupyter_cmd += tmp + '\n'
                jupyter_cmd += make_get_result_from_pkl_cmd(ret_str)
                # exit()
                
                tmp = '==========================================================\n'
                result += tmp + '\n'
                

            jupyter_cmd += f"{ret_str}_ll.append({ret_str})\n"
            
            tmp = f"Memory usage: {int(mem_usage/1024)} KB\n=========================================================="
            result += tmp + '\n'
            
            mem_list.append(int(mem_usage/1024))
        for mem in mem_list:
            tmp = f"Memory usage: {mem} KB"
            result += tmp + '\n'
            
    
    # print(result)
    # jupyter_cmd += "\n## call plotting\n"
    # jupyter_cmd += "ret_sol1, ret_sol2, ret_sol3, ret_sol4, ret_us = get_mean_from_iterations(ret_sol1_ll, ret_sol2_ll, ret_sol3_ll, ret_sol4_ll, ret_us_ll, all_metrics)\n"
    # jupyter_cmd += "call_plotting(ret_sol1, ret_sol2, ret_sol3, ret_sol4, ret_us, name, mem_size, all_metrics, isSaveFig)"

    filename = filename[:-5] #.json
    filename = filename.split('/')[-1]
    filename = args.output + "/" + datetime.datetime.now().strftime('%Y-%m-%d-') + filename + '-result.txt'
    # print(filename)
    if not os.path.exists(args.output):
        os.makedirs(args.output)
    with open(filename, 'w') as f:
        f.write(jupyter_cmd)
        # f.write(result)