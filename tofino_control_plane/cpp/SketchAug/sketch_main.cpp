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

#include <iostream>

#include "library/params.h"
#include "common/connection.h"
#include "library/timer.h"
#include "bf_library/register.h"

#include "sketch/mrb/mrb.h"
#include "sketch/cs/cs.h"
#include "sketch/cm/cm.h"
#include "sketch/hll/hll.h"
#include "sketch/univmon/univmon.h"



using namespace std;

pthread_t idle_thread;

static int connFd;

static Connection* conn_instance;
static parameters params;

Timer loop_timer;
void *read_start (void *dummyPt)
{
    char* test = (char*)dummyPt;
    cout << "[CPP] [New Thread] read_start " << endl;

    string tester (test);
    cout << tester << endl;
    strcpy(params.test_type, test);
    parse_msg(params);

    int epoch = params.epoch;
    // cout << params.mode << endl;
    // cout << params.op << endl;
    // cout << params.epoch << endl;
    // cout << params.array_size << endl;
    // cout << params.pcap_name << endl;
    // cout << params.date << endl;

    params.connection = conn_instance;

    if (strcmp(params.op, "read") == 0) {
        cout << "[CPP] wait for 1 sec" << endl;
        // // usleep(626 * 1000); // 626ms
        sleep(1); // 1000ms

        conn_instance->table_init(params);

        double ms_delay;
        for(int e_count=1; e_count<=60/epoch+1; e_count++) {

            loop_timer.start();

            conn_instance->sketch_main_loop(params, e_count);
            // if (e_count == 5) {
            //     break;
            // }

            ms_delay = loop_timer.lap();
            if (e_count == 60/epoch+1) { // extra, just in case
                sleep(3);
            }
            else {
                usleep(epoch * 1000 * 1000 - ms_delay * 1000 - 110);
            }
        }
    }

    if (strcmp(params.op, "read_test") == 0) {
        conn_instance->table_init(params);
        conn_instance->sketch_main_loop(params, 0);
    }
}

void tcp_listen()
{
    int pId, portNo, listenFd;
    portNo = 10001;
    socklen_t len; //store size of the address
    bool loop = false;
    struct sockaddr_in svrAdd, clntAdd;

    pthread_t threadA[1000];
    
    listenFd = socket(AF_INET, SOCK_STREAM, 0);
    
    if(listenFd < 0) {
        cout << "Cannot open socket" << endl;
        return;
    }
    int opt=1;
    if (setsockopt(listenFd, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT,
                                                  &opt, sizeof(opt)))
    {
        cout << "setsockopt error" << endl;
        return;
    }

    for(int i=0; i<=10; i++) {
        
        bzero((char*) &svrAdd, sizeof(svrAdd));
        
        svrAdd.sin_family = AF_INET;
        svrAdd.sin_addr.s_addr = INADDR_ANY;
        svrAdd.sin_port = htons(portNo);
        
        //bind socket
        if(bind(listenFd, (struct sockaddr *)&svrAdd, sizeof(svrAdd)) < 0) {
            cerr << "[TCP] Cannot bind" << endl;
            sleep(1);
        }
        else {
            break;
        }
    }
    
    listen(listenFd, 5);
    len = sizeof(clntAdd);

    int noThread = 0;
    while (noThread < 1000)
    {
        cout << "[CPP] [TCP] Listening" << endl;

        //this is where client connects. svr will hang in this mode until client conn
        connFd = accept(listenFd, (struct sockaddr *)&clntAdd, &len);

        if (connFd < 0) {
            cerr << "[CPP] [TCP] Cannot accept connection" << endl;
            return;
        }
        else {
            cout << "[CPP] [TCP] Connection successful" << endl;
        }

        char test[300];
        bzero(test, 301);
        read(connFd, test, 300);
        cout << "[CPP] [TCP] Closing thread and conn" << endl;
        close(connFd);
        if (strcmp(test, "exit") == 0) {
            close(listenFd);
            break;
        }
        pthread_create(&threadA[noThread], NULL, read_start, test); 
        noThread++;
    }
}

int main(int argc, char **argv) {

    // if(argc != 5) {
    //     cout << "usage : ./test [switch ip] [test name] [is_simulator] [str_arg_1]" << endl;
    //     return 0;
    // }

	struct in_addr inaddr;
	int rval;
	if ((rval = inet_pton(AF_INET, argv[1], &inaddr)) == 0)
	{
		printf("Invalid address: %s\n", argv[1]);
		exit(EXIT_FAILURE);
	}

    params.switch_ip = inaddr.s_addr;
    params.sketch_name = argv[2];
    params.str_args_1 = argv[3];
    params.int_args_1 = atoi(argv[4]);
    // params.is_simulator = atoi(argv[3]);

    // put dummy for test_name
    char a[100] = "void";
    params.test_name = a;


    print_params(params);

    CS cs_instance;
    CM cm_instance;
    MRB mrb_instance;
    HLL hll_instance;
    UnivMon univmon_instance;

    if (strcmp(params.sketch_name, "cs") == 0) {
        conn_instance = &cs_instance;
    }

    if (strcmp(params.sketch_name, "cm") == 0) {
        conn_instance = &cm_instance;
    }

    if (strcmp(params.sketch_name, "mrb") == 0) {
        conn_instance = &mrb_instance;
    }

    if (strcmp(params.sketch_name, "hll") == 0) {
        conn_instance = &hll_instance;
    }

    if (strcmp(params.sketch_name, "univmon") == 0) {
        conn_instance = &univmon_instance;
    }

    conn_instance->init(params);

    tcp_listen();

    return 0;
}