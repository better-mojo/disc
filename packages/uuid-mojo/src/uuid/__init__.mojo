from memory import UnsafePointer, memcpy
from sys.ffi import DLHandle, c_char, c_size_t, external_call
from memory import UnsafePointer, memcpy, stack_allocation
from sys.ffi import DLHandle, c_char, c_size_t
from utils import StringSlice


import . _uuid as inner


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
    """Generate a random uuid v4.
    use stack allocation.
    """
    alias buf_size = 37

    # stack allocation
    var buf = stack_allocation[buf_size, UInt8]()

    # heap allocation
    # var buf: UnsafePointer[c_uint8] = UnsafePointer[c_uint8].alloc(buf_size)

    # call rust ffi function
    var size = inner.gen_uuid_v4(buf, buf_size)

    # convert to string
    var str = String(StringSlice[__origin_of(buf)](ptr=buf, length=UInt(size)))
    return str


fn gen_uuid_v7() -> String:
    """Generate a random uuid v7.
    use heap allocation.
    """
    #
    alias buf_size = 37

    # stack allocation
    # var buf = stack_allocation[buf_size, UInt8]()

    # heap allocation
    var buf: UnsafePointer[c_uint8] = UnsafePointer[c_uint8].alloc(buf_size)

    # call rust ffi function
    var size = inner.gen_uuid_v7(buf, buf_size)

    # convert to string
    var str = String(StringSlice[__origin_of(buf)](ptr=buf, length=UInt(size)))

    # free memory
    buf.free()
    return str
