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
#include "test/read_delay/read_delay.h"
#include "test/hw_behave/hw_behave.h"
#include "test/reset/reset.h"
#include "library/timer.h"

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

void *task1 (void *dummyPt)
{
    cout << "Thread No: " << pthread_self() << endl;

    char test[300];
    bzero(test, 301);

    read(connFd, test, 300);

    string tester (test);
    cout << tester << endl;

    cout << "\nClosing thread and conn" << endl;
    close(connFd);
    strcpy(params.test_type, test);
    conn_instance->test(params);
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
        cerr << "Cannot open socket" << endl;
        return;
    }
    
    bzero((char*) &svrAdd, sizeof(svrAdd));
    
    svrAdd.sin_family = AF_INET;
    svrAdd.sin_addr.s_addr = INADDR_ANY;
    svrAdd.sin_port = htons(portNo);
    
    //bind socket
    if(bind(listenFd, (struct sockaddr *)&svrAdd, sizeof(svrAdd)) < 0) {
        cerr << "Cannot bind" << endl;
        return;
    }
    
    listen(listenFd, 5);
    len = sizeof(clntAdd);    
    int noThread = 0;
    while (noThread < 1000)
    {
        cout << "Listening" << endl;

        //this is where client connects. svr will hang in this mode until client conn
        connFd = accept(listenFd, (struct sockaddr *)&clntAdd, &len);

        if (connFd < 0) {
            cerr << "Cannot accept connection" << endl;
            return;
        }
        else {
            cout << "Connection successful" << endl;
        }
        
        pthread_create(&threadA[noThread], NULL, task1, NULL); 
        
        noThread++;
    }
    for(int i = 0; i < 10; i++)
    {
        pthread_join(threadA[i], NULL);
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
    params.test_name = argv[2];
    char a[100] = "void";
    params.sketch_name = a;
    params.is_simulator = atoi(argv[3]);
    params.str_args_1 = argv[4];

    // params.int_args2 = atoi(argv[4]);

    print_params(params);

    ReadDelay read_delay_instnace;
    HwBehave hw_behave_instance;
    Reset reset_instance;

    if (strcmp(params.test_name, "read_delay") == 0) {
        conn_instance = &read_delay_instnace;
    }
    else if (strcmp(params.test_name, "hw_behave") == 0) {
        conn_instance = &hw_behave_instance;
    }
    else if (strcmp(params.test_name, "reset") == 0) {
        conn_instance = &reset_instance;
    }

    conn_instance->init(params);
    // conn_instance->test(params);

    // for(int j=0; j<100; j++) {
    //     for(int i=0; i<5; i++) {
    //         printf("%d\n", i);
    //         sleep(1);
    //     }
    //     conn_instance->test(params);
    // }

    // while(1) {
    //     printf("hit enter when ready.\n");
    //     int strContent[128] = {0,};
    //     scanf("%s", &strContent);
    //     printf("okay let's test\n");
    //     sleep(1);

    //     conn_instance->test(params);
    // }
    tcp_listen();
    createThread();
    waitOnThreads();

    return 0;
}
