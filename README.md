
<div align="center">

<h3 align="center">Disc</h3>

  <p align="center">
    🦀 Binding Rust libraries for Mojo 🔥
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

- <https://better-mojo.github.io/disc/>

## Packages

| Package                             | Description | Host                                                        |
| ----------------------------------- | ----------- | ----------------------------------------------------------- |
| ✅ [uuid-ffi](./packages/uuid-ffi)   | uuid-rs FFI | <https://prefix.dev/channels/better-ffi/packages/libuuid_ffi> |
| ✅ [uuid](./packages/uuid) | uuid mojo   | <https://prefix.dev/channels/better-mojo/packages/uuid>       |
| ✅ [redis-ffi](./packages/redis-ffi) | redis-rs FFI | <https://prefix.dev/channels/better-ffi/packages/libredis_ffi> |
| ✅ [redis](./packages/redis) | redis mojo  | <https://prefix.dev/channels/better-mojo/packages/redis>      |

### 🔥 redis

- [redis](./packages/redis)
- [redis-ffi](./packages/redis-ffi)
- [examples](./packages/redis/examples)

```toml
channels = [
    "https://conda.modular.com/max-nightly",
    "https://repo.prefix.dev/better-ffi",    # contains spdlog-ffi package
    "https://repo.prefix.dev/better-mojo",   # contains spdlog mojo package
    "conda-forge",
]

[dependencies]
mojo = ">=1.0.0b2.dev2026052706,<2"

libredis_ffi = ">=1.2.1b,<2"
redis = ">=1.2.2,<2"

```

- usage:

<img width="600" alt="image" src="https://github.com/user-attachments/assets/ac6d46cd-5085-4f5b-a1cd-c4cca71b237e" />

### 🔥 uuid

- [uuid](./packages/uuid)
- [uuid-ffi](./packages/uuid-ffi)
- [examples](./packages/uuid/examples)

```toml
[dependencies]
mojo = ">=1.0.0b2.dev2026052706,<2"

libuuid_ffi = ">=1.2.1b,<2"
uuid = ">=1.2.2,<2"
```

## Reference

[language-shield]: https://img.shields.io/badge/Mojo%F0%9F%94%A5-25.2-orange

[license-shield]: https://img.shields.io/github/license/better-mojo/jojo?logo=github

[license-url]: https://github.com/better-mojo/jojo/blob/main/LICENSE

[contributors-shield]: https://img.shields.io/badge/contributors-welcome!-blue

[contributors-url]: https://github.com/better-mojo/uuid#contributing

### Mojo FFI Packages

- ✅ <https://github.com/better-mojo/uuid>
- ✅ <https://github.com/ehsanmok/sqlite>

### Rust FFI

- ✅ <https://github.com/getditto/safer_ffi>
