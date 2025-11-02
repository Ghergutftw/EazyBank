@echo off
REM Cleanup script for EazyBank Microservices on Kubernetes (Windows)
REM This script removes all deployed components

echo ==================================================
echo EazyBank Microservices - Kubernetes Cleanup
echo ==================================================
echo.
echo WARNING: This will delete all EazyBank resources from Kubernetes!
echo.

echo.
echo Deleting all resources...
echo.

kubectl delete -f 9_gatewayserver.yaml
kubectl delete -f 10_message.yaml
kubectl delete -f 8_cards.yaml
kubectl delete -f 7_loans.yaml
kubectl delete -f 6_accounts.yaml
kubectl delete -f 5_eurekaserver.yaml
kubectl delete -f 4_configserver.yaml
kubectl delete -f 17_keycloak.yaml
kubectl delete -f 16_grafana.yaml
kubectl delete -f 15_alloy.yaml
kubectl delete -f 14_tempo.yaml
kubectl delete -f 13_prometheus.yaml
kubectl delete -f 12_loki.yaml
kubectl delete -f 11_minio.yaml
kubectl delete -f 18_kafka.yaml
kubectl delete -f 3_rabbitmq.yaml
kubectl delete -f 2_mysql-databases.yaml
kubectl delete -f 1_configmap.yaml

echo.
echo ==================================================
echo Cleanup Complete!
echo ==================================================
echo.
echo Verify all resources are deleted:
echo   kubectl get all
echo   kubectl get configmap
echo.
pause

