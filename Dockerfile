# https://solr.apache.org/guide/8_9/taking-solr-to-production.html
FROM solr:8.11.3

ENV SOLR_HOME='/var/solr/data'
ENV SOLR_CORE_DIR=${SOLR_HOME}/islandora8
ENV SOLR_HEAP=512m

EXPOSE 8983
USER root
COPY islandora8 ${SOLR_CORE_DIR}

ADD https://github.com/dbmdz/solr-ocrhighlighting/releases/download/0.8.5/solr-ocrhighlighting-0.8.5-solr78.jar ${SOLR_HOME}/contrib/ocrhighlighting/lib/

# https://solr.apache.org/guide/8_9/basic-authentication-plugin.html
COPY solr.in.sh /etc/default/solr.in.sh

COPY  \
  security.json \
  /var/solr/data/security.json

RUN chown -R solr:solr /var/solr

USER solr

VOLUME ["${SOLR_CORE_DIR}/data"]

