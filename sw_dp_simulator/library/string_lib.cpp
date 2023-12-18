#include "string_lib.h"

void add_padding(string &temp, string str, int paddedLength)
{
    temp = str;
    temp.insert(temp.begin(), paddedLength - temp.size(), ' ');
}

void parse_delays(char* delay_str, parameters& params)
{
    // string s = string(delay_str);
    // string delimiter = ",";

    // vector<double> delays;
    // size_t pos = 0;
    // string token;
    // while ((pos = s.find(delimiter)) != string::npos) {
    //     token = s.substr(0, pos);
    //     delays.push_back(atof(token.c_str()));
    //     // cout << token << endl;
    //     s.erase(0, pos + delimiter.length());
    // }
    // // cout << s << endl;
    // delays.push_back(atof(s.c_str()));

    // params.delay1 = delays[0];
    // params.delay2 = delays[1];
    // params.delay3 = delays[2];
    // params.delay4 = delays[3];
}
