{{/*
Common labels
*/}}
{{- define "node-deploy.labels" -}}

{{end}}


{{- define "certificates.encode" }}
  {{ range $dir := .certificatePathes }}
    {{ range $filePath, $_ := $.Files.Glob (printf "%s%s" (tpl $dir $) "/*" ) }}
      {{- replace "/" "__" $filePath | replace "@" "___" }}: {{ $.Files.Get $filePath | b64enc }}
    {{ end }}
  {{ end }}
{{- end }}

{{- define "certificates.decode" }}
  {{ range $dir := .certificatePathes  }}
      {{ range $path, $_ := $.Files.Glob (printf "%s%s" (tpl $dir $) "/*" ) }}
        - key: {{ replace "/" "__" $path | replace "@" "___" }}
          path: {{ replace "crypto-config/" "" $path }}
      {{ end }}
  {{ end }}
{{- end }}