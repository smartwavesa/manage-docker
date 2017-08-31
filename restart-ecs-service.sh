#!/bin/bash

set -e

usage="Usage: restart-ecs-services  -s -a aws_credentials -n image_name -c cluster -v service_name \n
-s : to execute docker build with sudo \n
-t : Stop task instead of scaling down service \n
-a aws_credentials (mandatory) : aws credentials to use awscli \n
-n image_name  (mandatory) : the image's name to tag and push \n
-c cluster (mandatory) : ecs cluster \n
-v service_name (mandatory) : service_name"

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

while getopts 'sta:n:c:v:' opt; do
    case $opt in
        a)  aws_credentials_arg="$OPTARG" ;;
		t)  stop_ecs_task="stop_ecs_task"    ;;
		s)  sudo="sudo" ;;
        n)  image_name="$OPTARG"    ;;
		c) 	cluster="$OPTARG"    ;; 
		v)  service_name="$OPTARG"    ;; 
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

if [ -z $cluster ]
	then
	error_exit "\"cluster\" is mandatory."
fi


if [ -z $service_name ]
	then
	error_exit "\"service name\" is mandatory."
fi

eval "$sudo  wget http://stedolan.github.io/jq/download/linux64/jq"
eval "$sudo  chmod +x ./jq"
eval "$sudo cp jq /usr/bin"
		
eval aws_credentials=\$$aws_credentials_arg

AWS_ACCESS_KEY_ID=${aws_credentials%:*}
AWS_SECRET_ACCESS_KEY=${aws_credentials#*:}


ecs_cmd="$sudo docker run --rm  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION=eu-west-1 anigeo/awscli ecs"

ecs_list_tasks="$ecs_cmd list-tasks --cluster $cluster --service-name $service_name"

taskArns=$(eval "$ecs_list_tasks" | jq -r '.taskArns')
#taskArns=$(eval "$ecs_list_tasks" | cut -d'/' -f 2)

echo "RUNNING TASKS on $service_name ARE : $taskArns"

for task in $taskArns
do
	if [[ $task == *"task"* ]]; then
		echo "task: $task"
	fi
done

if [ ! -z "$stop_ecs_task" ]
then
	for task in $taskArns
	do
		if [[ $task == *"task"* ]]; then
			task_clean=$(eval "$task" | cut -d'/' -f 2)
			echo "task_clean: $task_clean"
			stop_task=`$ecs_cmd  stop-task --cluster $cluster --task $task_clean`
		fi
	done
else
	disable_service=`$ecs_cmd  update-service --cluster $cluster --service $service_name --desired-count 0`
fi

for task in $taskArns
do
	task_status='RUNNING'
	while [ "$task_status" == "RUNNING" ]
	do
		if [[ $task == *"task"* ]]; then
			task_clean=$(eval "$task" | cut -d'/' -f 2)
			echo "task_clean: $task_clean"
			task_status=`$ecs_cmd describe-tasks --cluster $cluster --tasks $task_clean`| jq -r '.tasks[0].lastStatus'
		fi
	done
	echo "$task $task_status"
done

if [ ! -z "$stop_ecs_task" ]
then
	echo "Task(s) will restart automatically."
else
	enable_service=`$ecs_cmd  update-service --cluster $cluster  --service $service_name --desired-count 1`
fi

exit 0