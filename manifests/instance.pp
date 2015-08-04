# == Define: riak::instance
#
# This define configures an individual node in a riak development cluster
#
#
# === Parameters
#
# [*instance*]
#   Integer.  Instance number for this install
#
# [*http_port*]
#   Integer.  Port riak listens for HTTP connections
#
# [*pb_port*]
#   Integer.  Port riak listens for PB connections
#
# [*handoff_port*]
#   Integer.  Riak handoff port
#
# [*install_dir*]
#   String.  Installation directory for nodes
#
#
# === Examples
#
#   riakdev::instance { 'dev1':
#     instance      => 1,
#     http_port     => 8091,
#     pb_port       => 8081,
#     handoff_port  => 8101,
#     install_dir   => '/var/lib/riak',
#   }
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
define riakdev::instance(
  $instance,
  $http_port,
  $pb_port,
  $handoff_port,
  $install_dir,
  $join_node = false,
) {

  $version = $riakdev::version

  File {
    require => User["riak${instance}"],
  }

  user { "riak${instance}":
    ensure => 'present',
    system => true,
    gid    => 'riak',
    home   => "${install_dir}/dev${instance}",
    shell  => '/bin/bash',
  }

  case $instance {
    /^(1|'1')$/, 1:  {
      $join_notify = File["${install_dir}/dev${instance}/bin/riak"]
    }
    default:    {
      $join_notify = Exec["join_node${instance}"]
    }
  }

  exec { "decompress_dev${instance}":
    command   => "/bin/tar -xzf ${install_dir}/riak-dev-instance-${version}.tar.gz -C ${install_dir} ; mv ${install_dir}/dev ${install_dir}/dev${instance} ; chown -R riak${instance}:riak ${install_dir}/dev${instance} ; rm -f ${install_dir}/dev${instance}/etc/riak.conf",
    cwd       => $install_dir,
    path      => '/usr/bin:/bin',
    unless    => "test -d ${install_dir}/dev${instance}",
    logoutput => on_failure,
    notify    => $join_notify,
    require   => [ User["riak${instance}"], Class['Riakdev::Prep'] ],
  }

  exec { "mkdir_tmpdir_${instance}":
    command => "mkdir -p /tmp/var/lib/riak/dev${instance}",
    cwd     => $install_dir,
    unless  => "test -d /tmp/var/lib/riak/dev${instance}",
    path    => '/bin:/usr/bin',
  }

  file { "/tmp/var/lib/riak/dev${instance}":
    owner   => "riak${instance}",
    group   => 'riak',
    require => [ Exec["mkdir_tmpdir_${instance}"], User["riak${instance}"] ],
  }

  file { [ "${install_dir}/dev${instance}/bin/riak", "${install_dir}/dev${instance}/bin/riak-admin" ]:
    owner   => "riak${instance}",
    group   => 'riak',
    mode    => '0555',
    require => Exec["decompress_dev${instance}"],
  }

  file { "${install_dir}/dev${instance}/etc/riak.conf":
    ensure  => file,
    owner   => "riak${instance}",
    group   => riak,
    mode    => '0444',
    content => template('riakdev/riak.conf.erb'),
    require => Exec["decompress_dev${instance}"],
    replace => false,
  }

  firewall { "550 allow riak(${instance}) inbound":
    action => 'accept',
    state  => 'NEW',
    dport  => [$http_port, $pb_port, $handoff_port],
  }

  file { "/usr/lib/systemd/system/riak${instance}.service":
    ensure  => 'file',
    content => template('riakdev/riak.service.erb'),
  }

  service { "riak${instance}":
    ensure  => running,
    enable  => true,
    require => [ File["/tmp/var/lib/riak/dev${instance}"], File["${install_dir}/dev${instance}/bin/riak"], File["${install_dir}/dev${instance}/etc/riak.conf"], File["/usr/lib/systemd/system/riak${instance}.service"] ],
  }

  # This is here to prevent dependency cycle on dev1.  Find a better way to do this
  case $instance {
    /^(1|'1')$/, 1:  { }
    default:    {
      exec { "join_node${instance}":
        command     => "/bin/sh -c \"${install_dir}/dev${instance}/bin/riak-admin cluster join dev1@127.0.0.1\"",
        cwd         => "${install_dir}/dev${instance}",
        path        => "/bin:/usr/bin:${install_dir}/dev${instance}/bin",
        refreshonly => true,
        environment => "HOME=${install_dir}/dev${instance}",
        notify      => Class['Riakdev::Finish'],
        require     => [ Riakdev::Instance['dev1'], Service["riak${instance}"] ],
      }
    }
  }

}
