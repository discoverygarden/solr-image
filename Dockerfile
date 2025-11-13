# https://solr.apache.org/guide/8_9/taking-solr-to-production.html
FROM solr:8.11.4

ENV SOLR_CORE_DIR=${SOLR_HOME}/islandora8

EXPOSE 8983

COPY --link --chown=${SOLR_UID}:${SOLR_GID} islandora8/. ${SOLR_CORE_DIR} 

# renovate: datasource=github-releases depName=dbmdz/solr-ocrhighlighting
ARG SOLR_OCRHIGHLIGHTING_VERSION=0.9.4
USER root
ENV SOLR_HOCR_PLUGIN_PATH=/opt/solr_extra_lib/ocrhighlighting/lib
RUN mkdir -p $SOLR_HOCR_PLUGIN_PATH
ADD --link --chown=0:${SOLR_GID} --chmod=040 https://github.com/dbmdz/solr-ocrhighlighting/releases/download/$SOLR_OCRHIGHLIGHTING_VERSION/solr-ocrhighlighting-$SOLR_OCRHIGHLIGHTING_VERSION-solr78.jar $SOLR_HOCR_PLUGIN_PATH
USER solr

# https://solr.apache.org/guide/8_9/basic-authentication-plugin.html
COPY --link --chown=${SOLR_UID}:${SOLR_GID} solr.in.sh /etc/default/solr.in.sh

COPY --link --chown=${SOLR_UID}:${SOLR_GID} \
  security.json \
  /var/solr/data/security.json

WORKDIR /jmx
ADD --link --chmod=644 https://github.com/prometheus/jmx_exporter/releases/download/1.4.0/jmx_prometheus_javaagent-1.4.0.jar jmx_prometheus_javaagent.jar
COPY --chmod=644 jmx.yml ./

WORKDIR /opt/solr
USER solr
VOLUME ["${SOLR_CORE_DIR}/data"]
