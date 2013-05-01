require 'spec_helper'

describe 'riakdev', :type => :class do
  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }
  let(:hiera_data) { { :static_url => 'myurl' } }

  it { should create_class('riakdev') }
  it { should contain_group('riak').with_system(true) }
  it { should contain_file('/var/lib/riak').with_ensure('directory') }
  it { should contain_exec('fetch_dev') }
  it { should contain_riakdev__instance('dev1') }
  it { should contain_riakdev__instance('dev2') }
  it { should contain_riakdev__instance('dev3') }
  it { should contain_riakdev__instance('dev4') }
  it { should contain_exec('join_plan').with(
    'command'     => '/bin/sh -c "/var/lib/riak/dev1/bin/riak-admin cluster plan"',
    'cwd'         => '/var/lib/riak/dev1',
    'environment' => 'HOME=/var/lib/riak/dev1',
    'refreshonly' => true
  ) }
  it { should contain_exec('join_commit').with(
    'command'     => '/bin/sh -c "/var/lib/riak/dev1/bin/riak-admin cluster commit"',
    'cwd'         => '/var/lib/riak/dev1',
    'environment' => 'HOME=/var/lib/riak/dev1',
    'refreshonly' => true
  ) }
  it { should contain_backups__riak('dev_riak').with_mode('dev') }

end
