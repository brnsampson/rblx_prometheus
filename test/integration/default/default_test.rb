# InSpec test for recipe rblx_prometheus::default

# The InSpec reference, with examples and extensive documentation, can be
# found at https://www.inspec.io/docs/reference/resources/

describe group('prometheus') do
  it { should exist }
end

describe user('prometheus') do
  it { should exist }
  its('uid') { should eq 34090 }
  its('group') { should eq 'prometheus' }
end

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

describe file('/etc/prometheus/prometheus.yml') do
  it { should exist }
end

describe file('/etc/prometheus/prometheus.rules.yml') do
  it { should exist }
end

describe command('curl -XGET -s http://localhost:9090/-/healthy') do
  its('stdout') { should match "Prometheus is Healthy." }
end

describe file('/etc/prometheus/prometheus.yml') do
  # The target list utilizes the override attr
  its('content') { should include(%q(["fake-target-1", "fake-target-2"])) }
  # These three query consul
  its('content') { should match %q(\["\d+\.\d+\.\d+\.\d+:9090"\]) }
  its('content') { should include(%q(["fake-alertmanager-1", "fake-alertmanager-2"])) }
  #its('content') { should match %q(\["\d+\.\d+\.\d+\.\d+:1234"\]) }
  its('content') { should match %q("http://\d+\.\d+\.\d+\.\d+:1236/receive") }
  # Make sure we got the drop regex in the config
  its('content') { should match %q(drop_me) }
  # Make sure we got the dc and pod labels in the config
  its('content') { should match %q(fake-pod) }
  its('content') { should match %q(fake-datacenter) }
end
