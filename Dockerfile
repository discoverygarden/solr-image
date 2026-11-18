# https://solr.apache.org/guide/8_9/taking-solr-to-production.html
ARG SOLR_VERSION=9.11.0
FROM solr:$SOLR_VERSION
ARG SOLR_VERSION

# XXX: Stopgap for Java4Shell (CVE-2026-114938). solr:9.11.0 ships Temurin
# 17.0.21+9, which is vulnerable, and Temurin has not yet published a fixed
# 17.0.21.1. Replace the bundled JRE in place with Azul Zulu 17.70.201
# (OpenJDK 17.0.21.1+2), which carries the fix. Remove this block once the
# upstream solr image is rebuilt with Temurin >= 17.0.21.1.
ARG TARGETARCH
ARG ZULU_JRE_VERSION=17.70.201-ca-jre17.0.21.1
ARG ZULU_JRE_SHA256_AMD64=1e4637d81dabcca728cf8a2dd94bd081eb232fe941b4773ddddea2893fbd163a
ARG ZULU_JRE_SHA256_ARM64=03489b3d69690141d61ff848f7be81d0ac7ded5e6648b393a588b00c80769efc
USER root
RUN set -eux; \
  case "$TARGETARCH" in \
    amd64) arch=x64; sha256=$ZULU_JRE_SHA256_AMD64 ;; \
    arm64) arch=aarch64; sha256=$ZULU_JRE_SHA256_ARM64 ;; \
    *) echo "Unsupported arch: $TARGETARCH" >&2; exit 1 ;; \
  esac; \
  curl -fsSL -o /tmp/zulu-jre.tar.gz \
    "https://cdn.azul.com/zulu/bin/zulu${ZULU_JRE_VERSION}-linux_${arch}.tar.gz"; \
  echo "$sha256  /tmp/zulu-jre.tar.gz" | sha256sum -c -; \
  rm -rf "$JAVA_HOME"; \
  mkdir -p "$JAVA_HOME"; \
  tar -xzf /tmp/zulu-jre.tar.gz -C "$JAVA_HOME" --strip-components=1 --no-same-owner; \
  rm /tmp/zulu-jre.tar.gz; \
  java -version
ENV JAVA_VERSION=zulu-17.0.21.1+2
USER solr

ENV SOLR_CORE_DIR=${SOLR_HOME}/islandora8

# XXX: Suppress security manager, given:
# - The security manager is slated for removal as of https://openjdk.org/jeps/411
# - We are missing configuration of the security manager to support our JMX agent
ENV SOLR_SECURITY_MANAGER_ENABLED="false"

EXPOSE 8983

COPY --link --chown=${SOLR_UID}:${SOLR_GID} islandora8/. ${SOLR_CORE_DIR}

# renovate: datasource=github-releases depName=dbmdz/solr-ocrhighlighting
ARG SOLR_OCRHIGHLIGHTING_VERSION=0.10.1
ARG SOLR_OCRHIGHLIGHTING_CHECKSUM=sha256:d10b86684004ebeec3d938a64608135e80c1cef58a176dacb9a556f0b5a78823
USER root

ARG SOLR_PATH=/opt/solr-${SOLR_VERSION}
ENV SOLR_HOCR_PLUGIN_PATH=$SOLR_PATH/lib

# extraction,langid,ltr,analysis-extras are required by search_api_solr, so
# let's set 'em by default.
ENV SOLR_MODULES=extraction,langid,ltr,analysis-extras
ADD --link --chown=0:0 --chmod=444 --checksum=$SOLR_OCRHIGHLIGHTING_CHECKSUM \
  https://github.com/dbmdz/solr-ocrhighlighting/releases/download/$SOLR_OCRHIGHLIGHTING_VERSION/solr-ocrhighlighting-$SOLR_OCRHIGHLIGHTING_VERSION.jar \
  $SOLR_HOCR_PLUGIN_PATH/
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
