#!/bin/bash

set -e

usage="Usage:	build-image  -s  -o docker_build_opt  -n docker_build_name -l docker_build_location \n
-s : to execute docker build with sudo \n
-o docker_build_opt : all the docker options except the image name /tag \n
-n docker_build_name  (mandatory) : the image's name /tag \n
-l docker_build_location : the location of the Dockerfile \n"


docker_build_opt=""
docker_build_name=""
docker_build_location="."
sudo=""

while getopts 'so:n:l:' opt; do
    case $opt in
        o)  docker_build_opt="$OPTARG" ;;
        n)  docker_build_name="$OPTARG"    ;;
		l)  docker_build_location="$OPTARG"    ;;
		s)  sudo="sudo" ;;
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


if [ -z $docker_build_name ]
	then
	error_exit "\"docker_build_name\" is mandatory."
fi


docker_build_cmd="$sudo docker build $docker_build_opt -t $docker_build_name $docker_build_location"

echo $docker_build_cmd


eval $docker_build_cmd

[ $? != 0 ] && \
error "Docker image build failed !" && exit 1


exit 0