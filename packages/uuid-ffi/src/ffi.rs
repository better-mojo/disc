use ::safer_ffi::prelude::*;

/// A `struct` usable from both Rust and C
#[derive_ReprC]
#[repr(C)]
#[derive(Debug, Clone, Copy)]
pub struct Point {
    x: f64,
    y: f64,
}

/* Export a Rust function to the C world. */
/// Returns the middle point of `[a, b]`.
#[ffi_export]
fn mid_point(a: &Point, b: &Point) -> Point {
    Point {
        x: (a.x + b.x) / 2.,
        y: (a.y + b.y) / 2.,
    }
}

/// Pretty-prints a point using Rust's formatting logic.
#[ffi_export]
fn print_point(point: &Point) {
    println!("{:?}", point);
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

//
// use in gen/gen.rs
//
pub fn generate() -> ::std::io::Result<()> {
    ::safer_ffi::headers::builder()
        .with_language(safer_ffi::ඞ::Language::Python)
        .to_file("py.cffi")?
        .generate()?;

    ::safer_ffi::headers::builder()
        .to_file("cffi.h")?
        .generate()?;

    Ok(())
}
