# uuid-mojo

## Usage

- TODO

### add package

- add channels to `mojoproject.toml`

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


- add package to `mojoproject.toml`

```ruby

# add rust(ffi) package
magic add libuuid_ffi


# add mojo package
magic add uuid_mojo

```




## Development


```ruby

# add prefix.dev channels
task um:magic -- project channel add "https://repo.prefix.dev/better-ffi" 

# add requirements
task um:magic -- add libuuid_ffi

# install
task um:magic -- i



```