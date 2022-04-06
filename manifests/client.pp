# @summary Install and configure GSI OpenSSH client
#
# @param required_packages
#   List of package names to be installed (OS specific).
#
# @example
#   include profile_gsi_ssh::client
class profile_gsi_ssh::client (
  Array[String]     $required_packages,   #per OS
) {

  # PACKAGES
  ensure_packages( $required_packages, {'ensure' => 'present'} )

}
