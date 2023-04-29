#!/bin/bash

NODES=(${NODES//,/ })
PORT=5984
MASTER_NODE=${NODES[0]}
CURRENT_NODE=$(ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
OTHER_NODES=`echo ${NODES[@]} | sed s/${MASTER_NODE}//`
USERNAME="${USERNAME}"
PASSWORD="${PASSWORD}"
COOKIE="a192aeb9904e6590849337933b000c99"
VERSION="3.2.1"

if sudo docker image ls | awk '{print $1":"$2}' | grep -q "couchdb:${VERSION}"; then
  echo "CouchDB3 with version ${VERSION} is already installed."
else
  echo "Pulling CouchDB3 with version ${VERSION}..."
  sudo docker pull couchdb:${VERSION}
fi

if [[ "${CURRENT_NODE}" == "${MASTER_NODE}" ]]; then
  CONTAINER_NAME="couch_master_${CURRENT_NODE}"
else
  for (( i=1; i<${#NODES[@]}; i++ )); do
    if [[ "${NODES[$i]}" == "${CURRENT_NODE}" ]]; then
      CONTAINER_NAME="couch_slave${i}_${CURRENT_NODE}"
      break
    fi
  done
fi

sudo docker create \
  --name "${CONTAINER_NAME}" \
  --network host \
  --env COUCHDB_USER=${USERNAME} \
  --env COUCHDB_PASSWORD=${PASSWORD} \
  --env COUCHDB_SECRET=${COOKIE} \
  --env ERL_FLAGS="-setcookie \"${COOKIE}\" -name \"couchdb@${CURRENT_NODE}\" -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9100" \
  couchdb:${VERSION}

sudo docker start "${CONTAINER_NAME}"

sleep 5

# Check if the current node is the master node
if [ "${CURRENT_NODE}" == "${MASTER_NODE}" ]; then
  echo "Setting up CouchDB cluster on master node ${MASTER_NODE}..."
  sleep 5
  for node in ${OTHER_NODES}; do
    echo "Enable cluster mode on node ${node}..."
    curl -XPOST "http://${USERNAME}:${PASSWORD}@${MASTER_NODE}:${PORT}/_cluster_setup" \
      --header "Content-Type: application/json" \
      --data "{\"action\": \"enable_cluster\", \"bind_address\":\"0.0.0.0\",\
               \"username\": \"${USERNAME}\", \"password\":\"${PASSWORD}\", \"port\": \"${PORT}\",\
               \"remote_node\": \"${node}\", \"node_count\": \"$(echo ${NODES[@]} | wc -w)\",\
               \"remote_current_user\":\"${USERNAME}\", \"remote_current_password\":\"${PASSWORD}\"}"
  done

  echo "Adding nodes to cluster..."
  for node in ${OTHER_NODES}; do
    echo "Adding node ${node} to cluster..."
    curl -XPOST "http://${USERNAME}:${PASSWORD}@${MASTER_NODE}:${_PORT}/_cluster_setup" \
      --header "Content-Type: application/json" \
      --data "{\"action\": \"add_node\", \"host\":\"${node}\",\
               \"port\": \"${PORT}\", \"username\": \"${USERNAME}\", \"password\":\"${PASSWORD}\"}"
  done

  echo "Finishing cluster setup..."
  curl -XPOST "http://${USERNAME}:${PASSWORD}@${MASTER_NODE}:${PORT}/_cluster_setup" \
    --header "Content-Type: application/json" --data "{\"action\": \"finish_cluster\"}"

else
  echo "This node (${CURRENT_NODE}) is not the master node. Skipping cluster setup."
fi

echo "Checking cluster status..."
curl -X GET "http://${USERNAME}:${PASSWORD}@${CURRENT_NODE}:${PORT}/_membership"

