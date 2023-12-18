import os
import sys
import argparse
import itertools
import subprocess
import multiprocessing

from main_constants import *

metrics = ['hh', 'ent', 'cardinality', 'cd', 'fsd']
#metrics = ['hh', 'ent', 'cardinality']
sketches = ['cm', 'cs', 'hll', 'lc', 'll', 'mrac', 'mrb', 'univmon']
srams = [1024*2**i for i in range(4, 10)] + [int(1024*0.75*2**10)]
srams = [1024*2**4, 1024*2**5]
#flowkeys = ['five_tuple']
flowkeys = [('dstIP', 'dstPort')]

script_dir = os.path.join(ROOT_DIR, 'global_opt')

def powerset(iterable):
    return itertools.chain.from_iterable(itertools.combinations(iterable, r) for r in range(1, len(iterable)+1))

def worker_function(info):
    print(info[:-1])
    print(info[-1])
    subprocess.run(info[-1], shell=True)

def run_packetq(sql):
    outputs = []
    sqls = sql.split(';')
    sqls = [sql.strip() for sql in sqls]

    for sql in sqls:
        cmd = os.path.join(ROOT_DIR, 'intent_parser', 'packetq')
        cmd += ' -s "' + sql + '"'
        output = subprocess.check_output(cmd, shell=True).strip().decode('utf-8')
        output = output.split('\n')
        outputs.extend(output)

    output = ';'.join(outputs)
    return output

def main(args):
    exp_dir = os.path.join(ROOT_DIR, args.output_dir)
    if not args.dry_run:
        os.makedirs(exp_dir, exist_ok=True)

    #metrics_powerset = list(powerset(metrics))
    #sketches_powerset = list(powerset(sketches))

    #metrics_powerset = [tuple(metrics), tuple(metrics[:-1])]
    if args.sql_input:
        queries = run_packetq(args.sql_input)
        queries_powerset = [queries]
    else:
        queries_powerset = [list(itertools.product(metrics, flowkeys)), list(itertools.product(metrics[:-1], flowkeys))]
    
    sketches_powerset = [tuple(sketches), tuple(sketches[:-1])]

    infos = []

    for sram in srams:
        for s_set in sketches_powerset:
            popens = []
            #for m_set in metrics_powerset:
            for q_idx, q_set in enumerate(queries_powerset):
                if args.sql_input:
                    output_dir = os.path.join(exp_dir, str(sram), '_'.join(s_set), str(q_idx))
                else:
                    m_set = sorted(list(set([q[0] for q in q_set])))
                    output_dir = os.path.join(exp_dir, str(sram), '_'.join(s_set), '_'.join(m_set))
                #output_dir = os.path.join(exp_dir, str(sram), '_'.join(s_set), '_'.join(m_set))
                output_file = os.path.join(output_dir, 'output.txt')
                if not args.dry_run:
                    os.makedirs(output_dir, exist_ok=True)

                cmd = 'python3 ' + os.path.join(script_dir, 'run.py')
                if args.sql_input:
                    cmd += ' --queries "' + str(q_set) + '"'
                else:
                    cmd += ' --queries "' + ';'.join([str(q) for q in q_set]) + '"'
                #cmd += ' --queries "' + ','.join(['(' + m + ',5tuple)' for m in m_set]) + '"'
                cmd += ' --sketches ' + ','.join(s_set)
                cmd += ' --resources level,row,width --total_sram ' + str(sram)
                cmd += ' --resource_modeler LinearModeler --profiler_config only_actual.ini --coverage_pickle_file actual.pkl'
                cmd += ' --deployment_output --output_dir ' + output_dir
                #cmd += ' --numbered_deployment_output'
                #cmd += ' --use_sketchovsky'
                cmd += ' > ' + output_file + ' 2>&1'

                if args.dry_run:
                    print(cmd)
                else:
                    infos.append((sram, s_set, q_set, cmd))

    if not args.dry_run:
        pool = multiprocessing.Pool(processes=multiprocessing.cpu_count()-1 or 1)
        pool.map(worker_function, infos)
        pool.close()
        pool.join()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--sql_input')
    parser.add_argument('--dry_run', action='store_true')
    parser.add_argument('--output_dir', required=True)
    args = parser.parse_args()
    main(args)
