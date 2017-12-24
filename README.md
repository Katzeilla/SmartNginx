## SmartNginx

> 基础功能已经可用，但没有任何错误处理机制，不建议使用, 除非你真的知道自己在做什么。

SmartNginx 是一个整合了多种常用工具的 Nginx，可以作为 Docker 容器使用。

### 功能：

* 自动通过 [acme.sh](https://github.com/Neilpang/acme.sh) 获取/安装/续期 Let\`s Encrypt 的证书 
* 自动通过 [nginx-ct](https://github.com/grahamedgecombe/nginx-ct) 获取/安装/续期证书透明度文件
* 整合 [VeryNginx](https://github.com/alexazhou/VeryNginx) (一个基于 OpenResty 的强大应用程序防火墙（WAF）)
* 自动配置 HSTS/HPKP 以加强安全性

* 持续开发中，TO DO 请参阅 [Project 页面](https://github.com/Katzeilla/SmartNginx/projects/1)

### 准备工作

1. 服务器配置为 80 / 443 端口开放

2. 将希望使用的域名解析至服务器

3. 安装 Docker

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
3. 启动

```bash

./main.sh

```
