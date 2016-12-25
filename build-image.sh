#!/bin/bash

set -e

usage="Usage:	build-image  -s  -o build_opt  -n image_name -l dockerfile_location \n
-s : to execute docker build with sudo \n
-o build_opt : all the docker options except the image name /tag \n
-n image_name  (mandatory) : the image's name \n
-l dockerfile_location : the location of the Dockerfile \n"

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

build_opt=""
image_name=""
dockerfile_location="."
sudo=""

while getopts 'so:n:l:' opt; do
    case $opt in
        o)  build_opt="$OPTARG" ;;
        n)  image_name="$OPTARG"    ;;
		l)  dockerfile_location="$OPTARG"    ;;
		s)  sudo="sudo" ;;
        *)  exit 1            ;;
    esac
done

if [ -z $image_name ]
	then
	error_exit "\"image_name\" is mandatory."
fi


build_cmd="$sudo docker build $build_opt -t $image_name $dockerfile_location"

eval $build_cmd

[ $? != 0 ] && \
error "Docker image build failed !" && exit 1


exit 0