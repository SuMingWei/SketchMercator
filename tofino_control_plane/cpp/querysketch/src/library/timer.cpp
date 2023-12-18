#include "timer.h"

Timer::Timer()
{
    t1 = high_resolution_clock::now();
    t2 = high_resolution_clock::now();
}

void Timer::start()
{
    t1 = high_resolution_clock::now();
    t2 = high_resolution_clock::now();
}

pair<double, double> Timer::lap()
{
    t3 = high_resolution_clock::now();

    // auto ms_int_total = duration_cast<milliseconds>(t3 - t1);
    duration<double, milli> ms_double_total = t3 - t1;

    // auto ms_int_lap = duration_cast<milliseconds>(t3 - t2);
    duration<double, milli> ms_double_lap = t3 - t2;
    pair<double, double> p;
    p.first = ms_double_total.count();
    p.second = ms_double_lap.count();

    t2 = t3;
    return p;
}
