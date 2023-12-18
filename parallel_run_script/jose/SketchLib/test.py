import os

from env_setting.env_module import switch_compiler_path
from env_setting.env_module import result_resource_path
from env_setting.env_module import p4_repo_path

python_path = os.path.join(switch_compiler_path, "mapper", "parser", "p4-compile.py")
print(python_path)

output_path = os.path.join(result_resource_path, "SketchLib", "jose")
print(output_path)

p4_repo_path = os.path.join(p4_repo_path, "p414", "open", "sketches", "SketchLib")
print(p4_repo_path)

for sketch in ['03_UnivMon']:
    if sketch == '03_UnivMon':
        name_template = "p414_original_univmon_row_%02d_level_%02d"

    objective_str = 'maximumStage'
    name = name_template % (3, 4)

    final_output_path = os.path.join(output_path, sketch, objective_str)
    from python_lib.sys import hun_mkdir
    hun_mkdir(final_output_path)


    output = os.path.join(final_output_path, name+".txt")
    output_log = os.path.join(final_output_path, "log_" + name+".txt")

    p4_full_path = os.path.join(p4_repo_path, sketch, name, "%s.p4" % name)

    log_str = "%s %s" % (name, objective_str)
    cmd = 'python %s' % python_path
    cmd += ' -c RmtIlpCompiler-020'
    cmd += ' -p %s' % p4_full_path
    cmd += ' -s RmtTofino60'
    cmd += ' -r RmtPreprocess'
    cmd += ' --log_level DEBUG'
    cmd += ' --compiler_objectiveStr %s' % objective_str                    
    cmd += ' --output %s' % output
    cmd += ' --objective %s' % objective_str
    cmd += ' --compiler_relativeGap 0.2'
    cmd += ' > %s' % output_log
    print(cmd)
    os.system(cmd)
