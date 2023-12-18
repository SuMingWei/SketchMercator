#include "w4.h"

extern std::shared_ptr<bfrt::BfRtSession> session;
extern int isPrint;

W4::W4()
{
}

void W4::init(parameters &params)
{
    cout << "[CPP] [W4] init" << endl;
    cout << params.program_name << endl;
    Connection::init(params);
}

void W4::table_init(parameters &params)
{
    cout << "[CPP] [W4] table init" << endl;

    if (strcmp(params.before_after, "before") == 0) {
        params.d_count = 10;
        params.resource_param_vec.push_back({0, 0, 0, 0, 0, 0, 0});

        params.resource_param_vec.push_back({1,  1, 32768,  0, NORMAL_TYPE, 0, 1});  // 1 epoch 20
        params.resource_param_vec.push_back({2,  1, 131072, 0, NORMAL_TYPE, 0, 1});  // 2 epoch 30
        params.resource_param_vec.push_back({3,  1, 262144, 0, NORMAL_TYPE, 0, 1});  // 3 epoch 20
        params.resource_param_vec.push_back({4,  1, 4096,   0, NORMAL_TYPE, 0, 1});  // 4 epoch 10
        params.resource_param_vec.push_back({5,  1, 16384,  0, NORMAL_TYPE, 0, 1});  // 5 epoch 20

        params.resource_param_vec.push_back({6,  3, 8192,   0, NORMAL_TYPE, 0, 3});  // 6 epoch 30

        params.resource_param_vec.push_back({9,  1, 16384,  0, NORMAL_TYPE, 0, 1});  // 9 epoch 40
        params.resource_param_vec.push_back({10, 1, 8192,   0, NORMAL_TYPE, 0, 1});  //10 epoch 30

        params.resource_param_vec.push_back({7,  5, 4096,   0, NORMAL_TYPE, 0, 5});  // 7 epoch 30
        params.resource_param_vec.push_back({8,  3, 8192,   0, NORMAL_TYPE, 4, 3});  // 8 epoch 30
    }

    else {
        params.d_count = 10;
        params.resource_param_vec.push_back({0, 0, 0, 0, 0, 0, 0});

        params.resource_param_vec.push_back({1,  1, 32768,  0, NORMAL_TYPE, 0, 1});  // 1 epoch 20
        params.resource_param_vec.push_back({2,  1, 131072, 0, NORMAL_TYPE, 0, 1});  // 2 epoch 30
        params.resource_param_vec.push_back({3,  1, 262144, 0, NORMAL_TYPE, 0, 1});  // 3 epoch 20
        params.resource_param_vec.push_back({4,  1, 4096,   0, NORMAL_TYPE, 0, 1});  // 4 epoch 10
        params.resource_param_vec.push_back({5,  1, 16384,  0, NORMAL_TYPE, 0, 1});  // 5 epoch 20

        params.resource_param_vec.push_back({6,  3, 8192,   0, NORMAL_TYPE, 0, 3});  // 6 epoch 30

        params.resource_param_vec.push_back({9,  1, 16384, 0, NORMAL_TYPE, 0, 1});   // 9 epoch 40
        params.resource_param_vec.push_back({10, 1, 8192,  0, NORMAL_TYPE, 0, 1});   //10 epoch 30

        params.resource_param_vec.push_back({7,  3, 8192,   0,  O2B_TYPE_FIRST, 0, 3});   // 8 epoch 30
        params.resource_param_vec.push_back({7,  5, 8192,   4096,  O2B_TYPE_SECOND, 0, 3});   // 7 epoch 30

        params.after_hkey_count = 4;
        params.after_HT_SIZE = 8192;
    }

    Connection::table_init(params);

    cout << "[CPP] [W4] table_init done" << endl;
}

void W4::sketch_main_loop(parameters &params, int e_count)
{
    cout << "[CPP] [W4] sketch_main_loop " << e_count << endl;
    Connection::sketch_main_loop(params, e_count);

    if (strcmp(params.before_after, "before") == 0) {
        int epoch_list [11] = { 0, 2, 3, 2, 1, 2,   3, 4, 3, 3, 3};
        for (int i=1; i<=10; i++) {
            params.read_signal_list[i] = params.reset_signal_list[i] = params.write_signal_list[i] = (e_count % epoch_list[i] == 0) ? 1 : 0;
        }
    }

    else {
        int epoch_list [11] = { 0, 2, 3, 2, 1, 2,   3, 4, 3, 3, 3};

        for (int i=1; i<=10; i++) {
            if (i != 9 && i != 10) {
                params.read_signal_list[i] = params.reset_signal_list[i] = params.write_signal_list[i] = (e_count % epoch_list[i] == 0) ? 1 : 0;
            }
            else {
                params.write_signal_list[i] = (e_count % epoch_list[i] == 0) ? 1 : 0;
            }
        }
        params.read_signal_list[11] = params.reset_signal_list[11] = params.write_signal_list[11] = 1;

        params.read_signal_list[10] = (e_count % epoch_list[10] == 0) ? 1 : 0;
        params.reset_signal_list[10] = (e_count % epoch_list[10] == 0) ? RESET_BOTH : 0;

    }
    read_reset_start(params, e_count);
}

void W4::test(parameters &params)
{
    cout << "[CPP] [W4] test " << endl;
    Connection::test(params);
}
