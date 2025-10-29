#!/bin/bash

ssh root@murmur register_new_matrix_user -u "$1" -p "$2" --no-admin -c /etc/matrix-synapse/homeserver.yaml http://localhost:8008
