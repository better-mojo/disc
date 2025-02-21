# uuid-rs ffi

## build

- run `main.c`

```make

# generate c headers
task uuid-ffi:gen  

  
# build rust binary lib, and generate c headers 
task uuid-ffi:build

# run main.c
task uuid-ffi:r   
  
 
```

## reference

- https://getditto.github.io/safer_ffi/usage/lib-rs.html
- https://github.com/getditto/safer_ffi/tree/master/examples/point