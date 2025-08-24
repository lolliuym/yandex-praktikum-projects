# === Stage 1: Сборка ===
FROM maven:3.8-openjdk-16 AS builder
WORKDIR /app
COPY pom.xml .
COPY src src
ARG VERSION
RUN mvn package -Dversion.application=${VERSION}

# === Stage 2: Запуск ===
FROM eclipse-temurin:17-jre-focal

# Установка утилит
RUN apt update && \
    apt install -y curl dumb-init && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Добавление CA-сертификата Яндекса
RUN mkdir -p /usr/local/share/ca-certificates && \
    curl -L https://storage.yandexcloud.net/cloud-certs/CA.pem \
    -o /usr/local/share/ca-certificates/YandexInternalRootCA.crt && \
    $JAVA_HOME/bin/keytool -importcert -trustcacerts -alias yandex \
    -keystore $JAVA_HOME/lib/security/cacerts \
    -storepass changeit -file /usr/local/share/ca-certificates/YandexInternalRootCA.crt -noprompt

# Создание пользователя
RUN addgroup --system jaruser && \
    adduser --system --shell /bin/false --group jaruser

WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar

# Права на /tmp
RUN chmod -R 777 /tmp

USER jaruser

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["dumb-init", "java", "-jar", "app.jar"]