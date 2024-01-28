#include "sketch_template.h"
#include "../config.h"

sketchTemplate::sketchTemplate(parameters &params, int _level)
{
    level = _level;
    depth = params.depth;
    width = params.width;

    sketchArray = new int[depth * width];

    total_counter = 0;

    for(int i = 0; i < depth * width; i++)
        sketchArray[i] = 0;

    index_hash = new HashSeedSet(10);
    res_hash = new HashSeedSet(10);
}

void sketchTemplate::clear()
{
    total_counter = 0;
    for(int i = 0; i < depth * width; i++)
        sketchArray[i] = 0;
}

int sketchTemplate::count_sketch(flowkey_t flowkey, parameters &params, int elem)
{
    total_counter++;

    int a[depth];
    
    uint32_t long_hash = res_hash->compute_hash(flowkey, params.flowkey_flags, 0, params.is_crc_hash, 1024);
    for(int i = 0; i < depth; i++) {
        int index = index_hash->compute_hash(flowkey, params.flowkey_flags, i, params.is_crc_hash, width);
        int res = 0;
        if (params.is_compact_hash == 0) {
            res = res_hash->compute_hash(flowkey, params.flowkey_flags, i, params.is_crc_hash, 2);
        }
        else {
            res = (long_hash >> i) & 1;
        }

        res = res * 2 - 1;
        sketchArray[i * width + index] += (res * elem);
        a[i] = sketchArray[i * width + index] * res;
    }    
    
    sort(a, a + depth);

    if (depth % 2 == 0)
        return (a[depth/2] + a[depth/2-1])/2;
    else
        return a[(depth/2)];
}

int sketchTemplate::count_min_sketch(flowkey_t flowkey, parameters &params, int elem)
{
    total_counter++;

    int a[depth];
    
    for(int i = 0; i < depth; i++) {
        // int index = index_hash->compute_hash(flowkey, params.flowkey_flags, i, params.is_crc_hash, width);
        int index = index_hash->compute_hash_xor_type(flowkey, params.flowkey_flags, i, params.is_crc_hash, width, params.xor_hash_type);
        sketchArray[i * width + index] += (elem);
        a[i] = sketchArray[i * width + index];
    }    

    sort(a, a + depth);

    return a[0];
}

// // just temporary for SketchLib FCM eval
// int sketchTemplate::count_min_sketch(flowkey_t flowkey, parameters &params, int elem)
// {
//     total_counter++;

//     int a[depth];
    
//     for(int i = 0; i < depth; i++) {
//         int index;
//         if(i <= 3) {
//             index = index_hash->compute_hash(flowkey, params.flowkey_flags, i, params.is_crc_hash, width);
//         }
//         else {
//             index = index_hash->compute_hash(flowkey, params.flowkey_flags, i, params.is_crc_hash, width/2);
//         }
//         sketchArray[i * width + index] += (elem);
//         a[i] = sketchArray[i * width + index];
//     }    
    
//     sort(a, a + depth);

//     return a[0];
// }

int sketchTemplate::fcm_sketch(flowkey_t flowkey, parameters &params, int elem)
{
    total_counter++;

    // 524288 x 6
    // 524288 -> 65536 -> 8192

    int est1=0;
    int index0 = index_hash->compute_hash(flowkey, params.flowkey_flags, 0, params.is_crc_hash, width);
    int index1 = index0 >> 3;
    int index2 = index0 >> 6;

    int est2=0;
    int index3 = index_hash->compute_hash(flowkey, params.flowkey_flags, 1, params.is_crc_hash, width);
    int index4 = index3 >> 3;
    int index5 = index3 >> 6;


    if(sketchArray[0 * width + index0] <= 254) {
        sketchArray[0 * width + index0] += elem;
    }
    if(sketchArray[0 * width + index0] <= 254) {
        est1 = sketchArray[0 * width + index0];
    }
    else { // overflowed, >= 255
        if(sketchArray[1 * width + index1] <= 65534) {
            sketchArray[1 * width + index1] += elem;
        }

        if(sketchArray[1 * width + index1] <= 65534) {
            est1 = 254 + sketchArray[1 * width + index1];
        }

        else { // overflowed, >= 65535
            sketchArray[2 * width + index2] += elem;
            est1 = 254 + 65534 + sketchArray[2 * width + index2];
        }
    }

    if(sketchArray[3 * width + index3] <= 254) {
        sketchArray[3 * width + index3] += elem;
    }
    if(sketchArray[3 * width + index3] <= 254) {
        est2 = sketchArray[3 * width + index3];
    }
    else { // overflowed, >= 255
        if(sketchArray[4 * width + index4] <= 65534) {
            sketchArray[4 * width + index4] += elem;
        }

        if(sketchArray[4 * width + index4] <= 65534) {
            est2 = 254 + sketchArray[4 * width + index4];
        }

        else { // overflowed, >= 65535
            sketchArray[5 * width + index5] += elem;
            est2 = 254 + 65534 + sketchArray[5 * width + index5];
        }
    }

    if(est1 < est2) {
        return est1;
    }
    return est2;
}

int sketchTemplate::get_index_hash(flowkey_t flowkey, parameters &params)
{
    return index_hash->compute_hash(flowkey, params.flowkey_flags, 0, params.is_crc_hash, width);
}

void sketchTemplate::hll_sketch(flowkey_t flowkey, parameters &params, int last_level)
{
    total_counter++;
    int index = index_hash->compute_hash(flowkey, params.flowkey_flags, 0, params.is_crc_hash, width);
    if (sketchArray[index] < last_level) {
        sketchArray[index] = last_level;
    }
}

void sketchTemplate::lc_sketch(flowkey_t flowkey, parameters &params)
{
    total_counter++;
    int index = index_hash->compute_hash(flowkey, params.flowkey_flags, 0, params.is_crc_hash, width);
    sketchArray[index] = 1;
}


void sketchTemplate::mrb_sketch(flowkey_t flowkey, parameters &params)
{
    total_counter++;
    int index = index_hash->compute_hash(flowkey, params.flowkey_flags, 0, params.is_crc_hash, width);

    // printf("[index]: (%d) (0x%x)\n", index, index);

    sketchArray[index] = 1;
}

void sketchTemplate::sketch_info_file_print(parameters &params, HashSeedSet sampling_hash)
{
    string dir_name = string(params.output_dir);
    // cout << "mkdir " << dir_name << endl;
    sys_mkdir(dir_name);
    string file_name;
    FILE* fp;
    file_name = dir_name + "total.txt";
    fp = fopen(file_name.c_str(), "w");
    fprintf(fp, "%d\n", total_counter);
    fclose(fp);

    file_name = dir_name + "sampling_hash_params.txt";
    fp = fopen(file_name.c_str(), "w");
    fprintf(fp, "sampling_hash\n");
    sampling_hash.filePrintParams(fp, level);
    fclose(fp);

    file_name = dir_name + "index_hash_params.txt";
    fp = fopen(file_name.c_str(), "w");
    // for(int i=0; i<depth; i++) {
    for(int i=0; i<10; i++) {
        index_hash->filePrintParams(fp, i);
    }
    fclose(fp);

    file_name = dir_name + "res_hash_params.txt";
    fp = fopen(file_name.c_str(), "w");
    // for(int i=0; i<depth; i++) {
    for(int i=0; i<10; i++) {
        res_hash->filePrintParams(fp, i);
    }
    fclose(fp);

    file_name = dir_name + "sketch_counter.txt";
    fp = fopen(file_name.c_str(), "w");
    for(int i = 0; i < depth * width; i++) {
        fprintf(fp, "%d\n", sketchArray[i]);

    }
    fclose(fp);
}

void sketchTemplate::counter_info_file_print(parameters &params, string idx)
{
    string dir_name = string(params.output_dir);
    // cout << "mkdir " << dir_name << endl;
    sys_mkdir(dir_name);

    string file_name;
    FILE* fp;

    file_name = dir_name + idx + ".txt";
    fp = fopen(file_name.c_str(), "w");
    for(int i = 0; i < depth * width; i++) {
        fprintf(fp, "%d\n", sketchArray[i]);

    }
    fclose(fp);
}