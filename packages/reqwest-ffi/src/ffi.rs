use reqwest::{Response, blocking::Client};
use safer_ffi::prelude::*;
use std::{collections::HashMap, os::raw::c_char};
use std::{ffi::CString, iter::Map};

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
/// 生成新的 UUIDv4
pub fn rs_http_get(url: String, params: Vec<(String, String)>) -> repr_c::Box<HttpResponse> {
    let params_str = params
        .into_iter()
        .map(|(k, v)| format!("{}={}", k, v))
        .collect::<Vec<String>>()
        .join("&");
    let uri = format!("{}?{}", url, params_str);
    println!("rs > http get req uri: {}", uri);

    let client = Client::new();
    let resp = client.get(&uri).send().unwrap();
    println!("rs > http get resp = {:?}", resp.text().unwrap());

    Box::new(HttpResponse::new(resp)).into()
}

/// Performs an HTTP POST request to the specified URL with given parameters.
///
/// # Arguments
///
/// * `url` - A String that holds the URL to which the POST request will be sent.
/// * `params` - A Vec of tuples (String, String) representing the key-value pairs
///              to be sent as query parameters in the request.
///
/// # Returns
///
/// A `repr_c::Box<Response>` containing the HTTP response from the server.
/// This boxed response can be used to access the status, headers, and body of the response.
#[ffi_export]
pub fn rs_http_post_form(url: String, form: HashMap<String, String>) -> repr_c::Box<HttpResponse> {
    println!("rs > http post req uri: {}, form: {:?}", url, form);

    let client = Client::new();
    let resp = client.post(&url).form(&form).send().unwrap();
    println!("rs > http post resp = {:?}", resp.status());

    Box::new(HttpResponse::new(resp)).into()
}

// http post json
#[ffi_export]
pub fn rs_http_post_json(url: String, json: HashMap<String, String>) -> repr_c::Box<HttpResponse> {
    println!("rs > http post req uri: {}, json: {:?}", url, json);

    let client = Client::new();
    let resp = client.post(&url).json(&json).send().unwrap();
    println!("rs > http post resp = {:?}", resp.status());

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
