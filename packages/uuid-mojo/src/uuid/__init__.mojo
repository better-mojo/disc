from memory import UnsafePointer, memcpy, stack_allocation
from sys.ffi import DLHandle, c_char, c_size_t, external_call
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


################################################################


# api style 1: c_char_ptr + free function
fn uuid_v4() -> String:
    """Generate uuid v4.
    ref:
        - https://github.com/modular/mojo/blob/369aa88490d48c8fc96e5fa910bc49c171fcb2a5/stdlib/src/pwd/_linux.mojo#L36

    Returns:
        String: uuid.v4().
    """
    alias buf_size = 37

    var buf: UnsafePointer[c_char] = UnsafePointer[c_char].alloc(buf_size)

    # call rust ffi function
    var raw = inner.uuid_v4()

    # memcpy
    memcpy(dest=buf, src=raw, count=buf_size)

    # convert to string
    var str = String(
        StringSlice[__origin_of(buf)](unsafe_from_utf8_cstr_ptr=buf)
    )

    # free memory
    inner.free_string(raw)
    buf.free()
    return str


# api style 1: c_char_ptr + free function
fn uuid_v7() -> String:
    alias buf_size = 37

    var buf: UnsafePointer[c_char] = UnsafePointer[c_char].alloc(buf_size)

    # call rust ffi function
    var raw = inner.uuid_v7()

    # memcpy
    memcpy(dest=buf, src=raw, count=buf_size)

    # convert to string
    var str = String(
        StringSlice[__origin_of(buf)](unsafe_from_utf8_cstr_ptr=buf)
    )

    # free memory
    inner.free_string(raw)
    buf.free()
    return str


################################################################


#
# api style 2: pre allocated buffer + stack allocation
#
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


#
# api style 2: pre allocated buffer + heap allocation
#
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
