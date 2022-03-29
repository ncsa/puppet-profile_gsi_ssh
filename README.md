# profile_gsi_ssh

![pdk-validate](https://github.com/ncsa/puppet-profile_gsi_ssh/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_gsi_ssh/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - configure GitLab service

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with profile_gsi_ssh](#setup)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Dependencies](#dependencies)
1. [Reference](#reference)


## Description

This puppet profile installs and configures GSI OpenSSH.

See the following references for GSI OpenSSH:
- https://opensciencegrid.org/docs/other/gsissh/
- https://gridcf.org/gct-docs/latest/gsiopenssh/
- https://software.xsede.org/production/gsi-openssh-server/latest/XSEDE-GSI-OpenSSH-install.html
- http://grid.ncsa.illinois.edu/ssh/admin.html

## Setup

Include profile_gsi_ssh in a puppet profile file:
```
include ::profile_gsi_ssh
```


## Usage

The goal is that no paramters are required to be set. The default paramters should work for most NCSA deployments out of the box.


## Dependencies

- [ncsa/sshd](https://github.com/ncsa/puppet-sshd)


## Reference

See: [REFERENCE.md](REFERENCE.md)
