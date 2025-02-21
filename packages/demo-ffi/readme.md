# demo ffi

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

- https://github.com/getditto/safer_ffi/tree/master/examples/point