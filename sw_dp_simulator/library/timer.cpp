#include "timer.h"

Timer::Timer(string _title)
{
    title = _title;
    startTime = clock();
//    printf("\t[Timer start] %s\n", title.c_str());
}

void Timer::stop_and_print()
{
    endTime = clock();

    clock_t clockTicksTaken = endTime - startTime;
    double timeInSeconds = clockTicksTaken / (double) CLOCKS_PER_SEC;

    int int_timeInSeconds = timeInSeconds;

    char time_char[100];
    sprintf(time_char, "%02d:%02d:%02d", (int_timeInSeconds/3600), (int_timeInSeconds%3600)/60,  int_timeInSeconds%60);

    printf("\t\t[timer end] %s %s\n\n", title.c_str(), time_char);
}

void Timer::print(char* content)
{
    endTime = clock();

    clock_t clockTicksTaken = endTime - startTime;
    double timeInSeconds = clockTicksTaken / (double) CLOCKS_PER_SEC;

    int int_timeInSeconds = timeInSeconds;

    char time_char[100];
    sprintf(time_char, "%02d:%02d:%02d", (int_timeInSeconds/3600), (int_timeInSeconds%3600)/60,  int_timeInSeconds%60);

    printf("\t\t%s %s\n", content, time_char);
}
