#include <iostream>
#include <execinfo.h>
#include <signal.h>

#include "unistd.h"
#include "getopt.h"

#include "library/params.h"
#include "library/pcap_helper.h"
#include "library/timer.h"
#include "library/flowkey.h"
#include "library/main_loop.h"

#include "file_io/cpp/sw_simulator/file_path.h"

#include "sketches/sketch_iteration_template.h"

#include "sketches/gt_iteration.h"
#include "sketches/univmon_iteration.h"
#include "sketches/mrac_iteration.h"
#include "sketches/hll_iteration.h"
#include "sketches/ll_iteration.h"
#include "sketches/lc_iteration.h"
#include "sketches/cs_iteration.h"
#include "sketches/cm_iteration.h"
#include "sketches/fcm_iteration.h"
#include "sketches/mrb_iteration.h"


using namespace std;

void sighandler(int sig);

int main(int argc, char* argv[])
{
    signal(SIGSEGV, sighandler);

	int c;

	int count = 0;

	parameters params;
    params.is_same_level_hash = 0;
    params.is_crc_hash = 0;
    params.is_compact_hash = 0;
    params.is_update_last_level = 0;
    params.epoch = 30;
    params.threshold = 99999999;
    params.seed = 1;
    params.xor_hash_type = 1;
    params.is_hardware = 0;

    static struct option long_options[] =
    {
        {"hash_type",           required_argument, 0, 'a'},
        {"crc_hash_on",         no_argument,       0, 'c'},
        {"depth",               required_argument, 0, 'd'},
        {"epoch",               required_argument, 0, 'e'},
        {"pcap_file_path",      required_argument, 0, 'f'},
        {"hardware_pcount_path",required_argument, 0, 'g'},
        {"same_level_hash_on",  no_argument,       0, 'h'},
        {"threshold",           required_argument, 0, 'i'},
        {"seed",                required_argument, 0, 'j'},
        {"key",                 required_argument, 0, 'k'},
        {"level",               required_argument, 0, 'l'},
        {"compact_hash_on",     no_argument,       0, 'm'},
        {"pcap_file_name",      required_argument, 0, 'n'},
        {"output_folder_path",  required_argument, 0, 'o'},
        {"is_count_packet",     required_argument, 0, 'p'},
        {"run",                 required_argument, 0, 'r'},
        {"topk",                required_argument, 0, 't'},
        {"update_last_level_on",no_argument,       0, 'u'},
        {"width",               required_argument, 0, 'w'},
        {"run_info",            required_argument, 0, 'z'},
        {0, 0, 0, 0}
    };

    char run[100];

    int option_index = 0;
    while(true) {

        c = getopt_long(argc, argv, "a:cd:e:f:g:hi:j:k:l:mn:o:p:r:t:uw:z:", long_options, &option_index);

        if (c == -1)
            break;
		switch(c) {
            // common parameters
			case 'f':
				memcpy(params.pcap_file_path, optarg, 500);
				break;
			case 'k':
				memcpy(params.key, optarg, 500);
				break;
            case 'p':
                params.is_count_packet = atoi(optarg);
                break;
            case 'o':
                memcpy(params.output_folder_arg, optarg, 500);
                // memcpy(params.output_dir, optarg, 500);
                break;
            case 'n':
                memcpy(params.pcap_file_name, optarg, 500);
                break;
            case 'e':
                params.epoch = atoi(optarg);
                break;

            // univmon specific
			case 't':
				params.topk_heavy_hitter = atoi(optarg);
				break;
			case 'd':
				params.depth = atoi(optarg);
				break;
			case 'w':
				params.width = atoi(optarg);
				break;
			case 'l':
				params.level = atoi(optarg);
				break;

            // run parameter
		    case 'r':
                memcpy(run, optarg, 100);
		        break;

            // heavy flowkey threshold
			case 'i':
				params.threshold = atoi(optarg);
				break;
            // seed
			case 'j':
				params.seed = atoi(optarg);
				break;

            // yes or no
            case 'h':
                params.is_same_level_hash = 1;
                break;
            case 'c':
                params.is_crc_hash = 1;
                break;
            case 'm':
                params.is_compact_hash = 1;
                break;
            case 'u':
                params.is_update_last_level = 1;
                break;

            case 'g':
                params.is_hardware = 1;
                memcpy(params.pcount_dir, optarg, 500);
                break;

		    case 'z':
                memcpy(params.run_info, optarg, 300);
                break;

		    case 'a':
                params.xor_hash_type = atoi(optarg);
                break;

            // error
			case '?':
				printf("Unknown flag : %c, exit\n", optopt);
				exit(0);
				break;
		}
		count++;
	}

    // This topk value is fixed to 200 for now
    params.topk_heavy_hitter = 200;

    parse_key_flags(params);
    cout << params.key << endl;
//    print_flowkey_flags(params.flowkey_flags);

    sketchIterationTemplate* sketch_iteration_instance;

    gtIteration gt_iteration;

    univmonIteration univmon_iteration;
    mracIteration mrac_iteration;
    hllIteration hll_iteration;
    llIteration ll_iteration;
    lcIteration lc_iteration;
    csIteration cs_iteration;
    cmIteration cm_iteration;
    fcmIteration fcm_iteration;
    mrbIteration mrb_iteration;

    if(strcmp(run, "gt") == 0) {
        sketch_iteration_instance = &gt_iteration;
    }
    else if(strcmp(run, "univmon") == 0) {
        sketch_iteration_instance = &univmon_iteration;
    }
    else if(strcmp(run, "mrac") == 0) {
        sketch_iteration_instance = &mrac_iteration;
    }
    else if(strcmp(run, "hll") == 0) {
        sketch_iteration_instance = &hll_iteration;
    }
    else if(strcmp(run, "ll") == 0) {
        sketch_iteration_instance = &ll_iteration;
    }
    else if(strcmp(run, "lc") == 0) {
        sketch_iteration_instance = &lc_iteration;
    }
    else if(strcmp(run, "cs") == 0) {
        sketch_iteration_instance = &cs_iteration;
    }
    else if(strcmp(run, "cm") == 0) {
        sketch_iteration_instance = &cm_iteration;
    }
    else if(strcmp(run, "fcm") == 0) {
        sketch_iteration_instance = &fcm_iteration;
    }
    else if(strcmp(run, "mrb") == 0) {
        sketch_iteration_instance = &mrb_iteration;
    }
    else {
        cout << "no sketch is selected, exit" << endl;
        exit(1);
    }

    // * init *
    sketch_iteration_instance->init(params);

    // int seed = 1;
    int seed = params.seed;
    sprintf(params.hash_seed_name, "%02d.txt", seed);

    // set_dir(params);
    sprintf(params.output_dir, "%s/", params.output_folder_arg);
    // cout << "output_dir: " << params.output_dir << endl;

    // if(strcmp(run, "gt") != 0) {
    //     set_hash_seed_name_dir(params);
    // }
    // else {
    //     set_dir(params);
    // }

    // if (dir_exist(string(params.output_dir) + "/01") == true) {
    //     printf("DIR Exist, Exit!\n");
    //     exit(1);
    // }


    Timer pcap_timer("pcap parse");
    vector<packet_summary> packet_stream;
    pcap_parse(params.pcap_file_path, packet_stream);
    pcap_timer.stop_and_print();
    
    // * load hash *
    sketch_iteration_instance->load_hash(params);

    if(params.is_hardware) {
        // main_loop_pcount(params, packet_stream, sketch_iteration_instance);
        main_loop_sketchmd(params, packet_stream, sketch_iteration_instance);
    }
    else {
        main_loop(params, packet_stream, sketch_iteration_instance);
    }

    return 0;
}

void print_trace()
{
   printf("%s = %p\n", __func__, print_trace);
//    printf("calle function = 0x%x\n", __builtin_return_address(0));
//    printf("caller function = 0x%x\n", __builtin_return_address(1));
}

void sighandler(int sig)
{
    void *array[10];
    size_t size;
    char **strings;
    size = backtrace(array, 10);
    strings = backtrace_symbols(array, size);
    for(int i = 2; i < size; i++)
        printf("%d: %s\n", i - 2, strings[i]);
    free(strings);
    exit(1);
}
