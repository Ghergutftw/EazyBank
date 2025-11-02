# Kubernetes Manifests - Summary

## ✅ Successfully Created Files

### Configuration
- **1_configmap.yaml** - Central ConfigMap with all environment variables

### Infrastructure (3 MySQL databases + messaging)
- **2_mysql-databases.yaml** - MySQL databases (accountsdb, loansdb, cardsdb)
- **3_rabbitmq.yaml** - RabbitMQ message broker
- **18_kafka.yaml** - Apache Kafka message streaming

### Core Microservices Framework
- **4_configserver.yaml** - Spring Cloud Config Server
- **5_eurekaserver.yaml** - Eureka Service Discovery

### Business Microservices
- **6_accounts.yaml** - Accounts microservice (LoadBalancer on port 8080)
- **7_loans.yaml** - Loans microservice (LoadBalancer on port 8090)
- **8_cards.yaml** - Cards microservice (LoadBalancer on port 9000)
- **10_message.yaml** - Message microservice (ClusterIP on port 9010)

### API Gateway
- **9_gatewayserver.yaml** - Spring Cloud Gateway (LoadBalancer on port 8072)

### Observability Stack
- **11_minio.yaml** - MinIO object storage
- **12_loki.yaml** - Loki log aggregation (read, write, backend, gateway)
- **13_prometheus.yaml** - Prometheus metrics
- **14_tempo.yaml** - Tempo distributed tracing
- **15_alloy.yaml** - Grafana Alloy agent
- **16_grafana.yaml** - Grafana dashboards (LoadBalancer on port 3000)

### Security
- **17_keycloak.yaml** - Keycloak authentication (LoadBalancer on port 7080)

### Utilities
- **deploy.bat** - Automated deployment script for Windows
- **deploy.sh** - Automated deployment script for Linux/Mac
- **cleanup.bat** - Cleanup script for Windows
- **README.md** - Complete documentation

---

## 📊 Total Resources Created

- **19 YAML manifest files**
- **20 Deployments** (including 3 MySQL, multiple Loki components)
- **20 Services**
- **1 ConfigMap** (centralized configuration)
- **3 Scripts** (2 deploy + 1 cleanup)
- **1 Documentation file**

---

## 🚀 Quick Start

### For Windows:
```cmd
cd kubernetes\auto
deploy.bat
```

### For Linux/Mac:
```bash
cd kubernetes/auto
chmod +x deploy.sh
./deploy.sh
```

### Manual Deployment:
```bash
kubectl apply -f 1_configmap.yaml
kubectl apply -f 2_mysql-databases.yaml
kubectl apply -f 3_rabbitmq.yaml
kubectl apply -f 18_kafka.yaml
kubectl apply -f 4_configserver.yaml
kubectl apply -f 5_eurekaserver.yaml
kubectl apply -f 6_accounts.yaml
kubectl apply -f 7_loans.yaml
kubectl apply -f 8_cards.yaml
kubectl apply -f 10_message.yaml
kubectl apply -f 9_gatewayserver.yaml
# Optional: Observability stack
kubectl apply -f 11_minio.yaml
kubectl apply -f 12_loki.yaml
kubectl apply -f 13_prometheus.yaml
kubectl apply -f 14_tempo.yaml
kubectl apply -f 15_alloy.yaml
kubectl apply -f 16_grafana.yaml
# Optional: Security
kubectl apply -f 17_keycloak.yaml
```

---

## 🔑 Key Features

### ✅ Pattern Compliance
- Each microservice has **Deployment + Service** in the same YAML file
- All environment variables in **centralized ConfigMap**
- Follows numbered naming convention for ordered deployment

### ✅ Configuration Management
- Environment variables managed via ConfigMap references
- Easy to update configurations centrally
- Consistent configuration across all services

### ✅ Service Discovery
- ClusterIP for internal services (databases, config server, eureka)
- LoadBalancer for externally accessible services (gateway, microservices, grafana)
- Proper DNS resolution via Kubernetes services

### ✅ Health Checks
- Liveness and readiness probes configured
- MySQL health checks using mysqladmin
- HTTP health checks for Spring Boot applications
- RabbitMQ diagnostics checks

### ✅ Resource Management
- Memory limits set to 700Mi for Spring Boot apps
- Resource quotas can be adjusted per service

### ✅ Observability
- OpenTelemetry integration for distributed tracing
- Prometheus for metrics collection
- Loki for log aggregation
- Grafana for visualization
- Tempo for trace storage

---

## 📝 Image References

All images are pulled from Docker Hub using the `ghergutmadalin` account:
- `ghergutmadalin/configserver:latest`
- `ghergutmadalin/eurekaserver:latest`
- `ghergutmadalin/accounts:latest`
- `ghergutmadalin/loans:latest`
- `ghergutmadalin/cards:latest`
- `ghergutmadalin/gatewayserver:latest`
- `ghergutmadalin/message:latest`

Public images used:
- `mysql:8.0`
- `rabbitmq:3.13-management`
- `apache/kafka:4.1.0`
- `grafana/loki:3.2.0`
- `grafana/tempo:2.6.0`
- `prom/prometheus:v2.54.1`
- `grafana/grafana:11.2.2`
- `grafana/alloy:v1.4.0`
- `minio/minio:RELEASE.2024-12-18T13-15-44Z`
- `quay.io/keycloak/keycloak:26.4.0`

---

## 🎯 Access Points (after deployment)

Get external IPs:
```bash
kubectl get services --field-selector spec.type=LoadBalancer
```

Default ports:
- **Gateway**: 8072 (main entry point)
- **Accounts**: 8080
- **Loans**: 8090
- **Cards**: 9000
- **Grafana**: 3000 (admin/admin)
- **Keycloak**: 7080 (admin/admin)

---

## ⚠️ Important Notes

1. **OpenTelemetry**: **DISABLED BY DEFAULT** to avoid connection errors. Enable only after deploying observability stack
2. **Storage**: Using `emptyDir` volumes (ephemeral). For production, replace with PersistentVolumeClaims
3. **Secrets**: Passwords are in ConfigMap. For production, use Kubernetes Secrets
4. **LoadBalancer**: Requires cloud provider or MetalLB for on-premises
5. **Dependencies**: Scripts include wait times for proper startup sequencing
6. **Docker Socket**: Alloy mounts Docker socket - may need privileges on some clusters

---

## 🧹 Cleanup

### Windows:
```cmd
cleanup.bat
```

### Linux/Mac:
```bash
kubectl delete -f .
```

---

## ✨ Next Steps

1. Deploy the manifests using the deployment script
2. Verify all pods are running: `kubectl get pods`
3. Get external IPs: `kubectl get svc`
4. Access Gateway Server and test endpoints
5. Monitor via Grafana dashboards
6. Configure Keycloak realms and clients as needed

---

Generated on: November 2, 2025

