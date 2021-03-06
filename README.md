## SmartNginx

[![Docker Image CI](https://github.com/Katzeilla/SmartNginx/actions/workflows/docker-image.yml/badge.svg)](https://github.com/Katzeilla/SmartNginx/actions/workflows/docker-image.yml)
[![ShellCheck](https://github.com/Katzeilla/SmartNginx/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/Katzeilla/SmartNginx/actions/workflows/shellcheck.yml)

> 基础功能已经可用，但没有任何错误处理机制，不建议使用, 除非你真的知道自己在做什么。

SmartNginx 基于 Nginx 最新稳定版本 1.18.0 构建，集成了多种工具和优化方案，可以作为 Docker 容器使用。

### 功能：

* 自动通过 [acme.sh](https://github.com/Neilpang/acme.sh) 获取/安装/续期 Let\`s Encrypt 的证书 
* 自动通过 [nginx-ct](https://github.com/grahamedgecombe/nginx-ct) 获取/安装/续期证书透明度文件
* 整合 [Google PageSpeed](https://developers.google.com/speed/) （来自 Google 的 Web 性能优化工具）

* 持续开发中，TO DO 请参阅 [Project 页面](https://github.com/Katzeilla/SmartNginx/projects/1)

### 准备工作

1. 服务器配置为 80 / 443 端口开放

2. 将希望使用的域名解析至服务器

3. [安装 Docker](https://docs.docker.com/engine/installation/#server)

### 安装及使用

1. Clone 这个仓库到你的服务器

```bash
git clone https://github.com/katzeilla/smartnginx/

cd smartnginx/

```

2. 添加希望使用的域名

```bash

echo www.example.org > ./inside/configs/smartnginx/domain_list
echo blog.example.org >> ./inside/configs/smartnginx/domain_list

```

3. 构建镜像

```bash

./main.sh build

```
4. 启动

```bash

./main.sh

```

