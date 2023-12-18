#include "kv_vector.h"

KeyValueVector::KeyValueVector(map <flowkey_t, int> &packetMap, parameters &params)
{
    map<flowkey_t, int>::iterator it;
    for (it=packetMap.begin(); it!=packetMap.end(); it++) {
        kv_elem e;
        e.flowkey = it -> first;
        generate_string_key(e.string_flowkey, e.flowkey, params);
        e.value = it->second;
        vec.push_back(e);
    }
}

KeyValueVector::KeyValueVector(PriorityQueue &pq, parameters &params)
{
    int size = pq.heap_size();
//    cout << size << endl;
    for(int i=1; i<=size; i++) {
        kv_elem e;
        e.flowkey = pq.min_heap[i].first;
        generate_string_key(e.string_flowkey, e.flowkey, params);
        e.value = pq.min_heap[i].second;
        vec.push_back(e);
    }
}

void KeyValueVector::sort_vector() {
    sort(vec.begin(), vec.end(), kv_cmp());
}

void KeyValueVector::file_print(parameters &params, string fn, int line_count) {

    string dir_name;
    dir_name = params.output_dir;
    cout << "? " << dir_name << endl;
    sys_mkdir(dir_name);

    string file_name = dir_name + fn;

    // cout << file_name << endl;

    FILE* fp = fopen(file_name.c_str(), "w");

    vector<kv_elem>::iterator it;
    int count = 1;
    fprintf(fp, "%s\n", params.key);
    for (it = vec.begin(); it != vec.end(); it++, count++) {
        fprintf(fp, "%s %d ", (it->string_flowkey).c_str(), it->value);
        flowkey_t flowkey = it->flowkey;
        fprintf(fp, "[%u %u %u %u %u]\n", flowkey.src_addr, flowkey.src_port, flowkey.dst_addr, flowkey.dst_port, flowkey.proto);
        // (srcIP =   220.28.108.254 | srcPort =    80 | dstIP =  215.158.238.253 | dstPort = 40093 | proto =   6) 190 [3692850430 80 3617517309 40093 6]
        if(line_count != 0 && count >= line_count)
            break;
    }
    // cout << count << endl;

    fclose(fp);
}
