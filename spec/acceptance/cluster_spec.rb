require 'spec_helper_acceptance'

describe 'riakdev cluster' do

  context 'install/configure' do
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      include firewall
      class { 'riakdev':
        version    => '2.1.1',
        static_url => 'http://yum/static/',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe port(8081) do
      it { should be_listening }
    end

    describe port(8082) do
      it { should be_listening }
    end

    describe port(8083) do
      it { should be_listening }
    end

    describe port(8084) do
      it { should be_listening }
    end

    describe port(8091) do
      it { should be_listening }
    end

    describe port(8092) do
      it { should be_listening }
    end

    describe port(8093) do
      it { should be_listening }
    end

    describe port(8094) do
      it { should be_listening }
    end

    describe port(8101) do
      it { should be_listening }
    end

    describe port(8102) do
      it { should be_listening }
    end

    describe port(8103) do
      it { should be_listening }
    end

    describe port(8104) do
      it { should be_listening }
    end

  end # install/config

end
