# InSpec test for recipe rblx_prometheus::default

# The InSpec reference, with examples and extensive documentation, can be
# found at https://www.inspec.io/docs/reference/resources/

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
