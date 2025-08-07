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
Create Admin-UI name and version as used by the chart label.
*/}}
{{- define "conduit-helm.admin.fullname" -}}
{{- printf "%s-%s" (include "conduit-helm.fullname" .) .Values.admin.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create Core name and version as used by the chart label.
*/}}
{{- define "conduit-helm.core.fullname" -}}
{{- printf "%s-%s" (include "conduit-helm.fullname" .) .Values.core.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create Database name and version as used by the chart label.
*/}}
{{- define "conduit-helm.database.fullname" -}}
{{- printf "%s-%s" (include "conduit-helm.fullname" .) .Values.database.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create Router name and version as used by the chart label.
*/}}
{{- define "conduit-helm.router.fullname" -}}
{{- printf "%s-%s" (include "conduit-helm.fullname" .) .Values.router.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create Redis name and version as used by the chart label.
*/}}
{{- define "conduit-helm.redis.fullname" -}}
{{- printf "%s-%s" (include "conduit-helm.fullname" .) .Values.redis.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create Mongo name and version as used by the chart label.
*/}}
{{- define "conduit-helm.mongodb.fullname" -}}
{{- printf "%s-%s" (include "conduit-helm.fullname" .) .Values.mongodb.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

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
{{- printf "mongodb://%s-mongodb.%s.svc.cluster.local:%d" (include "conduit-helm.fullname" .) .Release.Namespace (int .Values.mongodb.port) | b64enc -}}
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

{{/*
Create Master Key secret, by either auto-generating one or using one from Values.
*/}} 
{{- define "conduit-helm.master_key" -}}
{{- if .Values.global.secret.MASTER_KEY -}}
{{- printf "%s" .Values.global.secret.MASTER_KEY -}}
{{- else -}}
{{- $existingSecret := lookup "v1" "Secret" .Release.Namespace "conduit-secret" }}
{{- if $existingSecret -}}
{{- $master_key := $existingSecret.data.MASTER_KEY }}
{{- printf "%s" $master_key -}}
{{- else -}}
{{- $master_key := randAlphaNum 32 | b64enc }}
{{- printf "%s" $master_key -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create GRPC Key secret, by either auto-generating one or using one from Values.
*/}}
{{- define "conduit-helm.grpc_key" -}}
{{- if and .Values.global.secret.grpc_enable .Values.global.secret.GRPC_KEY -}}
{{- printf "%s" .Values.global.secret.GRPC_KEY -}}
{{- else if and .Values.global.secret.grpc_enable (not .Values.global.secret.GRPC_KEY) -}}
{{- $existingSecret := lookup "v1" "Secret" .Release.Namespace "conduit-secret" }}
{{- if $existingSecret -}}
{{- $grpc_key := $existingSecret.data.GRPC_KEY }}
{{- printf "%s" $grpc_key -}}
{{- else -}}
{{- $grpc_key := randAlphaNum 32 | b64enc }}
{{- printf "%s" $grpc_key -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create connection string for loki.
*/}} 
{{- define "conduit-helm.loki.url" -}}
{{- if .Values.loki.setup -}}
{{- printf "http://loki.%s.svc.cluster.local:%d" .Release.Namespace (int .Values.loki.loki.server.http_listen_port) -}}
{{- else -}}
{{- printf "%s" .Values.externalLoki.url -}}
{{- end -}}
{{- end -}}

{{/*
Create connection string for Prometheus.
*/}} 
{{- define "conduit-helm.prometheus.url" -}}
{{- if .Values.prometheus.setup -}}
{{- printf "http://%s-prometheus-server.%s.svc.cluster.local:%d" (include "conduit-helm.fullname" .) .Release.Namespace (int .Values.prometheus.server.service.servicePort) -}}
{{- else -}}
{{- printf "%s" .Values.externalPrometheus.url -}}
{{- end -}}
{{- end -}}

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
