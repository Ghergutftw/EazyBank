# Environment Configuration Guide

This guide explains how to work with different environment configurations (dev, qa, prod) for the EazyBank Helm chart.

## 📋 Overview

The Helm chart supports multiple environments through values files:
- **`values.yaml`** - Base/default configuration
- **`values-dev.yaml`** - Development environment overrides
- **`values-qa.yaml`** - QA/staging environment overrides
- **`values-prod.yaml`** - Production environment overrides

## 🚀 How to Deploy Different Environments

### 1. Development Environment

```bash
# Install with dev configuration
helm install eazybank eazybank -f eazybank/values-dev.yaml -n default

# Upgrade with dev configuration
helm upgrade eazybank eazybank -f eazybank/values-dev.yaml -n default
```

**Dev Environment Features:**
- Spring Profile: `default`
- Gateway Service: `NodePort` (easier for local access)
- Replicas: 1 for all services
- Lower resource limits (512Mi memory, 256Mi requests)
- Good for: Local development, testing on Docker Desktop/Minikube

### 2. QA Environment

```bash
# Install with QA configuration
helm install eazybank eazybank -f eazybank/values-qa.yaml -n qa

# Upgrade with QA configuration
helm upgrade eazybank eazybank -f eazybank/values-qa.yaml -n qa
```

**QA Environment Features:**
- Spring Profile: `qa`
- Gateway Service: `ClusterIP` with Ingress
- Replicas: 2 for all microservices (for load testing)
- Standard resource limits (700Mi memory, 512Mi requests)
- Ingress: `qa-api.eazybank.com`
- Good for: Integration testing, performance testing, UAT

### 3. Production Environment

```bash
# Install with Production configuration
helm install eazybank eazybank -f eazybank/values-prod.yaml -n production

# Upgrade with Production configuration
helm upgrade eazybank eazybank -f eazybank/values-prod.yaml -n production
```

**Production Environment Features:**
- Spring Profile: `prod`
- Gateway Service: `LoadBalancer` (or Ingress with TLS)
- Replicas: 3 for high availability
- Higher resource limits (1Gi memory, 768Mi requests)
- TLS enabled with cert-manager
- Rate limiting enabled on Ingress
- Good for: Production workloads

## 🔧 How to Override Specific Values

### Method 1: Using Multiple Values Files

You can combine multiple values files to layer configurations:

```bash
# Base + Dev + Custom overrides
helm upgrade eazybank eazybank \
  -f eazybank/values-dev.yaml \
  -f my-custom-values.yaml \
  -n default
```

Files are processed in order, with later files overriding earlier ones.

### Method 2: Using --set Flag

Override individual values on the command line:

```bash
# Change Spring profile to QA but keep other dev settings
helm upgrade eazybank eazybank \
  -f eazybank/values-dev.yaml \
  --set config.springProfilesActive=qa \
  -n default

# Scale accounts service to 5 replicas
helm upgrade eazybank eazybank \
  -f eazybank/values-prod.yaml \
  --set accounts.replicaCount=5 \
  -n production

# Enable/disable specific components
helm upgrade eazybank eazybank \
  --set kafka.enabled=false \
  --set keycloak.enabled=false \
  -n default
```

### Method 3: Create Custom Environment File

Create your own values file for a specific scenario:

```bash
# Create values-local.yaml
cat > values-local.yaml <<EOF
config:
  springProfilesActive: "default"

# Only enable core services
kafka:
  enabled: false
keycloak:
  enabled: false
loki:
  enabled: false
alloy:
  enabled: false

# Use LoadBalancer for easy access
gatewayserver:
  service:
    type: LoadBalancer
EOF

# Use it
helm upgrade eazybank eazybank -f eazybank/values-local.yaml -n default
```

## 📊 Environment Comparison

| Feature | Dev | QA | Prod |
|---------|-----|-----|------|
| **Spring Profile** | default | qa | prod |
| **Gateway Service** | NodePort | ClusterIP + Ingress | LoadBalancer + Ingress |
| **Replicas** | 1 | 2 | 3 |
| **Memory Limit** | 512Mi | 700Mi | 1Gi |
| **CPU Limit** | 100m | 250m | 1000m |
| **TLS/SSL** | No | Optional | Yes (cert-manager) |
| **Monitoring** | Basic | Full | Full + Alerts |
| **Ingress** | Disabled | Enabled | Enabled with TLS |

## 🎯 Common Use Cases

### Scenario 1: Local Development with All Observability

```bash
helm upgrade eazybank eazybank \
  -f eazybank/values-dev.yaml \
  --set prometheus.enabled=true \
  --set grafana.enabled=true \
  --set loki.enabled=true \
  --set alloy.enabled=true \
  -n default
```

### Scenario 2: QA Testing Without Kafka

```bash
helm upgrade eazybank eazybank \
  -f eazybank/values-qa.yaml \
  --set kafka.enabled=false \
  -n qa
```

### Scenario 3: Production with External Database

```bash
# Create custom values file that disables MySQL
cat > values-prod-external-db.yaml <<EOF
# Use prod configuration as base
config:
  springProfilesActive: "prod"

# Disable internal MySQL databases
mysql:
  accountsdb:
    enabled: false
  loansdb:
    enabled: false
  cardsdb:
    enabled: false

# Add external database connection strings via environment variables
# (These would be read from ConfigMap or Secrets in practice)
EOF

helm upgrade eazybank eazybank \
  -f eazybank/values-prod.yaml \
  -f values-prod-external-db.yaml \
  -n production
```

### Scenario 4: Scale Specific Service

```bash
# Scale only accounts service during high load
helm upgrade eazybank eazybank \
  -f eazybank/values-prod.yaml \
  --set accounts.replicaCount=10 \
  -n production

# Or use kubectl for immediate scaling
kubectl scale deployment accounts --replicas=10 -n production
```

## 🔐 Working with Secrets

For sensitive data, use Kubernetes Secrets instead of values files:

```bash
# Create a secret for database passwords
kubectl create secret generic eazybank-secrets \
  --from-literal=mysql-root-password=super-secret-password \
  --from-literal=grafana-admin-password=another-secret \
  -n production

# Reference in your custom values file
cat > values-with-secrets.yaml <<EOF
config:
  mysql:
    # This would reference the secret in the template
    rootPasswordSecret: eazybank-secrets
    rootPasswordKey: mysql-root-password
EOF
```

## 📝 Best Practices

1. **Never commit secrets** to values files - use Kubernetes Secrets or external secret managers
2. **Keep base values.yaml minimal** - only include defaults that apply everywhere
3. **Environment files should only override** what's different from base
4. **Use namespaces** to isolate environments:
   - `default` for dev
   - `qa` for QA
   - `production` for production
5. **Version control your custom values files** but exclude sensitive data
6. **Test in lower environments first** before promoting to production
7. **Use GitOps** (ArgoCD, FluxCD) for managing different environments

## 🔍 Viewing Current Configuration

```bash
# See what values are currently applied
helm get values eazybank -n default

# See all values (including defaults)
helm get values eazybank --all -n default

# See the rendered manifests
helm get manifest eazybank -n default

# Show release history
helm history eazybank -n default
```

## 🔄 Switching Environments

If you want to switch an existing deployment to a different environment:

```bash
# Currently running with dev config, switch to QA
helm upgrade eazybank eazybank -f eazybank/values-qa.yaml -n default

# Rollback if something goes wrong
helm rollback eazybank -n default
```

## 📦 Creating Your Own Environment

```bash
# Create a new environment file
cat > values-staging.yaml <<EOF
# Staging Environment - between QA and Prod
config:
  springProfilesActive: "qa"

gatewayserver:
  replicaCount: 2
  service:
    type: ClusterIP
  ingress:
    enabled: true
    hosts:
      - host: staging-api.eazybank.com
        paths:
          - path: /
            pathType: Prefix

accounts:
  replicaCount: 2
loans:
  replicaCount: 2
cards:
  replicaCount: 2

# Enable full observability
prometheus:
  enabled: true
grafana:
  enabled: true
loki:
  enabled: true
alloy:
  enabled: true
tempo:
  enabled: true
EOF

# Deploy to staging namespace
kubectl create namespace staging
helm install eazybank eazybank -f eazybank/values-staging.yaml -n staging
```

## 🎓 Advanced: Using Helm Environments with CI/CD

### GitLab CI Example

```yaml
deploy:dev:
  stage: deploy
  script:
    - helm upgrade --install eazybank ./helm/eazybank -f helm/eazybank/values-dev.yaml -n default
  only:
    - develop

deploy:qa:
  stage: deploy
  script:
    - helm upgrade --install eazybank ./helm/eazybank -f helm/eazybank/values-qa.yaml -n qa
  only:
    - main

deploy:prod:
  stage: deploy
  script:
    - helm upgrade --install eazybank ./helm/eazybank -f helm/eazybank/values-prod.yaml -n production
  only:
    - tags
  when: manual
```

### GitHub Actions Example

```yaml
name: Deploy

on:
  push:
    branches:
      - develop
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Deploy to Dev
        if: github.ref == 'refs/heads/develop'
        run: |
          helm upgrade --install eazybank ./helm/eazybank \
            -f helm/eazybank/values-dev.yaml \
            -n default
      
      - name: Deploy to QA
        if: github.ref == 'refs/heads/main'
        run: |
          helm upgrade --install eazybank ./helm/eazybank \
            -f helm/eazybank/values-qa.yaml \
            -n qa
```

## 🆘 Troubleshooting

### View Differences Between Environments

```bash
# Compare dev vs qa configurations
helm template eazybank eazybank -f eazybank/values-dev.yaml > /tmp/dev.yaml
helm template eazybank eazybank -f eazybank/values-qa.yaml > /tmp/qa.yaml
diff /tmp/dev.yaml /tmp/qa.yaml
```

### Dry Run Before Deploying

```bash
# See what would be deployed without actually deploying
helm upgrade eazybank eazybank -f eazybank/values-prod.yaml --dry-run --debug -n production
```

### Validate Configuration

```bash
# Lint the chart with specific values
helm lint eazybank -f eazybank/values-prod.yaml
```

---

## Quick Command Reference

```bash
# Install
helm install eazybank eazybank -f eazybank/values-<ENV>.yaml -n <NAMESPACE>

# Upgrade
helm upgrade eazybank eazybank -f eazybank/values-<ENV>.yaml -n <NAMESPACE>

# Check status
helm status eazybank -n <NAMESPACE>

# View values
helm get values eazybank -n <NAMESPACE>

# Rollback
helm rollback eazybank -n <NAMESPACE>

# Uninstall
helm uninstall eazybank -n <NAMESPACE>
```

Replace `<ENV>` with `dev`, `qa`, or `prod` and `<NAMESPACE>` with your target namespace.

