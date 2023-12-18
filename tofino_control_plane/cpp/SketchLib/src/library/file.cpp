#include "file.h"

void file_print_single_row_lib(char* file_path, int array_size, vector<int> &data)
{
    FILE * f = fopen(file_path, "w");
    int count = 0;
    for (auto& d : data) {
        fprintf(f, "%d\n", d);
        count += 1;
    }
    fclose(f);
}

void file_print_multiple_rows_lib(char* file_path, vector<int> &data1, vector<int> &data2, vector<int> &data3, vector<int> &data4, vector<int> &data5, vector<int> &data6)
{
    FILE * f = fopen(file_path, "w");
    for (auto& d : data1) {
        fprintf(f, "%d\n", d);
    }
    for (auto& d : data2) {
        fprintf(f, "%d\n", d);
    }
    for (auto& d : data3) {
        fprintf(f, "%d\n", d);
    }
    for (auto& d : data4) {
        fprintf(f, "%d\n", d);
    }
    for (auto& d : data5) {
        fprintf(f, "%d\n", d);
    }
    for (auto& d : data6) {
        fprintf(f, "%d\n", d);
    }
    fclose(f);
}
