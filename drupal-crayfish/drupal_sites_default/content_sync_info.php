<?php

global $content_directories;


$content_directories["provisioned_content"] = "/opt/www/drupal/sites/default" . "/" . "provisioned_content";

# Not going to use by default only needed for sample ingested data
#$content_directories["sample_data"] = "/opt/www/drupal/sites/default" . "/" . #"sample_data";

$content_directories["i8-specific"] = "/opt/www/drupal/sites/default" . "/" . "i8-specific";


$content_directories['sync'] = "repo-meta://";
