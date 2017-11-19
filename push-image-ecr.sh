#!/bin/bash

set -e

usage="Usage:	push-image-ecr  -s -a aws_credentials -n image_name -e ecr_url -t custom_tag\n
-s : to execute docker build with sudo \n
-a aws_credentials (mandatory) : aws credentials to use awscli \n
-n image_name  (mandatory) : the image's name to tag and push \n
-e ecr_url (mandatory) : url ecr \n
-t custom_tag (optional) : user tag to add on ECR \n
-d : no date tag will be added"

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

sudo=""
image_name=""

while getopts 'sda:n:e:t:' opt; do
    case $opt in
        a)  aws_credentials_arg="$OPTARG" ;;
		s)  sudo="sudo" ;;
        n)  image_name="$OPTARG"    ;;
		e) 	ecr_url="$OPTARG"    ;; 
		t)  custom_tag="$OPTARG"    ;; 
		d)  nodate="nodate"   ;;
        *)  exit 1            ;;
    esac
done


if [ -z $image_name ]
	then
	error_exit "\"image_name\" is mandatory."
fi

if [ -z $aws_credentials_arg ]
	then
	error_exit "\"aws_credentials\" is mandatory."
fi

if [ -z $ecr_url ]
	then
	error_exit "\"ecr_url\" is mandatory."
fi

base_tag="$ecr_url/$image_name"
latest_tag="$base_tag:latest"
date_tag="$base_tag:` date +%d%m%Y%H%M`"

eval "$sudo docker tag $image_name:latest $latest_tag"

if [ -z "$nodate" ]
then
	eval "$sudo docker tag $image_name:latest $date_tag"
fi

if [ ! -z "$custom_tag" ]
then
	custom_tag="$base_tag:$custom_tag" 
	eval "$sudo docker tag $image_name:latest $custom_tag"
fi
		
eval aws_credentials=\$$aws_credentials_arg

AWS_ACCESS_KEY_ID=${aws_credentials%:*}
AWS_SECRET_ACCESS_KEY=${aws_credentials#*:}

ecr_cmd="$sudo docker run --rm  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION=eu-west-1 anigeo/awscli ecr"

ecr_get_login="$ecr_cmd get-login"

docker_getlogin=$($ecr_get_login)

echo "$docker_getlogin"

exp='-e none'
blank=''

docker_getlogin="${docker_getlogin/$exp/$blank}"

echo "$docker_getlogin"

eval "$sudo $docker_getlogin"

eval "$sudo docker push $latest_tag"

if [ -z "$nodate" ]
then
	eval "$sudo docker push $date_tag"
fi

if [ ! -z "$custom_tag" ]
then
	eval "$sudo docker push $custom_tag"
fi

exit 0
