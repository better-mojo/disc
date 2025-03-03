# Rust Hyper FFI


## Development


### Requirements


```ruby

[dependencies]
hyper = { version = "1", features = ["full"] }
tokio = { version = "1", features = ["full"] }
http-body-util = "0.1"
hyper-util = { version = "0.1", features = ["full"] }

```

### Run

- [examples/client](./examples/client/)
- [examples/server](./examples/server/)

```bash

# run client
task hf:r -- --bin c01

# run server
task hf:r -- --bin s01

```



## References

- https://github.com/hyperium/hyper
- https://hyper.rs/guides/1/server/hello-world/

### examples

- https://github.com/hyperium/hyper/tree/master/examples
- [http_proxy.rs](https://github.com/hyperium/hyper/blob/master/examples/http_proxy.rs)
- [client_json.rs](https://github.com/hyperium/hyper/blob/master/examples/client_json.rs)