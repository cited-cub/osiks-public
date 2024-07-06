# Inspiration: https://ruan.dev/blog/2024/04/07/using-terraform-to-deploy-kind-kubernetes-clusters

# Deploy Kind cluster with Cilium and ArgoCD
terraform init
terraform apply -auto-approve

# Deploy ingress
cd applications/ingress-controller
terraform init
terraform apply -auto-approve
cd -

# Deploy osiks-public ArgoCD project and nginx ArgoCD application
cd argoapps/osiks
terraform init
terraform apply -auto-approve
cd -

# Deploy Grafana ArgoCD application
cd argoapps/osiks-grafana
terraform init
terraform apply -auto-approve
cd -

# Deploy DNSUtils pod
cd applications/dnsutils
terraform init
terraform apply -auto-approve
cd -

# Deploy kuard
cd applications/kuard
terraform init
terraform apply -auto-approve
cd -

# Deploy Pebble
cd applications/pebble
terraform init
terraform apply -auto-approve
cd -

# Deploy cert-manager
cd applications/cert-manager
terraform init
terraform apply -auto-approve
cd -

# Set kube config file
export KUBECONFIG=${PWD}/.kube/config

# Get ArgoCD initial admin password
kubectl -n argocd get secrets argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
