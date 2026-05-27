#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "cffi.h"

// 辅助函数：打印带标签的消息
void print_section(const char* title) {
    printf("\n%s:\n", title);
}

// 辅助函数：打印结果
void print_result(const char* operation, const char* result) {
    printf("   %s -> %s\n", operation, result);
}

void print_result_bool(const char* operation, int result) {
    printf("   %s -> %s\n", operation, result ? "true" : "false");
}

void print_result_int(const char* operation, int64_t result) {
    printf("   %s -> %ld\n", operation, (long)result);
}

int main(int argc, char const *const argv[])
{
    printf("===== redis-ffi C 示例 =====\n");
    
    // 获取版本信息
    print_section("版本信息");
    char *version = redis_version();
    print_result("redis_version()", version);
    free_rs_string(version);
    
    // 初始化 Redis 连接
    print_section("初始化连接");
    
    // 从环境变量获取 Redis URL，或使用默认值
    const char* redis_url = getenv("REDIS_URL");
    if (redis_url == NULL) {
        redis_url = "redis://127.0.0.1:6379/0";
    }
    printf("   连接到: %s\n", redis_url);
    
    int connected = redis_init(redis_url);
    print_result_bool("redis_init()", connected);
    
    if (!connected) {
        printf("\n✗ 无法连接到 Redis，请检查:\n");
        printf("   1. Redis 服务器是否运行\n");
        printf("   2. REDIS_URL 环境变量是否正确\n");
        printf("   3. 网络连接是否正常\n");
        return EXIT_FAILURE;
    }
    
    // 检查连接状态
    print_result_bool("redis_is_connected()", redis_is_connected());
    
    // PING 测试
    print_section("1. PING 测试");
    char *ping_result = redis_ping();
    print_result("redis_ping()", ping_result);
    free_rs_string(ping_result);
    
    // 字符串操作
    print_section("2. 字符串操作");
    
    const char* test_key = "test:c:string";
    const char* test_value = "Hello from C FFI!";
    
    // SET
    int set_result = redis_set(test_key, test_value);
    print_result_bool("redis_set()", set_result);
    
    // GET
    char *get_result = redis_get(test_key);
    print_result("redis_get()", get_result);
    free_rs_string(get_result);
    
    // EXISTS
    int exists_result = redis_exists(test_key);
    print_result_bool("redis_exists()", exists_result);
    
    // EXPIRE
    int expire_result = redis_expire(test_key, 60);
    print_result_bool("redis_expire(60s)", expire_result);
    
    // TTL
    int64_t ttl_result = redis_ttl(test_key);
    print_result_int("redis_ttl()", ttl_result);
    
    // 列表操作
    print_section("3. 列表操作");
    
    const char* list_key = "test:c:list";
    
    // 清理旧数据
    redis_del(list_key);
    
    // LPUSH
    int64_t lpush_result = redis_lpush(list_key, "item1");
    print_result_int("redis_lpush(item1)", lpush_result);
    
    lpush_result = redis_lpush(list_key, "item2");
    print_result_int("redis_lpush(item2)", lpush_result);
    
    // RPUSH
    int64_t rpush_result = redis_rpush(list_key, "item3");
    print_result_int("redis_rpush(item3)", rpush_result);
    
    // LLEN
    int64_t llen_result = redis_llen(list_key);
    print_result_int("redis_llen()", llen_result);
    
    // LPOP
    char *lpop_result = redis_lpop(list_key);
    print_result("redis_lpop()", lpop_result);
    free_rs_string(lpop_result);
    
    // RPOP
    char *rpop_result = redis_rpop(list_key);
    print_result("redis_rpop()", rpop_result);
    free_rs_string(rpop_result);
    
    // 哈希表操作
    print_section("4. 哈希表操作");
    
    const char* hash_key = "test:c:hash";
    
    // 清理旧数据
    redis_del(hash_key);
    
    // HSET
    int hset_result = redis_hset(hash_key, "field1", "value1");
    print_result_bool("redis_hset(field1, value1)", hset_result);
    
    hset_result = redis_hset(hash_key, "field2", "value2");
    print_result_bool("redis_hset(field2, value2)", hset_result);
    
    // HGET
    char *hget_result = redis_hget(hash_key, "field1");
    print_result("redis_hget(field1)", hget_result);
    free_rs_string(hget_result);
    
    // HEXISTS
    int hexists_result = redis_hexists(hash_key, "field1");
    print_result_bool("redis_hexists(field1)", hexists_result);
    
    // HGETALL
    char *hgetall_result = redis_hgetall(hash_key);
    print_result("redis_hgetall()", hgetall_result);
    free_rs_string(hgetall_result);
    
    // HDEL
    int64_t hdel_result = redis_hdel(hash_key, "field1");
    print_result_int("redis_hdel(field1)", hdel_result);
    
    // 集合操作
    print_section("5. 集合操作");
    
    const char* set_key = "test:c:set";
    
    // 清理旧数据
    redis_del(set_key);
    
    // SADD
    int64_t sadd_result = redis_sadd(set_key, "member1");
    print_result_int("redis_sadd(member1)", sadd_result);
    
    sadd_result = redis_sadd(set_key, "member2");
    print_result_int("redis_sadd(member2)", sadd_result);
    
    // 重复添加
    sadd_result = redis_sadd(set_key, "member1");
    print_result_int("redis_sadd(member1) [重复]", sadd_result);
    
    // SISMEMBER
    int sismember_result = redis_sismember(set_key, "member1");
    print_result_bool("redis_sismember(member1)", sismember_result);
    
    // SCARD
    int64_t scard_result = redis_scard(set_key);
    print_result_int("redis_scard()", scard_result);
    
    // SREM
    int64_t srem_result = redis_srem(set_key, "member1");
    print_result_int("redis_srem(member1)", srem_result);
    
    // 再次检查成员
    sismember_result = redis_sismember(set_key, "member1");
    print_result_bool("redis_sismember(member1) [删除后]", sismember_result);
    
    // 原始命令
    print_section("6. 原始命令");
    
    char *raw_result = redis_raw("INFO", "server");
    // 只打印前100个字符
    printf("   redis_raw(\"INFO\", \"server\") -> ");
    for (int i = 0; i < 100 && raw_result[i] != '\0'; i++) {
        putchar(raw_result[i]);
    }
    printf("...\n");
    free_rs_string(raw_result);
    
    // 清理测试数据
    print_section("7. 清理测试数据");
    
    // int64_t del_result = redis_del(test_key);
    // print_result_int("redis_del(string_key)", del_result);
    
    // del_result = redis_del(list_key);
    // print_result_int("redis_del(list_key)", del_result);
    
    // del_result = redis_del(hash_key);
    // print_result_int("redis_del(hash_key)", del_result);
    
    // del_result = redis_del(set_key);
    // print_result_int("redis_del(set_key)", del_result);
    
    // 关闭连接
    print_section("关闭连接");
    redis_close();
    print_result_bool("redis_is_connected() [关闭后]", redis_is_connected());
    
    printf("\n===== 示例完成 =====\n");
    
    return EXIT_SUCCESS;
}
