from memory import UnsafePointer
from sys.param_env import is_defined
from sys import os_is_macos
from sys.ffi import DLHandle, c_char, c_size_t, external_call
from memory import UnsafePointer, memcpy


alias c_void = UInt8
alias c_int32 = Int32
alias c_uint8 = UInt8
alias c_uint32 = UInt32
alias c_uint16 = UInt16


# 字符串指针
alias c_char_ptr = UnsafePointer[c_char]
alias c_void_ptr = UnsafePointer[c_void]


@always_inline("nodebug")
fn is_static_build() -> Bool:
    """
    Returns True if the build is in debug mode.

    Returns:
        Bool: True if the build is in debug mode and False otherwise.
    """

    @parameter
    if is_defined["IS_STATIC_BUILD"]():
        return True
    return False


################################################################################


fn get_libname() -> StringLiteral:
    @parameter
    if os_is_macos():
        return "libuuid_ffi.dylib"
    else:
        return "libuuid_ffi.so"


alias LIBNAME = get_libname()


# fn alias:
alias fn_rs_uuid_v4 = fn () -> c_char_ptr
alias fn_rs_uuid_v7 = fn () -> c_char_ptr
alias fn_rs_free_string = fn (string: c_char_ptr) -> None
alias fn_rs_gen_uuid_v4 = fn (
    result: UnsafePointer[c_uint8], size: c_size_t
) -> c_size_t
alias fn_rs_gen_uuid_v7 = fn (
    result: UnsafePointer[c_uint8], size: c_size_t
) -> c_size_t


################################################################################
#
# DLHandle
#
var _handle: DLHandle = DLHandle(LIBNAME)

#
# fn
#
var _fn_rs_uuid_v4 = _handle.get_function[fn_rs_uuid_v4]("rs_uuid_v4")
var _fn_rs_uuid_v7 = _handle.get_function[fn_rs_uuid_v7]("rs_uuid_v7")
var _fn_rs_free_string = _handle.get_function[fn_rs_free_string](
    "free_rs_string"
)
var _fn_rs_gen_uuid_v4 = _handle.get_function[fn_rs_gen_uuid_v4](
    "rs_gen_uuid_v4"
)
var _fn_rs_gen_uuid_v7 = _handle.get_function[fn_rs_gen_uuid_v7](
    "rs_gen_uuid_v7"
)


################################################################################
#
# api list
#
fn uuid_v4() -> c_char_ptr:
    @parameter
    if is_static_build():
        # c_char_ptr 为返回值类型
        return external_call["rs_uuid_v4", c_char_ptr]()
    else:
        return _fn_rs_uuid_v4()


fn uuid_v7() -> c_char_ptr:
    @parameter
    if is_static_build():
        return external_call["rs_uuid_v7", c_char_ptr]()
    else:
        return _fn_rs_uuid_v7()


fn free_string(str: c_char_ptr) -> NoneType:
    @parameter
    if is_static_build():
        return external_call["free_rs_string", NoneType](str)
    else:
        return _fn_rs_free_string(str)


fn gen_uuid_v4(result: UnsafePointer[c_uint8], size: c_size_t) -> c_size_t:
    @parameter
    if is_static_build():
        return external_call["rs_gen_uuid_v4", c_size_t](result, size)
    else:
        return _fn_rs_gen_uuid_v4(result, size)


fn gen_uuid_v7(result: UnsafePointer[c_uint8], size: c_size_t) -> c_size_t:
    @parameter
    if is_static_build():
        return external_call["rs_gen_uuid_v7", c_size_t](result, size)
    else:
        return _fn_rs_gen_uuid_v7(result, size)
