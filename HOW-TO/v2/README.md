# README

## Prerequisites
- required images must be built/exist


## To deploy 
- run `generate_configs.sh` to create "actual" configs which will be mounted over the defaults in the Docker image 
- `docker-compose up -d`

# Initializing (first time only)
- run all the containers
- enter Drupal container
- run from **`/opt/www/drupal/sites/default`**
```
export DRUPAL_USER=islandora
export DRUPAL_USER_PASS=islandora
export DRUPAL_SITE_EMAIL=noreplysys@discoverygarden.ca

sudo -Eu www-data drush site-install dgi_standard_profile --db-url=pgsql://$DRUPAL_DB_USER:$(cat $DRUPAL_DB_PASSWORD_FILE)@$POSTGRES_HOST:5432/$DRUPAL_DB_NAME --site-name=default_site --account-name=$DRUPAL_USER --account-pass=$DRUPAL_USER_PASS --account-mail=$DRUPAL_SITE_EMAIL --sites-subdir=default --existing-config -y

sudo -Eu www-data drush content-sync:import provisioned_content --actions=create --user=1 -y
sudo -Eu www-data drush content-sync:import i8-specific --actions=create --user=1 -y
sudo -Eu www-data drush -y migrate:import --userid=1 --group=islandora

sudo -Eu www-data drush -y state-set dgi_i8_helper_iiif_site_id drupal_d8_default
```

- run from **`/opt/www/drupal`**
```
drush cr
drush updb
```
