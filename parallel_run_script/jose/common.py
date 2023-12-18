from data_helper.data_path_helper.jose_path_helper import jose_python_path

def jose_run_cmd(objective_str, p4_full_path, output, output_log, switch_target, gap):
    cmd = 'python2.7 %s' % jose_python_path
    cmd += ' -c RmtIlpCompiler-020'
    cmd += ' -p %s' % p4_full_path
    cmd += ' -s %s' % switch_target
    cmd += ' -r RmtPreprocess'
    cmd += ' --log_level DEBUG'
    cmd += ' --compiler_objectiveStr %s' % objective_str                    
    cmd += ' --output %s' % output
    cmd += ' --objective %s' % objective_str
    cmd += ' --compiler_relativeGap %f' % gap
    cmd += ' > %s' % output_log
    return cmd