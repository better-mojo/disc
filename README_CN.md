<div align="center">

<h3 align="center">Disc</h3>

  <p align="center">
    🦀 为 Mojo 绑定 Rust 库 🔥
    <br/>

![Mojo 版本][language-shield]
[![MIT 许可证][license-shield]][license-url]
[![Pixi 徽章](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/prefix-dev/pixi/main/assets/badge/v0.json)](https://pixi.sh)
<br/>
[![欢迎贡献者][contributors-shield]][contributors-url]

简体中文 | [English](README.md)

  </p>
</div>

## 文档

- <https://better-mojo.github.io/disc/>

## 包列表

| 包                             | 描述 | 托管平台                                                        |
| ----------------------------------- | ----------- | ----------------------------------------------------------- |
| ✅ [uuid-ffi](./packages/uuid-ffi)   | uuid-rs FFI | <https://prefix.dev/channels/better-ffi/packages/libuuid_ffi> |
| ✅ [uuid](./packages/uuid) | uuid mojo   | <https://prefix.dev/channels/better-mojo/packages/uuid>       |
| ✅ [redis-ffi](./packages/redis-ffi) | redis-rs FFI | <https://prefix.dev/channels/better-ffi/packages/libredis_ffi> |
| ✅ [redis](./packages/redis) | redis mojo  | <https://prefix.dev/channels/better-mojo/packages/redis>      |

### 🔥 redis

- [redis](./packages/redis)
- [redis-ffi](./packages/redis-ffi)
- [示例](./packages/redis/examples)

```toml
channels = [
    "https://conda.modular.com/max-nightly",
    "https://repo.prefix.dev/better-ffi",    # 包含 spdlog-ffi 包
    "https://repo.prefix.dev/better-mojo",   # 包含 spdlog mojo 包
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
- [示例](./packages/uuid/examples)

```toml
[dependencies]
mojo = ">=1.0.0b2.dev2026052706,<2"

libuuid_ffi = ">=1.2.1b,<2"
uuid = ">=1.2.2,<2"
```

## 参考

[language-shield]: https://img.shields.io/badge/Mojo%F0%9F%94%A5-25.2-orange

[license-shield]: https://img.shields.io/github/license/better-mojo/jojo?logo=github

[license-url]: https://github.com/better-mojo/jojo/blob/main/LICENSE

[contributors-shield]: https://img.shields.io/badge/contributors-welcome!-blue

[contributors-url]: https://github.com/better-mojo/uuid#contributing

### Mojo FFI 库

- ✅ <https://github.com/better-mojo/uuid>
- ✅ <https://github.com/ehsanmok/sqlite>

### Rust FFI 库

- ✅ <https://github.com/getditto/safer_ffi>
