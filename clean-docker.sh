#!/bin/bash

set -e

usage="Usage:	clean-docker -s -n image_name\n
-s : to execute docker build with sudo \n
-n image_name  (optional) : the image's name \n"

sudo=""

while getopts 'sn:' opt; do
    case $opt in
		s)  sudo="sudo" ;;
		n)  image_name="$OPTARG"    ;;
        *)  exit 1            ;;
    esac
done


function help
{
	echo -e $usage
	exit 0
}

function error_exit
{
	echo -e "$1 \n
$usage \n
$2 \n" 1>&2
	exit 1
}

eval "$sudo docker rm $($sudo docker ps -a  -f 'status=exited' -q --no-trunc)" || true
eval "$sudo docker rmi $($sudo docker images --filter 'dangling=true' -q --no-trunc)" || true

if [ ! -z "$image_name" ]
then
	get_img_id_local="$sudo docker images -q $image_name"
	img_id_local=$(eval "$get_img_id_local")
	eval "$sudo docker rmi -f $img_id_local"
else
	echo "image_name parameter is empty"
fi
exit 0