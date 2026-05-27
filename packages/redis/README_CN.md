# redis-mojo

- ✅ 基于 FFI 绑定 rust 热门 Redis 客户端库 [redis-rs](https://github.com/redis-rs/redis-rs), 提供给 Mojo 使用。
- ✅ 支持完整的 Redis 数据类型操作：字符串、列表、哈希表、集合等。
- ✅ 自动内存管理，安全高效。

<a name="readme-top"></a>

<!-- 项目 LOGO -->
<br />
<div align="center">

<h3 align="center">Redis Mojo</h3>

  <p align="center">
    🔥 为 Mojo 绑定 redis-rs Redis 客户端库 🔥
    <br/>

![Mojo 版本][language-shield]
[![MIT 许可证][license-shield]][license-url]
[![Pixi 徽章](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/prefix-dev/pixi/main/assets/badge/v0.json)](https://pixi.sh)
<br/>
[![欢迎贡献者][contributors-shield]][contributors-url]

简体中文 | [English](README.md)

  </p>
</div>

## 包内容

| 项目                             | 包地址                 | 包托管平台     | 等级   | 描述                              |
|-------------------------------------|-------------------------|-----------| -------|------------------------------------------|
| ✅ [redis-ffi](../redis-ffi)   | [libredis_ffi](https://prefix.dev/channels/better-ffi/packages/libredis_ffi) | [prefix.dev](https://prefix.dev/channels/better-ffi) | ⭐️⭐️⭐️ | redis-rs ffi 包                              |
| ✅ [redis](./redis) | [redis](https://prefix.dev/channels/better-mojo/packages/redis)  | [prefix.dev](https://prefix.dev/channels/better-mojo) | ⭐️⭐️⭐️⭐️   | redis-mojo 包                        |

## 特性

- ✅ 支持 Redis 连接管理（连接池、URL 配置）
- ✅ 支持字符串操作：`SET`, `GET`, `DEL`, `EXISTS`, `EXPIRE`, `TTL`
- ✅ 支持列表操作：`LPUSH`, `RPUSH`, `LPOP`, `RPOP`, `LLEN`
- ✅ 支持哈希表操作：`HSET`, `HGET`, `HDEL`, `HEXISTS`, `HGETALL`
- ✅ 支持集合操作：`SADD`, `SREM`, `SISMEMBER`, `SCARD`
- ✅ 支持原始命令执行：`RAW`
- ✅ 自动内存管理，无需手动释放

## 使用方法

- 导入依赖：

```toml

# 先添加 2 个源地址，包含 redis-ffi 包和 redis 包
channels = [
    "https://conda.modular.com/max-nightly",
    "https://repo.prefix.dev/better-ffi", # 包含 redis-ffi 包
    "https://repo.prefix.dev/better-mojo", # 包含 redis mojo 包
    "conda-forge",
]

# 添加 2 个依赖包，包含 redis-ffi 包和 redis 包
[dependencies]
mojo = ">=1.0.0b2.dev2026052406,<2" # TODO X: fix 版本不一致问题！！！

# FFI 依赖
libredis_ffi = ">=0.1.0,<0.2"

# Mojo 包依赖
# redis = { git = "https://github.com/better-mojo/disc.git", branch = "main" }
redis = ">=0.1.0,<0.2"

```

- ✅ 简单示例:

```python
from redis import RedisClient


def main() raises -> None:
    # 创建 Redis 客户端
    var client = RedisClient("redis://:password@localhost:6379/0")

    # 字符串操作
    client.set("key", "value")
    var value = client.get("key")
    print("GET key -> " + value)

    # 列表操作
    client.lpush("list", "item1")
    client.rpush("list", "item2")
    var item = client.lpop("list")
    print("LPOP list -> " + item)

    # 哈希表操作
    client.hset("hash", "field", "value")
    var field_value = client.hget("hash", "field")
    print("HGET hash field -> " + field_value)

    # 集合操作
    client.sadd("set", "member")
    var is_member = client.sismember("set", "member")
    print("SISMEMBER set member -> " + String(is_member))

```

<img width="600" alt="image" src="https://github.com/user-attachments/assets/ac6d46cd-5085-4f5b-a1cd-c4cca71b237e" />

- ✅ run:

```bash
# 运行示例
pixi run mojo -I . examples/basic.mojo

```

- ✅ 完整示例 [examples/basic.mojo](./examples/basic.mojo)
  - 包含完整的包依赖导入方法
  - 包含所有数据类型操作示例

```bash
# 安装依赖
pixi install

# 运行
pixi run mojo run -I src examples/basic.mojo

```

### 连接配置

Redis 连接 URL 格式：

```
redis://[:password@]host:port[/db]
```

示例：

- `redis://localhost:6379/0` - 无密码连接
- `redis://:mypassword@localhost:6379/0` - 带密码连接
- `redis://192.168.1.100:6379/1` - 远程服务器，使用 db 1

## API 文档

### RedisClient

#### 连接管理

| 方法 | 描述 | 返回值 |
|------|------|--------|
| `ping()` | 执行 PING 命令 | `String` |
| `is_connected()` | 检查连接状态 | `Bool` |
| `version()` | 获取库版本 | `String` |

#### 字符串操作

| 方法 | 描述 | 参数 | 返回值 |
|------|------|------|--------|
| `set(key, value)` | 设置键值 | `key: String, value: String` | `Bool` |
| `get(key)` | 获取键值 | `key: String` | `String` |
| `delete(key)` | 删除键 | `key: String` | `Int64` |
| `exists(key)` | 检查键是否存在 | `key: String` | `Bool` |
| `expire(key, seconds)` | 设置过期时间 | `key: String, seconds: Int64` | `Bool` |
| `ttl(key)` | 获取剩余过期时间 | `key: String` | `Int64` |

#### 列表操作

| 方法 | 描述 | 参数 | 返回值 |
|------|------|------|--------|
| `lpush(key, value)` | 左侧推入 | `key: String, value: String` | `Int64` |
| `rpush(key, value)` | 右侧推入 | `key: String, value: String` | `Int64` |
| `lpop(key)` | 左侧弹出 | `key: String` | `String` |
| `rpop(key)` | 右侧弹出 | `key: String` | `String` |
| `llen(key)` | 获取列表长度 | `key: String` | `Int64` |

#### 哈希表操作

| 方法 | 描述 | 参数 | 返回值 |
|------|------|------|--------|
| `hset(key, field, value)` | 设置字段 | `key, field, value: String` | `Bool` |
| `hget(key, field)` | 获取字段值 | `key, field: String` | `String` |
| `hdel(key, field)` | 删除字段 | `key, field: String` | `Int64` |
| `hexists(key, field)` | 检查字段是否存在 | `key, field: String` | `Bool` |
| `hgetall(key)` | 获取所有字段 | `key: String` | `String` |

#### 集合操作

| 方法 | 描述 | 参数 | 返回值 |
|------|------|------|--------|
| `sadd(key, member)` | 添加成员 | `key, member: String` | `Int64` |
| `srem(key, member)` | 移除成员 | `key, member: String` | `Int64` |
| `sismember(key, member)` | 检查成员 | `key, member: String` | `Bool` |
| `scard(key)` | 获取成员数量 | `key: String` | `Int64` |

#### 原始命令

| 方法 | 描述 | 参数 | 返回值 |
|------|------|------|--------|
| `raw(cmd, args)` | 执行原始命令 | `cmd, args: String` | `String` |

## 开发环境

### 安装依赖

- 安装 [Taskfile](https://github.com/go-task/go-task) ： 编译构建工具
- 安装 [Rust](https://www.rust-lang.org/tools/install)
- 安装 [pixi](https://pixi.sh/)
- 安装 [rattler-build](https://rattler-build.prefix.dev/latest/#installation) ： 包管理工具，编译+发布 rust 二进制包
- 安装 [mojo](https://mojolang.org/install/)

```ruby
task setup
```

### 编译调试

- ✅ 编译调试 redis-ffi 包

```ruby

# 运行示例
task rf:r

# 编译 redis-ffi 包
task rf:b

# release redis-ffi 包
task rf:rel

```

- ✅ 编译调试 [examples](./examples) 示例

```ruby
# 运行 examples 示例
task run:basic

```

## 发布到 Prefix.dev

- ✅ <https://prefix.dev/channels/better-ffi>
- ✅ <https://prefix.dev/channels/better-mojo>
- ✅ [Taskfile](./Taskfile.yml)

```bash

# 发布
task release:rs
task release:mojo

# 发布到 prefix.dev
task publish:ffi
task publish:mojo

```

- ✅ 编译发布 Linux 版本， 基于 `orbstack` 虚拟机
  - 注意，每次都要把 ffi 库，`3 个 OS 版本`，都发布到 prefix.dev，再发布 redis 包。（依赖顺序）

```bash
# 查看可用的虚拟机
orbctl list 

# 连接 linux-aarch64 架构的 虚拟机, 执行编译+发布
orbctl run -m u22dev

# 连接 linux-64 架构的 虚拟机, 执行编译+发布
orbctl run -m u22build

```

## 测试

```bash
# 运行单元测试
pixi run mojo run -I src test/test_redis.mojo

# 运行内存压力测试
pixi run mojo run -I src test/test_memory.mojo
```

## 参考

### Mojo FFI 包

- ✅ <https://github.com/better-mojo/uuid>
- ✅ <https://github.com/ehsanmok/sqlite>

### Redis

- ✅ <https://github.com/redis-rs/redis-rs>
- ✅ <https://redis.io/commands/>

### Rust FFI

- ✅ <https://github.com/getditto/safer_ffi>
- ✅ <https://github.com/f0cii/diplomat>
  - <https://github.com/rust-diplomat/diplomat>
  - <https://rust-diplomat.github.io/book/>
- ✅ <https://github.com/mozilla/uniffi-rs>
- ✅ <https://rustwiki.org/zh-CN/std/ffi/struct.CString.html#examples>

[language-shield]: https://img.shields.io/badge/Mojo%F0%9F%94%A5-1.0.0b2-orange

[license-shield]: https://img.shields.io/github/license/better-mojo/jojo?logo=github

[license-url]: https://github.com/better-mojo/jojo/blob/main/LICENSE

[contributors-shield]: https://img.shields.io/badge/contributors-welcome!-blue

[contributors-url]: https://github.com/better-mojo/uuid#contributing
