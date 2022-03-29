# @summary Install and configure GSI OpenSSH Server
#
# @example
#   include profile_gsi_ssh::server
class profile_gsi_ssh::server {

  include ::profile_gsi_ssh::client

  ## NEED TO IMPLEMENT THE FOLLOWING
  # configuration for gsissh
  # install additional packages
  # alternate sshd service
  # build gridmap files, etc
  # alternate sshd_config authentication settings
  # obtaining a host certificate

}
