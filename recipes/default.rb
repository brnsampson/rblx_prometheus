#
# Cookbook:: rblx_prometheus
# Recipe:: default
#
# Copyright:: 2020, Roblox, All Rights Reserved.

infradb_available = (node.key?('infradb') and node['infradb'].key?('serverInfo') and node['infradb']['serverInfo'].key?('Server') and not node['infradb']['serverInfo']['Server'].nil?)
location_available = (infradb_available && !node['infradb']['serverInfo']['Server']['Location'].nil?)

if infradb_available && location_available
  node.override['rblx_prometheus']['config']['datacenter'] = node['infradb']['serverInfo']['Server']['Location']['DataCenter']['Name']
  node.override['rblx_prometheus']['config']['pod'] = node['infradb']['serverInfo']['Server']['Location']['Pod']['Name']
end

include_recipe 'rblx_prometheus::consul_discovery'
include_recipe 'rblx_prometheus::target_discovery'
include_recipe 'rblx_prometheus::install'
include_recipe 'rblx_prometheus::consul_service'
