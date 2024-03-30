{{/*
Expand the name of the chart.
*/}}
{{- define "logto.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "logto.fullname" -}}
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
{{- define "logto.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "logto.labels" -}}
helm.sh/chart: {{ include "logto.chart" . }}
{{ include "logto.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "logto.selectorLabels" -}}
app.kubernetes.io/name: {{ include "logto.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "logto.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "logto.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define storge provider configuration to be converted in JSON
*/}}
{{- define "logto.storageProviderJsonStruct" -}}
{{- if eq .Values.storageProvider.type "s3" -}}
provider: S3Storage
bucket: {{ required "Bucket is required when using an S3-compatible storage" .Values.storageProvider.bucket | quote }}
{{- if and .Values.storageProvider.accessKeyId .Values.storageProvider.accessSecretKey }}
accessKeyId: {{ .Values.storageProvider.accessKeyId | quote }}
accessSecretKey: {{ .Values.storageProvider.accessSecretKey | quote }}
{{- end }}
{{- if .Values.storageProvider.region }}
region: {{ .Values.storageProvider.region | quote }}
{{- end }}
{{- if .Values.storageProvider.endpoint }}
region: {{ .Values.storageProvider.endpoint | quote }}
{{- end }}
{{- end }}
{{- if eq .Values.storageProvider.type "azure" -}}
provider: AzureStorage
connectionString: {{ required "ConnectionString is required when using Azure storage" .Values.storageProvider.connectionString | quote }}
container: {{ required "Container is required when using Azure storage" .Values.storageProvider.container | quote }}
{{- end }}
{{- if .Values.storageProvider.publicUrl }}
region: {{ .Values.storageProvider.publicUrl | quote }}
{{- end }}
{{- end }}

{{/*
Define storge provider configuration JSON
*/}}
{{- define "logto.storageProvider" -}}
{{ include "logto.storageProviderJsonStruct" . | fromYaml | toJson }}
{{- end }}

{{/*
Define database DSN
*/}}
{{- define "logto.databaseDSN" -}}
{{- if .Values.database.dsn -}}
{{ .Values.database.dsn | quote }}
{{- end -}}
{{- if not .Values.database.dsn -}}
host={{ required "Database host must be defined" .Values.database.host | squote }}
{{- if .Values.database.port }} port={{ .Values.database.port }}{{- end -}}
{{- if .Values.database.username }} user={{ .Values.database.username | squote }}{{- end -}}
{{- if and (not .Values.database.password.useSecret) .Values.database.password.value }} password={{ .Values.database.password.value | squote }}{{- end -}}
{{- if .Values.database.dbname }} user={{ .Values.database.dbname | squote }}{{- end -}}
{{- if .Values.database.sslmode }} sslmode={{ .Values.database.sslmode | squote }}{{- end -}}
{{- if .Values.database.sslcert }} sslcert=/ssl/cert.crt{{- end -}}
{{- if .Values.database.sslkey }} sslkey=/ssl/cert.key{{- end -}}
{{- if .Values.database.sslpassword }} sslpassword={{ .Values.database.sslpassword | squote }}{{- end -}}
{{- if .Values.database.sslrootcert }} sslrootcert=/ssl/ca.pem{{- end -}}
{{- end }}
{{- end }}

{{/*
Define redis DSN
*/}}
{{- define "logto.redisDSN" -}}
{{- if .Values.redis.dsn -}}
{{ .Values.redis.dsn | quote }}
{{- end -}}
{{- if not .Values.redis.dsn -}}
redis{{- .Values.redis.tls -}}s://
{{- if .Values.redis.username -}}{{- .Values.redis.username | urlquery -}}{{- end -}}
{{- if .Values.redis.password -}}:{{- .Values.redis.password | urlquery -}}{{- end -}}
{{- if or .Values.redis.username .Values.redis.password }}@{{- end -}}
{{- required "Redis Host is required" .Values.redis.host -}}
{{- if .Values.redis.port }}:{{- .Values.redis.port -}}{{- end -}}
{{- end }}
{{- end }}
