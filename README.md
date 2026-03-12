# AutoKube Helm Charts

Official Helm charts for [AutoKube](https://github.com/autokubeio/autokube) — Kubernetes dashboard with AI-powered management.

## Usage

### Add the Helm repository

```bash
helm repo add autokube https://helm.autokube.io
helm repo update
```

### Install AutoKube Dashboard

```bash
helm install autokube autokube/autokube \
  --namespace autokube-system --create-namespace
```

### Install AutoKube Agent

The agent runs inside your target cluster and connects back to the AutoKube dashboard.

```bash
helm install autokube-agent autokube/autokube-agent \
  --namespace autokube-system --create-namespace \
  --set url=https://your-autokube-url \
  --set token=autokube_agent_token_xxxxx
```

## Available Charts

| Chart | Description |
|-------|-------------|
| [autokube](./charts/autokube) | AutoKube dashboard |
| [autokube-agent](./charts/autokube-agent) | In-cluster agent that connects your Kubernetes cluster to AutoKube |

## Configuration

### autokube-agent

| Parameter | Description | Default |
|-----------|-------------|---------|
| `url` | AutoKube dashboard URL (required) | `""` |
| `token` | Agent authentication token (required) | `""` |
| `image.repository` | Agent image repository | `ghcr.io/autokubeio/autokube-agent` |
| `image.tag` | Agent image tag | `latest` |
| `replicaCount` | Number of agent replicas | `1` |
| `rbac.create` | Create RBAC resources | `true` |
| `rbac.namespaceExec.create` | Create namespace-scoped exec roles | `true` |
| `rbac.namespaceExec.namespaces` | Namespaces for exec access | `["default","kube-system"]` |
| `serviceAccount.create` | Create ServiceAccount | `true` |
| `serviceAccount.name` | ServiceAccount name | `autokube-agent` |
| `resources.requests.cpu` | CPU request | `50m` |
| `resources.requests.memory` | Memory request | `64Mi` |
| `resources.limits.cpu` | CPU limit | `200m` |
| `resources.limits.memory` | Memory limit | `128Mi` |

### autokube

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Dashboard image repository | `ghcr.io/autokubeio/autokube` |
| `image.tag` | Dashboard image tag | `latest` |
| `replicaCount` | Number of replicas | `1` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `5173` |
| `ingress.enabled` | Enable ingress | `false` |
| `serviceAccount.create` | Create ServiceAccount | `true` |

## Development

### Lint charts locally

```bash
helm lint charts/autokube-agent
helm lint charts/autokube
```

### Template charts locally

```bash
helm template test charts/autokube-agent \
  --set url=http://localhost:5173 \
  --set token=test_token

helm template test charts/autokube
```


## Installation

### With Helm

```bash
helm repo add autokube https://helm.autokube.io
helm repo update

helm install autokube-agent autokube/autokube-agent \
  --namespace autokube-system --create-namespace \
  --set url=https://your-autokube-url \
  --set token=autokube_agent_token_xxxxx
```

See the [autokube-charts](https://github.com/autokubeio/autokube-charts) repository for all available charts and configuration options.


## Configuration

| Parameter | Env Variable | CLI Flag | Description |
|-----------|-------------|----------|--------------|
| URL | `AUTOKUBE_URL` | `--url` | AutoKube dashboard URL (required) |
| Token | `AUTOKUBE_TOKEN` | `--token` | Agent authentication token (required) |

### Dev-mode Kubernetes overrides

When running outside a cluster (no ServiceAccount token found), the agent checks:

| Env Variable | Description |
|---|---|
| `KUBERNETES_SERVICE_HOST` + `KUBERNETES_SERVICE_PORT` | Connect directly to this K8s API server |
| `KUBE_TOKEN` | Bearer token to use with the above |
| *(fallback)* | `kubectl proxy` on `http://localhost:8001` |

### Custom ClusterRole

If you prefer to manage RBAC yourself, disable chart-managed resources and create your own:

```yaml
# values.yaml
rbac:
  create: false
```

Then apply your own `ClusterRole` and `ClusterRoleBinding`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: my-autokube-agent
rules:
  # Read-only access to all common resources
  - apiGroups: [""]
    resources:
      - namespaces
      - pods
      - pods/log
      - services
      - endpoints
      - configmaps
      - secrets
      - persistentvolumeclaims
      - persistentvolumes
      - nodes
      - events
      - serviceaccounts
    verbs: ["get", "list", "watch"]
  - apiGroups: ["apps"]
    resources:
      - deployments
      - daemonsets
      - replicasets
      - statefulsets
    verbs: ["get", "list", "watch"]
  - apiGroups: ["batch"]
    resources: ["jobs", "cronjobs"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["networking.k8s.io"]
    resources: ["ingresses", "networkpolicies"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["metrics.k8s.io"]
    resources: ["nodes", "pods"]
    verbs: ["get", "list"]

  # Write access for management operations
  - apiGroups: ["apps"]
    resources:
      - deployments
      - statefulsets
      - daemonsets
      - replicasets
      - deployments/scale
      - statefulsets/scale
    verbs: ["patch", "update", "delete"]
  - apiGroups: [""]
    resources:
      - pods
      - pods/eviction
      - services
      - configmaps
      - secrets
    verbs: ["create", "patch", "update", "delete"]

  # Pod exec / terminal access
  - apiGroups: [""]
    resources:
      - pods/exec
      - pods/attach
      - pods/portforward
    verbs: ["create", "get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: my-autokube-agent
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: my-autokube-agent
subjects:
  - kind: ServiceAccount
    name: autokube-agent          # must match serviceAccount.name in values.yaml
    namespace: autokube-system    # must match the install namespace
```


## Release Process

Charts are automatically released when changes are pushed to `main` using [chart-releaser-action](https://github.com/helm/chart-releaser-action). The GitHub Pages site at `helm.autokube.io` serves the Helm repository index.

To release a new version:
1. Update `version` in the chart's `Chart.yaml`
2. Merge to `main`
3. The CI pipeline packages and publishes the chart automatically

## License

[MIT](LICENSE)
