# https://solr.apache.org/guide/8_1/basic-authentication-plugin.html#enable-basic-authentication
SOLR_AUTH_TYPE=basic
SOLR_AUTHENTICATION_OPTS=-Dbasicauth=drupal:drupal
SOLR_OPTS="$SOLR_OPTS -javaagent:/jmx/jmx_prometheus_javaagent.jar=3001:/jmx/jmx.yml -Dsolr.hocr.plugin.path=${SOLR_HOCR_PLUGIN_PATH}"
