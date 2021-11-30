# README

- Requires the `id_rsa` (added to .gitignore of repo) of **composer**  (file listed in .gitignore so not to be added by accident, but needs to be provider by user when building image)

- `config_override/clamav.settings.yml` not being used at the moment

## To run
- `docker run -d --name crayfish_svc --env-file=apache2_envvars -v /opt/drupal_keys/:/opt/drupal_keys/ -p 8888:80 crayfish:VERSION`


# TODO
- generation of thumbnail for PDF document currently does not work
- some Apache2 logging not going to stdout/stderr
