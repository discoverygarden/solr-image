# AWS Profile

Configures an AWS profile

## Requirements

The `aws_iam_user` must be created beforehand, and the user on localhost must
have access to the access keys for that role.

## Role Variables

The `config` object holds a set key values pairs for [configuring the aws
profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-settings).
The `profile` value holds the name of the profile to create on the host. The
default config is the following.

```yaml
config:
  region: us-east-1
profile: default
```

`user` and `home_dir` set for which linux user the profile is created for and
where the profile is created. By default the `home_dir` is `/home/{{ user }}`.

The `aws_iam_user` is the AWS user the generated profile will have access to.
The role creates an access key for the `aws_iam_user` on the host running the
playbook, the `local_profile` is the profile that will be used to generate the
key.

## Dependencies

- community.aws
