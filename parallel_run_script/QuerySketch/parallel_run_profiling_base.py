from multiprocessing import Process, current_process
import os
import json
import argparse

class ParallelRunHelper:

    def __init__(self, max_pcount):
        self.max_pcount = max_pcount
        self.pcount = 0
        self.procs = []

    def proc_check(self):
        self.pcount += 1
        if self.pcount % self.max_pcount == 0:
            for proc in self.procs:
                proc.join()
            self.procs = []

    def call(self, function, fun_args):
        proc = Process(target=function, args=(*fun_args, ))
        self.procs.append(proc)
        proc.start()

        self.proc_check()

    def join(self):
        for proc in self.procs:
            proc.join()
        self.procs = []

def run_cmd_func(cmd):
	print("[by thread %s] %s" % (current_process().name, cmd))
	os.system(cmd)


def run_generate_cmd_with_iterations(input_dir, output_dir):

    run_helper = ParallelRunHelper(5) # 5 processes

    pattern = "python3 generate_cmd_with_iterations.py"

    # print(os.listdir(input_dir))
    for f in os.listdir(input_dir):
        filename = input_dir + "/" + f
        # print(filename)
        if os.path.isfile(filename) and filename.endswith('.json'):
            cmd = f"{pattern} --file {filename} --output {output_dir}"
            print(cmd)
            run_helper.call(run_cmd_func, (cmd, ))

if __name__ == '__main__':

    directory_name_list = ['hh', 'cardinality', 'fsd']
    # directory_name_list = ['ensemble']
    for directory_name in directory_name_list:
        # ### theory_vs_profile
        # input_dir = f'./inputs/theory_vs_profile/{directory_name}/'
        # output_dir = f'outputs/theory_vs_profile/{directory_name}/'
        # run_generate_cmd_with_iterations(input_dir, output_dir)

        pass

    ### single
    directory_name_list = ['hh', 'cardinality', 'fsd']
    mem_list = [4096, 8192, 16384]
    ### ensemble
    # directory_name_list = ['hh_cardinality_fsd']
    # mem_list = [8192, 16384, 32768, ]
    for directory_name in directory_name_list:
        for mem in mem_list:
            # ## impact_distribution_single
            # input_dir = f'./inputs/impact_distribution_single/{directory_name}/mem_{mem}/'
            # output_dir = f'outputs/impact_distribution_single/{directory_name}/mem_{mem}/'
            # run_generate_cmd_with_iterations(input_dir, output_dir)

            # ## impact_distribution_ensemble
            # input_dir = f'./inputs/impact_distribution_ensemble/{directory_name}/mem_{mem}/'
            # output_dir = f'outputs/impact_distribution_ensemble/{directory_name}/mem_{mem}/'
            # run_generate_cmd_with_iterations(input_dir, output_dir)


            # ## run_impact_number_of_flows_single
            # input_dir = f'./inputs/impact_number_of_flows_single/{directory_name}/mem_{mem}/'
            # output_dir = f'outputs/impact_number_of_flows_single/{directory_name}/mem_{mem}/'
            # run_generate_cmd_with_iterations(input_dir, output_dir)

            # ## impact_number_of_flows_ensemble
            # input_dir = f'./inputs/impact_number_of_flows_ensemble/{directory_name}/mem_{mem}/'
            # output_dir = f'outputs/impact_number_of_flows_ensemble/{directory_name}/mem_{mem}/'
            # run_generate_cmd_with_iterations(input_dir, output_dir)


            # ### run_impact_number_of_packets_single
            # input_dir = f'./inputs/impact_number_of_packets_single/{directory_name}/mem_{mem}/'
            # output_dir = f'outputs/impact_number_of_packets_single/{directory_name}/mem_{mem}/'
            # run_generate_cmd_with_iterations(input_dir, output_dir)

            # ### impact_number_of_packets_ensemble
            # input_dir = f'./inputs/impact_number_of_packets_ensemble/{directory_name}/mem_{mem}/'
            # output_dir = f'outputs/impact_number_of_packets_ensemble/{directory_name}/mem_{mem}/'
            # run_generate_cmd_with_iterations(input_dir, output_dir)

            # # profiler_caida_interval (expiration test)
            # # Both single & ensemble in the same directory
            # input_dir = f'./inputs/profiler_caida_interval/{directory_name}/mem_{mem}/'
            # output_dir = f'outputs/profiler_caida_interval/{directory_name}/mem_{mem}/'
            # run_generate_cmd_with_iterations(input_dir, output_dir)

            pass

    ### single
    # directory_name_list = ['hh', 'cardinality', 'fsd']
    # mem_list = [4096, 8192, ] # 16384
    ### ensemble
    directory_name_list = ['hh_cardinality_fsd']
    mem_list = [8192, 16384, 32768, ]
    random_runs = 5
    for runs in range(random_runs):
        for directory_name in directory_name_list:
            for mem in mem_list:
                ### profiler_caida_num_of_pcaps/ (number of pcaps test)
                ### Both single & ensemble in the same directory
                input_dir = f'./inputs/profiler_caida_num_of_pcaps/runs_{runs}/{directory_name}/mem_{mem}/'
                output_dir = f'outputs/profiler_caida_num_of_pcaps/runs_{runs}/{directory_name}/mem_{mem}/'
                run_generate_cmd_with_iterations(input_dir, output_dir)

            