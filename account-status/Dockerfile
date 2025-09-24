# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY src ./src
COPY public ./public
COPY angular.json ./
COPY tsconfig*.json ./
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=build /app/dist/account-status /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
