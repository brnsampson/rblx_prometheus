#
# Cookbook:: rblx_prometheus
# Recipe:: consul_service
#
# Copyright:: 2020, Roblox, All Rights Reserved.

port = 9090
consul_name = "prometheus-pod-telemetry"

tag_list = ['prometheus']
infradb_available = (node.key?('infradb') and node['infradb'].key?('serverInfo') and node['infradb']['serverInfo'].key?('Server') and not node['infradb']['serverInfo']['Server'].nil?)
location_available = (infradb_available && !node['infradb']['serverInfo']['Server']['Location'].nil?)

if infradb_available && location_available
  pod = node['infradb']['serverInfo']['Server']['Location']['Pod']['Name']
  tag_list << pod
  skip_update = node['rblx_prometheus']['skip_consul']
else
  skip_update = true
end

consul_definition consul_name do
  type 'service'
  parameters(
    name: consul_name,
    port: port,
    tags: tag_list
  )
  notifies :reload, 'consul_service[consul]', :delayed
  not_if { node['rblx_prometheus']['absent_consul'] }
  not_if { skip_update }
end

consul_definition consul_name do
  type 'service'
  action :delete
  notifies :reload, 'consul_service[consul]', :delayed
  only_if { node['rblx_prometheus']['absent_consul'] }
end
