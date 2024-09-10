{{/*
Expand the name of the chart.
*/}}
{{- define "keycloak-realmimport.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "keycloak-realmimport.fullname" -}}
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
{{- define "keycloak-realmimport.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "keycloak-realmimport.labels" -}}
helm.sh/chart: {{ include "keycloak-realmimport.chart" . }}
{{ include "keycloak-realmimport.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "keycloak-realmimport.selectorLabels" -}}
app.kubernetes.io/name: {{ include "keycloak-realmimport.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "keycloak-realmimport.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "keycloak-realmimport.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
ArgoCD Syncwave
*/}}
{{- define "keycloak-realmimport.argocd-syncwave" -}}
{{- if .Values.argocd }}
{{- if and (.Values.argocd.syncwave) (.Values.argocd.enabled) -}}
argocd.argoproj.io/sync-wave: "{{ .Values.argocd.syncwave }}"
{{- else }}
{{- "{}" }}
{{- end }}
{{- else }}
{{- "{}" }}
{{- end }}
{{- end }}

{{/*
Target namespace for secret
*/}}
{{- define "keycloak-realmimport.gitlab-secret.target-namespace" -}}
{{- if .Values.hook.gitlabSecret.targetNamespace }}
{{- .Values.hook.gitlabSecret.targetNamespace }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Gitlab application clientId
*/}}
{{- define "keycloak-realmimport.gitlab-secret.clientId" }}
{{- $output := "" }}
{{- if .Values.identityProvider.gitlab.clientId }}
{{- $output = .Values.identityProvider.gitlab.clientId }}
{{- else }}
{{- $secretObj := (lookup "v1" "Secret" (include "keycloak-realmimport.gitlab-secret.target-namespace" .) .Values.hook.gitlabSecret.sourceSecret) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $clientId := (get $secretData "clientId") | b64dec }}
{{- $output = $clientId }}
{{- end }}
{{- $output }}
{{- end }}


{{/*
Gitlab application clientId
*/}}
{{- define "keycloak-realmimport.gitlab-secret.clientSecret" }}
{{- $output := "" }}
{{- if .Values.identityProvider.gitlab.clientSecret }}
{{- $output = .Values.identityProvider.gitlab.clientSecret }}
{{- else }}
{{- $secretObj := (lookup "v1" "Secret" (include "keycloak-realmimport.gitlab-secret.target-namespace" .) .Values.hook.gitlabSecret.sourceSecret) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $clientSecret := (get $secretData "clientSecret") | b64dec }}
{{- $output = $clientSecret }}
{{- end }}
{{- $output }}
{{- end }}