use reqwest::{Response, blocking::Client};
use safer_ffi::prelude::*;
use std::{collections::HashMap, os::raw::c_char};
use std::{ffi::CString, iter::Map};

#[ffi_export]
#[derive_ReprC]
#[derive(Debug, Clone, Copy)]
#[repr(u8)]
pub enum Method {
    Options,
    Get,
    Post,
    Put,
    Delete,
    Head,
    Trace,
    Connect,
    Patch,
}

#[ffi_export]
#[derive_ReprC]
#[derive(Debug, Clone, Copy, PartialEq, PartialOrd, Eq, Ord, Hash)]
#[repr(u8)]
pub enum HttpVersion {
    Http09,
    Http10,
    Http11,
    H2,
    H3,
    __NonExhaustive,
}

impl From<Method> for http::Method {
    fn from(method: Method) -> Self {
        match method {
            Method::Get => http::Method::GET,
            Method::Post => http::Method::POST,
            Method::Put => http::Method::PUT,
            Method::Delete => http::Method::DELETE,
            Method::Head => http::Method::HEAD,
            Method::Options => http::Method::OPTIONS,
            Method::Connect => http::Method::CONNECT,
            Method::Patch => http::Method::PATCH,
            Method::Trace => http::Method::TRACE,
        }
    }
}

impl From<HttpVersion> for http::Version {
    fn from(version: HttpVersion) -> Self {
        match version {
            HttpVersion::Http09 => http::Version::HTTP_09,
            HttpVersion::Http10 => http::Version::HTTP_10,
            HttpVersion::Http11 => http::Version::HTTP_11,
            HttpVersion::H2 => http::Version::HTTP_2,
            HttpVersion::H3 => http::Version::HTTP_3,
            HttpVersion::__NonExhaustive => http::Version::HTTP_11, // Default to HTTP/1.1
        }
    }
}

impl From<http::Version> for HttpVersion {
    fn from(version: http::Version) -> Self {
        match version {
            http::Version::HTTP_09 => HttpVersion::Http09,
            http::Version::HTTP_10 => HttpVersion::Http10,
            http::Version::HTTP_11 => HttpVersion::Http11,
            http::Version::HTTP_2 => HttpVersion::H2,
            http::Version::HTTP_3 => HttpVersion::H3,
            _ => HttpVersion::__NonExhaustive,
        }
    }
}

// http request
#[ffi_export]
#[derive_ReprC]
#[repr(opaque)]
struct HttpRequest {
    method: http::Method,
    url: String,
    headers: http::HeaderMap,
    version: HttpVersion,
    body: String,
}

impl HttpRequest {
    fn new(
        method: Method,
        url: char_p::Ref<'_>,
        version: HttpVersion,
        body: char_p::Ref<'_>,
    ) -> Self {
        let headers = http::HeaderMap::new();
        let method = method.into();

        Self {
            method,
            url: url.to_string(),
            headers,
            version,
            body: body.to_string(),
        }
    }
}

#[ffi_export]
fn new_http_request(
    method: Method,
    url: char_p::Ref<'_>,
    version: HttpVersion,
    body: char_p::Ref<'_>,
) -> repr_c::Box<HttpRequest> {
    Box::new(HttpRequest::new(method, url, version, body)).into()
}

#[derive_ReprC]
#[repr(opaque)]
struct HttpResponse {
    inner: reqwest::blocking::Response,
}

impl HttpResponse {
    fn new(inner: reqwest::blocking::Response) -> Self {
        Self { inner }
    }

    // free memory
    fn free(self) {
        drop(self);
    }
}

#[ffi_export]
pub fn rs_send_request(req: &HttpRequest) -> repr_c::Box<HttpResponse> {
    let client = Client::new();
    let resp = client
        .request(req.method.clone(), &req.url)
        .headers(req.headers.clone())
        .body(req.body.clone())
        .send()
        .unwrap();

    println!("rs > send request: {:?}", resp);

    Box::new(HttpResponse::new(resp)).into()
}

// free the Box<Response> allocated in Rust
#[ffi_export]
pub fn rs_http_resp_free(resp: repr_c::Box<HttpResponse>) {
    println!("rs > free http response");
    drop(resp);
}

/// The following test function is necessary for the header generation.
#[::safer_ffi::cfg_headers]
#[test]
pub fn generate_headers() -> ::std::io::Result<()> {
    ::safer_ffi::headers::builder()
        .with_language(safer_ffi::ඞ::Language::Python)
        .to_file("py.cffi")?
        .generate()?;

    ::safer_ffi::headers::builder()
        .to_file("cffi.h")?
        .generate()?;

    Ok(())
}
