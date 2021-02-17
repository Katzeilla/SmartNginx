FROM debian:buster

VOLUME /logs

VOLUME /configs

VOLUME /data

COPY /inside/configs/nginx/nginx.conf /usr/local/nginx/conf/

RUN apt-get update && \
    apt-get install -y \
        --no-install-recommends \
        --no-install-suggests \
	\
        ca-certificates \
        uuid-dev \
	procps \
	cron \
	golang \
	autoconf \
	libtool \
	automake \
	build-essential \
	curl \
	wget \
	libpcre3 \
	libpcre3-dev \
	zlib1g-dev \
	unzip \
	git \
	python && \
    curl https://get.acme.sh | sh && \
    mkdir ~/temp

RUN cd /root/temp && \
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
    wget -O openssl.tar.gz -c https://github.com/openssl/openssl/archive/OpenSSL_1_1_1j.tar.gz && \
    tar zxf openssl.tar.gz && \
    mv openssl-OpenSSL_1_1_1j/ openssl

RUN cd /root/temp/ && \
    LUAJIT2_VERSION=2.1-20201229 && \
    wget https://github.com/openresty/luajit2/archive/v${LUAJIT2_VERSION}.zip && \
    unzip v${LUAJIT2_VERSION}.zip  && \
    cd luajit2-${LUAJIT2_VERSION} && \
    make && \
    make install && \
    cd .. && \
    \
    wget 'https://github.com/simpl/ngx_devel_kit/archive/v0.3.1.zip' && \
    unzip v0.3.1.zip && \
    \
    wget https://github.com/openresty/lua-nginx-module/archive/v0.10.19.zip && \
    unzip v0.10.19.zip

RUN cd /root/temp/ && \
    NPS_VERSION=1.13.35.2-stable && \
    wget https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}.zip && \
    unzip v${NPS_VERSION}.zip && \
    nps_dir=$(find . -name "*pagespeed-ngx-${NPS_VERSION}" -type d) && \
    cd *pagespeed* && \
    psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz && \
    [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL) && \
    wget ${psol_url} && \
    tar -xzvf $(basename ${psol_url}) && \
    cd .. && \
    \
    wget -c https://nginx.org/download/nginx-1.18.0.tar.gz && \
    tar zxf nginx-1.18.0.tar.gz

RUN cd /root/temp/nginx-1.18.0/ && \
    export LUAJIT_LIB=/usr/local/lib && \
    export LUAJIT_INC=/usr/local/include/luajit-2.1 && \
    ./configure --with-ld-opt="-Wl,-rpath,/usr/local/lib/" \
		# required by OpenResty / VeryNginx
		--add-module=../ngx_devel_kit-0.3.1 \
		--add-module=../lua-nginx-module-0.10.19 \
		# compression
		--add-module=../ngx_brotli \
		# ct support
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
EXPOSE 443
