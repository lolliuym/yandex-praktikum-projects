# === Stage 1: Сборка ===
FROM maven:3.8-openjdk-16 AS builder
WORKDIR /app
COPY pom.xml .
COPY src src
ARG VERSION
RUN mvn package -Dversion.application=${VERSION}

# === Stage 2: Запуск ===
FROM eclipse-temurin:17-jre

# Установка утилит
RUN apt update && \
    apt install -y curl dumb-init && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Создание пользователя
# Создание пользователя с домашней директорией
RUN addgroup --system jaruser && \
    adduser --system --shell /bin/false --ingroup jaruser --home /home/jaruser jaruser

# Скачиваем CA-сертификат
RUN mkdir -p /usr/local/share/ca-certificates && \
    curl -L https://storage.yandexcloud.net/cloud-certs/CA.pem \
    -o /usr/local/share/ca-certificates/YandexInternalRootCA.crt

# Импорт в Java truststore
RUN $JAVA_HOME/bin/keytool -importcert -trustcacerts -alias yandex \
    -keystore $JAVA_HOME/lib/security/cacerts \
    -storepass changeit -file /usr/local/share/ca-certificates/YandexInternalRootCA.crt -noprompt

# Создаём директорию для PostgreSQL и копируем сертификат
RUN mkdir -p /home/jaruser/.postgresql && \
    cp /usr/local/share/ca-certificates/YandexInternalRootCA.crt /home/jaruser/.postgresql/root.crt && \
    chown -R jaruser:jaruser /home/jaruser/.postgresql && \
    chmod 600 /home/jaruser/.postgresql/root.crt

# Рабочая директория
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar

# Смена пользователя
USER jaruser

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["dumb-init", "java", "-jar", "app.jar"]