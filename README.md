# EazyBank Microservices Platform

A comprehensive microservices-based banking application built with Spring Boot, featuring complete infrastructure services, observability stack, and cloud-native deployment capabilities.

## 🏗️ Architecture Overview

This project implements a production-ready microservices architecture with the following components:

### Core Business Services
- **Accounts Service** (Port: 8080) - Customer account management and core banking operations
- **Cards Service** (Port: 9000) - Credit/debit card operations and lifecycle management
- **Loans Service** (Port: 8090) - Loan applications, approvals, and portfolio management

### Infrastructure Services
- **Config Server** (Port: 8071) - Centralized configuration management with Git backend
- **Eureka Server** (Port: 8761) - Service discovery and registry
- **Gateway Server** (Port: 8072) - API gateway with routing, load balancing, and security
- **Angular UI** (Account Status) - Frontend application for account management

### Data Layer
- **MySQL Databases** - Dedicated databases for each microservice
  - AccountsDB (Port: 3306)
  - LoansDB (Port: 3307) 
  - CardsDB (Port: 3308)
- **RabbitMQ** (Port: 5672/15672) - Message broker for async communication
- **MinIO** (Port: 9001) - S3-compatible object storage for logs and data

### Observability Stack
- **Prometheus** - Metrics collection and monitoring
- **Grafana** - Visualization and dashboards
- **Loki** - Log aggregation and analysis
- **Tempo** - Distributed tracing
- **Alloy** - Telemetry data collection agent

## 🚀 Technology Stack

### Backend Technologies
- **Java 21** - Latest LTS version with modern features
- **Spring Boot 3.x** - Application framework
- **Spring Cloud** - Microservices ecosystem
  - Spring Cloud Config
  - Spring Cloud Netflix Eureka
  - Spring Cloud Gateway
  - Spring Cloud OpenFeign
- **Spring Data JPA** - Data persistence layer
- **Spring Boot Actuator** - Production monitoring
- **MySQL** - Production database
- **RabbitMQ** - Message queuing

### DevOps & Deployment
- **Docker** - Containerization
- **Docker Compose** - Multi-container orchestration
- **Kubernetes** - Container orchestration (production)
- **Maven** - Build automation and dependency management
- **GitHub Actions** - CI/CD pipeline

### Observability & Monitoring
- **Prometheus** - Metrics and alerting
- **Grafana** - Monitoring dashboards
- **Loki** - Log aggregation
- **Tempo** - Distributed tracing
- **Alloy** - Telemetry collection
- **MinIO** - Object storage for observability data

### Frontend
- **Angular** - Modern web application framework
- **TypeScript** - Type-safe JavaScript
- **Nginx** - Web server and reverse proxy

## 📁 Project Structure

```
EazyBank/
├── accounts/                    # Account management microservice
├── cards/                      # Card management microservice  
├── loans/                      # Loan management microservice
├── configserver/               # Centralized configuration server
├── eurekaserver/              # Service discovery server
├── gatewayserver/             # API gateway service
├── account-status/            # Angular frontend application
├── docker-compose/            # Docker deployment configurations
│   ├── default/              # Default environment setup
│   ├── qa/                   # QA environment configuration
│   ├── prod/                 # Production environment setup
│   └── observability/        # Monitoring stack setup
│       ├── prometheus/       # Prometheus configuration
│       ├── grafana/         # Grafana dashboards and config
│       ├── loki/            # Loki configuration
│       ├── tempo/           # Tempo tracing setup
│       └── alloy/           # Alloy agent configuration
├── config-files-for-github/   # External configuration files
└── Microservices.postman_collection.json
```

## 🔧 Getting Started

### Prerequisites
- **Java 21** or higher
- **Maven 3.8+**
- **Docker & Docker Compose**
- **Node.js 18+** (for Angular frontend)
- **Git**

### Quick Start with Docker Compose

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd EazyBank
   ```

2. **Start the complete stack**
   ```bash
   # Default environment (development)
   cd docker-compose/default
   docker-compose up -d
   
   # With observability stack
   cd docker-compose/observability
   docker-compose up -d
   ```

3. **Verify services are running**
   ```bash
   docker-compose ps
   ```

### Environment-Specific Deployments

**QA Environment:**
```bash
cd docker-compose/qa
docker-compose up -d
```

**Production Environment:**
```bash
cd docker-compose/prod
docker-compose up -d
```

### Local Development Setup

1. **Start infrastructure services first**
   ```bash
   cd configserver && mvn spring-boot:run
   cd eurekaserver && mvn spring-boot:run
   cd gatewayserver && mvn spring-boot:run
   ```

2. **Start business services**
   ```bash
   cd accounts && mvn spring-boot:run
   cd cards && mvn spring-boot:run
   cd loans && mvn spring-boot:run
   ```

3. **Start Angular frontend**
   ```bash
   cd account-status
   npm install
   ng serve
   ```

## 🌐 Service Endpoints & Ports

### Infrastructure Services
- **Config Server**: http://localhost:8071
- **Eureka Dashboard**: http://localhost:8761
- **API Gateway**: http://localhost:8072
- **Angular UI**: http://localhost:4200

### Business Services (via Gateway)
- **Accounts API**: http://localhost:8072/eazybank/accounts/api/
- **Cards API**: http://localhost:8072/eazybank/cards/api/
- **Loans API**: http://localhost:8072/eazybank/loans/api/

### Direct Service Access (Development)
- **Accounts**: http://localhost:8080/api/
- **Cards**: http://localhost:9000/api/
- **Loans**: http://localhost:8090/api/

### Monitoring & Observability
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000
- **RabbitMQ Management**: http://localhost:15672
- **MinIO Console**: http://localhost:9001

## 📊 API Documentation

Each service provides comprehensive OpenAPI documentation:

- **Accounts**: http://localhost:8080/swagger-ui.html
- **Cards**: http://localhost:9000/swagger-ui.html  
- **Loans**: http://localhost:8090/swagger-ui.html
- **Gateway**: http://localhost:8072/swagger-ui.html

## 🔍 Monitoring & Observability

### Metrics Collection
- All services expose Prometheus metrics at `/actuator/prometheus`
- Custom business metrics and SLAs tracking
- Real-time performance monitoring

### Logging
- Centralized logging with Loki
- Structured JSON logging across all services
- Log correlation with trace IDs

### Distributed Tracing
- End-to-end request tracing with Tempo
- Service dependency mapping
- Performance bottleneck identification

### Dashboards
- Pre-configured Grafana dashboards for:
  - Application metrics
  - Infrastructure monitoring  
  - Business KPIs
  - Error tracking and alerting

## 🔐 Configuration Management

### Centralized Configuration
- **Git-based config**: External configuration repository
- **Environment-specific**: Separate configs for dev/qa/prod
- **Dynamic refresh**: Runtime configuration updates
- **Encryption support**: Sensitive data protection

### Configuration Files Structure
```
config-files-for-github/
├── accounts.yml              # Default accounts config
├── accounts-qa.yml          # QA environment
├── accounts-prod.yml        # Production environment
├── cards.yml / cards-qa.yml / cards-prod.yml
├── loans.yml / loans-qa.yml / loans-prod.yml
├── eurekaserver.yml
└── gatewayserver.yml
```

## 🚀 Deployment Strategies

### Development
- Local Maven builds
- H2 in-memory databases
- Embedded service discovery

### QA/Staging  
- Docker containerization
- MySQL databases
- Full observability stack

### Production
- Kubernetes orchestration
- High availability setup
- Auto-scaling capabilities
- Security hardening

## 🧪 Testing

### API Testing
Use the included Postman collection:
1. Import `Microservices.postman_collection.json`
2. Configure environment variables
3. Test all service endpoints

### Load Testing
- Prometheus metrics for performance monitoring
- Grafana dashboards for real-time analysis
- Distributed tracing for bottleneck identification

## 📈 Business Features

### Account Management
- Customer onboarding
- Account creation and management
- Transaction processing
- Account statements

### Card Services
- Card issuance and activation
- Transaction processing
- Limit management
- Fraud detection integration

### Loan Services
- Loan application processing
- Credit scoring integration
- Repayment scheduling
- Portfolio management

## 🔄 Communication Patterns

### Synchronous Communication
- **REST APIs** for real-time operations
- **OpenFeign** for service-to-service calls
- **Circuit Breaker** pattern for resilience

### Asynchronous Communication
- **RabbitMQ** for event-driven processing
- **Event sourcing** for audit trails
- **CQRS** pattern implementation

## 🛡️ Security & Compliance

### Security Features
- API Gateway security policies
- Service-to-service authentication
- Input validation and sanitization
- Audit logging for compliance

### Data Protection
- Database encryption at rest
- Secure communication (TLS)
- PII data handling compliance
- GDPR compliance features

## 📱 Frontend Application

The Angular-based account status application provides:
- Real-time account information
- Transaction history
- Card and loan status
- Responsive design for mobile/desktop

## 🔧 Development Guidelines

### Microservice Design Principles
- **Single Responsibility**: Each service owns its domain
- **Database per Service**: Data isolation and independence  
- **API-First Design**: Contract-driven development
- **Fault Tolerance**: Circuit breakers and fallback mechanisms

### Code Quality
- **Clean Architecture**: Separation of concerns
- **SOLID Principles**: Maintainable code structure
- **Testing Strategy**: Unit, integration, and contract testing
- **Code Documentation**: Comprehensive API documentation

## 🚀 Production Deployment

### Kubernetes Deployment
```bash
# Deploy to Kubernetes cluster
kubectl apply -f k8s/
```

### Health Checks & Monitoring
- Kubernetes readiness/liveness probes
- Prometheus metrics collection
- Grafana alerting rules
- Log aggregation with Loki

## 📞 Support & Maintenance

### Troubleshooting
- Check service health: `/actuator/health`
- View metrics: `/actuator/prometheus`
- Access logs through Grafana/Loki
- Distributed tracing via Tempo

### Performance Tuning
- JVM optimization parameters
- Database connection pooling
- Caching strategies
- Load balancing configuration

## 📄 License

This project is designed for educational purposes as part of a comprehensive microservices learning curriculum.

---

**🏦 Built with modern microservices architecture for scalable banking solutions**
