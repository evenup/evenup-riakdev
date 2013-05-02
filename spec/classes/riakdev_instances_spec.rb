require 'spec_helper'

describe 'riakdev', :type => :class do
  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }
  let(:hiera_data) { { :static_url => 'myurl' } }

  let(:params) { {
    :num_instances        => 4,
    :pb_initial_port      => 8081,
    :http_initial_port    => 8091,
    :handoff_initial_port => 8101,
    :install_dir          => '/var/lib/riak',
  } }

  it { should create_class('riakdev::instances') }
  it { should contain_riakdev__instance('dev1') }
  it { should contain_riakdev__instance('dev2') }
  it { should contain_riakdev__instance('dev3') }
  it { should contain_riakdev__instance('dev4') }

end
