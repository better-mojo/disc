use demo_ffi;

fn main() {
    demo_ffi::ffi::generate().expect("Failed to generate headers");
}
