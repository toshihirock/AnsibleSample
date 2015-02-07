#!/bin/bash
 
set -e
 
DOCKER_NAME="docker/ansible"
DEFAULT_IP="DOCKER_IP"
SCRIPT_NAME="ansible.sh"
 
get_ip() {
  IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' test01`
  echo "${IP}"
}
 
is_running_docker() {
  if docker ps -a |grep ${DOCKER_NAME} >/dev/null 2>&1 ; then
    return 0
  else
    return 1
  fi
}
 
case "$1" in
  prepare)
    if is_running_docker ; then
      echo "Docker container for ansible was already running."
      exit 0
    fi
    CID=`docker run -d --name test01 ${DOCKER_NAME}`
    echo "CID is ${CID}"
    IP=`get_ip`
    echo "IP is ${IP}"
    sed -i -e "s/${DEFAULT_IP}/${IP}/g" hosts
    ;;
  run)
    if ! is_running_docker ; then
      echo "Docker container for ansible was not running."
      exit 0
    fi
    if [ $# -ne 2 ]; then
      echo -e "You need to specify playbook file.\n[Example]./${SCRIPT_NAME} run all.yml "
      exit 1
    fi
    export ANSIBLE_HOST_KEY_CHECKING=False
    export PYTHONUNBUFFERED=1
    export ANSIBLE_FORCE_COLOR=true
    ansible-playbook -i hosts -u docker $2
    ;;
  test)
    if ! is_running_docker ; then
      echo "Docker container for ansible was not running."
      exit 0
    fi
    IP=`get_ip`
    DIR=`ls -F spec/ |grep / |sed -e "s/\///g"`
    echo ${DIR}
    mv "spec/${DIR}" "spec/${IP}"
    bundle exec rake
    mv "spec/${IP}" "spec/${DIR}"
    ;;
  delete)
    if ! is_running_docker ; then
      echo "Docker container for ansible was not running."
      exit 0
    fi
    CID=`docker ps -a| grep ${DOCKER_NAME} |sed 's/\s\{1,\}/ /g' | cut -d ' ' -f 1`
    IP=`get_ip`
    echo "delete CID = ${CID}"
    docker stop ${CID} >/dev/null 2>&1
    docker rm ${CID} >/dev/null 2>&1
    sed -i -e "s/${IP}/${DEFAULT_IP}/g" hosts
    ;;
  *)
    echo "Usage: ${SCRIPT_NAME} {prepare|run|test|delete}" >&2
    exit 3
    ;;
esac
