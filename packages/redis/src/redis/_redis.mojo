"""
Redis FFI 内部层 - 动态加载 redis-ffi 库

本模块提供对 redis-ffi 动态库的底层访问，使用 Mojo 的 FFI 机制。
设计参考 sqlite/ffi.mojo 的实现风格。
"""

from std.ffi import OwnedDLHandle, RTLD, c_char, c_size_t, c_int, c_long
from std.memory import UnsafePointer
from std.sys.info import CompilationTarget
from std.os import getenv


# ============================================================================
# 类型别名
# ============================================================================

comptime c_void = UInt8
comptime c_int32 = Int32
comptime c_int64 = Int64
comptime c_uint8 = UInt8
comptime c_bool = Bool


# ============================================================================
# 内部辅助函数
# ============================================================================


def _ptr_to_string(p: UnsafePointer[UInt8, MutExternalOrigin]) -> String:
    """将 C 字符串指针转换为 Mojo String

    Args:
        p: 指向 null 终止的 UTF-8 字符串的指针

    Returns:
        拥有的 Mojo String，null 指针返回空字符串
    """
    if not p:
        return String("")
    return String(StringSlice(unsafe_from_utf8_ptr=p))


def _find_redis_ffi_library() -> String:
    """定位 redis-ffi 动态库

    搜索顺序:
    1. 当前目录下的 target/release 或 target/debug
    2. 环境变量 REDIS_FFI_PATH
    3. 系统库路径

    Returns:
        库路径字符串
    """
    # 首先检查环境变量
    var prefix = getenv("CONDA_PREFIX", "")
    if prefix:
        if CompilationTarget.is_linux():
            return prefix + "/lib/libredis_ffi.so"
        else:
            return prefix + "/lib/libredis_ffi.dylib"

    if CompilationTarget.is_linux():
        return "libredis_ffi.so"
    elif CompilationTarget.is_macos():
        return "libredis_ffi.dylib"

    # env local path
    var redis_ffi_path = getenv(
        "REDIS_FFI_PATH", "../redis-ffi/target/release/"
    )
    if redis_ffi_path:
        return redis_ffi_path

    # local path
    var libname = (
        "libredis_ffi.so" if CompilationTarget.is_linux() else "libredis_ffi.dylib"
    )

    return "../redis-ffi/target/release/" + libname


# ============================================================================
# RedisFFI - FFI 封装结构体
# ============================================================================


struct RedisFFI(Movable):
    """运行时加载的 Redis FFI 封装

    使用 OwnedDLHandle 在运行时加载 libredis_ffi 动态库，
    通过 get_function 解析所有函数指针。

    所有 C ABI 函数指针都存储为成员变量，避免重复查找。
    """

    var _lib: OwnedDLHandle

    # 连接管理函数
    var _fn_redis_init: def(UnsafePointer[Int8, MutExternalOrigin]) thin abi(
        "C"
    ) -> c_bool
    var _fn_redis_is_connected: def() thin abi("C") -> c_bool
    var _fn_redis_close: def() thin abi("C") -> None
    var _fn_redis_ping: def() thin abi("C") -> UnsafePointer[
        UInt8, MutExternalOrigin
    ]

    # 字符串操作函数
    var _fn_redis_set: def(
        UnsafePointer[Int8, MutExternalOrigin],
        UnsafePointer[Int8, MutExternalOrigin],
    ) thin abi("C") -> c_bool
    var _fn_redis_get: def(UnsafePointer[Int8, MutExternalOrigin]) thin abi(
        "C"
    ) -> UnsafePointer[UInt8, MutExternalOrigin]
    var _fn_redis_del: def(UnsafePointer[Int8, MutExternalOrigin]) thin abi(
        "C"
    ) -> c_int64
    var _fn_redis_exists: def(UnsafePointer[Int8, MutExternalOrigin]) thin abi(
        "C"
    ) -> c_bool
    var _fn_redis_expire: def(
        UnsafePointer[Int8, MutExternalOrigin], c_int64
    ) thin abi("C") -> c_bool
    var _fn_redis_ttl: def(UnsafePointer[Int8, MutExternalOrigin]) thin abi(
        "C"
    ) -> c_int64

    # 列表操作函数
    var _fn_redis_lpush: def(
        UnsafePointer[Int8, MutExternalOrigin],
        UnsafePointer[Int8, MutExternalOrigin],
    ) thin abi("C") -> c_int64
    var _fn_redis_rpush: def(
        UnsafePointer[Int8, MutExternalOrigin],
        UnsafePointer[Int8, MutExternalOrigin],
    ) thin abi("C") -> c_int64
    var _fn_redis_lpop: def(UnsafePointer[Int8, MutExternalOrigin]) thin abi(
        "C"
    ) -> UnsafePointer[UInt8, MutExternalOrigin]
    var _fn_redis_rpop: def(UnsafePointer[Int8, MutExternalOrigin]) thin abi(
        "C"
    ) -> UnsafePointer[UInt8, MutExternalOrigin]
    var _fn_redis_llen: def(UnsafePointer[Int8, MutExternalOrigin]) thin abi(
        "C"
    ) -> c_int64

    # 哈希表操作函数
    var _fn_redis_hset: def(
        UnsafePointer[Int8, MutExternalOrigin],
        UnsafePointer[Int8, MutExternalOrigin],
        UnsafePointer[Int8, MutExternalOrigin],
    ) thin abi("C") -> c_bool
    var _fn_redis_hget: def(
        UnsafePointer[Int8, MutExternalOrigin],
        UnsafePointer[Int8, MutExternalOrigin],
    ) thin abi("C") -> UnsafePointer[UInt8, MutExternalOrigin]
    var _fn_redis_hdel: def(
        UnsafePointer[Int8, MutExternalOrigin],
        UnsafePointer[Int8, MutExternalOrigin],
    ) thin abi("C") -> c_int64
    var _fn_redis_hexists: def(
        UnsafePointer[Int8, MutExternalOrigin],
        UnsafePointer[Int8, MutExternalOrigin],
    ) thin abi("C") -> c_bool
    var _fn_redis_hgetall: def(UnsafePointer[Int8, MutExternalOrigin]) thin abi(
        "C"
    ) -> UnsafePointer[UInt8, MutExternalOrigin]

    # 集合操作函数
    var _fn_redis_sadd: def(
        UnsafePointer[Int8, MutExternalOrigin],
        UnsafePointer[Int8, MutExternalOrigin],
    ) thin abi("C") -> c_int64
    var _fn_redis_srem: def(
        UnsafePointer[Int8, MutExternalOrigin],
        UnsafePointer[Int8, MutExternalOrigin],
    ) thin abi("C") -> c_int64
    var _fn_redis_sismember: def(
        UnsafePointer[Int8, MutExternalOrigin],
        UnsafePointer[Int8, MutExternalOrigin],
    ) thin abi("C") -> c_bool
    var _fn_redis_scard: def(UnsafePointer[Int8, MutExternalOrigin]) thin abi(
        "C"
    ) -> c_int64

    # 原始命令和工具函数
    var _fn_redis_raw: def(
        UnsafePointer[Int8, MutExternalOrigin],
        UnsafePointer[Int8, MutExternalOrigin],
    ) thin abi("C") -> UnsafePointer[UInt8, MutExternalOrigin]
    var _fn_redis_version: def() thin abi("C") -> UnsafePointer[
        UInt8, MutExternalOrigin
    ]
    var _fn_free_rs_string: def(
        UnsafePointer[Int8, MutExternalOrigin]
    ) thin abi("C") -> None

    def __init__(out self) raises:
        """初始化 RedisFFI，加载动态库并解析所有函数指针"""
        var lib_path = _find_redis_ffi_library()
        self._lib = OwnedDLHandle(lib_path, RTLD.NOW | RTLD.GLOBAL)

        # 解析连接管理函数
        self._fn_redis_init = self._lib.get_function[
            def(UnsafePointer[Int8, MutExternalOrigin]) thin abi("C") -> c_bool
        ]("redis_init")
        self._fn_redis_is_connected = self._lib.get_function[
            def() thin abi("C") -> c_bool
        ]("redis_is_connected")
        self._fn_redis_close = self._lib.get_function[
            def() thin abi("C") -> None
        ]("redis_close")
        self._fn_redis_ping = self._lib.get_function[
            def() thin abi("C") -> UnsafePointer[UInt8, MutExternalOrigin]
        ]("redis_ping")

        # 解析字符串操作函数
        self._fn_redis_set = self._lib.get_function[
            def(
                UnsafePointer[Int8, MutExternalOrigin],
                UnsafePointer[Int8, MutExternalOrigin],
            ) thin abi("C") -> c_bool
        ]("redis_set")
        self._fn_redis_get = self._lib.get_function[
            def(
                UnsafePointer[Int8, MutExternalOrigin]
            ) thin abi("C") -> UnsafePointer[UInt8, MutExternalOrigin]
        ]("redis_get")
        self._fn_redis_del = self._lib.get_function[
            def(UnsafePointer[Int8, MutExternalOrigin]) thin abi("C") -> c_int64
        ]("redis_del")
        self._fn_redis_exists = self._lib.get_function[
            def(UnsafePointer[Int8, MutExternalOrigin]) thin abi("C") -> c_bool
        ]("redis_exists")
        self._fn_redis_expire = self._lib.get_function[
            def(
                UnsafePointer[Int8, MutExternalOrigin], c_int64
            ) thin abi("C") -> c_bool
        ]("redis_expire")
        self._fn_redis_ttl = self._lib.get_function[
            def(UnsafePointer[Int8, MutExternalOrigin]) thin abi("C") -> c_int64
        ]("redis_ttl")

        # 解析列表操作函数
        self._fn_redis_lpush = self._lib.get_function[
            def(
                UnsafePointer[Int8, MutExternalOrigin],
                UnsafePointer[Int8, MutExternalOrigin],
            ) thin abi("C") -> c_int64
        ]("redis_lpush")
        self._fn_redis_rpush = self._lib.get_function[
            def(
                UnsafePointer[Int8, MutExternalOrigin],
                UnsafePointer[Int8, MutExternalOrigin],
            ) thin abi("C") -> c_int64
        ]("redis_rpush")
        self._fn_redis_lpop = self._lib.get_function[
            def(
                UnsafePointer[Int8, MutExternalOrigin]
            ) thin abi("C") -> UnsafePointer[UInt8, MutExternalOrigin]
        ]("redis_lpop")
        self._fn_redis_rpop = self._lib.get_function[
            def(
                UnsafePointer[Int8, MutExternalOrigin]
            ) thin abi("C") -> UnsafePointer[UInt8, MutExternalOrigin]
        ]("redis_rpop")
        self._fn_redis_llen = self._lib.get_function[
            def(UnsafePointer[Int8, MutExternalOrigin]) thin abi("C") -> c_int64
        ]("redis_llen")

        # 解析哈希表操作函数
        self._fn_redis_hset = self._lib.get_function[
            def(
                UnsafePointer[Int8, MutExternalOrigin],
                UnsafePointer[Int8, MutExternalOrigin],
                UnsafePointer[Int8, MutExternalOrigin],
            ) thin abi("C") -> c_bool
        ]("redis_hset")
        self._fn_redis_hget = self._lib.get_function[
            def(
                UnsafePointer[Int8, MutExternalOrigin],
                UnsafePointer[Int8, MutExternalOrigin],
            ) thin abi("C") -> UnsafePointer[UInt8, MutExternalOrigin]
        ]("redis_hget")
        self._fn_redis_hdel = self._lib.get_function[
            def(
                UnsafePointer[Int8, MutExternalOrigin],
                UnsafePointer[Int8, MutExternalOrigin],
            ) thin abi("C") -> c_int64
        ]("redis_hdel")
        self._fn_redis_hexists = self._lib.get_function[
            def(
                UnsafePointer[Int8, MutExternalOrigin],
                UnsafePointer[Int8, MutExternalOrigin],
            ) thin abi("C") -> c_bool
        ]("redis_hexists")
        self._fn_redis_hgetall = self._lib.get_function[
            def(
                UnsafePointer[Int8, MutExternalOrigin]
            ) thin abi("C") -> UnsafePointer[UInt8, MutExternalOrigin]
        ]("redis_hgetall")

        # 解析集合操作函数
        self._fn_redis_sadd = self._lib.get_function[
            def(
                UnsafePointer[Int8, MutExternalOrigin],
                UnsafePointer[Int8, MutExternalOrigin],
            ) thin abi("C") -> c_int64
        ]("redis_sadd")
        self._fn_redis_srem = self._lib.get_function[
            def(
                UnsafePointer[Int8, MutExternalOrigin],
                UnsafePointer[Int8, MutExternalOrigin],
            ) thin abi("C") -> c_int64
        ]("redis_srem")
        self._fn_redis_sismember = self._lib.get_function[
            def(
                UnsafePointer[Int8, MutExternalOrigin],
                UnsafePointer[Int8, MutExternalOrigin],
            ) thin abi("C") -> c_bool
        ]("redis_sismember")
        self._fn_redis_scard = self._lib.get_function[
            def(UnsafePointer[Int8, MutExternalOrigin]) thin abi("C") -> c_int64
        ]("redis_scard")

        # 解析原始命令和工具函数
        self._fn_redis_raw = self._lib.get_function[
            def(
                UnsafePointer[Int8, MutExternalOrigin],
                UnsafePointer[Int8, MutExternalOrigin],
            ) thin abi("C") -> UnsafePointer[UInt8, MutExternalOrigin]
        ]("redis_raw")
        self._fn_redis_version = self._lib.get_function[
            def() thin abi("C") -> UnsafePointer[UInt8, MutExternalOrigin]
        ]("redis_version")
        self._fn_free_rs_string = self._lib.get_function[
            def(UnsafePointer[Int8, MutExternalOrigin]) thin abi("C") -> None
        ]("free_rs_string")

    # -----------------------------------------------------------------------
    # 连接管理 API
    # -----------------------------------------------------------------------

    def redis_init(self, url: UnsafePointer[Int8, MutExternalOrigin]) -> c_bool:
        """初始化 Redis 连接"""
        return self._fn_redis_init(url)

    def redis_is_connected(self) -> c_bool:
        """检查 Redis 连接是否已初始化"""
        return self._fn_redis_is_connected()

    def redis_close(self):
        """关闭 Redis 连接"""
        self._fn_redis_close()

    def redis_ping(self) -> UnsafePointer[UInt8, MutExternalOrigin]:
        """执行 PING 命令"""
        return self._fn_redis_ping()

    # -----------------------------------------------------------------------
    # 字符串操作 API
    # -----------------------------------------------------------------------

    def redis_set(
        self,
        key: UnsafePointer[Int8, MutExternalOrigin],
        value: UnsafePointer[Int8, MutExternalOrigin],
    ) -> c_bool:
        """设置字符串键值"""
        return self._fn_redis_set(key, value)

    def redis_get(
        self, key: UnsafePointer[Int8, MutExternalOrigin]
    ) -> UnsafePointer[UInt8, MutExternalOrigin]:
        """获取字符串键值"""
        return self._fn_redis_get(key)

    def redis_del(self, key: UnsafePointer[Int8, MutExternalOrigin]) -> c_int64:
        """删除指定的键"""
        return self._fn_redis_del(key)

    def redis_exists(
        self, key: UnsafePointer[Int8, MutExternalOrigin]
    ) -> c_bool:
        """检查键是否存在"""
        return self._fn_redis_exists(key)

    def redis_expire(
        self, key: UnsafePointer[Int8, MutExternalOrigin], seconds: c_int64
    ) -> c_bool:
        """设置键的过期时间（秒）"""
        return self._fn_redis_expire(key, seconds)

    def redis_ttl(self, key: UnsafePointer[Int8, MutExternalOrigin]) -> c_int64:
        """获取键的剩余过期时间（秒）"""
        return self._fn_redis_ttl(key)

    # -----------------------------------------------------------------------
    # 列表操作 API
    # -----------------------------------------------------------------------

    def redis_lpush(
        self,
        key: UnsafePointer[Int8, MutExternalOrigin],
        value: UnsafePointer[Int8, MutExternalOrigin],
    ) -> c_int64:
        """将值推入列表左侧"""
        return self._fn_redis_lpush(key, value)

    def redis_rpush(
        self,
        key: UnsafePointer[Int8, MutExternalOrigin],
        value: UnsafePointer[Int8, MutExternalOrigin],
    ) -> c_int64:
        """将值推入列表右侧"""
        return self._fn_redis_rpush(key, value)

    def redis_lpop(
        self, key: UnsafePointer[Int8, MutExternalOrigin]
    ) -> UnsafePointer[UInt8, MutExternalOrigin]:
        """从列表左侧弹出值"""
        return self._fn_redis_lpop(key)

    def redis_rpop(
        self, key: UnsafePointer[Int8, MutExternalOrigin]
    ) -> UnsafePointer[UInt8, MutExternalOrigin]:
        """从列表右侧弹出值"""
        return self._fn_redis_rpop(key)

    def redis_llen(
        self, key: UnsafePointer[Int8, MutExternalOrigin]
    ) -> c_int64:
        """获取列表长度"""
        return self._fn_redis_llen(key)

    # -----------------------------------------------------------------------
    # 哈希表操作 API
    # -----------------------------------------------------------------------

    def redis_hset(
        self,
        key: UnsafePointer[Int8, MutExternalOrigin],
        field: UnsafePointer[Int8, MutExternalOrigin],
        value: UnsafePointer[Int8, MutExternalOrigin],
    ) -> c_bool:
        """设置哈希表字段"""
        return self._fn_redis_hset(key, field, value)

    def redis_hget(
        self,
        key: UnsafePointer[Int8, MutExternalOrigin],
        field: UnsafePointer[Int8, MutExternalOrigin],
    ) -> UnsafePointer[UInt8, MutExternalOrigin]:
        """获取哈希表字段值"""
        return self._fn_redis_hget(key, field)

    def redis_hdel(
        self,
        key: UnsafePointer[Int8, MutExternalOrigin],
        field: UnsafePointer[Int8, MutExternalOrigin],
    ) -> c_int64:
        """删除哈希表字段"""
        return self._fn_redis_hdel(key, field)

    def redis_hexists(
        self,
        key: UnsafePointer[Int8, MutExternalOrigin],
        field: UnsafePointer[Int8, MutExternalOrigin],
    ) -> c_bool:
        """检查哈希表字段是否存在"""
        return self._fn_redis_hexists(key, field)

    def redis_hgetall(
        self, key: UnsafePointer[Int8, MutExternalOrigin]
    ) -> UnsafePointer[UInt8, MutExternalOrigin]:
        """获取哈希表所有字段和值"""
        return self._fn_redis_hgetall(key)

    # -----------------------------------------------------------------------
    # 集合操作 API
    # -----------------------------------------------------------------------

    def redis_sadd(
        self,
        key: UnsafePointer[Int8, MutExternalOrigin],
        member: UnsafePointer[Int8, MutExternalOrigin],
    ) -> c_int64:
        """将成员添加到集合"""
        return self._fn_redis_sadd(key, member)

    def redis_srem(
        self,
        key: UnsafePointer[Int8, MutExternalOrigin],
        member: UnsafePointer[Int8, MutExternalOrigin],
    ) -> c_int64:
        """从集合移除成员"""
        return self._fn_redis_srem(key, member)

    def redis_sismember(
        self,
        key: UnsafePointer[Int8, MutExternalOrigin],
        member: UnsafePointer[Int8, MutExternalOrigin],
    ) -> c_bool:
        """检查成员是否在集合中"""
        return self._fn_redis_sismember(key, member)

    def redis_scard(
        self, key: UnsafePointer[Int8, MutExternalOrigin]
    ) -> c_int64:
        """获取集合成员数量"""
        return self._fn_redis_scard(key)

    # -----------------------------------------------------------------------
    # 原始命令和工具 API
    # -----------------------------------------------------------------------

    def redis_raw(
        self,
        cmd: UnsafePointer[Int8, MutExternalOrigin],
        args: UnsafePointer[Int8, MutExternalOrigin],
    ) -> UnsafePointer[UInt8, MutExternalOrigin]:
        """执行原始 Redis 命令"""
        return self._fn_redis_raw(cmd, args)

    def redis_version(self) -> UnsafePointer[UInt8, MutExternalOrigin]:
        """获取库版本信息"""
        return self._fn_redis_version()

    def free_string(self, string: UnsafePointer[Int8, MutExternalOrigin]):
        """释放 Rust 分配的字符串"""
        self._fn_free_rs_string(string)
