# profile_gsi_ssh

![pdk-validate](https://github.com/ncsa/puppet-profile_gsi_ssh/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_gsi_ssh/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - install and configure GSI-SSH

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with profile_gsi_ssh](#setup)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Dependencies](#dependencies)
1. [Reference](#reference)


## Description

This puppet profile installs and configures GSI OpenSSH.

See the following references for GSI OpenSSH:
- https://gridcf.org/gct-docs/latest/gsiopenssh/
- https://software.xsede.org/production/gsi-openssh-server/versionless/XSEDE-GSI-OpenSSH-install.html
- https://opensciencegrid.org/docs/other/gsissh/

## Setup

### GSI-OpenSSHd Service

Include profile_gsi_ssh in a puppet profile file:
```
include ::profile_gsi_ssh::server
```

A few parameters must be set, e.g. via hiera or vault:
```yaml
profile_gsi_ssh::server::allow_groups:
  - "project_active_users"
profile_gsi_ssh::server::deny_groups:
  - "all_disabled_usr"
  - "project_denied_users"
profile_gsi_ssh::server::cert::hostcert: |
  -----BEGIN CERTIFICATE----- 
  ...
  -----END CERTIFICATE----- 
profile_gsi_ssh::server::cert::hostkey: |
  -----BEGIN RSA PRIVATE KEY-----
  ...
  -----END RSA PRIVATE KEY-----
```

### GSI-OpenSSH Client

Optionally you can just include the GSI-OpenSSH client:
```
include ::profile_gsi_ssh::client
```


## Usage

For GSI-OpenSSH Server usage, a few parameters noted above will need to be set.

### grid-mapfile Scripts

You will need to customize the `profile_gsi_ssh::server::gridmap::crons` & `profile_gsi_ssh::server::gridmap::files` parameters to fit with how you need to sync in the `/etc/grid-security/grid-mapfile`. Sample scripts and a cron are included, but at a minimum will need to be updated to match where you need to sync your `grid-mapfile`(s) from.


## Dependencies

- [herculesteam/augeasproviders](https://forge.puppet.com/herculesteam/augeasproviders)
- [ncsa/profile_monitoring](https://github.com/ncsa/puppet-profile_monitoring) - for optional telegraf monitoring of ssl hostkey
- [ncsa/sshd](https://github.com/ncsa/puppet-sshd)
- [puppet/epel](https://forge.puppet.com/modules/puppet/epel)


## Reference

See: [REFERENCE.md](REFERENCE.md)
