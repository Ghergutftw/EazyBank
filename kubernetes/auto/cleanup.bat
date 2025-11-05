
echo Cleaning up all Kubernetes resources...
echo.

echo [1/3] Deleting application resources...
kubectl delete -f 9_gatewayserver.yaml
kubectl delete -f 10_message.yaml
kubectl delete -f 8_cards.yaml
kubectl delete -f 7_loans.yaml
kubectl delete -f 6_accounts.yaml
kubectl delete -f 5_eurekaserver.yaml
kubectl delete -f 4_configserver.yaml
kubectl delete -f 17_keycloak.yaml
kubectl delete -f 18_kafka.yaml

echo [2/3] Deleting observability stack...
kubectl delete -f 16_grafana.yaml
kubectl delete -f 15_alloy.yaml
kubectl delete -f 14_tempo.yaml
kubectl delete -f 13_prometheus.yaml
kubectl delete -f 12_loki.yaml
kubectl delete -f 1e_configmap_alloy.yaml
kubectl delete -f 1d_configmap_grafana.yaml
kubectl delete -f 1c_configmap_prometheus.yaml
kubectl delete -f 11_minio.yaml

echo [3/3] Deleting infrastructure resources...
kubectl delete -f 3_rabbitmq.yaml
kubectl delete -f 2_mysql-databases.yaml
kubectl delete -f 1_configmap.yaml

echo.
echo Cleanup complete!

