# Inspiration: https://ruan.dev/blog/2024/04/07/using-terraform-to-deploy-kind-kubernetes-clusters

# Deploy Kind cluster with Cilium and ArgoCD
terraform init
terraform apply -auto-approve

# Deploy ingress
cd applications/ingress
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

# Set kube config file
export KUBECONFIG=${PWD}/.kube/config
