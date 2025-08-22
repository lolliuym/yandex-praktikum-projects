# 🚀 DevOps Портфолио — Проект "Сосисочная" (Яндекс.Практикум)

Это портфолио содержит проекты, реализованные мной в рамках обучения в **Яндекс.Практикуме** по программе DevOps/SRE. Все решения охватывают полный цикл доставки приложения: от инфраструктуры до CI/CD, безопасности и автоматизации.

Проект моделирует реальное микросервисное приложение — **"Сосисочная"**, включающее фронтенд, бэкенд, отчёты и базу данных. Каждая технология реализована в отдельной ветке с использованием лучших практик: GitOps, IaC, безопасное хранение секретов, стратегии деплоя.

---

## 🛠️ Общий стек

| Категория         | Технологии |
|------------------|-----------|
| **Контейнеры**   | Docker, Docker Compose, nginx-proxy |
| **Оркестрация**  | Kubernetes (Deployments, Services, Ingress, ConfigMap, Secrets) |
| **CI/CD**        | GitLab CI/CD, Kaniko, Crane, SSH-деплой |
| **Инфраструктура** | Terraform, Yandex Cloud (VPC, Compute) |
| **Конфигурация** | Ansible, Playbook, Roles, Inventory |
| **Безопасность** | HashiCorp Vault, TLS, cert-manager, Secrets management |
| **Базы данных**  | PostgreSQL, Flyway (миграции), Spring Data |
| **Автоматизация** | Shell-скрипты, health-check, blue-green, динамическая балансировка |

---

## 🌿 Ветки и реализованные проекты

Каждая ветка — это законченный модуль с описанием, кодом и MR. Ниже представлена структура:

| Ветка | Технологии | Описание | Демо / Ссылка |
|------|------------|---------|----------------|
| `kubernetes` | Kubernetes, GitLab CI, Ingress, TLS, ConfigMap | Манифесты для развёртывания frontend, backend, backend-report. Настройка Ingress с TLS через cert-manager. Автоматический деплой при изменении в директории `kubernetes`. | 🔗 [https://std-ext-016-02.k8s.praktikum-services.tech/](https://std-ext-016-02.k8s.praktikum-services.tech/) |
| `docker` | Docker, Dockerfile, Nginx, GitLab CI, SSH | Сборка образов фронтенда, конфигурация Nginx, автоматизация деплоя через `deploy.sh` с перезапуском и пробросом конфигов. | — |
| `microservices-blue-green` | Docker Compose, Blue-Green, Health Check, Actuator | Реализация стратегии blue-green деплоя: два контейнера (blue/green), health-check через `/actuator/health`, скрипт переключения. | — |
| `microservices-balancing` | nginx-proxy, Go templates, Docker socket | Динамическая балансировка нагрузки: Nginx как балансировщик, шаблон `nginx.tmpl`, автоматическое обнаружение бэкендов. | — |
| `terraform` | Terraform, Yandex Cloud, IaC, modules | Модульная инфраструктура: `tf-yc-instance` (ВМ), `tf-yc-network` (сеть и подсеть). Работа с провайдером `yandex-cloud/yandex`. | — |
| `ansible` | Ansible, Playbook, Roles, systemd, Inventory | Автоматизация развёртывания: роль `backend` (OpenJDK, JAR, systemd), роль `frontend` (Node.js, npm, Nginx). | — |
| `flyway` | Flyway, SQL, Maven, PostgreSQL | Версионированные миграции: `V001__create_tables.sql`, `V002__insert_data.sql`, `V003__create_index.sql`. Интеграция с Spring Boot. | — |
| `vault-integration` | HashiCorp Vault, Spring Cloud Vault, REST API | Хранение `spring.datasource.*` и `spring.data.mongodb.uri` в Vault. Удаление секретов из кода, динамическая подгрузка. | — |
| `microservices` | Docker Compose, Nginx, CI/CD | Запуск приложения через docker-compose, настройка балансировки и деплоя. | 🔗 [http://std-ext-016-02.praktikum-services.tech/](http://std-ext-016-02.praktikum-services.tech/) |

> 💡 **Примечание**:  
> - Ветка `kubernetes` развернута с HTTPS и TLS (Ingress в Kubernetes).  
> - Ветка `microservices` работает через nginx-proxy на HTTP.  
> - Приложение может быть временно недоступно — среда используется в учебных целях.

---

## 🔍 Как проверить?

1. Перейдите в репозиторий:  
   🔗 `https://gitlab.com/lolliuym/yandex-praktikum-projects`

2. Выберите нужную ветку (например, `kubernetes`).

3. Проверьте:
   - Наличие структуры файлов (например, `kubernetes/frontend/deployment.yaml`).
   - Корректность манифестов и конфигов.
   - Наличие `.gitlab-ci.yml` и скриптов деплоя.
   - Merge Request — там можно увидеть логи пайплайна и комментарии.

4. Откройте ссылку из таблицы выше, чтобы убедиться, что приложение работает.

---

## 📬 Связь

Если у вас есть вопросы или вы хотите обсудить сотрудничество — свяжитесь со мной:

- **Имя**: [Валерий]
- **Email**: [anest12mmm@gmail.com]
- **Telegram**: [@tumbulls]


---

> 💡 *Все проекты выполнены с соблюдением промышленных стандартов: безопасность, воспроизводимость, автоматизация. Готов применять эти навыки в production-среде.*