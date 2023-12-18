#include "params.h"

void print_params(parameters &params)
{
    cout << "---- [print params] ----" << endl;
    cout << "[switch ip]    " << params.switch_ip << endl;
    cout << "[sketch_name]    " << params.sketch_name << endl;
    cout << "[test_name]    " << params.test_name << endl;
    cout << "[str_args_1]    " << params.str_args_1 << endl;
    // cout << "[is_simulator] " << params.is_simulator << endl;
    cout << "------------------------" << endl;
    cout << endl;

}
