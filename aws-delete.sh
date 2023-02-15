#!/bin/bash
cd "$(dirname "$0")/aws"
source config.sh
echo "Working...."

# Delete const parameters
for param in "${const_parameters[@]}"; do
	aws ssm delete-parameter --name $param
done

# Delete user parameters
for param in "${user_parameters[@]}"; do
	aws ssm delete-parameter --name $param
done

# Delete Batch job definition
aws batch deregister-job-definition --job-definition $NAME
aws batch update-job-queue --job-queue $NAME \
	--state DISABLED
sleep 1
aws batch delete-job-queue --job-queue $NAME
aws batch update-compute-environment --compute-environment $NAME \
	--state DISABLED
sleep 1
aws batch delete-compute-environment --compute-environment $NAME
rm -r configured

# Delete Batch execution role
aws iam detach-role-policy --role-name $NAME \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
aws iam detach-role-policy --role-name $NAME \
    --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/$NAME
sleep 1
aws iam delete-policy \
    --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/$NAME
aws iam delete-role --role-name $NAME

# Delete EventBridge schedule
aws scheduler delete-schedule --name $NAME