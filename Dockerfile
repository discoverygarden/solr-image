# https://solr.apache.org/guide/8_9/taking-solr-to-production.html
ARG SOLR_VERSION=9.9.0
FROM solr:$SOLR_VERSION
ARG SOLR_VERSION

ENV SOLR_CORE_DIR=${SOLR_HOME}/islandora8

EXPOSE 8983

COPY --link --chown=${SOLR_UID}:${SOLR_GID} islandora8/. ${SOLR_CORE_DIR}

# renovate: datasource=github-releases depName=dbmdz/solr-ocrhighlighting
ARG SOLR_OCRHIGHLIGHTING_VERSION=0.9.4
USER root

ARG SOLR_PATH=/opt/solr-${SOLR_VERSION}
ARG SOLR_MODULE_DIR=$SOLR_PATH/modules

ENV SOLR_HOCR_PLUGIN_PATH=$SOLR_MODULE_DIR/ocrhighlighting/lib
RUN <<-EOS
set -eux
mkdir -p $SOLR_HOCR_PLUGIN_PATH
chmod -R a=rX $SOLR_MODULE_DIR/ocrhighlighting
EOS

# extraction,langid,ltr,analysis-extras are defaults of search_api_solr.
ENV SOLR_MODULES=extraction,langid,ltr,analysis-extras,ocrhighlighting
ADD --link --chown=0:0 --chmod=444 https://github.com/dbmdz/solr-ocrhighlighting/releases/download/$SOLR_OCRHIGHLIGHTING_VERSION/solr-ocrhighlighting-$SOLR_OCRHIGHLIGHTING_VERSION.jar $SOLR_HOCR_PLUGIN_PATH/
USER solr

# https://solr.apache.org/guide/8_9/basic-authentication-plugin.html
COPY --link --chown=${SOLR_UID}:${SOLR_GID} solr.in.sh /etc/default/solr.in.sh

COPY --link --chown=${SOLR_UID}:${SOLR_GID} \
  security.json \
  /var/solr/data/security.json

USER solr
VOLUME ["${SOLR_CORE_DIR}/data"]
