#! /bin/bash

cd ./inside
dir=$(pwd)

if [[ $1 == debug ]]
	then
		flag='bash'
		echo 'Debug Mode'
	else
		echo 'Normal Mode'
	fi

docker run -it \
  -p 80:80 \
  -p 443:443 \
  --mount type=bind,source=$dir/configs/,target=/configs/ \
  --mount type=bind,source=$dir/data/,target=/data/ \
  --mount type=bind,source=$dir/scripts/,target=/scripts/ \
  --mount type=bind,source=$dir/logs/,target=/logs/ \
  --mount type=bind,source=$dir/configs/verynginx/,target=/opt/verynginx/verynginx/configs/ \
  --mount type=bind,source=$dir/configs/nginx/nginx.conf,target=/usr/local/nginx/conf/nginx.conf \
  --name nginx \
  nginx:v3 $flag

