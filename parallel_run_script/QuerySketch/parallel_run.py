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

    run_helper = ParallelRunHelper(30) # 30 processes

    pattern = "python3 generate_cmd_with_iterations.py"

    # print(os.listdir(input_dir))
    for f in os.listdir(input_dir):
        filename = input_dir + "/" + f
        # print(filename)
        if os.path.isfile(filename):
            cmd = f"{pattern} --file {filename} --output {output_dir}"
            print(cmd)
            run_helper.call(run_cmd_func, (cmd, ))

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--dir', help='directory', default="./inputs/smartnic", required=False)
    args = parser.parse_args()

    # num_of_metric
    if args.dir == "./inputs/num_of_metric":
        output_dir = "outputs/num_of_metrics/"
    # impact_of_mem
    elif args.dir == "./inputs/impact_of_mem":
        output_dir = "outputs/impact_of_mem/"
    # num_of_pcap
    elif args.dir == "./inputs/num_of_pcap":
        output_dir = "outputs/num_of_pcap/"
    # diff_ensemble (gain over strawman)
    elif args.dir == "./inputs/diff_ensemble":
        output_dir = "outputs/diff_ensemble/"
    # different objective functions
    elif args.dir == "./inputs/objective_function":
        output_dir = "outputs/objective_function/"
    # different error constraints
    elif args.dir == "./inputs/diff_error_constraint":
        output_dir = "outputs/diff_error_constraint/"
    # effectiveness of each module
    elif args.dir == "./inputs/effective_module":
        output_dir = "outputs/effective_module/"
    # test profile per epoch
    elif args.dir == "./inputs/profile_frequency":
        output_dir = "outputs/profile_frequency/"
    # smartnic
    elif args.dir == "./inputs/smartnic":
        output_dir = "outputs/smartnic/"
    else:
        print("unexpected directory")
        exit(1)

    run_generate_cmd_with_iterations(args.dir, output_dir)


