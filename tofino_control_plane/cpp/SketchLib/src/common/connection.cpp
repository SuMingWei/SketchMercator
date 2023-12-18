#include "connection.h"

std::shared_ptr<bfrt::BfRtSession> session;

static Timer read_reset_timer;
// int isPrint = 1;
int isPrint = 0;

void Connection::init(parameters &params)
{
    cout << "[CPP] [Connection] init" << endl;
    cout << params.program_name << endl;

	dev_tgt.dev_id = 0;
	dev_tgt.pipe_id = ALL_PIPES;
    bf_switchd_context_t *switchd_main_ctx = NULL;
    char install_dir[5000];
    char target_conf_file[5000];
    bf_status_t bf_status;
    // install_dir = getenv("SDE_INSTALL");
    sprintf(install_dir, "/root/bf-sde-9.1.1/install");
    cout << params.program_name << endl;
    sprintf(target_conf_file, "%s/share/p4/targets/tofino/%s.conf", install_dir, params.program_name);
    cout << target_conf_file << endl;

    /* Allocate memory to hold switchd configuration and state */
    if ((switchd_main_ctx = (bf_switchd_context_t *)calloc(1, sizeof(bf_switchd_context_t))) == NULL) {
        printf("ERROR: Failed to allocate memory for switchd context\n");
        return;
    }

    memset(switchd_main_ctx, 0, sizeof(bf_switchd_context_t));
    switchd_main_ctx->install_dir = install_dir;
    switchd_main_ctx->conf_file = target_conf_file;
    switchd_main_ctx->skip_p4 = false;
    switchd_main_ctx->skip_port_add = false;
    switchd_main_ctx->running_in_background = false; 
    switchd_main_ctx->dev_sts_thread = true;
    switchd_main_ctx->dev_sts_port = THRIFT_PORT_NUM;

    bf_status = bf_switchd_lib_init(switchd_main_ctx);
    printf("Initialized bf_switchd, status = %d\n", bf_status);
    printf("bf_switchd_lib_init done\n");

    // Get devMgr singleton instance
    auto &devMgr = bfrt::BfRtDevMgr::getInstance();

    fprintf(stderr, "%s\n", params.program_name);
    // Get bfrtInfo object from dev_id and p4 program name
    bf_status = devMgr.bfRtInfoGet(dev_tgt.dev_id, params.program_name, &bfrtInfo);

    // Create a session object
    session = bfrt::BfRtSession::sessionCreate();
    g_switch_ip = htonl(params.switch_ip);

    if (bf_pkt_alloc(dev_tgt.dev_id, &tx_pkt, 1500, BF_DMA_CPU_PKT_TRANSMIT_0) != 0)
    {
        fprintf(stderr, "Failed to allocate packet buffer\n");
        return;
    }

    // callbackRegister();
    printf("Bfrt setup done! status = %d \n", bf_status);
}

