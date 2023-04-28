#!/bin/bash

PASSWORD="admin"
NODES=("172.26.128.215" "172.26.128.179" "172.26.132.88")
MANAGER_NODE=${NODES[0]}

SSH_KEY_PATH="default.key"

init_swarm() {
  echo "Initializing swarm on manager node..."
  ssh -i "$SSH_KEY_PATH" "$MANAGER_NODE" "sudo docker swarm init"
}

join_swarm() {
  join_token=$(ssh -i "$SSH_KEY_PATH" "$MANAGER_NODE" "sudo docker swarm join-token worker -q")
  echo "Join token: $join_token"
  for node in "${NODES[@]:1}"; do
    echo "Joining swarm on $node"
    ssh -i "$SSH_KEY_PATH" "$node" "sudo docker swarm join --token $join_token $MANAGER_NODE:2377"
  done
}

create_couchdb_service() {
  echo "Creating CouchDB service on swarm..."
  ssh -i "$SSH_KEY_PATH" "$MANAGER_NODE" "sudo docker network create --driver overlay --attachable couchdb_network"
  ssh -i "$SSH_KEY_PATH" "$MANAGER_NODE" "sudo docker service create \
    --name couchdb \
    --network couchdb_network \
    --replicas ${#NODES[@]} \
    -p 5984:5984 \
    --env COUCHDB_USER=admin \
    --env COUCHDB_PASSWORD=${PASSWORD} \
    --env NODENAME={{.Node.Hostname}} \
    --env ERL_FLAGS='-setcookie couchdb_cluster -name couchdb@{{.Node.Hostname}}' \
    couchdb:latest"
}

setup_cluster() {
  echo "Setting up CouchDB cluster..."
  MAIN_NODE=${NODES[0]}
  MAIN_NODE_URL="http://admin:${PASSWORD}@${MAIN_NODE}:5984"

  sleep 10

  # Enable cluster mode
  echo "Enabling cluster mode..."
  curl -X POST "${MAIN_NODE_URL}/_cluster_setup" \
    -H "Content-Type: application/json" \
    -d "{
      \"action\": \"enable_cluster\",
      \"bind_address\": \"0.0.0.0\",
      \"username\": \"admin\",
      \"password\": \"${PASSWORD}\",
      \"port\": 5984,
      \"node_count\": \"${#NODES[@]}\"
    }"

  # Add other nodes to the cluster
    for node in "${NODES[@]:1}"; do
    echo "Adding node $node to cluster..."
    curl -X POST "${MAIN_NODE_URL}/_cluster_setup" \
      -H "Content-Type: application/json" \
      -d "{
        \"action\": \"add_node\",
        \"host\": \"${node}\",
        \"port\": 5984,
        \"username\": \"admin\",
        \"password\": \"${PASSWORD}\"
      }"
    done

  # Finish cluster setup
    echo "Finishing cluster setup..."
  curl -X POST "${MAIN_NODE_URL}/_cluster_setup" \
    -H "Content-Type: application/json" \
    -d '{"action": "finish_cluster"}'
}

check_cluster_configuration() {
  echo "Checking cluster configuration..."

  MAIN_NODE=${NODES[0]}
  MAIN_NODE_URL="http://admin:${PASSWORD}@${MAIN_NODE}:5984"

  # Query the _membership endpoint to get information about the nodes in the cluster
  curl -s "${MAIN_NODE_URL}/_membership"
}


main() {
  init_swarm
  join_swarm
  create_couchdb_service
  setup_cluster
  check_cluster_configuration
}

main
