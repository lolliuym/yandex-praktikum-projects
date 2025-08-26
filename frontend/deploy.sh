#!/bin/bash
set -xe

DOCKER_IMAGE="$1"
VERSION="$2"
REGISTRY_USER="$3"
REGISTRY_PASS="$4"
CI_PROJECT_DIR="$5" 

echo "${CI_PROJECT_DIR}"

# Логинимся в реестр
sudo docker login -u "$REGISTRY_USER" -p "$REGISTRY_PASS" "${DOCKER_IMAGE%%/*}" || exit 1

# Создаём сеть (если не существует)
sudo docker network create sausage_network || true

# Удаляем старый контейнер
sudo docker rm -f sausage-frontend || true

# Стягиваем новый образ
sudo docker pull "$DOCKER_IMAGE"


# Запускаем фронтенд
sudo docker run -d \
  --name sausage-frontend \
  --network sausage_network \
  -p 80:80 \
  -v /tmp/$CI_PROJECT_DIR/frontend/default.conf:/etc/nginx/conf.d/default.conf \
  --restart always \
  "$DOCKER_IMAGE"