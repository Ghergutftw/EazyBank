{{/*
============================================================================
Common Helper Templates for EazyBank Helm Chart
These templates follow Helm best practices for DRY and reusability
============================================================================
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "eazybank.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eazybank.fullname" -}}
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
{{- define "eazybank.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to all resources
Follows Kubernetes recommended labels
*/}}
{{- define "eazybank.labels" -}}
helm.sh/chart: {{ include "eazybank.chart" . }}
{{ include "eazybank.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "eazybank.selectorLabels" -}}
app.kubernetes.io/name: {{ include "eazybank.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
============================================================================
Microservice-specific Helper Templates
These templates generate consistent resource definitions for microservices
============================================================================
*/}}

{{/*
Common labels for a specific microservice
Usage: {{ include "eazybank.microservice.labels" (dict "name" "accounts" "context" .) }}
*/}}
{{- define "eazybank.microservice.labels" -}}
app: {{ .name }}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .context.Release.Name }}
app.kubernetes.io/part-of: eazybank
app.kubernetes.io/managed-by: {{ .context.Release.Service }}
helm.sh/chart: {{ include "eazybank.chart" .context }}
{{- end }}

{{/*
Selector labels for a specific microservice
Usage: {{ include "eazybank.microservice.selectorLabels" (dict "name" "accounts" "context" .) }}
*/}}
{{- define "eazybank.microservice.selectorLabels" -}}
app: {{ .name }}
{{- end }}

{{/*
Generate the full image name with registry prefix if specified
Usage: {{ include "eazybank.image" (dict "repository" .Values.accounts.image.repository "tag" .Values.accounts.image.tag "context" .) }}
*/}}
{{- define "eazybank.image" -}}
{{- if .context.Values.global.imageRegistry -}}
{{- printf "%s/%s:%s" .context.Values.global.imageRegistry .repository .tag -}}
{{- else -}}
{{- printf "%s:%s" .repository .tag -}}
{{- end -}}
{{- end }}

{{/*
Generate environment variables from ConfigMap for Spring Boot microservices
This creates a consistent set of env vars for all microservices
Usage: {{ include "eazybank.springboot.env" . }}
*/}}
{{- define "eazybank.springboot.env" -}}
- name: SPRING_PROFILES_ACTIVE
  valueFrom:
    configMapKeyRef:
      name: {{ include "eazybank.fullname" . }}-config
      key: SPRING_PROFILES_ACTIVE
- name: SPRING_CONFIG_IMPORT
  valueFrom:
    configMapKeyRef:
      name: {{ include "eazybank.fullname" . }}-config
      key: SPRING_CONFIG_IMPORT
- name: EUREKA_CLIENT_SERVICEURL_DEFAULTZONE
  valueFrom:
    configMapKeyRef:
      name: {{ include "eazybank.fullname" . }}-config
      key: EUREKA_CLIENT_SERVICEURL_DEFAULTZONE
- name: SPRING_RABBITMQ_HOST
  valueFrom:
    configMapKeyRef:
      name: {{ include "eazybank.fullname" . }}-config
      key: SPRING_RABBITMQ_HOST
- name: SPRING_CLOUD_STREAM_DEFAULT-BINDER
  valueFrom:
    configMapKeyRef:
      name: {{ include "eazybank.fullname" . }}-config
      key: SPRING_CLOUD_STREAM_DEFAULT-BINDER
{{- end }}

{{/*
Generate liveness probe for Spring Boot actuator
Usage: {{ include "eazybank.springboot.livenessProbe" (dict "path" "/actuator/health/liveness" "port" 8080 "initialDelay" 90 "period" 10 "timeout" 5 "failureThreshold" 5) }}
*/}}
{{- define "eazybank.springboot.livenessProbe" -}}
livenessProbe:
  httpGet:
    path: {{ .path }}
    port: {{ .port }}
  initialDelaySeconds: {{ .initialDelay }}
  periodSeconds: {{ .period }}
  timeoutSeconds: {{ .timeout }}
  failureThreshold: {{ .failureThreshold }}
{{- end }}

{{/*
Generate readiness probe for Spring Boot actuator
Usage: {{ include "eazybank.springboot.readinessProbe" (dict "path" "/actuator/health/readiness" "port" 8080 "initialDelay" 60 "period" 10 "timeout" 5 "failureThreshold" 5) }}
*/}}
{{- define "eazybank.springboot.readinessProbe" -}}
readinessProbe:
  httpGet:
    path: {{ .path }}
    port: {{ .port }}
  initialDelaySeconds: {{ .initialDelay }}
  periodSeconds: {{ .period }}
  timeoutSeconds: {{ .timeout }}
  failureThreshold: {{ .failureThreshold }}
{{- end }}

{{/*
Generate resource limits and requests
Usage: {{ include "eazybank.resources" .Values.accounts.resources }}
*/}}
{{- define "eazybank.resources" -}}
{{- if . -}}
resources:
  {{- if .limits }}
  limits:
    {{- if .limits.memory }}
    memory: {{ .limits.memory }}
    {{- end }}
    {{- if .limits.cpu }}
    cpu: {{ .limits.cpu }}
    {{- end }}
  {{- end }}
  {{- if .requests }}
  requests:
    {{- if .requests.memory }}
    memory: {{ .requests.memory }}
    {{- end }}
    {{- if .requests.cpu }}
    cpu: {{ .requests.cpu }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Generate MySQL environment variable for database name
Usage: {{ include "eazybank.mysql.env" (dict "database" "accountsdb" "context" .) }}
*/}}
{{- define "eazybank.mysql.env" -}}
- name: MYSQL_DATABASE
  value: {{ .database | quote }}
- name: MYSQL_ROOT_PASSWORD
  valueFrom:
    configMapKeyRef:
      name: {{ include "eazybank.fullname" .context }}-config
      key: MYSQL_ROOT_PASSWORD
{{- end }}

{{/*
Generate MySQL liveness probe
*/}}
{{- define "eazybank.mysql.livenessProbe" -}}
livenessProbe:
  exec:
    command:
    - mysqladmin
    - ping
    - -h
    - localhost
  initialDelaySeconds: {{ .initialDelaySeconds }}
  periodSeconds: {{ .periodSeconds }}
  timeoutSeconds: {{ .timeoutSeconds }}
{{- end }}

{{/*
Generate MySQL readiness probe
*/}}
{{- define "eazybank.mysql.readinessProbe" -}}
readinessProbe:
  exec:
    command:
    - mysqladmin
    - ping
    - -h
    - localhost
  initialDelaySeconds: {{ .initialDelaySeconds }}
  periodSeconds: {{ .periodSeconds }}
  timeoutSeconds: {{ .timeoutSeconds }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "eazybank.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "eazybank.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

