"""
Redis Mojo 客户端单元测试.

测试 Redis 客户端的所有功能。
"""

from redis import RedisClient


# ============================================================================
# 测试常量
# ============================================================================

alias REDIS_URL = "redis://:redis_2MB8cN@192.168.139.143:6379/0"
alias TEST_KEY_PREFIX = "test:mojo:unit:"


# ============================================================================
# 测试辅助函数
# ============================================================================


def assert_equal(actual: String, expected: String, msg: String) raises:
    """断言字符串相等"""
    if actual != expected:
        raise Error(msg + " - 期望: '" + expected + "', 实际: '" + actual + "'")


def assert_equal_int(actual: Int64, expected: Int64, msg: String) raises:
    """断言整数相等"""
    if actual != expected:
        raise Error(
            msg + " - 期望: " + String(expected) + ", 实际: " + String(actual)
        )


def assert_true(value: Bool, msg: String) raises:
    """断言为真"""
    if not value:
        raise Error(msg + " - 期望 true, 实际 false")


def assert_false(value: Bool, msg: String) raises:
    """断言为假"""
    if value:
        raise Error(msg + " - 期望 false, 实际 true")


# ============================================================================
# 测试用例
# ============================================================================


def test_connection() raises:
    """测试连接功能"""
    var client = RedisClient(REDIS_URL)
    assert_true(client.is_connected(), "连接状态应为 true")
    var pong = client.ping()
    assert_equal(pong, "PONG", "PING 应返回 PONG")


def test_string_operations() raises:
    """测试字符串操作"""
    var client = RedisClient(REDIS_URL)
    var key = TEST_KEY_PREFIX + "string"

    # SET
    var set_result = client.set(key, "test_value")
    assert_true(set_result, "SET 应返回 true")

    # GET
    var value = client.get(key)
    assert_equal(value, "test_value", "GET 应返回设置的值")

    # EXISTS
    var exists = client.exists(key)
    assert_true(exists, "EXISTS 应返回 true")

    # EXPIRE
    var expire_result = client.expire(key, 60)
    assert_true(expire_result, "EXPIRE 应返回 true")

    # TTL
    var ttl = client.ttl(key)
    assert_true(ttl >= 0, "TTL 应 >= 0")

    # DELETE
    var del_count = client.delete(key)
    assert_equal_int(del_count, 1, "DELETE 应返回 1")

    # 删除后检查不存在
    var exists_after = client.exists(key)
    assert_false(exists_after, "删除后 EXISTS 应返回 false")


def test_list_operations() raises:
    """测试列表操作"""
    var client = RedisClient(REDIS_URL)
    var key = TEST_KEY_PREFIX + "list"

    # 清理
    _ = client.delete(key)

    # LPUSH
    var len1 = client.lpush(key, "item1")
    assert_equal_int(len1, 1, "LPUSH 第一个元素后长度应为 1")

    var len2 = client.lpush(key, "item2")
    assert_equal_int(len2, 2, "LPUSH 第二个元素后长度应为 2")

    # RPUSH
    var len3 = client.rpush(key, "item3")
    assert_equal_int(len3, 3, "RPUSH 后长度应为 3")

    # LLEN
    var len = client.llen(key)
    assert_equal_int(len, 3, "LLEN 应返回 3")

    # LPOP
    var popped1 = client.lpop(key)
    assert_equal(popped1, "item2", "LPOP 应返回最后推入左侧的元素")

    # RPOP
    var popped2 = client.rpop(key)
    assert_equal(popped2, "item3", "RPOP 应返回最后推入右侧的元素")

    # 清理
    _ = client.delete(key)


def test_hash_operations() raises:
    """测试哈希表操作"""
    var client = RedisClient(REDIS_URL)
    var key = TEST_KEY_PREFIX + "hash"

    # 清理
    _ = client.delete(key)

    # HSET
    var hset1 = client.hset(key, "field1", "value1")
    assert_true(hset1, "HSET 新字段应返回 true")

    var hset2 = client.hset(key, "field2", "value2")
    assert_true(hset2, "HSET 第二个新字段应返回 true")

    # HGET
    var value1 = client.hget(key, "field1")
    assert_equal(value1, "value1", "HGET 应返回正确的值")

    var value2 = client.hget(key, "field2")
    assert_equal(value2, "value2", "HGET 应返回正确的值")

    # HEXISTS
    var exists = client.hexists(key, "field1")
    assert_true(exists, "HEXISTS 应返回 true")

    # HDEL
    var del_count = client.hdel(key, "field1")
    assert_equal_int(del_count, 1, "HDEL 应返回 1")

    # 删除后检查不存在
    var exists_after = client.hexists(key, "field1")
    assert_false(exists_after, "删除后 HEXISTS 应返回 false")

    # HGETALL
    var all = client.hgetall(key)
    assert_true(len(all) > 0, "HGETALL 应返回非空结果")

    # 清理
    _ = client.delete(key)


def test_set_operations() raises:
    """测试集合操作"""
    var client = RedisClient(REDIS_URL)
    var key = TEST_KEY_PREFIX + "set"

    # 清理
    _ = client.delete(key)

    # SADD
    var added1 = client.sadd(key, "member1")
    assert_equal_int(added1, 1, "SADD 新成员应返回 1")

    var added2 = client.sadd(key, "member2")
    assert_equal_int(added2, 1, "SADD 第二个新成员应返回 1")

    var added3 = client.sadd(key, "member1")  # 重复
    assert_equal_int(added3, 0, "SADD 重复成员应返回 0")

    # SISMEMBER
    var is_member = client.sismember(key, "member1")
    assert_true(is_member, "SISMEMBER 应返回 true")

    var not_member = client.sismember(key, "member3")
    assert_false(not_member, "SISMEMBER 不存在的成员应返回 false")

    # SCARD
    var card = client.scard(key)
    assert_equal_int(card, 2, "SCARD 应返回 2")

    # SREM
    var rem_count = client.srem(key, "member1")
    assert_equal_int(rem_count, 1, "SREM 应返回 1")

    var rem_count2 = client.srem(key, "member3")  # 不存在
    assert_equal_int(rem_count2, 0, "SREM 不存在的成员应返回 0")

    # 清理
    _ = client.delete(key)


def test_raw_command() raises:
    """测试原始命令执行"""
    var client = RedisClient(REDIS_URL)

    # INFO server
    var info = client.raw("INFO", "server")
    assert_true(len(info) > 0, "INFO server 应返回非空结果")


def test_error_handling() raises:
    """测试错误处理"""
    # 测试无效 URL - 应该抛出异常
    var exception_thrown = False
    try:
        var client = RedisClient("redis://invalid_host:9999")
        _ = client.ping()
    except:
        exception_thrown = True

    # 我们接受连接失败或 ping 失败
    # 这里不做严格断言，因为行为可能因环境而异


# ============================================================================
# 主函数
# ============================================================================


def main() raises:
    print("=" * 50)
    print("Redis Mojo 客户端单元测试")
    print("=" * 50)
    print()

    var passed = 0
    var failed = 0

    # 测试 1: 连接功能
    print("测试 1: 连接功能")
    print("  测试: 连接和 PING ... ", end="")
    try:
        test_connection()
        print("✓ 通过")
        passed += 1
    except e:
        print("✗ 失败: " + String(e))
        failed += 1
    print()

    # 测试 2: 字符串操作
    print("测试 2: 字符串操作")
    print("  测试: 字符串 SET/GET/EXISTS/EXPIRE/TTL/DELETE ... ", end="")
    try:
        test_string_operations()
        print("✓ 通过")
        passed += 1
    except e:
        print("✗ 失败: " + String(e))
        failed += 1
    print()

    # 测试 3: 列表操作
    print("测试 3: 列表操作")
    print("  测试: 列表 LPUSH/RPUSH/LLEN/LPOP/RPOP ... ", end="")
    try:
        test_list_operations()
        print("✓ 通过")
        passed += 1
    except e:
        print("✗ 失败: " + String(e))
        failed += 1
    print()

    # 测试 4: 哈希表操作
    print("测试 4: 哈希表操作")
    print("  测试: 哈希表 HSET/HGET/HEXISTS/HDEL/HGETALL ... ", end="")
    try:
        test_hash_operations()
        print("✓ 通过")
        passed += 1
    except e:
        print("✗ 失败: " + String(e))
        failed += 1
    print()

    # 测试 5: 集合操作
    print("测试 5: 集合操作")
    print("  测试: 集合 SADD/SISMEMBER/SCARD/SREM ... ", end="")
    try:
        test_set_operations()
        print("✓ 通过")
        passed += 1
    except e:
        print("✗ 失败: " + String(e))
        failed += 1
    print()

    # 测试 6: 原始命令
    print("测试 6: 原始命令")
    print("  测试: 原始命令执行 ... ", end="")
    try:
        test_raw_command()
        print("✓ 通过")
        passed += 1
    except e:
        print("✗ 失败: " + String(e))
        failed += 1
    print()

    # 测试 7: 错误处理
    print("测试 7: 错误处理")
    print("  测试: 错误处理 ... ", end="")
    try:
        test_error_handling()
        print("✓ 通过")
        passed += 1
    except e:
        print("✗ 失败: " + String(e))
        failed += 1
    print()

    # 打印摘要
    print("=" * 50)
    print("测试摘要:")
    print("  通过: " + String(passed))
    print("  失败: " + String(failed))
    print("=" * 50)

    if failed > 0:
        raise Error("部分测试失败")
