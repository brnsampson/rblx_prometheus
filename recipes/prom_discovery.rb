#
# Cookbook:: rblx_prometheus
# Recipe:: prom_discovery
#
# Copyright:: 2020, Roblox, All Rights Reserved.

##### copy-paste blob to get pod and dc
infradb_available = (node.key?('infradb') and node['infradb'].key?('serverInfo') and node['infradb']['serverInfo'].key?('Server') and not node['infradb']['serverInfo']['Server'].nil?)
location_available = (infradb_available && !node['infradb']['serverInfo']['Server']['Location'].nil?)

pod = node['rblx_prometheus']['config']['pod']
if pod.nil?
  raise 'prom_discovery: pod unspecified by attributes and graphql unavailable' unless location_available
  pod = node['infradb']['serverInfo']['Server']['Location']['Pod']['Name'].downcase()
end

dc = node['rblx_prometheus']['config']['datacenter']
if dc.nil?
  raise 'prom_discovery: datacenter unspecified by attributes and graphql unavailable' unless location_available
  dc = node['infradb']['serverInfo']['Server']['Location']['DataCenter']['Abbreviation'].downcase()
end
##### end of copy-paste blob

if node['rblx_prometheus']['config']['prometheus']['enable'] == true
  require 'net/http'
  require 'uri'
  require 'json'

  addresses = []
  prometheus_service = node['rblx_prometheus']['config']['prometheus']['consul_service']
  begin
    uri = URI.parse("http://127.0.0.1:8500/v1/catalog/service/#{prometheus_service}")
    response = Net::HTTP.get_response(uri)
  
    res = JSON.parse(response.body)
    res.each do |instance|
      if instance['ServiceTags'].include?(dc) && instance['ServiceTags'].include?(pod)
        addr = "#{instance['Address']}:#{instance['ServicePort']}"
        addresses << addr
      end
    end if response.code
   
    if addresses.empty?
      # Don't abort config changes if no prom consul services are up. That's okay, we will just send an alert.
      # node.override['rblx_prometheus']['config']['prometheus']['_disable'] = true
      node.override['rblx_prometheus']['config']['prometheus']['_target_list'] = []
    else
      node.override['rblx_prometheus']['config']['prometheus']['_target_list'] = addresses
    end 
  rescue
    # We had some error looking up the consul service
    node.override['rblx_prometheus']['config']['prometheus']['_disable'] = true
    node.override['rblx_prometheus']['config']['prometheus']['_target_list'] = ['ERROR']
  end
end
