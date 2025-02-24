# uuid-mojo

## Usage

### package hosted

> rust ffi library

- ✅ https://prefix.dev/channels/better-ffi/packages/libuuid_ffi

> mojo package

- ✅ https://prefix.dev/channels/better-mojo/packages/uuid


### add package

- ✅ add channels to `mojoproject.toml`

```ruby

[project]
channels = [
    "conda-forge", 
    "https://conda.modular.com/max", 
    "https://repo.prefix.dev/better-ffi",  
    "https://repo.prefix.dev/better-mojo",
 ]

```

- or, use `magic command` to add channels

```ruby

magic project channel add "https://repo.prefix.dev/better-ffi" 
magic project channel add "https://repo.prefix.dev/better-mojo" 

```


- ✅ add package to `mojoproject.toml`

```ruby
# add rust(ffi) package
magic add libuuid_ffi

# add mojo package
magic add uuid

```


## Example

- ✅ `main.mojo`


```python

import uuid


def test_uuid():
    # implement style 1:
    var id = uuid.uuid_v4()  # auto free memory
    var id2 = uuid.uuid_v7()  # auto free memory

    # implement style 2:
    var id3 = uuid.gen_uuid_v4()
    var id4 = uuid.gen_uuid_v7()  # auto free memory

    print(id)
    print(id2)

    print(id3)
    print(id4)


fn main() raises:
    test_uuid()



```

- ✅ output:

```python
rust > uuid v4: d688553f-bfab-424c-9d16-61646b8ce4d7
rust > freeing string: "d688553f-bfab-424c-9d16-61646b8ce4d7", raw: "d688553f-bfab-424c-9d16-61646b8ce4d7"
rust > uuid v7: 01953637-218e-7d02-abd2-eb215b5e7810
rust > freeing string: "01953637-218e-7d02-abd2-eb215b5e7810", raw: "01953637-218e-7d02-abd2-eb215b5e7810"
rust > uuid v4: b94423df-2c6e-4aa8-a895-7e0ea9f8dac5
rust > uuid v7: 01953637-218e-7d02-abd2-eb366ecef95f

d688553f-bfab-424c-9d16-61646b8ce4d7
01953637-218e-7d02-abd2-eb215b5e7810
b94423df-2c6e-4aa8-a895-7e0ea9f8dac5
01953637-218e-7d02-abd2-eb366ecef95f

```





## Development


```ruby
# install
task um:magic -- i

# run example
task um:run -- src/main.mojo

# release
task um:release:rust
task um:release:mojo

# publish package
task um:publish:rust
task um:publish:mojo

```