# Conduit chart correctness audit (0.2.13)

Prioritized findings from a full pass of `charts/conduit`. Items marked **fixed in this PR** are low-risk and behaviour-preserving for default values. Everything else is a recommendation only.

## High

| File | Issue | Fix |
|------|--------|-----|
| `templates/_helpers.tpl` (`master_key` / `grpc_key`), `templates/config/conduit-secret.yaml` | Secret name is hardcoded `conduit-secret` (not release-scoped). Keys are `randAlphaNum` plus `lookup` of that fixed name. `helm template` / first install without a live cluster always emit new keys. Two releases in one namespace collide and can overwrite each other. | Name the Secret with `fullname`. Lookup that name. Prefer `existingSecret` or require values-provided keys. Never regenerate on upgrade. |
| `templates/mongodb/pvc.yaml`, `values.yaml` (`mongodb.persistence`, `mongodb.volumes`) | PVC name defaults to `mongo-pv-claim` (not release-scoped). Size is hardcoded `5Gi` and ignores `mongodb.persistence.size` (`8Gi`) and `storageClass`. | Drive the claim from `mongodb.persistence` (name, size, storageClass, accessModes) using a fullname-based claim. |
| `values.yaml` (`redis.image.tag`, `mongodb.image.tag`, `admin.image.tag`) | Redis, Mongo, and Admin default to `latest`. `IfNotPresent` + `latest` pins an arbitrary digest forever; `Always` + `latest` is non-reproducible. No digest field exists. | Pin semver tags aligned with known-good images. Add optional `digest` that, when set, takes precedence over tag. |
| `values.yaml` (`securityContext`, `podSecurityContext`), `templates/*/deployment.yaml` | Both contexts default to `{}`. Admin, Redis, Mongo, and `wait-for-redis` do not apply the chart `securityContext`. No `runAsNonRoot`, `readOnlyRootFilesystem`, or dropped capabilities. | Set non-root UIDs, drop `ALL`, and use `readOnlyRootFilesystem` plus emptyDir for writable paths. Verify official Redis/Mongo images before forcing a UID. |
| `values.yaml` (`externalRedis.password`, `existingSecret`), `templates/core/deployment.yaml` | Password / existing Secret are documented and unused. Core only sets `REDIS_HOST` / `REDIS_PORT`. | Mount `REDIS_PASSWORD` from values or `existingSecret` (key `redis-password`). Behaviour-changing; do not land with this PR. |
| `templates/services/deployment.yaml`, `templates/services/service.yaml`, `templates/*/*.headless.yaml` | Component helpers trunc to 63, but `{{ fullname }}-{{ module }}`, `{{ fullname }}-{{ module }}-headless`, and `{{ component.fullname }}-headless` append suffixes after truncation. Long release names fail Kubernetes DNS validation. | Add per-resource name helpers that `trunc 63 \| trimSuffix "-"` after the full suffix. Changing names is a breaking upgrade for existing releases. |
| `charts/conduit/` (missing `values.schema.json`) | No JSON schema. Invalid types (for example `module-settings.annotations` is a list, annotations must be a map) fail at apply. | Add `values.schema.json` with required types and `additionalProperties` where maps are open. |

## Medium

| File | Issue | Fix |
|------|--------|-----|
| `values.yaml` (`admin.resources`, `module-settings.resources`) | CPU request `"0"`. Scheduler treats the pod as best-effort/burstable with no CPU guarantee; HPA CPU utilization is meaningless. | Set a small non-zero request (for example `50m`–`100m`) after measuring. |
| `templates/*/deployment.yaml` | Readiness + liveness exist (gRPC on app workloads, HTTP `/` on admin). No `startupProbe`. Slow Node starts can fail liveness. Redis/Mongo have no probes. | Add `startupProbe` (gRPC/HTTP) and Redis `PING` / Mongo `hello` probes. Tune independently of liveness. |
| `templates/redis/deployment.yaml`, `templates/mongodb/deployment.yaml` | No `resources`, `securityContext`, `serviceAccountName`, or `imagePullSecrets`. | Wire the same optional blocks as core. Add resource defaults only after sizing. |
| `templates/hpa.yaml`, `templates/pdb.yaml`, `values.yaml` | HPA and PDB default off and target **core only**. Redis/Mongo with RWO PVCs have no disruption protection. | Per-component HPA/PDB (or a list). Enable PDB at least for single-replica stateful deps. |
| `templates/*/deployment.yaml` | No `strategy` (rollingUpdate). Defaults are fine for stateless; Redis/Mongo + RWO cannot surge. | Set `Recreate` (or a StatefulSet) for RWO workloads; keep RollingUpdate for stateless with optional values. |
| `templates/_helpers.tpl` (`podScheduling`) | Affinity / tolerations / nodeSelector are complete: component → `module-settings` → `global`. No `topologySpreadConstraints`, `priorityClassName`, or `schedulerName`. Chart does not pin arch (correct). | Extend the helper with the same override chain. Empty defaults keep current behaviour. |
| `templates/core/deployment.yaml` (`wait-for-redis`) | Init image has no resources or securityContext. Extra `core.initContainers` previously rendered without an `initContainers:` key (or at the wrong indent) when combined with wait-for-redis. | **Fixed in this PR:** always wrap both sources under `initContainers` at the correct indent. Still recommend resources/securityContext (not added; would change the pod spec). |
| `Chart.yaml` (`dependencies`) | `loki` `3.2.0` is years behind current Grafana Loki charts (6.x). `prometheus` `27.6.0` should be reviewed against current prometheus-community releases. | Bump in a dedicated PR; subchart upgrades are behaviour-changing. |
| `templates/_helpers.tpl` (`loki.url`, `prometheus.url`) | Loki URL is `loki.<ns>.svc` (no release name). Prometheus URL is `{{ fullname }}-prometheus-server`. Subchart services are typically `{{ Release.Name }}-loki` / `{{ Release.Name }}-prometheus-server`. These match only when `fullname == Release.Name` (common `helm install conduit`). | Use subchart service names (`{{ .Release.Name }}-…`) or `fullnameOverride` on the deps. |
| `templates/config/conduit-database-secret.yaml` | Mixes `data` and `stringData`. In-cluster Mongo URI is `b64enc`'d; `externalDatabase.url` is written into `data` and is documented as already base64. Easy to double-encode or store plaintext in `data`. | Single encoding path; `stringData` for the URI or a documented `existingSecret`. |
| `templates/redis/deployment.yaml`, `templates/redis/pvc.yaml` | Redis is a Deployment + RWO PVC. `replicas > 1` cannot schedule. | Convert to StatefulSet (breaking) or lock `replicas: 1` with a fail when persistence is on. |
| `templates/redis/service.yaml`, `templates/mongodb/service.yaml` | Service `selector` includes `selectorLabels` + `app`. Deployment `matchLabels` are `app` only. Works because pods still carry selector labels; a pod that only matches the Deployment selector would miss the Service. | Keep selectors as-is (immutable). Optionally align Service selector to `app` only in a planned upgrade. |
| `templates/config/*.yaml` | ConfigMaps and Secrets have no chart labels. | Add `conduit-helm.labels` on resource metadata only (not on pods). |
| `README.md` / `README.md.gotmpl` | Documents `crds/crd-servicemonitor.yaml`; the chart has no `crds/` directory. | Add the CRD or remove the claim. |
| `templates/core/service.yaml`, `templates/core/deployment.yaml` | Core Service targets container ports `3030` / `3031` / gRPC, but the core container declares no `ports:`. Works, but opaque. | Declare container ports (and names) to match the Service. |
| `templates/database/service.yaml`, `templates/services/service.yaml` | Database and module Service ports are named `tcp` but target the gRPC port. | Rename to `grpc` (Service port name change can break ServiceMonitors / clients that select by name). |
| `templates/admin/deployment.yaml` | Admin does not set `serviceAccountName` or `imagePullSecrets`. | Wire the same optional blocks as core. |
| `values.yaml` (`global.image.tag`) | Templates use `default global.image.tag` and do not fall back to `Chart.AppVersion`. An empty tag renders `repo/name:`. | `default .Chart.AppVersion .Values.global.image.tag`. |

## Low

| File | Issue | Fix |
|------|--------|-----|
| `templates/NOTES.txt` | Port-forward used hardcoded `svc/conduit-admin`. External Loki/Prometheus said “set url to true”. | **Fixed in this PR:** templated admin Service name and HTTP port; URL wording corrected. |
| `templates/*/deployment.yaml` (pod template labels) | `conduit-helm.labels` (including `helm.sh/chart` and `app.kubernetes.io/version`) was on every pod template, so a chart bump rolled all Deployments. No checksum annotations existed (good for version churn; ConfigMap/Secret edits do not roll pods). | **Fixed in this PR:** `conduit-helm.podLabels` = selector labels + component `app` + values `podLabels`. Resource metadata still uses `conduit-helm.labels`. Selectors unchanged. If checksums are added later, hash only that workload’s own ConfigMap/Secret (for example admin → `conduit-admin-cm`, database → `conduit-database-secret`). Do not checksum `conduit-cm` onto every module unless a restart is intended. |
| `templates/redis/deployment.yaml`, `templates/mongodb/deployment.yaml` | Workload `metadata.labels` had only `app`. | **Fixed in this PR:** add `conduit-helm.labels` on Deployment metadata (not on the pod template or selector). |
| `charts/conduit/` (missing `values.schema.json`) | See High. Also blocks `ct lint --validate-chart-schema` if enabled later. | Add schema in a follow-up. |
| `templates/serviceaccount.yaml`, `templates/role.yaml` | SA is created by default; RBAC is off and only `get/list/watch` pods. Fine for current images. | Keep off until a module needs in-cluster API access; then least-privilege rules. |
| `templates/networkpolicy.yaml` | Disabled by default; when on, allow same-namespace ingress/egress. | Keep. Add DNS/egress exceptions when tightening. |
| `values.yaml` (`module-settings.annotations`) | Typed as `[]` but used as a map. Empty list is skipped; a list value would render invalid annotations. | Change default to `{}`. |
| `templates/ingress/*.yaml` | Ingress objects have no common labels. | Add `conduit-helm.labels`. |
| `templates/_helpers.tpl` (`validateImageTag`) | `semverCompare` against tags that may include a `v` prefix or distro suffixes. | Normalize tags before compare. |
| `README.md` (helm-docs table) | Values table can drift from `values.yaml` (Check Docs runs helm-docs v1.9.1). | Regenerate README via helm-docs on every values/chart edit. |

## Scheduling helper (ARM) — completeness

`conduit-helm.podScheduling` is applied on admin, core, database, router, redis, mongodb, and `install.*`. Override order is component → `module-settings` (modules only) → `global`. Defaults are empty; the chart does not pin `kubernetes.io/arch`.

**Present:** `affinity`, `tolerations`, `nodeSelector`.

**Missing (same chain would be behaviour-preserving if added empty):** `topologySpreadConstraints`, `priorityClassName`, `runtimeClassName`, `schedulerName`.

ARM installs should set `global.tolerations` / preferred `nodeAffinity` as in the README. `wait-for-redis` uses multi-arch `busybox:1.36.1` (`nc -z`). Redis/Mongo official images are multi-arch; pin tags rather than `latest` before relying on that.

## Out of scope (not changed)

QuintOps consumer bumps, helm repo index publish, Argo sync, appVersion, dependency version bumps, securityContext defaults, image pin/digest, HPA/PDB expansion, StatefulSet conversion.
