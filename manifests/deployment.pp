#
# Manages a Wildfly deployment
#
define wildfly::deployment(
  $ensure            = present,
  $timeout           = undef,
  $server_group      = undef,
  $source            = undef) {

  $file_name = inline_template('<%= File.basename(URI::parse(@source).path) %>')
  $local_source = "/tmp/${file_name}"

  exec { "download deployable from ${source}":
    command  => "/usr/bin/wget -N -P /tmp ${source} --max-redirect=5",
    path     => ['/bin', '/usr/bin', '/sbin'],
    loglevel => 'notice',
    creates  => $local_source,
  }
  ->
  file { $local_source:
    ensure  => 'present',
    owner   => $::wildfly::user,
    group   => $::wildfly::group,
    mode    => '0755',
  }
  ~>
  wildfly_deployment { $name:
    ensure       => $ensure,
    server_group => $server_group,
    username     => keys($::wildfly::users_mgmt)[0],
    password     => $::wildfly::users_mgmt['wildfly']['password'],
    host         => $::wildfly::mgmt_bind,
    port         => $::wildfly::mgmt_http_port,
    timeout      => $timeout,
    source       => "file:${local_source}"
  }

}