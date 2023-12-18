from subprocess import check_output
import os
import signal
import traceback
import sys

def print_level(level, msg):
    logging_level = 5
    if  level <= logging_level:
        print(msg)

def get_pid(name):
    return check_output(["pidof", name])

try:
    print_level(0, "[kill run_switchd]")
    cmd = "ps -x | grep '/home/hnamkung/sketch_home/tofino_control_plane/cpp/SketchMD/sketch'" 
    x = check_output(cmd, shell=True)
    print_level(2, cmd)
    split = x.split('\n')
    pid_list = [] 
    for line in split:
        if "grep" in line:
            print_level(2, "[X] " + line)
        elif len(line) != 0:
            print_level(2, "[O] " + line)
            stripped = line.strip()
            pid_string = stripped.split(' ')[0]
            pid_list.append(int(pid_string))

    print_level(2, "pid list - " + str(pid_list))
    for pid in pid_list:
        print_level(2, pid)
        os.kill(int(pid), signal.SIGKILL)
    print_level(0, "[kill success] %d" % (len(pid_list)-1))
except:
    print_level(0, "[kill run_switchd fail]")
    traceback.print_exc()
