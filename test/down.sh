#!/bin/bash

set -e

cd ~/environment/ecsdemo-crystal
mu pipeline term

cd ~/environment/ecsdemo-nodejs
mu pipeline term

echo "================================"
echo "Beginning frontend pipeline term at $(date)"
cd ~/environment/ecsdemo-frontend
mu pipeline term

echo "================================"
echo "Beginning acceptance platform term at $(date)"
cd ~/environment/ecsdemo-platform
mu env term acceptance
echo "================================"
echo "Beginning production platform term at $(date)"
mu env term production

echo "================================"
echo "Beginning ecr repo delete at $(date)"
aws ecr delete-repository --repository-nam ${MU_NAMESPACE}-ecsdemo-frontend --force || true
aws ecr delete-repository --repository-nam ${MU_NAMESPACE}-ecsdemo-nodejs --force || true
aws ecr delete-repository --repository-nam ${MU_NAMESPACE}-ecsdemo-crystal --force ||true

echo "================================"
echo "Beginning s3 bucket delete at $(date)"
export REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/\(.*\)[a-z]/\1/'
)
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws s3 rm --recursive s3://${MU_NAMESPACE}-codedeploy-${REGION}-${ACCOUNT_ID}
aws s3 rm --recursive s3://${MU_NAMESPACE}-codepipeline-${REGION}-${ACCOUNT_ID}

echo "================================"
echo "Beginning cf stack delete at $(date)"
aws cloudformation delete-stack --stack-name ${MU_NAMESPACE}-iam-service-ecsdemo-frontend-acceptance
aws cloudformation delete-stack --stack-name ${MU_NAMESPACE}-iam-service-ecsdemo-frontend-production
aws cloudformation delete-stack --stack-name ${MU_NAMESPACE}-iam-service-ecsdemo-nodejs-acceptance
aws cloudformation delete-stack --stack-name ${MU_NAMESPACE}-iam-service-ecsdemo-nodejs-production
aws cloudformation delete-stack --stack-name ${MU_NAMESPACE}-iam-service-ecsdemo-crystal-acceptance
aws cloudformation delete-stack --stack-name ${MU_NAMESPACE}-iam-service-ecsdemo-crystal-production

aws cloudformation delete-stack --stack-name ${MU_NAMESPACE}-repo-ecsdemo-frontend
aws cloudformation delete-stack --stack-name ${MU_NAMESPACE}-repo-ecsdemo-nodejs
aws cloudformation delete-stack --stack-name ${MU_NAMESPACE}-repo-ecsdemo-crystal

aws cloudformation delete-stack --stack-name ${MU_NAMESPACE}-bucket-codedeploy
aws cloudformation delete-stack --stack-name ${MU_NAMESPACE}-bucket-codepipeline

echo "================================"
echo "Beginning sleep 300 at $(date)"
sleep 300 # delay waiting for all the other CF stacks to be deleted -- replace with a count of stacks or something

echo "================================"
echo "Beginning iam-common stack delete at $(date)"
aws cloudformation delete-stack --stack-name ${MU_NAMESPACE}-iam-common
echo "================================"
echo "Teardown complete at $(date)"
