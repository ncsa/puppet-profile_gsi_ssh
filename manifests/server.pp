# @summary Install and configure GSI OpenSSH Server
#
# @param allow_groups
#   List of groups allowed access via GSI OpenSSH server
#
# @param config
#   Hash of global config settings
#   Defaults provided by this module
#   Values from multiple sources are merged
#   Key collisions are resolved in favor of the higher priority value
#
# @param config_file
#   Full path to sshd_config file
#
# @param deny_groups
#   List of groups denied access via GSI OpenSSH server
#
# @param disable_service_name
#   Name of default sshd service to disable
#
# @param files
#   File resources for setting up files
#
# @param manage_service
#   Flag of whether to manage sshd service
#
# @param port
#   TCP port that GSI OpenSSH server listens on
#
# @param required_packages
#   List of package names to be installed (OS specific).
#
# @param service_name
#   Name of gsi-sshd service
#
# @param subnets
#   List of network subnets allowed access via GSI OpenSSH server
#
# @example
#   include profile_gsi_ssh::server
class profile_gsi_ssh::server (
  Array[String] $allow_groups,
  Hash          $config,
  String        $config_file,
  Array[String] $deny_groups,
  String        $disabled_service_name,
  Hash          $files,
  Boolean       $manage_service,
  String        $port,
  Array[String] $required_packages,
  String        $service_name,
  Array[String] $subnets,
) {

  include ::profile_gsi_ssh::client
  include ::profile_gsi_ssh::server::cert
  include ::profile_gsi_ssh::server::gridmap

  # PACKAGES
  ensure_packages( $required_packages, {'ensure' => 'present'} )

  $file_defaults = {
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
  ensure_resources('file', $files, $file_defaults )

  if ( ! empty($disabled_service_name) ) {
    service { $disabled_service_name :
      ensure     => stopped,
      enable     => false,
      hasstatus  => true,
      hasrestart => true,
    }
  }
  if ( $manage_service ) {
    service { $service_name :
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => [
        Package[ $required_packages ],
      ],
    }
    # SET DEFAULTS TO NOTIFY SERVICE
    $config_defaults = {
      'notify' => Service[$service_name] ,
      'target' => $config_file,
    }
  } else {
    # SET DEFAULTS TO SKIP NOTIFY SERVICE
    # THE ENSURE => PRESENT IS A DEFAULT, BUT SETTING IT SO THAT WE CAN SET SOME DEFAULT
    $config_defaults = {
      'ensure' => present,
      'target' => $config_file,
    }
  }

  # CONFIGURE gsissh sshd_config FILE

  $puppet_file_header = '# This file is managed by Puppet - Changes may be overwritten'
  exec { "add puppet header to ${config_file}":
    command => "sed -i '1s/^/${puppet_file_header}\\n/' '${config_file}'",
    unless  => "grep '${puppet_file_header}' ${config_file}",
    path    => [ '/bin', '/usr/bin' ],
  }
  # CONFIGURE PORT
  sshd_config {
    'GSI Port' :
      key   => 'Port',
      value => $port,
    ;
    default:
      * => $config_defaults,
    ;
  }
  # ADD DENY GROUPS
  sshd_config {
    'GSI DenyGroups' :
      key   => 'DenyGroups',
      value => $deny_groups,
    ;
    default:
      * => $config_defaults,
    ;
  }
  # APPLY MISC sshd_config SETTINGS
  $config.each | $key, $val | {
    sshd_config {
      "GSI ${key}" :
        key   => $key,
        value => $val,
      ;
      default:
        * => $config_defaults,
      ;
    }
  }

  # Setup Match Block
  # Logic borrowed from https://github.com/ncsa/puppet-sshd/blob/3a27bd52e01f5484605e6e45297b0cc646f1c979/manifests/allow_from.pp#L127
  $config_match_defaults = $config_defaults + {
    'position' => 'before first match'
  }
  $additional_match_params = {
    'AuthenticationMethods' => 'gssapi-keyex gssapi-with-mic',
  }
  $group_params = $allow_groups ? {
    Array[ String, 1 ] => { 'AllowGroups' => $allow_groups },
    default            => {}
  }
  # Combine all cfg_match_params into a single hash
  $cfg_match_params = $additional_match_params + $group_params
  #$cfg_match_params = $group_params

  # Create Host and/or Address match criteria
  # Hostnames require "Match Host"
  # IPs/CIDRs require "Match Address"
  # Create separate lists and make two separate match blocks in sshd_config
  # Criteria will be either "Host" or "Address"
  # Pattern will be the CSV string of hostnames or IPs
  # See also: "sshd_config" man page, for details of "criteria-pattern pairs"
  $name_list = $subnets.filter | $elem | { $elem =~ /[a-zA-Z]/ }
  $ip_list   = $subnets.filter | $elem | { $elem !~ /[a-zA-Z]/ }
  #associate the correct criteria with each list, filter empty lists
  $host_data = {
    'Host'    => $name_list,
    'Address' => $ip_list,
  }.filter | $criteria, $list | {
    size( $list ) > 0
  }

  # WE DO NOT CURRENTLY SUPPORT LISTS OF USERS
  #$users = []
  ## Create User match criteria (empty if user list is empty)
  #$user_csv = $users ? {
  #  Array[ String, 1 ] => join( $users, ',' ),
  #  default            => '',
  #}
  #$user_criteria = $user_csv ? {
  #  String[1] => "User ${user_csv}",
  #  default   => '',
  #}
  # Create Group match criteria (empty if group list is empty)
  $group_csv = $allow_groups ? {
    Array[ String, 1 ] => join( $allow_groups, ',' ),
    default            => '',
  }
  $group_criteria = $group_csv ? {
    String[1] => "Group ${group_csv}",
    default   => '',
  }

  #loop through host_data creating a match block for each criteria-pattern
  $host_data.each | $criteria, $list | {
    $pattern = join( $list, ',' )
    #$match_condition = "${criteria} ${pattern} ${user_criteria} ${group_criteria}"
    # SPECIFYING GROUPS IN MATCH BREAKS ACCESS FOR USERS WHOSE REMOTE USERNAMES DIFFER FROM MAPPED USERNAME
    #$match_condition = "${criteria} ${pattern} ${group_criteria}"
    $match_condition = "${criteria} ${pattern}"

    #ensure match block exists
    ensure_resource( 'sshd_config_match', $match_condition, $config_match_defaults )

    #add parameters to the match block
    $config_data = $cfg_match_params.reduce( {} ) | $memo, $kv | {
      $key = $kv[0]
      $val = $kv[1]
      $memo + {
        "${match_condition} ${key}" => {
          'key'       => $key,
          'value'     => $val,
          'condition' => $match_condition,
        }
      }
    }
    ensure_resources( 'sshd_config', $config_data, $config_defaults )
  }


  ### FIREWALL
  $subnets.each | $subnet | {
    firewall { "222 allow GSI-SSH on ${port} from ${subnet}":
      dport  => $port,
      proto  => tcp,
      source => $subnet,
      action => accept,
    }
  }

}
