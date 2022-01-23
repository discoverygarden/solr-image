<?php

$settings['trusted_host_patterns'] = [];

foreach (json_decode(file_get_contents(__DIR__ . '/trusted_hosts.json'), TRUE) as $host) {
  $settings['trusted_host_patterns'][] = '^' . preg_quote($host) . '$';
}
