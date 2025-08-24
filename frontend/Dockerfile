# Stage 1: Build with Node.js
FROM node:16.20.0-alpine3.18 as builder
WORKDIR /usr/src/app
COPY . .
RUN npm install && npm run build

# Stage 2: Serve with Nginx
FROM nginx:stable-alpine3.17-slim
# Удаляем стандартные файлы Nginx
RUN rm -rf /usr/share/nginx/html/*

# Копируем наши файлы фронтенда внутрь образа
COPY --from=builder /usr/src/app/dist/frontend /usr/share/nginx/html

# Копируем конфиг Nginx
COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]