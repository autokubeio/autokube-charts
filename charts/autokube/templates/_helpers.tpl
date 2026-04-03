{{/*
Fullname
*/}}
{{- define "autokube.fullname" -}}
{{- if contains .Chart.Name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "autokube.labels" -}}
app.kubernetes.io/name: autokube
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "autokube.selectorLabels" -}}
app.kubernetes.io/name: autokube
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name
*/}}
{{- define "autokube.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default "autokube" .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
PersistentVolumeClaim name
*/}}
{{- define "autokube.persistentVolumeClaimName" -}}
{{- if .Values.persistence.enabled }}
{{- printf "%s-%s" (include "autokube.fullname" .) "data" }}
{{- end }}
{{- end }}
