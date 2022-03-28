{{/*
Common labels
*/}}
{{- define "node-deploy.labels" -}}

{{end}}

{{- define "orderer.nameDomain" -}}
    {{- .ordererName }}.{{ default .domain .ordererDomain -}}
{{- end -}}


{{- define "certificates.encode" }}
  {{ range $filePathTemplate := .certificatePathes }}
    {{ $filePath := tpl $filePathTemplate $ }}
    {{- replace "/" "__" $filePath | replace "@" "___" }}: {{ $.Files.Get $filePath | b64enc }}
  {{ end }}
{{- end }}

{{- define "certificates.decode" }}
  {{ range $filePathTemplate := .certificatePathes  }}
    {{ $filePath := tpl $filePathTemplate $ }}
        - key: {{ replace "/" "__" $filePath | replace "@" "___" }}
          path: {{ replace "crypto-config/" "" $filePath }}
  {{ end }}
{{- end }}


{{- define "resources" }}
    {{ $resources := . }}
    {{ if $resources }}
      resources:
        limits:
          cpu: {{ default $.Values.resources.CPULIMIT $resources.CPULIMIT }}
          memory: {{ default $.Values.resources.MEMORYLIMIT $resources.MEMORYLIMIT }}
        requests:
          cpu: {{ default $resources.CPULIMIT $resources.CPUREQUEST | default $.Values.resources.CPULIMIT }}
          memory: {{ default $resources.MEMORYLIMIT $resources.MEMORYREQUEST | default $.Values.resources.MEMORYLIMIT }}
    {{ end }}
{{- end }}

{{- define "external-hosts" }}
    {{ if or (.Values.externalHosts) (.Values.newExternalHost) }}
      hostAliases:
        {{- if .Values.externalHosts }}
            {{- range $externalOrg := .Values.externalHosts }}
            - ip: {{ default $externalOrg.ip .Values.nginx.ip }}
              hostnames:
              - "{{ $externalOrg.peer }}"
              {{- if  $externalOrg.orderer }}
              - "{{ $externalOrg.orderer }}"
              {{- end }}
              {{- if  $externalOrg.www }}
              - "{{ $externalOrg.www }}"
              {{- end }}
            {{- end }}
        {{- end }}
        {{- if .Values.newExternalHost }}
            - ip: {{ default .Values.newExternalHost.ip .Values.nginx.ip }}
              hostnames:
              - "{{ .Values.newExternalHost.peer }}"
              {{- if  .Values.newExternalHost.orderer }}
              - "{{ .Values.newExternalHost.orderer }}"
              {{- end }}
              {{- if .Values.newExternalHost.www }}
              - "{{ .Values.newExternalHost.www }}"
              {{- end }}
        {{- end -}}
    {{ end}}
{{ end }}
