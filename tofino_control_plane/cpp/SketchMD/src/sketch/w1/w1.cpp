#include "w1.h"


extern std::shared_ptr<bfrt::BfRtSession> session;
extern int isPrint;

W1::W1()
{
}

void W1::init(parameters &params)
{
    cout << "[CPP] [W1] init" << endl;
    cout << params.program_name << endl;
    Connection::init(params);
}

void W1::table_init(parameters &params)
{
    cout << "[CPP] [W1] table init" << endl;

    if (strcmp(params.before_after, "before") == 0) {
        params.d_count = 6;
        params.resource_param_vec.push_back({0, 0, 0, 0, 0,0, 0});
        params.resource_param_vec.push_back({1, 1, 16384,0,  NORMAL_TYPE, 1, 1});
        params.resource_param_vec.push_back({2, 5, 4096,0, NORMAL_TYPE, 1, 5});
        params.resource_param_vec.push_back({3, 2, 16384,0, NORMAL_TYPE, 2, 2});
        params.resource_param_vec.push_back({4, 5, 8192,0,  NORMAL_TYPE, 2, 5});
        params.resource_param_vec.push_back({5, 2, 4096,0,  NORMAL_TYPE, 2, 2});
        params.resource_param_vec.push_back({6, 5, 8192,0,  NORMAL_TYPE, 5, 5});
    }

    if (strcmp(params.before_after, "after") == 0) {
        params.d_count = 6;
        params.resource_param_vec.push_back({0, 0, 0, 0, 0,0, 0});
        params.resource_param_vec.push_back({1, 1, 16384,0,  NORMAL_TYPE, 0, 1});
        params.resource_param_vec.push_back({2, 5, 4096,0, NORMAL_TYPE, 0, 5});
        params.resource_param_vec.push_back({3, 2, 16384,0, NORMAL_TYPE, 0, 2});
        params.resource_param_vec.push_back({4, 5, 8192,0,  NORMAL_TYPE, 0, 5});
        params.resource_param_vec.push_back({5, 2, 4096,0,  NORMAL_TYPE, 0, 2});
        params.resource_param_vec.push_back({6, 5, 8192,0,  NORMAL_TYPE, 0, 5});

        params.after_hkey_count = 5;
        params.after_HT_SIZE = 32768;
    }

    Connection::table_init(params);

    cout << "[CPP] [W1] table_init done" << endl;
}

void W1::sketch_main_loop(parameters &params, int e_count)
{
    cout << "[CPP] [W1] sketch_main_loop " << e_count << endl;
    Connection::sketch_main_loop(params, e_count);

    int epoch_list [7] = {0, 4, 1, 3, 3, 2, 4};

    for(int i=1; i<=6; i++) {
        params.read_signal_list[i] = params.reset_signal_list[i] = params.write_signal_list[i] = (e_count % epoch_list[i] == 0) ? 1 : 0;
    }

    if (strcmp(params.before_after, "after") == 0) {
        params.read_signal_list[7] = params.reset_signal_list[7] = params.write_signal_list[7] = 1; // heavy flowkey in here
    }

    read_reset_start(params, e_count);
}
