use safer_ffi::prelude::*;
use std::ffi::CString;
use std::os::raw::c_char;

#[ffi_export]
/// 生成新的 UUIDv4
pub fn rs_http_get() -> char_p::Box {
    let body = reqwest::get("https://www.rust-lang.org")
        .await?
        .text()
        .await?;

    println!("body = {body:?}");

    body
}
