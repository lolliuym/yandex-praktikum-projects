#!/bin/bash
set -xe

DOCKER_IMAGE=$(echo "$1" | xargs)
VERSION=$(echo "$2" | xargs)
REGISTRY_USER=$(echo "$3" | xargs)
REGISTRY_PASS=$(echo "$4" | xargs)
SPRING_DATASOURCE_URL=$(echo "$5" | xargs)
SPRING_DATASOURCE_DATABASE=$(echo "$6" | xargs)
SPRING_DATASOURCE_USERNAME=$(echo "$7" | xargs)
SPRING_DATASOURCE_PASSWORD=$(echo "$8" | xargs)
SPRING_DATA_MONGODB_URI=$(echo "$9" | xargs)
CI_REGISTRY_IMAGE=$(echo "$10" | xargs)
CI_PROJECT_DIR="builds/std-ext-016-02/sausage-store"
 

# PROJECT_DIR="/home/deploy/sausage-store"
# Логин в registry
echo "Логин в Docker registry..."
sudo docker login -u "$REGISTRY_USER" -p "$REGISTRY_PASS" "${DOCKER_IMAGE%%/*}" || exit 1

# Создаём сеть
sudo docker network create sausage_network || true

# Загружаем переменные
if [ -f "$CI_PROJECT_DIR/.env" ]; then
  export $(grep -v '^#' "$CI_PROJECT_DIR/.env" | xargs)
else
  echo "❌ .env not found"
  exit 1
fi

# Определяем текущий активный контейнер
CURRENT="none"
if sudo docker inspect sausage-backend-blue &>/dev/null && \
   [ "$(sudo docker inspect --format='{{.State.Running}}' sausage-backend-blue)" == "true" ]; then
    CURRENT="blue"
elif sudo docker inspect sausage-backend-green &>/dev/null && \
     [ "$(sudo docker.inspect --format='{{.State.Running}}' sausage-backend-green)" == "true" ]; then
    CURRENT="green"
fi

echo "Текущий активный: $CURRENT"

# Удаляем старый green, если есть
if sudo docker inspect sausage-backend-green &>/dev/null; then
  sudo docker stop sausage-backend-green || true
  sudo docker rm sausage-backend-green || true
fi

# Стягиваем новый образ
sudo docker pull "${CI_REGISTRY_IMAGE}/sausage-backend:${BACKEND_VERSION}"

# Запускаем backend-green (без проброса порта 8080)
sudo docker run -d \
  --name sausage-backend-green \
  --network sausage_network \
  -e SPRING_DATASOURCE_USERNAME="${SPRING_DATASOURCE_USERNAME}" \
  -e SPRING_DATASOURCE_PASSWORD="${SPRING_DATASOURCE_PASSWORD}" \
  -e SPRING_DATASOURCE_URL="jdbc:postgresql://${SPRING_DATASOURCE_HOST}:${SPRING_DATASOURCE_PORT}/${SPRING_DATASOURCE_DATABASE}" \
  -e SPRING_DATA_MONGODB_URI="${REPORTS_MONGODB_URI}" \
  -e SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE=8 \
  -e LOG_PATH=/tmp \
  -e REPORT_PATH=/tmp \
  "${CI_REGISTRY_IMAGE}/sausage-backend:${BACKEND_VERSION}"

# Ждём здоровья
MAX_RETRIES=8
for i in $(seq 1 $MAX_RETRIES); do
  HEALTH=$(sudo docker inspect --format='{{json .State.Health.Status}}' sausage-backend-green 2>/dev/null || true)
  if [ "$HEALTH" == '"healthy"' ]; then
    echo "✅ sausage-backend-green готов"
    break
  fi
  sleep 10
done

if [ "$HEALTH" != '"healthy"' ]; then
  echo "❌ sausage-backend-green не стал здоровым"
  sudo docker logs sausage-backend-green
  exit 1
fi

# Останавливаем старый
if [ "$CURRENT" == "blue" ]; then
  sudo docker stop sausage-backend-blue || true
  sudo docker rm sausage-backend-blue || true
elif [ "$CURRENT" == "green" ]; then
  sudo docker stop sausage-backend-green || true
  sudo docker rm sausage-backend-green || true
fi

echo "✅ Blue-Green деплой завершён"