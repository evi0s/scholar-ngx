FROM nginx:stable-alpine AS builder

# build deps
RUN apk add --no-cache --virtual .build-deps \
        gcc libc-dev make openssl-dev pcre-dev \
        zlib-dev linux-headers curl git gnupg \
        libxslt-dev gd-dev geoip-dev

# fetch sources
RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
        -O nginx.tar.gz && \
    mkdir -p /usr/src/ && \
    cd /usr/src/ && \
    git clone git://github.com/cuber/ngx_http_google_filter_module && \
    git clone \
        git://github.com/yaoweibin/ngx_http_substitutions_filter_module

# build nginx
RUN tar -zxC /usr/src -f nginx.tar.gz && \
    cd /usr/src/nginx-$NGINX_VERSION && \
    ./configure --with-compat \
        --add-dynamic-module=/usr/src/ngx_http_google_filter_module \
        --add-dynamic-module=/usr/src/ngx_http_substitutions_filter_module && \
    make -j && make install

# end of builder

FROM nginx:stable-alpine

# copy from builder
COPY --from=builder /usr/local/nginx/modules/ngx_http_subs_filter_module.so /etc/nginx/modules/ngx_http_subs_filter_module.so
COPY --from=builder /usr/local/nginx/modules/ngx_http_google_filter_module.so /etc/nginx/modules/ngx_http_google_filter_module.so

# Fix conf
RUN sed -i '/worker_processes/a\load_module modules/ngx_http_google_filter_module.so;' /etc/nginx/nginx.conf && \
    sed -i '/worker_processes/a\load_module modules/ngx_http_subs_filter_module.so;' /etc/nginx/nginx.conf

COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]

