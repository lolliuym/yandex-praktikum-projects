# берём базовый образ, содержащий утилиту maven и jdk для сборки java-проекта
FROM maven:3.8.2-openjdk-16-slim

# сделали переменную VERSION, она нам понадобится, чтобы передавать при сборке образа версию сосисочного бэкенда
ARG VERSION=0.0.${VERSION}

# копируем исходники сосисочного бэкенда в создаваемый образ
WORKDIR /root
COPY ./src ./src
COPY *.xml ./

# собираем бэкенд сосисочной
# после этой команды в папке target создастся jar-файл с сервсисом сосисочного бэкенда
RUN mvn package -Dversion.application=0.0.${VERSION}

# копируем CA-сертификат Яндекса в образ
RUN curl https://storage.yandexcloud.net/cloud-certs/CA.pem -o YandexInternalRootCA.crt

# подкидываем CA-сертификат Яндекса в хранилище сертификатов для Java,
# создаём пользователя jaruser,
# устанавливаем утилиту dumb-init,
# копируем собранный артефакт в папку /app
RUN keytool -importcert -file YandexInternalRootCA.crt \
    -alias yandex -cacerts -storepass changeit -noprompt \
    && rm YandexInternalRootCA.crt \
    && addgroup --system jaruser \
    && adduser --system --shell /bin/false -group jaruser \
    && apt update && apt install dumb-init && apt clean \
    && mkdir /app \
    && ls -la target \
    && echo "Версия приложения: ${VERSION}" \
    && cp ./target/sausage-store-0.0.${VERSION}.jar /app/sausage-store.jar

# директива EXPOSE не открывает порт, а лишь указывает, что приложение работает на этом порту
EXPOSE 8080

# приложение будет запускаться под пользователем jaruser
USER jaruser

# устанавливаем точку входа, вернее ту команду, которая запустится при старте контейнера
ENTRYPOINT ["dumb-init", "java", "-jar", "-Dmyserver.bindPort=8080", "/app/sausage-store.jar"]