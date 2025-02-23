import uuid


def test_uuid():
    # var id = uuid.uuid_v4()
    # var id2 = uuid.uuid_v7()
    # print(id)
    # print(id2)
    # uuid.free_string(id)
    # uuid.free_string(id2)

    var id3 = uuid.gen_uuid_v4()
    var id4 = uuid.gen_uuid_v7()
    print(id3)
    print(id4)


fn main() raises:
    test_uuid()
