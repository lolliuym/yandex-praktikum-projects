#!/bin/bash
set -xe

DOCKER_IMAGE=$(echo "$1" | xargs)
VERSION=$(echo "$2" | xargs)
REGISTRY_USER=$(echo "$3" | xargs)
REGISTRY_PASS=$(echo "$4" | xargs)
SPRING_DATASOURCE_URL=$(echo "$5" | xargs)
SPRING_DATASOURCE_USERNAME=$(echo "$6" | xargs)
SPRING_DATASOURCE_PASSWORD=$(echo "$7" | xargs)
SPRING_DATA_MONGODB_URI=$(echo "$8" | xargs)
CI_PROJECT_DIR=$(echo "$9" | xargs)

echo "CI_PROJECT_DIR=$8"
echo "DOCKER_IMAGE = $1"
echo "VERSION      = $2"
echo "REGISTRY_USER= $3"
echo "REGISTRY_PASS= $4"
echo "SPRING_DATASOURCE_URL   = $5"
echo "SPRING_DATASOURCE_USERNAME = $6"
echo "SPRING_DATASOURCE_PASSWORD = $7"
echo "SPRING_DATA_MONGODB_URI     = $8"
 


echo "REGISTRY    = ${DOCKER_IMAGE%%/*}"

sudo docker login -u "$REGISTRY_USER" -p "$REGISTRY_PASS" "${DOCKER_IMAGE%%/*}" || exit 1

# Создаём сеть, если её нет
sudo docker network create sausage_network || true

# Останавливаем старый контейнер
sudo docker rm -f sausage-backend || true

# Скачиваем новый образ
sudo docker pull ${DOCKER_IMAGE}

# Запускаем бэкенд
sudo docker run -d \
  --name sausage-backend \
  --network sausage_network \
  -e SPRING_DATASOURCE_URL="$SPRING_DATASOURCE_URL" \
  -e SPRING_DATASOURCE_USERNAME="$SPRING_DATASOURCE_USERNAME" \
  -e SPRING_DATASOURCE_PASSWORD="$SPRING_DATASOURCE_PASSWORD" \
  -e SPRING_DATA_MONGODB_URI="$SPRING_DATA_MONGODB_URI" \
  "$DOCKER_IMAGE"