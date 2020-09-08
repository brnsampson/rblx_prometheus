default['rblx_prometheus']['image'] = 'prom/prometheus'
default['rblx_prometheus']['tag'] = 'latest'

default['rblx_prometheus']['config']['uid'] = "34090"
default['rblx_prometheus']['config']['docker_label'] = 'prometheus'

default['rblx_prometheus']['config']['datacenter'] = nil
default['rblx_prometheus']['config']['pod'] = nil

default['rblx_prometheus']['config']['telegraf_input']['enable'] = true
default['rblx_prometheus']['config']['telegraf_input']['port'] = '9273'
default['rblx_prometheus']['config']['telegraf_input']['target_list_override'] = []
default['rblx_prometheus']['config']['telegraf_input']['graphql'] = node['graphql'].nil? ? 'graphql-infra.simulpong.com' : node['graphql']['addr']

default['rblx_prometheus']['config']['alertmanager']['enable'] = true
default['rblx_prometheus']['config']['alertmanager']['consul_service'] = 'alertmanager-pod-telemetry'
default['rblx_prometheus']['config']['alertmanager']['target_list_override'] = []

default['rblx_prometheus']['config']['prometheus']['enable'] = true
default['rblx_prometheus']['config']['prometheus']['consul_service'] = 'prometheus-pod-telemetry'
default['rblx_prometheus']['config']['prometheus']['target_list_override'] = []

#### Absent attribute. Set this to true to remove prometheus from the system
default['rblx_prometheus']['absent'] = false

#### Consul service control
default['rblx_prometheus']['absent_consul'] = false
default['rblx_prometheus']['skip_consul'] = false
