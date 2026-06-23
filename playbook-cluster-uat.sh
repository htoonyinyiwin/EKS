#!/bin/bash
# Run once after cloning: chmod +x playbook-cluster-uat.sh

export AWS_PROFILE=github-eksuat
echo $AWS_PROFILE

aws eks update-kubeconfig --name eks-eks-uat --region ap-northeast-1 --profile github-eksuat

# Register apps with ArgoCD (one-time after fresh cluster deploy)
# This tells ArgoCD to watch argocd-server/ and booking-app/k8s/ in Git and auto-sync them
kubectl apply -f argocd-apps/

# Get admin password
echo "ArgoCD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

# ArgoCD is now exposed via ALB — no port forward needed
echo "ArgoCD URL:"
kubectl get ingress argocd-ingress -n argocd \
  -o jsonpath="http://{.status.loadBalancer.ingress[0].hostname}" && echo
