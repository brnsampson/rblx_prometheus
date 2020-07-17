default['rblx_prometheus']['absent'] = false
default['rblx_prometheus']['config']['collection']['scrape_discovery'] = true
default['rblx_prometheus']['config']['collection']['scrape_list'] = ['localhost:9090']

default['rblx_prometheus']['config']['alerting']['consul_discovery'] = true
default['rblx_prometheus']['config']['alerting']['alertmanager_service'] = 'alertmanager-pod-telemetry'
default['rblx_prometheus']['config']['alerting']['_disable'] = false

#### Consul service control
default['rblx_prometheus']['absent_consul'] = false
default['rblx_prometheus']['skip_consul'] = false
