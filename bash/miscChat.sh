#!/bin/bash

#msg="\"{\\\"content\\\":\\\"$@\\\"}\""
msg="{\"content\":\"$@\"}"
echo $msg

curl -H "Content-Type: application/json" -d "$msg" \
	#WEBHOOK URL