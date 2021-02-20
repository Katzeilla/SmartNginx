FROM debian:buster

VOLUME /logs

VOLUME /configs

VOLUME /data

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
	wget \
	libpcre3 \
	libpcre3-dev \
	zlib1g-dev \
	unzip \
	git \
	python && \
    wget -O -  https://get.acme.sh | sh && \
    mkdir /root/temp && \
    cd /root/temp && \
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
    mv openssl-OpenSSL_1_1_1j/ openssl && \
    \
    cd /root/temp/ && \
    NPS_VERSION=1.13.35.2-stable && \
    wget https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}.zip && \
    unzip v${NPS_VERSION}.zip && \
    nps_dir=$(find . -name "*pagespeed-ngx-${NPS_VERSION}" -type d) && \
    cd *pagespeed* && \
    psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz && \
    [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL) && \
    wget ${psol_url} && \
    tar -xzvf $(basename ${psol_url}) && \
    \
    cd /root/temp && \
    NGINX_VERSION=1.18.0 && \
    wget -c https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar zxf nginx-${NGINX_VERSION}.tar.gz && \
    cd /root/temp/nginx-${NGINX_VERSION}/ && \
    ./configure --with-ld-opt="-Wl,-rpath,/usr/local/lib/" \
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
    make -j4 && \
    make install && \
    rm -r /root/temp && \
    apt purge \
        unzip \
        git \
        build-essential \
        automake \
        autoconf -y && \
    apt autoremove -y && \
    apt clean && \
    mkdir /data/nginx/ && \
    /usr/local/nginx/sbin/nginx -V
ENTRYPOINT ["/scripts/entrypoint.sh"]

EXPOSE 80 443
