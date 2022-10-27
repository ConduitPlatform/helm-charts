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

To expose the service you may use port forwarding:

```console
kubectl port-forward svc/conduit-admin 8000:80
```

For more advanced options, there is also support for Ingress as well as NodePort and LoadBalancer configurations.

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

## Values

## General
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nameOverride | string | `"conduit"` | Provide a name in place of `conduit` |
| fullnameOverride | string | `""` | String to fully override `"conduit-helm.fullname"` |
| kubeVersionOverride | string | `""` | Override the Kubernetes version, which is used to evaluate certain manifests |
| apiVersionOverrides | object | `{"ingress":""}` | Override for the Ingress API version |

## Global section
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.config.conduit_url | string | `""` | Override for "conduit-helm.conduit.url" |
| global.config.grpc_port | int | `5000` | GRPC port |
| global.config.metrics_port | int | `9100` | Metrics port, used for Prometheus |
| global.image.imagePullPolicy | string | `"Always"` | If defined, a imagePullPolicy applied to all Conduit deployments |
| global.image.repository | string | `"conduitplatform"` | Global repository option |
| global.image.tag | string | `"latest"` | Overrides the global Conduit image tag whose default is the chart appVersion |
| global.secret.GRPC_KEY | string | `nil` | Optional GRPC Key override. Must be given in b64 format. |
| global.secret.MASTER_KEY | string | `nil` | Master Secret override. Must be given in b64 format. |
| global.secret.grpc_enable | bool | `true` | Optional GRPC Key option |

## Install object
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| install | object | `{"authentication":{"enabled":true,"image":{"name":"authentication"},"metrics":{"enabled":true}},"chat":{"enabled":true,"image":{"name":"chat"},"metrics":{"enabled":true}},"email":{"enabled":true,"image":{"name":"email"},"metrics":{"enabled":true}},"forms":{"enabled":true,"image":{"name":"forms"},"metrics":{"enabled":true}},"notification":{"enabled":true,"image":{"name":"push-notifications"},"metrics":{"enabled":true}},"sms":{"enabled":true,"image":{"name":"sms"},"metrics":{"enabled":true}},"storage":{"enabled":true,"image":{"name":"storage"},"metrics":{"enabled":true}}}` | Choosing which microservices you want deployed (except for Admin-UI, Core, Database and Router) |

## Module settings to apply to all services of the install object
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| module-settings | object | | Default module settings for the microservices (except Admin-UI, Core, Database, Router) |
| module-settings.annotations | list | `[]` | Extra annotations |
| module-settings.containerPort | int | `5000` | Configure for the container port |
| module-settings.env | list | `[]` | Extra environment variables |
| module-settings.envFrom | list | `[]` | Extra envFrom |
| module-settings.extraArgs | list | `[]` | Additional command line arguments |
| module-settings.extraContainers | list | `[]` | Additional containers to be added |
| module-settings.initContainers | list | `[]` | Init containers |
| module-settings.metrics.service.name | string | `"metrics"` | Metrics service name |
| module-settings.metrics.service.port | int | `9100` | Metrics service port |
| module-settings.metrics.service.targetPort | int | `9100` | Metrics service port |
| module-settings.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| module-settings.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| module-settings.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| module-settings.metrics.serviceMonitor.name | string | `nil` | Optional name override |
| module-settings.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| module-settings.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| module-settings.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| module-settings.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| module-settings.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| module-settings.podAnnotations | object | `{}` | Annotations |
| module-settings.podLabels | object | `{}` | Labels |
| module-settings.replicas | int | `1` | Number of pods to run |
| module-settings.resources | object | `{"limits":{"cpu":"200m","memory":"500Mi"},"requests":{"cpu":"100m","memory":"300Mi"}}` | Resource limits and requests |
| module-settings.service | object | `{"annotations":{},"labels":{},"tcp_port":5000}` | Service configuration |
| module-settings.service.annotations | object | `{}` | Service annotations |
| module-settings.service.labels | object | `{}` | Service labels |
| module-settings.service.tcp_port | int | `5000` | Service tcp port |
| module-settings.volumeMounts | list | `[]` | Additional volumeMounts |
| module-settings.volumes | list | `[]` | Additional volumes |

## Admin UI
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| admin.annotations | list | `[]` | Extra annotations |
| admin.enabled | bool | `true` | Optional module. |
| admin.env | list | `[]` | Extra environment variables to pass to the Admin Panel |
| admin.envFrom | list | `[]` | Extra envFrom to pass to the Admin Panel |
| admin.extraArgs | list | `[]` | Additional command line arguments to pass to the admin pod |
| admin.extraContainers | list | `[]` | Additional containers to be added to the admin pod |
| admin.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the Admin Panel image |
| admin.image.name | string | `"conduit-ui"` | Image name |
| admin.image.repository | string | `""` | Intended images are from Dockerhub registry. Reminder: use tag latest for them. |
| admin.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the Admin Panel image |
| admin.ingress | object | `{"annotations":null,"enabled":false,"extraPaths":[],"hostName":"","tls":[]}` | Enable an ingress resource for the Admin Panel |
| admin.ingress.annotations | string | `nil` | Additional ingress annotations |
| admin.ingress.extraPaths | list | `[]` | Additional ingress paths |
| admin.ingress.hostName | string | `""` | Hostnames must be provided if Ingress is enabled. |
| admin.ingress.ingressClassName | string | `""` | Defines which ingress controller will implement the resource |
| admin.ingress.tls | list | `[]` | Ingress TLS configuration |
| admin.initContainers | list | `[]` | Init containers to add to the admin pod |
| admin.name | string | `"admin"` | Admin Panel name |
| admin.podAnnotations | object | `{}` | Annotations to be added to admin pods |
| admin.podLabels | object | `{}` | Labels to be added to admin pods |
| admin.replicas | int | `1` | Number of Admin Panel pods to run |
| admin.resources | object | `{"limits":{"cpu":"200m","memory":"500Mi"},"requests":{"cpu":"100m","memory":"300Mi"}}` | Resource limits and requests for the Admin Panel |
| admin.service.annotations | object | `{}` | Admin service annotations |
| admin.service.http_port | int | `80` | Admin service http port |
| admin.service.labels | object | `{}` | Admin service labels |
| admin.service.loadBalancerIP | string | `""` | LoadBalancer will get created with the IP specified in this field |
| admin.service.nodePort | int | `31867` | Admin service http port for NodePort service type (only if `admin.service.type` is set to "NodePort") |
| admin.service.type | string | `"ClusterIP"` | Admin service type |
| admin.volumeMounts | list | `[]` | Additional volumeMounts to the Admin main container |
| admin.volumes | list | `[]` | Additional volumes to the Admin pod |

## Core
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| core.annotations | list | `[]` | Extra annotations |
| core.containerPort | int | `5000` | Configure for the container port |
| core.env | list | `[]` | Extra environment variables to pass to the core |
| core.envFrom | list | `[]` | Extra envFrom to pass to the core |
| core.extraArgs | list | `[]` | Additional command line arguments to pass to the core pod |
| core.extraContainers | list | `[]` | Additional containers to be added to the core pod |
| core.hostName | string | `""` | Alternative option for the host URL if ingress host is not defined. |
| core.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the Core image |
| core.image.name | string | `"conduit"` | Image name |
| core.image.repository | string | `""` | Intended images are from Dockerhub registry. Reminder: use tag latest for them. |
| core.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the Core image |
| core.ingress | object | `{"annotations":null,"enabled":false,"extraPaths":[],"hostName":"","tls":[]}` | Enable an ingress resource for the Core |
| core.ingress.annotations | string | `nil` | Additional ingress annotations |
| core.ingress.extraPaths | list | `[]` | Additional ingress paths |
| core.ingress.hostName | string | `""` | Hostnames must be provided if Ingress is enabled. |
| core.ingress.ingressClassName | string | `""` | Defines which ingress controller will implement the resource |
| core.ingress.tls | list | `[]` | Ingress TLS configuration |
| core.initContainers | list | `[]` | Init containers to add to the core pod |
| core.metrics.enabled | bool | `true` | Deploy metrics service |
| core.metrics.service.name | string | `"metrics"` | Metrics service name |
| core.metrics.service.port | int | `9100` | Metrics service port |
| core.metrics.service.targetPort | int | `9100` | Metrics service port |
| core.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| core.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| core.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| core.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| core.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| core.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| core.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| core.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| core.name | string | `"core"` | Core name |
| core.podAnnotations | object | `{}` | Annotations to be added to core pods |
| core.podLabels | object | `{}` | Labels to be added to core pods |
| core.replicas | int | `1` | Number of Core pods to run |
| core.resources | object | `{"limits":{"cpu":"200m","memory":"500Mi"},"requests":{"cpu":"100m","memory":"300Mi"}}` | Resource limits and requests for Core |
| core.service.annotations | object | `{}` | Core service annotations |
| core.service.grpc_port | int | `55152` | Core service grpc port |
| core.service.labels | object | `{}` | Core service labels |
| core.service.loadBalancerIP | string | `""` | LoadBalancer will get created with the IP specified in this field |
| core.service.nodePort | int | `31868` | Core service http port for NodePort service type (only if `core.service.type` is set to "NodePort") |
| core.service.socket_port | int | `3001` | Core service socket port |
| core.service.tcp_port | int | `80` | Core service tcp port |
| core.service.type | string | `"ClusterIP"` | Core service type |
| core.volumeMounts | list | `[]` | Additional volumeMounts to the core main container |
| core.volumes | list | `[]` | Additional volumes to the core pod |

## Database
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| database.annotations | list | `[]` | Extra annotations |
| database.containerPort | int | `5000` | Configure for the container port |
| database.env | list | `[]` | Extra environment variables to pass to the database |
| database.envFrom | list | `[]` | Extra envFrom to pass to the database |
| database.extraArgs | list | `[]` | Additional command line arguments to pass to the database pod |
| database.extraContainers | list | `[]` | Additional containers to be added to the database pod |
| database.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the Database image |
| database.image.name | string | `"database"` | Image name |
| database.image.repository | string | `""` | Intended images are from Dockerhub registry. Reminder: use tag latest for them. |
| database.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the Database image |
| database.initContainers | list | `[]` | Init containers to add to the database pod |
| database.metrics.enabled | bool | `true` | Deploy metrics service |
| database.metrics.service.name | string | `"metrics"` | Metrics service name |
| database.metrics.service.port | int | `9100` | Metrics service port |
| database.metrics.service.targetPort | int | `9100` | Metrics service port |
| database.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| database.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| database.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| database.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| database.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| database.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| database.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| database.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| database.name | string | `"database-provider"` | Database name |
| database.podAnnotations | object | `{}` | Annotations to be added to database pods |
| database.podLabels | object | `{}` | Labels to be added to database pods |
| database.replicas | int | `1` | Number of Database pods to run |
| database.resources | object | `{"limits":{"cpu":"1000m","memory":"500Mi"},"requests":{"cpu":"100m","memory":"300Mi"}}` | Resource limits and requests for Database |
| database.service.annotations | object | `{}` | Database service annotations |
| database.service.labels | object | `{}` | Database service labels |
| database.service.tcp_port | int | `5000` | Database service tcp port |
| database.volumeMounts | list | `[]` | Additional volumeMounts to the database main container |
| database.volumes | list | `[]` | Additional volumes to the database pod |

## Router
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| router.annotations | list | `[]` | Extra annotations |
| router.containerPort | int | `5000` | Configure for the container port |
| router.enabled | bool | `true` | Optional module. |
| router.env | list | `[]` | Extra environment variables to pass to the router |
| router.envFrom | list | `[]` | Extra envFrom to pass to the router |
| router.extraArgs | list | `[]` | Additional command line arguments to pass to the router pod |
| router.extraContainers | list | `[]` | Additional containers to be added to the router pod |
| router.hostName | string | `""` | Alternative option for the host URL if ingress host is not defined. |
| router.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the Router image |
| router.image.name | string | `"router"` | Image name |
| router.image.repository | string | `""` | Intended images are from Dockerhub registry. Reminder: use tag latest for them. |
| router.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the Router image |
| router.ingress | object | `{"annotations":null,"enabled":false,"extraPaths":[],"hostName":"","tls":[]}` | Enable an ingress resource for the Router |
| router.ingress.annotations | string | `nil` | Additional ingress annotations |
| router.ingress.extraPaths | list | `[]` | Additional ingress paths |
| router.ingress.hostName | string | `""` | Hostnames must be provided if Ingress is enabled. |
| router.ingress.ingressClassName | string | `""` | Defines which ingress controller will implement the resource |
| router.ingress.tls | list | `[]` | Ingress TLS configuration |
| router.initContainers | list | `[]` | Init containers to add to the router pod |
| router.metrics.enabled | bool | `true` | Deploy metrics service |
| router.metrics.service.name | string | `"metrics"` | Metrics service name |
| router.metrics.service.port | int | `9100` | Metrics service port |
| router.metrics.service.targetPort | int | `9100` | Metrics service port |
| router.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| router.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| router.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| router.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| router.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| router.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| router.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| router.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| router.name | string | `"router"` | Router name |
| router.podAnnotations | object | `{}` | Annotations to be added to router pods |
| router.podLabels | object | `{}` | Labels to be added to router pods |
| router.replicas | int | `1` | Number of Router pods to run |
| router.resources | object | `{"limits":{"cpu":"200m","memory":"500Mi"},"requests":{"cpu":"100m","memory":"300Mi"}}` | Resource limits and requests for Router |
| router.service.annotations | object | `{}` | Router service annotations |
| router.service.grpc_port | int | `5000` | Router service grpc port |
| router.service.labels | object | `{}` | Router service labels |
| router.service.loadBalancerIP | string | `""` | LoadBalancer will get created with the IP specified in this field |
| router.service.nodePort | int | `31869` | Router service http port for NodePort service type (only if `router.service.type` is set to "NodePort") |
| router.service.socket_port | int | `3001` | Router service socket port |
| router.service.tcp_port | int | `80` | Router service tcp port |
| router.service.type | string | `"ClusterIP"` | Router service type |
| router.volumeMounts | list | `[]` | Additional volumeMounts to the router main container |
| router.volumes | list | `[]` | Additional volumes to the router pod |

## Redis
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| redis.annotations | list | `[]` | Extra annotations |
| redis.enabled | bool | `true` | Optional module. If set to false, you may specify an external redis URL in the following section. |
| redis.env | list | `[]` | Extra environment variables to pass to the redis |
| redis.envFrom | list | `[]` | Extra envFrom to pass to the redis |
| redis.extraArgs | list | `[]` | Additional command line arguments to pass to the redis pod |
| redis.extraContainers | list | `[]` | Additional containers to be added to the redis pod |
| redis.image.imagePullPolicy | string | IfNotPresent | Image pull policy for the redis image. |
| redis.image.tag | string | `"latest"` | Tag to use for the redis image |
| redis.initContainers | list | `[]` | Init containers to add to the redis pod |
| redis.name | string | `"redis"` | Redis name |
| redis.podAnnotations | object | `{}` | Annotations to be added to redis pods |
| redis.podLabels | object | `{}` | Labels to be added to redis pods |
| redis.replicas | int | `1` | Number of Redis pods to run |
| redis.service | object | `{"annotations":{},"labels":{}}` | Storage service configuration |
| redis.service.annotations | object | `{}` | Storage service annotations |
| redis.service.labels | object | `{}` | Storage service labels |
| redis.volumeMounts | list | `[]` | Additional volumeMounts to the redis main container |
| redis.volumes | list | `[]` | Additional volumes to the redis pod |

## External Redis
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| externalRedis.host | string | `""` | External Redis server URL |
| externalRedis.password | string | `""` | External Redis password |
| externalRedis.port | int | `6379` | External Redis server port |
| externalRedis.secretAnnotations | object | `{}` | External Redis Secret annotations |
| externalRedis.existingSecret | string | `""` | The name of an existing secret with Redis credentials (must contain key `redis-password`). When it's set, the `externalRedis.password` parameter is ignored |

## MongoDB
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| mongodb.annotations | list | `[]` | Extra annotations |
| mongodb.enabled | bool | `true` | Optional module. If set to false, specify an external MongoDB or Postgres URL in the following section. |
| mongodb.env | list | `[]` | Extra environment variables to pass to the mongodb |
| mongodb.envFrom | list | `[]` | Extra envFrom to pass to the mongodb |
| mongodb.extraArgs | list | `[]` | Additional command line arguments to pass to the mongo pod |
| mongodb.extraContainers | list | `[]` | Additional containers to be added to the mongo pod |
| mongodb.image.imagePullPolicy | string | IfNotPresent | Image pull policy for the mongo image. |
| mongodb.image.tag | string | `"latest"` | Tag to use for the mongo image |
| mongodb.initContainers | list | `[]` | Init containers to add to the mongo pod |
| mongodb.name | string | `"mongodb"` | MongoDB name |
| mongodb.podAnnotations | object | `{}` | Annotations to be added to mongo pods |
| mongodb.podLabels | object | `{}` | Labels to be added to mongo pods |
| mongodb.port | int | `27017` | Configure for the container port |
| mongodb.replicas | int | `1` | Number of Mongo pods to run |
| mongodb.service | object | `{"annotations":{},"labels":{}}` | Mongo service configuration |
| mongodb.service.annotations | object | `{}` | Mongo service annotations |
| mongodb.service.labels | object | `{}` | Mongo service labels |
| mongodb.volumeMounts | list | `[]` | Additional volumeMounts to the mongodb main container |
| mongodb.volumes | list | `[]` | Additional volumes to the mongodb pod |

## External Database
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| externalDatabase | object | `{"type":"","url":""}` | External Database section |
| externalDatabase.type | string | `""` | Database type. Can be 'mongodb' or 'postgres'. |
| externalDatabase.url | string | `""` | URL for external Mongo or Postgres DB. Must be given in b64 format. |

## Loki
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| loki.loki.auth_enabled | bool | `false` | Single tenant deployment needed for loki |
| loki.loki.commonConfig | object | `{"replication_factor":1}` | The following sections are needed to deploy loki with the bare minimum |
| loki.loki.server | object | `{"http_listen_port":3100}` | Override for Loki service port |
| loki.monitoring | object | `{"selfMonitoring":{"enabled":false,"grafanaAgent":{"installOperator":false},"lokiCanary":{"enabled":false}}}` | Self Monitoring disabled by default. You may enable it for additional logs |

## External Loki
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| externalLoki | object | `{"url":""}` | External Loki section |

## Prometheus
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| prometheus | object | `{"server":{"service":{"servicePort":9100}},"setup":true}` | Prometheus dependency configuration |
| prometheus.server | object | `{"service":{"servicePort":9100}}` | Override for Prometheus service port |

## External Prometheus
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| externalPrometheus | object | `{"url":""}` | External Prometheus section |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.8.1](https://github.com/norwoodj/helm-docs/releases/v1.8.1)