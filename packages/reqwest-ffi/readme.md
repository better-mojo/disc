# Rust Reqwest + FFI


## Development

### Requirements

```toml

[dependencies]
reqwest = { version = "0.12", features = ["json"] }
tokio = { version = "1", features = ["full"] }

```


### Run

- [examples](./examples/)


```bash

cd git-repo-root-dir

# run
task rf:r -- --bin t01b
task reqf:r -- --bin t01b

```


## References

- https://github.com/seanmonstar/reqwest
- https://docs.rs/reqwest/latest/reqwest/


> usage:

- [Http客户端reqwest模块实战](https://juejin.cn/post/7226177081197068346)
    - 阻塞式请求 