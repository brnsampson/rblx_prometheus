#
# Cookbook:: rblx_prometheus
# Recipe:: default
#
# Copyright:: 2020, Roblox, All Rights Reserved.
#

default['rblx_prometheus']['config']['image'] = 'prom/prometheus'
default['rblx_prometheus']['config']['tag'] = 'latest'

default['rblx_prometheus']['config']['uid'] = "34090"
default['rblx_prometheus']['config']['docker_label'] = 'prometheus'

default['rblx_prometheus']['config']['consul_addr'] = '127.0.0.1:8500'
default['rblx_prometheus']['config']['datacenter'] = nil
default['rblx_prometheus']['config']['pod'] = nil

default['rblx_prometheus']['config']['retention_time'] = '3d'
default['rblx_prometheus']['config']['scrape_unresponsive'] = true

default['rblx_prometheus']['config']['telegraf_input']['enable'] = true
default['rblx_prometheus']['config']['telegraf_input']['port'] = '9273'
default['rblx_prometheus']['config']['telegraf_input']['target_list_override'] = []
default['rblx_prometheus']['config']['telegraf_input']['graphql'] = 'graphql-infra.simulpong.com'

default['rblx_prometheus']['config']['alertmanager']['enable'] = true
default['rblx_prometheus']['config']['alertmanager']['consul_service'] = 'alertmanager-pod-telemetry'
default['rblx_prometheus']['config']['alertmanager']['target_list_override'] = []

default['rblx_prometheus']['config']['prometheus']['enable'] = true
default['rblx_prometheus']['config']['prometheus']['consul_service'] = 'prometheus-pod-telemetry'
default['rblx_prometheus']['config']['prometheus']['target_list_override'] = []

default['rblx_prometheus']['config']['remote_write']['enable'] = true
default['rblx_prometheus']['config']['remote_write']['consul_service'] = 'prom-write-adapters-pod-telemetry'
default['rblx_prometheus']['config']['remote_write']['target_list_override'] = []
default['rblx_prometheus']['config']['remote_write']['drop_metric_regex'] = 'drop_me'

#### Absent attribute. Set this to true to remove prometheus from the system
default['rblx_prometheus']['absent'] = false

#### Consul service control
default['rblx_prometheus']['absent_consul'] = false
default['rblx_prometheus']['skip_consul'] = false
