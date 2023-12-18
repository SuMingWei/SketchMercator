from multiprocessing import Process, current_process
import os

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

def run_cmd_list(cmd_list, max_pcount):
    run_helper = ParallelRunHelper(max_pcount)

    for cmd in cmd_list:
        print(cmd)
        run_helper.call(run_cmd_func, (cmd, ))

##########################

# test the impact of different memory size on solver
def run_impact_memory_size(run_helper, profile_name = 'profiler_caida_srcip', iteration_num = 3):
    # memory_list = [32768, 65536, 131072, 262144, 524288, 1048576]
    memory_list = [16384, 32768, 65536, 131072, 262144, 524288]

    metric_str = '(hh,5tuple),(cd,5tuple),(ent,5tuple),(cardinality,5tuple),(fsd,5tuple)'
    # metric_str = '(hh,5tuple),(cd,5tuple),(ent,5tuple)'
    # sketches = 'cm,lc,cs,hll,mrb,mrac,univmon,ll'
    sketches = 'cm,lc,cs,hll,mrb,mrac,ll'
    profiles_path = os.path.join(os.path.expandvars('$sketch_home'), 'query_to_sketch', \
                                    'profiler', profile_name)

    output_dir = f'output/{profile_name}/impact_of_mem'

    # create directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    cnt = 0
    for mem in memory_list:
        cmd = f'python3 run.py --queries \"{metric_str}\" '\
            f'--sketches {sketches} --resources level,row,width --resource_modeler LinearModeler '\
            f'--profiler_config_file only_actual.ini --profiles_path {profiles_path} ' \
            f'--coverage_pickle_file actual.pkl --num_strawman_runs {iteration_num} '\
            f'--total_sram {mem} --deployment_output --output_dir {output_dir} '\
            f'--output_file mem_{mem}.json > {output_dir}/mem_{mem}.txt'
        print(cmd)
        cnt += 1
        run_helper.call(run_cmd_func, (cmd, ))
    print("count:", cnt)

# test the impact of different distributions on single metric
def run_impact_distribution_single(run_helper, profile_name_list = ['profiler_caida_srcip'], iteration_num = 3):
    memory_list = [4096, 8192, 16384, ]

    metric_str_list = ['(hh,5tuple)', '(cardinality,5tuple)', '(fsd,5tuple)']
    directory_name_list = ['hh', 'cardinality', 'fsd']
    # metric_str = '(hh,5tuple),(cd,5tuple),(ent,5tuple),(cardinality,5tuple),(fsd,5tuple)'
    # sketches = 'cm,lc,cs,hll,mrb,mrac,univmon,ll'
    sketches = 'cm,lc,cs,hll,mrb,mrac,ll'

    cnt = 0
    for mem in memory_list:
        for metric_str, directory_name in zip(metric_str_list, directory_name_list):
            output_dir = f'output/impact_distribution_single/{directory_name}'
            # print(f'output_dir: {output_dir}')

            # create directory if it doesn't exist
            if not os.path.exists(output_dir):
                os.makedirs(output_dir)

            for profile_name in profile_name_list:
                profiles_path = os.path.join(os.path.expandvars('$sketch_home'), 'query_to_sketch', \
                                    'profiler', profile_name)
                # print(f'profiles_path: {profiles_path}')

                cmd = f'python3 run.py --queries \"{metric_str}\" '\
                    f'--sketches {sketches} --resources level,row,width --resource_modeler LinearModeler '\
                    f'--profiler_config_file only_actual.ini --profiles_path {profiles_path} ' \
                    f'--coverage_pickle_file actual.pkl --num_strawman_runs {iteration_num} '\
                    f'--total_sram {mem} --deployment_output --output_dir {output_dir} '\
                    f'--output_file {profile_name}_mem_{mem}.json > {output_dir}/{profile_name}_mem_{mem}.txt'
                print(cmd)
                cnt += 1
                run_helper.call(run_cmd_func, (cmd, ))
    print("count:", cnt)

# test the impact of different distributions on ensemble metric
def run_impact_distribution_ensemble(run_helper, profile_name_list = ['profiler_caida_srcip'], iteration_num = 3):
    memory_list = [16384, 32768, 65536, ]

    metric_str_list = ['(hh,5tuple),(cardinality,5tuple),(fsd,5tuple)']
    directory_name_list = ['hh_cardinality_fsd']
    # metric_str = '(hh,5tuple),(cd,5tuple),(ent,5tuple),(cardinality,5tuple),(fsd,5tuple)'
    # sketches = 'cm,lc,cs,hll,mrb,mrac,univmon,ll'
    sketches = 'cm,lc,cs,hll,mrb,mrac,ll'

    cnt = 0
    for mem in memory_list:
        for metric_str, directory_name in zip(metric_str_list, directory_name_list):
            output_dir = f'output/impact_distribution_ensemble/{directory_name}'
            # print(f'output_dir: {output_dir}')

            # create directory if it doesn't exist
            if not os.path.exists(output_dir):
                os.makedirs(output_dir)

            for profile_name in profile_name_list:
                profiles_path = os.path.join(os.path.expandvars('$sketch_home'), 'query_to_sketch', \
                                    'profiler', profile_name)
                # print(f'profiles_path: {profiles_path}')

                cmd = f'python3 run.py --queries \"{metric_str}\" '\
                    f'--sketches {sketches} --resources level,row,width --resource_modeler LinearModeler '\
                    f'--profiler_config_file only_actual.ini --profiles_path {profiles_path} ' \
                    f'--coverage_pickle_file actual.pkl --num_strawman_runs {iteration_num} '\
                    f'--total_sram {mem} --deployment_output --output_dir {output_dir} '\
                    f'--output_file {profile_name}_mem_{mem}.json > {output_dir}/{profile_name}_mem_{mem}.txt'
                print(cmd)
                cnt += 1
                run_helper.call(run_cmd_func, (cmd, ))
    print("count:", cnt)


# test the impact of different number of flows on single metric
def run_impact_number_of_flows_single(run_helper, profile_name_list = ['profiler_caida_srcip'], iteration_num = 3):
    memory_list = [4096, 8192, 16384, ]

    metric_str_list = ['(hh,5tuple)', '(cardinality,5tuple)', '(fsd,5tuple)']
    directory_name_list = ['hh', 'cardinality', 'fsd']
    # metric_str = '(hh,5tuple),(cd,5tuple),(ent,5tuple),(cardinality,5tuple),(fsd,5tuple)'
    # sketches = 'cm,lc,cs,hll,mrb,mrac,univmon,ll'
    sketches = 'cm,lc,cs,hll,mrb,mrac,ll'

    cnt = 0
    for mem in memory_list:
        for metric_str, directory_name in zip(metric_str_list, directory_name_list):
            output_dir = f'output/impact_number_of_flows_single/{directory_name}'
            # print(f'output_dir: {output_dir}')

            # create directory if it doesn't exist
            if not os.path.exists(output_dir):
                os.makedirs(output_dir)

            for profile_name in profile_name_list:
                profiles_path = os.path.join(os.path.expandvars('$sketch_home'), 'query_to_sketch', \
                                    'profiler', profile_name)
                # print(f'profiles_path: {profiles_path}')

                cmd = f'python3 run.py --queries \"{metric_str}\" '\
                    f'--sketches {sketches} --resources level,row,width --resource_modeler LinearModeler '\
                    f'--profiler_config_file only_actual.ini --profiles_path {profiles_path} ' \
                    f'--coverage_pickle_file actual.pkl --num_strawman_runs {iteration_num} '\
                    f'--total_sram {mem} --deployment_output --output_dir {output_dir} '\
                    f'--output_file {profile_name}_mem_{mem}.json > {output_dir}/{profile_name}_mem_{mem}.txt'
                print(cmd)
                cnt += 1
                run_helper.call(run_cmd_func, (cmd, ))
    print("count:", cnt)


# test the impact of different number of packets on single metric
def run_impact_number_of_packets_single(run_helper, profile_name_list = ['profiler_caida_srcip'], iteration_num = 3):
    memory_list = [4096, 8192, 16384, ]

    # metric_str_list = ['(hh,5tuple)', '(cardinality,5tuple)', '(fsd,5tuple)']
    # directory_name_list = ['hh', 'cardinality', 'fsd']
    metric_str_list = ['(cardinality,5tuple)']
    directory_name_list = ['cardinality']
    sketches = 'cm,lc,cs,hll,mrb,mrac,ll'

    cnt = 0
    for mem in memory_list:
        for metric_str, directory_name in zip(metric_str_list, directory_name_list):
            output_dir = f'output/impact_number_of_packets_single/{directory_name}'
            # print(f'output_dir: {output_dir}')

            # create directory if it doesn't exist
            if not os.path.exists(output_dir):
                os.makedirs(output_dir)

            for profile_name in profile_name_list:
                profiles_path = os.path.join(os.path.expandvars('$sketch_home'), 'query_to_sketch', \
                                    'profiler', profile_name)
                # print(f'profiles_path: {profiles_path}')

                cmd = f'python3 run.py --queries \"{metric_str}\" '\
                    f'--sketches {sketches} --resources level,row,width --resource_modeler LinearModeler '\
                    f'--profiler_config_file only_actual.ini --profiles_path {profiles_path} ' \
                    f'--coverage_pickle_file actual.pkl --num_strawman_runs {iteration_num} '\
                    f'--total_sram {mem} --deployment_output --output_dir {output_dir} '\
                    f'--output_file {profile_name}_mem_{mem}.json > {output_dir}/{profile_name}_mem_{mem}.txt'
                print(cmd)
                cnt += 1
                run_helper.call(run_cmd_func, (cmd, ))
    print("count:", cnt)


if __name__ == '__main__':
    
    run_helper = ParallelRunHelper(30) # 30 processes
    iteration_num = 5 # --num_strawman_runs argument for solver, represent how many runs for strawmen in solver

    # This script can run the solver (run.py) in parallel
    # Each function maps to each experiment

    # After execute this script, if we want to get figures from these output results, 
    # we need to copy the output json files to `$sketch_home/parallel_run_script/QuerySketch/inputs/`,
    # then setup & execute the `$sketch_home/parallel_run_script/QuerySketch/parallel_run.py` 
    # (which can generate code for different plotting results from the output json here) 
    # to get the auto-generation codes for plotting scripts.
    # After that, we need to copy&paste the auto-generation codes to the mapping plotting scripts,
    # (plotting scripts is in `$sketch_home/result_plots/QuerySketch/`)
    # then we can get the result figures of experiments (figures on the paper)
    
    # profile_name_list = ['profiler_caida_srcip', 'profiler_uniform_100_srcip', 'profiler_zipf_1.1_srcip']
    # for profile_name in profile_name_list:
    #     run_impact_memory_size(run_helper, profile_name, iteration_num)
    
    # profile_name_list = ['profiler_caida_srcip', 'profiler_uniform_fixFlowPkt_srcip', 'profiler_zipf_1.1_fixFlowPkt_srcip']
    # run_impact_distribution_single(run_helper, profile_name_list, iteration_num)
    # run_impact_distribution_ensemble(run_helper, profile_name_list, iteration_num)

    # profile_name_list = ['profiler_zipf_1.1_numberofFlow_0.5x_srcip', 'profiler_zipf_1.1_numberofFlow_1x_srcip', 'profiler_zipf_1.1_numberofFlow_2x_srcip']
    profile_name_list = ['profiler_zipf_1.1_numberofFlow_0.1x_srcip', 'profiler_zipf_1.1_numberofFlow_4x_srcip', 'profiler_zipf_1.1_numberofFlow_10x_srcip']
    run_impact_number_of_flows_single(run_helper, profile_name_list, iteration_num)

    # profile_name_list = ['profiler_zipf_1.1_numberofPkt_0.3x_srcip', 'profiler_zipf_1.1_numberofPkt_0.6x_srcip', 'profiler_zipf_1.1_numberofPkt_1x_srcip']
    # run_impact_number_of_packets_single(run_helper, profile_name_list, iteration_num)

    pass
