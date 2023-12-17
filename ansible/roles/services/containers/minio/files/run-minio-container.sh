#!/bin/bash

set -e

CONTAINER_RUNTIME_BINARY=/usr/bin/docker
CONTAINER_NAME=minio
CONTAINER_IMAGE_NAME=minio/minio:latest
CONTAINER_HOST_IP=$(hostname -I | awk '{print $1}')

if test -f /opt/containers/${CONTAINER_NAME}/config/${CONTAINER_NAME}.label; then
  echo " ===> Using label file"
  export ENABLE_LABEL_FLAG="--label-file /opt/containers/${CONTAINER_NAME}/config/${CONTAINER_NAME}.label"
fi

if test -f /opt/containers/${CONTAINER_NAME}/config/${CONTAINER_NAME}.env; then
  echo " ===> Using environment file"
  export ENABLE_ENV_FLAG="--env-file /opt/containers/${CONTAINER_NAME}/config/${CONTAINER_NAME}.env"
fi

echo " ===> Shutting down any existing instances of container..."

${CONTAINER_RUNTIME_BINARY} exec ${CONTAINER_NAME} stop 2>/dev/null || true

echo " ===> Removing any existing instances of container..."

${CONTAINER_RUNTIME_BINARY} rm ${CONTAINER_NAME} 2>/dev/null || true

echo " ===> Starting container..."

${CONTAINER_RUNTIME_BINARY} run -t --rm --name ${CONTAINER_NAME} -h ${CONTAINER_NAME} "$@" \
  --add-host=containerhost:"$CONTAINER_HOST_IP" \
  ${ENABLE_LABEL_FLAG} \
  ${ENABLE_ENV_FLAG} \
  -p '9093:9001' \
  -p '9094:9000' \
  -v /opt/containers/${CONTAINER_NAME}/data:/data \
  ${CONTAINER_IMAGE_NAME} \
  server /data --console-address ":9001"
