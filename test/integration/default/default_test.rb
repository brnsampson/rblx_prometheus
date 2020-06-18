# InSpec test for recipe rblx_prometheus::default

# The InSpec reference, with examples and extensive documentation, can be
# found at https://www.inspec.io/docs/reference/resources/

#unless os.windows?
#  # This is an example test, replace with your own test.
#  describe user('root'), :skip do
#    it { should exist }
#  end
#end
#
## This is an example test, replace it with your own test.
#describe port(80), :skip do
#  it { should_not be_listening }
#end

describe service('docker') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe service('prometheus') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe port(9090) do
  it { should be_listening }
end

describe command('curl -XGET -s http://localhost:9090/-/healthy') do
  its('stdout') { should eq "Prometheus is Healthy.\n" }
end
