#
# Cookbook:: rblx_prometheus
# Recipe:: consul_service
#
# Copyright:: 2020, Roblox, All Rights Reserved.

port = 9090
consul_name = "prometheus-pod-telemetry"

tag_list = ['prometheus']
meta = {'path' => 'api/v1/metrics/prometheus'}

consul_definition consul_name do
  type 'service'
  parameters(
    name: consul_name,
    address: '127.0.0.1',
    port: port,
    tags: tag_list,
    meta: meta,
  )
  notifies :reload, 'consul_service[consul]', :delayed
  not_if { node['rblx_prometheus']['absent_consul'] }
  not_if { node['rblx_prometheus']['skip_consul'] }
end

consul_definition consul_name do
  type 'service'
  action :delete
  notifies :reload, 'consul_service[consul]', :delayed
  only_if { node['rblx_prometheus']['absent_consul'] }
end
