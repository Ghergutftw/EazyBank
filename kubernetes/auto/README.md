# Kubernetes Manifests for EazyBank Microservices

This folder contains auto-generated Kubernetes manifests for all microservices in the EazyBank application.

## Deployment Order

Deploy the manifests in the following order to ensure proper dependencies:

1. **ConfigMap** (must be deployed first)
   ```bash
   kubectl apply -f 1_configmap.yaml
   ```

2. **Infrastructure Components**
   ```bash
   kubectl apply -f 2_mysql-databases.yaml
   kubectl apply -f 3_rabbitmq.yaml
   kubectl apply -f 18_kafka.yaml
   kubectl apply -f 11_minio.yaml
   ```

3. **Config Server**
   ```bash
   kubectl apply -f 4_configserver.yaml
   ```

4. **Eureka Server**
   ```bash
   kubectl apply -f 5_eurekaserver.yaml
   ```

5. **Microservices**
   ```bash
   kubectl apply -f 6_accounts.yaml
   kubectl apply -f 7_loans.yaml
   kubectl apply -f 8_cards.yaml
   kubectl apply -f 10_message.yaml
   ```

6. **Gateway Server**
   ```bash
   kubectl apply -f 9_gatewayserver.yaml
   ```

7. **Observability Stack** (optional)
   ```bash
   kubectl apply -f 12_loki.yaml
   kubectl apply -f 13_prometheus.yaml
   kubectl apply -f 14_tempo.yaml
   kubectl apply -f 15_alloy.yaml
   kubectl apply -f 16_grafana.yaml
   ```

8. **Keycloak** (optional, for authentication)
   ```bash
   kubectl apply -f 17_keycloak.yaml
   ```

## Quick Deploy All

To deploy everything at once:
```bash
kubectl apply -f .
```

**Note:** This may cause some pods to restart as dependencies become available.

## Access Services

### LoadBalancer Services (exposed externally):
- **Accounts Service**: `http://<external-ip>:8080`
- **Loans Service**: `http://<external-ip>:8090`
- **Cards Service**: `http://<external-ip>:9000`
- **Gateway Server**: `http://<external-ip>:8072`
- **Grafana**: `http://<external-ip>:3000` (admin/admin)
- **Keycloak**: `http://<external-ip>:7080` (admin/admin)

### ClusterIP Services (internal only):
- Config Server: `http://configserver:8071`
- Eureka Server: `http://eurekaserver:8761`
- RabbitMQ: `http://rabbitmq:15672`
- Kafka: `kafka:9092`
- Prometheus: `http://prometheus:9090`
- Tempo: `http://tempo:4318`
- Loki Gateway: `http://gateway:3100`

## Verify Deployment

Check pod status:
```bash
kubectl get pods
```

Check services:
```bash
kubectl get services
```

Check logs for a specific pod:
```bash
kubectl logs <pod-name>
```

## Configuration

All environment variables are managed through the `eazybank-configmap` ConfigMap. To modify configurations:

1. Edit `1_configmap.yaml`
2. Apply changes:
   ```bash
   kubectl apply -f 1_configmap.yaml
   ```
3. Restart affected pods:
   ```bash
   kubectl rollout restart deployment/<deployment-name>
   ```

### Enabling OpenTelemetry (Optional)

OpenTelemetry is **disabled by default** to avoid connection errors when the observability stack is not deployed.

To enable OpenTelemetry tracing:

1. Deploy the observability stack first (Tempo, Prometheus, Loki, Grafana)
2. Uncomment the OpenTelemetry lines in `1_configmap.yaml`:
   ```yaml
   # OpenTelemetry
   JAVA_TOOL_OPTIONS: "-javaagent:/app/libs/opentelemetry-javaagent-2.11.0.jar"
   OTEL_EXPORTER_OTLP_ENDPOINT: "http://tempo:4318"
   OTEL_METRICS_EXPORTER: "none"
   OTEL_LOGS_EXPORTER: "none"
   ```
3. Re-add the environment variable references to each microservice deployment (configserver, eurekaserver, accounts, loans, cards, gatewayserver)
4. Apply changes and restart services:
   ```bash
   kubectl apply -f 1_configmap.yaml
   kubectl rollout restart deployment/configserver
   kubectl rollout restart deployment/eurekaserver
   kubectl rollout restart deployment/accounts
   kubectl rollout restart deployment/loans
   kubectl rollout restart deployment/cards
   kubectl rollout restart deployment/gatewayserver
   ```

## Cleanup

To remove all resources:
```bash
kubectl delete -f .
```

Or remove specific components:
```bash
kubectl delete -f 6_accounts.yaml
```

## Notes

- All Spring Boot microservices use OpenTelemetry for distributed tracing
- Memory limit is set to 700Mi for Spring Boot applications
- Health checks are configured for all services
- PersistentVolumes are not used (using emptyDir for simplicity); consider adding PVCs for production
- Docker socket mounting in Alloy may require additional permissions depending on your cluster configuration

## Architecture

```
┌─────────────┐
│   Keycloak  │
└─────────────┘
       │
┌──────▼────────────────────────────────────────┐
│              Gateway Server                    │
└──────┬────────────────────────────────────────┘
       │
   ┌───┴────┬──────────┬──────────┐
   │        │          │          │
┌──▼───┐ ┌─▼────┐ ┌───▼───┐ ┌───▼────┐
│Accounts│ │Loans│ │ Cards │ │Message │
└──┬───┘ └─┬────┘ └───┬───┘ └───┬────┘
   │       │          │          │
┌──▼───┐ ┌─▼────┐ ┌───▼───┐     │
│AccDB │ │LoansDB│ │CardsDB│    │
└──────┘ └──────┘ └───────┘     │
                                 │
         ┌──────────────────────┼────────────┐
         │                      │            │
    ┌────▼────┐           ┌────▼────┐  ┌───▼────┐
    │RabbitMQ │           │  Kafka  │  │ MinIO  │
    └─────────┘           └─────────┘  └────────┘

Observability Stack:
┌─────────┐  ┌──────────┐  ┌──────┐  ┌───────┐
│ Grafana │◄─┤Prometheus│◄─┤ Tempo│◄─┤ Alloy │
└─────────┘  └──────────┘  └──────┘  └───────┘
     ▲                                     ▲
     │           ┌──────────┐             │
     └───────────┤   Loki   │◄────────────┘
                 └──────────┘
```

