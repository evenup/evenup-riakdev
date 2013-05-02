require 'spec_helper'

describe 'riakdev::prep', :type => :class do
#  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }
  let(:hiera_data) { { :static_url => 'myurl' } }
  let(:params) { { :install_dir => '/var/lib/riak', :version => '1.3.1' }}

  it { should create_class('riakdev::prep') }
  it { should contain_group('riak').with_system(true) }
  it { should contain_file('/var/lib/riak').with_ensure('directory') }
  it { should contain_exec('fetch_dev') }

end
