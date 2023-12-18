#include "register.h"

extern std::shared_ptr<bfrt::BfRtSession> session;

uint64_t read_point(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, char* data_field_name, bf_rt_id_t &reg_index_key_id, uint64_t key, bfrt::BfRtTable::BfRtTableGetFlag flag)
{
    bf_rt_id_t data_id;
    auto bf_status = register_table->dataFieldIdGet(data_field_name, &data_id);
    assert(bf_status == BF_SUCCESS);

    std::unique_ptr<bfrt::BfRtTableKey> register_table_key;
    std::unique_ptr<bfrt::BfRtTableData> register_table_data;

    bf_status = register_table->keyAllocate(&register_table_key);
    assert(bf_status == BF_SUCCESS);

    bf_status = register_table->dataAllocate(&register_table_data);
    assert(bf_status == BF_SUCCESS);

    bf_status = register_table_key->setValue(reg_index_key_id, key);
    assert(bf_status == BF_SUCCESS);

    bf_status = register_table->tableEntryGet(*session, dev_tgt, *(register_table_key.get()),
                                flag, register_table_data.get());
    assert(bf_status == BF_SUCCESS);

    std::vector<uint64_t> values;
    bf_status = register_table_data->getValue(data_id, &values);
    assert(bf_status == BF_SUCCESS);

    return values[1];
}

void write_point(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, char* data_field_name, bf_rt_id_t &reg_index_key_id, uint64_t key, uint64_t valueq)
{
    bf_rt_id_t data_id;
    auto bf_status = register_table->dataFieldIdGet(data_field_name, &data_id);
    assert(bf_status == BF_SUCCESS);

    std::unique_ptr<bfrt::BfRtTableKey> register_table_key;
    std::unique_ptr<bfrt::BfRtTableData> register_table_data;

    bf_status = register_table->keyAllocate(&register_table_key);
    assert(bf_status == BF_SUCCESS);

    bf_status = register_table_key->setValue(reg_index_key_id, key);
    assert(bf_status == BF_SUCCESS);

    bf_status = register_table->dataAllocate(&register_table_data);
    assert(bf_status == BF_SUCCESS);

    bf_status = register_table_data->setValue(data_id, valueq);
    assert(bf_status == BF_SUCCESS);

    bf_status = register_table->tableEntryMod(*session, dev_tgt, *register_table_key, *register_table_data);
    assert(bf_status == BF_SUCCESS);
}

void read_whole(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, bfrt::BfRtTable::BfRtTableGetFlag flag, int array_size, char* data_field_name, vector<int> &data)
{
    uint64_t value;
    for (uint64_t key = 0; key < array_size; key++) {
        bf_rt_id_t reg_index_key_id;
        auto bf_status = register_table->keyFieldIdGet("$REGISTER_INDEX", &reg_index_key_id);
        assert(bf_status == BF_SUCCESS);
        value = read_point(register_table, dev_tgt, data_field_name, reg_index_key_id, key, flag);
        data.push_back(value);
    }
}

void reset_whole(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, int array_size, char* data_field_name)
{
    for (uint64_t key = 0; key < array_size; key++) {
        bf_rt_id_t reg_index_key_id;
        auto bf_status = register_table->keyFieldIdGet("$REGISTER_INDEX", &reg_index_key_id);
        assert(bf_status == BF_SUCCESS);
        write_point(register_table, dev_tgt, data_field_name, reg_index_key_id, key, 0);
    }
}
