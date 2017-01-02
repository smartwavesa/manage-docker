#!/bin/bash

set -e

usage="Usage:	clean-ecr  -s -a aws_credentials -n image_name -e ecr_url\n
-s : to execute docker build with sudo \n
-a aws_credentials (mandatory) : aws credentials to use awscli \n
-n image_name  (mandatory) : the image's name \n
-e ecr_url (mandatory) : url ecr \n"


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

while getopts 'sa:n:e:' opt; do
    case $opt in
        a)  aws_credentials_arg="$OPTARG" ;;
		s)  sudo="sudo" ;;
        n)  image_name="$OPTARG"    ;;
		e) 	ecr_url="$OPTARG"    ;;
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


eval aws_credentials=\$$aws_credentials_arg

AWS_ACCESS_KEY_ID=${aws_credentials%:*}
AWS_SECRET_ACCESS_KEY=${aws_credentials#*:}


ecr_cmd="$sudo docker run --rm  -e AWS_ACCESS_KEY_ID=$1 -e AWS_SECRET_ACCESS_KEY=$2 -e AWS_DEFAULT_REGION=eu-west-1 anigeo/awscli ecr"

get_image_ids="$ecr_cmd list-images --repository-name $image_name --filter tagStatus=UNTAGGED --query 'imageIds[*]'"

image_Ids=`$get_image_ids`| tr -d " \t\n\r"

if [ $image_Ids ==  '[]' ]
	then
	echo "No Images UNTAGGED"
else
	echo "Images UNTAGGED $image_Ids"
fi


exit 0