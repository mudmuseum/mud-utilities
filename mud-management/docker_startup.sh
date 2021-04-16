#!/usr/bin/env bash

###############################################################################
#                                                                             #
# Purpose:     This script will start the latest image of a repository        #
# Location:    Add this to /usr/local/bin/muds on the mud host VM             #
# Permissions: '0755, root:root' should be adequate permissions               #
# Use:         docker_startup.sh <repository-name>                            #
# Integration: Integrates with the AWS EventBridge Trigger on ECR image push  #
#                                                                             #
###############################################################################

if [[ -z $1 ]]; then
  echo "No argument supplied to startup script. One argument, name of repository, must be supplied."
  exit 1
fi

# Initial Configuration
REPOSITORY_NAME=$1
VOLUME_NAME=$REPOSITORY_NAME

# Builds the ECR image reference from Account, Region, and Tag
ACCOUNT=$(aws sts get-caller-identity | jq -r .Account)
REGION=$(curl -s 169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')

# Get a list of image tags in the repository, sort numerically and return the most recent (highest) tag
TAG=$(aws ecr list-images --repository-name ${REPOSITORY_NAME} | jq -r .imageIds[].imageTag | sort -n | tail -n 1)

# Setup the latest image reference
IMAGE="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${REPOSITORY_NAME}:${TAG}"

# Get the needed repository tags; mud-name, port, mud-directory
MUD_NAME=$(aws ecr list-tags-for-resource \
  --resource-arn arn:aws:ecr:${REGION}:${ACCOUNT}:repository/${REPOSITORY_NAME} | \
    jq -r '.tags[] | select(.Key == "mud-name") | .Value')

HOST_PORT=$(aws ecr list-tags-for-resource \
  --resource-arn arn:aws:ecr:${REGION}:${ACCOUNT}:repository/${REPOSITORY_NAME} | \
    jq -r '.tags[] | select(.Key == "port") | .Value')
CONTAINER_PORT=$HOST_PORT

MUD_DIRECTORY=$(aws ecr list-tags-for-resource \
  --resource-arn arn:aws:ecr:${REGION}:${ACCOUNT}:repository/${REPOSITORY_NAME} | \
    jq -r '.tags[] | select(.Key == "mud-directory") | .Value')

# Login to ECR
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com

# Verify ECR login worked and then prepare to start container
if [[ $? == 0 ]]; then

  # Identifies if container is already running
  RUNNING=$(/usr/bin/docker ps -q -f name=${REPOSITORY_NAME})

  if [[ ! -z $RUNNING ]]; then
    echo "${MUD_NAME} is currently running."
  else
    # Launches Container
    /usr/bin/docker run -d \
      --name ${REPOSITORY_NAME} \
      -p ${HOST_PORT}:${CONTAINER_PORT} \
      -v ${VOLUME_NAME}_player:/${MUD_DIRECTORY}/player \
      --restart always \
      $IMAGE
    if [[ $? != 0 ]]; then
      echo "Issue with starting ${MUD_NAME}."
    else
      echo "Started ${MUD_NAME}."
    fi
  fi

else
  echo "Issue with logging into Docker registry."
fi
