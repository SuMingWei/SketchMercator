#include "connection.h"
// #define HT_SIZE 4096
#define HT_SIZE 8192

// #define HT_SIZE 16384

// #define HT_SIZE 4
// #define HT_SIZE 2

std::shared_ptr<bfrt::BfRtSession> session;

static Timer read_reset_timer;

int isPrint = 1;
// int isPrint = 0;

/* table init -> sketch main loop  -> read_reset_start */


/* table init */
void Connection::table_init(parameters &params)
{
    cout << "[CPP] [Connection] table_init" << endl;
    int i;

    char table_name[5000];
    sprintf(table_name, "SwitchIngress.epoch_count_1.cs_table");
    auto bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_index_table);
    assert(bf_status == BF_SUCCESS);
    if (strcmp(params.before_after, "before") == 0) {
        params.read_signal_list = vector<int>(params.d_count+1, 0);
        params.reset_signal_list = vector<int>(params.d_count+1, 0);
        params.write_signal_list = vector<int>(params.d_count+1, 0);
    }
    else {
        params.read_signal_list = vector<int>(params.d_count+2, 0);
        params.reset_signal_list = vector<int>(params.d_count+2, 0);
        params.write_signal_list = vector<int>(params.d_count+2, 0);
    }

    vector<const bfrt::BfRtTable *> table_vec0;
    params.table_list.push_back(table_vec0);

    vector<tuple<int, int, string, string>> info_vec0;
    params.info_list.push_back(info_vec0);

    for (int d=1; d<=params.d_count; d++) {
        int id = get<0>(params.resource_param_vec[d]);
        int row_count = get<1>(params.resource_param_vec[d]);
        int asize = get<2>(params.resource_param_vec[d]);
        int asize_2 = get<3>(params.resource_param_vec[d]);
        int type = get<4>(params.resource_param_vec[d]);
        int hkey_count = get<5>(params.resource_param_vec[d]);
        int type_limit = get<6>(params.resource_param_vec[d]);

        // printf("id(%d) row(%d) asize(%d) asize_2(%d) type(%d) hkey(%d) type_limit(%d) \n", id, row_count, asize, asize_2, type, hkey_count, type_limit);

        // info_vec init
        vector<tuple<int, int, string, string>> info_vec;
        info_vec.push_back({0, 0, " ", " "});

        // table_vec init
        vector<const bfrt::BfRtTable *> table_vec;
        table_vec.push_back(NULL);

        for(i=1; i<=row_count; i++)
            table_vec.push_back(NULL);

        for(i=1; i<=row_count; i++) {
            char table_name[1000];
            char data_field_name[1000];
            char counter_array_name[1000];
            sprintf(table_name, "SwitchIngress.update_%d_%d.ca", id, i);
            sprintf(data_field_name, "%s", table_name);
            sprintf(counter_array_name, "update_%d_%d", id, i);
            auto bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &table_vec[i]);
            assert(bf_status == BF_SUCCESS);
            if(i <= type_limit) {
                info_vec.push_back({asize, type, counter_array_name, data_field_name});
            }
            else {
                info_vec.push_back({asize_2, NORMAL_TYPE, counter_array_name, data_field_name});
            }
        }
        
        if (strcmp(params.before_after, "before") == 0) {
            for(i=1; i<=hkey_count; i++)
                table_vec.push_back(NULL);
            for(i=1; i<=hkey_count; i++) {
                char table_name[1000];
                char data_field_name[1000];
                char counter_array_name[1000];
                sprintf(table_name, "SwitchIngress.heavy_flowkey_storage_%d.key%d_hash_table", id, i);
                sprintf(data_field_name, "%s", table_name);
                sprintf(counter_array_name, "flowkey_%d_key%d", id, i);
                auto bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &table_vec[row_count+i]);
                assert(bf_status == BF_SUCCESS);

                info_vec.push_back({HT_SIZE, type, counter_array_name, data_field_name});
            }
        }
        params.table_list.push_back(table_vec);
        params.info_list.push_back(info_vec);
    }

    if (strcmp(params.before_after, "after") == 0) {
        // info_vec init
        vector<tuple<int, int, string, string>> info_vec;
        info_vec.push_back({0, 0, " ", " "});

        // table_vec init
        vector<const bfrt::BfRtTable *> table_vec;
        table_vec.push_back(NULL);

        for(i=1; i<=params.after_hkey_count; i++)
            table_vec.push_back(NULL);

        for(i=1; i<=params.after_hkey_count; i++) {
            char table_name[1000];
            char data_field_name[1000];
            char counter_array_name[1000];
            sprintf(table_name, "SwitchIngress.heavy_flowkey_storage.key%d_hash_table", i);
            sprintf(data_field_name, "%s", table_name);
            sprintf(counter_array_name, "flowkey_key%d", i);
            auto bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &table_vec[i]);
            assert(bf_status == BF_SUCCESS);

            info_vec.push_back({params.after_HT_SIZE, NORMAL_TYPE, counter_array_name, data_field_name});
        }

        params.table_list.push_back(table_vec);
        params.info_list.push_back(info_vec);
    }
}


/* sketch main loop */
static void write_to_register_index_table(parameters &params, bf_rt_target_t &dev_tgt, int e_count)
{
    const bfrt::BfRtTable *register_index_table = params.register_index_table;
    bf_rt_id_t reg_index_key_id;
    auto bf_status = register_index_table->keyFieldIdGet("$REGISTER_INDEX", &reg_index_key_id);
    assert(bf_status == BF_SUCCESS);
    char data_field_name[5000];
    sprintf(data_field_name, "SwitchIngress.epoch_count_1.cs_table.f1");
    write_point(register_index_table, dev_tgt, data_field_name, reg_index_key_id, 0, e_count+1);
}


void Connection::sketch_main_loop(parameters &params, int e_count)
{
    printf("[CPP] [Connection] -------------- sketch_main_loop (%d) --------------\n", e_count);

    read_reset_timer.start();

    // write e_count to register_index_table
    write_to_register_index_table(params, dev_tgt, e_count);

    read_reset_timer.start();
    if(isPrint) {
        pair<double, double> p = read_reset_timer.lap();
        printf("[CPP] [Timer] %8.2f ms (%8.2f ms) | epoch register write \n", p.first, p.second);
    }
}



/* read_reset_start -> read/reset/write */
static void callback_main(const bf_rt_target_t &dev_tgt, void *cookie);
void callback_ready(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, void *cookie);

void callback_ready(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, void *cookie)
{
    bfrt::TableOperationsType type = bfrt::TableOperationsType::REGISTER_SYNC; // REGISTER_SYNC
    std::unique_ptr<bfrt::BfRtTableOperations> table_ops;
    auto bf_status = register_table->operationsAllocate(type, &table_ops);
    assert(bf_status == BF_SUCCESS);

    parameters &params = * (parameters *) cookie;

    bf_status = table_ops->registerSyncSet(*session, dev_tgt, callback_main, cookie);
    assert(bf_status == BF_SUCCESS);

    bf_status = register_table->tableOperationsExecute(*table_ops);
    assert(bf_status == BF_SUCCESS);
}

static void callback_main(const bf_rt_target_t &dev_tgt, void *cookie)
{
    // if(isPrint)
    //     printf("[CPP] [Connection] callback_main \n");
    parameters &params = * (parameters *) cookie;

    int row = params.row;
    params.row = params.row + 1;

    bf_rt_target_t dev_tgt_2 = dev_tgt;

    int sum1=0, sum2=0;
    int i, j, k;
    for(int i=1; i<=params.read_signal_list.size()-1; i++) {
        if (params.read_signal_list[i] == 1) {
            sum1 += params.table_list[i].size()-1;
        }
    }
    if (row <= sum1) {
        for(i=1; i<=params.read_signal_list.size()-1; i++) {
            if (params.read_signal_list[i] == 1) {
                j = row - sum2;
                sum2 += params.table_list[i].size()-1;
                if(row <= sum2) {
                    break;
                }
            }
        }
        if(isPrint) {
            pair<double, double> p = read_reset_timer.lap();
            printf("[CPP] [Connection] %8.2f ms (%8.2f ms) | read register call %d %d \n", p.first, p.second, i, j);
        }
        callback_ready(params.table_list[i][j], dev_tgt_2, &params);

    } else if (row > sum1) {
        if(isPrint) {
            pair<double, double> p = read_reset_timer.lap();
            printf("[CPP] [Connection] %8.2f ms (%8.2f ms) | read done \n\n", p.first, p.second);
        }

        printf("[CPP] [Connection] reset start \n");
        int type;
        int asize;
        string aname;
        string data_field;
        int reset_type;

        for(i=1; i<=params.reset_signal_list.size()-1; i++) {
            reset_type = params.reset_signal_list[i];
            if (reset_type > 0) {
                for(j=1; j<=params.table_list[i].size()-1; j++) {
                    asize = get<0>(params.info_list[i][j]);
                    type = get<1>(params.info_list[i][j]);
                    aname = get<2>(params.info_list[i][j]);
                    data_field = get<3>(params.info_list[i][j]);
                    // cout << i << " " << j << " " << reset_type << " " << asize << " " << type << " " << aname << " " << data_field << endl;

                    if(type == NORMAL_TYPE || reset_type == RESET_YES || reset_type == RESET_BOTH) {
                        auto bf_status = params.table_list[i][j]->tableClear(*session, dev_tgt_2);
                        assert(bf_status == BF_SUCCESS);
                        if(isPrint) {
                            pair<double, double> p = read_reset_timer.lap();
                            if(type == NORMAL_TYPE) {
                                printf("[CPP] [Connection] %8.2f ms (%8.2f ms) | reset register type (normal)       %s \n", p.first, p.second, data_field.c_str());
                            } else if (reset_type == RESET_BOTH) {
                                printf("[CPP] [Connection] %8.2f ms (%8.2f ms) | reset register type (first,second) %s \n", p.first, p.second, data_field.c_str());
                            } else if(reset_type == RESET_YES) {
                                printf("[CPP] [Connection] %8.2f ms (%8.2f ms) | reset register type (error)           %s\n", p.first, p.second, data_field.c_str());
                            }
                        }
                    }
                    else {
                        if (reset_type != RESET_ONLY_ME) {
                            printf("SOMETHING WRONG! - (reset_type != RESET_ONLY_ME)\n");
                        }

                        bf_rt_id_t reg_index_key_id;
                        auto bf_status = params.table_list[i][j]->keyFieldIdGet("$REGISTER_INDEX", &reg_index_key_id);
                        assert(bf_status == BF_SUCCESS);
                        auto flag = bfrt::BfRtTable::BfRtTableGetFlag::GET_FROM_SW;

                        char data_field_name1[5000];
                        char data_field_name2[5000];
                        if(type == O2B_TYPE_FIRST) {
                            sprintf(data_field_name1, "%s.first", data_field.c_str());
                            sprintf(data_field_name2, "%s.second", data_field.c_str());
                        }
                        else {
                            sprintf(data_field_name1, "%s.second", data_field.c_str());
                            sprintf(data_field_name2, "%s.first", data_field.c_str());
                        }

                        bf_status = session->beginTransaction(false);
                        vector<int> data1;
                        uint64_t value1, value2;
                        for (uint64_t key = 0; key < asize; key++) {
                            value1 = read_point(params.table_list[i][j], dev_tgt_2, data_field_name1, reg_index_key_id, key, flag);
                            value2 = read_point(params.table_list[i][j], dev_tgt_2, data_field_name2, reg_index_key_id, key, flag);
                            data1.push_back(value1);
                            if(type == O2B_TYPE_FIRST) {
                                write_point_two(params.table_list[i][j], dev_tgt_2, (char *)data_field.c_str(), reg_index_key_id, key, 0, value2);
                            }
                            else {
                                write_point_two(params.table_list[i][j], dev_tgt_2, (char *)data_field.c_str(), reg_index_key_id, key, value2, 0);
                            }
                        }
                        bf_status = session->verifyTransaction();
                        bf_status = session->sessionCompleteOperations();
                        bf_status = session->commitTransaction(true);



                        params.cache_map.insert(make_pair(make_pair(i, j), data1));

                        if(isPrint) {
                            pair<double, double> p = read_reset_timer.lap();
                            if (type==O2B_TYPE_FIRST) {
                                printf("[CPP] [Connection] %8.2f ms (%8.2f ms) | reset only me (first) done %s \n", p.first, p.second, data_field.c_str());
                            } else {
                                printf("[CPP] [Connection] %8.2f ms (%8.2f ms) | reset only me (second) done %s \n", p.first, p.second, data_field.c_str());
                            }
                        }
                    }
                }
            }
        }

        printf("[CPP] [Connection] reset done \n\n");

        // then read
        printf("[CPP] [Connection] write start \n");

        for(i=1; i<=params.write_signal_list.size()-1; i++) {
            if (params.write_signal_list[i] == 1) {
                for(j=1; j<=params.table_list[i].size()-1; j++) {
                    asize = get<0>(params.info_list[i][j]);
                    type = get<1>(params.info_list[i][j]);
                    aname = get<2>(params.info_list[i][j]);
                    data_field = get<3>(params.info_list[i][j]);
                    
                    vector<int> data;
                    char data_field_name[5000];
                    if(type == NORMAL_TYPE) {
                        sprintf(data_field_name, "%s.f1", data_field.c_str());
                    }
                    else {
                        if(type == O2B_TYPE_FIRST) {
                            sprintf(data_field_name, "%s.first", data_field.c_str());
                        }
                        else {
                            sprintf(data_field_name, "%s.second", data_field.c_str());
                        }
                    }

                    if (params.cache_map.find(make_pair(i, j)) == params.cache_map.end()) {
                        // cout << i << " " << j << " " << asize << " " << type << " " << aname << " " << data_field << endl;
                        bf_rt_id_t reg_index_key_id;
                        auto bf_status = params.table_list[i][j]->keyFieldIdGet("$REGISTER_INDEX", &reg_index_key_id);
                        assert(bf_status == BF_SUCCESS);

                        auto flag = bfrt::BfRtTable::BfRtTableGetFlag::GET_FROM_SW;

                        bf_status = session->beginTransaction(false);

                        uint64_t value;
                        // cout << "asize: " << asize << endl;
                        for (uint64_t key = 0; key < asize; key++) {
                            value = read_point(params.table_list[i][j], dev_tgt_2, data_field_name, reg_index_key_id, key, flag);
                            data.push_back(value);
                        }
                        bf_status = session->verifyTransaction();
                        bf_status = session->sessionCompleteOperations();
                        bf_status = session->commitTransaction(true);
                    }
                    else {
                        data = params.cache_map[make_pair(i, j)];
                        printf("Data found in cache! (%d, %d)\n", i, j);
                    }

                    // if (isPrint) {
                    //     pair<double, double> p = read_reset_timer.lap();
                    //     printf("[CPP] [Connection] %8.2f ms (%8.2f ms) | register  read %d %d %d %d %s %s \n", p.first, p.second, i, j, asize, type, aname.c_str(), data_field_name);
                    // }
                    char dir_name[1000];
                    if (strcmp(params.before_after, "before") == 0) {
                        sprintf(dir_name, "/home/hnamkung/sketch_home/result_tofino_dp/sketchMD/%s/%s/%s/%s/%s/%d",
                            params.workload_name, params.program_name, params.pcap_name, params.date, aname.c_str(), params.e_count);
                    }
                    else {
                        sprintf(dir_name, "/home/hnamkung/sketch_home/result_tofino_dp/sketchMD/%s/%s/%s/%s/%s/type_%d/%d",
                            params.workload_name, params.program_name, params.pcap_name, params.date, aname.c_str(), type, params.e_count);
                    }
                    // cout << dir_name << endl;

                    char cmd[1000];
                    sprintf(cmd, "mkdir -p %s", dir_name);
                    system(cmd);

                    char file_path[1000];
                    sprintf(file_path, "%s/result.txt", dir_name);
                    // printf("[CPP] [file path] %s\n", file_path);

                    FILE * f = fopen(file_path, "w");
                    for (auto& d : data) {
                        fprintf(f, "%d\n", d);
                    }
                    fclose(f);
                    if (isPrint) {
                        pair<double, double> p = read_reset_timer.lap();
                        printf("[CPP] [Connection] %8.2f ms (%8.2f ms) | register write %d %d %d %d %s %s \n", p.first, p.second, i, j, asize, type, aname.c_str(), data_field_name);
                        // cout << data.size() << endl;
                    }
                }
            }
        }
        pair<double, double> p = read_reset_timer.lap();
        printf("[CPP] [Connection] %8.2f ms (%8.2f ms) | write done \n", p.first, p.second);
    }
}

void Connection::read_reset_start(parameters &params, int e_count)
{
    cout << "[CPP] [Connection] read start" << endl;

    printf("read_signal_list  (epoch: %d) ", e_count);
    for(int i=1; i<=params.read_signal_list.size()-1; i++) {
        cout << params.read_signal_list[i] << " ";
    }
    cout << endl;

    printf("reset_signal_list (epoch: %d) ", e_count);
    for(int i=1; i<=params.reset_signal_list.size()-1; i++) {
        cout << params.reset_signal_list[i] << " ";
    }
    cout << endl;

    printf("write_signal_list (epoch: %d) ", e_count);
    for(int i=1; i<=params.write_signal_list.size()-1; i++) {
        cout << params.write_signal_list[i] << " ";
    }
    cout << endl;

    params.row = 1;
    params.e_count = e_count;
    params.cache_map.clear();
    callback_main(dev_tgt, &params);
    // for(int i=1; i<=params.read_signal_list.size()-1; i++) {
    //     if (params.read_signal_list[i] == 1) {
    //         callback_ready(params.table_list[i][1], dev_tgt, &params);
    //         break;
    //     }
    // }
}

/* test */
void Connection::test(parameters &params)
{
    cout << "[CPP] [Connection] test" << endl;

    int type;
    int asize;
    string aname;
    string data_field;
    int i = 4;
    int j = 1;
    int k;


    asize = get<0>(params.info_list[i][j]);
    type = get<1>(params.info_list[i][j]);
    aname = get<2>(params.info_list[i][j]);
    data_field = get<3>(params.info_list[i][j]);

    if(type == NORMAL_TYPE) {
        auto bf_status = params.table_list[i][j]->tableClear(*session, dev_tgt);
        assert(bf_status == BF_SUCCESS);
        if(isPrint)
            cout << i << " " << j << " table reset" << endl;
    }
    else {
        bf_rt_id_t reg_index_key_id;
        auto bf_status = params.table_list[i][j]->keyFieldIdGet("$REGISTER_INDEX", &reg_index_key_id);
        assert(bf_status == BF_SUCCESS);
        cout << i << " " << j << " reset first " << data_field << endl;
        char data_field_name_first[5000];
        char data_field_name_second[5000];
        sprintf(data_field_name_first, "%s.first", data_field.c_str());
        sprintf(data_field_name_second, "%s.second", data_field.c_str());

        cout << data_field_name_first << endl;
        cout << data_field_name_second << endl;

        // bf_status = session->beginTransaction(false);
        
        // write_point(params.table_list[i][j], dev_tgt, data_field_name_first, reg_index_key_id, 0, 100);
        // write_point(params.table_list[i][j], dev_tgt, data_field_name_second, reg_index_key_id, 0, 200);

        write_point_two(params.table_list[i][j], dev_tgt, (char *)data_field.c_str(), reg_index_key_id, 0, 100, 200);

        // for(k=0; k<asize; k++) {
        //     write_point(params.table_list[i][j], dev_tgt, data_field_name_first, reg_index_key_id, k, 100);
        //     write_point(params.table_list[i][j], dev_tgt, data_field_name_second, reg_index_key_id, k, 200);
        // }

        // bf_status = session->verifyTransaction();
        // bf_status = session->sessionCompleteOperations();
        // bf_status = session->commitTransaction(true);
    }
}

/* init */
void Connection::init(parameters &params)
{
    cout << "[CPP] [Connection] init" << endl;
    cout << params.program_name << endl;

	dev_tgt.dev_id = 0;
	dev_tgt.pipe_id = ALL_PIPES;
    bf_switchd_context_t *switchd_main_ctx = NULL;
    char install_dir[5000];
    char target_conf_file[5000];
    bf_status_t bf_status;
    // install_dir = getenv("SDE_INSTALL");
    sprintf(install_dir, "/root/bf-sde-9.1.1/install");
    cout << params.program_name << endl;
    sprintf(target_conf_file, "%s/share/p4/targets/tofino/%s.conf", install_dir, params.program_name);
    cout << target_conf_file << endl;

    /* Allocate memory to hold switchd configuration and state */
    if ((switchd_main_ctx = (bf_switchd_context_t *)calloc(1, sizeof(bf_switchd_context_t))) == NULL) {
        printf("ERROR: Failed to allocate memory for switchd context\n");
        return;
    }

    memset(switchd_main_ctx, 0, sizeof(bf_switchd_context_t));
    switchd_main_ctx->install_dir = install_dir;
    switchd_main_ctx->conf_file = target_conf_file;
    switchd_main_ctx->skip_p4 = false;
    switchd_main_ctx->skip_port_add = false;
    switchd_main_ctx->running_in_background = false; 
    switchd_main_ctx->dev_sts_thread = true;
    switchd_main_ctx->dev_sts_port = THRIFT_PORT_NUM;

    bf_status = bf_switchd_lib_init(switchd_main_ctx);
    printf("Initialized bf_switchd, status = %d\n", bf_status);
    printf("bf_switchd_lib_init done\n");

    // Get devMgr singleton instance
    auto &devMgr = bfrt::BfRtDevMgr::getInstance();

    fprintf(stderr, "%s\n", params.program_name);
    // Get bfrtInfo object from dev_id and p4 program name
    bf_status = devMgr.bfRtInfoGet(dev_tgt.dev_id, params.program_name, &bfrtInfo);

    // Create a session object
    session = bfrt::BfRtSession::sessionCreate();
    g_switch_ip = htonl(params.switch_ip);

    if (bf_pkt_alloc(dev_tgt.dev_id, &tx_pkt, 1500, BF_DMA_CPU_PKT_TRANSMIT_0) != 0)
    {
        fprintf(stderr, "Failed to allocate packet buffer\n");
        return;
    }

    // callbackRegister();
    printf("Bfrt setup done! status = %d \n", bf_status);
}