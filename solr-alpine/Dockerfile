# https://solr.apache.org/guide/8_9/taking-solr-to-production.html
FROM alpine:3.14

ENV OPENJDK_VERSION=11
ENV SOLR_VERSION=8.9.0
ENV SOLR_HOME='/var/solr/data'
ENV SOLR_HEAP=512m

EXPOSE 8983

# Update packages and install tools
RUN apk add --no-cache \
    bash curl lsof \
    openjdk${OPENJDK_VERSION}-jdk

# NOTE: need to set JAVA_HOME, otherwise it won't be able to find the javadoc binary
ENV JAVA_HOME="/usr/lib/jvm/java-${OPENJDK_VERSION}-openjdk"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Run non privileged
RUN addgroup --system solr \
  && adduser --system solr --ingroup solr

RUN curl --silent --fail -OL http://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz \
  && tar -zxvf solr-${SOLR_VERSION}.tgz -C /opt \
  && ln -s /opt/solr-${SOLR_VERSION} /opt/solr \
  && mkdir -p /var/solr/data /var/solr/logs \
  && chown -R solr:solr /opt/solr-${SOLR_VERSION} /opt/solr ${SOLR_HOME} \
  && rm /solr-${SOLR_VERSION}.tgz

COPY solr_islandora8_core.tgz /tmp/

RUN tar -zxvf /tmp/solr_islandora8_core.tgz -C /var/solr/data \
  && cp /opt/solr/server/solr/solr.xml /var/solr/data/solr.xml \
  && cp /opt/solr/server/solr/zoo.cfg /var/solr/data/zoo.cfg \
  && cp /opt/solr/server/resources/log4j2.xml /var/solr/log4j2.xml \
  && chown -R solr:solr /var/solr \
  && rm /tmp/solr_islandora8_core.tgz

# https://solr.apache.org/guide/8_9/basic-authentication-plugin.html
COPY solr.in.sh /etc/default/solr.in.sh

COPY --chown=solr:solr \
  security.json \
  /var/solr/data/security.json

COPY solr_8.x_config_3.zip /tmp/
RUN unzip -o /tmp/solr_8.x_config_3.zip -d /var/solr/data/isladora8/conf/ \
    && chown -R solr:solr /var/solr/data/isladora8/conf/
USER solr

WORKDIR /opt/solr

CMD ["/opt/solr/bin/solr", "-f"]
