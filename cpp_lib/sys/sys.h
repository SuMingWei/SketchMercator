#ifndef _CPP_LIB_SYS_H

#define _CPP_LIB_SYS_H

#include <iostream>
#include <string>

#include <stdlib.h>
#include <stdio.h>

#include <sys/stat.h>
#include <unistd.h>
#include <fstream>

#include <dirent.h>
#include <sys/types.h>

#include <string.h>
#include <vector>

using namespace std;

void sys_mkdir(string dir_name);
bool dir_exist (const std::string& name);
void folder_iterate(const char *path, vector<string> &strVec);

#endif
