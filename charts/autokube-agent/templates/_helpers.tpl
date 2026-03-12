{{/*
Fullname — avoids duplication when release name == chart name
e.g. `helm install autokube-agent ./chart/autokube-agent` → "autokube-agent"
     `helm install my-release ./chart/autokube-agent`    → "my-release-autokube-agent"
*/}}
{{- define "autokube-agent.fullname" -}}
{{- if contains .Chart.Name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "autokube-agent.labels" -}}
app.kubernetes.io/name: autokube-agent
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "autokube-agent.selectorLabels" -}}
app.kubernetes.io/name: autokube-agent
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name
*/}}
{{- define "autokube-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default "autokube-agent" .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
