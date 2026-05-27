# redis-ffi

基于 redis-rs 库的 Redis FFI 封装，提供 C ABI 接口供 Mojo 调用。

## 功能特性

- 连接管理：初始化、关闭、检查连接状态
- 字符串操作：SET、GET、DEL、EXISTS、EXPIRE、TTL
- 列表操作：LPUSH、RPUSH、LPOP、RPOP、LLEN
- 哈希表操作：HSET、HGET、HDEL、HEXISTS、HGETALL
- 集合操作：SADD、SREM、SISMEMBER、SCARD
- 原始命令：支持执行任意 Redis 命令

## 构建

```bash
# 生成 C 头文件并构建库
task b

# 或手动执行
cargo test --features c-headers -- generate_headers
cargo build
```

## 运行示例

### Rust 示例

```bash
# 设置 Redis 连接 URL（可选，默认使用 redis://127.0.0.1:6379/0）
export REDIS_URL="redis://192.168.139.143:6379/0"

# 运行 Rust 示例
task rr
# 或: cargo run --example basic
```

### C 示例

```bash
# 设置 Redis 连接 URL
export REDIS_URL="redis://192.168.139.143:6379/0"

# 构建并运行 C 示例
task r
```

## C API 列表

### 连接管理

| 函数 | 描述 |
|------|------|
| `redis_init(url)` | 初始化 Redis 连接 |
| `redis_is_connected()` | 检查连接状态 |
| `redis_close()` | 关闭连接 |
| `redis_ping()` | 测试连接 |
| `redis_version()` | 获取库版本 |

### 字符串操作

| 函数 | 描述 |
|------|------|
| `redis_set(key, value)` | 设置键值 |
| `redis_get(key)` | 获取键值 |
| `redis_del(key)` | 删除键 |
| `redis_exists(key)` | 检查键是否存在 |
| `redis_expire(key, seconds)` | 设置过期时间 |
| `redis_ttl(key)` | 获取剩余过期时间 |

### 列表操作

| 函数 | 描述 |
|------|------|
| `redis_lpush(key, value)` | 左侧推入元素 |
| `redis_rpush(key, value)` | 右侧推入元素 |
| `redis_lpop(key)` | 左侧弹出元素 |
| `redis_rpop(key)` | 右侧弹出元素 |
| `redis_llen(key)` | 获取列表长度 |

### 哈希表操作

| 函数 | 描述 |
|------|------|
| `redis_hset(key, field, value)` | 设置哈希字段 |
| `redis_hget(key, field)` | 获取哈希字段值 |
| `redis_hdel(key, field)` | 删除哈希字段 |
| `redis_hexists(key, field)` | 检查字段是否存在 |
| `redis_hgetall(key)` | 获取所有字段和值（JSON 格式） |

### 集合操作

| 函数 | 描述 |
|------|------|
| `redis_sadd(key, member)` | 添加成员到集合 |
| `redis_srem(key, member)` | 从集合移除成员 |
| `redis_sismember(key, member)` | 检查成员是否在集合中 |
| `redis_scard(key)` | 获取集合成员数量 |

### 原始命令

| 函数 | 描述 |
|------|------|
| `redis_raw(cmd, args)` | 执行原始 Redis 命令 |

### 内存管理

| 函数 | 描述 |
|------|------|
| `free_rs_string(string)` | 释放 Rust 分配的字符串 |

## 参考

- [redis-rs 库](https://github.com/redis-rs/redis-rs)
- [safer_ffi 库](https://github.com/getditto/safer_ffi)
