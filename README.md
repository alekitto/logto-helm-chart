# Logto helm charts

This Logto Chart is the best way to deploy Logto (https://logto.io/) on Kubernetes.

## Usage

```bash
helm pull oci://ghcr.io/alekitto/logto-helm-chart/logto --version 1.0.0
helm install logto oci://ghcr.io/alekitto/logto-helm-chart/logto --version 1.0.0 --set database.dsn=$DATABASE_URL
```

access the logto service by port-forwarding

** If you want to use another port or domain, please set value `admin.endpoint` **
```bash
kubectl port-forward svc/logto-admin 3002:3002
```
