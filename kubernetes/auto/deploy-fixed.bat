

echo [1/13] Deploying Kubernetes Dashboard...
kubectl delete secret kubernetes-dashboard-csrf -n kubernetes-dashboard 2>nul
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard

echo kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443


echo [2/13] Deploying Dashboard Admin User...
kubectl apply -f ../utils/dashboard-adminuser.yaml
kubectl apply -f ../utils/dashboard-rolebinding.yaml
kubectl apply -f ../utils/secret-adminuser.yaml

kubectl -n kubernetes-dashboard create token admin-user

echo Dashboard admin user created.
echo.


kubectl apply -f 1_configmap.yaml
kubectl apply -f 2_mysql-databases.yaml
kubectl apply -f 3_rabbitmq.yaml
kubectl apply -f 4_configserver.yaml
kubectl apply -f 5_eurekaserver.yaml
kubectl apply -f 6_accounts.yaml
kubectl apply -f 7_loans.yaml
kubectl apply -f 8_cards.yaml
kubectl apply -f 10_message.yaml

kubectl apply -f 11_minio.yaml
kubectl apply -f 1c_configmap_prometheus.yaml
kubectl apply -f 1d_configmap_grafana.yaml
kubectl apply -f 1e_configmap_alloy.yaml
kubectl apply -f 12_loki.yaml
kubectl apply -f 13_prometheus.yaml
kubectl apply -f 14_tempo.yaml

kubectl apply -f allow_rbac.yaml
kubectl apply -f 15_alloy.yaml
kubectl apply -f 16_grafana.yaml
kubectl apply -f 17_keycloak.yaml
kubectl apply -f 18_kafka.yaml
kubectl apply -f 9_gatewayserver.yaml