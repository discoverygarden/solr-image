# https://solr.apache.org/guide/8_9/taking-solr-to-production.html
FROM alpine:3.20

ENV OPENJDK_VERSION=11
ENV SOLR_VERSION=8.11.2
ENV SOLR_HOME='/var/solr/data'
ENV SOLR_CORE_DIR=${SOLR_HOME}/islandora8
ENV SOLR_HEAP=512m

EXPOSE 8983

# Update packages and install tools
RUN apk add --no-cache \
    bash curl lsof \
    openjdk${OPENJDK_VERSION}-jdk \
    procps

# NOTE: need to set JAVA_HOME, otherwise it won't be able to find the javadoc binary
ENV JAVA_HOME="/usr/lib/jvm/java-${OPENJDK_VERSION}-openjdk"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Run non privileged
RUN addgroup --system solr \
  && adduser --system solr --ingroup solr

RUN curl --silent --fail -OL http://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz \
  && tar -zxvf solr-${SOLR_VERSION}.tgz -C /opt \
  && ln -s /opt/solr-${SOLR_VERSION} /opt/solr \
  && mkdir -p ${SOLR_HOME} /var/solr/logs \
  && chown -R solr:solr /opt/solr-${SOLR_VERSION} /opt/solr ${SOLR_HOME} \
  && rm /solr-${SOLR_VERSION}.tgz

COPY --link islandora8 ${SOLR_CORE_DIR}

RUN cp /opt/solr/server/solr/solr.xml ${SOLR_HOME}/solr.xml \
  && cp /opt/solr/server/solr/zoo.cfg ${SOLR_HOME}/zoo.cfg \
  && cp /opt/solr/server/resources/log4j2.xml /var/solr/log4j2.xml \
  && chown -R solr:solr /var/solr

# XXX: User and Group IDs are necessary due to an open issue with buildx: https://github.com/docker/buildx/issues/1526
ADD --link --chown=100:101 https://github.com/dbmdz/solr-ocrhighlighting/releases/download/0.8.3/solr-ocrhighlighting-0.8.3-solr78.jar ${SOLR_HOME}/contrib/ocrhighlighting/lib/

# https://solr.apache.org/guide/8_9/basic-authentication-plugin.html
COPY --link --chown=100:101 solr.in.sh /etc/default/solr.in.sh

COPY --link --chown=100:101 \
  security.json \
  /var/solr/data/security.json

USER solr

VOLUME ["${SOLR_CORE_DIR}/data"]
WORKDIR /opt/solr

CMD ["/opt/solr/bin/solr", "-f"]
