#! /bin/bash

docker run -it -p 80:80 -p 443:443 \
  --mount type=bind,source=/home/katzeilla/Work/docker/inside/configs/,target=/configs/ \
  --mount type=bind,source=/home/katzeilla/Work/docker/inside/data/,target=/data/ \
  --mount type=bind,source=/home/katzeilla/Work/docker/inside/logs/,target=/logs/ \
  --mount type=bind,source=/home/katzeilla/Work/docker/inside/configs/verynginx/,target=/opt/verynginx/verynginx/configs/ \
  --mount type=bind,source=/home/katzeilla/Work/docker/inside/configs/nginx/nginx.conf,target=/usr/local/nginx/conf/nginx.conf \
  nginx:v1 bash 
