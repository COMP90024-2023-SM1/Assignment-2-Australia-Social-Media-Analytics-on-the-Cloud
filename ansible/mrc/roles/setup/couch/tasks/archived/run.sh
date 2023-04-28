#!/usr/bin/env bash

# Load environment variables from the .env file
export $(grep -v '^#' .env | xargs)

sudo docker-compose up -d

sleep 5

echo "== Verify CouchDB instance =="

echo ${USER}
echo ${PASS}
curl -X GET http://${USER}:${PASS}@${NODE}:${PORT}/_membership