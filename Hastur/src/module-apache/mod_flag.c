// apxs -c -o mod_flag.so mod_flag.c
// strip --strip-debug .libs/mod_flag.so
#include "httpd.h"
#include "http_config.h"
#include <stdio.h>

char flag1[128];
char flag2[128];
static void flag_register_hooks(apr_pool_t *p)
{
    FILE *fp;
    fp = fopen("/flag1", "r");
    if (fp) {
        fgets(flag1, sizeof(flag1), fp);
        fclose(fp);
    }
    fp = fopen("/flag2", "r");
    if (fp) {
        fgets(flag2, sizeof(flag2), fp);
        fclose(fp);
    }
}

/* Dispatch list for API hooks */
module AP_MODULE_DECLARE_DATA flag_module = {
    STANDARD20_MODULE_STUFF,
    NULL,                  /* create per-dir    config structures */
    NULL,                  /* merge  per-dir    config structures */
    NULL,                  /* create per-server config structures */
    NULL,                  /* merge  per-server config structures */
    NULL,                  /* table of config file commands       */
    flag_register_hooks    /* register hooks          */
};
