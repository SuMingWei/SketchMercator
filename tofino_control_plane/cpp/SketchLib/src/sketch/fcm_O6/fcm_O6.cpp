#include "fcm_O6.h"

extern std::shared_ptr<bfrt::BfRtSession> session;
extern int isPrint;

FCM_O6::FCM_O6()
{
}

void FCM_O6::init(parameters &params)
{
    cout << "[CPP] [FCM_O6] init" << endl;

    sprintf(params.program_name, "p416_eval_fcm");
    cout << params.program_name << endl;

    Connection::init(params);
}


void FCM_O6::read(parameters &params)
{
    cout << "[CPP] [FCM_O6] read" << endl;
}

void FCM_O6::reset(parameters &params)
{
    cout << "[CPP] [FCM_O6] reset" << endl;
}
