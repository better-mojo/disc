"""
Redis 客户端库 for Mojo.

基于 redis-rs FFI 实现的 Mojo Redis 客户端，提供安全易用的 API。

## 快速开始

```mojo
from redis import RedisClient

def main() raises:
    # 创建客户端并连接
    var client = RedisClient("redis://:password@localhost:6379/0")
    
    # 字符串操作
    client.set("key", "value")
    var value = client.get("key")
    
    # 列表操作
    client.lpush("list", "item1")
    client.rpush("list", "item2")
    var item = client.lpop("list")
    
    # 哈希表操作
    client.hset("hash", "field", "value")
    var field_value = client.hget("hash", "field")
    
    # 集合操作
    client.sadd("set", "member")
    var is_member = client.sismember("set", "member")
```
"""

from ._redis import RedisFFI, _ptr_to_string
from std.memory import UnsafePointer, alloc, free, Layout
from std.collections.string import StringSlice


# ============================================================================
# RedisClient - 高级 API
# ============================================================================


struct RedisClient(Movable):
    """Redis 客户端 - 提供类型安全的 Redis 操作 API。

    封装底层 FFI 调用，自动处理字符串转换和内存管理。
    所有返回字符串的方法都会自动释放 Rust 分配的内存。

    Example:
        var client = RedisClient("redis://localhost:6379/0")
        client.set("key", "value")
        var value = client.get("key")
    """

    var _ffi: RedisFFI
    var _connected: Bool

    def __init__(out self, url: String) raises:
        """创建 Redis 客户端并初始化连接。

        Args:
            url: Redis 连接 URL，格式如 "redis://:password@host:port/db"

        Raises:
            Error: 如果连接失败
        """
        self._ffi = RedisFFI()
        self._connected = False

        # 将 URL 转换为 C 字符串
        var url_bytes = url.as_bytes()
        var url_layout = Layout[Int8](count=len(url_bytes) + 1)
        var url_ptr = alloc(url_layout)
        for i in range(len(url_bytes)):
            url_ptr[i] = Int8(url_bytes[i])
        url_ptr[len(url_bytes)] = Int8(0)  # null 终止

        var result = self._ffi.redis_init(url_ptr)
        free(url_ptr, url_layout)

        if not result:
            raise Error("Failed to connect to Redis")

        self._connected = True

    def __del__(deinit self):
        """析构时关闭连接"""
        if self._connected:
            self._ffi.redis_close()

    def _string_to_ptr(
        self, s: String
    ) -> UnsafePointer[Int8, MutExternalOrigin]:
        """将 Mojo String 转换为 C 字符串指针（需要调用者释放）"""
        var bytes = s.as_bytes()
        var layout = Layout[Int8](count=len(bytes) + 1)
        var ptr = alloc(layout)
        for i in range(len(bytes)):
            ptr[i] = Int8(bytes[i])
        ptr[len(bytes)] = Int8(0)
        return ptr

    def _free_string_ptr(
        self, ptr: UnsafePointer[Int8, MutExternalOrigin], size: Int
    ):
        """释放字符串指针"""
        var layout = Layout[Int8](count=size)
        free(ptr, layout)

    def _ptr_to_string_and_free(
        self, ptr: UnsafePointer[UInt8, MutExternalOrigin]
    ) -> String:
        """将 C 字符串指针转换为 Mojo String 并释放内存"""
        var result = _ptr_to_string(ptr)
        self._ffi.free_string(ptr.bitcast[Int8]())
        return result

    # -----------------------------------------------------------------------
    # 连接管理
    # -----------------------------------------------------------------------

    def ping(self) -> String:
        """执行 PING 命令"""
        var ptr = self._ffi.redis_ping()
        return self._ptr_to_string_and_free(ptr)

    def is_connected(self) -> Bool:
        """检查连接状态"""
        return self._ffi.redis_is_connected()

    def version(self) -> String:
        """获取库版本"""
        var ptr = self._ffi.redis_version()
        return self._ptr_to_string_and_free(ptr)

    # -----------------------------------------------------------------------
    # 字符串操作
    # -----------------------------------------------------------------------

    def set(self, key: String, value: String) -> Bool:
        """设置字符串键值"""
        var key_bytes = key.as_bytes()
        var value_bytes = value.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var value_ptr = self._string_to_ptr(value)
        var result = self._ffi.redis_set(key_ptr, value_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        self._free_string_ptr(value_ptr, len(value_bytes) + 1)
        return result

    def get(self, key: String) -> String:
        """获取字符串键值"""
        var key_bytes = key.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var ptr = self._ffi.redis_get(key_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        return self._ptr_to_string_and_free(ptr)

    def delete(self, key: String) -> Int64:
        """删除键，返回删除的键数量"""
        var key_bytes = key.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var result = self._ffi.redis_del(key_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        return result

    def exists(self, key: String) -> Bool:
        """检查键是否存在"""
        var key_bytes = key.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var result = self._ffi.redis_exists(key_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        return result

    def expire(self, key: String, seconds: Int64) -> Bool:
        """设置键的过期时间（秒）"""
        var key_bytes = key.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var result = self._ffi.redis_expire(key_ptr, seconds)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        return result

    def ttl(self, key: String) -> Int64:
        """获取键的剩余过期时间（秒）"""
        var key_bytes = key.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var result = self._ffi.redis_ttl(key_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        return result

    # -----------------------------------------------------------------------
    # 列表操作
    # -----------------------------------------------------------------------

    def lpush(self, key: String, value: String) -> Int64:
        """将值推入列表左侧，返回列表长度"""
        var key_bytes = key.as_bytes()
        var value_bytes = value.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var value_ptr = self._string_to_ptr(value)
        var result = self._ffi.redis_lpush(key_ptr, value_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        self._free_string_ptr(value_ptr, len(value_bytes) + 1)
        return result

    def rpush(self, key: String, value: String) -> Int64:
        """将值推入列表右侧，返回列表长度"""
        var key_bytes = key.as_bytes()
        var value_bytes = value.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var value_ptr = self._string_to_ptr(value)
        var result = self._ffi.redis_rpush(key_ptr, value_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        self._free_string_ptr(value_ptr, len(value_bytes) + 1)
        return result

    def lpop(self, key: String) -> String:
        """从列表左侧弹出值"""
        var key_bytes = key.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var ptr = self._ffi.redis_lpop(key_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        return self._ptr_to_string_and_free(ptr)

    def rpop(self, key: String) -> String:
        """从列表右侧弹出值"""
        var key_bytes = key.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var ptr = self._ffi.redis_rpop(key_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        return self._ptr_to_string_and_free(ptr)

    def llen(self, key: String) -> Int64:
        """获取列表长度"""
        var key_bytes = key.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var result = self._ffi.redis_llen(key_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        return result

    # -----------------------------------------------------------------------
    # 哈希表操作
    # -----------------------------------------------------------------------

    def hset(self, key: String, field: String, value: String) -> Bool:
        """设置哈希表字段"""
        var key_bytes = key.as_bytes()
        var field_bytes = field.as_bytes()
        var value_bytes = value.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var field_ptr = self._string_to_ptr(field)
        var value_ptr = self._string_to_ptr(value)
        var result = self._ffi.redis_hset(key_ptr, field_ptr, value_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        self._free_string_ptr(field_ptr, len(field_bytes) + 1)
        self._free_string_ptr(value_ptr, len(value_bytes) + 1)
        return result

    def hget(self, key: String, field: String) -> String:
        """获取哈希表字段值"""
        var key_bytes = key.as_bytes()
        var field_bytes = field.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var field_ptr = self._string_to_ptr(field)
        var ptr = self._ffi.redis_hget(key_ptr, field_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        self._free_string_ptr(field_ptr, len(field_bytes) + 1)
        return self._ptr_to_string_and_free(ptr)

    def hdel(self, key: String, field: String) -> Int64:
        """删除哈希表字段，返回删除的字段数量"""
        var key_bytes = key.as_bytes()
        var field_bytes = field.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var field_ptr = self._string_to_ptr(field)
        var result = self._ffi.redis_hdel(key_ptr, field_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        self._free_string_ptr(field_ptr, len(field_bytes) + 1)
        return result

    def hexists(self, key: String, field: String) -> Bool:
        """检查哈希表字段是否存在"""
        var key_bytes = key.as_bytes()
        var field_bytes = field.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var field_ptr = self._string_to_ptr(field)
        var result = self._ffi.redis_hexists(key_ptr, field_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        self._free_string_ptr(field_ptr, len(field_bytes) + 1)
        return result

    def hgetall(self, key: String) -> String:
        """获取哈希表所有字段和值（JSON 格式）"""
        var key_bytes = key.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var ptr = self._ffi.redis_hgetall(key_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        return self._ptr_to_string_and_free(ptr)

    # -----------------------------------------------------------------------
    # 集合操作
    # -----------------------------------------------------------------------

    def sadd(self, key: String, member: String) -> Int64:
        """将成员添加到集合，返回新增成员数量（0 表示已存在）"""
        var key_bytes = key.as_bytes()
        var member_bytes = member.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var member_ptr = self._string_to_ptr(member)
        var result = self._ffi.redis_sadd(key_ptr, member_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        self._free_string_ptr(member_ptr, len(member_bytes) + 1)
        return result

    def srem(self, key: String, member: String) -> Int64:
        """从集合移除成员，返回移除的成员数量"""
        var key_bytes = key.as_bytes()
        var member_bytes = member.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var member_ptr = self._string_to_ptr(member)
        var result = self._ffi.redis_srem(key_ptr, member_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        self._free_string_ptr(member_ptr, len(member_bytes) + 1)
        return result

    def sismember(self, key: String, member: String) -> Bool:
        """检查成员是否在集合中"""
        var key_bytes = key.as_bytes()
        var member_bytes = member.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var member_ptr = self._string_to_ptr(member)
        var result = self._ffi.redis_sismember(key_ptr, member_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        self._free_string_ptr(member_ptr, len(member_bytes) + 1)
        return result

    def scard(self, key: String) -> Int64:
        """获取集合成员数量"""
        var key_bytes = key.as_bytes()
        var key_ptr = self._string_to_ptr(key)
        var result = self._ffi.redis_scard(key_ptr)
        self._free_string_ptr(key_ptr, len(key_bytes) + 1)
        return result

    # -----------------------------------------------------------------------
    # 原始命令
    # -----------------------------------------------------------------------

    def raw(self, cmd: String, args: String) -> String:
        """执行原始 Redis 命令。

        Args:
            cmd: 命令名，如 "INFO", "CONFIG" 等
            args: 命令参数，如 "server", "GET maxmemory" 等

        Returns:
            命令执行结果字符串
        """
        var cmd_bytes = cmd.as_bytes()
        var args_bytes = args.as_bytes()
        var cmd_ptr = self._string_to_ptr(cmd)
        var args_ptr = self._string_to_ptr(args)
        var ptr = self._ffi.redis_raw(cmd_ptr, args_ptr)
        self._free_string_ptr(cmd_ptr, len(cmd_bytes) + 1)
        self._free_string_ptr(args_ptr, len(args_bytes) + 1)
        return self._ptr_to_string_and_free(ptr)
