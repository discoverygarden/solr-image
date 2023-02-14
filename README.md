# README

After a redeploy, you'll have to delete and reindex from:

Home > Administration > Configuration > Search and metadata > Search API

Default Solr content index

`Clear all indexed data` followed by `Index now`


To resolve this, the cache directory should probably be a mounted fs rather than in-container
