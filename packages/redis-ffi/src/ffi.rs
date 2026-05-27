use safer_ffi::prelude::*;
use std::ffi::CString;
use std::sync::Mutex;
use once_cell::sync::Lazy;
use redis::{Client, Commands, Connection};

/// 调试输出开关，可以通过环境变量控制
const DEBUG_ENABLED: bool = cfg!(debug_assertions);

#[inline]
fn debug_print(msg: &str) {
    if DEBUG_ENABLED {
        println!("{}", msg);
    }
}

/// 全局 Redis 连接管理器
static REDIS_CONNECTION: Lazy<Mutex<Option<Connection>>> = Lazy::new(|| {
    Mutex::new(None)
});

/// 初始化 Redis 连接
/// 
/// # 参数
/// - `url`: Redis 连接 URL，格式如 "redis://127.0.0.1:6379/0"
/// 
/// # 返回值
/// - `true`: 连接成功
/// - `false`: 连接失败
/// 
/// # Safety
/// - `url` 必须是有效的 UTF-8 字符串
/// - 必须在程序启动时调用一次
#[ffi_export]
pub fn redis_init(url: char_p::Ref<'_>) -> bool {
    let url_str = url.to_str();
    debug_print(&format!("rust > initializing redis connection to: {}", url_str));
    
    match Client::open(url_str) {
        Ok(client) => {
            match client.get_connection() {
                Ok(conn) => {
                    let mut guard = REDIS_CONNECTION.lock().unwrap();
                    *guard = Some(conn);
                    debug_print("rust > redis connection established successfully");
                    true
                }
                Err(e) => {
                    eprintln!("rust > failed to get redis connection: {:?}", e);
                    false
                }
            }
        }
        Err(e) => {
            eprintln!("rust > failed to open redis client: {:?}", e);
            false
        }
    }
}

/// 检查 Redis 连接是否已初始化
#[ffi_export]
pub fn redis_is_connected() -> bool {
    let guard = REDIS_CONNECTION.lock().unwrap();
    guard.is_some()
}

/// 关闭 Redis 连接
#[ffi_export]
pub fn redis_close() {
    debug_print("rust > closing redis connection");
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    *guard = None;
}

/// 执行 PING 命令，测试连接
/// 
/// # 返回值
/// 返回 "PONG" 如果连接正常，否则返回错误信息
#[ffi_export]
pub fn redis_ping() -> char_p::Box {
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match redis::cmd("PING").query::<String>(conn) {
                Ok(result) => {
                    debug_print(&format!("rust > ping result: {}", result));
                    CString::new(result).unwrap().into()
                }
                Err(e) => {
                    let err_msg = format!("ERROR: {:?}", e);
                    CString::new(err_msg).unwrap().into()
                }
            }
        }
        None => {
            CString::new("ERROR: Not connected").unwrap().into()
        }
    }
}

/// 设置字符串键值
/// 
/// # 参数
/// - `key`: 键名
/// - `value`: 键值
/// 
/// # 返回值
/// - `true`: 设置成功
/// - `false`: 设置失败
#[ffi_export]
pub fn redis_set(key: char_p::Ref<'_>, value: char_p::Ref<'_>) -> bool {
    let key_str = key.to_str();
    let value_str = value.to_str();
    debug_print(&format!("rust > set key: {}, value: {}", key_str, value_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.set::<&str, &str, ()>(key_str, value_str) {
                Ok(_) => true,
                Err(e) => {
                    eprintln!("rust > failed to set key: {:?}", e);
                    false
                }
            }
        }
        None => {
            eprintln!("rust > not connected to redis");
            false
        }
    }
}

/// 获取字符串键值
/// 
/// # 参数
/// - `key`: 键名
/// 
/// # 返回值
/// - 成功: 返回键值字符串
/// - 失败: 返回错误信息或 nil
#[ffi_export]
pub fn redis_get(key: char_p::Ref<'_>) -> char_p::Box {
    let key_str = key.to_str();
    debug_print(&format!("rust > get key: {}", key_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.get::<&str, Option<String>>(key_str) {
                Ok(Some(value)) => {
                    CString::new(value).unwrap().into()
                }
                Ok(None) => {
                    CString::new("(nil)").unwrap().into()
                }
                Err(e) => {
                    let err_msg = format!("ERROR: {:?}", e);
                    CString::new(err_msg).unwrap().into()
                }
            }
        }
        None => {
            CString::new("ERROR: Not connected").unwrap().into()
        }
    }
}

/// 删除指定的键
/// 
/// # 参数
/// - `key`: 键名
/// 
/// # 返回值
/// - 成功删除的键数量
#[ffi_export]
pub fn redis_del(key: char_p::Ref<'_>) -> i64 {
    let key_str = key.to_str();
    debug_print(&format!("rust > del key: {}", key_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.del::<&str, i64>(key_str) {
                Ok(count) => count,
                Err(e) => {
                    eprintln!("rust > failed to del key: {:?}", e);
                    -1
                }
            }
        }
        None => {
            eprintln!("rust > not connected to redis");
            -1
        }
    }
}

/// 检查键是否存在
/// 
/// # 参数
/// - `key`: 键名
/// 
/// # 返回值
/// - `true`: 键存在
/// - `false`: 键不存在
#[ffi_export]
pub fn redis_exists(key: char_p::Ref<'_>) -> bool {
    let key_str = key.to_str();
    debug_print(&format!("rust > exists key: {}", key_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.exists::<&str, bool>(key_str) {
                Ok(exists) => exists,
                Err(e) => {
                    eprintln!("rust > failed to check exists: {:?}", e);
                    false
                }
            }
        }
        None => {
            eprintln!("rust > not connected to redis");
            false
        }
    }
}

/// 设置键的过期时间（秒）
/// 
/// # 参数
/// - `key`: 键名
/// - `seconds`: 过期时间（秒）
/// 
/// # 返回值
/// - `true`: 设置成功
/// - `false`: 设置失败
#[ffi_export]
pub fn redis_expire(key: char_p::Ref<'_>, seconds: i64) -> bool {
    let key_str = key.to_str();
    debug_print(&format!("rust > expire key: {}, seconds: {}", key_str, seconds));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.expire::<&str, i64>(key_str, seconds) {
                Ok(1) => true,
                Ok(_) => false,
                Err(e) => {
                    eprintln!("rust > failed to expire key: {:?}", e);
                    false
                }
            }
        }
        None => {
            eprintln!("rust > not connected to redis");
            false
        }
    }
}

/// 获取键的剩余过期时间（秒）
/// 
/// # 参数
/// - `key`: 键名
/// 
/// # 返回值
/// - 成功: 返回剩余秒数
/// - 键不存在或没有过期时间: 返回 -1
/// - 错误: 返回 -2
#[ffi_export]
pub fn redis_ttl(key: char_p::Ref<'_>) -> i64 {
    let key_str = key.to_str();
    debug_print(&format!("rust > ttl key: {}", key_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.ttl::<&str, i64>(key_str) {
                Ok(ttl) => ttl,
                Err(e) => {
                    eprintln!("rust > failed to get ttl: {:?}", e);
                    -2
                }
            }
        }
        None => {
            eprintln!("rust > not connected to redis");
            -2
        }
    }
}

/// 将值推入列表左侧
/// 
/// # 参数
/// - `key`: 列表键名
/// - `value`: 要推入的值
/// 
/// # 返回值
/// - 成功: 返回列表长度
/// - 失败: 返回 -1
#[ffi_export]
pub fn redis_lpush(key: char_p::Ref<'_>, value: char_p::Ref<'_>) -> i64 {
    let key_str = key.to_str();
    let value_str = value.to_str();
    debug_print(&format!("rust > lpush key: {}, value: {}", key_str, value_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.lpush::<&str, &str, i64>(key_str, value_str) {
                Ok(len) => len,
                Err(e) => {
                    eprintln!("rust > failed to lpush: {:?}", e);
                    -1
                }
            }
        }
        None => {
            eprintln!("rust > not connected to redis");
            -1
        }
    }
}

/// 将值推入列表右侧
/// 
/// # 参数
/// - `key`: 列表键名
/// - `value`: 要推入的值
/// 
/// # 返回值
/// - 成功: 返回列表长度
/// - 失败: 返回 -1
#[ffi_export]
pub fn redis_rpush(key: char_p::Ref<'_>, value: char_p::Ref<'_>) -> i64 {
    let key_str = key.to_str();
    let value_str = value.to_str();
    debug_print(&format!("rust > rpush key: {}, value: {}", key_str, value_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.rpush::<&str, &str, i64>(key_str, value_str) {
                Ok(len) => len,
                Err(e) => {
                    eprintln!("rust > failed to rpush: {:?}", e);
                    -1
                }
            }
        }
        None => {
            eprintln!("rust > not connected to redis");
            -1
        }
    }
}

/// 从列表左侧弹出值
/// 
/// # 参数
/// - `key`: 列表键名
/// 
/// # 返回值
/// - 成功: 返回弹出的值
/// - 列表为空: 返回 "(nil)"
/// - 失败: 返回错误信息
#[ffi_export]
pub fn redis_lpop(key: char_p::Ref<'_>) -> char_p::Box {
    let key_str = key.to_str();
    debug_print(&format!("rust > lpop key: {}", key_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.lpop::<&str, Option<String>>(key_str, None) {
                Ok(Some(value)) => {
                    CString::new(value).unwrap().into()
                }
                Ok(None) => {
                    CString::new("(nil)").unwrap().into()
                }
                Err(e) => {
                    let err_msg = format!("ERROR: {:?}", e);
                    CString::new(err_msg).unwrap().into()
                }
            }
        }
        None => {
            CString::new("ERROR: Not connected").unwrap().into()
        }
    }
}

/// 从列表右侧弹出值
/// 
/// # 参数
/// - `key`: 列表键名
/// 
/// # 返回值
/// - 成功: 返回弹出的值
/// - 列表为空: 返回 "(nil)"
/// - 失败: 返回错误信息
#[ffi_export]
pub fn redis_rpop(key: char_p::Ref<'_>) -> char_p::Box {
    let key_str = key.to_str();
    debug_print(&format!("rust > rpop key: {}", key_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.rpop::<&str, Option<String>>(key_str, None) {
                Ok(Some(value)) => {
                    CString::new(value).unwrap().into()
                }
                Ok(None) => {
                    CString::new("(nil)").unwrap().into()
                }
                Err(e) => {
                    let err_msg = format!("ERROR: {:?}", e);
                    CString::new(err_msg).unwrap().into()
                }
            }
        }
        None => {
            CString::new("ERROR: Not connected").unwrap().into()
        }
    }
}

/// 获取列表长度
/// 
/// # 参数
/// - `key`: 列表键名
/// 
/// # 返回值
/// - 成功: 返回列表长度
/// - 失败: 返回 -1
#[ffi_export]
pub fn redis_llen(key: char_p::Ref<'_>) -> i64 {
    let key_str = key.to_str();
    debug_print(&format!("rust > llen key: {}", key_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.llen::<&str, i64>(key_str) {
                Ok(len) => len,
                Err(e) => {
                    eprintln!("rust > failed to llen: {:?}", e);
                    -1
                }
            }
        }
        None => {
            eprintln!("rust > not connected to redis");
            -1
        }
    }
}

/// 设置哈希表字段
/// 
/// # 参数
/// - `key`: 哈希表键名
/// - `field`: 字段名
/// - `value`: 字段值
/// 
/// # 返回值
/// - `true`: 设置成功
/// - `false`: 设置失败
#[ffi_export]
pub fn redis_hset(key: char_p::Ref<'_>, field: char_p::Ref<'_>, value: char_p::Ref<'_>) -> bool {
    let key_str = key.to_str();
    let field_str = field.to_str();
    let value_str = value.to_str();
    debug_print(&format!("rust > hset key: {}, field: {}, value: {}", key_str, field_str, value_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.hset::<&str, &str, &str, i64>(key_str, field_str, value_str) {
                Ok(_) => true,
                Err(e) => {
                    eprintln!("rust > failed to hset: {:?}", e);
                    false
                }
            }
        }
        None => {
            eprintln!("rust > not connected to redis");
            false
        }
    }
}

/// 获取哈希表字段值
/// 
/// # 参数
/// - `key`: 哈希表键名
/// - `field`: 字段名
/// 
/// # 返回值
/// - 成功: 返回字段值
/// - 字段不存在: 返回 "(nil)"
/// - 失败: 返回错误信息
#[ffi_export]
pub fn redis_hget(key: char_p::Ref<'_>, field: char_p::Ref<'_>) -> char_p::Box {
    let key_str = key.to_str();
    let field_str = field.to_str();
    debug_print(&format!("rust > hget key: {}, field: {}", key_str, field_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.hget::<&str, &str, Option<String>>(key_str, field_str) {
                Ok(Some(value)) => {
                    CString::new(value).unwrap().into()
                }
                Ok(None) => {
                    CString::new("(nil)").unwrap().into()
                }
                Err(e) => {
                    let err_msg = format!("ERROR: {:?}", e);
                    CString::new(err_msg).unwrap().into()
                }
            }
        }
        None => {
            CString::new("ERROR: Not connected").unwrap().into()
        }
    }
}

/// 删除哈希表字段
/// 
/// # 参数
/// - `key`: 哈希表键名
/// - `field`: 字段名
/// 
/// # 返回值
/// - 成功删除的字段数量
#[ffi_export]
pub fn redis_hdel(key: char_p::Ref<'_>, field: char_p::Ref<'_>) -> i64 {
    let key_str = key.to_str();
    let field_str = field.to_str();
    debug_print(&format!("rust > hdel key: {}, field: {}", key_str, field_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.hdel::<&str, &str, i64>(key_str, field_str) {
                Ok(count) => count,
                Err(e) => {
                    eprintln!("rust > failed to hdel: {:?}", e);
                    -1
                }
            }
        }
        None => {
            eprintln!("rust > not connected to redis");
            -1
        }
    }
}

/// 检查哈希表字段是否存在
/// 
/// # 参数
/// - `key`: 哈希表键名
/// - `field`: 字段名
/// 
/// # 返回值
/// - `true`: 字段存在
/// - `false`: 字段不存在
#[ffi_export]
pub fn redis_hexists(key: char_p::Ref<'_>, field: char_p::Ref<'_>) -> bool {
    let key_str = key.to_str();
    let field_str = field.to_str();
    debug_print(&format!("rust > hexists key: {}, field: {}", key_str, field_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.hexists::<&str, &str, bool>(key_str, field_str) {
                Ok(exists) => exists,
                Err(e) => {
                    eprintln!("rust > failed to hexists: {:?}", e);
                    false
                }
            }
        }
        None => {
            eprintln!("rust > not connected to redis");
            false
        }
    }
}

/// 获取哈希表所有字段和值
/// 
/// # 参数
/// - `key`: 哈希表键名
/// 
/// # 返回值
/// - 成功: 返回 JSON 格式的字符串，如 {"field1":"value1","field2":"value2"}
/// - 失败: 返回错误信息
#[ffi_export]
pub fn redis_hgetall(key: char_p::Ref<'_>) -> char_p::Box {
    let key_str = key.to_str();
    debug_print(&format!("rust > hgetall key: {}", key_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.hgetall::<&str, Vec<(String, String)>>(key_str) {
                Ok(pairs) => {
                    let mut json = String::from("{");
                    for (i, (field, value)) in pairs.iter().enumerate() {
                        if i > 0 {
                            json.push(',');
                        }
                        json.push_str(&format!("\"{}\":\"{}\"", field, value));
                    }
                    json.push('}');
                    CString::new(json).unwrap().into()
                }
                Err(e) => {
                    let err_msg = format!("ERROR: {:?}", e);
                    CString::new(err_msg).unwrap().into()
                }
            }
        }
        None => {
            CString::new("ERROR: Not connected").unwrap().into()
        }
    }
}

/// 将成员添加到集合
/// 
/// # 参数
/// - `key`: 集合键名
/// - `member`: 成员值
/// 
/// # 返回值
/// - 成功: 返回添加到集合的元素数量（新元素为1，已存在为0）
/// - 失败: 返回 -1
#[ffi_export]
pub fn redis_sadd(key: char_p::Ref<'_>, member: char_p::Ref<'_>) -> i64 {
    let key_str = key.to_str();
    let member_str = member.to_str();
    debug_print(&format!("rust > sadd key: {}, member: {}", key_str, member_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.sadd::<&str, &str, i64>(key_str, member_str) {
                Ok(count) => count,
                Err(e) => {
                    eprintln!("rust > failed to sadd: {:?}", e);
                    -1
                }
            }
        }
        None => {
            eprintln!("rust > not connected to redis");
            -1
        }
    }
}

/// 从集合移除成员
/// 
/// # 参数
/// - `key`: 集合键名
/// - `member`: 成员值
/// 
/// # 返回值
/// - 成功: 返回从集合移除的元素数量
/// - 失败: 返回 -1
#[ffi_export]
pub fn redis_srem(key: char_p::Ref<'_>, member: char_p::Ref<'_>) -> i64 {
    let key_str = key.to_str();
    let member_str = member.to_str();
    debug_print(&format!("rust > srem key: {}, member: {}", key_str, member_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.srem::<&str, &str, i64>(key_str, member_str) {
                Ok(count) => count,
                Err(e) => {
                    eprintln!("rust > failed to srem: {:?}", e);
                    -1
                }
            }
        }
        None => {
            eprintln!("rust > not connected to redis");
            -1
        }
    }
}

/// 检查成员是否在集合中
/// 
/// # 参数
/// - `key`: 集合键名
/// - `member`: 成员值
/// 
/// # 返回值
/// - `true`: 成员存在
/// - `false`: 成员不存在
#[ffi_export]
pub fn redis_sismember(key: char_p::Ref<'_>, member: char_p::Ref<'_>) -> bool {
    let key_str = key.to_str();
    let member_str = member.to_str();
    debug_print(&format!("rust > sismember key: {}, member: {}", key_str, member_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.sismember::<&str, &str, bool>(key_str, member_str) {
                Ok(is_member) => is_member,
                Err(e) => {
                    eprintln!("rust > failed to sismember: {:?}", e);
                    false
                }
            }
        }
        None => {
            eprintln!("rust > not connected to redis");
            false
        }
    }
}

/// 获取集合成员数量
/// 
/// # 参数
/// - `key`: 集合键名
/// 
/// # 返回值
/// - 成功: 返回集合成员数量
/// - 失败: 返回 -1
#[ffi_export]
pub fn redis_scard(key: char_p::Ref<'_>) -> i64 {
    let key_str = key.to_str();
    debug_print(&format!("rust > scard key: {}", key_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            match conn.scard::<&str, i64>(key_str) {
                Ok(count) => count,
                Err(e) => {
                    eprintln!("rust > failed to scard: {:?}", e);
                    -1
                }
            }
        }
        None => {
            eprintln!("rust > not connected to redis");
            -1
        }
    }
}

/// 执行原始 Redis 命令
/// 
/// # 参数
/// - `cmd`: 命令名称
/// - `args`: 命令参数，多个参数用空格分隔
/// 
/// # 返回值
/// - 成功: 返回命令执行结果
/// - 失败: 返回错误信息
#[ffi_export]
pub fn redis_raw(cmd: char_p::Ref<'_>, args: char_p::Ref<'_>) -> char_p::Box {
    let cmd_str = cmd.to_str();
    let args_str = args.to_str();
    debug_print(&format!("rust > raw cmd: {}, args: {}", cmd_str, args_str));
    
    let mut guard = REDIS_CONNECTION.lock().unwrap();
    
    match guard.as_mut() {
        Some(conn) => {
            let mut redis_cmd = redis::cmd(cmd_str);
            for arg in args_str.split_whitespace() {
                redis_cmd.arg(arg);
            }
            
            match redis_cmd.query::<redis::Value>(conn) {
                Ok(value) => {
                    let result = format!("{:?}", value);
                    CString::new(result).unwrap().into()
                }
                Err(e) => {
                    let err_msg = format!("ERROR: {:?}", e);
                    CString::new(err_msg).unwrap().into()
                }
            }
        }
        None => {
            CString::new("ERROR: Not connected").unwrap().into()
        }
    }
}

/// 获取库版本信息
#[ffi_export]
pub fn redis_version() -> char_p::Box {
    let version = env!("CARGO_PKG_VERSION");
    debug_print(&format!("rust > redis-ffi version: {}", version));
    CString::new(version).unwrap().into()
}

/// 释放 Rust 分配的字符串
#[ffi_export]
pub fn free_rs_string(string: char_p::Box) {
    let str = string.to_str();
    debug_print(&format!("rust > freeing string: {:?}", str));
    drop(string);
}

#[cfg(test)]
mod tests {
    use super::*;

    /// 获取测试用的 Redis URL
    fn get_test_redis_url() -> String {
        std::env::var("REDIS_URL").unwrap_or_else(|_| "redis://127.0.0.1:6379/0".to_string())
    }

    /// 测试连接管理
    #[test]
    fn test_connection_management() {
        let url = get_test_redis_url();
        let url_cstring = CString::new(url.as_str()).unwrap();
        let url_ref = char_p::Ref::from(url_cstring.as_c_str());

        // 测试初始化
        let result = redis_init(url_ref);
        // 注意：如果没有 Redis 服务器，这个测试会失败
        // 在实际 CI 环境中可能需要跳过
        if !result {
            println!("警告: 无法连接到 Redis 服务器，跳过连接测试");
            return;
        }

        // 测试连接状态
        assert!(redis_is_connected());

        // 测试 PING
        let ping_result = redis_ping();
        let ping_str = ping_result.to_str();
        assert!(ping_str.contains("PONG") || ping_str.contains("pong"));

        // 测试关闭
        redis_close();
        assert!(!redis_is_connected());
    }

    /// 测试版本信息
    #[test]
    fn test_version() {
        let version = redis_version();
        let version_str = version.to_str();
        assert!(!version_str.is_empty());
        // 版本号格式应该是 x.y.z
        assert!(version_str.contains('.'));
    }

    /// 测试字符串操作
    #[test]
    fn test_string_operations() {
        let url = get_test_redis_url();
        let url_cstring = CString::new(url.as_str()).unwrap();
        let url_ref = char_p::Ref::from(url_cstring.as_c_str());

        if !redis_init(url_ref) {
            println!("警告: 无法连接到 Redis 服务器，跳过字符串操作测试");
            return;
        }

        let test_key = CString::new("test:ffi:string").unwrap();
        let test_value = CString::new("test_value").unwrap();
        let updated_value = CString::new("updated_value").unwrap();

        let key_ref = char_p::Ref::from(test_key.as_c_str());
        let value_ref = char_p::Ref::from(test_value.as_c_str());
        let updated_ref = char_p::Ref::from(updated_value.as_c_str());

        // 清理可能存在的旧数据
        redis_del(key_ref);

        // 测试 SET
        assert!(redis_set(key_ref, value_ref));

        // 测试 EXISTS
        assert!(redis_exists(key_ref));

        // 测试 GET
        let get_result = redis_get(key_ref);
        assert_eq!(get_result.to_str(), "test_value");

        // 测试更新值
        assert!(redis_set(key_ref, updated_ref));
        let get_result2 = redis_get(key_ref);
        assert_eq!(get_result2.to_str(), "updated_value");

        // 测试 EXPIRE
        assert!(redis_expire(key_ref, 60));

        // 测试 TTL
        let ttl = redis_ttl(key_ref);
        assert!(ttl > 0 && ttl <= 60);

        // 测试 DEL
        let del_count = redis_del(key_ref);
        assert_eq!(del_count, 1);

        // 确认已删除
        assert!(!redis_exists(key_ref));

        redis_close();
    }

    /// 测试列表操作
    #[test]
    fn test_list_operations() {
        let url = get_test_redis_url();
        let url_cstring = CString::new(url.as_str()).unwrap();
        let url_ref = char_p::Ref::from(url_cstring.as_c_str());

        if !redis_init(url_ref) {
            println!("警告: 无法连接到 Redis 服务器，跳过列表操作测试");
            return;
        }

        let list_key = CString::new("test:ffi:list").unwrap();
        let item1 = CString::new("item1").unwrap();
        let item2 = CString::new("item2").unwrap();
        let item3 = CString::new("item3").unwrap();

        let key_ref = char_p::Ref::from(list_key.as_c_str());
        let item1_ref = char_p::Ref::from(item1.as_c_str());
        let item2_ref = char_p::Ref::from(item2.as_c_str());
        let item3_ref = char_p::Ref::from(item3.as_c_str());

        // 清理旧数据
        redis_del(key_ref);

        // 测试 LPUSH
        let len = redis_lpush(key_ref, item1_ref);
        assert_eq!(len, 1);

        let len = redis_lpush(key_ref, item2_ref);
        assert_eq!(len, 2);

        // 测试 RPUSH
        let len = redis_rpush(key_ref, item3_ref);
        assert_eq!(len, 3);

        // 测试 LLEN
        let list_len = redis_llen(key_ref);
        assert_eq!(list_len, 3);

        // 测试 LPOP (应该从左侧弹出 item2)
        let pop_result = redis_lpop(key_ref);
        assert_eq!(pop_result.to_str(), "item2");

        // 测试 RPOP (应该从右侧弹出 item3)
        let pop_result2 = redis_rpop(key_ref);
        assert_eq!(pop_result2.to_str(), "item3");

        // 清理
        redis_del(key_ref);
        redis_close();
    }

    /// 测试哈希表操作
    #[test]
    fn test_hash_operations() {
        let url = get_test_redis_url();
        let url_cstring = CString::new(url.as_str()).unwrap();
        let url_ref = char_p::Ref::from(url_cstring.as_c_str());

        if !redis_init(url_ref) {
            println!("警告: 无法连接到 Redis 服务器，跳过哈希表操作测试");
            return;
        }

        let hash_key = CString::new("test:ffi:hash").unwrap();
        let field1 = CString::new("field1").unwrap();
        let value1 = CString::new("value1").unwrap();
        let field2 = CString::new("field2").unwrap();
        let value2 = CString::new("value2").unwrap();

        let key_ref = char_p::Ref::from(hash_key.as_c_str());
        let field1_ref = char_p::Ref::from(field1.as_c_str());
        let value1_ref = char_p::Ref::from(value1.as_c_str());
        let field2_ref = char_p::Ref::from(field2.as_c_str());
        let value2_ref = char_p::Ref::from(value2.as_c_str());

        // 清理旧数据
        redis_del(key_ref);

        // 测试 HSET
        assert!(redis_hset(key_ref, field1_ref, value1_ref));
        assert!(redis_hset(key_ref, field2_ref, value2_ref));

        // 测试 HEXISTS
        assert!(redis_hexists(key_ref, field1_ref));

        // 测试 HGET
        let hget_result = redis_hget(key_ref, field1_ref);
        assert_eq!(hget_result.to_str(), "value1");

        // 测试 HGETALL
        let hgetall_result = redis_hgetall(key_ref);
        let hgetall_str = hgetall_result.to_str();
        assert!(hgetall_str.contains("field1"));
        assert!(hgetall_str.contains("value1"));

        // 测试 HDEL
        let hdel_count = redis_hdel(key_ref, field1_ref);
        assert_eq!(hdel_count, 1);

        // 确认已删除
        assert!(!redis_hexists(key_ref, field1_ref));

        // 清理
        redis_del(key_ref);
        redis_close();
    }

    /// 测试集合操作
    #[test]
    fn test_set_operations() {
        let url = get_test_redis_url();
        let url_cstring = CString::new(url.as_str()).unwrap();
        let url_ref = char_p::Ref::from(url_cstring.as_c_str());

        if !redis_init(url_ref) {
            println!("警告: 无法连接到 Redis 服务器，跳过集合操作测试");
            return;
        }

        let set_key = CString::new("test:ffi:set").unwrap();
        let member1 = CString::new("member1").unwrap();
        let member2 = CString::new("member2").unwrap();

        let key_ref = char_p::Ref::from(set_key.as_c_str());
        let member1_ref = char_p::Ref::from(member1.as_c_str());
        let member2_ref = char_p::Ref::from(member2.as_c_str());

        // 清理旧数据
        redis_del(key_ref);

        // 测试 SADD
        let added = redis_sadd(key_ref, member1_ref);
        assert_eq!(added, 1);

        let added = redis_sadd(key_ref, member2_ref);
        assert_eq!(added, 1);

        // 重复添加应该返回 0
        let added = redis_sadd(key_ref, member1_ref);
        assert_eq!(added, 0);

        // 测试 SISMEMBER
        assert!(redis_sismember(key_ref, member1_ref));

        // 测试 SCARD
        let card = redis_scard(key_ref);
        assert_eq!(card, 2);

        // 测试 SREM
        let removed = redis_srem(key_ref, member1_ref);
        assert_eq!(removed, 1);

        // 确认已移除
        assert!(!redis_sismember(key_ref, member1_ref));

        // 清理
        redis_del(key_ref);
        redis_close();
    }

    /// 测试原始命令
    #[test]
    fn test_raw_command() {
        let url = get_test_redis_url();
        let url_cstring = CString::new(url.as_str()).unwrap();
        let url_ref = char_p::Ref::from(url_cstring.as_c_str());

        if !redis_init(url_ref) {
            println!("警告: 无法连接到 Redis 服务器，跳过原始命令测试");
            return;
        }

        let cmd = CString::new("PING").unwrap();
        let args = CString::new("").unwrap();

        let cmd_ref = char_p::Ref::from(cmd.as_c_str());
        let args_ref = char_p::Ref::from(args.as_c_str());

        let result = redis_raw(cmd_ref, args_ref);
        let result_str = result.to_str();
        assert!(result_str.contains("PONG") || result_str.contains("pong") || result_str.contains("BulkString") || result_str.contains("SimpleString"));

        redis_close();
    }

    /// 测试字符串释放
    #[test]
    fn test_free_string() {
        let test_string = char_p::Box::from(CString::new("test").unwrap());
        free_rs_string(test_string);
        // 如果释放成功，不会 panic
    }
}
