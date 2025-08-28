# https://solr.apache.org/guide/8_9/taking-solr-to-production.html
FROM solr:8.11.4

ENV SOLR_CORE_DIR=${SOLR_HOME}/islandora8

EXPOSE 8983

COPY --link --chown=${SOLR_UID}:${SOLR_GID} islandora8/. ${SOLR_CORE_DIR} 

# renovate: datasource=github-releases depName=dbmdz/solr-ocrhighlighting
ARG SOLR_OCRHIGHLIGHTING_VERSION=0.9.4
# XXX: User and Group IDs are necessary due to an open issue with buildx: https://github.com/docker/buildx/issues/1526
ADD --link --chown=${SOLR_UID}:${SOLR_GID} https://github.com/dbmdz/solr-ocrhighlighting/releases/download/$SOLR_OCRHIGHLIGHTING_VERSION/solr-ocrhighlighting-$SOLR_OCRHIGHLIGHTING_VERSION-solr78.jar ${SOLR_HOME}/contrib/ocrhighlighting/lib/
# Installing in a second directory to support the solr cloud operator
ADD --link --chown=${SOLR_UID}:${SOLR_GID} https://github.com/dbmdz/solr-ocrhighlighting/releases/download/$SOLR_OCRHIGHLIGHTING_VERSION/solr-ocrhighlighting-$SOLR_OCRHIGHLIGHTING_VERSION-solr78.jar /opt/solr_contrib/

# https://solr.apache.org/guide/8_9/basic-authentication-plugin.html
COPY --link --chown=${SOLR_UID}:${SOLR_GID} solr.in.sh /etc/default/solr.in.sh

COPY --link --chown=${SOLR_UID}:${SOLR_GID} \
  security.json \
  /var/solr/data/security.json

USER solr
VOLUME ["${SOLR_CORE_DIR}/data"]
