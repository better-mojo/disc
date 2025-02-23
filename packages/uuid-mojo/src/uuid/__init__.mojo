import . internal as inner


fn gen_uuid_v4():
    var raw = inner.uuid_v4()
    print(raw)

    var id = raw.to_str()

    pass


fn gen_uuid_v7():
    pass
