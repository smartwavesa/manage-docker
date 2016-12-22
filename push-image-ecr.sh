#!/bin/bash

set -e

usage="Usage:	push-image-ecr  -a  aws_credentials \n
-c aws_credentials : to execute docker build with sudo \n"


while getopts 'a:' opt; do
    case $opt in
        a)  aws_credentials_arg="$OPTARG" ;;
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


eval aws_credentials=\$$aws_credentials_arg

AWS_ACCESS_KEY_ID=${aws_credentials%:*}
AWS_SECRET_ACCESS_KEY=${aws_credentials#*:}

ecr_get_login="$1 docker run --rm  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION=eu-west-1 anigeo/awscli ecr get-login"

$1 `$ecr_get_login`

eval "$1 docker push $4"


exit 0