use safer_ffi::prelude::*;
use std::ffi::CString;
use std::os::raw::c_char;
use uuid::Uuid;

#[ffi_export]
/// 生成新的 UUIDv4
pub fn rs_uuid_v4() -> char_p::Box {
    let id = Uuid::new_v4().to_string().try_into().unwrap();
    println!("rust > uuid v4: {}", id);
    id
}

#[ffi_export]
/// 生成新的 UUIDv4
pub fn rs_gen_uuid_v4(result: *mut u8, size: usize) -> usize {
    const UUID_LEN: usize = 36; // UUID 字符串长度
    const UUID_LEN_WITH_NULL: usize = UUID_LEN + 1; // 包括空字符

    if size < UUID_LEN_WITH_NULL {
        eprintln!("rust > buffer size(min = 37) too small for UUIDv4");
        return 0; // 返回错误码表示缓冲区太小
    }

    let id = Uuid::new_v4().to_string();
    println!("rust > uuid v4: {}", id);
    let c_str = CString::new(id).unwrap();
    let bytes = c_str.as_bytes_with_nul();

    unsafe {
        std::ptr::copy_nonoverlapping(bytes.as_ptr(), result, UUID_LEN_WITH_NULL);
    }

    UUID_LEN // 返回实际写入的字节数（不包括空字符）
}

#[ffi_export]
/// 生成新的 UUIDv4
pub fn rs_uuid_v7() -> char_p::Box {
    let id = Uuid::now_v7().to_string().try_into().unwrap();
    println!("rust > uuid v7: {}", id);
    id
}

#[ffi_export]
/// 生成新的 UUIDv7
pub fn rs_gen_uuid_v7(result: *mut u8, size: usize) -> usize {
    const UUID_LEN: usize = 36; // UUID 字符串长度
    const UUID_LEN_WITH_NULL: usize = UUID_LEN + 1; // 包括空字符

    if size < UUID_LEN_WITH_NULL {
        eprintln!("rust > buffer size(min = 37) too small for UUIDv7");
        return 0; // 返回错误码表示缓冲区太小
    }

    let id = Uuid::now_v7().to_string();
    println!("rust > uuid v7: {}", id);
    let c_str = CString::new(id).unwrap();
    let bytes = c_str.as_bytes_with_nul();

    unsafe {
        std::ptr::copy_nonoverlapping(bytes.as_ptr(), result, UUID_LEN_WITH_NULL);
    }

    UUID_LEN // 返回实际写入的字节数（不包括空字符）
}

/// Frees a Rust-allocated string.
#[ffi_export]
fn free_rs_string(string: char_p::Box) {
    let str = string.to_str();
    println!("rust > freeing string: {:?}, raw: {:?}", str, string);
    drop(string)
}

#[ffi_export]
/// 格式化 UUID 为字符串
pub fn uuid_to_string(bytes: &[u8; 16]) -> char_p::Box {
    match Uuid::from_slice(bytes) {
        Ok(uuid) => uuid.to_string().try_into().unwrap(),
        Err(_) => "invalid_uuid".to_string().try_into().unwrap(),
    }
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

// 单元测试模块
// #[cfg(test)]
// mod tests {
//     use super::*;
//     use safer_ffi::char_p;
//
//     #[test]
//     fn test_uuid_generate() {
//         let uuid_str = uuid_generate();
//         let rust_str = uuid_str.to_string();
//         assert_eq!(rust_str.len(), 36);
//         assert!(Uuid::parse_str(&rust_str).is_ok());
//     }
//
//     #[test]
//     fn test_uuid_parse() {
//         let valid = char_p::new("67e55044-10b1-426f-9247-bb680e5fe0c8");
//         let invalid = char_p::new("invalid");
//
//         let mut buffer = [0u8; 16];
//
//         assert_eq!(uuid_parse(&valid, &mut buffer), 0);
//         assert_eq!(uuid_parse(&invalid, &mut buffer), -1);
//     }
//
//     #[test]
//     fn test_uuid_to_string() {
//         let bytes = [
//             0x12, 0x3e, 0x45, 0x67, 0x98, 0xab, 0xcd, 0xef, 0x12, 0x34, 0x56, 0x78, 0x90, 0x12,
//             0x34, 0x56,
//         ];
//
//         let uuid_str = uuid_to_string(&bytes);
//         assert_eq!(uuid_str.to_string(), "123e4567-98ab-cdef-1234-567890123456");
//     }
// }
