# EazyBank Microservices Helm Chart

This Helm chart deploys the complete EazyBank microservices platform on Kubernetes, following industry best practices and the 12-factor app methodology.

## 🏗️ Architecture

The EazyBank platform consists of:

### Infrastructure Layer
- **RabbitMQ**: Message broker for asynchronous communication
- **MySQL Databases**: Separate databases for accounts, loans, and cards (database per service pattern)

### Spring Cloud Infrastructure
- **Config Server**: Centralized configuration management
- **Gateway Server**: API Gateway with routing, rate limiting, and circuit breaking

### Business Microservices
- **Accounts Service**: Customer account management
- **Loans Service**: Loan application and management
- **Cards Service**: Credit/debit card operations
- **Message Service**: Asynchronous message processing

### Observability Stack (Optional)
- MinIO, Loki, Prometheus, Tempo, Grafana Alloy, Grafana
- Keycloak for IAM
- Kafka for event streaming

## 📋 Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- kubectl configured to access your cluster
- Sufficient cluster resources (minimum 8GB RAM, 4 CPUs)

## 🚀 Installation

### Quick Start (Default Configuration)

```bash
# Install the chart with default values
helm install eazybank ./helm/eazybank

# Or with a custom release name
helm install my-banking-app ./helm/eazybank
```

### Install in a Specific Namespace

```bash
# Create namespace
kubectl create namespace banking

# Install chart
helm install eazybank ./helm/eazybank --namespace banking
```

### Install with Custom Values

```bash
# Use a custom values file
helm install eazybank ./helm/eazybank -f my-values.yaml

# Or set specific values
helm install eazybank ./helm/eazybank \
  --set config.springProfilesActive=qa \
  --set gatewayserver.service.type=NodePort \
  --set accounts.replicaCount=2
```

## ⚙️ Configuration

### Common Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.imagePullPolicy` | Image pull policy for all containers | `Always` |
| `global.imageRegistry` | Container registry prefix | `""` |
| `config.springProfilesActive` | Spring profile (default, qa, prod) | `default` |
| `config.mysql.rootPassword` | MySQL root password | `root` |

### Microservice Configuration

Each microservice can be configured independently:

```yaml
accounts:
  enabled: true
  replicaCount: 1
  image:
    repository: ghergutmadalin/accounts
    tag: latest
  resources:
    limits:
      memory: "700Mi"
    requests:
      memory: "512Mi"
      cpu: "250m"
```

### Environment-Specific Configurations

#### Development Environment
```bash
helm install eazybank ./helm/eazybank \
  --set config.springProfilesActive=default \
  --set gatewayserver.service.type=NodePort
```

#### Production Environment
```bash
helm install eazybank ./helm/eazybank \
  --set config.springProfilesActive=prod \
  --set gatewayserver.service.type=LoadBalancer \
  --set gatewayserver.ingress.enabled=true \
  --set accounts.replicaCount=3 \
  --set loans.replicaCount=3 \
  --set cards.replicaCount=3
```

## 🔄 Upgrade

```bash
# Upgrade with new values
helm upgrade eazybank ./helm/eazybank

# Upgrade with specific values
helm upgrade eazybank ./helm/eazybank --set accounts.replicaCount=3

# Upgrade with a new values file
helm upgrade eazybank ./helm/eazybank -f production-values.yaml
```

## 🗑️ Uninstallation

```bash
# Uninstall the release
helm uninstall eazybank

# Uninstall from specific namespace
helm uninstall eazybank --namespace banking
```

## 📊 Monitoring and Debugging

### Check Deployment Status

```bash
# Get all Helm releases
helm list

# Get detailed status
helm status eazybank

# Check pod status
kubectl get pods

# Check services
kubectl get services
```

### View Logs

```bash
# View logs for a specific service
kubectl logs -f deployment/accounts

# View logs with label selector
kubectl logs -l app=accounts

# View logs from all containers in a pod
kubectl logs -f pod/accounts-xxxxx --all-containers
```

### Debugging Issues

```bash
# Describe a failing pod
kubectl describe pod accounts-xxxxx

# Get events
kubectl get events --sort-by='.lastTimestamp'

# Check ConfigMap
kubectl get configmap eazybank-config -o yaml

# Port forward for local testing
kubectl port-forward svc/gatewayserver 8072:8072
```

## 🎯 Advanced Features

### Using Ingress for Production

Enable Ingress for production environments:

```yaml
gatewayserver:
  service:
    type: ClusterIP  # Change from LoadBalancer
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
    hosts:
      - host: api.eazybank.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: gateway-tls
        hosts:
          - api.eazybank.com
```

### Enabling Observability Stack

```bash
helm upgrade eazybank ./helm/eazybank \
  --set config.observability.enabled=true \
  --set prometheus.enabled=true \
  --set grafana.enabled=true \
  --set loki.enabled=true \
  --set tempo.enabled=true
```

### Horizontal Pod Autoscaling

Create HPA for microservices:

```bash
kubectl autoscale deployment accounts \
  --cpu-percent=70 \
  --min=2 \
  --max=10
```

### Using Private Container Registry

```bash
helm install eazybank ./helm/eazybank \
  --set global.imageRegistry=myregistry.azurecr.io \
  --set global.imagePullSecrets[0].name=regcred
```

## 🔐 Security Considerations

### Production Security Checklist

1. **Secrets Management**: Use Kubernetes Secrets or external secret managers
   ```bash
   kubectl create secret generic mysql-secret \
     --from-literal=root-password=<strong-password>
   ```

2. **Network Policies**: Restrict pod-to-pod communication
3. **RBAC**: Configure proper service accounts and roles
4. **TLS**: Enable TLS for all external communications
5. **Image Scanning**: Scan container images for vulnerabilities
6. **Resource Limits**: Always set resource limits in production

### Using External Secrets

Modify values to use Kubernetes Secrets:

```yaml
config:
  mysql:
    rootPasswordSecret:
      name: mysql-secret
      key: root-password
```

## 📝 Customization Guide

### Creating Environment-Specific Values Files

**values-dev.yaml**:
```yaml
config:
  springProfilesActive: "default"
gatewayserver:
  service:
    type: NodePort
accounts:
  replicaCount: 1
```

**values-prod.yaml**:
```yaml
config:
  springProfilesActive: "prod"
gatewayserver:
  service:
    type: ClusterIP
  ingress:
    enabled: true
accounts:
  replicaCount: 3
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
```

### Disabling Components

Disable optional components:

```bash
helm install eazybank ./helm/eazybank \
  --set message.enabled=false \
  --set mysql.cardsdb.enabled=false
```

## 🏭 CI/CD Integration

### GitLab CI Example

```yaml
deploy:
  stage: deploy
  script:
    - helm upgrade --install eazybank ./helm/eazybank 
      --namespace production 
      --values helm/eazybank/values-prod.yaml
      --wait
```

### GitHub Actions Example

```yaml
- name: Deploy with Helm
  run: |
    helm upgrade --install eazybank ./helm/eazybank \
      --namespace production \
      --values helm/eazybank/values-prod.yaml \
      --wait
```

## 🧪 Testing

### Template Rendering

Test template rendering without installation:

```bash
# Render all templates
helm template eazybank ./helm/eazybank

# Render with specific values
helm template eazybank ./helm/eazybank -f values-prod.yaml

# Debug mode
helm install eazybank ./helm/eazybank --dry-run --debug
```

### Validation

```bash
# Lint the chart
helm lint ./helm/eazybank

# Validate against Kubernetes API
helm install eazybank ./helm/eazybank --dry-run --validate
```

## 📚 Architecture Decisions

### Why These Patterns?

1. **Database per Service**: Each microservice has its own database for loose coupling
2. **Named Templates**: DRY principle for reusable Helm template snippets
3. **ConfigMaps**: Externalized configuration following 12-factor app
4. **Health Checks**: Liveness and readiness probes for reliability
5. **Resource Limits**: Prevent resource exhaustion in multi-tenant clusters
6. **Labels**: Kubernetes recommended labels for better organization

### Helm Best Practices Applied

- ✅ Semantic versioning in Chart.yaml
- ✅ Comprehensive values.yaml with comments
- ✅ Named templates in \_helpers.tpl
- ✅ Conditional resource rendering
- ✅ NOTES.txt for post-installation guidance
- ✅ Resource labels and annotations
- ✅ Configurable via values
- ✅ No hardcoded values in templates

## 🤝 Contributing

To extend this chart:

1. Add new template in `templates/` directory
2. Add configuration in `values.yaml`
3. Update documentation in README.md
4. Test with `helm lint` and `helm template`
5. Validate with dry-run: `helm install --dry-run`

## 📄 License

This Helm chart is provided as-is for educational and production use.

## 🆘 Support

For issues and questions:
- Check NOTES.txt after installation
- Review values.yaml for configuration options
- Check pod logs: `kubectl logs <pod-name>`
- Describe resources: `kubectl describe <resource>`

## 🔗 Related Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Spring Cloud Documentation](https://spring.io/projects/spring-cloud)
- [12-Factor App](https://12factor.net/)

