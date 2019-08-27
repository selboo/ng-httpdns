# ng-httpdns

 * http dns

## http.conf

```
http {
    ...
    lua_shared_dict HTTPDNS 10m;
    ...

    server {
        listen 53;
        server_name _;

        default_type application/json;

        location / {
            content_by_lua_file conf/httpdns.lua;
        }
    }
}
```

## curl

```
# curl '127.0.0.1:20053/?host=www.aikaiyuan.com'
{
    "error": "",
    "host": "www.aikaiyuan.com",
    "ips": [
        "123.125.23.191",
        "123.125.23.190"
    ],
    "status": 0
}
```

```
 # curl '127.0.0.1:20053/?host=www.aikaiyuan.com&resolve=8.8.8.8'
{
    "error": "",
    "host": "www.aikaiyuan.com",
    "ips": [
        "220.181.136.110",
        "220.181.136.120",
        "183.60.187.58",
        "183.60.187.57"
    ],
    "status": 0
}
```