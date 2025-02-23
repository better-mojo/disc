import uuid


def test_uuid():
    var id = uuid.uuid_v4()
    var id2 = uuid.uuid_v7()
    print(id)
    print(id2)
    # uuid.free_string(id)


fn main() raises:
    test_uuid()
