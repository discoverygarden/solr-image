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
envsubst < drupal/config_override/key.key.default.yml > actual.key.key.default.yml

# Generate Crayfish keys
mkdir -p keys
openssl genrsa -out keys/default.key 2048
openssl rsa -pubout -in keys/default.key -out keys/default.pub
# Docker compose bind mounts secrets so perms can't be better
chmod 644 keys/default.key keys/default.pub
