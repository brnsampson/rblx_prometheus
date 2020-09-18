#
# Cookbook:: rblx_prometheus
# Recipe:: alertmanager_discovery
#
# Copyright:: 2020, Roblox, All Rights Reserved.

##### copy-paste blob to get pod and dc
infradb_available = (node.key?('infradb') and node['infradb'].key?('serverInfo') and node['infradb']['serverInfo'].key?('Server') and not node['infradb']['serverInfo']['Server'].nil?)
location_available = (infradb_available && !node['infradb']['serverInfo']['Server']['Location'].nil?)

pod = node['rblx_prometheus']['config']['pod']
if pod.nil?
  raise 'target_discovery: pod unspecified by attributes and graphql unavailable' unless location_available
  pod = node['infradb']['serverInfo']['Server']['Location']['Pod']['Name'].downcase()
end

dc = node['rblx_prometheus']['config']['datacenter']
if dc.nil?
  raise 'target_discovery: datacenter unspecified by attributes and graphql unavailable' unless location_available
  dc = node['infradb']['serverInfo']['Server']['Location']['DataCenter']['Abbreviation'].downcase()
end
##### end of copy-paste blob

if node['rblx_prometheus']['config']['alertmanager']['enable'] == true
  require 'net/http'
  require 'uri'
  require 'json'

  addresses = []
  alertmanager_service = node['rblx_prometheus']['config']['alertmanager']['consul_service']
  begin
    uri = URI.parse("http://127.0.0.1:8500/v1/catalog/service/#{alertmanager_service}")
    response = Net::HTTP.get_response(uri)
  
    res = JSON.parse(response.body)
    res.each do |instance|
      if instance['ServiceTags'].include?(dc) && instance['ServiceTags'].include?(pod)
        addr = "#{instance['Address']}:#{instance['ServicePort']}"
        addresses << addr
      end
    end if response.code
   
    if addresses.empty?
      node.override['rblx_prometheus']['config']['alertmanager']['_disable'] = true
      node.override['rblx_prometheus']['config']['alertmanager']['_target_list'] = ['EMPTY']
    else
      node.override['rblx_prometheus']['config']['alertmanager']['_target_list'] = addresses
    end 
  rescue
    # We had some error looking up the consul service
    node.override['rblx_prometheus']['config']['alertmanager']['_disable'] = true
    node.override['rblx_prometheus']['config']['alertmanager']['_target_list'] = ['ERROR']
  end
end
