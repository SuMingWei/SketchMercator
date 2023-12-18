#include "timer.h"

Timer::Timer()
{
    t1 = high_resolution_clock::now();
}

void Timer::start()
{
    t1 = high_resolution_clock::now();
}

double Timer::lap()
{
    t2 = high_resolution_clock::now();
    auto ms_int = duration_cast<milliseconds>(t2 - t1);
    duration<double, milli> ms_double = t2 - t1;
    return ms_double.count();
}
