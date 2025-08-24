#!/bin/bash
set -xe

# Получаем аргументы
CI_REGISTRY_IMAGE=$(echo "$1" | xargs)
VERSION=$(echo "$2" | xargs)
SPRING_DATA_MONGODB_URI=$(echo "$3" | xargs)
CI_PROJECT_DIR=$(echo "$4" | xargs)
REGISTRY_USER=$(echo "$5" | xargs)
REGISTRY_PASS=$(echo "$6" | xargs)
DOCKER_IMAGE=$(echo "$7" | xargs)

# PATHENV=$(echo "${CI_REGISTRY_IMAGE}/sausage-backend-report:${VERSION}" | sed 's/[[:space:]]//g')


# Логин в Docker registry
sudo docker login -u "$REGISTRY_USER" -p "$REGISTRY_PASS" "${DOCKER_IMAGE%%/*}" || {
  echo "Ошибка: Не удалось войти в registry '$DOCKER_IMAGE'" >&2
  exit 1
}

# Создаём сеть, если её нет
# Создаём сеть, если её нет
if ! sudo docker network inspect sausage-network >/dev/null 2>&1; then
  echo "Создаём сеть sausage-network"
  sudo docker network create sausage-network
fi

# Останавливаем старый контейнер, если он есть
if [ "$(sudo docker ps -a -f "name=sausage-backend-report" --format "{{.Status}}")" ]; then
  sudo docker stop sausage-backend-report || true
  sudo docker rm sausage-backend-report || true
fi

# Создаём директорию, если её нет
mkdir -p "${CI_PROJECT_DIR}/backend-report"

# Создаём env-файл
cat > "${CI_PROJECT_DIR}/backend-report/deploy.env" <<EOL
CI_REGISTRY_IMAGE=${CI_REGISTRY_IMAGE}
VERSION=${VERSION}
SPRING_DATA_MONGODB_URI=${SPRING_DATA_MONGODB_URI}
PORT=8082
EOL

# Отладочный вывод
echo "Файл .env создан:"
ls -l "${CI_PROJECT_DIR}/backend-report"
 
echo $PATHENV
# Запуск сервиса
sudo docker run \
  --name sausage-backend-report \
  --env-file "${CI_PROJECT_DIR}/backend-report/deploy.env" \
  -d \
  -p 8082:8080 \
  --network sausage-network \
  ${CI_REGISTRY_IMAGE}/sausage-backend-report:${VERSION}