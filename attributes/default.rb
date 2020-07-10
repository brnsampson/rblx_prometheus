default['rblx_prometheus']['absent'] = false
default['rblx_prometheus']['collection']['scrape_list'] = ['localhost:9090']
default['rblx_prometheus']['collection']['scrape_discovery'] = true

#### Consul service control
default['rblx_fluent_bit']['absent_consul'] = false
default['rblx_fluent_bit']['skip_consul'] = false
