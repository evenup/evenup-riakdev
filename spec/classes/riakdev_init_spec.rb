require 'spec_helper'

describe 'riakdev', :type => :class do
  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }
  let(:hiera_data) { { :static_url => 'myurl' } }

  it { should create_class('riakdev') }
  it { should contain_class('riakdev::prep')}
  it { should contain_class('riakdev::instances')}
  it { should contain_class('riakdev::finish')}

end
