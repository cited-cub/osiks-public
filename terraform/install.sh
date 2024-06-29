# Inspiration: https://ruan.dev/blog/2024/04/07/using-terraform-to-deploy-kind-kubernetes-clusters

# Initialize Terraform
terraform init

# View plan
terraform plan

# Deploy Kind cluster
terraform apply -auto-approve

# Set kube config file
export KUBECONFIG=${PWD}/.kube/config
