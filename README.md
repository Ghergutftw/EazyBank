# Eazybank Microservices

A comprehensive microservices-based banking application built with Spring Boot, demonstrating modern banking operations including account management, cards, and loans services.

## 🏗️ Architecture

This project follows a microservices architecture pattern with the following services:

- **Accounts Service** - Manages customer accounts and core banking operations
- **Cards Service** - Handles credit/debit card operations and management
- **Loans Service** - Manages loan applications, approvals, and tracking

## 🚀 Technologies Used

- **Java 21**
- **Spring Boot 3.x**
- **Spring Data JPA**
- **Spring Boot Actuator**
- **H2 Database** (for development/testing)
- **Maven** (for dependency management)
- **Lombok** (for reducing boilerplate code)
- **SpringDoc OpenAPI** (for API documentation)
- **Docker** (for containerization)
- **Kubernetes** (for orchestration)

## 📁 Project Structure

```
Eazybank/
├── accounts/          # Account management microservice
├── cards/            # Card management microservice
├── loans/            # Loan management microservice
├── pom.xml           # Parent POM configuration
├── start-all-services.bat  # Utility script to start all services
└── Microservices.postman_collection.json  # Postman collection for API testing
```

### Individual Microservice Structure

Each microservice follows a standard Spring Boot structure:

```
service-name/
├── src/main/java/com/eazybytes/[service]/
│   ├── audit/        # Audit configuration
│   ├── constants/    # Application constants
│   ├── controller/   # REST controllers
│   ├── dto/          # Data Transfer Objects
│   ├── entity/       # JPA entities
│   ├── exception/    # Custom exceptions
│   ├── mapper/       # Entity-DTO mappers
│   ├── repository/   # Data access repositories
│   └── service/      # Business logic services
├── src/main/resources/
│   ├── application.yml  # Configuration
│   └── schema.sql      # Database schema
└── pom.xml
```

## 🔧 Getting Started

### Prerequisites

- Java 21 or higher
- Maven 3.6+ 
- Docker (optional, for containerization)
- Git

### Installation & Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Eazybank
   ```

2. **Build all services**
   ```bash
   mvn clean install
   ```

3. **Start individual services**

   **Accounts Service:**
   ```bash
   cd accounts
   mvn spring-boot:run
   ```

   **Cards Service:**
   ```bash
   cd cards
   mvn spring-boot:run
   ```

   **Loans Service:**
   ```bash
   cd loans
   mvn spring-boot:run
   ```

4. **Or use the batch script (Windows)**
   ```bash
   start-all-services.bat
   ```

## 🌐 API Endpoints

### Accounts Service (Port: 8080)

- `POST /api/create` - Create a new customer account
- `GET /api/fetch?mobileNumber={mobile}` - Fetch account details
- `PUT /api/update` - Update account information
- `DELETE /api/delete?mobileNumber={mobile}` - Delete account

### Cards Service (Port: 9000)

- `POST /api/create?mobileNumber={mobile}` - Create a new card
- `GET /api/fetch?mobileNumber={mobile}` - Fetch card details
- `PUT /api/update` - Update card information
- `DELETE /api/delete?mobileNumber={mobile}` - Delete card

### Loans Service (Port: 8090)

- `POST /api/create?mobileNumber={mobile}` - Create a new loan
- `GET /api/fetch?mobileNumber={mobile}` - Fetch loan details
- `PUT /api/update` - Update loan information
- `DELETE /api/delete?mobileNumber={mobile}` - Delete loan

## 📊 Monitoring & Health Checks

Each service includes Spring Boot Actuator endpoints for monitoring:

- `/actuator/health` - Health check endpoint
- `/actuator/info` - Application information
- `/actuator/metrics` - Application metrics

## 📚 API Documentation

Each service provides OpenAPI documentation accessible at:

- **Accounts**: `http://localhost:8080/swagger-ui.html`
- **Cards**: `http://localhost:9000/swagger-ui.html`
- **Loans**: `http://localhost:8090/swagger-ui.html`

## 🗄️ Database

The application uses H2 in-memory database for development and testing. Each service maintains its own database instance:

- **Accounts DB**: Stores customer and account information
- **Cards DB**: Stores card-related data
- **Loans DB**: Stores loan information

### Database Schema

Each service includes a `schema.sql` file that automatically creates the required tables on startup.

## 🔐 Security & Auditing

The application includes:

- **JPA Auditing**: Automatic tracking of creation and modification timestamps
- **Custom Auditor**: `AuditAwareImpl` provides audit information for each service
- **Data Validation**: Input validation using Bean Validation annotations

## 🐳 Docker Support

The project is containerization-ready with Docker support. Each microservice can be containerized and deployed using Docker and Kubernetes.

## 🧪 Testing

Use the included Postman collection (`Microservices.postman_collection.json`) to test all API endpoints:

1. Import the collection into Postman
2. Ensure all services are running
3. Execute the requests to test functionality

## 🛠️ Development Guidelines

### Code Structure

- **Controllers**: Handle HTTP requests and responses
- **Services**: Contain business logic
- **Repositories**: Data access layer using Spring Data JPA
- **DTOs**: Data transfer objects for API communication
- **Entities**: JPA entities representing database tables
- **Mappers**: Convert between entities and DTOs

### Best Practices

- Each microservice is independently deployable
- Services communicate through well-defined APIs
- Database per service pattern is followed
- Proper error handling and custom exceptions
- Comprehensive logging and monitoring

## 🚀 Deployment

### Local Development
```bash
# Build all services
mvn clean install

# Run services (each in separate terminal)
cd accounts && mvn spring-boot:run
cd cards && mvn spring-boot:run
cd loans && mvn spring-boot:run
```

### Production Deployment
Refer to the included documentation for Docker and Kubernetes deployment strategies.

## 📞 Support

For questions and support, please refer to the project documentation or create an issue in the repository.

## 📄 License

This project is part of a microservices learning curriculum and is intended for educational purposes.

---

**Built with ❤️ using Spring Boot and Microservices Architecture**
