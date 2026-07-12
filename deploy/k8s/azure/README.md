# Azure AKS Wave A (demo stack)

Self-contained Dashflow on AKS with **in-cluster MySQL + RabbitMQ**, platform images and pipelets from **ACR**, plus petstore mocks.

Wave B (Azure MySQL Flexible Server + Service Bus) stays documented in [`docs/AZURE_ASSEMBLY.md`](../../../docs/AZURE_ASSEMBLY.md).

## What this deploys

| Workload | Service | Notes |
|----------|---------|-------|
| `dashflow-api` | `dashflow-api:8080` | Profiles `local,k8s`; creates `tenant-*` Jobs |
| `dashflow-ui` | `dashflow-ui:80` (LoadBalancer) | nginx proxies `/api` → API |
| `mysql` | `mysql:3306` | DBs `pipeline` + `petstore` |
| `rabbitmq` | `rabbitmq:5672` | AMQP for stage queues |
| `petstore` | `petstore:4010` | Webhook / upload sink |
| `petstore-inventory` | `petstore-inventory:4011` | REST source demo |

## Prerequisites

```bash
az login
az group create -n rg-dashflow -l eastus

# Infra (ACR + AKS + …) — or reuse an existing AKS+ACR
az deployment group create \
  --resource-group rg-dashflow \
  --template-file deploy/azure/main.bicep \
  --parameters namePrefix=dfdev mysqlAdminPassword='<strong-password>'

AKS=$(az deployment group show -g rg-dashflow -n main --query properties.outputs.aksName.value -o tsv)
ACR=$(az acr list -g rg-dashflow --query '[0].name' -o tsv)

az aks get-credentials -g rg-dashflow -n "$AKS"
az aks update -g rg-dashflow -n "$AKS" --attach-acr "$ACR"
```

Docker Desktop / Rancher must be able to build and push.

## Build & push images

```bash
chmod +x scripts/azure/*.sh
./scripts/azure/build-push-acr.sh "$ACR" 0.1.0
```

Pushes:

- `$LOGIN_SERVER/dashflow/api:0.1.0`
- `$LOGIN_SERVER/dashflow/ui:0.1.0`
- `$LOGIN_SERVER/dashflow/petstore:0.1.0`
- `$LOGIN_SERVER/dashflow/petstore-inventory:0.1.0`
- `$LOGIN_SERVER/dashflow/plet-*:0.1.0`

## Apply to AKS

```bash
./scripts/azure/apply-aks.sh "$ACR" 0.1.0
kubectl -n dashflow get pods,svc
kubectl -n dashflow get svc dashflow-ui -w   # wait for EXTERNAL-IP
```

Optional: copy `secret.example.yaml` → `secret.yaml` and change passwords before apply (keep AMQP URL in `api.yaml` ConfigMap in sync with RabbitMQ password, or leave demo defaults).

## Demo connector URLs (in-cluster)

Use these in pipeline connectors — **not** `localhost` / `host.docker.internal`:

```text
http://petstore-inventory.dashflow.svc.cluster.local:4011
http://petstore.dashflow.svc.cluster.local:4010
```

## Verify

```bash
kubectl -n dashflow logs deploy/dashflow-api --tail=50
kubectl -n dashflow port-forward svc/dashflow-api 8080:8080
curl -s http://localhost:8080/actuator/health
# After a Run:
kubectl get jobs,pods -A -l dashflow.io/execution_id
```

## Tear down

```bash
kubectl delete namespace dashflow
# optional: kubectl delete clusterrole,clusterrolebinding dashflow-api-pipelet-jobs
```
