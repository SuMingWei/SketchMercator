#include "connection.h"

std::shared_ptr<bfrt::BfRtSession> session;

static Timer read_reset_timer;
// int isPrint = 1;
int isPrint = 0;

static void get_file_path(parameters &params, char* file_path);
static void write_to_register_index_table(parameters &params, bf_rt_target_t &dev_tgt, int e_count);
void read_reset_start(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, void *cookie);
static void callback_single_row(const bf_rt_target_t &dev_tgt, void *cookie);
static void callback_mutiple_rows(const bf_rt_target_t &dev_tgt, void *cookie);
static void read_whole_single_row(parameters &params, bf_rt_target_t &dev_tgt, vector<int> &data1);
static void read_whole_multiple_rows(parameters &params, bf_rt_target_t &dev_tgt, vector<int> &data1, vector<int> &data2, vector<int> &data3, vector<int> &data4);
static void reset_whole_single_row(parameters &params, bf_rt_target_t &dev_tgt);
static void reset_whole_multiple_rows(parameters &params, bf_rt_target_t &dev_tgt);

static void bulk_reset_single_row(parameters &params, bf_rt_target_t &dev_tgt);
static void bulk_reset_multiple_rows(parameters &params, bf_rt_target_t &dev_tgt);

static void bulk_reset(parameters& params);

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

void Connection::table_init(parameters &params)
{
    cout << "[CPP] [Connection] table_init" << endl;

    char table_name[5000];
    sprintf(table_name, "SwitchIngress.epoch_count_1.cs_table");
    auto bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_index_table);
    assert(bf_status == BF_SUCCESS);
}

void Connection::sketch_main_loop(parameters &params, int e_count)
{
    read_reset_timer.start();
    if(isPrint)
        cout << "[CPP] [Connection] sketch_main_loop " << e_count << endl;
    params.e_count = e_count;

    // write e_count to register_index_table
    write_to_register_index_table(params, dev_tgt, e_count);

    if(strcmp(params.mode, "pingpong") == 0) {
        params.connection->setup_pingpong(params, e_count);
    }
    params.row = 1;
    read_reset_start(params.register_table_1, dev_tgt, &params);
}

void Connection::file_print_single_row(parameters &params, vector<int> &data1)
{
    if(isPrint)
        cout << "[CPP] [Connection] file_print_single_row" << endl;
    
    char file_path[5000];
    get_file_path(params, file_path);
    file_print_single_row_lib(file_path, params.array_size, data1);
}

void Connection::file_print_multiple_rows(parameters &params, vector<int> &data1, vector<int> &data2, vector<int> &data3, vector<int> &data4)
{
    if(isPrint)
        cout << "[CPP] [Connection] file_print_multiple_rows" << endl;
    
    char file_path[5000];
    get_file_path(params, file_path);
    file_print_multiple_rows_lib(file_path, params.array_size, data1, data2, data3, data4);
}

static void get_file_path(parameters &params, char* file_path)
{
    char dir_name[1000];
    sprintf(dir_name, "/home/hnamkung/sketch_home/result_tofino_dp/sketchAug/%s/%s/cpp/%05d/%02ds/%s/%s/%02d",
        params.sketch_name, params.mode, params.array_size, params.epoch, params.pcap_name, params.date, params.e_count);

    char cmd[1000];
    sprintf(cmd, "mkdir -p %s", dir_name);
    system(cmd);

    sprintf(file_path, "%s/result.txt", dir_name);
    printf("[CPP] [file path] %s\n", file_path);
}

void read_reset_start(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, void *cookie)
{
    bfrt::TableOperationsType type = bfrt::TableOperationsType::REGISTER_SYNC; // REGISTER_SYNC
    std::unique_ptr<bfrt::BfRtTableOperations> table_ops;
    auto bf_status = register_table->operationsAllocate(type, &table_ops);
    assert(bf_status == BF_SUCCESS);

    parameters &params = * (parameters *) cookie;
    if(isPrint)
        printf("[CPP] [bulk read] register %f %d row(%d)\n", read_reset_timer.lap(), params.array_size, params.row);

    if(params.multiple_rows == 0) {
        bf_status = table_ops->registerSyncSet(*session, dev_tgt, callback_single_row, cookie);
    }
    else {
        bf_status = table_ops->registerSyncSet(*session, dev_tgt, callback_mutiple_rows, cookie);
    }

    assert(bf_status == BF_SUCCESS);

    bf_status = register_table->tableOperationsExecute(*table_ops);
    assert(bf_status == BF_SUCCESS);
}

static void callback_single_row(const bf_rt_target_t &dev_tgt, void *cookie)
{
    parameters &params = * (parameters *) cookie;

    if(isPrint)
        printf("[CPP] [bulk read] callback %f mode(%s) epoch(%d) size(%d) \n", read_reset_timer.lap(), params.mode, params.epoch, params.array_size);

    int array_size = params.array_size;
    bf_rt_target_t dev_tgt_2 = dev_tgt;

    vector<int> data1;

    if (strcmp(params.mode, "baseline") == 0 || strcmp(params.mode, "pingpong") == 0) {
        read_whole_single_row(params, dev_tgt_2, data1);
        reset_whole_single_row(params, dev_tgt_2);
    }
    else if(strcmp(params.mode, "noreset") == 0) {
        read_whole_single_row(params, dev_tgt_2, data1);
    }
    else if(strcmp(params.mode, "sol3") == 0) {
        bulk_reset(params);
        read_whole_single_row(params, dev_tgt_2, data1);
    }
    else if(strcmp(params.mode, "sol3cpp") == 0) {
        bulk_reset_single_row(params, dev_tgt_2);
        read_whole_single_row(params, dev_tgt_2, data1);
    }


    /****** connection file print *****/
    params.connection->file_print_single_row(params, data1);
}

static void callback_mutiple_rows(const bf_rt_target_t &dev_tgt, void *cookie)
{
    parameters &params = * (parameters *) cookie;

    if(isPrint)
        printf("[CPP] [bulk read] callback %f mode(%s) epoch(%d) size(%d) row(%d) \n", read_reset_timer.lap(), params.mode, params.epoch, params.array_size, params.row);

    int row = params.row;
    int array_size = params.array_size;
    bf_rt_target_t dev_tgt_2 = dev_tgt;

    if(row < 4) {
        params.row = row+1;
        if (row == 1) {
            read_reset_start(params.register_table_2, dev_tgt_2, cookie);
        }
        else if (row == 2) {
            read_reset_start(params.register_table_3, dev_tgt_2, cookie);
        }
        else if (row == 3) {
            read_reset_start(params.register_table_4, dev_tgt_2, cookie);
        }
    }
    else if (row == 4) {
        auto flag = bfrt::BfRtTable::BfRtTableGetFlag::GET_FROM_SW;
        vector<int> data1;
        vector<int> data2;
        vector<int> data3;
        vector<int> data4;

        if (strcmp(params.mode, "baseline") == 0 || strcmp(params.mode, "pingpong") == 0) {
            read_whole_multiple_rows(params, dev_tgt_2, data1, data2, data3, data4);
            reset_whole_multiple_rows(params, dev_tgt_2);
        }
        else if(strcmp(params.mode, "noreset") == 0) {
            read_whole_multiple_rows(params, dev_tgt_2, data1, data2, data3, data4);
        }
        else if(strcmp(params.mode, "sol3") == 0) {
            bulk_reset(params);
            read_whole_multiple_rows(params, dev_tgt_2, data1, data2, data3, data4);
        }
        else if(strcmp(params.mode, "sol3cpp") == 0) {
            bulk_reset_multiple_rows(params, dev_tgt_2);
            read_whole_multiple_rows(params, dev_tgt_2, data1, data2, data3, data4);
        }

        /****** connection file print *****/
        params.connection->file_print_multiple_rows(params, data1, data2, data3, data4);
    }
}

static void write_to_register_index_table(parameters &params, bf_rt_target_t &dev_tgt, int e_count)
{
    const bfrt::BfRtTable *register_index_table = params.register_index_table;
    bf_rt_id_t reg_index_key_id;
    auto bf_status = register_index_table->keyFieldIdGet("$REGISTER_INDEX", &reg_index_key_id);
    assert(bf_status == BF_SUCCESS);
    char data_field_name[5000];
    sprintf(data_field_name, "SwitchIngress.epoch_count_1.cs_table.f1");
    write_point(register_index_table, dev_tgt, data_field_name, reg_index_key_id, 0, e_count);
}

static void read_whole_single_row(parameters &params, bf_rt_target_t &dev_tgt, vector<int> &data1)
{
    auto flag = bfrt::BfRtTable::BfRtTableGetFlag::GET_FROM_SW;
    read_whole(params.register_table_1, dev_tgt, flag, params.array_size, params.data_field_name_1, data1);

    double delay = read_reset_timer.lap();
    if(isPrint)
        printf("[CPP] [bulk read] [s row] [%s] read done - %f\n\n", params.mode, delay);
}

static void read_whole_multiple_rows(parameters &params, bf_rt_target_t &dev_tgt, vector<int> &data1, vector<int> &data2, vector<int> &data3, vector<int> &data4)
{
    auto flag = bfrt::BfRtTable::BfRtTableGetFlag::GET_FROM_SW;
    read_whole(params.register_table_1, dev_tgt, flag, params.array_size, params.data_field_name_1, data1);
    read_whole(params.register_table_2, dev_tgt, flag, params.array_size, params.data_field_name_2, data2);
    read_whole(params.register_table_3, dev_tgt, flag, params.array_size, params.data_field_name_3, data3);
    read_whole(params.register_table_4, dev_tgt, flag, params.array_size, params.data_field_name_4, data4);

    double delay = read_reset_timer.lap();
    if(isPrint)
        printf("[CPP] [bulk read] [m row] [%s] read done - %f\n\n", params.mode, delay);
}

static void reset_whole_single_row(parameters &params, bf_rt_target_t &dev_tgt)
{
    auto bf_status = session->beginTransaction(false);
    reset_whole(params.register_table_1, dev_tgt, params.array_size, params.data_field_name_1);
    bf_status = session->verifyTransaction();
    bf_status = session->sessionCompleteOperations();
    bf_status = session->commitTransaction(true);

    double delay = read_reset_timer.lap();
    if(isPrint)
        printf("[CPP] [bulk read] [s row] [%s] reset done - %f\n\n", params.mode, delay);
}

static void reset_whole_multiple_rows(parameters &params, bf_rt_target_t &dev_tgt)
{
    auto bf_status = session->beginTransaction(false);
    reset_whole(params.register_table_1, dev_tgt, params.array_size, params.data_field_name_1);
    reset_whole(params.register_table_2, dev_tgt, params.array_size, params.data_field_name_2);
    reset_whole(params.register_table_3, dev_tgt, params.array_size, params.data_field_name_3);
    reset_whole(params.register_table_4, dev_tgt, params.array_size, params.data_field_name_4);
    bf_status = session->verifyTransaction();
    bf_status = session->sessionCompleteOperations();
    bf_status = session->commitTransaction(true);
    
    double delay = read_reset_timer.lap();
    if(isPrint)
        printf("[CPP] [bulk read] [m row] [%s] reset done - %f\n\n", params.mode, delay);
}

static void bulk_reset_single_row(parameters &params, bf_rt_target_t &dev_tgt)
{
    auto bf_status = params.register_table_1->tableClear(*session, dev_tgt);
    assert(bf_status == BF_SUCCESS);

    double delay = read_reset_timer.lap();
    if(isPrint)
        printf("[CPP] [bulk read] [s row] [%s] reset done - %f\n\n", params.mode, delay);
}

static void bulk_reset_multiple_rows(parameters &params, bf_rt_target_t &dev_tgt)
{
    auto bf_status = params.register_table_1->tableClear(*session, dev_tgt);
    assert(bf_status == BF_SUCCESS);

    bf_status = params.register_table_2->tableClear(*session, dev_tgt);
    assert(bf_status == BF_SUCCESS);

    bf_status = params.register_table_3->tableClear(*session, dev_tgt);
    assert(bf_status == BF_SUCCESS);

    bf_status = params.register_table_4->tableClear(*session, dev_tgt);
    assert(bf_status == BF_SUCCESS);

    double delay = read_reset_timer.lap();
    if(isPrint)
        printf("[CPP] [bulk read] [s row] [%s] reset done - %f\n\n", params.mode, delay);
}
static void create_tcp_reset_msg(parameters& params, char* msg)
{
    sprintf(msg, "%s/reset/%d/%d/%s/cpp/%s", params.mode, params.epoch, params.array_size, params.pcap_name, params.date);
}

static void bulk_reset(parameters& params)
{
    if(isPrint)
        printf("[CPP] [bulk reset] [%s] %f \n", params.mode, read_reset_timer.lap());

    int PORT=10002;
    int sock = 0, valread;
    struct sockaddr_in serv_addr;
    char buffer[1024] = {0};
    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
        printf("\n Socket creation error \n");
        return;
    }
    
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);

    if(inet_pton(AF_INET, "10.81.1.32", &serv_addr.sin_addr)<=0)
    {
        printf("\nInvalid address/ Address not supported \n");
        return;
    }

    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0)
    {
        printf("\nConnection Failed \n");
        return;
    }
    char msg[1024];
    create_tcp_reset_msg(params, msg);
    if(isPrint)
        printf("[CPP] [bulk reset] [%s] %f send msg - %s\n", params.mode, read_reset_timer.lap(), msg);
    send(sock , msg , strlen(msg) , 0 );
    valread = read( sock , buffer, 1024);
    if(isPrint)
        printf("[CPP] [bulk reset] [%s] %f receive msg - %s\n", params.mode, read_reset_timer.lap(), buffer);
}
