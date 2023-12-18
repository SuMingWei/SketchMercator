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

#include "sketch/w1/w1.h"
#include "sketch/w2/w2.h"
#include "sketch/w3/w3.h"
#include "sketch/w4/w4.h"

using namespace std;

pthread_t idle_thread;

static int connFd;

static Connection* conn_instance;
static parameters params;

Timer loop_timer;
void *msg_receive (void *dummyPt)
{
    char* msg = (char*)dummyPt;
    cout << "[CPP] [New Thread] msg_receive " << endl;

    string msg_string (msg);
    cout << msg_string << endl;
    strcpy(params.msg, msg);
    parse_msg(params);

    // int epoch = params.epoch;
    cout << params.op << endl;
    cout << params.pcap_name << endl;
    cout << params.date << endl;

    params.connection = conn_instance;

    if (strcmp(params.op, "test") == 0) {
        conn_instance->table_init(params);
        conn_instance->test(params);
    }

    if (strcmp(params.op, "start") == 0) {
        cout << "[CPP] wait for 1 sec" << endl;
        // usleep(500 * 1000); // 500ms
        sleep(1); // 1000ms

        conn_instance->table_init(params);

        // double ms_delay;
        // double epoch = 4;
        // for(int e_count=0; e_count<=1; e_count++) {
        //     loop_timer.start();

        //     conn_instance->sketch_main_loop(params, e_count);

        //     ms_delay = loop_timer.lap();
        //     usleep(epoch * 1000 * 1000 - ms_delay * 1000 - 110);
        // }
        // conn_instance->sketch_main_loop(params, 2);


        double ms_delay;
        double epoch = 10;
        for(int e_count=0; e_count<=5; e_count++) {
            loop_timer.start();

            conn_instance->sketch_main_loop(params, e_count);

            ms_delay = loop_timer.lap().first;
            usleep(epoch * 1000 * 1000 - ms_delay * 1000 - 110);
            cout << endl;
        }
        conn_instance->sketch_main_loop(params, 6);
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
        pthread_create(&threadA[noThread], NULL, msg_receive, test); 
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
    params.workload_name = argv[2];
    params.program_name = argv[3];
    params.before_after = argv[4];

    print_params(params);

    W1 w1_instance;
    W2 w2_instance;
    W3 w3_instance;
    W4 w4_instance;

    if (strcmp(params.workload_name, "workload_1") == 0) {
        conn_instance = &w1_instance;
    }

    if (strcmp(params.workload_name, "workload_2") == 0) {
        conn_instance = &w2_instance;
    }

    if (strcmp(params.workload_name, "workload_3") == 0) {
        conn_instance = &w3_instance;
    }

    if (strcmp(params.workload_name, "workload_4") == 0) {
        conn_instance = &w4_instance;
    }

    conn_instance->init(params);

    tcp_listen();

    return 0;
}
