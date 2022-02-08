# docker-dgi-proto
Prototype docker setup for Islandora8

## Building the Images
```
docker build -t [IMAGE_NAME]:[IMAGE_TAG] .
```

i.e. `docker build -t cantaloupe:4.1.9-tomcat .` from the `tomcat-cantaloupe` directory

NOTE: the if you want to name/tag the images differently, don't forget to update the docker-compose.yaml ;)


## Pre-requisites

### Docker (for [Ubuntu](https://docs.docker.com/engine/install/ubuntu/))
```
sudo apt-get -y install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
```

- Optional: `sudo usermod -a -G docker ubuntu`

### docker-compose
See documentation [here](https://docs.docker.com/compose/install/#install-compose-on-linux-systems)

### PostgreSQL
```
sudo apt-get -y install postgresql-12 

sudo mkdir -p /opt/postgresql /opt/backup
sudo chown -R postgres:postgres /opt/backup
```

- Note: [fix](https://www.drupal.org/project/drupal/issues/2569365) required or Drupal install will fail
```
sudo sed -i "s/#bytea_output.*/bytea_output = 'escape'/g" /etc/postgresql/12/main/postgresql.conf
```

- Setup DB
```
sudo -u postgres psql -c "CREATE USER $DRUPAL_DB_USER WITH PASSWORD '$DRUPAL_DB_PASSWORD';"
sudo -u postgres psql -c "CREATE DATABASE $DRUPAL_DB_NAME WITH TEMPLATE = 'template0' ENCODING = 'UTF-8'"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DRUPAL_DB_NAME TO $DRUPAL_DB_USER;"

sudo systemctl restart postgresql
```

### ClamAV
** ATTENTION ** - ClamAV needs to be disabled in the containerized version.  There may be [potential workarounds](https://hub.docker.com/r/mkodockx/docker-clamav) but the needs exploring/testing
```
sudo apt-get -y install clamav-daemon

sudo sed -i "s/\#ReceiveTimeout.*/ReceiveTimeout 120/g" /etc/clamav/freshclam.conf
sudo sed -i "s/^MaxScanSize.*/MaxScanSize 2048M/g" /etc/clamav/clamd.conf
sudo sed -i "s/^MaxFileSize.*/MaxFileSize 2048M/g" /etc/clamav/clamd.conf
sudo sed -i "s/^StreamMaxLength.*/StreamMaxLength 2048M/g" /etc/clamav/clamd.conf

sudo cp etc_apparmord_dgi-usr.sbin.clamd /etc/apparmor.d/dgi-usr.sbin.clamd
sudo ln -s /etc/apparmor.d/usr.sbin.clamd /etc/apparmor.d/disable/usr.sbin.clamd

sudo systemctl restart apparmor
sudo systemctl stop clamav-freshclam
sudo systemctl stop clamav-daemon
sudo systemctl enable clamav-freshclam
sudo systemctl enable clamav-daemon
sudo systemctl start clamav-freshclam
sudo systemctl start clamav-daemon
```

- added `/usr/bin/freshclam` to **root** crontab
```
0 1 * * * /usr/bin/freshclam
```


### d8_configs
**DEPRECATION NOTE:** this is built into the image now as of v0.1.0 of drupal-crayfish image
```
sudo mkdir -p /opt/www/drupal/sites/default
sudo tar -zxvf provisioned_content-2021-05-10.tar.gz -C /opt/www/drupal/sites/default/
sudo tar -zxvf i8-specific-2021-05-18.tar.gz -C /opt/www/drupal/sites/default/
sudo chmod -R 644 /opt/www/drupal/sites/default/provisioned_content*
sudo chmod -R 644 /opt/www/drupal/sites/default/i8-specific*
sudo chown -R www-data:www-data /opt/www/drupal


sudo mkdir -p /opt/www/d8_configs
sudo tar -xvf i8-proto-config_i8manage.tar -C /opt/www/d8_configs/
sudo mv /opt/www/d8_configs/i8-proto-config /opt/www/d8_configs/default
sudo chown -R www-data:www-data /opt/www/d8_configs
```
