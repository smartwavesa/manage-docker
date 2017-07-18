#!/bin/bash

set -e

usage="Usage:	clean-docker -s \n
-s : to execute docker build with sudo \n"

sudo=""

while getopts 's' opt; do
    case $opt in
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


eval "$sudo docker rm $($sudo docker ps -a  -f 'status=exited' -q --no-trunc)" || true
eval "$sudo docker rmi $($sudo docker images --filter 'dangling=true' -q --no-trunc)" || true

exit 0