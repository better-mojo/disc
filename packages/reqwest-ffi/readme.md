# Rust Reqwest + FFI


## Development

### Requirements

```toml

[dependencies]
reqwest = { version = "0.12", features = ["json"] }
tokio = { version = "1", features = ["full"] }

```


### Run

#### Run C Example

- run [main.c](./main.c)


```ruby

task reqf:rc

```

- main.c response

```ruby

rs > send request: Response { url: "https://www.rust-lang.org/", status: 200, headers: {"content-type": "text/html; charset=utf-8", "content-length": "19898", "connection": "keep-alive", "report-to": "{\"group\":\"heroku-nel\",\"max_age\":3600,\"endpoints\":[{\"url\":\"https://nel.heroku.com/reports?ts=1741001896&sid=67ff5de4-ad2b-4112-9289-cf96be89efed&s=eD3WSDJBU5eZuilI1%2BsAGbcrYwlzj4uQ5%2F5PtRplAws%3D\"}]}", "reporting-endpoints": "heroku-nel=https://nel.heroku.com/reports?ts=1741001896&sid=67ff5de4-ad2b-4112-9289-cf96be89efed&s=eD3WSDJBU5eZuilI1%2BsAGbcrYwlzj4uQ5%2F5PtRplAws%3D", "nel": "{\"report_to\":\"heroku-nel\",\"max_age\":3600,\"success_fraction\":0.005,\"failure_fraction\":0.05,\"response_headers\":[\"Via\"]}", "via": "1.1 vegur, 1.1 d96c44188c84dbd785e3172d07c41070.cloudfront.net (CloudFront)", "server": "Rocket", "x-frame-options": "SAMEORIGIN", "x-content-type-options": "nosniff", "permissions-policy": "interest-cohort=()", "x-xss-protection": "1; mode=block", "strict-transport-security": "max-age=63072000", "referrer-policy": "no-referrer, strict-origin-when-cross-origin", "content-security-policy": "default-src 'self'; frame-ancestors 'self'; img-src 'self' avatars.githubusercontent.com; frame-src 'self' player.vimeo.com", "date": "Mon, 03 Mar 2025 11:38:15 GMT", "x-cache": "Miss from cloudfront", "x-amz-cf-pop": "TPE53-P1", "x-amz-cf-id": "d7KNmvz5It3PrzC6nW1e92oJkdZB_n9ZUcIi6K5zHYwZKA8tEk9_cw=="} }
rs > free http response

```


#### Run Rust Example

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


> ffi + cpp:

- https://github.com/markrenChina/reqwest_cpp
- [reqwest + proxy](https://github.com/markrenChina/reqwest_cpp/blob/master/client/src/proxy.rs#L10)
- https://github.com/markrenChina/reqwest_cpp/blob/master/client/src/response.rs
