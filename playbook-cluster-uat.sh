#!/bin/bash

export AWS_PROFILE=github-eksuat
echo $AWS_PROFILE

aws eks update-kubeconfig --name eks-eks-uat --region ap-northeast-1 --profile github-eksuat

# Register apps with ArgoCD (one-time after fresh cluster deploy)
# This tells ArgoCD to watch booking-app/k8s/ in Git and auto-sync it to the cluster
kubectl apply -f argocd-apps/

# Get admin password
echo "ArgoCD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

# Port forward — open http://localhost:8080 in browser
kubectl port-forward svc/argocd-server -n argocd 8080:443
