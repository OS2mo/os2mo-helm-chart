# SPDX-FileCopyrightText: Magenta ApS
#
# SPDX-License-Identifier: MPL-2.0
---
{{/*
Expand the name of the chart.
*/}}
{{- define "os2mo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "os2mo.fullname" -}}
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
{{- define "os2mo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "os2mo.labels" -}}
helm.sh/chart: {{ include "os2mo.chart" . }}
{{ include "os2mo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "os2mo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "os2mo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "os2mo.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "os2mo.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "keycloak_db_name" -}}
{{- if .Values.database.db_prefix -}}
{{ .Values.database.db_prefix }}_keycloak
{{- else -}}
keycloak
{{- end }}
{{- end }}

{{- define "keycloak_db_user" -}}
{{- if .Values.database.db_prefix -}}
{{ .Values.database.db_prefix }}_keycloak
{{- else -}}
keycloak
{{- end }}
{{- end }}

{{- define "keycloak_db_connection_string" -}}
{{- $use_ssl := (ne .Values.database.sslmode "") -}}
{{- $sslmode := ternary "require" "disable" $use_ssl -}}
postgres://{{ include "keycloak_db_user" . }}:$(KEYCLOAK_DB_PASSWORD)@{{ .Values.database.host }}/{{ include "keycloak_db_name" . }}?sslmode={{ $sslmode }}
{{- end }}

{{- define "keycloak_terraform_db_connection" -}}
- name: KEYCLOAK_DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: keycloak-secret
      key: db_password

# Postgres state connection
- name: POSTGRES_CONNECTION_STRING
  value: {{ include "keycloak_db_connection_string" . }}
{{- end }}

{{- define "mox_db_name" -}}
{{- if .Values.database.db_prefix -}}
{{ .Values.database.db_prefix }}_mox
{{- else -}}
mox
{{- end }}
{{- end }}

{{- define "mox_db_user" -}}
{{- if .Values.database.db_prefix -}}
{{ .Values.database.db_prefix }}_mox
{{- else -}}
mox
{{- end }}
{{- end }}

{{- define "wait-for-service" -}}
- name: wait-for-{{ .name }}
  image: curlimages/curl
  command: ["/bin/sh","-c"]
  args: ['while [ $(curl -ksw "%{http_code}" "http://{{ .name }}-service:{{ .port }}{{ .url }}" -o /dev/null) -ne 200 ]; do sleep 1; echo "Waiting for {{ .name | title }} to be ready"; done; echo "OK"']
  resources:
    {{- toYaml .resources | nindent 4 }}
{{- end }}

{{- define "wait-for-keycloak" -}}
{{ ( include "wait-for-service" (dict "name" "keycloak" "port" 8080 "url" "/auth/realms/master" "resources" .Values.initContainers.resources ) ) }}
{{- end }}

{{- define "wait-for-mo" -}}
{{ ( include "wait-for-service" (dict "name" "mo" "port" 5000 "url" "/" "resources" .Values.initContainers.resources ) ) }}
{{- end }}

{{- define "wait-for-mox" -}}
{{ ( include "wait-for-service" (dict "name" "mox" "port" 8080 "url" "/site-map" "resources" .Values.initContainers.resources ) ) }}
{{- end }}

{{- define "wait-for-sdtool" -}}
{{ ( include "wait-for-service" (dict "name" "sdtool" "port" 80 "url" "/triggers" "resources" .Values.initContainers.resources ) ) }}
{{- end }}

{{- define "wait-for-sd-changed-at" -}}
{{ ( include "wait-for-service" (dict "name" "sd-changed-at" "port" 8000 "url" "/" "resources" .Values.initContainers.resources ) ) }}
{{- end }}
