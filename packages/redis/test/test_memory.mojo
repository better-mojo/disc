"""
Redis Mojo 客户端内存压力测试.

验证内存管理是否正确，无内存泄漏。
"""

from redis import RedisClient


alias REDIS_URL = "redis://:redis_2MB8cN@192.168.139.143:6379/0"
alias TEST_KEY_PREFIX = "test:mojo:memory:"


def test_memory_leak_strings() raises:
    """测试字符串操作内存泄漏 - 循环执行大量操作"""
    var client = RedisClient(REDIS_URL)
    var key = TEST_KEY_PREFIX + "string"

    print("  执行 1000 次 SET/GET 操作...")
    for i in range(1000):
        var key_i = key + String(i)
        var value = "value_" + String(i) + "_" + String(i * 2)
        _ = client.set(key_i, value)
        var result = client.get(key_i)
        _ = client.delete(key_i)
    print("  ✓ 字符串操作内存测试完成")


def test_memory_leak_lists() raises:
    """测试列表操作内存泄漏"""
    var client = RedisClient(REDIS_URL)
    var key = TEST_KEY_PREFIX + "list"

    print("  执行 500 次列表操作...")
    for i in range(500):
        var key_i = key + String(i)
        # 推入多个元素
        for j in range(10):
            _ = client.lpush(key_i, "item_" + String(j))
        # 弹出所有元素
        for j in range(10):
            _ = client.lpop(key_i)
        _ = client.delete(key_i)
    print("  ✓ 列表操作内存测试完成")


def test_memory_leak_hashes() raises:
    """测试哈希表操作内存泄漏"""
    var client = RedisClient(REDIS_URL)
    var key = TEST_KEY_PREFIX + "hash"

    print("  执行 500 次哈希表操作...")
    for i in range(500):
        var key_i = key + String(i)
        # 设置多个字段
        for j in range(10):
            _ = client.hset(key_i, "field_" + String(j), "value_" + String(j))
        # 获取所有字段
        for j in range(10):
            _ = client.hget(key_i, "field_" + String(j))
        # 获取整个哈希
        _ = client.hgetall(key_i)
        _ = client.delete(key_i)
    print("  ✓ 哈希表操作内存测试完成")


def test_memory_leak_sets() raises:
    """测试集合操作内存泄漏"""
    var client = RedisClient(REDIS_URL)
    var key = TEST_KEY_PREFIX + "set"

    print("  执行 500 次集合操作...")
    for i in range(500):
        var key_i = key + String(i)
        # 添加多个成员
        for j in range(10):
            _ = client.sadd(key_i, "member_" + String(j))
        # 检查成员
        for j in range(10):
            _ = client.sismember(key_i, "member_" + String(j))
        _ = client.delete(key_i)
    print("  ✓ 集合操作内存测试完成")


def test_memory_leak_raw() raises:
    """测试原始命令内存泄漏"""
    var client = RedisClient(REDIS_URL)

    print("  执行 500 次原始命令...")
    for i in range(500):
        var info = client.raw("INFO", "server")
        var clients = client.raw("INFO", "clients")
        var memory = client.raw("INFO", "memory")
    print("  ✓ 原始命令内存测试完成")


def test_multiple_clients() raises:
    """测试多个客户端实例"""
    print("  创建 100 个客户端实例...")
    for i in range(100):
        var client = RedisClient(REDIS_URL)
        _ = client.ping()
        # 客户端在作用域结束时自动关闭
    print("  ✓ 多客户端测试完成")


def main() raises:
    print("=" * 60)
    print("Redis Mojo 客户端内存压力测试")
    print("=" * 60)
    print()

    print("测试 1: 字符串操作内存测试")
    test_memory_leak_strings()
    print()

    print("测试 2: 列表操作内存测试")
    test_memory_leak_lists()
    print()

    print("测试 3: 哈希表操作内存测试")
    test_memory_leak_hashes()
    print()

    print("测试 4: 集合操作内存测试")
    test_memory_leak_sets()
    print()

    print("测试 5: 原始命令内存测试")
    test_memory_leak_raw()
    print()

    print("测试 6: 多客户端实例测试")
    test_multiple_clients()
    print()

    print("=" * 60)
    print("所有内存测试完成!")
    print("如果没有崩溃或内存错误，说明内存管理正确。")
    print("=" * 60)
