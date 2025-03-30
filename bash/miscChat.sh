#!/bin/bash

msgString=$@

curl -XPOST \
    -d "$(jq -cn  --arg msgtype 'm.text' --arg body "$msgString" '{msg: $ARGS.named}' | jq -s add | jq .msg)" \
	#WEBHOOK URL
