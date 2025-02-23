from memory import UnsafePointer, memcpy
from sys.ffi import DLHandle, c_char, c_size_t, external_call

import uuid


alias c_void = UInt8
alias c_int32 = Int32
alias c_uint8 = UInt8
alias c_uint32 = UInt32
alias c_uint16 = UInt16


def test_uuid():
    var id = uuid.uuid_v4()
    var id2 = uuid.uuid_v7()
    print(id)
    print(id2)
    uuid.free_string(id)
    uuid.free_string(id2)

    var id3 = uuid.gen_uuid_v4()
    var id4 = uuid.gen_uuid_v7()
    print(id3)
    print(id4)


fn main() raises:
    test_uuid()
