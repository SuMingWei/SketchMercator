#include "fcm_topk.h"

extern std::shared_ptr<bfrt::BfRtSession> session;
extern int isPrint;

FCM_TOPK::FCM_TOPK()
{
}

void FCM_TOPK::init(parameters &params)
{
    cout << "[CPP] [FCM_TOPK] init" << endl;

    sprintf(params.program_name, "p414_fcm_topk");
    cout << params.program_name << endl;

    Connection::init(params);
}

void FCM_TOPK::read(parameters &params)
{
    cout << "[CPP] [FCM_TOPK] read" << endl;
}

void FCM_TOPK::reset(parameters &params)
{
    cout << "[CPP] [FCM_TOPK] reset" << endl;
}
