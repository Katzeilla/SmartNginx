#! /bin/bash

cd ./inside
dir=$(pwd)
cd ..

date="[$(date)]"


stop_nginx()
{
    docker stop smartnginx
    docker rm smartnginx
}

show_usage()
{
        echo "This is a bash script for manage SmartNginx"
        echo "./main [ACTION]"
        echo
        echo "ACTION:"
        echo "test                    ls all mount dir of host"
        echo "stop                    Stop Nginx"
        echo "debug                   Start in to bash"
        echo "--help, -h ,help        Show this message"
        echo
        echo "If no [ACTION], start normally"
}

  if [[ $1 == debug ]]; then
        flag='--entrypoint /bin/bash'
		echo $date 'Debug Mode'

elif [[ $1 == stop ]];then
        echo $date 'Stoping SmartNginx......'
        stop_nginx
        exit

elif [[ $1 == test ]]; then
        echo $date Test Mode
        ls $dir/configs/
        ls $dir/data/
        ls $dir/scripts/
        ls $dir/logs/
        ls $dir/configs/verynginx/
        exit

elif [[ $1 == build ]]; then
        echo $date Start build smartnginx:v5
        docker build . --tag smartnginx:v5
        exit

elif [[ $1 == --help ]] || [[ $1 == -h ]] || [[ $1 == help ]]; then
        show_usage
        exit

else
	    echo $date 'Normal Mode'
fi

if [ ! -f $dir/logs ]; then

  echo $date mkdir for logs......
  mkdir -p $dir/logs

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
  --name smartnginx \
  $flag \
  smartnginx:v5

if [[ $? == 125 ]];
    then
    echo $date "Another Nginx already start, stop it......"
    stop_nginx
    ./main.sh $1
  fi
