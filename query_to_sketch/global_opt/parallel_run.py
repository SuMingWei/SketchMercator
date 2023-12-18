import os
import itertools
from multiprocessing import Process, current_process

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
def run_impact_memory_size(run_helper, iteration_num = 3):
    memory_list = [32768, 65536, 131072, 262144, 524288, 1048576]

    cnt = 0
    for mem in memory_list:
        # \"(hh,5tuple),(cd,5tuple),(ent,5tuple),(cardinality,5tuple),(fsd,5tuple)\"
        cmd = 'python3 run.py --queries \"(hh,5tuple)\" '\
            '--sketches cm,lc,cs,hll,mrb,mrac,univmon,ll --resources level,row,width --resource_modeler LinearModeler '\
            f'--profiler_config only_actual.ini --coverage_pickle_file actual.pkl --num_strawman_runs {iteration_num} '\
            f'--total_sram {mem} --deployment_output --output_dir impact_of_mem '\
            f'--output_file mem_{mem}_run_{iteration_num}.json > impact_of_mem/mem_{mem}_run_{iteration_num}.txt'
        print(cmd)
        cnt += 1
        run_helper.call(run_cmd_func, (cmd, ))
    print("count:", cnt)

# test the impact of number of metrics in an ensemble on solver
# num=5 has only one ensemble
# num=2~4 has 3 differnet ensembles
def run_number_of_metrics(run_helper, iteration_num = 3):
    metrics_list = [['hh', 'cd', 'ent', 'cardinality', 'fsd'], 
                    ['hh', 'cd', 'ent', 'fsd'], ['hh', 'ent', 'cardinality', 'fsd'], ['hh', 'cd', 'ent', 'cardinality'], 
                    ['hh', 'ent', 'fsd'], ['ent', 'cardinality', 'fsd'], ['hh', 'cd', 'cardinality'], 
                    ['ent', 'fsd'], ['hh', 'fsd'], ['hh', 'cardinality'], ]

    cnt = 0
    for d in metrics_list:
        metric_str = ""
        filename = ""
        for m in d:
            metric_str += f"({m},5tuple),"
            filename += f"{m}_"
        metric_str = metric_str[:-1]
        filename = filename[:-1]
        cmd = f'python3 run.py --queries \"{metric_str}\" '\
            '--sketches cm,lc,cs,hll,mrb,mrac,univmon,ll --resources level,row,width --resource_modeler LinearModeler '\
            '--profiler_config only_actual.ini --coverage_pickle_file actual.pkl --total_sram 131072 --deployment_output '\
            f' --num_strawman_runs {iteration_num} --output_dir num_of_metric '\
            f'--output_file metric_{len(d)}_{filename}_run_{iteration_num}.json > '\
            f'num_of_metric/metric_{len(d)}_{filename}_run_{iteration_num}.txt'
        print(cmd)
        cnt += 1
        run_helper.call(run_cmd_func, (cmd, ))
    print("count:", cnt)

# use how many pcaps to get the profiling results, and as the input for the solver
def run_number_of_pcaps(run_helper, iteration_num = 3):
    pcap_nums = [1, 3, 5, 7, 9]

    cnt = 0
    for pcap_num in pcap_nums: 

        profiles_path = os.path.join(os.path.expandvars('$sketch_home'), 'query_to_sketch', \
                                    'profiler', 'actual_profiles_diff_pcaps', f'pcap_{pcap_num}')

        cmd = 'python3 run.py --queries \"(hh,5tuple),(cd,5tuple),(ent,5tuple),(cardinality,5tuple),(fsd,5tuple)\" '\
            '--sketches cm,lc,cs,hll,mrb,mrac,univmon,ll --resources level,row,width --resource_modeler LinearModeler '\
            f'--profiler_config only_actual.ini --coverage_pickle_file actual.pkl --num_strawman_runs {iteration_num} '\
            f'--total_sram 131072 --deployment_output --output_dir num_of_pcap --profiles_path {profiles_path} '\
            f'--output_file pcap_{pcap_num}_run_{iteration_num}.json > num_of_pcap/pcap_{pcap_num}_run_{iteration_num}.txt'
        print(cmd)
        cnt += 1
        # run_helper.call(run_cmd_func, (cmd, ))
    print("count:", cnt)

# test the impact of using different metrics in an ensemble
# num=4, test all combination of 5 metrics (test 5 ensembles)
# num=5 (all), only one ensemble
def run_diff_ensemble(run_helper, iteration_num = 3):
    metrics_all = ['hh', 'cd', 'ent', 'cardinality', 'fsd']
    num_of_metric_per_ensemble = [4, 5]

    cnt = 0
    for n in num_of_metric_per_ensemble:
        if n == 4:
            for skip in range(len(metrics_all)):
                metric_str = ""
                filename = ""
                for i, m in enumerate(metrics_all):
                    if i == skip:
                        continue
                    metric_str += f"({m},5tuple),"
                    filename += f"{m}_"
                metric_str = metric_str[:-1]
                filename = filename[:-1]
                cmd = f'python3 run.py --queries \"{metric_str}\" '\
                    '--sketches cm,lc,cs,hll,mrb,mrac,univmon,ll --resources level,row,width --resource_modeler LinearModeler '\
                    '--profiler_config only_actual.ini --coverage_pickle_file actual.pkl --total_sram 131072 --deployment_output '\
                    f'--num_strawman_runs {iteration_num} --output_dir diff_ensemble '\
                    f'--output_file metric_{n}_{filename}_run_{iteration_num}.json  '\
                    f'> diff_ensemble/metric_{n}_{filename}_run_{iteration_num}.txt'

                print(cmd)
                cnt += 1
                run_helper.call(run_cmd_func, (cmd, ))
        
        elif n == 5:
            metric_str = ""
            filename = ""
            for i, m in enumerate(metrics_all):
                metric_str += f"({m},5tuple),"
                filename += f"{m}_"
            metric_str = metric_str[:-1]
            filename = filename[:-1]
            cmd = f'python3 run.py --queries \"{metric_str}\" '\
                '--sketches cm,lc,cs,hll,mrb,mrac,univmon,ll --resources level,row,width --resource_modeler LinearModeler '\
                '--profiler_config only_actual.ini --coverage_pickle_file actual.pkl --total_sram 131072 --deployment_output '\
                f'--num_strawman_runs {iteration_num} --output_dir diff_ensemble '\
                f'--output_file metric_{n}_{filename}_run_{iteration_num}.json  '\
                f'> diff_ensemble/metric_{n}_{filename}_run_{iteration_num}.txt'
            
            print(cmd)
            cnt += 1
            run_helper.call(run_cmd_func, (cmd, ))

    print("count:", cnt)

# use different objective functions on the solver
def run_objective_functions(run_helper, iteration_num):
    agg_queries = ['avg', 'max', 'avg']
    agg_traces = ['median', 'max', 'min']

    assert len(agg_queries) == len(agg_traces)

    cnt = 0
    for query, trace in zip(agg_queries, agg_traces):
        cmd = 'python3 run.py --queries \"(hh,5tuple),(cd,5tuple),(ent,5tuple),(cardinality,5tuple),(fsd,5tuple)\" '\
            '--sketches cm,lc,cs,hll,mrb,mrac,univmon,ll --resources level,row,width --resource_modeler LinearModeler '\
            f'--profiler_config only_actual.ini --coverage_pickle_file actual.pkl --num_strawman_runs {iteration_num} '\
            f'--total_sram 131072 --deployment_output --output_dir objective_function '\
            f'--agg_queries {query} --agg_traces {trace} ' \
            f'--output_file {query}_{trace}_run_{iteration_num}.json > objective_function/{query}_{trace}_run_{iteration_num}.txt'
        print(cmd)
        cnt += 1
        run_helper.call(run_cmd_func, (cmd, ))
    print("count:", cnt)

# test the impact of different error constraints on a single metric
# e.g. change detection, 0.2 vs. 0.3
def run_diff_error_constraint(run_helper, iteration_num):
    
    metrics_list = [['hh', 'cd', 'ent', 'cardinality', 'fsd'], 
                    ['hh', 'cd', 'ent', 'cardinality', 'fsd'], 
                    ['cd', 'ent', 'cardinality', 'fsd'],
                    ['cd', 'ent', 'cardinality', 'fsd'],
                    ['hh', 'ent', 'cardinality', 'fsd'],
                    ['hh', 'ent', 'cardinality', 'fsd'],] 

    bound_list = ["(cd,0.3)",
                "(cd,0.2)",
                "(cd,0.3)",
                "(cd,0.2)",
                "(hh,0.1)",
                "(hh,0.05)",]
                

    assert len(metrics_list) == len(bound_list)
    
    cnt = 0
    for metrics, bound in zip(metrics_list, bound_list):
        metric_str = ""
        filename = ""
        for m in metrics:
            metric_str += f"({m},5tuple),"
            filename += f"{m}_"
        metric_str = metric_str[:-1]
        filename = filename[:-1]

        tmp = bound[1:-1].split(',')
        bound_str = tmp[0] + "_" + tmp[1].split('.')[1]

        # --agg_queries max 
        cmd = f'python3 run.py --queries \"{metric_str}\" '\
            '--sketches cm,lc,cs,hll,mrb,mrac,univmon,ll --resources level,row,width --resource_modeler LinearModeler '\
            f'--profiler_config only_actual.ini --coverage_pickle_file actual.pkl --num_strawman_runs {iteration_num} '\
            f'--total_sram 131072 --deployment_output --output_dir diff_error_constraint '\
            f'--query_error_constraints \"{bound}\" ' \
            f'--output_file metric_{len(metrics)}_{filename}_bound_{bound_str}_run_{iteration_num}.json '\
            f'> diff_error_constraint/metric_{len(metrics)}_{filename}_bound_{bound_str}_run_{iteration_num}.txt'
        print(cmd)
        cnt += 1
        run_helper.call(run_cmd_func, (cmd, ))
    print("count:", cnt)

# test different effectiveness modules on the solver
# e.g. naive_sketch_selection, naive_resource_allocation
# WARNING: 
# The solver will output 2 results of bruteforce in a single output json file
# So, we need to run `split_effective_module.py` to split 2 results of 1 json file into 2 json files
def run_effectiveness_of_module(run_helper, iteration_num):
    modules = ['', 'naive_sketch_selection', 'naive_resource_allocation']
    profiles_path = os.path.join(os.path.expandvars('$sketch_home'), 'query_to_sketch', \
                                'profiler', 'actual_profiles_lower_memory')

    cnt = 0
    for module in modules:
        if module == '':
            name = 'original'
        else:
            name = module
            module = '--' + module

        cmd = 'python3 run.py --queries \"(hh,5tuple),(cd,5tuple),(ent,5tuple),(cardinality,5tuple),(fsd,5tuple)\" '\
            '--sketches cm,lc,cs,hll,mrb,mrac,univmon,ll --resources level,row,width --resource_modeler LinearModeler '\
            f'--profiler_config only_actual.ini --coverage_pickle_file actual.pkl --num_strawman_runs {iteration_num} '\
            f'--total_sram 131072 --deployment_output --output_dir effective_module '\
            f'{module} --profiles_path {profiles_path} ' \
            f'--output_file {name}_run_{iteration_num}.json > effective_module/{name}_run_{iteration_num}.txt'
        print(cmd)
        cnt += 1
        run_helper.call(run_cmd_func, (cmd, ))
    print("count:", cnt)

def run_profile_frequency(run_helper, iteration_num):
    date_list = ['20180621', '20180816'] #'20180517', 
    epochs = 6

    cnt = 0
    for date in date_list:
        for epoch in range(epochs):
            profiles_path = os.path.join(os.path.expandvars('$sketch_home'), 'query_to_sketch', \
                                    'profiler', 'actual_profiles_per_epoch', date, f'epoch_{epoch}')

            cmd = 'python3 run.py --queries \"(hh,5tuple),(cd,5tuple),(ent,5tuple),(cardinality,5tuple),(fsd,5tuple)\" '\
                '--sketches cm,lc,cs,hll,mrb,mrac,univmon,ll --resources level,row,width --resource_modeler LinearModeler '\
                f'--profiler_config only_actual.ini --coverage_pickle_file actual.pkl --num_strawman_runs {iteration_num} '\
                f'--total_sram 131072 --deployment_output --output_dir profile_frequency '\
                f'--profiles_path {profiles_path} ' \
                f'--output_file {date}_epoch_{epoch}_run_{iteration_num}.json > profile_frequency/{date}_epoch_{epoch}_run_{iteration_num}.txt'
            print(cmd)
            cnt += 1
            run_helper.call(run_cmd_func, (cmd, ))
    print("count:", cnt)


def run_theory_vs_profile(run_helper, iteration_num = 3):
    memory_list = [4096, 8192, 16384, 32768, 65536]
    profile_name_list = ['actual_profiles_lower_memory']

    metric_str_list = ['(hh,5tuple)', '(cardinality,5tuple)']
    directory_name_list = ['hh', 'cardinality']
    sketches = 'cm,lc,cs,hll,mrb,mrac,univmon,ll'

    cnt = 0
    for mem in memory_list:
        for metric_str, directory_name in zip(metric_str_list, directory_name_list):
            output_dir = f'output/theory_vs_profile/{directory_name}'
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

def run_accuracy_resource_tradeoff(run_helper, iteration_num):
    memory_list = [16384, 32768, 65536, 131072, 262144, 524288, 1048576]

    metrics = ['hh', 'cd', 'ent', 'cardinality', 'fsd']
    flowkey = ('dstip', 'dstport')

    queries = [(m, *flowkey) for m in metrics]
    print_queries = [str(q) for q in queries]
    final_query_string = ';'.join(print_queries)

    cnt = 0
    for mem in memory_list:
        # \"('hh',5tuple),(cd,5tuple),(ent,5tuple),(cardinality,5tuple),(fsd,5tuple)\"
        # cmd = 'python3 run.py --queries \"(hh,5tuple)\" '\
        cmd = f'python3 run.py --queries \"{final_query_string}\" '\
            '--sketches cm,lc,cs,hll,mrb,mrac,univmon,ll --resources level,row,width --resource_modeler LinearModeler '\
            f'--profiler_config only_actual.ini --coverage_pickle_file actual.pkl --num_strawman_runs {iteration_num} '\
            f'--total_sram {mem} --deployment_output --output_dir acc_res_tradeoff '\
            f'--output_file mem_{mem}_run_{iteration_num}.json > acc_res_tradeoff/mem_{mem}_run_{iteration_num}.txt'
        print(cmd)
        cnt += 1
        run_helper.call(run_cmd_func, (cmd, ))
    print("count:", cnt)

def run_impact_of_sketch_library_size(run_helper, iteration_num):
    def powerset(iterable, length):
        return list(itertools.combinations(iterable, length))

    memory_bound = 131072
    output_dir = 'impact_of_num_sketches'

    metrics = ['hh', 'cd', 'ent', 'cardinality', 'fsd']
    flowkey = ('dstip', 'dstport')

    queries = [(m, *flowkey) for m in metrics]
    print_queries = [str(q) for q in queries]
    final_query_string = ';'.join(print_queries)

    all_sketches = ['cm', 'lc', 'cs', 'hll', 'mrb', 'mrac', 'univmon', 'll']
    sketches_lists = []
    for l in range(len(all_sketches) - 3, len(all_sketches) + 1):
        sketches_lists.extend(powerset(all_sketches, l))

    cnt = 0
    for sketches_list in sketches_lists:
        sketches_list_arg = ','.join(sketches_list)
        sketches_list_repr = '_'.join(sketches_list)
        cmd = f'python3 run.py --queries \"{final_query_string}\" '\
            f'--sketches {sketches_list_arg} --resources level,row,width --resource_modeler LinearModeler '\
            f'--profiler_config only_actual.ini --coverage_pickle_file actual.pkl --num_strawman_runs {iteration_num} '\
            f'--total_sram {memory_bound} --deployment_output --output_dir {output_dir} '\
            f'--output_file sketches_{sketches_list_repr}_run_{iteration_num}.json > {output_dir}/sketches_{sketches_list_repr}_run_{iteration_num}.txt'
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

    # run_impact_memory_size(run_helper, iteration_num)
    # run_number_of_metrics(run_helper, iteration_num)
    # run_number_of_pcaps(run_helper, iteration_num)
    # run_diff_ensemble(run_helper, iteration_num)
    # run_objective_functions(run_helper, iteration_num)
    # run_diff_error_constraint(run_helper, iteration_num)
    # run_effectiveness_of_module(run_helper, iteration_num)
    # run_profile_frequency(run_helper, iteration_num)
    # run_theory_vs_profile(run_helper, iteration_num)
    run_accuracy_resource_tradeoff(run_helper, iteration_num)
    # run_impact_of_sketch_library_size(run_helper, iteration_num)
    pass
