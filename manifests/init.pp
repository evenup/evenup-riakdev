# == Class: riakdev
#
# This class installs, configures, and joines together a four node riak
# "development" cluster.
#
#
# === Parameters
#
# [*version*]
#   String.  What version number of riak should be installed
#   Default: 1.2.1
#
# [*install_dir*]
#   String.  Path where the development nodes should be installed
#   Default: /var/lib/riak
#
#
# === Examples
#
# * Installation:
#     class { 'riakdev':
#       version => '1.3.1',
#     }
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
class riakdev(
  $version      = '1.2.1',
  $install_dir  = '/var/lib/riak',
) {

  $static_url = hiera('static_url')

  group {
    'riak':
      ensure  => 'present',
      system  => true
  }

  file {
    $install_dir:
      ensure  => directory,
      owner   => root,
      group   => root;
  }

  # TODO - move static path to hiera
  exec {
    'fetch_dev':
      command   => "/usr/bin/curl -o ${install_dir}/riak-dev-instance-${version}.tar.gz ${static_url}/riak-dev-instance-${version}.tar.gz",
      cwd       => $install_dir,
      creates   => "${install_dir}/riak-dev-instance-${version}.tar.gz",
      path      => '/usr/bin:/bin',
      logoutput => on_failure,
      require   => File[$install_dir];
  }

  riakdev::instance { 'dev1':
    instance      => 1,
    http_port     => 8091,
    pb_port       => 8081,
    handoff_port  => 8101,
    install_dir   => $install_dir,
  }

   riakdev::instance { 'dev2':
     instance      => 2,
     http_port     => 8092,
     pb_port       => 8082,
     handoff_port  => 8102,
    install_dir   => $install_dir,
  }

  riakdev::instance { 'dev3':
    instance      => 3,
    http_port     => 8093,
    pb_port       => 8083,
    handoff_port  => 8103,
    install_dir   => $install_dir,
  }

  riakdev::instance { 'dev4':
    instance      => 4,
    http_port     => 8094,
    pb_port       => 8084,
    handoff_port  => 8104,
    install_dir   => $install_dir,
  }

  # Erlang needs $HOME to be set
  exec {
    'join_plan':
      command     => "/bin/sh -c \"${install_dir}/dev1/bin/riak-admin cluster plan\"",
      cwd         => "${install_dir}/dev1",
      path        => "/bin:/usr/bin/:${install_dir}/dev1/bin",
      refreshonly => true,
      environment => "HOME=${install_dir}/dev1",
      notify      => Exec['join_commit'];

    'join_commit':
      command     => "/bin/sh -c \"${install_dir}/dev1/bin/riak-admin cluster commit\"",
      cwd         => "${install_dir}/dev1",
      path        => "/bin:/usr/bin/:${install_dir}/dev1/bin",
      refreshonly => true,
      environment => "HOME=${install_dir}/dev1",
      require     => Exec['join_plan'];
  }

  backups::riak {
    'dev_riak':
      mode    => 'dev',
      hour    => 7,
      minute  => 10;
  }
}
