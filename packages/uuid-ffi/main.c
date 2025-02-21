
#include <stdlib.h>

#include "cffi.h"

int main (int argc, char const * const argv[])
{

    char * uuid_v4 = rs_uuid_v4();
    char * uuid_v7 = rs_uuid_v7();

    printf("uuid v4: %s\n", uuid_v4);
    printf("uuid v7: %s\n", uuid_v7);


    // free memory
    free_rs_string(uuid_v4);
    free_rs_string(uuid_v7);

    return EXIT_SUCCESS;
}