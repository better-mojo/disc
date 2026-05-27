//! Redis FFI 基本示例 - 演示如何使用 redis-rs 客户端

use redis::{Client, Commands, Connection, RedisResult};

fn main() {
    // 从环境变量获取 Redis URL，或使用带密码的默认值
    // 格式: redis://:password@host:port/db
    let redis_url = std::env::var("REDIS_URL")
        .unwrap_or_else(|_| "redis://:redis_2MB8cN@192.168.139.143:6379/0".to_string());
    
    println!("===== Redis FFI 示例 =====\n");
    println!("连接到: {}\n", redis_url);
    
    // 创建 Redis 客户端
    let client = match Client::open(redis_url.as_str()) {
        Ok(client) => {
            println!("✓ Redis 客户端创建成功");
            client
        }
        Err(e) => {
            eprintln!("✗ 创建 Redis 客户端失败: {:?}", e);
            return;
        }
    };
    
    // 获取连接
    let mut conn: Connection = match client.get_connection() {
        Ok(conn) => {
            println!("✓ Redis 连接建立成功\n");
            conn
        }
        Err(e) => {
            eprintln!("✗ 连接 Redis 失败: {:?}", e);
            return;
        }
    };
    
    // 1. PING 测试
    println!("1. PING 测试:");
    match redis::cmd("PING").query::<String>(&mut conn) {
        Ok(result) => println!("   PING -> {}", result),
        Err(e) => println!("   PING 失败: {:?}", e),
    }
    
    // 2. 字符串操作
    println!("\n2. 字符串操作:");
    let test_key = "test:ffi:string";
    let test_value = "Hello from Rust FFI!";
    
    // SET
    match conn.set::<&str, &str, ()>(test_key, test_value) {
        Ok(_) => println!("   SET {} -> OK", test_key),
        Err(e) => println!("   SET 失败: {:?}", e),
    }
    
    // GET
    match conn.get::<&str, Option<String>>(test_key) {
        Ok(Some(value)) => println!("   GET {} -> {}", test_key, value),
        Ok(None) => println!("   GET {} -> (nil)", test_key),
        Err(e) => println!("   GET 失败: {:?}", e),
    }
    
    // EXISTS
    match conn.exists::<&str, bool>(test_key) {
        Ok(exists) => println!("   EXISTS {} -> {}", test_key, exists),
        Err(e) => println!("   EXISTS 失败: {:?}", e),
    }
    
    // EXPIRE
    match conn.expire::<&str, i64>(test_key, 60) {
        Ok(1) => println!("   EXPIRE {} 60s -> OK", test_key),
        Ok(_) => println!("   EXPIRE {} -> 键不存在", test_key),
        Err(e) => println!("   EXPIRE 失败: {:?}", e),
    }
    
    // TTL
    match conn.ttl::<&str, i64>(test_key) {
        Ok(ttl) => println!("   TTL {} -> {}s", test_key, ttl),
        Err(e) => println!("   TTL 失败: {:?}", e),
    }
    
    // 3. 列表操作
    println!("\n3. 列表操作:");
    let list_key = "test:ffi:list";
    
    // 清理旧数据
    let _: RedisResult<i64> = conn.del(list_key);
    
    // LPUSH
    match conn.lpush::<&str, &str, i64>(list_key, "item1") {
        Ok(len) => println!("   LPUSH {} item1 -> 列表长度: {}", list_key, len),
        Err(e) => println!("   LPUSH 失败: {:?}", e),
    }
    
    match conn.lpush::<&str, &str, i64>(list_key, "item2") {
        Ok(len) => println!("   LPUSH {} item2 -> 列表长度: {}", list_key, len),
        Err(e) => println!("   LPUSH 失败: {:?}", e),
    }
    
    // RPUSH
    match conn.rpush::<&str, &str, i64>(list_key, "item3") {
        Ok(len) => println!("   RPUSH {} item3 -> 列表长度: {}", list_key, len),
        Err(e) => println!("   RPUSH 失败: {:?}", e),
    }
    
    // LLEN
    match conn.llen::<&str, i64>(list_key) {
        Ok(len) => println!("   LLEN {} -> {}", list_key, len),
        Err(e) => println!("   LLEN 失败: {:?}", e),
    }
    
    // LPOP
    match conn.lpop::<&str, Option<String>>(list_key, None) {
        Ok(Some(value)) => println!("   LPOP {} -> {}", list_key, value),
        Ok(None) => println!("   LPOP {} -> (nil)", list_key),
        Err(e) => println!("   LPOP 失败: {:?}", e),
    }
    
    // 4. 哈希表操作
    println!("\n4. 哈希表操作:");
    let hash_key = "test:ffi:hash";
    
    // 清理旧数据
    let _: RedisResult<i64> = conn.del(hash_key);
    
    // HSET
    match conn.hset::<&str, &str, &str, i64>(hash_key, "field1", "value1") {
        Ok(_) => println!("   HSET {} field1 value1 -> OK", hash_key),
        Err(e) => println!("   HSET 失败: {:?}", e),
    }
    
    match conn.hset::<&str, &str, &str, i64>(hash_key, "field2", "value2") {
        Ok(_) => println!("   HSET {} field2 value2 -> OK", hash_key),
        Err(e) => println!("   HSET 失败: {:?}", e),
    }
    
    // HGET
    match conn.hget::<&str, &str, Option<String>>(hash_key, "field1") {
        Ok(Some(value)) => println!("   HGET {} field1 -> {}", hash_key, value),
        Ok(None) => println!("   HGET {} field1 -> (nil)", hash_key),
        Err(e) => println!("   HGET 失败: {:?}", e),
    }
    
    // HEXISTS
    match conn.hexists::<&str, &str, bool>(hash_key, "field1") {
        Ok(exists) => println!("   HEXISTS {} field1 -> {}", hash_key, exists),
        Err(e) => println!("   HEXISTS 失败: {:?}", e),
    }
    
    // HGETALL
    match conn.hgetall::<&str, Vec<(String, String)>>(hash_key) {
        Ok(pairs) => {
            print!("   HGETALL {} -> ", hash_key);
            for (field, value) in &pairs {
                print!("{}:{} ", field, value);
            }
            println!();
        }
        Err(e) => println!("   HGETALL 失败: {:?}", e),
    }
    
    // 5. 集合操作
    println!("\n5. 集合操作:");
    let set_key = "test:ffi:set";
    
    // 清理旧数据
    let _: RedisResult<i64> = conn.del(set_key);
    
    // SADD
    match conn.sadd::<&str, &str, i64>(set_key, "member1") {
        Ok(count) => println!("   SADD {} member1 -> 新增: {}", set_key, count),
        Err(e) => println!("   SADD 失败: {:?}", e),
    }
    
    match conn.sadd::<&str, &str, i64>(set_key, "member2") {
        Ok(count) => println!("   SADD {} member2 -> 新增: {}", set_key, count),
        Err(e) => println!("   SADD 失败: {:?}", e),
    }
    
    // SISMEMBER
    match conn.sismember::<&str, &str, bool>(set_key, "member1") {
        Ok(is_member) => println!("   SISMEMBER {} member1 -> {}", set_key, is_member),
        Err(e) => println!("   SISMEMBER 失败: {:?}", e),
    }
    
    // SCARD
    match conn.scard::<&str, i64>(set_key) {
        Ok(count) => println!("   SCARD {} -> {}", set_key, count),
        Err(e) => println!("   SCARD 失败: {:?}", e),
    }
    
    // 6. 清理测试数据
    println!("\n6. 清理测试数据:");
    // let keys_to_delete = vec![test_key, list_key, hash_key, set_key];
    // for key in &keys_to_delete {
    //     match conn.del::<&str, i64>(*key) {
    //         Ok(1) => println!("   DEL {} -> OK", key),
    //         Ok(_) => println!("   DEL {} -> 键不存在", key),
    //         Err(e) => println!("   DEL {} 失败: {:?}", key, e),
    //     }
    // }
    
    println!("\n===== 示例完成 =====");
}
