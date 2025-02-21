# uuid-rs ffi

## build

- run `main.c`

```make

# generate c headers
task demo-ffi:gen  

  
# build rust binary lib, and generate c headers 
task demo-ffi:build

# run main.c
task demo-ffi:r   
  
 
```

## reference

- https://getditto.github.io/safer_ffi/usage/lib-rs.html
- https://github.com/getditto/safer_ffi/tree/master/examples/point