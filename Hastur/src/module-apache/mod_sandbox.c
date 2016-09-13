// apxs -c -o mod_sandbox.so mod_sandbox.c
// strip --strip-debug .libs/mod_sandbox.so
#include "httpd.h"
#include "http_config.h"
#include "http_protocol.h"
#include "http_connection.h"
#include "ap_config.h"
#include "ap_listen.h"
#include "unixd.h"

const char *user_name = "sandbox", *group_name = "sandbox";
int limit_nproc = 10;
int limit_cpu = 20;
int limit_as = 256*1024*1024;
static void sandbox_drop_privileges(apr_pool_t *pool, server_rec *s)
{
    ap_unixd_config.user_name = user_name;
    ap_unixd_config.group_name = group_name;
    ap_unixd_config.user_id = 65536 + getpid();
    ap_unixd_config.group_id = 65536 + getpid();

    setrlimit(RLIMIT_NPROC, &(struct rlimit){ limit_nproc, limit_nproc });
    setrlimit(RLIMIT_CPU, &(struct rlimit){ limit_cpu, limit_cpu });
    setrlimit(RLIMIT_AS, &(struct rlimit){ limit_as, limit_as });
}

static int sandbox_pre_connection(conn_rec *c, void *csd)
{
    ap_listen_rec *lr;
    /* Close all listening sockets */
    for (lr = ap_listeners; lr; lr = lr->next) {
        apr_socket_close(lr->sd);
    }

    return OK;
}

static void sandbox_register_hooks(apr_pool_t *p)
{
    ap_hook_drop_privileges(sandbox_drop_privileges,
                            NULL, NULL, APR_HOOK_FIRST);
    ap_hook_pre_connection(sandbox_pre_connection, NULL, NULL, APR_HOOK_MIDDLE);
}

/* Dispatch list for API hooks */
module AP_MODULE_DECLARE_DATA sandbox_module = {
    STANDARD20_MODULE_STUFF,
    NULL,                  /* create per-dir    config structures */
    NULL,                  /* merge  per-dir    config structures */
    NULL,                  /* create per-server config structures */
    NULL,                  /* merge  per-server config structures */
    NULL,                  /* table of config file commands       */
    sandbox_register_hooks /* register hooks          */
};
