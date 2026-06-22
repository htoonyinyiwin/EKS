# Interview Brush-up Guide

Personal reference — scan this the morning of the interview.

---

## Full Component Flow (What Calls What)

```
Developer
  └── git push
        ├── GitHub Actions (CI)
        │     └── docker build → push to ECR → ECR image scan
        └── GitHub Actions (Infra Pipeline)
              └── terraform plan → terraform apply → EKS cluster

ArgoCD (GitOps)
  ├── watches Git repo for manifest changes
  ├── pulls Docker image from ECR
  └── deploys booking-app to EKS

User
  └── HTTP request → ALB → booking-app pod
        ├── reads/writes → RDS PostgreSQL
        ├── reads/writes → ElastiCache Redis
        └── reads env vars from K8s Secret (via ESO)

Secrets flow
  └── Secrets Manager (AWS)
        └── ESO (External Secrets Operator) polls every 1h
              └── creates K8s Secret
                    └── injected into pod as env vars

Observability flow
  ├── Prometheus scrapes all pods every 30s → remote_write → Grafana Cloud (Mimir)
  ├── Fluent Bit DaemonSet reads /var/log/containers/ → push → Grafana Cloud (Loki)
  └── AlertManager → Slack #alerts
```

---

## Component by Component

### 1. EKS (Elastic Kubernetes Service)
**What:** AWS-managed Kubernetes control plane. We manage the worker nodes.

**Our setup:**
- Version 1.35
- Managed node group: `t3a.medium`, 2 nodes in UAT
- Nodes in private subnets (no public IP)
- Control plane in AWS-managed account (you don't see it)

**Why managed node group over self-managed:**
AWS handles node patching, AMI updates, and replacement. We just define the desired state.

**Key commands:**
```bash
kubectl get nodes
kubectl describe node <node-name>
```

---

### 2. VPC + Networking
**What:** Isolated network for the cluster.

**Our setup:**
- CIDR: `10.10.0.0/22` (1024 IPs)
- Private subnets: `10.10.1.0/26`, `10.10.1.64/26` (pods + nodes live here)
- Public subnets: `10.10.0.0/27`, `10.10.0.32/27` (ALB lives here)
- NAT Gateway: allows private subnet outbound internet (for ECR pulls, Grafana push)

**CNI: AWS VPC CNI** — each pod gets a real VPC IP address. No overlay network. Pod traffic is native VPC routing.

**Key commands:**
```bash
kubectl get pods -o wide  # shows pod IPs (real VPC IPs)
```

---

### 3. ArgoCD (GitOps)
**What:** Kubernetes-native GitOps controller. Watches Git, syncs cluster state.

**Why GitOps over CI push:**
- Git is the single source of truth
- Every change is a Git commit (audit trail)
- ArgoCD detects drift and self-heals
- No kubectl in CI pipelines

**Our setup:**
- Installed via Helm in `argocd` namespace
- Watches `booking-app/k8s/` in this repo
- Auto-syncs on Git changes
- Pulls images from ECR

**Flow:**
```
git push manifest change → ArgoCD detects → kubectl apply automatically
```

**Key commands:**
```bash
kubectl get applications -n argocd
kubectl get pods -n argocd
# UI: kubectl port-forward svc/argocd-server -n argocd 8080:443
```

---

### 4. External Secrets Operator (ESO)
**What:** K8s operator that syncs secrets from external secret stores (Secrets Manager, Parameter Store, Vault) into K8s Secrets.

**Why ESO:**
- Secrets never live in Git
- Secrets never live in Terraform state in plaintext
- Rotation: update Secrets Manager → ESO re-syncs → pod picks up new value
- Works with IRSA (no hardcoded AWS credentials)

**Our setup:**
- `ClusterSecretStore`: points to AWS Secrets Manager via IRSA
- `ExternalSecret` resources: define which secret key to pull and what K8s Secret to create

**Flow:**
```
Secrets Manager (AWS)
  └── ClusterSecretStore (auth via IRSA)
        └── ExternalSecret (CRD) → K8s Secret → pod env var
```

**Secrets we manage:**
| Secrets Manager Key | K8s Secret | Used by |
|---|---|---|
| `uat/app/db-password` | `app-db-secret` | booking-app → RDS |
| `grafana-cloud/remote-write` | `grafana-cloud-secret` | Prometheus → Grafana Cloud |
| `grafana-cloud/remote-write` | `grafana-loki-secret` | Fluent Bit → Grafana Loki |
| `alertmanager/slack-webhook` | `alertmanager-slack-secret` | AlertManager → Slack |

**Key commands:**
```bash
kubectl get clustersecretstore
kubectl get externalsecret -n monitoring
kubectl get externalsecret -n booking-app
# force re-sync:
kubectl annotate externalsecret <name> force-sync=$(date +%s) --overwrite -n <namespace>
```

---

### 5. AWS Load Balancer Controller (ALB)
**What:** K8s controller that creates AWS ALBs from Ingress resources.

**Why ALB over NodePort/classic LB:**
- Native AWS integration (WAF, ACM, target groups)
- IP mode: traffic goes directly to pod IP (no NodePort hop)
- Internet-facing for public traffic, internal for private

**Our setup:**
- Installed via Helm
- Uses IRSA for AWS API access
- booking-app Ingress → internet-facing ALB → pod:8000

**Flow:**
```
Ingress YAML (kubectl apply via ArgoCD)
  └── ALB Controller watches → creates ALB in AWS
        └── User → ALB DNS → pod IP
```

**Key commands:**
```bash
kubectl get ingress -n booking-app   # shows ALB DNS name
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

---

### 6. kube-prometheus-stack (Prometheus + AlertManager)
**What:** Helm chart that bundles Prometheus, AlertManager, Grafana, node-exporter, kube-state-metrics.

**Components:**
- **Prometheus**: scrapes metrics from pods (via ServiceMonitors), stores 7 days locally
- **AlertManager**: receives alerts from Prometheus, routes to Slack
- **node-exporter**: DaemonSet, exposes node-level metrics (CPU, memory, disk)
- **kube-state-metrics**: exposes K8s object metrics (pod status, deployment replicas)
- **Grafana**: in-cluster dashboard (we use Grafana Cloud instead)

**Remote write:**
Prometheus pushes all metrics to Grafana Cloud (Mimir) via `remote_write`. This means metrics are available even after cluster destroys.

**Key commands:**
```bash
kubectl get pods -n monitoring
kubectl get prometheusrule -n monitoring
kubectl get servicemonitor -n monitoring
```

---

### 7. Fluent Bit (Log Shipping)
**What:** Lightweight log collector DaemonSet. Runs on every node, ships logs to Loki.

**Why Fluent Bit over Fluentd:**
- Written in C (lower memory than Fluentd which is Ruby)
- Built-in Loki output plugin
- DaemonSet = one pod per node, collects all container logs

**Flow:**
```
/var/log/containers/*.log (pod stdout/stderr)
  └── Fluent Bit tail input
        └── Kubernetes filter (enriches with namespace, pod, container labels)
              └── Loki output → Grafana Cloud
```

**Labels on each log entry:** `job=fluent-bit`, `cluster=eks-eks-uat`, `env=uat`, `namespace_name`, `pod_name`, `container_name`

**Key commands:**
```bash
kubectl get pods -n monitoring -l app.kubernetes.io/name=fluent-bit
kubectl logs -n monitoring -l app.kubernetes.io/name=fluent-bit --tail=10
# Query in Grafana Cloud → Explore → Loki: {job="fluent-bit"}
```

---

### 8. AlertManager
**What:** Handles alert routing, grouping, and silencing. Receives firing alerts from Prometheus.

**Our setup:**
- `AlertmanagerConfig` CRD: routes alerts with `namespace=monitoring` to Slack
- `PrometheusRule` CRD: defines alert conditions (PodCrashLooping, PodNotReady, BookingAppDown)
- `groupWait: 30s` — waits 30s before sending first notification (groups related alerts)
- `repeatInterval: 12h` — re-notifies every 12h if still firing

**Test an alert:**
```bash
kubectl port-forward svc/kube-prometheus-stack-alertmanager -n monitoring 9093:9093 &
curl -X POST http://localhost:9093/api/v2/alerts \
  -H 'Content-Type: application/json' \
  -d '[{"labels":{"alertname":"Test","severity":"critical","namespace":"monitoring"},"annotations":{"summary":"Test alert"}}]'
```

**Key commands:**
```bash
kubectl get alertmanagerconfig -n monitoring
kubectl get prometheusrule -n monitoring
kubectl logs -n monitoring alertmanager-kube-prometheus-stack-alertmanager-0 -c alertmanager --tail=20
```

---

### 9. ECR (Elastic Container Registry)
**What:** AWS private Docker registry. Stores all container images.

**Our repos:** `aws-load-balancer-controller`, `argocd`, `dex`, `redis`, `external-secrets`, `booking-app`

**Key features:**
- **Lifecycle policy**: keeps last 10 images per repo (auto-deletes old ones)
- **Image scan on push**: ECR scans for CVEs automatically
- **Cross-account replication**: UAT → PROD + DEV (UAT is the build account)

**Why ECR over Docker Hub:**
- Private, no rate limits, native AWS IAM auth, same region as cluster (faster pulls)

**Key commands:**
```bash
aws ecr describe-repositories --region ap-northeast-1 --profile github-eksuat
aws ecr list-images --repository-name booking-app --region ap-northeast-1 --profile github-eksuat
```

---

### 10. RDS PostgreSQL + ElastiCache Redis
**What:** Managed database and cache. Both in private subnets.

**Why in `main-platform` (not `main-infra`):**
They destroy with the EKS cluster daily. Data is lost on destroy — this is intentional for cost (dev/uat workflow).

**Security:**
- RDS password: generated by Terraform `random_password`, stored in Secrets Manager
- Security group: only allows port 5432/6379 from within the VPC CIDR
- No public access

**booking-app connects via:**
- DB: `DATABASE_URL` env var from K8s Secret (synced from Secrets Manager by ESO)
- Redis: `REDIS_HOST`/`REDIS_PORT` from ConfigMap (non-sensitive, just endpoint)

---

### 11. GitHub Actions + OIDC
**What:** CI/CD pipeline. No stored AWS credentials — uses OIDC.

**OIDC flow:**
```
GitHub Actions job starts
  └── requests JWT token from GitHub
        └── assumes AWS IAM role via Web Identity (sts:AssumeRoleWithWebIdentity)
              └── gets temporary credentials (15min TTL)
```

**Why OIDC over access keys:**
No long-lived credentials to rotate, leak, or expire. IAM role has condition: only this repo + this branch can assume it.

**Infra pipeline jobs (sequential):**
```
dev VPC → dev platform → uat VPC → uat platform → prod VPC → prod platform
```
Each stage waits for the previous to complete.

**Key files:**
- `.github/workflows/infra-pipeline.yml` — infra pipeline
- `.github/workflows/build.yml` — app CI (build + push to ECR)

---

## Policies in This Project

| Policy Type | Resource | Purpose |
|---|---|---|
| NetworkPolicy | `booking-app` namespace | Default deny, allow-list ALB + Prometheus + RDS/Redis |
| RBAC | `booking-app` namespace | Developer (read+exec) and readonly roles |
| PrometheusRule | `monitoring` + `booking-app` | Alert conditions for cluster and app |
| IAM Policy | GitHub OIDC role, node role | Least-privilege AWS access |
| ECR Lifecycle Policy | All ECR repos | Keep last 10 images |
| ECR Registry Policy | PROD/DEV accounts | Allow UAT to replicate images |

**Interview answer:** "Policies are defined as Kubernetes-native YAML manifests (NetworkPolicy, RBAC, PrometheusRule) and applied via ArgoCD from Git. AWS-level policies (IAM, ECR) are managed in Terraform. Everything is version-controlled — changes require a Git commit."

---

## Verification Commands (After Cluster Create)

Run in this order every morning:

```bash
# 1. Nodes
kubectl get nodes

# 2. Namespaces
kubectl get ns

# 3. System pods
kubectl get pods -n kube-system

# 4. ESO
kubectl get pods -n external-secrets
kubectl get clustersecretstore

# 5. Secrets synced
kubectl get externalsecret -n monitoring
kubectl get externalsecret -n booking-app

# 6. Monitoring
kubectl get pods -n monitoring

# 7. ArgoCD + app
kubectl get pods -n argocd
kubectl get applications -n argocd

# 8. booking-app
kubectl get pods -n booking-app
kubectl get ingress -n booking-app   # grab ALB DNS

# 9. Smoke test
curl http://<ALB_DNS>/health
```

---

## Common Interview Q&A

**Q: How do you manage secrets?**
A: "AWS Secrets Manager is the source of truth. External Secrets Operator (ESO) runs in the cluster and polls Secrets Manager every hour, syncing values into K8s Secrets. Pods consume those as env vars. Nothing sensitive is in Git or Terraform state."

**Q: How do deployments work?**
A: "GitOps via ArgoCD. Developers push to Git — ArgoCD detects the change and syncs the cluster automatically. No kubectl in pipelines, no manual deploys. The cluster state always matches Git."

**Q: What happens if a pod crashes?**
A: "Kubernetes restarts it automatically (ReplicaSet controller). If it keeps crashing, the PodCrashLooping PrometheusRule fires after 5 minutes, AlertManager routes it to Slack. Fluent Bit captures all crash logs in Loki for investigation."

**Q: How does CI/CD work without storing AWS credentials?**
A: "GitHub Actions assumes an IAM role via OIDC. GitHub issues a short-lived JWT, AWS STS exchanges it for temporary credentials valid for 15 minutes. The IAM role has a condition that restricts it to this specific GitHub repository and branch."

**Q: How do you handle multi-environment promotion?**
A: "Three separate AWS accounts — DEV, UAT, PROD. The CI pipeline builds images in UAT (the build account) and ECR replicates to PROD and DEV. The infra pipeline is sequential: DEV completes before UAT starts, UAT completes before PROD starts. PROD requires an explicit checkbox to trigger."

**Q: What's the difference between ConfigMap and Secret?**
A: "ConfigMap for non-sensitive config like Redis host/port. K8s Secrets (created by ESO from Secrets Manager) for credentials. The rule: if compromising the value gives access to data or systems, it's a Secret."

**Q: How do you monitor the cluster?**
A: "Three pillars: metrics via Prometheus remote-writing to Grafana Cloud Mimir, logs via Fluent Bit DaemonSet shipping to Grafana Cloud Loki, and alerts via AlertManager routing to Slack. All three are visible in a single Grafana Cloud instance."

**Q: What policies do you apply to the cluster?**
A: "NetworkPolicy with default-deny in the booking-app namespace, allow-listing only ALB ingress, Prometheus scrape, and egress to RDS/Redis. RBAC with developer and readonly roles. PrometheusRules for alerting. All defined as K8s YAML in Git, applied by ArgoCD."

**Q: How do you handle cluster upgrades?**
A: "EKS managed node groups support rolling upgrades. We'd update the `eks_version` variable in Terraform, apply in DEV first, verify, then promote to UAT and PROD via the pipeline. PodDisruptionBudgets ensure at least one booking-app pod stays running during node drain."
