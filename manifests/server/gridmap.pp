# @summary Configure and manage gridmap file
# 
# Generally speaking some files and/or cron scripts will need to be put in place for
# grid map and voms authentication.
# This class lets various custom files and cron entries be setup via hiera parameters
# for this purpose.
#
# See: https://opensciencegrid.org/docs/security/lcmaps-voms-authentication/#configuring-the-lcmaps-voms-plugin
#
# @param crons
#   Cron resources for setting up gridmap files
#
# @param files
#   File resources for setting up gridmap files
#
# @example
#   include profile_gsi_ssh::server::gridmap
class profile_gsi_ssh::server::gridmap (
  Hash $crons,
  Hash $files,
) {

  $cron_defaults = {
    ensure  => present,
  }
  ensure_resources('cron', $crons, $cron_defaults )

  $file_defaults = {
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
  ensure_resources('file', $files, $file_defaults )

}
