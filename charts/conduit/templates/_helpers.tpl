{{/*
-------------------- Names --------------------
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "conduit-helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "conduit-helm.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "conduit-helm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Join prefix-suffix and trunc to 63 chars.
Usage: include "conduit-helm.resourceName" (dict "prefix" $prefix "suffix" $suffix)
*/}}
{{- define "conduit-helm.resourceName" -}}
{{- printf "%s-%s" .prefix .suffix | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "conduit-helm.admin.fullname" -}}
{{- include "conduit-helm.resourceName" (dict "prefix" (include "conduit-helm.fullname" .) "suffix" .Values.admin.name) }}
{{- end }}

{{- define "conduit-helm.core.fullname" -}}
{{- include "conduit-helm.resourceName" (dict "prefix" (include "conduit-helm.fullname" .) "suffix" .Values.core.name) }}
{{- end }}

{{- define "conduit-helm.database.fullname" -}}
{{- include "conduit-helm.resourceName" (dict "prefix" (include "conduit-helm.fullname" .) "suffix" .Values.database.name) }}
{{- end }}

{{- define "conduit-helm.router.fullname" -}}
{{- include "conduit-helm.resourceName" (dict "prefix" (include "conduit-helm.fullname" .) "suffix" .Values.router.name) }}
{{- end }}

{{- define "conduit-helm.redis.fullname" -}}
{{- include "conduit-helm.resourceName" (dict "prefix" (include "conduit-helm.fullname" .) "suffix" .Values.redis.name) }}
{{- end }}

{{- define "conduit-helm.mongodb.fullname" -}}
{{- include "conduit-helm.resourceName" (dict "prefix" (include "conduit-helm.fullname" .) "suffix" .Values.mongodb.name) }}
{{- end }}

{{/*
-------------------- Configs --------------------
*/}}

{{/*
Create Conduit core default host.
*/}}
{{- define "conduit-helm.core.default_host" -}}
{{- if and .Values.core.ingress.enabled .Values.core.ingress.hostName (not .Values.core.ingress.tls) }}
{{- printf "http://%s" .Values.core.ingress.hostName -}}
{{- else if and .Values.core.ingress.enabled .Values.core.ingress.hostName .Values.core.ingress.tls -}}
{{- printf "https://%s" .Values.core.ingress.hostName -}}
{{- else -}}
{{- printf "%s" .Values.core.hostName -}}
{{- end -}}
{{- end -}}

{{/*
Create Conduit router default host.
*/}}
{{- define "conduit-helm.router.default_host" -}}
{{- if and .Values.router.ingress.enabled .Values.router.ingress.hostName (not .Values.router.ingress.tls) }}
{{- printf "http://%s" .Values.router.ingress.hostName -}}
{{- else if and .Values.router.ingress.enabled .Values.router.ingress.hostName .Values.router.ingress.tls -}}
{{- printf "https://%s" .Values.router.ingress.hostName -}}
{{- else -}}
{{- printf "%s" .Values.router.hostName -}}
{{- end -}}
{{- end -}}

{{/*
Create Conduit API URL which is used by the admin module.
*/}}
{{- define "conduit-helm.conduit.api" -}}
{{- if and .Values.core.ingress.enabled (not .Values.core.ingress.tls) }}
{{- printf "http://%s" .Values.core.ingress.hostName -}}
{{- else if and .Values.core.ingress.enabled .Values.core.ingress.tls -}}
{{- printf "https://%s" .Values.core.ingress.hostName  -}}
{{- end -}}
{{- end -}}

{{/*
Create Conduit URL which is used by the admin module.
*/}}
{{- define "conduit-helm.conduit.url" -}}
{{- if (not .Values.global.config.conduit_url) -}}
{{- printf "http://%s.%s.svc.cluster.local:%d" (include "conduit-helm.core.fullname" .) .Release.Namespace (int .Values.core.service.tcp_port) -}}
{{- else -}}
{{- printf "%s" .Values.global.config.conduit_url -}}
{{- end -}}
{{- end -}}

{{/*
Create connection URI for database.
*/}}
{{- define "conduit-helm.db.uri" -}}
{{- if .Values.mongodb.enabled -}}
{{- printf "mongodb://%s.%s.svc.cluster.local:%d" (include "conduit-helm.mongodb.fullname" .) .Release.Namespace (int .Values.mongodb.port) | b64enc -}}
{{- else -}}
{{- printf "%s" .Values.externalDatabase.url -}}
{{- end -}}
{{- end -}}

{{/*
Create database type variable.
*/}}
{{- define "conduit-helm.db.type" -}}
{{- if .Values.mongodb.enabled -}}
{{- printf "mongodb" -}}
{{- else -}}
{{- printf "%s" .Values.externalDatabase.type -}}
{{- end -}}
{{- end -}}

{{- define "conduit-helm.redis.passwordSecretName" -}}
{{- if .Values.externalRedis.existingSecret -}}
{{- .Values.externalRedis.existingSecret -}}
{{- else -}}
{{- include "conduit-helm.resourceName" (dict "prefix" (include "conduit-helm.fullname" .) "suffix" "redis") }}
{{- end -}}
{{- end }}

{{- define "conduit-helm.secretName" -}}
{{- if .Values.global.secret.existingSecret -}}
{{- .Values.global.secret.existingSecret -}}
{{- else -}}
{{- include "conduit-helm.resourceName" (dict "prefix" (include "conduit-helm.fullname" .) "suffix" "secret") }}
{{- end -}}
{{- end }}

{{- define "conduit-helm.lookupSecretKey" -}}
{{- $name := include "conduit-helm.secretName" .root -}}
{{- $found := lookup "v1" "Secret" .root.Release.Namespace $name | default dict -}}
{{- $data := $found.data | default dict -}}
{{- if not (hasKey $data .key) -}}
{{- $found = lookup "v1" "Secret" .root.Release.Namespace "conduit-secret" | default dict -}}
{{- $data = $found.data | default dict -}}
{{- end -}}
{{- if hasKey $data .key -}}
{{- index $data .key -}}
{{- end -}}
{{- end }}

{{- define "conduit-helm.master_key" -}}
{{- if .Values.global.secret.MASTER_KEY -}}
{{- .Values.global.secret.MASTER_KEY -}}
{{- else -}}
{{- $existing := include "conduit-helm.lookupSecretKey" (dict "root" . "key" "MASTER_KEY") -}}
{{- if $existing -}}
{{- $existing -}}
{{- else -}}
{{- randAlphaNum 32 | b64enc -}}
{{- end -}}
{{- end -}}
{{- end }}

{{- define "conduit-helm.grpc_key" -}}
{{- if and .Values.global.secret.grpc_enable .Values.global.secret.GRPC_KEY -}}
{{- .Values.global.secret.GRPC_KEY -}}
{{- else if .Values.global.secret.grpc_enable -}}
{{- $existing := include "conduit-helm.lookupSecretKey" (dict "root" . "key" "GRPC_KEY") -}}
{{- if $existing -}}
{{- $existing -}}
{{- else -}}
{{- randAlphaNum 32 | b64enc -}}
{{- end -}}
{{- end -}}
{{- end }}

{{- define "conduit-helm.loki.serviceName" -}}
{{- if contains "loki" .Release.Name -}}
{{- .Release.Name -}}
{{- else -}}
{{- printf "%s-loki" .Release.Name -}}
{{- end -}}
{{- end }}

{{- define "conduit-helm.prometheus.serviceName" -}}
{{- if contains "prometheus" .Release.Name -}}
{{- printf "%s-server" .Release.Name -}}
{{- else -}}
{{- printf "%s-prometheus-server" .Release.Name -}}
{{- end -}}
{{- end }}

{{- define "conduit-helm.loki.url" -}}
{{- if .Values.loki.setup -}}
{{- $port := 3100 -}}
{{- if and .Values.loki.loki .Values.loki.loki.server .Values.loki.loki.server.http_listen_port -}}
{{- $port = .Values.loki.loki.server.http_listen_port -}}
{{- end -}}
{{- printf "http://%s.%s.svc.cluster.local:%d" (include "conduit-helm.loki.serviceName" .) .Release.Namespace (int $port) -}}
{{- else -}}
{{- .Values.externalLoki.url -}}
{{- end -}}
{{- end }}

{{- define "conduit-helm.prometheus.url" -}}
{{- if .Values.prometheus.setup -}}
{{- printf "http://%s.%s.svc.cluster.local:%d" (include "conduit-helm.prometheus.serviceName" .) .Release.Namespace (int .Values.prometheus.server.service.servicePort) -}}
{{- else -}}
{{- .Values.externalPrometheus.url -}}
{{- end -}}
{{- end }}

{{- define "conduit-helm.image" -}}
{{- if .digest -}}
{{- printf "%s@%s" .repository .digest -}}
{{- else -}}
{{- printf "%s:%s" .repository (default "latest" .tag) -}}
{{- end -}}
{{- end }}

{{- define "conduit-helm.appImage" -}}
{{- $repo := printf "%s/%s" (default .root.Values.global.image.repository .component.image.repository) .component.image.name -}}
{{- $tag := default .root.Chart.AppVersion (default .root.Values.global.image.tag .component.image.tag) -}}
{{- $digest := default .root.Values.global.image.digest .component.image.digest -}}
{{- include "conduit-helm.image" (dict "repository" $repo "tag" $tag "digest" $digest) -}}
{{- end }}

{{- define "conduit-helm.containerSecurityContext" -}}
{{- $ctx := .component.securityContext | default .root.Values.securityContext -}}
{{- if not (empty $ctx) }}
securityContext:
  {{- toYaml $ctx | nindent 2 }}
{{- end }}
{{- end }}

{{- define "conduit-helm.podSecurityContext" -}}
{{- $ctx := .component.podSecurityContext | default .root.Values.podSecurityContext -}}
{{- if not (empty $ctx) }}
securityContext:
  {{- toYaml $ctx | nindent 2 }}
{{- end }}
{{- end }}

{{- define "conduit-helm.boolOr" -}}
{{- if kindIs "bool" .override -}}
{{- .override -}}
{{- else -}}
{{- .fallback -}}
{{- end -}}
{{- end }}

{{/*
-------------------- Labels --------------------
*/}}

{{/*
Common labels
*/}}
{{- define "conduit-helm.labels" -}}
helm.sh/chart: {{ include "conduit-helm.chart" . }}
{{ include "conduit-helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "conduit-helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "conduit-helm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Pod template labels. Omits helm.sh/chart and app.kubernetes.io/version.
*/}}
{{- define "conduit-helm.podLabels" -}}
{{- $root := .root -}}
{{- $app := .app -}}
{{- $extra := default dict .extra -}}
{{ include "conduit-helm.selectorLabels" $root }}
{{- if $app }}
app: {{ $app }}
{{- end }}
{{- if not (empty $extra) }}
{{ toYaml $extra }}
{{- end }}
{{- end }}

{{/*
Validate global image tag version (must be 'latest', 'dev', 'next', or >= Chart.AppVersion)
*/}}
{{- define "conduit-helm.validateImageTag" -}}
{{- $tag := default "" .Values.global.image.tag -}}
{{- $min := .Chart.AppVersion -}}
{{- if and $tag (not (eq $tag "latest")) (not (eq $tag "dev")) (not (eq $tag "next")) (semverCompare (printf "<%s" $min) $tag) -}}
{{- fail (printf "global.image.tag '%s' is not supported by this chart; use 'latest', 'dev', 'next' or %s+" $tag $min) -}}
{{- end -}}
{{- end -}}

{{/*
Reject embeddings workload without GRPC_KEY
*/}}
{{- define "conduit-helm.validateEmbeddings" -}}
{{- $embeddings := default dict .Values.install.embeddings -}}
{{- if and $embeddings.enabled (not .Values.global.secret.grpc_enable) -}}
{{- fail "install.embeddings.enabled=true requires global.secret.grpc_enable=true so GRPC_KEY is mounted" -}}
{{- end -}}
{{- end -}}

{{/*
Return the ServiceAccount name
*/}}
{{- define "conduit-helm.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "conduit-helm.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- printf "%s" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
-------------------- Versions --------------------
*/}}

{{/*
Return the appropriate apiVersion for ingress
*/}}
{{- define "conduit-helm.ingress.apiVersion" -}}
{{- if .Values.apiVersionOverrides.ingress -}}
{{- print .Values.apiVersionOverrides.ingress -}}
{{- else if semverCompare "<v1.19.x" (include "conduit-helm.kubeVersion" $) -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the target Kubernetes version
*/}}
{{- define "conduit-helm.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.kubeVersionOverride }}
{{- end -}}

{{/*
affinity / tolerations / nodeSelector: component > module-settings > global
*/}}
{{- define "conduit-helm.podScheduling" -}}
{{- $root := .root -}}
{{- $component := default dict .component -}}
{{- $moduleSettings := default dict .moduleSettings -}}
{{- $global := default dict $root.Values.global -}}
{{- $affinity := $component.affinity | default $moduleSettings.affinity | default $global.affinity -}}
{{- $tolerations := $component.tolerations | default $moduleSettings.tolerations | default $global.tolerations -}}
{{- $nodeSelector := $component.nodeSelector | default $moduleSettings.nodeSelector | default $global.nodeSelector -}}
{{- if not (empty $affinity) }}
affinity:
  {{- toYaml $affinity | nindent 2 }}
{{- end }}
{{- if not (empty $tolerations) }}
tolerations:
  {{- toYaml $tolerations | nindent 2 }}
{{- end }}
{{- if not (empty $nodeSelector) }}
nodeSelector:
  {{- toYaml $nodeSelector | nindent 2 }}
{{- end }}
{{- end -}}
