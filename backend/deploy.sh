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


ls -l builds/std-ext-016-02/sausage-store

# Загружаем переменные из .env
if [ -f "$CI_PROJECT_DIR/.env" ]; then
  export $(grep -v '^#' "$CI_PROJECT_DIR/.env" | xargs)
else
  echo "❌ .env not found"
  exit 1
fi

# Проверка обязательных переменных
if [ -z "$BACKEND_VERSION" ]; then
  echo "Ошибка: BACKEND_VERSION не задана"
  exit 1
fi

# Логин в registry
echo "Логин в Docker registry..."
sudo docker login -u "${CI_REGISTRY_USER}" -p "${CI_REGISTRY_PASSWORD}" "${CI_REGISTRY_IMAGE%%/*}" || {
  echo "❌ Ошибка: Не удалось войти в registry"
  exit 1
}

# Создаём сеть
sudo docker network create sausage_network || true

# Определяем текущий контейнер
CURRENT_CONTAINER="none"
if sudo docker inspect sausage-backend-blue &>/dev/null && \
   [ "$(sudo docker inspect --format='{{.State.Running}}' sausage-backend-blue)" == "true" ]; then
    CURRENT_CONTAINER="blue"
elif sudo docker inspect sausage-backend-green &>/dev/null && \
     [ "$(sudo docker inspect --format='{{.State.Running}}' sausage-backend-green)" == "true" ]; then
    CURRENT_CONTAINER="green"
fi

# Удаляем старый green
if sudo docker inspect sausage-backend-green &>/dev/null; then
  sudo docker stop sausage-backend-green || true
  sudo docker rm sausage-backend-green || true
fi

# Останавливаем текущий
if [ "$CURRENT_CONTAINER" != "none" ]; then
  sudo docker stop "sausage-backend-$CURRENT_CONTAINER" || true
  sudo docker rm "sausage-backend-$CURRENT_CONTAINER" || true
  sleep 10
fi

# Запускаем новый
sudo docker run -d \
  --name sausage-backend-green \
  --network sausage_network \
  -e SPRING_DATASOURCE_URL="$SPRING_DATASOURCE_URL" \
  -e SPRING_DATASOURCE_USERNAME="$SPRING_DATASOURCE_USERNAME" \
  -e SPRING_DATASOURCE_PASSWORD="$SPRING_DATASOURCE_PASSWORD" \
  -e SPRING_DATA_MONGODB_URI="$SPRING_DATA_MONGODB_URI" \
  -e REPORT_PATH=/var/logs/app \
  -e LOG_PATH=/var/logs/app \
  -p 8080:8080 \
  "$DOCKER_IMAGE"


# Ждём здоровья
MAX_RETRIES=15
for i in $(seq 1 $MAX_RETRIES); do
  HEALTH=$(sudo docker inspect --format='{{json .State.Health.Status}}' sausage-backend-green 2>/dev/null || true)
  if [ "$HEALTH" == '"healthy"' ]; then
    echo "✅ Контейнер готов"
    exit 0
  fi
  sleep 10
done

# Фолбэк
if ! sudo docker exec sausage-backend-green curl -s --fail http://localhost:8080/actuator/health; then
  echo "❌ Приложение не ответило"
  sudo docker logs sausage-backend-green  
  exit 1
fi

echo "✅ Приложение работает"