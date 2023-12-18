#include "params.h"

void print_params(parameters &params)
{
    cout << "---- [print params] ----" << endl;
    cout << "[switch ip]        " << params.switch_ip << endl;
    cout << "[workload_name]    " << params.workload_name << endl;
    cout << "[program_name]     " << params.program_name << endl;
    cout << "[before_after]     " << params.before_after << endl;
    // cout << "[str_args_1]       " << params.str_args_1 << endl;
    // cout << "[is_simulator] " << params.is_simulator << endl;
    cout << "------------------------" << endl;
    cout << endl;

}
