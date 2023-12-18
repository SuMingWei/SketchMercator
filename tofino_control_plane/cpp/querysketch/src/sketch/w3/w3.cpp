#include "w3.h"

extern std::shared_ptr<bfrt::BfRtSession> session;
extern int isPrint;

W3::W3()
{
}

void W3::init(parameters &params)
{
    cout << "[CPP] [W3] init" << endl;
    cout << params.program_name << endl;
    Connection::init(params);
}

void W3::table_init(parameters &params)
{
    cout << "[CPP] [W3] table init" << endl;

    if (strcmp(params.before_after, "before") == 0) {
        params.d_count = 10;
        params.resource_param_vec.push_back({0, 0, 0, 0, 0, 0, 0});

        params.resource_param_vec.push_back({1,  1, 16384,  0, NORMAL_TYPE, 0, 1});  // 1 epoch 30
        params.resource_param_vec.push_back({2,  1, 4096,   0, NORMAL_TYPE, 0, 1});  // 2 epoch 30
        params.resource_param_vec.push_back({3,  1, 16384,  0, NORMAL_TYPE, 0, 1});  // 3 epoch 30
        params.resource_param_vec.push_back({4,  3, 32768,  0, NORMAL_TYPE, 2, 3});  // 4 epoch 30
        params.resource_param_vec.push_back({5,  4, 32768,  0, NORMAL_TYPE, 2, 4});  // 5 epoch 30
        params.resource_param_vec.push_back({6,  1, 8192,   0, NORMAL_TYPE, 0, 1});  // 6 epoch 30
        params.resource_param_vec.push_back({7,  2, 16384,  0, NORMAL_TYPE, 0, 2});  // 7 epoch 30
        params.resource_param_vec.push_back({8,  3, 131072, 0, NORMAL_TYPE, 0, 3});  // 8 epoch 30
        params.resource_param_vec.push_back({9,  1, 131072, 0, NORMAL_TYPE, 0, 1});  // 9 epoch 30
        params.resource_param_vec.push_back({10, 5, 4096,   0, NORMAL_TYPE, 0, 5});  //10 epoch 30

    }
    else {
        params.d_count = 9;
        params.resource_param_vec.push_back({0, 0, 0, 0, 0, 0, 0});

        params.resource_param_vec.push_back({1,  1, 16384,  0, NORMAL_TYPE, 0, 1});  // 1 epoch 30


        params.resource_param_vec.push_back({2,  1, 4096,   0, NORMAL_TYPE, 0, 1});  // 2 epoch 30


        params.resource_param_vec.push_back({4,  3, 32768,  32768, O2B_TYPE_FIRST, 0, 1});  // 4 epoch 30
        params.resource_param_vec.push_back({4,  1, 32768,  0, O2B_TYPE_SECOND, 0, 1});  // 3 epoch 30


        params.resource_param_vec.push_back({5,  4, 32768,  0, NORMAL_TYPE, 0, 4});  // 5 epoch 30


        params.resource_param_vec.push_back({7,  2, 16384,  16384, O2B_TYPE_FIRST, 0, 1});  // 7 epoch 30
        params.resource_param_vec.push_back({7,  1, 16384,   0, O2B_TYPE_SECOND, 0, 1});  // 6 epoch 30


        params.resource_param_vec.push_back({8,  3, 131072, 0, NORMAL_TYPE, 0, 3});  // 8 epoch 30
        // params.resource_param_vec.push_back({9,  1, 131072, 0, NORMAL_TYPE, 0, 1});  // 9 epoch 30

        params.resource_param_vec.push_back({10, 5, 4096,   0, NORMAL_TYPE, 0, 5});  //10 epoch 30

        params.after_hkey_count = 3;
        params.after_HT_SIZE = 16384;

    }

    Connection::table_init(params);

    cout << "[CPP] [W3] table_init done" << endl;
}

void W3::sketch_main_loop(parameters &params, int e_count)
{
    cout << "[CPP] [W3] sketch_main_loop " << e_count << endl;
    Connection::sketch_main_loop(params, e_count);

    if (strcmp(params.before_after, "before") == 0) {
        // int epoch_list [11] = { 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2};
        int epoch_list [11] = { 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3};
        for (int i=1; i<=10; i++) {
            params.read_signal_list[i] = params.reset_signal_list[i] = params.write_signal_list[i] = (e_count % epoch_list[i] == 0) ? 1 : 0;
        }
    }

    else {
        int epoch_list [10] = { 0, 3, 3, 3, 3, 3, 3, 3, 3, 3};

        for (int i=1; i<=9; i++) {
            if (i == 1 || i == 2 || i == 5 || i == 8 || i == 9) {
                params.read_signal_list[i] = params.reset_signal_list[i] = params.write_signal_list[i] = (e_count % epoch_list[i] == 0) ? 1 : 0;
            }
            else {
                params.write_signal_list[i] = (e_count % epoch_list[i] == 0) ? 1 : 0;
            }
        }
        params.read_signal_list[10] = params.reset_signal_list[10] = params.write_signal_list[10] = 1;

        params.read_signal_list[3] = (e_count % epoch_list[3] == 0) ? 1 : 0;
        params.reset_signal_list[3] = (e_count % epoch_list[3] == 0) ? RESET_BOTH : 0;


        params.read_signal_list[6] = (e_count % epoch_list[6] == 0) ? 1 : 0;
        params.reset_signal_list[6] = (e_count % epoch_list[6] == 0) ? RESET_BOTH : 0;


        params.read_signal_list[8] = (e_count % epoch_list[8] == 0) ? 1 : 0;
        params.reset_signal_list[8] = (e_count % epoch_list[8] == 0) ? RESET_BOTH : 0;
    }
    read_reset_start(params, e_count);
}

// void W3::test(parameters &params)
// {
//     cout << "[CPP] [W3] test " << endl;
//     Connection::test(params);
// }







        // params.read_signal_list[8] = params.reset_signal_list[8] = params.write_signal_list[8] = (e_count % epoch_list[8] == 0) ? 1 : 0;
        // params.read_signal_list[11] = params.reset_signal_list[11] = params.write_signal_list[11] = 1;


        // // read reset write for 6,7, 9,10

        // /* Read List */
        // params.read_signal_list[6] = 1;

        // if (e_count == 0 || e_count == 2 || e_count == 3 || e_count == 4 || e_count == 6) { // epoch 20 and 30
        //     params.read_signal_list[9] = 1;
        // }
        // else {
        //     params.read_signal_list[9] = 0;
        // }

        // /* Write List */
        // params.write_signal_list[6] = (e_count % epoch_list[6] == 0) ? 1 : 0;
        // params.write_signal_list[7] = (e_count % epoch_list[7] == 0) ? 1 : 0;
        // params.write_signal_list[9] = (e_count % epoch_list[9] == 0) ? 1 : 0;
        // params.write_signal_list[10] = (e_count % epoch_list[10] == 0) ? 1 : 0;

        // /* Reset List */
        // int reset_signal_matrix[11][7] = {
        //     {0, 0, 0, 0, 0, 0, 0},
        //     {1, 0, 0, 0, 0, 0, 0},
        //     {1, 0, 0, 0, 0, 0, 0},
        //     {1, 0, 0, 0, 0, 0, 0},
        //     {1, 0, 0, 0, 0, 0, 0},
        //     {1, 0, 0, 0, 0, 0, 0},

        //     {RESET_BOTH,             0,             0,             0, RESET_BOTH, RESET_BOTH, RESET_BOTH},
        //     {         0, RESET_ONLY_ME, RESET_ONLY_ME, RESET_ONLY_ME,          0,          0,          0},

        //     {1, 0, 0, 0, 0, 0, 0},

        //     {RESET_BOTH,             0,             0, RESET_ONLY_ME,             0, 0, RESET_BOTH},
        //     {         0,             0, RESET_ONLY_ME,             0, RESET_ONLY_ME, 0,          0},
        // };
        // params.reset_signal_list[6] = reset_signal_matrix[6][e_count];
        // params.reset_signal_list[7] = reset_signal_matrix[7][e_count];
        // params.reset_signal_list[9] = reset_signal_matrix[9][e_count];
        // params.reset_signal_list[10] = reset_signal_matrix[10][e_count];
