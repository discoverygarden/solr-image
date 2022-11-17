# README

## Prerequisites
- required images must be built/exist
- deploy Postgresql (local to the server or otherwise)

### ADDITIONAL POSTGRES SETUP!!!
- edit `pg_hba.conf` (on Ubuntu, it's likely `/etc/postgresql/12/main/pg_hba.conf`) to allow connection from DRUPAL_IP (default: 127.0.0.1):
```
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    all             all             172.20.100.30/32            md5
```

- edit `postgresql.conf` (on Ubuntu, it's likely `/etc/postgresql/12/main/postgresql.conf`) to `listen_addresses` to `'*'` (default: localhost):
```
#------------------------------------------------------------------------------
# CONNECTIONS AND AUTHENTICATION
#------------------------------------------------------------------------------

# - Connection Settings -

listen_addresses = '*'          # what IP address(es) to listen on;
```

- restart postgresql service


## To deploy 
- run `generate_configs.sh` to create "actual" configs which will be mounted over the defaults in the Docker image AND generate the `docker-compose.yaml` file itself (POSTGRES_HOST = VM private IP)
- The `actual.flysystem_config.json` does not contain any credentials to access s3. Use the `flysystem_config.json` from a dev box and change the prefix to be unique to your container.
- `docker-compose up -d`

# Initializing (first time only)
- run all the containers
- enter Drupal container
- run from **`/opt/www/drupal/sites/default`**
```
export DRUPAL_USER=islandora
export DRUPAL_USER_PASS=islandora
export DRUPAL_SITE_EMAIL=noreplysys@discoverygarden.ca

sudo -u www-data drush site-install minimal --db-url=pgsql://$DRUPAL_DB_USER:$(cat $DRUPAL_DB_PASSWORD)@$POSTGRES_HOST:5432/$DRUPAL_DB_NAME --site-name=default_site --account-name=$DRUPAL_USER --account-pass=$DRUPAL_USER_PASS --account-mail=$DRUPAL_SITE_EMAIL --sites-subdir=default --existing-config

drush content-sync:import provisioned_content --actions=create --user=1
drush content-sync:import i8-specific --actions=create --user=1
drush -y migrate:import --userid=1 --group=islandora

drush -y state-set dgi_i8_helper_iiif_site_id ${DRUPAL_IP}_d8_default
```

- run from **`/opt/www/drupal`**
```
drush cr
drush updb
```
