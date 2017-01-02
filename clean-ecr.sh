ecr_cmd="$sudo docker run --rm  -e AWS_ACCESS_KEY_ID=$1 -e AWS_SECRET_ACCESS_KEY=$2 -e AWS_DEFAULT_REGION=eu-west-1 anigeo/awscli ecr"

image_Ids=$($ecr_cmd list-images --repository-name $3  --query 'imageIds[*]'| tr -d " \t\n\r")


if [ $image_Ids ==  '[]' ]
	then
	echo "No Images UNTAGGED"
else
	echo "Images UNTAGGED $image_Ids"
fi



#eval "$ecr_cmd batch-delete-image --repository-name $image_name --image-ids $image_Ids"

exit 0