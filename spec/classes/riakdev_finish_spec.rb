require 'spec_helper'

describe 'riakdev::finish', :type => :class do
  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }
  let(:hiera_data) { { :static_url => 'myurl' } }
  let(:params) { { :install_dir => '/var/lib/riak' } }

  it { should create_class('riakdev::finish') }
  it { should contain_exec('join_plan').with(
    'command'     => '/bin/sh -c "/var/lib/riak/dev2/bin/riak-admin cluster plan"',
    'cwd'         => '/var/lib/riak/dev2',
    'environment' => 'HOME=/var/lib/riak/dev2',
    'refreshonly' => true
  ) }
  it { should contain_exec('join_commit').with(
    'command'     => '/bin/sh -c "/var/lib/riak/dev2/bin/riak-admin cluster commit"',
    'cwd'         => '/var/lib/riak/dev2',
    'environment' => 'HOME=/var/lib/riak/dev2',
    'refreshonly' => true
  ) }
#  it { should contain_backups__riak('dev_riak').with_mode('dev') }

end
