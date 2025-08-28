# https://solr.apache.org/guide/8_9/taking-solr-to-production.html
FROM solr:8.11.4

# renovate: datasource=github-releases depName=dbmdz/solr-ocrhighlighting
ARG SOLR_OCRHIGHLIGHTING_VERSION=0.9.4
# XXX: User and Group IDs are necessary due to an open issue with buildx: https://github.com/docker/buildx/issues/1526
ADD --link --chown=${SOLR_UID}:${SOLR_GID} https://github.com/dbmdz/solr-ocrhighlighting/releases/download/$SOLR_OCRHIGHLIGHTING_VERSION/solr-ocrhighlighting-$SOLR_OCRHIGHLIGHTING_VERSION-solr78.jar /opt/solr_contrib/

