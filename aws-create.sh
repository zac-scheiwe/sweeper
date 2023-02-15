#!/bin/bash
cd "$(dirname "$0")/aws"
source parameter-config.sh
echo "Working...."

# Create configured json files
mkdir configured
cp templates/* configured

# Set GITHUB_USER
echo -n "GitHub username [zac-scheiwe]: "
read GITHUB_USER
if [[ $GITHUB_USER == "" ]]; then
	GITHUB_USER="zac-scheiwe"
fi

sed -i "s/GITHUB_USER/$GITHUB_USER/g" configured/*.json
sed -i "s/ACCOUNT_ID/$ACCOUNT_ID/g" configured/*.json
sed -i "s/NAME/$NAME/g" configured/*.json
sed -i "s/REGION/$AWS_REGION/g" configured/*.json

# Set const parameters to default (not expected to be changed by user)
for (( i=0; i<${#const_parameters[@]}; i++ )) do
	put_parameter ${const_parameters[$i]} ${const_parameter_defaults[$i]}
done

# Set user parameters to default
for (( i=0; i<${#user_parameters[@]}; i++ )) do
	put_parameter ${user_parameters[$i]} ${user_parameter_defaults[$i]}
done

# Ask user to override user parameter values
echo "Set parameter values or leave blank to skip"
for (( i=0; i<${#user_parameters[@]}; i++ )) do
	parameter_input ${user_parameters[$i]} ${user_parameter_defaults[$i]}
done
echo "Parameters set"

# Create Batch execution role with required permissions
aws iam create-role --role-name $NAME \
	--assume-role-policy-document file://configured/role.json
aws iam create-policy --policy-name $NAME \
	--policy-document file://configured/policy.json
aws iam attach-role-policy --policy-arn arn:aws:iam::493784563160:policy/$NAME \
	--role-name $NAME
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy \
	--role-name $NAME

subnets=$(aws ec2 describe-subnets | jq -r '.[] | .[] | .SubnetId')
IFS=$'\n'
subnets=($subnets)

# Add subnet list to environment.json
for s in ${subnets[@]}; do
	jq --arg v $s '.computeResources.subnets |= . + [$v]' configured/environment.json > temp.json
	mv temp.json configured/environment.json
done

# Add group id to environment.json
group_id=$(unwrap $(aws ec2 describe-security-groups | jq '.[] | .[] | select(.GroupName == "default") | .GroupId'))
jq --arg v $group_id '.computeResources.securityGroupIds = [$v]' configured/environment.json > temp.json
mv temp.json configured/environment.json

# Set up Batch job definition
aws batch create-compute-environment --cli-input-json file://configured/environment.json
sleep 1
aws batch update-compute-environment --compute-environment $NAME \
	--state ENABLED
sleep 1
aws batch create-job-queue --cli-input-json file://configured/job-queue.json
aws batch register-job-definition \
    --job-definition-name $NAME \
    --type container \
    --platform-capabilities FARGATE \
    --timeout attemptDurationSeconds=120 \
    --retry-strategy attempts=1 \
    --container-properties file://configured/container-properties.json > temp.json


# Configure schedule-target.json
job_definition_arn=$(unwrap $(jq '.jobDefinitionArn' temp.json))
jq --arg v $job_definition_arn '.JobDefinition = $v' configured/target-input.json > temp.json
mv temp.json configured/target-input.json
input_str=$(jq -c . configured/target-input.json)
jq --arg v $input_str '.Input = $v' configured/schedule-target.json > temp.json
mv temp.json configured/schedule-target.json

# Create EventBridge schedule
aws scheduler create-schedule \
    --flexible-time-window Mode="OFF" \
    --name $NAME \
    --schedule-expression "cron(45 15 ? * MON-FRI *)" \
    --schedule-expression-timezone "America/New_York" \
    --target file://configured/schedule-target.json