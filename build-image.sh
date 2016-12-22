#!/bin/bash

#bash build-publish.sh sudo "--build-arg GIT_REPO=https://USERNAME:PASSWORD@smartwave.git.beanstalkapp.com/sw_website.git --no-cache=true --pull=true" "648292630089.dkr.ecr.eu-west-1.amazonaws.com/sw_website" . AWS_CREDENTIALS

#bash build-publish.sh sudo   "648292630089.dkr.ecr.eu-west-1.amazonaws.com/sw_artifactory" . AWS_CREDENTIALS

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


eval $docker_build_cmd

[ $? != 0 ] && \
error "Docker image build failed !" && exit 1


exit 0