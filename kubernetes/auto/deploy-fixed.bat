@echo off
echo ================================================
echo EazyBank - Clean Deployment (Fixed)
echo ================================================
echo.

echo [1/8] Deploying ConfigMap...
kubectl apply -f 1_configmap.yaml
echo.

echo [2/8] Deploying MySQL Databases...
kubectl apply -f 2_mysql-databases.yaml
echo Waiting 30 seconds for databases to initialize...
ping 127.0.0.1 -n 10 > nul
echo.

echo [3/8] Deploying RabbitMQ...
kubectl apply -f 3_rabbitmq.yaml
echo Waiting 20 seconds for RabbitMQ to start...
ping 127.0.0.1 -n 21 > nul
echo.

echo [4/8] Deploying Config Server...
kubectl apply -f 4_configserver.yaml
echo Waiting 30 seconds for Config Server...
ping 127.0.0.1 -n 10 > nul
echo.

echo [5/8] Deploying Eureka Server...
kubectl apply -f 5_eurekaserver.yaml
echo Waiting 30 seconds for Eureka Server...
ping 127.0.0.1 -n 10 > nul
echo.

echo [6/8] Deploying Microservices (Accounts, Loans, Cards, Message)...
kubectl apply -f 6_accounts.yaml
kubectl apply -f 7_loans.yaml
kubectl apply -f 8_cards.yaml
kubectl apply -f 10_message.yaml
echo Waiting 60 seconds for microservices to start...
ping 127.0.0.1 -n 61 > nul
echo.

echo [7/11] Deploying Gateway Server...
kubectl apply -f 9_gatewayserver.yaml
echo.

echo [8/11] Deploying Keycloak...
kubectl apply -f 17_keycloak.yaml
echo Waiting 20 seconds for Keycloak to start...
ping 127.0.0.1 -n 21 > nul
echo.

echo [9/11] Deploying Kafka...
kubectl apply -f 18_kafka.yaml
echo.


echo [10/11] Deploying Observability Stack...
kubectl apply -f 11_minio.yaml
kubectl apply -f 12_loki.yaml
kubectl apply -f 13_prometheus.yaml
kubectl apply -f 14_tempo.yaml
kubectl apply -f 15_alloy.yaml
kubectl apply -f 16_grafana.yaml
echo Observability stack deployed.
echo.

echo [11/11] Checking deployment status...
echo.
kubectl get pods
echo.
echo ================================================
echo Deployment Complete!
echo ================================================
echo.
echo Wait 2-3 minutes for all services to be fully ready.
echo.
echo Check status: kubectl get pods
echo Check services: kubectl get svc
echo.
echo Get LoadBalancer external IPs:
echo kubectl get svc --field-selector spec.type=LoadBalancer
echo.
echo Access URLs (replace ^<EXTERNAL-IP^> with actual IP):
echo   - Gateway Server: http://^<EXTERNAL-IP^>:8072
echo   - Accounts: http://^<EXTERNAL-IP^>:8080
echo   - Loans: http://^<EXTERNAL-IP^>:8090
echo   - Cards: http://^<EXTERNAL-IP^>:9000
echo   - Keycloak: http://^<EXTERNAL-IP^>:7080 (admin/admin)
if /i "%deploy_obs%"=="y" (
    echo   - Grafana: http://^<EXTERNAL-IP^>:3000 (admin/admin)
)
echo.
pause

