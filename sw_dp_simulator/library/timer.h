#ifndef TIMER_H
#define TIMER_H

#include <stdio.h>

#include <iostream>

using namespace std;

class Timer {
public:

    string title;
    clock_t startTime;
    clock_t endTime;

    Timer(string title);

    void stop_and_print();
    void print(char* content);
};

#endif
