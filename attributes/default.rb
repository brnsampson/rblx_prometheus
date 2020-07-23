default['rblx_prometheus']['config']['datacenter'] = nil
default['rblx_prometheus']['config']['pod'] = nil

default['rblx_prometheus']['config']['telegraf_input']['enable'] = true
default['rblx_prometheus']['config']['telegraf_input']['disable'] = false
default['rblx_prometheus']['config']['telegraf_input']['port'] = '9273'
default['rblx_prometheus']['config']['telegraf_input']['target_list'] = []
default['rblx_prometheus']['config']['telegraf_input']['graphql'] = node['graphql'].nil? ? 'graphql-infra.simulpong.com' : node['graphql']['addr']

default['rblx_prometheus']['config']['alertmanager_output']['enable'] = true
default['rblx_prometheus']['config']['alertmanager_output']['disable'] = false
default['rblx_prometheus']['config']['alertmanager_output']['service'] = 'alertmanager-pod-telemetry'

#### Absent attribute. Set this to true to remove prometheus from the system. ####
default['rblx_prometheus']['absent'] = false

#### Consul service control
default['rblx_prometheus']['absent_consul'] = false
default['rblx_prometheus']['skip_consul'] = false
