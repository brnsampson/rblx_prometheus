control 'prometheus_consul_service' do
  title 'Test prometheus consul service file'
  describe 'test for the consul service file contents expected from the kitchen test.'
  describe file('/etc/consul/conf.d/prometheus-pod-telemetry.json') do
    it { should exist }
    its('content') { should match %q({
  "service": {
    "name": "prometheus-pod-telemetry",
    "port": 9090,
    "tags": [
      "prometheus",
      "test_tag"
    ]
  }
})}
  end
end
