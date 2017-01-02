#!/bin/bash

set -e

usage="Usage:	push-image-ecr  -s -a aws_credentials -n image_name -e ecr_url\n
-s : to execute docker build with sudo \n
-a aws_credentials (mandatory) : to execute docker build with sudo \n
-n image_name  (mandatory) : the image's image_name \n
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

base_tag="$ecr_url/$image_name"
latest_tag="$base_tag:latest"
date_tag="$base_tag:` date +%d%m%Y%H%M`"

eval "$sudo docker tag $image_name:latest $latest_tag"

eval "$sudo docker tag $image_name:latest $date_tag"
		
eval aws_credentials=\$$aws_credentials_arg

AWS_ACCESS_KEY_ID=${aws_credentials%:*}
AWS_SECRET_ACCESS_KEY=${aws_credentials#*:}

ecr_cmd="$sudo docker run --rm  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION=eu-west-1 anigeo/awscli ecr"

ecr_get_login="$ecr_cmd get-login"

$sudo `$ecr_get_login`

eval "$sudo docker push $latest_tag"

eval "$sudo docker push $date_tag"

image_Ids=$($ecr_cmd list-images --repository-name $image_name --filter tagStatus=UNTAGGED --query 'imageIds[*]'| tr -d " \t\n\r")

if [ $image_Ids ==  '[]' ]
	then
	echo "No Images UNTAGGED to delete"
else
	echo "Images UNTAGGED to delete : $image_Ids"
	eval "$ecr_cmd batch-delete-image --repository-name $image_name --image-ids $image_Ids"
fi

exit 0