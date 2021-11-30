# https://github.com/apache/karaf/blob/main/assemblies/docker/Dockerfile
FROM alpine:3.14

ENV OPENJDK_VERSION=11
ENV KARAF_VERSION=4.2.11

EXPOSE 1099 8101 44444 8181 9999


# Update packages and install tools
RUN apk add --no-cache \
    curl \
    openjdk${OPENJDK_VERSION}-jre

# NOTE: need to set JAVA_HOME, otherwise it won't be able to find the javadoc binary
ENV JAVA_HOME="/usr/lib/jvm/java-${OPENJDK_VERSION}-openjdk"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Run non privileged
RUN addgroup --system karaf \
  && adduser --system karaf

RUN curl --silent --fail -OL http://archive.apache.org/dist/karaf/${KARAF_VERSION}/apache-karaf-${KARAF_VERSION}.tar.gz \
  && tar -zxvf apache-karaf-${KARAF_VERSION}.tar.gz -C /opt \
  && ln -s /opt/apache-karaf-${KARAF_VERSION} /opt/karaf \
  && mkdir -p /opt/karaf/data/log \
  && chown -R karaf:karaf /opt/apache-karaf-${KARAF_VERSION} /opt/karaf \
  && rm /apache-karaf-${KARAF_VERSION}.tar.gz

COPY --chown=karaf:karaf \
  karaf.conf custom.system.properties jmx.acl.org.apache.camel.cfg org.fcrepo.camel.service.activemq.cfg \
  /opt/karaf/etc/

COPY --chown=karaf:karaf \
  crayfish.dgi.xml ca.islandora.alpaca.connector.homarus.blueprint.xml ca.islandora.alpaca.connector.houdini.blueprint.xml ca.islandora.alpaca.connector.hypercube.blueprint.xml \
  /opt/karaf/deploy/

USER karaf

WORKDIR /opt/karaf

CMD ["bin/karaf", "run"]
