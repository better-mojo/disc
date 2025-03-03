/*! \file */
/*******************************************
 *                                         *
 *  File auto-generated by `::safer_ffi`.  *
 *                                         *
 *  Do not manually edit this file.        *
 *                                         *
 *******************************************/

#ifndef __RUST_REQWEST_FFI__
#define __RUST_REQWEST_FFI__
#ifdef __cplusplus
extern "C" {
#endif

/** <No documentation available> */
typedef struct HttpRequest HttpRequest_t;


#include <stddef.h>
#include <stdint.h>

/** <No documentation available> */
/** \remark Has the same ABI as `uint8_t` **/
#ifdef DOXYGEN
typedef
#endif
enum HttpVersion {
    /** <No documentation available> */
    HTTP_VERSION_HTTP09,
    /** <No documentation available> */
    HTTP_VERSION_HTTP10,
    /** <No documentation available> */
    HTTP_VERSION_HTTP11,
    /** <No documentation available> */
    HTTP_VERSION_H2,
    /** <No documentation available> */
    HTTP_VERSION_H3,
    /** <No documentation available> */
    HTTP_VERSION___NON_EXHAUSTIVE,
}
#ifndef DOXYGEN
; typedef uint8_t
#endif
HttpVersion_t;

/** <No documentation available> */
/** \remark Has the same ABI as `uint8_t` **/
#ifdef DOXYGEN
typedef
#endif
enum Method {
    /** <No documentation available> */
    METHOD_OPTIONS,
    /** <No documentation available> */
    METHOD_GET,
    /** <No documentation available> */
    METHOD_POST,
    /** <No documentation available> */
    METHOD_PUT,
    /** <No documentation available> */
    METHOD_DELETE,
    /** <No documentation available> */
    METHOD_HEAD,
    /** <No documentation available> */
    METHOD_TRACE,
    /** <No documentation available> */
    METHOD_CONNECT,
    /** <No documentation available> */
    METHOD_PATCH,
}
#ifndef DOXYGEN
; typedef uint8_t
#endif
Method_t;

/** <No documentation available> */
HttpRequest_t *
new_http_request (
    Method_t method,
    char const * url,
    HttpVersion_t version,
    char const * body);

/** <No documentation available> */
typedef struct HttpResponse HttpResponse_t;

/** <No documentation available> */
void
rs_http_resp_free (
    HttpResponse_t * resp);

/** <No documentation available> */
HttpResponse_t *
rs_send_request (
    HttpRequest_t const * req);


#ifdef __cplusplus
} /* extern \"C\" */
#endif

#endif /* __RUST_REQWEST_FFI__ */
