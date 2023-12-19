import os
import sys
import itertools
import subprocess
import multiprocessing

from main_constants import *

metrics = ['hh', 'ent', 'cardinality', 'cd', 'fsd']
sketches = ['cm', 'cs', 'hll', 'lc', 'll', 'mrac', 'mrb', 'univmon']
srams = [1024*2**i for i in range(4, 10)] + [int(1024*0.75*2**10)]

script_dir = os.path.join(ROOT_DIR, 'global_opt')
exp_dir = os.path.join(ROOT_DIR, 'outputs')

def powerset(iterable):
    return itertools.chain.from_iterable(itertools.combinations(iterable, r) for r in range(1, len(iterable)+1))

def worker_function(info):
    print(info[:-1])
    subprocess.run(info[-1], shell=True)

def main():

    #metrics_powerset = list(powerset(metrics))
    #sketches_powerset = list(powerset(sketches))

    metrics_powerset = [tuple(metrics), tuple(metrics[:-1])]
    sketches_powerset = [tuple(sketches), tuple(sketches[:-1])]

    infos = []

    for sram in srams:
        for s_set in sketches_powerset:
            popens = []
            for m_set in metrics_powerset:
                output_dir = os.path.join(exp_dir, str(sram), '_'.join(s_set), '_'.join(m_set))
                output_file = os.path.join(output_dir, 'output.txt')
                os.makedirs(output_dir, exist_ok=True)

                cmd = 'python3 ' + os.path.join(script_dir, 'run.py')
                cmd += ' --queries "' + ','.join(['(' + m + ',5tuple)' for m in m_set]) + '"'
                cmd += ' --sketches ' + ','.join(s_set)
                cmd += ' --resources level,row,width --total_sram ' + str(sram)
                cmd += ' --resource_modeler LinearModeler --profiler_config only_actual.ini --coverage_pickle_file actual.pkl'
                cmd += ' --deployment_output --output_dir ' + output_dir
                cmd += ' > ' + output_file + ' 2>&1'

                infos.append((sram, s_set, m_set, cmd))

    pool = multiprocessing.Pool(processes=multiprocessing.cpu_count()-1 or 1)
    pool.map(worker_function, infos)
    pool.close()
    pool.join()

if __name__ == '__main__':
    main()
