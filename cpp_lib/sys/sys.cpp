#include "sys.h"

void sys_mkdir(string dir_name)
{
    char cmd[1000];
    sprintf(cmd, "mkdir -p %s", dir_name.c_str());
    // cout << cmd << endl;
    system(cmd);
}

bool dir_exist (const std::string& name) {
    struct stat buffer;
    return (stat (name.c_str(), &buffer) == 0);
}

void folder_iterate(const char *path, vector<string> &strVec)
{
    struct dirent *entry;
    DIR *dir = opendir(path);
    if (dir == NULL) {
        return;
    }

    while ((entry = readdir(dir)) != NULL) {
        if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0) {
            // printf("%s\n", entry->d_name);
            strVec.push_back(string(entry->d_name));
        }
    }

    closedir(dir);
}
