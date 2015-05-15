#!/bin/bash

docker build --no-cache -t slack-notify-resource .
docker tag -f slack-notify-resource 192.168.59.103:5000/slack-notify-resource
docker push 192.168.59.103:5000/slack-notify-resource

