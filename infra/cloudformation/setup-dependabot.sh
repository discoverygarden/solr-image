#!/usr/bin/env bash

# Creates an IAM user and allows dependabot to use it to update ecr packages in
# the provided repo.  
### Usage ####
# ./setup-dependabot <REPO> 
# ex: ./setup-dependabot discoverygarden/docker-dgi-proto
repository=${1:?Missing repository positional argument}

echo "Checking if repository exists"
gh repo view "$repository" > /dev/null || {
    echo Could not find github repository.
    exit 1
}

echo "Creating AWS user"
script_dir=$(dirname $(realpath $0))
stack_name="dependabot-${repository//\//-}" 

aws cloudformation deploy \
    --stack-name "$stack_name" \
    --template-file "$script_dir/dependabot.template.yml" \
    --capabilities CAPABILITY_IAM

iam_user=$( \
    aws cloudformation describe-stack-resources --stack-name "$stack_name" | \
    jq -r '.StackResources[] | select( .LogicalResourceId == "Dependabot").PhysicalResourceId'
)

echo $iam_user

secret-set(){
    secrets=$(gh secret list --app dependabot --repo $repository)
    grep "^ECR_AWS_ACCESS_KEY_ID" <<< "$secrets" > /dev/null || return 1
    grep "^ECR_AWS_SECRET_ACCESS_KEY" <<< "$secrets" > /dev/null || return 1
}

echo "Checking if the secrests are set"
secret-set || {
    echo "Secrets not set, setting secrets."
    access_key=$(aws iam create-access-key --user-name "$iam_user")
    access_key_id=$(jq -r '.AccessKey.AccessKeyId' <<< "$access_key")
    access_key_secret=$(jq -r '.AccessKey.SecretAccessKey' <<< "$access_key")

    gh secret set --app dependabot --repo "$repository" ECR_AWS_ACCESS_KEY_ID <<< "$access_key_id"
    gh secret set --app dependabot --repo "$repository" ECR_AWS_SECRET_ACCESS_KEY <<< "$access_key_secret"
}