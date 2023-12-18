#ifndef TIMER_H
#define TIMER_H

#include <stdio.h>

#include <iostream>
#include <chrono>

using namespace std;
using namespace std::chrono;

class Timer {
public:

    high_resolution_clock::time_point t1;
    high_resolution_clock::time_point t2;
    high_resolution_clock::time_point t3;

    Timer();

    void start();
    pair<double, double> lap();
    // void print(char* content);
};

#endif
