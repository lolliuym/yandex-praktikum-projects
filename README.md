# Sausage Store

![image](https://user-images.githubusercontent.com/9394918/121517767-69db8a80-c9f8-11eb-835a-e98ca07fd995.png)

# 🔐 DevOps-проект: Vault Integration — "Сосисочная"

Этот проект реализует **безопасное хранение и динамическую подгрузку конфигурации** для микросервисов приложения "Сосисочная" с использованием **HashiCorp Vault**. Цель — устранить секреты из кода, обеспечить централизованное управление конфигурацией и повысить безопасность доставки приложения в production.

---

## 🎯 Проблема

Хранение чувствительных данных (например, `spring.datasource.username`, `spring.datasource.password`, `spring.data.mongodb.uri`) в коде, `.properties`-файлах или переменных окружения — **нарушение безопасности**.
Решение: **HashiCorp Vault** как единый источник истины для секретов.

## 🛠️ Технологический стек

| Технология               | Назначение                                                                 |
| :----------------------- | :------------------------------------------------------------------------- |
| **HashiCorp Vault**      | Хранение и управление секретами                                            |
| **Spring Cloud Vault**   | Интеграция Vault с Spring Boot для динамического получения конфигурации    |
| **Docker**               | Контейнеризация приложения и Vault                                         |
| **GitLab CI/CD**         | Автоматизация сборки, тестирования и развёртывания                         |
| **JWT Authentication**   | Безопасная аутентификация пайплайнов GitLab в Vault                        |

## 📋 Предварительные требования

- Доступ к виртуальной машине (ВМ) в Yandex Cloud
- Установленные Docker и Docker Compose на ВМ
- Доступ к репозиторию GitLab CI: `std-ext-016-02/sausage-store`
- Разрешение на использование JWT в настройках CI/CD GitLab

## 🚀 Пошаговое развёртывание

### 1. Подготовка виртуальной машины
# Настройка Vault и запуск CI/CD для проекта "Сосисочная"

Этот документ описывает процесс настройки HashiCorp Vault на сервере и запуска CI/CD для проекта "Сосисочная" с использованием предоставленной конфигурации. Предполагается, что у вас есть доступ к виртуальной машине (ВМ) в Yandex Cloud, репозиторию GitLab `std-ext-016-02/sausage-store`, установлены Docker и Docker Compose, а также включена поддержка JWT в настройках GitLab CI/CD.

---

## Настройка Vault на сервере

### 1. Подготовка виртуальной машины
1. Подключитесь к ВМ через SSH:
   ```bash
   ssh <DEPLOY_USER>@<DEPLOY_HOST>
   ```
   Замените `<DEPLOY_USER>` (например, `ubuntu`) и `<DEPLOY_HOST>` (например, `51.250.3.212`) на ваши значения.

2. Создайте директории для Vault:
   ```bash
   sudo mkdir -p /opt/vault/{config,file,logs}
   ```

3. Убедитесь, что Docker установлен. Если нет, установите его:
   ```bash
   curl -fsSL https://get.docker.com | sh
   sudo usermod -aG docker $USER
   ```
   Перезайдите в сессию, чтобы применить изменения группы.

### 2. Запуск HashiCorp Vault
1. Создайте конфигурационный файл для Vault:
   ```bash
   sudo tee /opt/vault/config/config.hcl > /dev/null <<EOF
   storage "file" {
     path = "/vault/file"
   }

   listener "tcp" {
     address     = "0.0.0.0:8200"
     tls_disable = "true"
   }

   disable_mlock = true
   api_addr = "http://0.0.0.0:8200"
   cluster_addr = "https://127.0.0.1:8201"
   ui = true
   EOF
   ```

2. Создайте Docker-сеть:
   ```bash
   sudo docker network create sausage_network || true
   ```

3. Запустите Vault в Docker-контейнере:
   ```bash
   sudo docker run -d \
     --name vault \
     --network sausage_network \
     -p 8200:8200 \
     -v /opt/vault/config:/vault/config \
     -v /opt/vault/file:/vault/file \
     -v /opt/vault/logs:/vault/logs \
     -e VAULT_ADDR="http://0.0.0.0:8200" \
     vault:1.11.3 server
   ```

### 3. Инициализация и распечатывание Vault
1. Инициализируйте Vault:
   ```bash
   sudo docker exec vault vault operator init
   ```
   Сохраните **5 Unseal Keys** и **Root Token** в безопасное место. Они понадобятся для дальнейшей работы.

2. Распечатайте Vault, используя три из пяти Unseal Keys:
   ```bash
   sudo docker exec vault vault operator unseal <UNSEAL_KEY_1>
   sudo docker exec vault vault operator unseal <UNSEAL_KEY_2>
   sudo docker exec vault vault operator unseal <UNSEAL_KEY_3>
   ```

### 4. Настройка Vault
1. Войдите в Vault с root-токеном:
   ```bash
   sudo docker exec -e VAULT_TOKEN="<YOUR_ROOT_TOKEN>" vault vault login
   ```

2. Включите KV-хранилище версии 2:
   ```bash
   sudo docker exec -e VAULT_TOKEN="<YOUR_ROOT_TOKEN>" vault vault secrets enable -version=2 -path=secret kv
   ```

3. Создайте политику доступа `sausage-store`:
   ```bash
   sudo docker exec -e VAULT_TOKEN="<YOUR_ROOT_TOKEN>" vault vault policy write sausage-store - <<EOF
   path "secret/data/sausage-store" {
     capabilities = ["read"]
   }
   EOF
   ```

4. Включите JWT-аутентификацию:
   ```bash
   sudo docker exec -e VAULT_TOKEN="<YOUR_ROOT_TOKEN>" vault vault auth enable jwt
   ```

5. Настройте JWT-аутентификацию для GitLab:
   ```bash
   sudo docker exec -e VAULT_TOKEN="<YOUR_ROOT_TOKEN>" vault vault write auth/jwt/config \
     jwks_url="https://gitlab.praktikum-services.ru/-/jwks" \
     bound_issuer="gitlab.praktikum-services.ru"
   ```

6. Создайте роль для проекта:
   ```bash
   sudo docker exec -e VAULT_TOKEN="<YOUR_ROOT_TOKEN>" vault vault write auth/jwt/role/sausage-store \
     role_type=jwt \
     policies=sausage-store \
     user_claim=email \
     bound_claims='{"project_path": "std-ext-016-02/sausage-store"}'
   ```

### 5. Добавление секретов в Vault
Запишите секреты для приложения:
```bash
sudo docker exec -e VAULT_TOKEN="<YOUR_ROOT_TOKEN>" vault vault kv put secret/sausage-store \
  spring.datasource.username=std-ext-016-02 \
  spring.datasource.password=Testusr1234 \
  spring.data.mongodb.uri="mongodb://std-ext-016-02:Testusr1234@rc1a-udg79n2h293n1hdk.mdb.yandexcloud.net:27018/std-ext-016-02?tls=true"
```

### 6. Проверка работоспособности Vault
Убедитесь, что Vault работает:
```bash
curl http://<DEPLOY_HOST>:8200/v1/sys/health
```
Ожидаемый ответ — JSON с кодом состояния 200, указывающий, что Vault распечатан и работает.

---

## Настройка и запуск CI/CD

### 1. Настройка приложения
Убедитесь, что в файле `src/main/resources/application.properties` настроена интеграция с Vault.

### 2. Настройка переменных в GitLab CI/CD
1. Перейдите в проект GitLab (`std-ext-016-02/sausage-store`).
2. Откройте `Settings -> CI/CD -> Variables` и добавьте следующие переменные:

   | Ключ                     | Значение                                           | Masked |
   | :----------------------- | :------------------------------------------------- | :----- |
   | `VAULT_ADDR`            | `http://<DEPLOY_HOST>:8200` (например, `http://51.250.3.212:8200`) | ✅     |
   | `SSH_PRIVATE_KEY_DEPLOY`| Ваш приватный SSH-ключ                             | ✅     |
   | `SSH_KNOWN_HOSTS_DEPLOY`| Результат команды `ssh-keyscan <DEPLOY_HOST>`      | ✅     |
   | `CI_REGISTRY_USER`      | `gitlab-ci-token`                                  | ✅     |
   | `CI_REGISTRY_PASSWORD`  | `$CI_JOB_TOKEN`                                    | ✅     |
   | `DEPLOY_USER`           | Имя пользователя (например, `ubuntu`)               | ❌     |
   | `DEPLOY_HOST`           | IP-адрес вашей ВМ (например, `51.250.3.212`)        | ❌     |

3. Убедитесь, что JWT включен: `Settings -> CI/CD -> General pipelines -> Enable JWT token for CI/CD jobs`.

### 3. Проверка файла `.gitlab-ci.yml`
Убедитесь, что в корне репозитория есть файл `.gitlab-ci.yml`.  

### 4. Создание скрипта деплоя
Создайте файл `backend/deploy.sh` в репозитории:
```bash
#!/bin/bash
set -xe

DOCKER_IMAGE=$(echo "$1" | xargs)
VERSION=$(echo "$2" | xargs)
REGISTRY_USER=$(echo "$3" | xargs)
REGISTRY_PASS=$(echo "$4" | xargs)

if [ -z "$VAULT_TOKEN" ]; then
  echo "Ошибка: VAULT_TOKEN не установлен"
  exit 1