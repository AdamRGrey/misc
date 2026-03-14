#!/bin/bash

token=$(cat .local/bin/jenkinstoken.txt)

curl -X POST --user "$token" -F "jenkinsfile=<./Jenkinsfile" alloces.lan:8080/pipeline-model-converter/validate
