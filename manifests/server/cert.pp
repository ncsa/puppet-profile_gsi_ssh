# @summary Manage the certificates for GSI-OpenSSH service
#
# @param files
#   File resources for setting up files
#
# @param hostcert
#   Host IGTF Server certificate file contents
#
# @param hostcert_path
#   Full path to host IGTF Server certificate file
#
# @param hostkey
#   Host IGTF Server private key file contents
#
# @param hostkey_path
#   Full path to host IGTF Server private key file
#
# @param monitor
#   Whether to monitor the hostcert for validity with Telegraf
#
# @param monitor_file_content
#   Content of telegraf input file template
#
# @param monitor_file_path
#   Full path to telegraf input file template
#
# @param monitor_interval
#   Interval used by telegraf input
#
# @param required_packages
#   List of package names to be installed (OS specific).
#
# @example
#   include profile_gsi_ssh::server::cert
class profile_gsi_ssh::server::cert (
  Hash          $files,
  String        $hostcert,
  String        $hostcert_path,
  String        $hostkey,
  String        $hostkey_path,
  Boolean       $monitor,
  String        $monitor_file_content,
  String        $monitor_file_path,
  String        $monitor_interval,
  Array[String] $required_packages,
) {

  # PACKAGES
  ensure_packages( $required_packages, {'ensure' => 'present'} )

  if ( $profile_gsi_ssh::server::manage_service ) {
    File {
      notify  => Service[$profile_gsi_ssh::server::service_name],
    }
  }

  $file_defaults = {
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
  ensure_resources('file', $files, $file_defaults )

  file { $hostcert_path :
    content => Sensitive($hostcert),
    mode    => '0444',
  }
  file { $hostkey_path :
    content => Sensitive($hostkey),
    mode    => '0400',
  }

  if ( $monitor ) {
    # SETUP A LOCAL TELEGRAF INPUT FILE FOR SSL CERT MONITORING
    include profile_monitoring::telegraf
    if ( $::profile_monitoring::telegraf::enabled )
    {
      file { $monitor_file_path :
        content => $monitor_file_content,
        group   => 'telegraf',
        mode    => '0640',
        owner   => 'root',
        replace => false,
        notify  => Service['telegraf'],
      }
      file_line { 'set sslcert-check interval':
        ensure   => 'present',
        after    => ']',
        line     => "  interval = \"${monitor_interval}\"",
        match    => 'interval',
        multiple => 'false',
        notify   => Service['telegraf'],
        path     => $monitor_file_path,
      }
      file_line { "telegraf_sslcert_check for ${hostcert_path}":
        ensure   => 'present',
        after    => 'sources',
        line     => "    \"file://${hostcert_path}\",",
        match    => $hostcert_path,
        multiple => 'false',
        notify   => Service['telegraf'],
        path     => $monitor_file_path,
      }
    }
  }

}
