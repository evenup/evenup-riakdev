# == Class: riakdev
#
# This class is here to encapsulate dependencies.  The riakdev::finish execs
# make for some nasty dependency loops.  This class should not be called
# directly.
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class riakdev::instances (
  $num_instances        = $::riakdev::num_instances,
  $pb_initial_port      = $::riakdev::pb_initial_port,
  $http_initial_port    = $::riakdev::http_initial_port,
  $handoff_initial_port = $::riakdev::handoff_initial_port,
  $install_dir          = $::riakdev::install_dir,
) {

  $instances = gen_instances($num_instances, $pb_initial_port, $http_initial_port, $handoff_initial_port, $install_dir)
  create_resources('riakdev::instance', $instances)

}
