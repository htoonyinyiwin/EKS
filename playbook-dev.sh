#!/bin/bash

export AWS_PROFILE=github-eks
echo $AWS_PROFILE

# ─────────────────────────────────────────────
# STEP 1 — main-infra (VPC + ECR + Budget)
# Run once, or when VPC/ECR changes
# ─────────────────────────────────────────────

cd main-infra
terraform init -backend-config=aws-tfstate.dev.hcl
terraform plan -var-file=variables.dev.tfvars -out=dev.plan
terraform apply dev.plan
cd ..

# ─────────────────────────────────────────────
# STEP 2 — Mirror images to ECR
# Run manually in GitHub Actions:
#   Actions → Mirror Images to ECR → Run workflow
# Must run after Step 1 (ECR repos must exist)
# ─────────────────────────────────────────────

# ─────────────────────────────────────────────
# STEP 3 — main-platform (EKS + ArgoCD + ALB controller)
# ─────────────────────────────────────────────

cd main-platform
terraform init -backend-config=aws-tfstate.dev.hcl
terraform plan -var-file=variables.dev.tfvars -out=dev.plan
terraform apply dev.plan
cd ..

# ─────────────────────────────────────────────
# STEP 4 — Access ArgoCD UI
# ─────────────────────────────────────────────

aws eks update-kubeconfig --name eks-eks-dev --region ap-northeast-1 --profile github-eks

# Get admin password
echo "ArgoCD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

# Port forward — open http://localhost:8080 in browser
kubectl port-forward svc/argocd-server -n argocd 8080:443
