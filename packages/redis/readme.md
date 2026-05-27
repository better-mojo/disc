# redis-mojo

- ✅ Based on FFI binding to the popular Rust Redis client library [redis-rs](https://github.com/redis-rs/redis-rs), for use with Mojo.
- ✅ Supports complete Redis data type operations: strings, lists, hashes, sets, etc.
- ✅ Automatic memory management, safe and efficient.

<a name="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">

<h3 align="center">Redis Mojo</h3>

  <p align="center">
    🔥 Redis-rs Redis client library binding for Mojo 🔥
    <br/>

![Mojo Version][language-shield]
[![MIT License][license-shield]][license-url]
[![Pixi Badge](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/prefix-dev/pixi/main/assets/badge/v0.json)](https://pixi.sh)
<br/>
[![Contributors Welcome][contributors-shield]][contributors-url]

[简体中文](README_CN.md) | English

  </p>
</div>

## Package Contents

| Project                             | Package URL                 | Hosting Platform     | Rating   | Description                              |
|-------------------------------------|-------------------------|-----------| -------|------------------------------------------|
| ✅ [redis-ffi](../redis-ffi)   | [libredis_ffi](https://prefix.dev/channels/better-ffi/packages/libredis_ffi) | [prefix.dev](https://prefix.dev/channels/better-ffi) | ⭐️⭐️⭐️ | redis-rs FFI package                              |
| ✅ [redis](./redis) | [redis](https://prefix.dev/channels/better-mojo/packages/redis)  | [prefix.dev](https://prefix.dev/channels/better-mojo) | ⭐️⭐️⭐️⭐️   | redis-mojo package                        |

## Features

- ✅ Supports Redis connection management (connection pooling, URL configuration)
- ✅ Supports string operations: `SET`, `GET`, `DEL`, `EXISTS`, `EXPIRE`, `TTL`
- ✅ Supports list operations: `LPUSH`, `RPUSH`, `LPOP`, `RPOP`, `LLEN`
- ✅ Supports hash operations: `HSET`, `HGET`, `HDEL`, `HEXISTS`, `HGETALL`
- ✅ Supports set operations: `SADD`, `SREM`, `SISMEMBER`, `SCARD`
- ✅ Supports raw command execution: `RAW`
- ✅ Automatic memory management, no manual release needed

## Usage

- Import dependencies:

```toml

# First add 2 source channels, including redis-ffi and redis packages
channels = [
    "https://conda.modular.com/max-nightly",
    "https://repo.prefix.dev/better-ffi", # contains redis-ffi package
    "https://repo.prefix.dev/better-mojo", # contains redis mojo package
    "conda-forge",
]

# Add 2 dependency packages, including redis-ffi and redis packages
[dependencies]
mojo = ">=1.0.0b2.dev2026052406,<2" # TODO X: fix version inconsistency issue!!!

# FFI dependency
libredis_ffi = ">=0.1.0,<0.2"

# Mojo package dependency
# redis = { git = "https://github.com/better-mojo/disc.git", branch = "main" }
redis = ">=0.1.0,<0.2"

```

- ✅ Simple example:

```python
from redis import RedisClient


def main() raises -> None:
    # Create Redis client
    var client = RedisClient("redis://:password@localhost:6379/0")

    # String operations
    client.set("key", "value")
    var value = client.get("key")
    print("GET key -> " + value)

    # List operations
    client.lpush("list", "item1")
    client.rpush("list", "item2")
    var item = client.lpop("list")
    print("LPOP list -> " + item)

    # Hash operations
    client.hset("hash", "field", "value")
    var field_value = client.hget("hash", "field")
    print("HGET hash field -> " + field_value)

    # Set operations
    client.sadd("set", "member")
    var is_member = client.sismember("set", "member")
    print("SISMEMBER set member -> " + String(is_member))

```

<img width="600" alt="image" src="https://github.com/user-attachments/assets/ac6d46cd-5085-4f5b-a1cd-c4cca71b237e" />

- ✅ run:

```bash
# Run example
pixi run mojo -I . examples/basic.mojo

```

- ✅ Complete example [examples/basic.mojo](./examples/basic.mojo)
  - Includes complete package dependency import methods
  - Includes all data type operation examples

```bash
# Install dependencies
pixi install

# Run
pixi run mojo run -I src examples/basic.mojo

```

### Connection Configuration

Redis connection URL format:

```
redis://[:password@]host:port[/db]
```

Examples:

- `redis://localhost:6379/0` - Connection without password
- `redis://:mypassword@localhost:6379/0` - Connection with password
- `redis://192.168.1.100:6379/1` - Remote server, using db 1

## API Documentation

### RedisClient

#### Connection Management

| Method | Description | Return Value |
|------|------|--------|
| `ping()` | Execute PING command | `String` |
| `is_connected()` | Check connection status | `Bool` |
| `version()` | Get library version | `String` |

#### String Operations

| Method | Description | Parameters | Return Value |
|------|------|------|--------|
| `set(key, value)` | Set key-value | `key: String, value: String` | `Bool` |
| `get(key)` | Get key value | `key: String` | `String` |
| `delete(key)` | Delete key | `key: String` | `Int64` |
| `exists(key)` | Check if key exists | `key: String` | `Bool` |
| `expire(key, seconds)` | Set expiration time | `key: String, seconds: Int64` | `Bool` |
| `ttl(key)` | Get remaining expiration time | `key: String` | `Int64` |

#### List Operations

| Method | Description | Parameters | Return Value |
|------|------|------|--------|
| `lpush(key, value)` | Push from left | `key: String, value: String` | `Int64` |
| `rpush(key, value)` | Push from right | `key: String, value: String` | `Int64` |
| `lpop(key)` | Pop from left | `key: String` | `String` |
| `rpop(key)` | Pop from right | `key: String` | `String` |
| `llen(key)` | Get list length | `key: String` | `Int64` |

#### Hash Operations

| Method | Description | Parameters | Return Value |
|------|------|------|--------|
| `hset(key, field, value)` | Set field | `key, field, value: String` | `Bool` |
| `hget(key, field)` | Get field value | `key, field: String` | `String` |
| `hdel(key, field)` | Delete field | `key, field: String` | `Int64` |
| `hexists(key, field)` | Check if field exists | `key, field: String` | `Bool` |
| `hgetall(key)` | Get all fields | `key: String` | `String` |

#### Set Operations

| Method | Description | Parameters | Return Value |
|------|------|------|--------|
| `sadd(key, member)` | Add member | `key, member: String` | `Int64` |
| `srem(key, member)` | Remove member | `key, member: String` | `Int64` |
| `sismember(key, member)` | Check membership | `key, member: String` | `Bool` |
| `scard(key)` | Get member count | `key: String` | `Int64` |

#### Raw Commands

| Method | Description | Parameters | Return Value |
|------|------|------|--------|
| `raw(cmd, args)` | Execute raw command | `cmd, args: String` | `String` |

## Development Environment

### Install Dependencies

- Install [Taskfile](https://github.com/go-task/go-task): Build tool
- Install [Rust](https://www.rust-lang.org/tools/install)
- Install [pixi](https://pixi.sh/)
- Install [rattler-build](https://rattler-build.prefix.dev/latest/#installation): Package management tool for building and publishing Rust binary packages
- Install [mojo](https://mojolang.org/install/)

```ruby
task setup
```

### Compile and Debug

- ✅ Compile and debug redis-ffi package

```ruby

# Run example
task rf:r

# Compile redis-ffi package
task rf:b

# release redis-ffi package
task rf:rel

```

- ✅ Compile and debug [examples](./examples)

```ruby
# Run examples
task run:basic

```

## Publish to Prefix.dev

- ✅ <https://prefix.dev/channels/better-ffi>
- ✅ <https://prefix.dev/channels/better-mojo>
- ✅ [Taskfile](./Taskfile.yml)

```bash

# Release
task release:rs
task release:mojo

# Publish to prefix.dev
task publish:ffi
task publish:mojo

```

- ✅ Compile and publish Linux versions using `orbstack` virtual machine
  - Note: Each time, the FFI library for `3 OS versions` must be published to prefix.dev before publishing the redis package. (Dependency order)

```bash
# List available virtual machines
orbctl list 

# Connect to linux-aarch64 architecture VM for compile and publish
orbctl run -m u22dev

# Connect to linux-64 architecture VM for compile and publish
orbctl run -m u22build

```

## Testing

```bash
# Run unit tests
pixi run mojo run -I src test/test_redis.mojo

# Run memory stress tests
pixi run mojo run -I src test/test_memory.mojo
```

## References

### Mojo FFI Packages

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
