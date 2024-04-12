#include "main_loop.h"

void main_loop(parameters &params, vector<packet_summary> &packet_stream, sketchIterationTemplate* sketch_iteration_instance)
{
    printf("main loop\n");

    uint64_t original_time = 0;
    uint64_t timer = 0;
    uint64_t window_timer = 0;
    int window_num = 0;
    double window_size = 0.2;

    int pcount = 1;
    int total_count = 0;
    int epoch_pcount = 0;
    char content[50000];
    uint64_t current_time;
    params.current_epoch_count = 1;

    sprintf(content, "\t\t epoch %d start", params.current_epoch_count);
    cout << content << endl;

    vector<packet_summary>::iterator p;
    for (p = packet_stream.begin(); p != packet_stream.end(); p++, pcount++) {
        current_time = p->timestamp;
        if (timer == 0) {
            timer = current_time;
            window_timer = current_time;
            original_time = current_time;
        }

        if(current_time - window_timer >= uint64_t(window_size * 1000000)) { // for each window
            window_timer = current_time;
            sketch_iteration_instance->counter_file_print(params, window_num, window_size*1000);
            sketch_iteration_instance->clear(params);
            window_num++;
            // sprintf(content, "\t\t%s %s (%d/%lu)-(%.2f%%) %.4f (s) duration(%.4f)", params.run_info, params.hash_seed_name, pcount, packet_stream.size(), (float)pcount*100 / (float)packet_stream.size(), ((double)current_time - (double)original_time)/1000000, ((double)current_time - (double)timer)/1000000);
            // cout << content << endl;
        }

        if (current_time - timer >= uint64_t(params.epoch * 1000000)) { // for each epoch
            window_timer = current_time;
            // sketch_iteration_instance->counter_file_print(params, window_num, window_size*1000);
            window_num = 0;

            timer = current_time;
            sketch_iteration_instance->file_print(params);
            sketch_iteration_instance->clear(params);

            epoch_pcount = 0;
            params.current_epoch_count++;

            sprintf(content, "\t\t%s %s (%d/%lu)-(%.2f%%) %.4f (s) duration(%.4f)", params.run_info, params.hash_seed_name, pcount, packet_stream.size(), (float)pcount*100 / (float)packet_stream.size(), ((double)current_time - (double)original_time)/1000000, ((double)current_time - (double)timer)/1000000);
            cout << content << endl;
            sprintf(content, "\n\t\t epoch %d start", params.current_epoch_count);
            cout << content << endl;
        }

        if(pcount % 1000000 == 0) {
            sprintf(content, "\t\t%s %s (%d/%lu)-(%.2f%%) %.4f (s) duration(%.4f)", params.run_info, params.hash_seed_name, pcount, packet_stream.size(), (float)pcount*100 / (float)packet_stream.size(), ((double)current_time - (double)original_time)/1000000, ((double)current_time - (double)timer)/1000000);
            cout << content << endl;
        }

        total_count++;
        epoch_pcount++;
        sketch_iteration_instance->iteration(*p, params);

    }
    sketch_iteration_instance->file_print(params);
    sketch_iteration_instance->clear(params);
    sprintf(content, "\t\t%s %s (%d/%lu)-(%.2f%%) %.4f (s) duration(%.4f)", params.run_info, params.hash_seed_name, pcount-1, packet_stream.size(), (float)pcount*100 / (float)packet_stream.size(), ((double)current_time - (double)original_time)/1000000, ((double)current_time - (double)timer)/1000000);
    cout << content << endl;
    // * file print and clear *
    //
    cout << "count: " << total_count << endl;

}

void main_loop_pcount(parameters &params, vector<packet_summary> &packet_stream, sketchIterationTemplate* sketch_iteration_instance)
{
    printf("main loop pcount\n");

    uint64_t original_time = 0;
    uint64_t timer = 0;
    int pcount = 1;
    int epoch_pcount = 0;
    char content[50000];
    uint64_t current_time;
    int temp;
    int total = 0;
    int count = 0;
    params.current_epoch_count = 1;

    cout << params.pcount_dir << endl;
    vector<int> pcount_list;
    FILE* fp = fopen(params.pcount_dir, "r");
    for(int i=0; i<80; i++) {
        fscanf(fp, "%d ", &temp);
        pcount_list.push_back(temp);
        total += temp;
    }

    sprintf(content, "\t\t epoch %d start", params.current_epoch_count);
    cout << content << endl;

    vector<packet_summary>::iterator p;
    for (p = packet_stream.begin(); p != packet_stream.end(); p++, pcount++) {
        current_time = p->timestamp;
        if (timer == 0) {
            timer = current_time;
            original_time = current_time;
        }

        if(params.current_epoch_count > (60 / params.epoch)+3) {
            exit(1);
        }

        if (pcount_list[params.current_epoch_count] == 0) {
            sketch_iteration_instance->file_print(params);
            sketch_iteration_instance->clear(params);
            epoch_pcount = 0;
            params.current_epoch_count++;

            sprintf(content, "\t\t%s %s (%d/%lu)-(%.2f%%) %.4f (s) duration(%.4f)", params.run_info, params.hash_seed_name, pcount, packet_stream.size(), (float)pcount*100 / (float)packet_stream.size(), ((double)current_time - (double)original_time)/1000000, ((double)current_time - (double)timer)/1000000);
            cout << content << endl;
            sprintf(content, "\n\t\t epoch %d start", params.current_epoch_count);
            cout << content << endl;

            timer = current_time;
            p--;
            pcount--;
            continue;
        }

        count++;
        epoch_pcount++;
        sketch_iteration_instance->iteration(*p, params);

        if (epoch_pcount >= pcount_list[params.current_epoch_count]) {
            sketch_iteration_instance->file_print(params);
            sketch_iteration_instance->clear(params);
            epoch_pcount = 0;
            params.current_epoch_count++;

            sprintf(content, "\t\t%s %s (%d/%lu)-(%.2f%%) %.4f (s) duration(%.4f)", params.run_info, params.hash_seed_name, pcount, packet_stream.size(), (float)pcount*100 / (float)packet_stream.size(), ((double)current_time - (double)original_time)/1000000, ((double)current_time - (double)timer)/1000000);
            cout << content << endl;
            sprintf(content, "\n\t\t epoch %d start", params.current_epoch_count);
            cout << content << endl;

            timer = current_time;
        }
    }

    sketch_iteration_instance->file_print(params);
    sketch_iteration_instance->clear(params);
    sprintf(content, "\t\t%s %s (%d/%lu)-(%.2f%%) %.4f (s) duration(%.4f)", params.run_info, params.hash_seed_name, pcount-1, packet_stream.size(), (float)pcount*100 / (float)packet_stream.size(), ((double)current_time - (double)original_time)/1000000, ((double)current_time - (double)timer)/1000000);
    cout << content << endl;
    // * file print and clear *
    //
    cout << "count: " << count << endl;
}



void main_loop_sketchmd(parameters &params, vector<packet_summary> &packet_stream, sketchIterationTemplate* sketch_iteration_instance)
{
    printf("main loop sketchmd\n");

    uint64_t original_time = 0;
    uint64_t timer = 0;
    int pcount = 1;
    int epoch_pcount = 0;
    char content[50000];
    uint64_t current_time;
    int temp;
    int total = 0;
    int count = 0;
    params.current_epoch_count = 0;

    // int debug_count = 0;

    cout << params.pcount_dir << endl;
    vector<int> pcount_list;
    FILE* fp = fopen(params.pcount_dir, "r");
    for(int i=0; i<80; i++) {
        fscanf(fp, "%d ", &temp);
        pcount_list.push_back(temp);
        total += temp;
        // cout << temp << endl;
    }
    
    // cout << "data plane total: " << total << endl;
    // cout << "simulator total " << packet_stream.size() << endl;
    // exit(1);

    sprintf(content, "\t\t epoch %d start", params.current_epoch_count);
    cout << content << endl;
    cout << params.epoch << endl;

    vector<packet_summary>::iterator p;
    for (p = packet_stream.begin(); p != packet_stream.end(); p++, pcount++) {
        current_time = p->timestamp;
        if (timer == 0) {
            timer = current_time;
            original_time = current_time;
        }


        count++;
        // if (p->src_ip == 2464186718 && p->dst_ip == 1875764454 && p->src_port == 55137 && p->dst_port == 8080 && p->ip_proto == 17) {
        //     if (count >=109880 && count <= 17223228) {
        //         debug_count += 1;
        //         cout << count << " " << debug_count << endl;
        //     }
        //     // if(debug_count % 500 == 0) {
        //     //     cout << count << " " << debug_count << endl;
        //     // }
        // }

        // // if (count % 500000 == 0) {
        // //     cout << count << " " << p->src_ip << " " << p->dst_ip << " " << p->src_port << " " << p->dst_port << " " << p->ip_proto << endl;
        // // }
        epoch_pcount++;
        sketch_iteration_instance->iteration(*p, params);

        if (epoch_pcount >= pcount_list[params.current_epoch_count]) {
            epoch_pcount = 0;
            sprintf(content, "\t\t%s %s (%d/%lu)-(%.2f%%) %.4f (s) duration(%.4f)", params.run_info, params.hash_seed_name, pcount, packet_stream.size(), (float)pcount*100 / (float)packet_stream.size(), ((double)current_time - (double)original_time)/1000000, ((double)current_time - (double)timer)/1000000);
            cout << content << endl;
            // sprintf(content, "\n\t\t epoch %d start", params.current_epoch_count);
            // cout << content << endl;
            if (params.current_epoch_count % (params.epoch/10) == 0) {
                sprintf(content, "\t\tepoch (%ds) and now is %d, file save!", params.epoch, params.current_epoch_count);
                cout << content << endl;
                sketch_iteration_instance->file_print(params);
                sketch_iteration_instance->clear(params);
            }
            params.current_epoch_count++;
            timer = current_time;
        }


        //     timer = current_time;
        // }
    }

    sprintf(content, "\t\tepoch (%ds) and now is %d, file save!", params.epoch, params.current_epoch_count);
    cout << content << endl;
    sketch_iteration_instance->file_print(params);
    sketch_iteration_instance->clear(params);
    // sprintf(content, "\t\t%s %s (%d/%lu)-(%.2f%%) %.4f (s) duration(%.4f)", params.run_info, params.hash_seed_name, pcount-1, packet_stream.size(), (float)pcount*100 / (float)packet_stream.size(), ((double)current_time - (double)original_time)/1000000, ((double)current_time - (double)timer)/1000000);
    // cout << content << endl;
    // * file print and clear *
    //
    cout << "total: " << total << endl;
    cout << "count: " << count << endl;
}
