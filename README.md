# README

After a redeploy, you'll have to delete and reindex from:

Home > Administration > Configuration > Search and metadata > Search API

Default Solr content index

`Clear all indexed data` followed by `Index now`


To resolve this, the cache directory should probably be a mounted fs rather than in-container

# Updating solr config

To update the solr config download the config.zip from Islandora, then replace islandora8/conf/ with the contents of the zip file.
