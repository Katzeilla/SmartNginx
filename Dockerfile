FROM debian:stretch

VOLUME /logs

VOLUME /configs

VOLUME /data

COPY /inside/configs/nginx/nginx.conf /usr/local/nginx/conf/

RUN pkg_depend='uuid-dev procps cron golang autoconf libtool automake build-essential curl wget libpcre3 libpcre3-dev zlib1g-dev unzip git python ' && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y $pkg_depend && \
    curl https://get.acme.sh | sh && \
    mkdir ~/temp && \
    cd ~/temp && \
    \    
    wget -O nginx-ct.zip -c https://github.com/grahamedgecombe/nginx-ct/archive/v1.3.2.zip && \
    unzip nginx-ct.zip && \
    \
    git clone https://github.com/bagder/libbrotli && \
    cd libbrotli && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd  ../ && \
    \
    wget -O ct-submit.zip -c https://github.com/grahamedgecombe/ct-submit/archive/v1.1.2.zip && \
    unzip ct-submit.zip && \
    cd ct-submit-1.1.2 && \
    go build && \
    mv ./ct-submit-1.1.2 /bin/ct-submit && \
    cd ../ && \
    \
    git clone https://github.com/google/ngx_brotli.git && \
    cd ngx_brotli && \
    git submodule update --init && \
    cd ../ && \
    \
    git clone https://github.com/cloudflare/sslconfig.git &&  \
    wget -O openssl.tar.gz -c https://github.com/openssl/openssl/archive/OpenSSL_1_0_2k.tar.gz && \
    tar zxf openssl.tar.gz && \
    mv openssl-OpenSSL_1_0_2k/ openssl && \
    cd openssl && \
    patch -p1 < ../sslconfig/patches/openssl__chacha20_poly1305_draft_and_rfc_ossl102j.patch && \ 
    cd ../ && \
    \
    wget https://luajit.org/download/LuaJIT-2.0.5.zip && \
    unzip LuaJIT-2.0.5.zip  && \
    cd LuaJIT-2.0.5 && \
    make && \
    make install && \
    export LUAJIT_LIB=/usr/local/lib && \
    export LUAJIT_INC=/usr/local/include/luajit-2.0/ && \
    cd ../ && \
    \
    wget 'https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.zip' && \
    unzip v0.3.0.zip && \
    \
    wget https://github.com/openresty/lua-nginx-module/archive/v0.10.7.zip && \
    unzip v0.10.7.zip && \
    cd lua-nginx-module-0.10.7/ && \
    \
    curl 'https://raw.githubusercontent.com/macports/macports-ports/master/www/nginx/files/patch-src-ngx_http_lua_headers.c.diff' > patch-src-ngx_http_lua_headers.c.diff && \
    patch -p1 < patch-src-ngx_http_lua_headers.c.diff && \
    cd .. && \
    \
    NPS_VERSION=1.13.35.2-stable && \
    wget https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}.zip && \
    unzip v${NPS_VERSION}.zip && \
    nps_dir=$(find . -name "*pagespeed-ngx-${NPS_VERSION}" -type d) && \
    cd *pagespeed* && \
    psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz && \
    [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL) && \
    wget ${psol_url} && \
    tar -xzvf $(basename ${psol_url})  # extracts to psol/ && \
    cd .. && \
    \
    wget -c https://nginx.org/download/nginx-1.11.13.tar.gz && \
    tar zxf nginx-1.11.13.tar.gz && \
    cd nginx-1.11.13/ && \
    patch -p1 < ../sslconfig/patches/nginx__1.11.5_dynamic_tls_records.patch && \
    ./configure --with-ld-opt="-Wl,-rpath,/usr/local/lib/" \
		--add-module=../ngx_devel_kit-0.3.0 \
		--add-module=../lua-nginx-module-0.10.7 \
		--add-module=../ngx_brotli \
		--add-module=../nginx-ct-1.3.2 \
		--add-module=../*pagespeed* \
		--with-openssl=../openssl \
		--with-http_v2_module \
		--with-http_ssl_module \
		--with-http_stub_status_module \
		--with-http_gzip_static_module && \
    make && \
    make install &&\
    \ 
    cd ~/temp && \
    git clone https://github.com/alexazhou/VeryNginx && \
    cd VeryNginx/ && \
    python install.py install verynginx && \
    cd ~/ && \
    \
    rm -rf ~/temp  && \
    mkdir /data/nginx/ && \
    /usr/local/nginx/sbin/nginx -V

ENTRYPOINT ["/scripts/entrypoint.sh"]

EXPOSE 80

