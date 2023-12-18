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
// #include "library/timer.h"
// #include "bf_library/register.h"

#include "sketch/cm_O6/cm_O6.h"
#include "sketch/fcm_topk/fcm_topk.h"
#include "sketch/fcm_O6/fcm_O6.h"


using namespace std;

pthread_t idle_thread;

void *idleFunction(void *args)
{
    printf("idleFunction thread started..\n");
    while (1) {
        sleep(10);
    }
}

void createThread()
{
    pthread_create(&idle_thread, NULL, idleFunction, NULL);
}

void waitOnThreads()
{
    pthread_join(idle_thread, NULL);
}

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
    printf("[parse_msg]\n");
    cout << params.op << endl;
    cout << params.pcap_name << endl;


    params.connection = conn_instance;

    if (strcmp(params.op, "read") == 0) {
        printf("read received!\n");
        conn_instance->read(params);
    }

    if (strcmp(params.op, "reset") == 0) {
        printf("reset received!\n");
        conn_instance->reset(params);
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
    // params.str_args_1 = argv[3];
    // params.int_args_1 = atoi(argv[4]);
    // params.is_simulator = atoi(argv[3]);

    // put dummy for test_name
    char a[100] = "void";
    params.test_name = a;


    print_params(params);

    CM_O6 cs_instance;
    FCM_O6 fcm_instance;
    FCM_TOPK fcm_topk_instance;

    if (strcmp(params.sketch_name, "cm_O6") == 0) {
        conn_instance = &cs_instance;
    }

    if (strcmp(params.sketch_name, "fcm_O6") == 0) {
        conn_instance = &fcm_instance;
    }

    if (strcmp(params.sketch_name, "fcm_topk") == 0) {
        conn_instance = &fcm_topk_instance;
    }

    conn_instance->init(params);

    // tcp_listen();
    createThread();
    waitOnThreads();

    return 0;
}