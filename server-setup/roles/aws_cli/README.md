AWS Cli
=========

Installs the AWS CLI.

Role Variables
--------------

- aws_bin_dir: The localtion to install the binary. Default: /usr/bin
- aws_install_dir: The localtion to install the rest of the files. Default: /usr/local/aws-cli
- staging_dir: A staging directory for temporary files. Default: /tmp/staging
- aws_cli_download: The location of the AWS CLI installer. Default: https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - aws_cli

