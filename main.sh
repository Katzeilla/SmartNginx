#! /bin/bash

cd ./inside
dir=$(pwd)
cd ..

run()
{
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
    $flag \
    nginx:v4

if [[ $? == 125 ]];
    then
    echo "Another Nginx already start, stop it......"
    stop_nginx
    ./main.sh $1
fi
}

stop_nginx()
{
    docker stop nginx
    docker rm nginx
}

  if [[ $1 == debug ]]
	then
		flag='--entrypoint /bin/bash'
		echo 'Debug Mode'
        run
    elif [[ $1 == stop ]];
    then
        stop_nginx

    elif [[ $1 == test ]];
    then
        echo Test Mode
        ls $dir/configs/
        ls $dir/data/
        ls $dir/scripts/
        ls $dir/logs/
        ls $dir/configs/verynginx/
        run
    elif [[ $1 == --help ]] || [[ $1 == -h ]] || [[ $1 == help ]]  
    then
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
    else
        run
		echo 'Normal Mode'
	fi
