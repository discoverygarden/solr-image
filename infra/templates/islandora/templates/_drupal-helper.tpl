{{/* vim: set filetype=mustache: */}}
{{/*
Get the drupal volumes
*/}}
{{- define "islandora.drupalVolumes" -}}
- name: crayfish-key
  secret:
    secretName: crayfish-key
    items:
    - key: private
      path: "default.key"
- name: public-filesystem
  persistentVolumeClaim:
    claimName: drupal-public-claim
- name: private-filesystem
  persistentVolumeClaim:
    claimName: drupal-private-claim
- name: islandora-data
  persistentVolumeClaim:
    claimName: drupal-islandora-data-claim
{{- end -}}

{{- define "islandora.drupalVolumeMounts" -}}
- name: crayfish-key
  mountPath: /run/secrets/crayfish
- name: public-filesystem
  mountPath: /opt/www/drupal/web/sites/default/files
- name: private-filesystem
  mountPath: /opt/drupal_private_filesystem/d8/default
- name: islandora-data
  mountPath: /opt/islandora_data
{{- end -}}

{{- define "islandora.drupalEnv" -}}
- name: DRUPAL_DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: drupal-db
      key: password
- name: SOLR_PASSWORD
  valueFrom:
    secretKeyRef:
      name: solr-auth
      key: password
{{- end -}}
