export ACTIVEMQ_IP=172.20.100.10
export MEMCACHED_IP=172.20.100.20
export DRUPAL_IP=172.20.100.30
export KARAF_IP=172.20.100.40
export SOLR_IP=172.20.100.50
export CANTALOUPE_IP=172.20.100.60
export FQDN=$(curl -s ipinfo.io/ip)
export POSTGRES_HOST="db"
export INGRESS_HOST="localhost"
export SOLR_USER=drupal
export SOLR_PASSWORD=drupal

# Read from a .env file for local overrides
[[ -f ".env" ]] && export $(grep -v '^#' .env | xargs)

# Generate Crayfish keys
mkdir -p keys
openssl genrsa -out keys/default.key 2048
openssl rsa -pubout -in keys/default.key -out keys/default.pub
# Docker compose bind mounts secrets so perms can't be better
chmod 644 keys/default.key keys/default.pub
