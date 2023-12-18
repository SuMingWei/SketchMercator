#ifndef LIBRARY_FILE
#define LIBRARY_FILE

#include <vector>
#include <iostream>
#include <time.h>
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

using namespace std;

void file_print_single_row_lib(char* file_path, int array_size, vector<int> &data);
void file_print_multiple_rows_lib(char* file_path, int array_size, vector<int> &data1, vector<int> &data2, vector<int> &data3, vector<int> &data4);

#endif