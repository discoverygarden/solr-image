export ACTIVEMQ_IP=172.20.100.10
export MEMCACHED_IP=172.20.100.20
export DRUPAL_IP=172.20.100.30
export KARAF_IP=172.20.100.40
export SOLR_IP=172.20.100.50
export CANTALOUPE_IP=172.20.100.60
export FQDN=$(curl -s ipinfo.io/ip)
export POSTGRES_HOST="db"

source ./islandora-install.properties

# drupal - /etc/apache2/sites-available
envsubst < drupal/sites-available/25-80-dgi.conf > actual.25-80-dgi.conf

# drupal - /etc/apache2/conf-available
# NOTE: passing in '${FQDN} ${PRIVATE_IP}' so it it *only* substitutes that variable
#       otherwise it will try to substitute the $1 in the conf as well
envsubst '${FQDN} ${ACTIVEMQ_IP} ${KARAF_IP} ${CANTALOUPE_IP}' < drupal/conf-available/25-crayfish-homarus.conf > actual.25-crayfish-homarus.conf
envsubst '${FQDN} ${ACTIVEMQ_IP} ${KARAF_IP} ${CANTALOUPE_IP}' < drupal/conf-available/25-crayfish-houdini.conf > actual.25-crayfish-houdini.conf
envsubst '${FQDN} ${ACTIVEMQ_IP} ${KARAF_IP} ${CANTALOUPE_IP}' < drupal/conf-available/25-crayfish-hypercube.conf > actual.25-crayfish-hypercube.conf

# drupal - /opt/www/drupal/sites/default
envsubst < drupal/drupal_sites_default/flysystem_config.json > actual.flysystem_config.json
envsubst < drupal/drupal_sites_default/trusted_hosts.json > actual.trusted_hosts.json
envsubst '${DRUPAL_DB_NAME} ${DRUPAL_DB_USER} ${DRUPAL_DB_PASSWORD} ${POSTGRES_HOST}' < drupal/drupal_sites_default/settings.php > actual.settings.php

# drupal - /opt/www/drupal/sites/default/config_override
envsubst < drupal/config_override/openseadragon.settings.yml > actual.openseadragon.settings.yml
envsubst < drupal/config_override/islandora_iiif.settings.yml > actual.islandora_iiif.settings.yml
envsubst < drupal/config_override/search_api.server.default_solr_server.yml > actual.search_api.server.default_solr_server.yml
envsubst < drupal/config_override/islandora.settings.yml > actual.islandora.settings.yml
envsubst < drupal/config_override/clamav.settings.yml > actual.clamav.settings.yml

# karaf - /opt/karaf/etc
envsubst < karaf/org.fcrepo.camel.service.activemq.cfg > actual.org.fcrepo.camel.service.activemq.cfg

# karaf - /opt/karaf/deploy
envsubst < karaf/crayfish.dgi.xml > actual.crayfish.dgi.xml
envsubst < karaf/ca.islandora.alpaca.connector.homarus.blueprint.xml > actual.ca.islandora.alpaca.connector.homarus.blueprint.xml
envsubst < karaf/ca.islandora.alpaca.connector.houdini.blueprint.xml > actual.ca.islandora.alpaca.connector.houdini.blueprint.xml
envsubst < karaf/ca.islandora.alpaca.connector.hypercube.blueprint.xml > actual.ca.islandora.alpaca.connector.hypercube.blueprint.xml
