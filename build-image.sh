#!/bin/bash

set -e

usage="Usage:	build-image  -s  -o build-opt  -n image-name -l dockerfile-location \n
-s : to execute docker build with sudo \n
-o build-opt : all the docker options except the image name /tag \n
-n image-name  (mandatory) : the image's name \n
-l dockerfile-location : the location of the Dockerfile \n"


build-opt=""
image-name=""
dockerfile-location="."
sudo=""

while getopts 'so:n:l:' opt; do
    case $opt in
        o)  build-opt="$OPTARG" ;;
        n)  image-name="$OPTARG"    ;;
		l)  dockerfile-location="$OPTARG"    ;;
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


if [ -z $image-name ]
	then
	error_exit "\"image-name\" is mandatory."
fi


build-cmd="$sudo docker build $build-opt -t $image-name $dockerfile-location"

echo $build-cmd


eval $build-cmd

[ $? != 0 ] && \
error "Docker image build failed !" && exit 1


exit 0