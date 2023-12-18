#include "w2.h"

extern std::shared_ptr<bfrt::BfRtSession> session;
extern int isPrint;

W2::W2()
{
}

void W2::init(parameters &params)
{
    cout << "[CPP] [W2] init" << endl;
    cout << params.program_name << endl;
    Connection::init(params);
}

void W2::table_init(parameters &params)
{
    cout << "[CPP] [W2] table init" << endl;

    if (strcmp(params.before_after, "before") == 0) {
        params.d_count = 10;
        params.resource_param_vec.push_back({0, 0, 0, 0, 0, 0, 0});

        params.resource_param_vec.push_back({1,  3, 16384,  0, NORMAL_TYPE, 0, 3});  // 1 epoch 10
        params.resource_param_vec.push_back({2,  3, 16384,  0, NORMAL_TYPE, 2, 3});  // 2 epoch 10
        params.resource_param_vec.push_back({3,  1, 131072, 0, NORMAL_TYPE, 0, 1});  // 3 epoch 20
        params.resource_param_vec.push_back({4,  1, 16384,  0, NORMAL_TYPE, 0, 1});  // 4 epoch 20
        params.resource_param_vec.push_back({5,  3, 131072, 0, NORMAL_TYPE, 0, 3});  // 5 epoch 30

        params.resource_param_vec.push_back({6,  1, 262144, 0, NORMAL_TYPE, 0, 1});  // 6 epoch 30
        params.resource_param_vec.push_back({7,  4, 4096,   0, NORMAL_TYPE, 0, 4});  // 7 epoch 30
        params.resource_param_vec.push_back({8,  3, 4096,   0, NORMAL_TYPE, 2, 3});  // 8 epoch 30
        params.resource_param_vec.push_back({9,  1, 4096,   0, NORMAL_TYPE, 2, 1});  // 9 epoch 30
        params.resource_param_vec.push_back({10, 1, 16384,  0, NORMAL_TYPE, 0, 1});  //10 epoch 40
    }
    else {
        params.d_count = 9;
        params.resource_param_vec.push_back({0, 0, 0, 0, 0, 0, 0});

        params.resource_param_vec.push_back({1,  3, 16384,  0, O2B_TYPE_FIRST, 0, 3});  // 2 epoch 10
        params.resource_param_vec.push_back({1,  3, 16384,  0, O2B_TYPE_SECOND, 0, 3});  // 1 epoch 10

        params.resource_param_vec.push_back({3,  1, 131072, 0, NORMAL_TYPE, 0, 1});  // 3 epoch 20
        params.resource_param_vec.push_back({4,  1, 16384,  0, NORMAL_TYPE, 0, 1});  // 4 epoch 20
        params.resource_param_vec.push_back({5,  3, 131072, 0, NORMAL_TYPE, 0, 3});  // 5 epoch 30
        params.resource_param_vec.push_back({6,  1, 262144, 0, NORMAL_TYPE, 0, 1});  // 6 epoch 30

        params.resource_param_vec.push_back({7,  3, 4096,   0, O2B_TYPE_FIRST, 0, 3});  // 8 epoch 30
        params.resource_param_vec.push_back({7,  4, 4096,   4096, O2B_TYPE_SECOND, 0, 3});  // 7 epoch 30
        // params.resource_param_vec.push_back({9,  1, 4096,   0, NORMAL_TYPE, 0, 1});  // 9 epoch 30

        params.resource_param_vec.push_back({10, 1, 16384,  0, NORMAL_TYPE, 0, 1});  //10 epoch 40

        params.after_hkey_count = 2;
        params.after_HT_SIZE = 16384;

    }
    Connection::table_init(params);

    cout << "[CPP] [W2] table_init done" << endl;
}

void W2::sketch_main_loop(parameters &params, int e_count)
{
    cout << "[CPP] [W2] sketch_main_loop " << e_count << endl;
    Connection::sketch_main_loop(params, e_count);

    if (strcmp(params.before_after, "before") == 0) {
        int epoch_list [11] = { 0, 1, 1, 2, 2, 3, 3, 3, 3, 3, 4};
        for (int i=1; i<=10; i++) {
            params.read_signal_list[i] = params.reset_signal_list[i] = params.write_signal_list[i] = (e_count % epoch_list[i] == 0) ? 1 : 0;
        }
    }

    else {
        int epoch_list [10] = { 0, 1, 1, 2, 2, 3, 3, 3, 3, 4};

        for (int i=1; i<=9; i++) {
            if (i == 3 || i == 4 || i == 5 || i == 6 || i == 9) {
                params.read_signal_list[i] = params.reset_signal_list[i] = params.write_signal_list[i] = (e_count % epoch_list[i] == 0) ? 1 : 0;
            }
            else {
                params.write_signal_list[i] = (e_count % epoch_list[i] == 0) ? 1 : 0;
            }
        }
        params.read_signal_list[10] = params.reset_signal_list[10] = params.write_signal_list[10] = 1;

        params.read_signal_list[1] = (e_count % epoch_list[1] == 0) ? 1 : 0;
        params.reset_signal_list[1] = (e_count % epoch_list[1] == 0) ? RESET_BOTH : 0;

        params.read_signal_list[8] = (e_count % epoch_list[8] == 0) ? 1 : 0;
        params.reset_signal_list[8] = (e_count % epoch_list[8] == 0) ? RESET_BOTH : 0;

        // params.read_signal_list[8] = (e_count % epoch_list[8] == 0) ? 1 : 0;
        // params.reset_signal_list[8] = (e_count % epoch_list[8] == 0) ? RESET_BOTH : 0;
    }
    read_reset_start(params, e_count);
}

void W2::test(parameters &params)
{
    cout << "[CPP] [W2] test " << endl;
    Connection::test(params);
}
