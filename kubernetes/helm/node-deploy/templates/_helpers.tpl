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
    {{ if .Values.externalHosts }}
      hostAliases:
        {{ range $externalOrg := .Values.externalHosts }}
        - ip: {{ $externalOrg.ip }}
          hostnames:
          - "{{ $externalOrg.peer }}"
          - "{{ $externalOrg.orderer }}"
          {{ if  $externalOrg.www }}
          - "{{ $externalOrg.www }}"
          {{ end }}
        {{ end }}
    {{ end}}
{{ end }}
