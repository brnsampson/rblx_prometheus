#
# Cookbook:: rblx_prometheus
# Recipe:: consul_service
#
# Copyright:: 2020, Roblox, All Rights Reserved.

port = 9090
consul_name = node['rblx_prometheus']['config']['prometheus']['consul_service']

##### copy-paste blob to get pod and dc
infradb_available = (node.key?('infradb') and node['infradb'].key?('serverInfo') and node['infradb']['serverInfo'].key?('Server') and not node['infradb']['serverInfo']['Server'].nil?)
location_available = (infradb_available && !node['infradb']['serverInfo']['Server']['Location'].nil?)

pod = node['rblx_prometheus']['config']['pod']
if pod.nil?
  raise 'consul_service: pod unspecified by attributes and graphql unavailable' unless location_available
  pod = node['infradb']['serverInfo']['Server']['Location']['Pod']['Name'].downcase()
end

dc = node['rblx_prometheus']['config']['datacenter']
if dc.nil?
  raise 'consul_service: datacenter unspecified by attributes and graphql unavailable' unless location_available
  dc = node['infradb']['serverInfo']['Server']['Location']['DataCenter']['Abbreviation'].downcase()
end
##### end of copy-paste blob

tag_list = ['prometheus', dc, pod]
skip_update = node['rblx_prometheus']['skip_consul']

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
