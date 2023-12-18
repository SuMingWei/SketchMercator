#include "hll.h"

extern std::shared_ptr<bfrt::BfRtSession> session;
extern int isPrint;

HLL::HLL()
{
}

void HLL::init(parameters &params)
{
    cout << "[CPP] [HLL] init" << endl;
    if (strcmp(params.str_args_1, "pingpong") == 0) {
        sprintf(params.program_name, "p416_hll_pp");
    }
    else {
        sprintf(params.program_name, "p416_hll");
    }
    cout << params.program_name << endl;

    params.multiple_rows = 0;

    Connection::init(params);
}

void HLL::table_init(parameters &params)
{
    cout << "[CPP] [HLL] table init" << endl;

    Connection::table_init(params);

    int array_size = params.array_size;

    char table_name[5000];
    if(strcmp(params.mode, "pingpong") != 0) {
        sprintf(table_name, "SwitchIngress.update_%d.cs_table", array_size);
        auto bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_1);
        assert(bf_status == BF_SUCCESS);
    
        sprintf(params.data_field_name_1, "SwitchIngress.update_%d.cs_table.f1", array_size);
    }

    else {

        sprintf(table_name, "SwitchIngress.update_%d_0.cs_table", array_size);
        auto bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_1_0);
        assert(bf_status == BF_SUCCESS);

        sprintf(table_name, "SwitchIngress.update_%d_1.cs_table", array_size);
        bf_status = bfrtInfo->bfrtTableFromNameGet(table_name, &params.register_table_1_1);
        assert(bf_status == BF_SUCCESS);
    }
}

void HLL::setup_pingpong(parameters &params, int e_count)
{
    if (isPrint)
        cout << "[CPP] [HLL] setup_pingpong" << endl;
    if (e_count % 2 == 1) {
        params.register_table_1 = params.register_table_1_0;

        sprintf(params.data_field_name_1, "SwitchIngress.update_%d_0.cs_table.f1", params.array_size);
    }
    else {
        params.register_table_1 = params.register_table_1_1;

        sprintf(params.data_field_name_1, "SwitchIngress.update_%d_1.cs_table.f1", params.array_size);
    }
}

void HLL::test(parameters &params)
{
    cout << "[CPP] HLL test" << endl;
    cout << params.test_type << endl;
}
