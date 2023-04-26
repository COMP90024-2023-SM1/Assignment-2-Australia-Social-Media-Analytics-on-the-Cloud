#!/usr/bin/env bash

install_docker() {
  sudo apt-get update
  sudo apt-get install \
      ca-certificates \
      curl \
      gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli docker-compose containerd.io docker-buildx-plugin docker-compose-plugin
}

set_variables() {
  nodes=(172.26.128.215 172.26.128.179 172.26.132.88)
  masternode="${nodes[0]}"
  othernodes=("${nodes[@]:1}")
  size=${#nodes[@]}
  user='admin'
  pass='admin'
  VERSION='3.2.1'
  cookie='a192aeb9904e6590849337933b000c99'
}

export_variables() {
  export COUCHDB_USER=${user}
  export COUCHDB_PASSWORD=${pass}
  export COUCH_MASTER=${nodes[0]}
  export COUCH_SLAVE1=${nodes[1]}
  export COUCH_SLAVE2=${nodes[2]}
}

deploy_containers() {
  sudo docker-compose up -d
}

setup_cluster() {
  for node in "${othernodes[@]}"; do
    curl -XPOST "http://${user}:${pass}@${masternode}:5984/_cluster_setup" \
      --header "Content-Type: application/json"\
      --data "{\"action\": \"enable_cluster\", \"bind_address\":\"0.0.0.0\",\
             \"username\": \"${user}\", \"password\":\"${pass}\", \"port\": \"5984\",\
             \"remote_node\": \"${node}\", \"node_count\": \"${size}\",\
             \"remote_current_user\":\"${user}\", \"remote_current_password\":\"${pass}\"}"

    curl -XPOST "http://${user}:${pass}@${masternode}:5984/_cluster_setup"\
      --header "Content-Type: application/json"\
      --data "{\"action\": \"add_node\", \"host\":\"${node}\",\
             \"port\": \"5984\", \"username\": \"${user}\", \"password\":\"${pass}\"}"
  done

  curl -XPOST "http://${user}:${pass}@${masternode}:5984/_cluster_setup"\
    --header "Content-Type: application/json" --data "{\"action\": \"finish_cluster\"}"
}

check_cluster_config() {
  for node in "${nodes[@]}"; do
    curl -X GET "http://${user}:${pass}@${node}:5984/_membership"
  done
}

add_photon_web_admin() {
  couch="-H Content-Type:application/json -X PUT http://$user:$pass@172.17.0.2:5984"
  curl $couch/photon
  curl https://raw.githubusercontent.com/ermouth/couch-photon/master/photon.json | \
    curl $couch/photon/_design/photon -d @-
  curl $couch/photon/_security -d '{}'
  curl $couch/_node/_local/_config/csp/attachments_enable -d '"false"'
  curl $couch/_node/_local/_config/chttpd_auth/same_site -d '"lax"'
}

add_database_to_all_nodes() {
  curl -XPUT "http://${user}:${pass}@${masternode}:5984/twitter"
  for node in "${nodes[@]}"; do
    curl -X GET "http://${user}:${pass}@${node}:5984/_all_dbs"
  done
}

main() {
  echo "== Install Docker and required components =="
  install_docker

  echo "== Set variables =="
  set_variables

  echo "== Export variables for the docker-compose.yml =="
  export_variables

  echo "== Deploy containers =="
  deploy_containers

  echo "== Set up the CouchDB cluster =="
  setup_cluster

  echo "== Check whether the cluster configuration is correct =="
  check_cluster_config

  echo "== Addition of the Photon web-admin =="
  add_photon_web_admin

  echo "== Adding a database to one node of the cluster makes it to be created on all other nodes as well =="
  add_database_to_all_nodes
}

main
