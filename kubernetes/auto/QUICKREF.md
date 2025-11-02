# Quick Reference Guide - EazyBank K8s

## 🚀 Deploy Everything (Windows)
```cmd
cd kubernetes\auto
deploy.bat
```

## 📋 Check Status
```bash
# All pods
kubectl get pods

# All services
kubectl get services

# Get LoadBalancer external IPs
kubectl get svc -l type=LoadBalancer

# Watch pod status
kubectl get pods -w

# Describe a pod
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>

# Follow logs
kubectl logs -f <pod-name>
```

## 🔍 Debugging

### Check pod not starting
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Check ConfigMap
```bash
kubectl get configmap eazybank-configmap -o yaml
```

### Restart a deployment
```bash
kubectl rollout restart deployment/<deployment-name>
kubectl rollout status deployment/<deployment-name>
```

## 🌐 Service Ports

| Service | Port | Type | Access |
|---------|------|------|--------|
| Gateway | 8072 | LoadBalancer | External |
| Accounts | 8080 | LoadBalancer | External |
| Loans | 8090 | LoadBalancer | External |
| Cards | 9000 | LoadBalancer | External |
| Grafana | 3000 | LoadBalancer | External |
| Keycloak | 7080 | LoadBalancer | External |
| ConfigServer | 8071 | ClusterIP | Internal |
| EurekaServer | 8761 | ClusterIP | Internal |
| RabbitMQ AMQP | 5672 | ClusterIP | Internal |
| RabbitMQ UI | 15672 | ClusterIP | Internal |
| Kafka | 9092 | ClusterIP | Internal |
| Prometheus | 9090 | ClusterIP | Internal |
| Tempo | 4318 | ClusterIP | Internal |

## 🔧 Common Operations

### Scale a deployment
```bash
kubectl scale deployment accounts --replicas=3
```

### Update ConfigMap and restart
```bash
kubectl apply -f 1_configmap.yaml
kubectl rollout restart deployment accounts
kubectl rollout restart deployment loans
kubectl rollout restart deployment cards
kubectl rollout restart deployment gatewayserver
```

### Port forward for internal service
```bash
kubectl port-forward svc/eurekaserver 8761:8761
kubectl port-forward svc/configserver 8071:8071
kubectl port-forward svc/rabbitmq 15672:15672
```

### Execute into pod
```bash
kubectl exec -it <pod-name> -- /bin/bash
```

### View resource usage
```bash
kubectl top pods
kubectl top nodes
```

## 🧹 Cleanup
```cmd
cleanup.bat
```

Or manually:
```bash
kubectl delete -f kubernetes/auto/
```

## 📊 URLs (Replace <EXTERNAL-IP>)

```
Gateway:    http://<EXTERNAL-IP>:8072
Accounts:   http://<EXTERNAL-IP>:8080
Loans:      http://<EXTERNAL-IP>:8090
Cards:      http://<EXTERNAL-IP>:9000
Grafana:    http://<EXTERNAL-IP>:3000
Keycloak:   http://<EXTERNAL-IP>:7080
```

## 🔐 Default Credentials

- **Grafana**: admin / admin
- **Keycloak**: admin / admin
- **MySQL Root**: root

## 💡 Tips

1. Wait 2-3 minutes after deployment for all services to be ready
2. Check logs if a service is not responding
3. Ensure LoadBalancer support (cloud provider or MetalLB)
4. Config changes require pod restart
5. Use `kubectl get events` to troubleshoot issues

