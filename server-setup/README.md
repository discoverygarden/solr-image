# Server Provisioning

This directory contains ansible and cloudformation resources to provision
microk8s on servers. Currently the scripts only support single server RHEL
installations.

## Usage

Create the required AWS resources. From this directory run the
[`aws_resources.sh`](./aws_resources.sh) script. The script requires the
hostname of the new server as a positional argument. It can also take the
environment (dev/prod) with `-e`, the client with `-c`, and can be forced to
regenerate the encryption key with `-f`.

EX:
```bash
./aws_resources.sh -e stage -c ctda ctda.staging.dgicloud.com
```

Add the new host to the [inventory](./inventory) and add host-specific
configuration in the [host_vars](./host_vars/) directory.
[This](./host_vars/micro.doge.irish.yml) can be used as reference.

When running the playbook `-l <GROUP|HOST>` can be used to filter which servers
to run the playbook on. For example:

```bash
ansible-playbook microk8s.yml --inventory=inventory   -l dev-alexander
```
Will only run the playbook against the `dev-alexander` group.

To add more users to the microk8s group add them to the `users` list.

EX:
```yaml
users:
  - alexander
  - luke
```