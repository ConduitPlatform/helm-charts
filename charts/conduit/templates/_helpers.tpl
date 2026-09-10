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
Embeddings workload, image, Storage, and convict-limit guards
*/}}
{{- define "conduit-helm.validateEmbeddings" -}}
{{- $embeddings := default dict .Values.install.embeddings -}}
{{- if and $embeddings.enabled (not .Values.global.secret.grpc_enable) -}}
{{- fail "install.embeddings.enabled=true requires global.secret.grpc_enable=true so GRPC_KEY is mounted" -}}
{{- end -}}
{{- $embImage := default dict $embeddings.image -}}
{{- $embTag := default "" $embImage.tag -}}
{{- if and $embeddings.enabled (or (eq $embTag "") (eq $embTag .Chart.AppVersion)) -}}
{{- fail (printf "install.embeddings.enabled=true requires install.embeddings.image.tag set to a published embeddings image; Chart.appVersion %s does not include embeddings" .Chart.AppVersion) -}}
{{- end -}}
{{- if and $embeddings.enabled $embeddings.requireStorage (not .Values.install.storage.enabled) -}}
{{- fail "install.embeddings.requireStorage=true requires install.storage.enabled=true" -}}
{{- end -}}
{{- $config := default dict $embeddings.config -}}
{{- if and $config.enabled (not $embeddings.enabled) -}}
{{- fail "install.embeddings.config.enabled=true requires install.embeddings.enabled=true" -}}
{{- end -}}
{{- $providers := default dict $config.providers -}}
{{- $openai := default dict (index $providers "openai-compatible") -}}
{{- if $openai.apiKey -}}
{{- fail "install.embeddings.config.providers.openai-compatible.apiKey is not allowed; set install.embeddings.secrets.providers.openai-compatible.apiKey" -}}
{{- end -}}
{{- if $embeddings.enabled -}}
{{- include "conduit-helm.validateEmbeddingsLimits" $config -}}
{{- end -}}
{{- end -}}

{{/*
Convict limit checks. chunkOverlapBytes may be zero; other limits must be > 0.
*/}}
{{- define "conduit-helm.validateEmbeddingsLimits" -}}
{{- $config := . -}}
{{- $queue := default dict $config.queue -}}
{{- $security := default dict $config.security -}}
{{- $extraction := default dict $config.storageExtraction -}}
{{- $positive := dict
  "queue.concurrency" $queue.concurrency
  "queue.attempts" $queue.attempts
  "queue.maxBatchSize" $queue.maxBatchSize
  "queue.drainTimeoutMs" $queue.drainTimeoutMs
  "security.maxMutationEventIds" $security.maxMutationEventIds
  "security.embedTimeoutMs" $security.embedTimeoutMs
  "security.maxEmbedInputBytes" $security.maxEmbedInputBytes
  "security.maxEmbedResponseBytes" $security.maxEmbedResponseBytes
  "security.maxIngestBatchSize" $security.maxIngestBatchSize
  "security.maxChunksPerDocument" $security.maxChunksPerDocument
  "security.maxChunkTextBytes" $security.maxChunkTextBytes
  "security.maxMetadataBytes" $security.maxMetadataBytes
  "security.maxReferenceBytes" $security.maxReferenceBytes
  "security.sourceSearchMaxLimit" $security.sourceSearchMaxLimit
  "storageExtraction.maxFileBytes" $extraction.maxFileBytes
  "storageExtraction.maxExtractedBytes" $extraction.maxExtractedBytes
  "storageExtraction.maxPdfPages" $extraction.maxPdfPages
  "storageExtraction.extractTimeoutMs" $extraction.extractTimeoutMs
  "storageExtraction.maxChunksPerFile" $extraction.maxChunksPerFile
  "storageExtraction.queueConcurrency" $extraction.queueConcurrency
  "storageExtraction.queueAttempts" $extraction.queueAttempts
-}}
{{- range $name, $value := $positive -}}
{{- include "conduit-helm.assertIntegerBound" (dict "name" $name "value" $value "min" 1) -}}
{{- end -}}
{{- include "conduit-helm.assertIntegerBound" (dict "name" "storageExtraction.chunkOverlapBytes" "value" $extraction.chunkOverlapBytes "min" 0) -}}
{{- $modules := $security.trustedIngestModules -}}
{{- if and $modules (not (kindIs "slice" $modules)) -}}
{{- fail "install.embeddings.config.security.trustedIngestModules must be a list of module names" -}}
{{- end -}}
{{- range $modules -}}
{{- if not (regexMatch "^[A-Za-z][A-Za-z0-9_-]{0,63}$" .) -}}
{{- fail "install.embeddings.config.security.trustedIngestModules entries must be module names" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "conduit-helm.assertIntegerBound" -}}
{{- $value := .value -}}
{{- $name := .name -}}
{{- $min := .min -}}
{{- if or (kindIs "float64" $value) (kindIs "int" $value) (kindIs "int64" $value) -}}
{{- if lt ($value | int) ($min | int) -}}
{{- fail (printf "install.embeddings.config.%s must be an integer >= %d" $name ($min | int)) -}}
{{- end -}}
{{- else if not (empty $value) -}}
{{- fail (printf "install.embeddings.config.%s must be an integer >= %d" $name ($min | int)) -}}
{{- end -}}
{{- end -}}

{{/*
Embeddings Core module config JSON (convict keys, secrets omitted)
*/}}
{{- define "conduit-helm.embeddings.moduleConfig" -}}
{{- $config := deepCopy (default dict .Values.install.embeddings.config) -}}
{{- $providers := default dict $config.providers -}}
{{- $openai := default dict (index $providers "openai-compatible") -}}
{{- $_ := unset $openai "apiKey" -}}
{{- $_ := set $providers "openai-compatible" $openai -}}
{{- $_ := set $config "providers" $providers -}}
{{- $config | toPrettyJson }}
{{- end -}}

{{/*
Optional b64 OpenAI-compatible provider API key from values
*/}}
{{- define "conduit-helm.embeddings.providerApiKey" -}}
{{- $embeddings := default dict .Values.install.embeddings -}}
{{- $secrets := default dict $embeddings.secrets -}}
{{- $providers := default dict $secrets.providers -}}
{{- $openai := default dict (index $providers "openai-compatible") -}}
{{- if $openai.apiKey -}}{{ $openai.apiKey }}{{- end -}}
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
