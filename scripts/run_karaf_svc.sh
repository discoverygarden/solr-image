docker rm --force karaf_svc

source ~/islandora-install.properties

# /opt/karaf/etc
/usr/bin/envsubst < karaf-alpine/org.fcrepo.camel.service.activemq.cfg > actual.org.fcrepo.camel.service.activemq.cfg

# /opt/karaf/deploy
/usr/bin/envsubst < karaf-alpine/crayfish.dgi.xml > actual.crayfish.dgi.xml
/usr/bin/envsubst < karaf-alpine/ca.islandora.alpaca.connector.homarus.blueprint.xml > actual.ca.islandora.alpaca.connector.homarus.blueprint.xml
/usr/bin/envsubst < karaf-alpine/ca.islandora.alpaca.connector.houdini.blueprint.xml > actual.ca.islandora.alpaca.connector.houdini.blueprint.xml
/usr/bin/envsubst < karaf-alpine/ca.islandora.alpaca.connector.hypercube.blueprint.xml > actual.ca.islandora.alpaca.connector.hypercube.blueprint.xml

/usr/bin/docker run -d --name karaf_svc \
	-v ${PWD}/actual.org.fcrepo.camel.service.activemq.cfg:/opt/karaf/etc/org.fcrepo.camel.service.activemq.cfg \
	-v ${PWD}/actual.crayfish.dgi.xml:/opt/karaf/deploy/crayfish.dgi.xml \
	-v ${PWD}/actual.ca.islandora.alpaca.connector.homarus.blueprint.xml:/opt/karaf/deploy/ca.islandora.alpaca.connector.homarus.blueprint.xml \
	-v ${PWD}/actual.ca.islandora.alpaca.connector.houdini.blueprint.xml:/opt/karaf/deploy/ca.islandora.alpaca.connector.houdini.blueprint.xml \
	-v ${PWD}/actual.ca.islandora.alpaca.connector.hypercube.blueprint.xml:/opt/karaf/deploy/ca.islandora.alpaca.connector.hypercube.blueprint.xml \
	-p 1099:1099 \
	-p 8101:8101 \
	-p 44444:44444 \
	karaf:4.2.11-alpine
