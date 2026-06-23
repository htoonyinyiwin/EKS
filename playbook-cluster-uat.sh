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
ARGOCD_URL=$(kubectl get ingress argocd-ingress -n argocd \
  -o jsonpath="http://{.status.loadBalancer.ingress[0].hostname}")
echo "$ARGOCD_URL"

# Register GitHub webhook so ArgoCD syncs instantly on every push
# ALB URL changes each cluster recreate so we re-register each morning
# Removes stale hooks first to avoid accumulation
echo "Registering GitHub webhook for ArgoCD..."
REPO="htoonyinyiwin/EKS"
WEBHOOK_URL="${ARGOCD_URL}/api/webhook"

# Delete existing ArgoCD webhooks to avoid duplicates
for id in $(gh api repos/$REPO/hooks --jq '.[] | select(.config.url | contains("argocd")) | .id'); do
  gh api repos/$REPO/hooks/$id --method DELETE
  echo "Removed stale webhook $id"
done

# Register fresh webhook
gh api repos/$REPO/hooks --method POST \
  -f "config[url]=$WEBHOOK_URL" \
  -f "config[content_type]=json" \
  -f "events[]=push" \
  -f "active=true" > /dev/null

echo "Webhook registered: $WEBHOOK_URL"
