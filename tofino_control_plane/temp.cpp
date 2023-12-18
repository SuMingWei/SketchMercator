#ifndef SKETCH_MRB
#define SKETCH_MRB

#include <vector>
#include <iostream>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdint.h>
#include <sched.h>
#include <string.h>
#include <time.h>
#include <assert.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pthread.h>
#include <unistd.h>
#include <pcap.h>
#include <arpa/inet.h>

#include "common/connection.h"
#include "bf_library/register.h"
#include "library/params.h"
#include "library/timer.h"
#include "library/com.h"

using namespace std;

class MRB : public Connection {
public:
    MRB();

    virtual void init(parameters &params);
    virtual void test(parameters &params);
};

#endif // SKETCH_MRB

#include "mrb.h"

extern std::shared_ptr<bfrt::BfRtSession> session;

struct cookie_parameters
{
    int array_size;
    int counter_size;
    const bfrt::BfRtTable *register_table;
    int logging;
    int epoch;
    int e_count;
};

MRB::MRB()
{
}

static Timer bulk_read_timer;
static Timer individual_reset_timer;

static int isPrint = 1;
// static int isPrint = 0;
static void reset_individual(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, int array_size);

void MRB::init(parameters &params)
{
    cout << "MRB init" << endl;
    sprintf(params.program_name, "p416_mrb");
    cout << params.program_name << endl;

    Connection::init(params);
}

static void file_print(char* file_path, int array_size, vector<int> &data)
{
    FILE * f = fopen(file_path, "w");
    int count = 0;
    for (auto& d : data) {
        fprintf(f, "%d\n", d);
        // if (d != 0) {
        //     fprintf(f, "%d %d\n", count, d);
        //     // printf("%d %d\n", count, d);
        // }
        count += 1;
    }
    fclose(f);
}

static void read(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, uint64_t key, auto flag, int array_size, vector<int> &data)
{
    bf_rt_id_t reg_index_key_id;
    auto bf_status = register_table->keyFieldIdGet("$REGISTER_INDEX", &reg_index_key_id);
    assert(bf_status == BF_SUCCESS);

    uint64_t value;
    char data_field_name[5000];
    sprintf(data_field_name, "SwitchIngress.update_%d.cs_table.f1", array_size);
    value = read_point(register_table, dev_tgt, data_field_name, reg_index_key_id, key, flag);
    data.push_back(value);
    if(isPrint) {
        // if (value != 0)
        //     printf("(%d %d)\n", key, value);
    }
}

static void callback(const bf_rt_target_t &dev_tgt, void *cookie) {
    if(isPrint)
        printf("[bulk read] callback %f\n", bulk_read_timer.lap());

    cookie_parameters params = * (cookie_parameters *) cookie;

    auto flag = bfrt::BfRtTable::BfRtTableGetFlag::GET_FROM_SW;
    vector<int> data;
    bf_rt_target_t dev_tgt_2 = dev_tgt;
    int array_size;
    array_size = params.array_size;
    const bfrt::BfRtTable *register_table = params.register_table;
    for (uint64_t key = 0; key < array_size; key++) {
        read(register_table, dev_tgt_2, key, flag, array_size, data);
    }

    double delay = bulk_read_timer.lap();
    printf("[bulk read] done - %f\n\n", delay);

    if (isPrint) {
        printf("[reset] start\n");
    }
    individual_reset_timer.start();
    auto bf_status = session->beginTransaction(false);
    reset_individual(register_table, dev_tgt_2, array_size);
    bf_status = session->verifyTransaction();
    bf_status = session->sessionCompleteOperations();
    bf_status = session->commitTransaction(true);
    delay = individual_reset_timer.lap();
    if (isPrint) {
        printf("[reset] done - %f\n\n", delay);
    }

    char cmd[1000];
    char dir_name[1000];
    sprintf(dir_name, "/home/hnamkung/sketch_home/result_tofino_dp/sketchAug/mrb/cpp/%05d/%02ds/%02d", params.array_size, params.epoch, params.e_count);
    sprintf(cmd, "mkdir -p %s", dir_name);
    system(cmd);

    char file_path[5000];
    sprintf(file_path, "%s/result.txt", dir_name);

    printf("[file path] %s\n", file_path);
    file_print(file_path, array_size, data);
}

static void read_bulk(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, int array_size, cookie_parameters &cookie_params)
{
    bulk_read_timer.start();
    bfrt::TableOperationsType type = bfrt::TableOperationsType::REGISTER_SYNC; // REGISTER_SYNC
    std::unique_ptr<bfrt::BfRtTableOperations> table_ops;
    auto bf_status = register_table->operationsAllocate(type, &table_ops);
    assert(bf_status == BF_SUCCESS);

    void *cookie = &cookie_params;
    if(isPrint) {
        printf("[bulk read] register %f %d\n", bulk_read_timer.lap(), cookie_params.array_size);
    }
    bf_status = table_ops->registerSyncSet(*session, dev_tgt, callback, cookie);
    assert(bf_status == BF_SUCCESS);

    bf_status = register_table->tableOperationsExecute(*table_ops);
    assert(bf_status == BF_SUCCESS);
}


void MRB::test(parameters &params)
{
    cout << "mrb test" << endl;
    cout << params.test_type << endl;

    parse_msg(params);

    int epoch = params.epoch;
    int array_size = params.size;

    cout << "epoch: " << epoch << endl;
    cout << "size: " << array_size << endl;


    vector<int> array_size_vector;

    cookie_parameters cookie_params;

    char table_name[5000];

    const bfrt::BfRtTable *register_table = nullptr;
    sprintf(table_name, "SwitchIngress.update_%d.cs_table", array_size);
    auto bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &register_table);
    assert(bf_status == BF_SUCCESS);

    const bfrt::BfRtTable *register_index_table = nullptr;
    sprintf(table_name, "SwitchIngress.epoch_count_1.cs_table");
    bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &register_index_table);
    assert(bf_status == BF_SUCCESS);


    cout << "wait for 1 sec" << endl;
    usleep(626 * 1000); // 626ms
    sleep(1); // 1000ms
    
    Timer total_timer;
    Timer loop_timer;

    double ms_delay;
    

    total_timer.start();
    for(int e_count=0; e_count<=60/epoch; e_count++) {
        cout << e_count << " " << total_timer.lap() << endl;
        loop_timer.start();
        cookie_params.array_size = array_size;
        cookie_params.register_table = register_table;
        cookie_params.logging = 2;
        cookie_params.epoch = epoch;
        cookie_params.e_count = e_count;

        bf_rt_id_t reg_index_key_id;
        auto bf_status = register_index_table->keyFieldIdGet("$REGISTER_INDEX", &reg_index_key_id);
        assert(bf_status == BF_SUCCESS);

        char data_field_name[5000];
        sprintf(data_field_name, "SwitchIngress.epoch_count_1.cs_table.f1");

        write_point(register_index_table, dev_tgt, data_field_name, reg_index_key_id, 0, e_count+1);

        if(isPrint) {
            printf("[bulk read] start\n");
        }

        read_bulk(register_table, dev_tgt, array_size, cookie_params);

        ms_delay = loop_timer.lap();
        if (e_count == 60/epoch) {
            sleep(4);
        }
        else {
            usleep(epoch * 1000 * 1000 - ms_delay * 1000 - 110);
        }
        // break;
    }
}

static void reset_individual(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, int array_size)
{
    for (uint64_t key = 0; key < array_size; key++) {
        bf_rt_id_t reg_index_key_id;
        auto bf_status = register_table->keyFieldIdGet("$REGISTER_INDEX", &reg_index_key_id);
        assert(bf_status == BF_SUCCESS);

        char data_field_name[5000];
        sprintf(data_field_name, "SwitchIngress.update_%d.cs_table.f1", array_size);
        reset_point(register_table, dev_tgt, data_field_name, reg_index_key_id, key);
    }
}

#ifndef SKETCH_MRB_OPT
#define SKETCH_MRB_OPT

#include <vector>
#include <iostream>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdint.h>
#include <sched.h>
#include <string.h>
#include <time.h>
#include <assert.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pthread.h>
#include <unistd.h>
#include <pcap.h>
#include <arpa/inet.h>

#include "common/connection.h"
#include "bf_library/register.h"
#include "library/params.h"
#include "library/timer.h"
#include "library/com.h"

using namespace std;

class MRB_OPT : public Connection {
public:
    MRB_OPT();

    virtual void init(parameters &params);
    virtual void test(parameters &params);
};

#endif // SKETCH_MRB_OPT

#include "mrb_opt.h"

extern std::shared_ptr<bfrt::BfRtSession> session;

struct cookie_parameters
{
    int array_size;
    int counter_size;
    const bfrt::BfRtTable *register_table;
    int logging;
    int epoch;
    int e_count;
};

MRB_OPT::MRB_OPT()
{
}

static Timer bulk_read_timer;
static Timer individual_reset_timer;

static int isPrint = 1;
// static int isPrint = 0;
static void reset_individual(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, int array_size);

void MRB_OPT::init(parameters &params)
{
    cout << "MRB_OPT init" << endl;
    sprintf(params.program_name, "p416_mrb");
    cout << params.program_name << endl;

    Connection::init(params);
}

static void file_print(char* file_path, int array_size, vector<int> &data)
{
    FILE * f = fopen(file_path, "w");
    int count = 0;
    for (auto& d : data) {
        fprintf(f, "%d\n", d);
        // if (d != 0) {
        //     fprintf(f, "%d %d\n", count, d);
        //     // printf("%d %d\n", count, d);
        // }
        count += 1;
    }
    fclose(f);
}

static void bulk_reset(int array_size)
{
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
    sprintf(msg, "reset_1_%d", array_size);
    send(sock , msg , strlen(msg) , 0 );
    valread = read( sock , buffer, 1024);
    printf("%s\n",buffer );
}

static void read(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, uint64_t key, auto flag, int array_size, vector<int> &data)
{
    bf_rt_id_t reg_index_key_id;
    auto bf_status = register_table->keyFieldIdGet("$REGISTER_INDEX", &reg_index_key_id);
    assert(bf_status == BF_SUCCESS);

    uint64_t value;
    char data_field_name[5000];
    sprintf(data_field_name, "SwitchIngress.update_%d.cs_table.f1", array_size);
    value = read_point(register_table, dev_tgt, data_field_name, reg_index_key_id, key, flag);
    data.push_back(value);
    if(isPrint) {
        // if (value != 0)
        //     printf("(%d %d)\n", key, value);
    }
}


static void callback(const bf_rt_target_t &dev_tgt, void *cookie) {
    if(isPrint)
        printf("[bulk read] callback %f\n", bulk_read_timer.lap());

    cookie_parameters params = * (cookie_parameters *) cookie;
    int array_size = params.array_size;

    if (isPrint) {
        printf("[reset] start\n");
    }
    individual_reset_timer.start();
    bulk_reset(array_size);
    double delay = individual_reset_timer.lap();
    if (isPrint) {
        printf("[bulk reset] done - %f\n\n", delay);
    }

    auto flag = bfrt::BfRtTable::BfRtTableGetFlag::GET_FROM_SW;
    vector<int> data;
    bf_rt_target_t dev_tgt_2 = dev_tgt;
    const bfrt::BfRtTable *register_table = params.register_table;
    for (uint64_t key = 0; key < array_size; key++) {
        read(register_table, dev_tgt_2, key, flag, array_size, data);
    }

    delay = bulk_read_timer.lap();
    printf("[defered bulk read] done - %f\n\n", delay);

    char cmd[1000];
    char dir_name[1000];
    sprintf(dir_name, "/home/hnamkung/sketch_home/result_tofino_dp/sketchAug/mrb_opt/cpp/%05d/%02ds/%02d", params.array_size, params.epoch, params.e_count);
    sprintf(cmd, "mkdir -p %s", dir_name);
    system(cmd);

    char file_path[5000];
    sprintf(file_path, "%s/result.txt", dir_name);

    printf("[file path] %s\n", file_path);
    file_print(file_path, array_size, data);
}

static void read_bulk(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, int array_size, cookie_parameters &cookie_params)
{
    bulk_read_timer.start();
    bfrt::TableOperationsType type = bfrt::TableOperationsType::REGISTER_SYNC; // REGISTER_SYNC
    std::unique_ptr<bfrt::BfRtTableOperations> table_ops;
    auto bf_status = register_table->operationsAllocate(type, &table_ops);
    assert(bf_status == BF_SUCCESS);

    void *cookie = &cookie_params;
    if(isPrint) {
        printf("[bulk read] register %f %d\n", bulk_read_timer.lap(), cookie_params.array_size);
    }
    bf_status = table_ops->registerSyncSet(*session, dev_tgt, callback, cookie);
    assert(bf_status == BF_SUCCESS);

    bf_status = register_table->tableOperationsExecute(*table_ops);
    assert(bf_status == BF_SUCCESS);
}


void MRB_OPT::test(parameters &params)
{
    cout << "MRB_OPT test" << endl;
    cout << params.test_type << endl;

    parse_msg(params);

    int epoch = params.epoch;
    int array_size = params.size;

    cout << "epoch: " << epoch << endl;
    cout << "size: " << array_size << endl;


    vector<int> array_size_vector;

    cookie_parameters cookie_params;

    char table_name[5000];

    const bfrt::BfRtTable *register_table = nullptr;
    sprintf(table_name, "SwitchIngress.update_%d.cs_table", array_size);
    auto bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &register_table);
    assert(bf_status == BF_SUCCESS);

    const bfrt::BfRtTable *register_index_table = nullptr;
    sprintf(table_name, "SwitchIngress.epoch_count_1.cs_table");
    bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &register_index_table);
    assert(bf_status == BF_SUCCESS);


    cout << "wait for 1 sec" << endl;
    usleep(626 * 1000); // 626ms
    sleep(1); // 1000ms
    
    Timer total_timer;
    Timer loop_timer;

    double ms_delay;
    

    total_timer.start();
    for(int e_count=0; e_count<=60/epoch; e_count++) {
        cout << e_count << " " << total_timer.lap() << endl;
        loop_timer.start();
        cookie_params.array_size = array_size;
        cookie_params.register_table = register_table;
        cookie_params.logging = 0;
        cookie_params.epoch = epoch;
        cookie_params.e_count = e_count;

        bf_rt_id_t reg_index_key_id;
        auto bf_status = register_index_table->keyFieldIdGet("$REGISTER_INDEX", &reg_index_key_id);
        assert(bf_status == BF_SUCCESS);

        char data_field_name[5000];
        sprintf(data_field_name, "SwitchIngress.epoch_count_1.cs_table.f1");

        write_point(register_index_table, dev_tgt, data_field_name, reg_index_key_id, 0, e_count+1);

        if(isPrint) {
            printf("[bulk read] start\n");
        }

        read_bulk(register_table, dev_tgt, array_size, cookie_params);

        ms_delay = loop_timer.lap();
        if (e_count == 60/epoch) {
            sleep(4);
        }
        else {
            usleep(epoch * 1000 * 1000 - ms_delay * 1000 - 110);
        }
        // break;
    }
}

static void reset_individual(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, int array_size)
{
    for (uint64_t key = 0; key < array_size; key++) {
        bf_rt_id_t reg_index_key_id;
        auto bf_status = register_table->keyFieldIdGet("$REGISTER_INDEX", &reg_index_key_id);
        assert(bf_status == BF_SUCCESS);

        char data_field_name[5000];
        sprintf(data_field_name, "SwitchIngress.update_%d.cs_table.f1", array_size);
        reset_point(register_table, dev_tgt, data_field_name, reg_index_key_id, key);
    }
}


#ifndef SKETCH_MRB_PP
#define SKETCH_MRB_PP

#include <vector>
#include <iostream>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdint.h>
#include <sched.h>
#include <string.h>
#include <time.h>
#include <assert.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pthread.h>
#include <unistd.h>
#include <pcap.h>
#include <arpa/inet.h>

#include "common/connection.h"
#include "bf_library/register.h"
#include "library/params.h"
#include "library/timer.h"
#include "library/com.h"

using namespace std;

class MRB_PP : public Connection {
public:
    MRB_PP();

    virtual void init(parameters &params);
    virtual void test(parameters &params);
};

#endif // SKETCH_MRB


#include "mrb_pingpong.h"

extern std::shared_ptr<bfrt::BfRtSession> session;

struct cookie_parameters
{
    int array_size;
    int counter_size;
    const bfrt::BfRtTable *register_table;
    int logging;
    int epoch;
    int e_count;
};

MRB_PP::MRB_PP()
{
}

static Timer bulk_read_timer;
static Timer individual_reset_timer;

static int isPrint = 1;
// static int isPrint = 0;
static void reset_individual(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, int array_size, int bin);

void MRB_PP::init(parameters &params)
{
    cout << "MRB pingpong init" << endl;
    sprintf(params.program_name, "p416_mrb_pingpong");
    cout << params.program_name << endl;

    Connection::init(params);
}

static void file_print(char* file_path, int array_size, vector<int> &data)
{
    FILE * f = fopen(file_path, "w");
    int count = 0;
    for (auto& d : data) {
        fprintf(f, "%d\n", d);
        // if (d != 0) {
        //     fprintf(f, "%d %d\n", count, d);
        //     // printf("%d %d\n", count, d);
        // }
        count += 1;
    }
    fclose(f);
}

static void read(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, uint64_t key, auto flag, int array_size, vector<int> &data, int bin)
{
    bf_rt_id_t reg_index_key_id;
    auto bf_status = register_table->keyFieldIdGet("$REGISTER_INDEX", &reg_index_key_id);
    assert(bf_status == BF_SUCCESS);

    uint64_t value;
    char data_field_name[5000];
    sprintf(data_field_name, "SwitchIngress.update_%d_%d.cs_table.f1", array_size, bin);
    value = read_point(register_table, dev_tgt, data_field_name, reg_index_key_id, key, flag);
    data.push_back(value);
    if(isPrint) {
        // if (value != 0)
        //     printf("(%d %d)\n", key, value);
    }
}

static void callback(const bf_rt_target_t &dev_tgt, void *cookie) {
    if(isPrint)
        printf("[bulk read] callback %f\n", bulk_read_timer.lap());

    cookie_parameters params = * (cookie_parameters *) cookie;

    auto flag = bfrt::BfRtTable::BfRtTableGetFlag::GET_FROM_SW;
    vector<int> data;
    bf_rt_target_t dev_tgt_2 = dev_tgt;
    int array_size;
    array_size = params.array_size;
    const bfrt::BfRtTable *register_table = params.register_table;
    for (uint64_t key = 0; key < array_size; key++) {
        read(register_table, dev_tgt_2, key, flag, array_size, data, params.logging);
    }

    double delay = bulk_read_timer.lap();
    printf("[bulk read] done - %f\n\n", delay);

    if (isPrint) {
        printf("[reset] start\n");
    }
    individual_reset_timer.start();
    auto bf_status = session->beginTransaction(false);
    reset_individual(register_table, dev_tgt_2, array_size, params.logging);
    bf_status = session->verifyTransaction();
    bf_status = session->sessionCompleteOperations();
    bf_status = session->commitTransaction(true);
    delay = individual_reset_timer.lap();
    if (isPrint) {
        printf("[reset] done - %f\n\n", delay);
    }

    char cmd[1000];
    char dir_name[1000];
    sprintf(dir_name, "/home/hnamkung/sketch_home/result_tofino_dp/sketchAug/mrb_pingpong/cpp/%05d/%02ds/%02d", params.array_size, params.epoch, params.e_count);
    sprintf(cmd, "mkdir -p %s", dir_name);
    system(cmd);

    char file_path[5000];
    sprintf(file_path, "%s/result.txt", dir_name);

    printf("[file path] %s\n", file_path);
    file_print(file_path, array_size, data);
}

static void read_bulk(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, int array_size, cookie_parameters &cookie_params)
{
    bulk_read_timer.start();
    bfrt::TableOperationsType type = bfrt::TableOperationsType::REGISTER_SYNC; // REGISTER_SYNC
    std::unique_ptr<bfrt::BfRtTableOperations> table_ops;
    auto bf_status = register_table->operationsAllocate(type, &table_ops);
    assert(bf_status == BF_SUCCESS);

    void *cookie = &cookie_params;
    if(isPrint) {
        printf("[bulk read] register %f %d\n", bulk_read_timer.lap(), cookie_params.array_size);
    }
    bf_status = table_ops->registerSyncSet(*session, dev_tgt, callback, cookie);
    assert(bf_status == BF_SUCCESS);

    bf_status = register_table->tableOperationsExecute(*table_ops);
    assert(bf_status == BF_SUCCESS);
}


void MRB_PP::test(parameters &params)
{
    cout << "mrb pingpong test" << endl;
    cout << params.test_type << endl;

    parse_msg(params);

    int epoch = params.epoch;
    int array_size = params.size;

    cout << "epoch: " << epoch << endl;
    cout << "size: " << array_size << endl;

    vector<int> array_size_vector;

    cookie_parameters cookie_params;

    char table_name[5000];

    const bfrt::BfRtTable *register_index_table = nullptr;
    sprintf(table_name, "SwitchIngress.epoch_count_1.cs_table");
    auto bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &register_index_table);
    assert(bf_status == BF_SUCCESS);

    const bfrt::BfRtTable *register_table_0 = nullptr;
    sprintf(table_name, "SwitchIngress.update_%d_0.cs_table", array_size);
    bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &register_table_0);
    assert(bf_status == BF_SUCCESS);

    const bfrt::BfRtTable *register_table_1 = nullptr;
    sprintf(table_name, "SwitchIngress.update_%d_1.cs_table", array_size);
    bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &register_table_1);
    assert(bf_status == BF_SUCCESS);


    cout << "wait for 1 sec" << endl;
    usleep(626 * 1000); // 626ms
    sleep(1); // 1000ms
    
    Timer total_timer;
    Timer loop_timer;

    double ms_delay;

    total_timer.start();
    for(int e_count=0; e_count<=60/epoch; e_count++) {
        cout << e_count << " " << total_timer.lap() << endl;
        loop_timer.start();
        if (e_count % 2 == 0) {
            cookie_params.register_table = register_table_0;
        }
        else {
            cookie_params.register_table = register_table_1;
        }
        cookie_params.array_size = array_size;
        cookie_params.logging = e_count % 2;
        cookie_params.epoch = epoch;
        cookie_params.e_count = e_count;

        bf_rt_id_t reg_index_key_id;
        auto bf_status = register_index_table->keyFieldIdGet("$REGISTER_INDEX", &reg_index_key_id);
        assert(bf_status == BF_SUCCESS);

        char data_field_name[5000];
        sprintf(data_field_name, "SwitchIngress.epoch_count_1.cs_table.f1");
        write_point(register_index_table, dev_tgt, data_field_name, reg_index_key_id, 0, e_count+1);

        if(isPrint) {
            printf("[bulk read] start\n");
        }

        read_bulk(cookie_params.register_table, dev_tgt, array_size, cookie_params);

        ms_delay = loop_timer.lap();
        if (e_count == 60/epoch) {
            sleep(4);
        }
        else {
            usleep(epoch * 1000 * 1000 - ms_delay * 1000 - 110);
        }
        // break;
    }
}

static void reset_individual(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, int array_size, int bin)
{
    for (uint64_t key = 0; key < array_size; key++) {
        bf_rt_id_t reg_index_key_id;
        auto bf_status = register_table->keyFieldIdGet("$REGISTER_INDEX", &reg_index_key_id);
        assert(bf_status == BF_SUCCESS);

        char data_field_name[5000];
        sprintf(data_field_name, "SwitchIngress.update_%d_%d.cs_table.f1", array_size, bin);
        reset_point(register_table, dev_tgt, data_field_name, reg_index_key_id, key);
    }
}
