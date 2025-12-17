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

{{- define "os2mo.keycloak_admin_secret" -}}
{{- .Values.keycloak.admin_secret | default "keycloak-admin-secret" }}
{{- end }}

{{- define "os2mo.keycloak_db_connection_string" -}}
{{- $use_ssl := (ne .Values.database.sslmode "") -}}
{{- $sslmode := ternary "require" "disable" $use_ssl -}}
postgres://{{ .Values.database.keycloak.user }}:$(KEYCLOAK_DB_PASSWORD)@{{ .Values.database.host }}/{{ .Values.database.keycloak.name }}?sslmode={{ $sslmode }}
{{- end }}

{{- define "os2mo.keycloak_terraform_db_connection" -}}
- name: KEYCLOAK_DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: keycloak-secret
      key: db_password

# Postgres state connection
- name: POSTGRES_CONNECTION_STRING
  value: {{ include "os2mo.keycloak_db_connection_string" . }}
{{- end }}

{{- define "os2mo.wait-for-service" -}}
- name: wait-for-{{ .name }}
  image: {{ printf "%s/%s:%s" .Values.wait_for_service.image.registry .Values.wait_for_service.image.repository .Values.wait_for_service.image.tag }}
  command: ["/bin/sh","-c"]
  args:
    - |
      while true; do
        echo "Waiting for {{ .name | title }} to be ready"
        if curl --insecure --silent --fail "http://{{ .name }}-service:{{ .port }}{{ .url }}" -o /dev/null
        then
          break
        fi
        sleep 1
      done
      echo "OK"
  resources:
    {{- toYaml .resources | nindent 4 }}
{{- end }}

{{- define "os2mo.wait-for-keycloak" -}}
{{ ( include "os2mo.wait-for-service" (dict "name" "keycloak" "port" 8080 "url" "/auth/realms/master" "resources" .Values.initContainers.resources "Values" .Values ) ) }}
{{- end }}

{{- define "os2mo.wait-for-mo" -}}
{{ ( include "os2mo.wait-for-service" (dict "name" "mo" "port" 5000 "url" "/health/ready" "resources" .Values.initContainers.resources "Values" .Values ) ) }}
{{- end }}

{{- define "os2mo.wait-for-sdtool" -}}
{{ ( include "os2mo.wait-for-service" (dict "name" "sdtool" "port" 80 "url" "/triggers" "resources" .Values.initContainers.resources "Values" .Values ) ) }}
{{- end }}

{{- define "os2mo.wait-for-sdtool-plus" -}}
{{ ( include "os2mo.wait-for-service" (dict "name" "sdtool-plus" "port" 8000 "url" "/" "resources" .Values.initContainers.resources "Values" .Values ) ) }}
{{- end }}

{{- define "os2mo.wait-for-xflow" -}}
{{ ( include "os2mo.wait-for-service" (dict "name" "xflow" "port" 8000 "url" "/" "resources" .Values.initContainers.resources "Values" .Values ) ) }}
{{- end }}

{{- define "os2mo.wait-for-sd-changed-at" -}}
{{ ( include "os2mo.wait-for-service" (dict "name" "sd-changed-at" "port" 8000 "url" "/" "resources" .Values.initContainers.resources "Values" .Values ) ) }}
{{- end }}

{{- define "os2mo.wait-for-os2sync-export" -}}
{{ ( include "os2mo.wait-for-service" (dict "name" "os2sync-export" "port" 8000 "url" "/" "resources" .Values.initContainers.resources "Values" .Values ) ) }}
{{- end }}

{{- define "os2mo.wait-for-orggatekeeper" -}}
{{ ( include "os2mo.wait-for-service" (dict "name" "orggatekeeper" "port" 8000 "url" "/" "resources" .Values.initContainers.resources "Values" .Values ) ) }}
{{- end }}
