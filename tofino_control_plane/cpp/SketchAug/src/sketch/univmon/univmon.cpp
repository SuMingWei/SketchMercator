#include "univmon.h"

extern std::shared_ptr<bfrt::BfRtSession> session;
extern int isPrint;

UnivMon::UnivMon()
{
}

void UnivMon::init(parameters &params)
{
    cout << "[CPP] [UnivMon] init" << endl;
    if (strcmp(params.str_args_1, "pingpong") == 0) {
        sprintf(params.program_name, "p416_univmon_pp");
    }
    else {
        sprintf(params.program_name, "p416_univmon");
    }
    cout << params.program_name << endl;

    params.multiple_rows = 1;

    Connection::init(params);
}

void UnivMon::table_init(parameters &params)
{
    cout << "[CPP] [UnivMon] table init" << endl;

    Connection::table_init(params);

    int array_size = params.array_size;

    char table_name[5000];
    if(strcmp(params.mode, "pingpong") != 0) {
        sprintf(table_name, "SwitchIngress.update_%d_1.cs_table", array_size);
        auto bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_1);
        assert(bf_status == BF_SUCCESS);

        sprintf(table_name, "SwitchIngress.update_%d_2.cs_table", array_size);
        bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_2);
        assert(bf_status == BF_SUCCESS);

        sprintf(table_name, "SwitchIngress.update_%d_3.cs_table", array_size);
        bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_3);
        assert(bf_status == BF_SUCCESS);

        sprintf(table_name, "SwitchIngress.update_%d_4.cs_table", array_size);
        bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_4);
        assert(bf_status == BF_SUCCESS);
    
        sprintf(params.data_field_name_1, "SwitchIngress.update_%d_1.cs_table.f1", array_size);
        sprintf(params.data_field_name_2, "SwitchIngress.update_%d_2.cs_table.f1", array_size);
        sprintf(params.data_field_name_3, "SwitchIngress.update_%d_3.cs_table.f1", array_size);
        sprintf(params.data_field_name_4, "SwitchIngress.update_%d_4.cs_table.f1", array_size);
    }

    else {

        sprintf(table_name, "SwitchIngress.update_%d_1_0.cs_table", array_size);
        auto bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_1_0);
        assert(bf_status == BF_SUCCESS);

        sprintf(table_name, "SwitchIngress.update_%d_2_0.cs_table", array_size);
        bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_2_0);
        assert(bf_status == BF_SUCCESS);

        sprintf(table_name, "SwitchIngress.update_%d_3_0.cs_table", array_size);
        bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_3_0);
        assert(bf_status == BF_SUCCESS);

        sprintf(table_name, "SwitchIngress.update_%d_4_0.cs_table", array_size);
        bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_4_0);
        assert(bf_status == BF_SUCCESS);

        sprintf(table_name, "SwitchIngress.update_%d_1_1.cs_table", array_size);
        bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_1_1);
        assert(bf_status == BF_SUCCESS);

        sprintf(table_name, "SwitchIngress.update_%d_2_1.cs_table", array_size);
        bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_2_1);
        assert(bf_status == BF_SUCCESS);

        sprintf(table_name, "SwitchIngress.update_%d_3_1.cs_table", array_size);
        bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_3_1);
        assert(bf_status == BF_SUCCESS);

        sprintf(table_name, "SwitchIngress.update_%d_4_1.cs_table", array_size);
        bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_4_1);
        assert(bf_status == BF_SUCCESS);
    }
}

void UnivMon::setup_pingpong(parameters &params, int e_count)
{
    if (isPrint)
        cout << "[CPP] [UnivMon] setup_pingpong" << endl;
    if (e_count % 2 == 1) {
        params.register_table_1 = params.register_table_1_0;
        params.register_table_2 = params.register_table_2_0;
        params.register_table_3 = params.register_table_3_0;
        params.register_table_4 = params.register_table_4_0;

        sprintf(params.data_field_name_1, "SwitchIngress.update_%d_1_0.cs_table.f1", params.array_size);
        sprintf(params.data_field_name_2, "SwitchIngress.update_%d_2_0.cs_table.f1", params.array_size);
        sprintf(params.data_field_name_3, "SwitchIngress.update_%d_3_0.cs_table.f1", params.array_size);
        sprintf(params.data_field_name_4, "SwitchIngress.update_%d_4_0.cs_table.f1", params.array_size);
    }
    else {
        params.register_table_1 = params.register_table_1_1;
        params.register_table_2 = params.register_table_2_1;
        params.register_table_3 = params.register_table_3_1;
        params.register_table_4 = params.register_table_4_1;

        sprintf(params.data_field_name_1, "SwitchIngress.update_%d_1_1.cs_table.f1", params.array_size);
        sprintf(params.data_field_name_2, "SwitchIngress.update_%d_2_1.cs_table.f1", params.array_size);
        sprintf(params.data_field_name_3, "SwitchIngress.update_%d_3_1.cs_table.f1", params.array_size);
        sprintf(params.data_field_name_4, "SwitchIngress.update_%d_4_1.cs_table.f1", params.array_size);
    }
}

void UnivMon::test(parameters &params)
{
    cout << "[CPP] UnivMon test" << endl;
    cout << params.test_type << endl;
}
