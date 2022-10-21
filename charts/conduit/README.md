# Conduit 

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.14.7](https://img.shields.io/badge/AppVersion-0.14.7-informational?style=flat-square)

Conduit is a NodeJS-based Self-Hosted backend, that aims to cut down development times by providing ready-made modules that offer common functionality out of the box, and allowing maximum flexibility to add custom functionality.

This chart bootstraps a [Conduit](https://getconduit.dev/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Get Repo Info

```console
helm repo add conduit-platform https://conduitplatform.github.io/helm-charts/
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
helm install [RELEASE_NAME] conduit-platform/conduit
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Dependencies

By default this chart installs additional, dependent charts:

- [loki](https://github.com/grafana/loki/tree/main/production/helm/loki)

- [prometheus](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus)

To disable the dependencies during installation, set `loki.setup` and `prometheus.setup` respectively to `false`.

_See [helm dependency](https://helm.sh/docs/helm/helm_dependency/) for command documentation._

_See also [deployment options](#Deployment-options) below._

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values [RELEASE_NAME]
```
 
## Accessing the application 

You may access Conduit through the Admin panel by setting .Values.admin.enabled to true.

To expose the service, Ingress method is preferred, but there are options for NodePort and LoadBalancer configurations aswell.

After reaching the UI the first time you can login with username: admin and password: admin. 

## Deployment options

1. Redis (required)

a) Default Redis image. Set `.Values.redis.enabled` to `true`, for this option.

b) External Redis. Set the `.Values.externalRedis.host` and the related values (port, password etc), for this option.

2. Database (required)

a) Default Mongo image. Set `.Values.mongodb.enabled` to `true`, for this option.

b) External Database, Mongo or Postgres. Set the `.Values.externalDatabase.url` along with its type, for this option.

3. Loki (optional)

a) Loki chart dependency. Set `.Values.loki.setup` to `true`, for this option.

b) External Loki. Set `.Values.externalLoki.url` to `true`, for this option.

4. Prometheus Metrics (optional)

a) Prometheus chart dependency. Set `.Values.prometheus.setup` to `true`, for this option.

b) External Prometheus. Set `.Values.externalPrometheus.url` to `true`, for this option.

