#ifndef _EC_GETLINE_H
#define _EC_GETLINE_H

#include <stdio.h>
#include <stddef.h>

#ifndef EC_GETLINE_SIZE
#define EC_GETLINE_SIZE (256)
#endif

char *ec_getline(FILE *stream);

#endif
