#include "com.h"

void parse_msg(parameters& params)
{
    string s = string(params.test_type);
    string delimiter = "/";

    vector<int> parse;

    int count = 0;

    size_t pos = 0;
    string token;
    while ((pos = s.find(delimiter)) != string::npos) {
        token = s.substr(0, pos);
        // cout << token << endl;
        if (count == 0) {
            sprintf(params.op ,"%s", token.c_str());
        }
        count++;
        parse.push_back(atoi(token.c_str()));
        // cout << token << endl;
        s.erase(0, pos + delimiter.length());
    }
    sprintf(params.pcap_name, "%s", s.c_str());
}
