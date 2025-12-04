# https://solr.apache.org/guide/8_9/taking-solr-to-production.html
ARG SOLR_VERSION=9.9.0
FROM solr:$SOLR_VERSION
ARG SOLR_VERSION

ENV SOLR_CORE_DIR=${SOLR_HOME}/islandora8

EXPOSE 8983

COPY --link --chown=${SOLR_UID}:${SOLR_GID} islandora8/. ${SOLR_CORE_DIR}

# renovate: datasource=github-releases depName=dbmdz/solr-ocrhighlighting
ARG SOLR_OCRHIGHLIGHTING_VERSION=0.9.5
USER root

ARG SOLR_PATH=/opt/solr-${SOLR_VERSION}
ENV SOLR_HOCR_PLUGIN_PATH=$SOLR_PATH/lib

# extraction,langid,ltr,analysis-extras are required by search_api_solr, so
# let's set 'em by default.
ENV SOLR_MODULES=extraction,langid,ltr,analysis-extras
ADD --link --chown=0:0 --chmod=444 https://github.com/dbmdz/solr-ocrhighlighting/releases/download/$SOLR_OCRHIGHLIGHTING_VERSION/solr-ocrhighlighting-$SOLR_OCRHIGHLIGHTING_VERSION.jar $SOLR_HOCR_PLUGIN_PATH/
USER solr

# https://solr.apache.org/guide/8_9/basic-authentication-plugin.html
COPY --link --chown=${SOLR_UID}:${SOLR_GID} solr.in.sh /etc/default/solr.in.sh

COPY --link --chown=${SOLR_UID}:${SOLR_GID} \
  security.json \
  /var/solr/data/security.json

# renovate: datasource=github-release-attachments depName=prometheus/jmx_exporter
ARG JMX_EXPORTER_VERSION=1.4.0
ARG JMX_EXPORTER_DIGEST=sha256:db1492e95a7ee95cd5e0a969875c0d4f0ef6413148d750351a41cc71d775f59a
WORKDIR /jmx
ADD \
  --link \
  --chmod=644 \
  --checksum=$JMX_EXPORTER_DIGEST \
  https://github.com/prometheus/jmx_exporter/releases/download/$JMX_EXPORTER_VERSION/jmx_prometheus_javaagent-$JMX_EXPORTER_VERSION.jar jmx_prometheus_javaagent.jar
COPY --chmod=644 jmx.yml ./

ENV SOLR_OPTS="-javaagent:/jmx/jmx_prometheus_javaagent.jar=3001:/jmx/jmx.yml"

WORKDIR /opt/solr
USER solr
VOLUME ["${SOLR_CORE_DIR}/data"]
