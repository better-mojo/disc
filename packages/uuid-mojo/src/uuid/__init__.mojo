from memory import UnsafePointer, memcpy
from sys.ffi import DLHandle, c_char, c_size_t, external_call

import . internal as inner


alias c_void = UInt8
alias c_int32 = Int32
alias c_uint8 = UInt8
alias c_uint32 = UInt32
alias c_uint16 = UInt16

# 字符串指针
alias c_char_ptr = UnsafePointer[c_char]
alias c_void_ptr = UnsafePointer[c_void]


fn uuid_v4() -> c_char_ptr:
    return inner.uuid_v4()


fn uuid_v7() -> c_char_ptr:
    return inner.uuid_v7()


fn free_string(str: c_char_ptr) -> None:
    inner.free_string(str)


fn gen_uuid_v4() -> String:
    # 使用 gen_uuid_v4 和 gen_uuid_v7
    var buf: UnsafePointer[c_uint8] = UnsafePointer[c_uint8].alloc(37)

    var raw = inner.gen_uuid_v4(buf, 37)
    print(raw)

    str = String(buf)
    print(str)

    # 释放分配的内存
    buf.free()
    return str


fn gen_uuid_v7() -> String:
    # 使用 gen_uuid_v4 和 gen_uuid_v7
    var buf: UnsafePointer[c_uint8] = UnsafePointer[c_uint8].alloc(37)

    var raw = inner.gen_uuid_v7(buf, 37)
    print(raw)

    str = String(buf)
    print(str)

    buf.free()
    return str
