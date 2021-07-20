# Scholar-NGX

Reverse proxy for google & scholar by Nginx

## Usage

```shell
docker build -t scholar-ngx .
docker run -it -d \
    --name=scholar \
    -p 80:80 \
    scholar-ngx

```

You may also modify the `default.conf`

```shell
docker run -it -d \
    --name=scholar \
    -p 443:443 \
    -v $PWD/default.conf:/etc/nginx/conf.d/default.conf \
    scholar-ngx
```

## Credit

* Nginx: https://nginx.org/
* Nginx Module for Google: https://github.com/cuber/ngx_http_google_filter_module

