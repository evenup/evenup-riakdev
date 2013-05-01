require 'spec_helper'

describe 'riakdev::instance', :type => :define do
  let(:title) { 'instance1' }
  let(:facts) { { :fqdn => 'somehost', :concat_basedir => '/var/lib/puppet/concat' } }

  context "when called with instance => 1, http_port => 1234, pb_port => 2345, handoff_port => 3456" do
    let(:params) { { :instance => 1, :http_port => 1234, :pb_port => 2345, :handoff_port => 3456, :install_dir => '/varlib/riak' } }

    it { should contain_exec('decompress_dev1').with_notify('File[/varlib/riak/dev1/bin/riak]') }
  end

  context "when called with instance => 10, http_port => 1234, pb_port => 2345, handoff_port => 3456" do
    let(:params) { { :instance => 10, :http_port => 1234, :pb_port => 2345, :handoff_port => 3456, :install_dir => '/var/lib/riak' } }

    it { should contain_user('riak10').with_home('/var/lib/riak/dev10') }
    it { should contain_exec('decompress_dev10').with_notify('Exec[join_node10]') }
    it { should contain_file('/var/lib/riak/dev10/bin/riak').with_owner('riak10') }
    it { should contain_file('/var/lib/riak/dev10/bin/riak-admin').with_owner('riak10') }
    it { should contain_file('/var/lib/riak/dev10/etc/app.config') }
    it { should contain_file('/var/lib/riak/dev10/etc/app.config').with_content(/\{http, \[ \{"0.0.0.0", 1234 \} \]\}/) }
    it { should contain_file('/var/lib/riak/dev10/etc/app.config').with_content(/\{pb_port, 2345 \}/) }
    it { should contain_file('/var/lib/riak/dev10/etc/app.config').with_content(/\{handoff_port, 3456 \}/) }
    it { should contain_file('/var/lib/riak/dev10/etc/vm.args') }
    it { should contain_file('/var/lib/riak/dev10/etc/vm.args').with_content(/\-name dev10@somehost/) }
    it { should contain_file('/etc/init.d/riak_dev10') }
    it { should contain_file('/etc/init.d/riak_dev10').with_content(/HOME=\/var\/lib\/riak\/dev10/) }
    it { should contain_service('riak_dev10').with_enable(true) }
    it { should contain_exec('join_node10') }

  end

end
