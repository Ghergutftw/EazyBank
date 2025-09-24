# EazyBank Microservices Docker Setup

This project includes Docker containers for all EazyBank microservices.

## Services Included

- **Accounts Service** (Port 8080)
- **Cards Service** (Port 9000) 
- **Loans Service** (Port 8090)
- **Status Dashboard** (Port 4200) - Angular frontend

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Java 17+ (for building Spring Boot JARs)
- Node.js 18+ (for building Angular app)

### Build and Run

1. **Build all Spring Boot services:**
```bash
# Build accounts service
cd accounts && mvn clean package -DskipTests && cd ..

# Build cards service  
cd cards && mvn clean package -DskipTests && cd ..

# Build loans service
cd loans && mvn clean package -DskipTests && cd ..
```

2. **Build and start all services:**
```bash
docker-compose up --build
```

3. **Access the services:**
- Status Dashboard: http://localhost:4200
- Accounts API: http://localhost:8080
- Cards API: http://localhost:9000
- Loans API: http://localhost:8090

## Maintenance Mode Testing

To test maintenance mode, you can set environment variables:

```bash
# Enable maintenance on accounts service
docker-compose exec accounts sh -c 'export app.maintenance=true'

# Or rebuild with maintenance enabled
docker-compose up --build -e app.maintenance=true accounts
```

## Service URLs in Docker

The Angular dashboard automatically proxies API calls to:
- `/api/contact-info` → accounts:8080/api/contact-info
- `/api/cards/contact-info` → cards:9000/api/contact-info  
- `/api/loans/contact-info` → loans:8090/api/contact-info

Note: All backend services expose the same `/api/contact-info` endpoint on their respective ports. The Angular frontend uses different URL prefixes to distinguish between services.

## Docker Network

All services run on the `eazybank-network` bridge network for internal communication.

## Health Checks

Each service includes health checks accessible at:
- http://localhost:8080/actuator/health (accounts)
- http://localhost:9000/actuator/health (cards)
- http://localhost:8090/actuator/health (loans)
