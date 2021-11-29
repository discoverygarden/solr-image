docker rm --force drupal_svc

source ~/islandora-install.properties

sudo chown ubuntu ./actual.*

# /etc/apache2/sites-available
/usr/bin/envsubst < drupal-crayfish/sites-available/25-80-dgi.conf > actual.25-80-dgi.conf

# /opt/www/drupal/sites/default
/usr/bin/envsubst < drupal-crayfish/drupal_sites_default/flysystem_config.json > actual.flysystem_config.json
/usr/bin/envsubst < drupal-crayfish/drupal_sites_default/trusted_hosts.json > actual.trusted_hosts.json

# /opt/www/drupal/sites/default/config_override
/usr/bin/envsubst < drupal-crayfish/config_override/openseadragon.settings.yml > actual.openseadragon.settings.yml
/usr/bin/envsubst < drupal-crayfish/config_override/islandora_iiif.settings.yml > actual.islandora_iiif.settings.yml
/usr/bin/envsubst < drupal-crayfish/config_override/search_api.server.default_solr_server.yml > actual.search_api.server.default_solr_server.yml


/usr/bin/docker run -d --name drupal_svc \
	--env-file drupal-crayfish/apache2_envvars \
	-v /opt/www/d8_configs/default/:/opt/www/d8_configs/default/ \
	-v /opt/www/drupal/sites/default/provisioned_content/:/opt/www/drupal/sites/default/provisioned_content/ \
	-v /opt/www/drupal/sites/default/i8-specific/:/opt/www/drupal/sites/default/i8-specific/ \
	-v ${PWD}/actual.settings.php:/opt/www/drupal/sites/default/settings.php \
	-v ${PWD}/actual.25-80-dgi.conf:/etc/apache2/sites-available/25-80-dgi.conf \
        -v ${PWD}/actual.flysystem_config.json:/opt/www/drupal/sites/default/flysystem_config.json \
	-v ${PWD}/actual.trusted_hosts.json:/opt/www/drupal/sites/default/trusted_hosts.json \
	-v ${PWD}/actual.islandora_iiif.settings.yml:/opt/www/drupal/sites/default/config_override/islandora_iiif.settings.yml \
	-v ${PWD}/actual.openseadragon.settings.yml:/opt/www/drupal/sites/default/config_override/openseadragon.settings.yml \
	-v ${PWD}/actual.search_api.server.default_solr_server.yml:/opt/www/drupal/sites/default/config_override/search_api.server.default_solr_server.yml \
	--net=host \
	drupal-crayfish:8.x-manage
