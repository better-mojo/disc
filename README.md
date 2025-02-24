
<div align="center">

<h3 align="center">Disc</h3>

  <p align="center">
    🦀 binding rust libraries to mojo 🔥
    <br/>

![Mojo Version][language-shield]
[![MIT License][license-shield]][license-url]
[![Pixi Badge](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/prefix-dev/pixi/main/assets/badge/v0.json)](https://pixi.sh)
<br/>
[![Contributors Welcome][contributors-shield]][contributors-url]

[简体中文](README_CN.md) | English

  </p>
</div>

## Docs

- https://better-mojo.github.io/disc/

## Packages

| Package                             | Description |
| ----------------------------------- | ----------- |
| ✅ [uuid-ffi](./packages/uuid-ffi)   | uuid-rs FFI |
| ✅ [uuid-mojo](./packages/uuid-mojo) | uuid mojo   |


### uuid

```ruby
# add rust(ffi) package
magic add libuuid_ffi  # add channel first: "https://repo.prefix.dev/better-ffi" 

# add mojo package
magic add uuid  # add channel first: "https://repo.prefix.dev/better-mojo" 
```

- example

```python
import uuid


def test_uuid():
    # implement style 1:
    var id = uuid.uuid_v4()  # auto free memory
    var id2 = uuid.uuid_v7()  # auto free memory

    # implement style 2:
    var id3 = uuid.gen_uuid_v4()
    var id4 = uuid.gen_uuid_v7()  # auto free memory

    print(id)
    print(id2)

    print(id3)
    print(id4)


fn main() raises:
    test_uuid()
```




## Reference

[language-shield]: https://img.shields.io/badge/Mojo%F0%9F%94%A5-25.2-orange

[license-shield]: https://img.shields.io/github/license/better-mojo/jojo?logo=github

[license-url]: https://github.com/better-mojo/jojo/blob/main/LICENSE

[contributors-shield]: https://img.shields.io/badge/contributors-welcome!-blue

[contributors-url]: https://github.com/better-mojo/uuid#contributing

[uuid-ffi]: https://prefix.dev/channels/better-ffi/packages/libuuid_ffi

[uuid-mojo]: https://prefix.dev/channels/better-mojo/packages/uuid_mojo





