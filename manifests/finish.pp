# == Class: riakdev::finish
#
# This class finishes the cluster config and sets up backups
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
class riakdev::finish(
  $install_dir  = '/var/lib/riak',
) {

  # Erlang needs $HOME to be set
  exec { 'join_plan':
    command     => "/bin/sh -c \"${install_dir}/dev2/bin/riak-admin cluster plan\"",
    cwd         => "${install_dir}/dev2",
    path        => "/bin:/usr/bin/:${install_dir}/dev2/bin",
    refreshonly => true,
    environment => "HOME=${install_dir}/dev2",
    notify      => Exec['join_commit'],
  }

  exec { 'join_commit':
    command     => "/bin/sh -c \"${install_dir}/dev2/bin/riak-admin cluster commit\"",
    cwd         => "${install_dir}/dev2",
    path        => "/bin:/usr/bin/:${install_dir}/dev2/bin",
    refreshonly => true,
    environment => "HOME=${install_dir}/dev2",
    require     => Exec['join_plan'],
  }

#  backups::riak {
#    'dev_riak':
#      mode    => 'dev',
#      hour    => 7,
#      minute  => 10;
#  }

}

