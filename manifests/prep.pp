# == Class: riakdev::prep
#
# This class sets up the environment for installing instances.  It should not
# be called directly
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
class riakdev::prep(
  $version      = '1.2.1',
  $install_dir  = '/var/lib/riak',
  $static_url   = 'http://files/',
) {

  group { 'riak':
    ensure  => 'present',
    system  => true,
  }

  file { $install_dir:
    ensure  => directory,
    owner   => root,
    group   => root,
  }

  # TODO - move static path to hiera
  exec { 'fetch_dev':
    command   => "/usr/bin/curl -o ${install_dir}/riak-dev-instance-${version}.tar.gz ${static_url}/riak-dev-instance-${version}.tar.gz",
    cwd       => $install_dir,
    creates   => "${install_dir}/riak-dev-instance-${version}.tar.gz",
    path      => '/usr/bin:/bin',
    logoutput => on_failure,
    require   => File[$install_dir],
  }
}
