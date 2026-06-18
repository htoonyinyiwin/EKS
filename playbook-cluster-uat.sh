aws eks update-kubeconfig --name eks-eks-uat --region ap-northeast-1 --profile github-eksuat

# Get admin password
echo "ArgoCD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

# Port forward — open http://localhost:8080 in browser
kubectl port-forward svc/argocd-server -n argocd 8080:443
