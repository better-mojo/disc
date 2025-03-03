#include <stdlib.h>
#include <stdio.h>
#include "cffi.h"

int main(int argc, char const *const argv[])
{

    // initialize http request
    HttpRequest_t *req = new_http_request(
        METHOD_GET,
        "https://www.rust-lang.org",
        HTTP_VERSION_HTTP11, "");

    // send http request
    HttpResponse_t *response = rs_send_request(req);

    // free memory allocated by Rust
    rs_http_resp_free(response);
    rs_http_req_free(req);

    return EXIT_SUCCESS;
}