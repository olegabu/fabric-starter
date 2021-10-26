{{- define "orderer-generate.labels" -}}
step: {{ .Chart.Name }}
{{end}}

{{- define "common.env" -}}
- name: "OOOO"
  value: {{ .Chart.Name }}
{{- end }}