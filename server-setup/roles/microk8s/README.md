# Microk8s

An Ansible role to install Microk8s on a host.

## Requirements

See requirements in [aws_profile](../aws_profile/README.md) and
[aws_cli](../aws_cli/README.md).

## Role Variables

The `microk8s_user` object defines the user that is used for automated microk8s
management tasks. It has `name` and `home` values. EX:

```yaml 
microk8s_user:
  name: microk8s
  home: /home/microk8s
```

The `microk8s_addons` list gives a list of addons to enabled.

`secrets_encryption_key` is the key used to encrypt secrets at rest. It does not
have a default value.

The `registries` object has a list of image registries. Each registry has a
name, the uri to access it, and the type. Ex:

```yaml
microk8s_user:
  name: microk8s
  home: /home/microk8s
microk8s_path: /var/lib/snapd/snap/bin/microk8s
microk8s_addons:
  - dns
  - dashboard
```

## Dependencies

- community.general
- community.aws
