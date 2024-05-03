# https://solr.apache.org/guide/8_9/taking-solr-to-production.html
FROM solr:8.11.3

ENV SOLR_HOME='/var/solr/data'
ENV SOLR_CORE_DIR=${SOLR_HOME}/islandora8
ENV SOLR_HEAP=512m

EXPOSE 8983

USER root

COPY --link --chown=8983:8983 islandora8/. ${SOLR_CORE_DIR} 

ADD --link --chown=8983:8983 https://github.com/dbmdz/solr-ocrhighlighting/releases/download/0.8.5/solr-ocrhighlighting-0.8.5-solr78.jar ${SOLR_HOME}/contrib/ocrhighlighting/lib/

RUN cp /opt/solr/server/solr/solr.xml ${SOLR_HOME}/solr.xml \
  && cp /opt/solr/server/solr/zoo.cfg ${SOLR_HOME}/zoo.cfg \
  && cp /opt/solr/server/resources/log4j2.xml /var/solr/log4j2.xml \
  && chown -R solr:solr /var/solr

# XXX: User and Group IDs are necessary due to an open issue with buildx: https://github.com/docker/buildx/issues/1526
ADD --link --chown=8983:8983 https://github.com/dbmdz/solr-ocrhighlighting/releases/download/0.8.3/solr-ocrhighlighting-0.8.3-solr78.jar ${SOLR_HOME}/contrib/ocrhighlighting/lib/

# https://solr.apache.org/guide/8_9/basic-authentication-plugin.html
COPY --link --chown=8983:8983 solr.in.sh /etc/default/solr.in.sh

COPY --link --chown=8983:8983 \
  security.json \
  /var/solr/data/security.json

USER solr
VOLUME ["${SOLR_CORE_DIR}/data"]