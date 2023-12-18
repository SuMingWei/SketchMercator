import os
import argparse
import subprocess

from query_to_sketch.main_constants import ROOT_DIR

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
    print(run_packetq(args.s))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', required=True)
    args = parser.parse_args()
    main(args)
