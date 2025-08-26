# Sausage Store

![image](https://user-images.githubusercontent.com/9394918/121517767-69db8a80-c9f8-11eb-835a-e98ca07fd995.png)

# 🐳 DevOps-проект: Docker Deployment — "Сосисочная"

Этот проект реализует **сборку и развёртывание микросервисного приложения "Сосисочная"** с использованием **Docker**, **Nginx** и **автоматизированного деплоя через SSH**. Цель — смоделировать процесс доставки приложения в production-подобную среду с использованием CI/CD и инфраструктуры как кода.

Приложение включает:
- **Frontend** — веб-интерфейс на Node.js
- **Nginx** — веб-сервер и обратный прокси
- **Автоматизация** — через GitLab CI/CD и shell-скрипты

---

## 🌐 Демо

Приложение доступно по адресу:  
👉 [http://std-ext-016-02.praktikum-services.tech](http://std-ext-016-02.praktikum-services.tech)

> ⚠️ Среда используется в учебных целях — может быть временно недоступна.

---

## 🛠️ Технологии

| Технология       | Назначение |
|------------------|-----------|
| **Docker**       | Контейнеризация сервисов |
| **Dockerfile**   | Описание образов для сборки |
| **Nginx**        | Веб-сервер и reverse proxy |
| **GitLab CI/CD** | Автоматическая сборка и деплой |
| **SSH**          | Доставка на удалённый сервер |
| **Shell-скрипты**| Автоматизация перезапуска (`deploy.sh`) |

---

## 📦 Архитектура

User → HTTP → Nginx (прокси) → Frontend (Docker)
↓
Проксирование /api → Внешний backend

- Frontend и Nginx запускаются как отдельные Docker-контейнеры.
- Nginx обслуживает статику и проксирует `/api/*` на внешний backend.
- Образы собираются и пушатся в GitLab Container Registry.
- Деплой выполняется на удалённой ВМ через SSH.

---

## 📂 Структура проекта

docker/
├── frontend/
│ ├── Dockerfile # Сборка frontend-образа
│ └── .dockerignore
├── nginx/
│ ├── Dockerfile # Кастомный образ Nginx
│ └── nginx.conf # Конфигурация проксирования
├── .gitlab-ci.yml # Пайплайн CI/CD
└── deploy.sh # Скрипт деплоя на сервер


---

## 🏗️ Сборка образов

### ✅ Frontend
- Собирается в два этапа:
  1. Сборка (`npm install`, `npm run build`)
  2. Финальный образ на `nginx:alpine` с копированием `dist/`
- Образ: `registry.gitlab.com/lolliuym/yandex-praktikum-projects/frontend:latest`

### ✅ Nginx
- Кастомный образ на базе `nginx:alpine`
- Подменяет стандартный `nginx.conf`
- Настроен на:
  - Обслуживание статики с `/usr/share/nginx/html`
  - Проксирование `/api/**` на внешний backend (например, `backend.praktikum-services.tech:8080`)

---

## 🔄 CI/CD Pipeline (GitLab CI)

Пайплайн в `.gitlab-ci.yml` выполняет:

1. **Сборку и пуш образов**:
   - `frontend`
   - `nginx`

2. **Деплой через SSH**:
   - Подключение к удалённому серверу по зашифрованному ключу
   - Выполнение скрипта `deploy.sh`

```yaml

deploy:
  stage: deploy
  script:
    - chmod 600 $SSH_KEY
    - ssh -o StrictHostKeyChecking=no -i $SSH_KEY user@$SERVER_IP "cd /opt/sausage && ./deploy.sh"
  environment: production
  only:
    - docker