use redis_ffi;

fn main() {
    #[cfg(feature = "c-headers")]
    redis_ffi::generate_headers().expect("Failed to generate headers");
}
