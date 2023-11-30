#!/bin/bash

INSTANCE_NAME="Hard_Work"
KEY_NAME="Turtle"

INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$INSTANCE_NAME" "Name=key-name,Values=$KEY_NAME" \
  --query 'Reservations | sort_by(@, &Instances[0].LaunchTime) | [-1].Instances[0].InstanceId' \
  --output text)

INSTANCE_STATUS=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$INSTANCE_NAME" "Name=key-name,Values=$KEY_NAME" \
    --query "Reservations | sort_by(@, &Instances[0].LaunchTime) | [-1].Instances[0].State.Name" \
    --output text)

if [ "$INSTANCE_ID" != "None" ] && [ "$INSTANCE_STATUS" == "running" ]; then
	aws ec2 terminate-instances --instance-ids $INSTANCE_ID > /dev/null 2>&1
	echo "EC2 terminate edilyor."
else
	echo "Kriterlere uygun bir EC2 yok."
fi
