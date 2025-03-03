# disc

- 参考 [go 标准库](https://pkg.go.dev/std) 和 [x 扩展库](https://pkg.go.dev/golang.org/x) 设计的一个 mojo 工具库



## References


### Go Std Library

- https://pkg.go.dev/std
- https://pkg.go.dev/golang.org/x
- https://pkg.go.dev/encoding@go1.24.0#section-directories

> go 标准库结构

```ruby

encoding.go
    encoding/ascii85
    encoding/asn1
    encoding/base32
    encoding/base64
    encoding/binary
    encoding/csv
    encoding/gob
    encoding/hex
    encoding/json
    encoding/pem
    encoding/xml


```

> x 扩展库:

```ruby
    benchmarks — benchmarks to measure Go as it is developed.
    build — build.golang.org's implementation.
    crypto — additional cryptography packages.
    debug — an experimental debugger for Go.
    exp — experimental and deprecated packages (handle with care; may change without warning).
    image — additional imaging packages.
    mobile — experimental support for Go on mobile platforms.
    mod — packages for writing tools that work with Go modules.
    net — additional networking packages.
    oauth2 — a client implementation for the OAuth 2.0 spec
    perf — packages and tools for performance measurement, storage, and analysis.
    pkgsite — home of the pkg.go.dev website.
    review — a tool for working with Gerrit code reviews.
    sync — additional concurrency primitives.
    sys — packages for making system calls.
    term — Go terminal and console support packages.
    text — packages for working with text.
    time — additional time packages.
    tools — godoc, goimports, gorename, and other tools.
    tour — tour.golang.org's implementation.
    vuln — packages for accessing and analyzing data from the Go Vulnerability Database.
    website — home of the go.dev and golang.org websites.
```