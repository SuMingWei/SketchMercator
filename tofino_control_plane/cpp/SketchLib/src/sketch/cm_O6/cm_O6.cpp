#include "cm_O6.h"

extern std::shared_ptr<bfrt::BfRtSession> session;
extern int isPrint;

CM_O6::CM_O6()
{
}

void CM_O6::init(parameters &params)
{
    cout << "[CPP] [CM_O6] init" << endl;

    sprintf(params.program_name, "p416_eval_countmin");
    cout << params.program_name << endl;

    Connection::init(params);
}

void CM_O6::read(parameters &params)
{
    cout << "[CPP] [CM_O6] read" << endl;

    char table_name[5000];

    sprintf(table_name, "SwitchIngress.update_1.cs_table");
    auto bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_1);
    assert(bf_status == BF_SUCCESS);

    sprintf(table_name, "SwitchIngress.update_2.cs_table");
    bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_2);
    assert(bf_status == BF_SUCCESS);

    sprintf(table_name, "SwitchIngress.update_3.cs_table");
    bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_3);
    assert(bf_status == BF_SUCCESS);

    sprintf(table_name, "SwitchIngress.update_4.cs_table");
    bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_4);
    assert(bf_status == BF_SUCCESS);

    sprintf(table_name, "SwitchIngress.update_5.cs_table");
    bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_5);
    assert(bf_status == BF_SUCCESS);

    sprintf(table_name, "SwitchIngress.update_6.cs_table");
    bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_6);
    assert(bf_status == BF_SUCCESS);

    sprintf(params.data_field_name_1, "SwitchIngress.update_1.cs_table.f1");
    sprintf(params.data_field_name_2, "SwitchIngress.update_2.cs_table.f1");
    sprintf(params.data_field_name_3, "SwitchIngress.update_3.cs_table.f1");
    sprintf(params.data_field_name_4, "SwitchIngress.update_4.cs_table.f1");
    sprintf(params.data_field_name_5, "SwitchIngress.update_5.cs_table.f1");
    sprintf(params.data_field_name_6, "SwitchIngress.update_6.cs_table.f1");
        
    auto flag = bfrt::BfRtTable::BfRtTableGetFlag::GET_FROM_HW;
    vector<int> data1;
    vector<int> data2;
    vector<int> data3;
    vector<int> data4;
    vector<int> data5;
    vector<int> data6;

    printf("read1\n");
    read_whole(params.register_table_1, dev_tgt, flag, 65536, params.data_field_name_1, data1);

    printf("read2\n");
    read_whole(params.register_table_2, dev_tgt, flag, 65536, params.data_field_name_2, data2);

    printf("read3\n");
    read_whole(params.register_table_3, dev_tgt, flag, 65536, params.data_field_name_3, data3);

    printf("read4\n");
    read_whole(params.register_table_4, dev_tgt, flag, 65536, params.data_field_name_4, data4);

    printf("read5\n");
    read_whole(params.register_table_5, dev_tgt, flag, 32768, params.data_field_name_5, data5);

    printf("read6\n");
    read_whole(params.register_table_6, dev_tgt, flag, 32768, params.data_field_name_6, data6);

    printf("read done\n");

    char dir_name[1000];
    sprintf(dir_name, "/home/hnamkung/sketch_home/result_tofino_dp/SketchLib/fcm_eval/%s/%s", params.sketch_name, params.pcap_name);

    char cmd[1000];
    sprintf(cmd, "mkdir -p %s", dir_name);
    system(cmd);

    char file_path[5000];
    sprintf(file_path, "%s/result.txt", dir_name);
    file_print_multiple_rows_lib(file_path, data1, data2, data3, data4, data5, data6);

    printf("write done\n");
}

void CM_O6::reset(parameters &params)
{
    cout << "[CPP] [CM_O6] reset" << endl;
    char table_name[5000];

    sprintf(table_name, "SwitchIngress.update_1.cs_table");
    auto bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_1);
    assert(bf_status == BF_SUCCESS);

    sprintf(table_name, "SwitchIngress.update_2.cs_table");
    bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_2);
    assert(bf_status == BF_SUCCESS);

    sprintf(table_name, "SwitchIngress.update_3.cs_table");
    bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_3);
    assert(bf_status == BF_SUCCESS);

    sprintf(table_name, "SwitchIngress.update_4.cs_table");
    bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_4);
    assert(bf_status == BF_SUCCESS);

    sprintf(table_name, "SwitchIngress.update_5.cs_table");
    bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_5);
    assert(bf_status == BF_SUCCESS);

    sprintf(table_name, "SwitchIngress.update_6.cs_table");
    bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_6);
    assert(bf_status == BF_SUCCESS);


    printf("reset1\n");
    bf_status = params.register_table_1->tableClear(*session, dev_tgt);
    assert(bf_status == BF_SUCCESS);

    printf("reset2\n");
    bf_status = params.register_table_2->tableClear(*session, dev_tgt);
    assert(bf_status == BF_SUCCESS);

    printf("reset3\n");
    bf_status = params.register_table_3->tableClear(*session, dev_tgt);
    assert(bf_status == BF_SUCCESS);

    printf("reset4\n");
    bf_status = params.register_table_4->tableClear(*session, dev_tgt);
    assert(bf_status == BF_SUCCESS);

    printf("reset5\n");
    bf_status = params.register_table_5->tableClear(*session, dev_tgt);
    assert(bf_status == BF_SUCCESS);

    printf("reset6\n");
    bf_status = params.register_table_6->tableClear(*session, dev_tgt);
    assert(bf_status == BF_SUCCESS);
}
