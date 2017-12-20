## SmartNginx

> 尚未开发完毕，请不要使用。

SmartNginx 是一个整合了多种常用工具的 Docker 镜像。

功能：

* 自动通过 [acme.sh](https://github.com/Neilpang/acme.sh) 获取/安装/续期 Let\`s Encrypt 的证书 
* 自动通过 [nginx-ct](https://github.com/grahamedgecombe/nginx-ct) 获取/安装/续期证书透明度文件
* 整合 [VeryNginx](https://github.com/alexazhou/VeryNginx) (一个基于 OpenResty 的强大应用程序防火墙（WAF）)
* 自动配置 HSTS/HPKP 以加强安全性
* 持续开发中...
