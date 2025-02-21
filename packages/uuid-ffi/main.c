
#include <stdlib.h>

#include "cffi.h"

int main (int argc, char const * const argv[])
{

    char * uuid = rs_uuid_v4();
    printf("uuid v4: %s\n", uuid);
    free_rs_string(uuid);

    return EXIT_SUCCESS;
}