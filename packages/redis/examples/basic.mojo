"""
Redis Mojo 客户端基本示例

演示如何使用 redis 包进行基本的 Redis 操作。
"""

from redis import RedisClient
from std.os import getenv
from std.collections.string import StringSlice


def main() raises:
    print("===== Redis Mojo 客户端示例 =====\n")

    # 从环境变量获取 Redis URL，或使用默认值
    var redis_url = getenv(
        "REDIS_URL", "redis://:redis_2MB8cN@192.168.139.143:6379/0"
    )
    print("连接到: " + redis_url + "\n")

    # 创建 Redis 客户端
    var client = RedisClient(redis_url)
    print("✓ Redis 客户端创建成功\n")

    # 1. PING 测试
    print("1. PING 测试:")
    var pong = client.ping()
    print("   PING -> " + pong)

    # 2. 字符串操作
    print("\n2. 字符串操作:")
    var test_key = "test:mojo:string"
    var test_value = "Hello from Mojo!"

    # SET
    var set_result = client.set(test_key, test_value)
    print("   SET " + test_key + " -> " + ("OK" if set_result else "FAILED"))

    # GET
    var get_result = client.get(test_key)
    print("   GET " + test_key + " -> " + get_result)

    # EXISTS
    var exists_result = client.exists(test_key)
    print(
        "   EXISTS "
        + test_key
        + " -> "
        + ("true" if exists_result else "false")
    )

    # EXPIRE
    var expire_result = client.expire(test_key, 60)
    print(
        "   EXPIRE "
        + test_key
        + " 60s -> "
        + ("true" if expire_result else "false")
    )

    # TTL
    var ttl_result = client.ttl(test_key)
    print("   TTL " + test_key + " -> " + String(ttl_result) + "s")

    # 3. 列表操作
    print("\n3. 列表操作:")
    var list_key = "test:mojo:list"
    _ = client.delete(list_key)  # 清理旧数据

    var lpush1 = client.lpush(list_key, "item1")
    print("   LPUSH " + list_key + " item1 -> 列表长度: " + String(lpush1))

    var lpush2 = client.lpush(list_key, "item2")
    print("   LPUSH " + list_key + " item2 -> 列表长度: " + String(lpush2))

    var rpush1 = client.rpush(list_key, "item3")
    print("   RPUSH " + list_key + " item3 -> 列表长度: " + String(rpush1))

    var llen = client.llen(list_key)
    print("   LLEN " + list_key + " -> " + String(llen))

    var lpop = client.lpop(list_key)
    print("   LPOP " + list_key + " -> " + lpop)

    # 4. 哈希表操作
    print("\n4. 哈希表操作:")
    var hash_key = "test:mojo:hash"
    _ = client.delete(hash_key)  # 清理旧数据

    var hset1 = client.hset(hash_key, "field1", "value1")
    print(
        "   HSET "
        + hash_key
        + " field1 value1 -> "
        + ("OK" if hset1 else "FAILED")
    )

    var hset2 = client.hset(hash_key, "field2", "value2")
    print(
        "   HSET "
        + hash_key
        + " field2 value2 -> "
        + ("OK" if hset2 else "FAILED")
    )

    var hget = client.hget(hash_key, "field1")
    print("   HGET " + hash_key + " field1 -> " + hget)

    var hexists = client.hexists(hash_key, "field1")
    print(
        "   HEXISTS "
        + hash_key
        + " field1 -> "
        + ("true" if hexists else "false")
    )

    var hgetall = client.hgetall(hash_key)
    print("   HGETALL " + hash_key + " -> " + hgetall)

    # 5. 集合操作
    print("\n5. 集合操作:")
    var set_key = "test:mojo:set"
    _ = client.delete(set_key)  # 清理旧数据

    var sadd1 = client.sadd(set_key, "member1")
    print("   SADD " + set_key + " member1 -> 新增: " + String(sadd1))

    var sadd2 = client.sadd(set_key, "member2")
    print("   SADD " + set_key + " member2 -> 新增: " + String(sadd2))

    var sismember = client.sismember(set_key, "member1")
    print(
        "   SISMEMBER "
        + set_key
        + " member1 -> "
        + ("true" if sismember else "false")
    )

    var scard = client.scard(set_key)
    print("   SCARD " + set_key + " -> " + String(scard))

    # 6. 原始命令
    print("\n6. 原始命令:")
    var info = client.raw("INFO", "server")
    # 只显示前 100 个字符
    var info_preview: String
    if info.byte_length() > 100:
        info_preview = String(StringSlice(info)[byte=0:100])
    else:
        info_preview = info
    print("   RAW INFO server -> " + info_preview + "...")

    # 7. 清理测试数据
    print("\n7. 清理测试数据:")
    # _ = client.delete(test_key)
    # _ = client.delete(list_key)
    # _ = client.delete(hash_key)
    # _ = client.delete(set_key)
    print("   已删除所有测试键")

    print("\n===== 示例完成 =====")
