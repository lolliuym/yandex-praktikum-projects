# === Stage 1: Сборка приложения ===
FROM maven:3.8.3-openjdk-16 AS builder

WORKDIR /root

# Копируем исходники и POM
COPY ./pom.xml .
COPY ./src ./src

# Собираем проект с версией из аргумента
ARG VERSION
RUN mvn package -Dversion.application=${VERSION}

# === Stage 2: Запуск приложения ===
FROM eclipse-temurin:16-jdk-focal

# Установим JAVA_HOME
ENV JAVA_HOME=/opt/java/openjdk

# Проверим Java
RUN java -version && \
    javac -version && \
    echo "Java path: $(which java)" && \
    echo "JVM path: $(readlink -f $(which java))"

# Установка утилит
RUN apt update && \
    apt install -y curl dumb-init && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Создаем пользователя jaruser
RUN addgroup --system jaruser && \
    adduser --system --shell /bin/false --group jaruser

# Добавляем CA-сертификат Яндекса в хранилище Java
RUN mkdir -p /usr/local/share/ca-certificates && \
    curl -L https://storage.yandexcloud.net/cloud-certs/CA.pem  \
         -o /usr/local/share/ca-certificates/YandexInternalRootCA.crt && \
    $JAVA_HOME/bin/keytool -importcert -trustcacerts -alias yandex \
        -keystore $JAVA_HOME/lib/security/cacerts \
        -storepass changeit -noprompt \
        -file /usr/local/share/ca-certificates/YandexInternalRootCA.crt || true

# Рабочая директория
WORKDIR /app

# Копируем JAR-файл из стадии сборки
COPY --from=builder /root/target/*.jar app.jar

# Запускаем от непривилегированного пользователя
USER jaruser

# Команда запуска
ENTRYPOINT ["dumb-init", "java", "-jar", "./app.jar"]