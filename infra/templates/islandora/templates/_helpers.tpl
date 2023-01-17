{{/* vim: set filetype=mustache: */}}
{{/*
Get a list of trusted hostnames
*/}}
{{- define "islandora.trustedHosts" -}}
{{- $serviceName := "svc-drupal" -}}
{{- $namespaced := print $serviceName "." .Release.Namespace  -}}
{{- $fullName := print $namespaced ".svc.cluster.local" -}}
{{- $baseNames := list "localhost" $serviceName $namespaced $fullName -}}
{{ .Values.ingress.host | append $baseNames | toJson | quote }}
{{- end }}

{{/*
Get the ingress port
*/}}
{{- define "islandora.ingressPort" -}}
{{- $traefikService := 	lookup "v1" "Service" "traefik" "traefik" -}}
{{- if $traefikService -}}
{{ range $traefikService.spec.ports }}
    {{- if eq .name "web" -}}
        {{-  .nodePort | toString -}}
    {{- end -}}
{{- end -}}
{{ end }}
{{- end }}


{{/*
Expand the name of the chart.
*/}}
{{- define "islandora.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "islandora.fullname" -}}
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
{{- define "islandora.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "islandora.labels" -}}
helm.sh/chart: {{ include "islandora.chart" . }}
{{ include "islandora.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "islandora.selectorLabels" -}}
app.kubernetes.io/name: {{ include "islandora.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "islandora.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "islandora.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
