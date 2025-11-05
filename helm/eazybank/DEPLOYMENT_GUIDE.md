# EazyBank Helm Chart - Quick Start Guide

## 🚀 Quick Deployment

### Step 1: Verify Prerequisites

```bash
# Check Helm version (requires 3.0+)
helm version

# Check kubectl connection
kubectl cluster-info

# Check available resources
kubectl top nodes
```

### Step 2: Deploy to Development

```bash
# Navigate to the chart directory
cd helm/eazybank

# Install with development settings
helm install eazybank . -f values-dev.yaml

# Watch the deployment
kubectl get pods -w
```

### Step 3: Access the Application

```bash
# Get the Gateway NodePort
export NODE_PORT=$(kubectl get svc gatewayserver -o jsonpath='{.spec.ports[0].nodePort}')
export NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')

echo "Gateway URL: http://$NODE_IP:$NODE_PORT"

# Or use port-forward
kubectl port-forward svc/gatewayserver 8072:8072
# Access: http://localhost:8072
```

### Step 4: Verify Services

```bash
# Check all pods are running
kubectl get pods

# Check Eureka Server (port-forward)
kubectl port-forward svc/eurekaserver 8761:8761
# Visit: http://localhost:8761

# Check RabbitMQ Management
kubectl port-forward svc/rabbitmq 15672:15672
# Visit: http://localhost:15672 (guest/guest)
```

## 🏭 Production Deployment

### Prerequisites for Production

1. **External Database** (Recommended)
   - Use managed MySQL service (AWS RDS, Azure Database, etc.)
   - Update ConfigMap with external DB URLs

2. **Ingress Controller**
   ```bash
   # Install nginx-ingress
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   helm install nginx-ingress ingress-nginx/ingress-nginx
   ```

3. **Cert Manager** (for TLS)
   ```bash
   # Install cert-manager
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
   ```

### Deploy to Production

```bash
# Create production namespace
kubectl create namespace production

# Deploy with production values
helm install eazybank . \
  -f values-prod.yaml \
  --namespace production

# Verify deployment
kubectl get all -n production
```

### Configure DNS

Point your domain to the LoadBalancer IP:

```bash
# Get LoadBalancer IP
kubectl get svc gatewayserver -n production

# Create DNS A record: api.eazybank.com -> LOADBALANCER_IP
```

## 📊 Environment Comparison

| Feature | Development | QA | Production |
|---------|-------------|-----|------------|
| **Profile** | default | qa | prod |
| **Replicas** | 1 per service | 2 per service | 3 per service |
| **Memory** | 512Mi | 700Mi | 1Gi |
| **Gateway** | NodePort | ClusterIP+Ingress | LB+Ingress |
| **TLS** | No | No | Yes |
| **Observability** | Disabled | Partial | Full |

## 🔄 Upgrade Strategies

### Zero-Downtime Rolling Update

```bash
# Update image tag in values.yaml, then:
helm upgrade eazybank . \
  --set accounts.image.tag=v2.0.0 \
  --wait

# Or upgrade entire environment
helm upgrade eazybank . -f values-prod.yaml
```

### Rollback

```bash
# View release history
helm history eazybank

# Rollback to previous version
helm rollback eazybank

# Rollback to specific revision
helm rollback eazybank 3
```

## 🧪 Testing the Deployment

### 1. Health Checks

```bash
# Test each microservice health endpoint
kubectl port-forward svc/accounts 8080:8080
curl http://localhost:8080/actuator/health

kubectl port-forward svc/loans 8090:8090
curl http://localhost:8090/actuator/health

kubectl port-forward svc/cards 9000:9000
curl http://localhost:9000/actuator/health
```

### 2. Service Discovery

```bash
# Check Eureka dashboard
kubectl port-forward svc/eurekaserver 8761:8761
# Visit: http://localhost:8761
# Verify all services are registered
```

### 3. API Gateway

```bash
# Test routing through gateway
kubectl port-forward svc/gatewayserver 8072:8072

# Test accounts endpoint
curl http://localhost:8072/eazybank/accounts/api/contact-info

# Test loans endpoint
curl http://localhost:8072/eazybank/loans/api/contact-info

# Test cards endpoint
curl http://localhost:8072/eazybank/cards/api/contact-info
```

## 🐛 Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods

# Describe failing pod
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

### Common Issues

**1. ImagePullBackOff**
```bash
# Check if image exists and is accessible
docker pull ghergutmadalin/accounts:latest

# Use imagePullSecrets if using private registry
kubectl create secret docker-registry regcred \
  --docker-server=<registry> \
  --docker-username=<username> \
  --docker-password=<password>
```

**2. CrashLoopBackOff**
```bash
# Check application logs
kubectl logs <pod-name> --previous

# Check if ConfigMap is created
kubectl get configmap eazybank-config -o yaml
```

**3. Service Not Accessible**
```bash
# Check service endpoints
kubectl get endpoints

# Test service connectivity
kubectl run test-pod --rm -it --image=busybox -- sh
wget -qO- http://accounts:8080/actuator/health
```

## 📈 Scaling

### Manual Scaling

```bash
# Scale specific microservice
helm upgrade eazybank . --set accounts.replicaCount=5

# Or use kubectl
kubectl scale deployment accounts --replicas=5
```

### Horizontal Pod Autoscaler

```bash
# Create HPA for accounts service
kubectl autoscale deployment accounts \
  --cpu-percent=70 \
  --min=2 \
  --max=10

# Check HPA status
kubectl get hpa
```

## 🔐 Security Hardening

### 1. Use Secrets Instead of ConfigMap

```bash
# Create secret for sensitive data
kubectl create secret generic mysql-credentials \
  --from-literal=root-password=<secure-password>

# Update values.yaml to reference secret
```

### 2. Enable Network Policies

```bash
# Apply network policy to restrict traffic
kubectl apply -f network-policies/
```

### 3. Run as Non-Root

Update Deployment security context:
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
```

## 📞 Support Checklist

Before seeking support:

- [ ] Check pod status: `kubectl get pods`
- [ ] Check pod logs: `kubectl logs <pod-name>`
- [ ] Check events: `kubectl get events`
- [ ] Verify ConfigMap: `kubectl get configmap`
- [ ] Test connectivity: `kubectl run test --rm -it --image=busybox`
- [ ] Check resource usage: `kubectl top pods`
- [ ] Verify Helm release: `helm status eazybank`

## 🎓 Learning Resources

- **Helm**: https://helm.sh/docs/
- **Kubernetes**: https://kubernetes.io/docs/
- **Spring Cloud**: https://spring.io/projects/spring-cloud
- **Microservices Patterns**: https://microservices.io/

## 📝 Maintenance

### Regular Tasks

```bash
# Update Helm repositories
helm repo update

# Check for outdated images
# (Manual check or use tools like kube-hunter)

# Review resource usage
kubectl top pods
kubectl top nodes

# Backup Helm releases
helm get values eazybank > backup-values.yaml
```

### Disaster Recovery

```bash
# Export current values
helm get values eazybank > production-backup.yaml

# Export all manifests
helm get manifest eazybank > production-manifest.yaml

# Recreate from backup
helm install eazybank . -f production-backup.yaml
```

---

**Happy Deploying! 🚀**

