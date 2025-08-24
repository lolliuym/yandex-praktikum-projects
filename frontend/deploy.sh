#!/bin/bash
set -xe

# Получаем аргументы
DOCKER_IMAGE="$1"
VERSION="$2"
REGISTRY_USER="$3"
REGISTRY_PASS="$4"
CI_PROJECT_DIR="$5"


echo "CI_PROJECT_DIR = ${CI_PROJECT_DIR}"

# Определяем хост реестра (все символы до первого /)
REGISTRY_HOST="${DOCKER_IMAGE%%/*}"

# Логинимся в Docker Registry
sudo docker login -u "$REGISTRY_USER" -p "$REGISTRY_PASS" "$REGISTRY_HOST" || {
  echo "Ошибка: Не удалось войти в registry '$REGISTRY_HOST'" >&2
  exit 1
}

# Создаём сеть, если её нет
sudo docker network create sausage_network || true

# Останавливаем и удаляем старый контейнер, если он существует
if sudo docker inspect sausage-frontend &>/dev/null; then
  sudo docker stop sausage-frontend || true
  sudo docker rm sausage-frontend || true
fi

echo $DOCKER_IMAGE

# Стягиваем новый образ
sudo docker pull "$DOCKER_IMAGE" || {
  echo "Ошибка: Не удалось загрузить образ '$DOCKER_IMAGE'" >&2
  exit 1
}

 
# Запускаем фронтенд
sudo docker run -d \
  --name sausage-frontend \
  --network sausage_network \
  -p 80:80 \
  $DOCKER_IMAGE
  # gitlab.praktikum-services.ru:5050/std-ext-016-02/sausage-store/sausage-frontend:1.0.2199418

  # Выполняем exec и проверяем файлы внутри контейнера
echo "Проверяем содержимое контейнера..."
if sudo docker inspect sausage-frontend > /dev/null 2>&1; then
  sudo docker exec sausage-frontend ls -l /usr/share/nginx/html || {
    echo "❌ Не удалось выполнить ls в контейнере"
    exit 1
  }
else
  echo "❌ Контейнер 'sausage-frontend' не найден!"
  sudo docker ps -a
  exit 1
fi