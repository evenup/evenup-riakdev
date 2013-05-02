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
#
# === Copyright
#
# Copyright 2013 EvenUp.
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
    before  => Service["riak_dev${instance}"]
  }

  Exec {
    require => User["riak${instance}"]
  }

  user { "riak${instance}":
    ensure  => 'present',
    system  => true,
    gid     => 'riak',
    home    => "${install_dir}/dev${instance}",
    shell   => '/bin/bash',
  }

  case $instance {
    /^(1|'1')$/:  {
      $join_notify = File["${install_dir}/dev${instance}/bin/riak"]
    }
    default:    {
      $join_notify = Exec["join_node${instance}"]
    }
  }

  exec { "decompress_dev${instance}":
    command   => "/bin/tar -xzf ${install_dir}/riak-dev-instance-${version}.tar.gz -C ${install_dir} ; mv ${install_dir}/dev ${install_dir}/dev${instance} ; chown -R riak${instance}:riak ${install_dir}/dev${instance} ; rm -f ${install_dir}/dev${instance}/etc/{app.config,vm.args}",
    cwd       => $install_dir,
    path      => '/usr/bin:/bin',
    unless    => "test -d ${install_dir}/dev${instance}",
    logoutput => on_failure,
    notify    => $join_notify,
    require   => [ User["riak${instance}"], Class['Riakdev::Prep'] ],
  }

  file { [ "${install_dir}/dev${instance}/bin/riak", "${install_dir}/dev${instance}/bin/riak-admin" ]:
    owner   => "riak${instance}",
    group   => 'riak',
    mode    => '0555',
    require => Exec["decompress_dev${instance}"],
  }

  file { "${install_dir}/dev${instance}/etc/app.config":
    ensure  => file,
    owner   => "riak${instance}",
    group   => riak,
    mode    => '0444',
    content => template('riakdev/dev_app.config'),
    require => Exec["decompress_dev${instance}"],
    replace => false,
  }

  file { "${install_dir}/dev${instance}/etc/vm.args":
    ensure  => file,
    owner   => "riak${instance}",
    group   => riak,
    mode    => '0444',
    content => template('riakdev/dev_vm.args'),
    require => Exec["decompress_dev${instance}"],
    replace => false,
  }

  file { "/etc/init.d/riak_dev${instance}":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0555,
    content  => template('riakdev/riak_init.erb'),
  }

  service { "riak_dev${instance}":
    ensure  => running,
    enable  => true,
    require => [ File["${install_dir}/dev${instance}/bin/riak"], File["${install_dir}/dev${instance}/bin/riak-admin"],
                 File["${install_dir}/dev${instance}/etc/app.config"], File["${install_dir}/dev${instance}/etc/vm.args"],
                 File["/etc/init.d/riak_dev${instance}"] ]
  }

  # This is here to prevent dependency cycle on dev1.  Find a better way to do this
  case $instance {
    /^(1|'1')$/:  { }
    default:    {
      exec { "join_node${instance}":
        command     => "/bin/sh -c \"${install_dir}/dev${instance}/bin/riak-admin cluster join dev1@${::fqdn}\"",
        cwd         => "${install_dir}/dev${instance}",
        path        => "/bin:/usr/bin:${install_dir}/dev${instance}/bin",
        refreshonly => true,
        environment => "HOME=${install_dir}/dev${instance}",
        notify      => Class['Riakdev::Finish'],
        require     => Riakdev::Instance['dev1'],
      }
    }
  }


  $scheme = inline_template("<%= scope.lookupvar('::fqdn').split('.').reverse.join('.')%>.riak.dev<%= scope.lookupvar('instance')%>")
  # Metrics
  sensu::check { "riak-dev${instance}-metrics":
    type        => 'metric',
    handlers    => 'graphite',
    command     => "/etc/sensu/plugins/riak-metrics.rb -s ${scheme} -h localhost -p ${http_port}",
    standalone  => true,
    interval    => 30,
  }

}

# TODO - purge logs?
