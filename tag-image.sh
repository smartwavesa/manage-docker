#!/bin/bash

set -e

usage="Usage:	tag-image  -s -n image-name -t tag\n
-s : to execute docker build with sudo \n
-n image-name  (mandatory) : the image's name \n
-t tag  (mandatory) : the image's tag \n"

sudo=""
tag=""

while getopts 'sn:t:' opt; do
    case $opt in
        a)  image-name="$OPTARG" ;;
		s)  sudo="sudo" ;;
        t)  tag="$OPTARG"    ;;
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

if [ -z $tag ]
	then
	error_exit "\"tag\" is mandatory."
fi

eval "$sudo docker tag $image-name $tag"

exit 0