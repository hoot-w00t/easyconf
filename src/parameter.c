#include "easyconf.h"
#include <stdlib.h>
#include <string.h>

ecp_t *ecp_empty(void)
{
    ecp_t *ecp = malloc(sizeof(ecp_t));

    if (ecp) memset(ecp, 0, sizeof(ecp_t));
    return ecp;
}

ecp_t *ecp_create(const char *name, const char *value)
{
    char *d_name = NULL;
    char *d_value = NULL;
    ecp_t *ecp = NULL;

    if (!name || !(d_name = strdup(name)))
        goto fail;
    if (value && !(d_value = strdup(value)))
        goto fail;
    if (!(ecp = malloc(sizeof(ecp_t))))
        goto fail;

    memset(ecp, 0, sizeof(ecp_t));
    ecp->name = d_name;
    ecp->value = d_value;
    return ecp;

fail:
    free(d_name);
    free(d_value);
    free(ecp);
    return NULL;
}

ecp_t *ecp_dup(const ecp_t *ecp)
{
    return ecp ? ecp_create(ecp->name, ecp->value) : NULL;
}

void ecp_free(ecp_t *ecp)
{
    if (ecp) {
        free(ecp->name);
        free(ecp->value);
        free(ecp);
    }
}

int ecp_set_name(ecp_t *ecp, const char *name)
{
    char *d_name;

    if (!ecp || !name) return -1;
    if (!(d_name = strdup(name))) return -1;
    free(ecp->name);
    ecp->name = d_name;
    return 0;
}

int ecp_set_value(ecp_t *ecp, const char *value)
{
    char *d_value;

    if (!ecp) return -1;
    if (value) {
        if (!(d_value = strdup(value))) return -1;
        free(ecp->value);
        ecp->value = d_value;
    } else {
        free(ecp->value);
        ecp->value = NULL;
    }
    return 0;
}