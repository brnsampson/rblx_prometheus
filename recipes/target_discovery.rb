#
# Cookbook:: rblx_prometheus
# Recipe:: target_discovery
#
# Copyright:: 2020, Roblox, All Rights Reserved.

config = node['rblx_prometheus']['config']

def is_port_open?(ip, port, timeout=5)
  begin
    Socket.tcp(ip, port, connect_timeout: timeout)
    return true
  rescue
    return false
  end
end

##### copy-paste blob to get pod and dc
infradb_available = (node.key?('infradb') and node['infradb'].key?('serverInfo') and node['infradb']['serverInfo'].key?('Server') and not node['infradb']['serverInfo']['Server'].nil?)
location_available = (infradb_available && !node['infradb']['serverInfo']['Server']['Location'].nil?)

pod = config['pod']
if pod.nil?
  raise 'target_discovery: pod unspecified by attributes and graphql unavailable' unless location_available
  pod = node['infradb']['serverInfo']['Server']['Location']['Pod']['Name'].downcase()
end

dc = config['datacenter']
if dc.nil?
  raise 'target_discovery: datacenter unspecified by attributes and graphql unavailable' unless location_available
  dc = node['infradb']['serverInfo']['Server']['Location']['DataCenter']['Abbreviation'].downcase()
end
##### end of copy-paste blob

if config['telegraf_input']['enable'] and dc and pod
  require 'net/http'
  require 'uri'
  require 'json'
  require 'socket'

  addresses = []
  port = config['telegraf_input']['port']
  graphql = config['telegraf_input']['graphql']
  begin
    uri = URI.parse(%Q(https://#{graphql}/graphql?query={DataCenter(Abbreviation:"#{dc}"){PodsWithDataCenter(Name:"#{pod}"){ServerLocationsWithPod{Server{HostName,PrimaryIPAddress}}}}}))
    response = Net::HTTP.get_response(uri)
    
    res = JSON.parse(response.body)
    servers_available = (res.key?('data') and res['data'].key?('DataCenter') and res['data']['DataCenter'].key?('PodsWithDataCenter') and
                         not res['data']['DataCenter']['PodsWithDataCenter'].nil? and res['data']['DataCenter']['PodsWithDataCenter'][0].key?('ServerLocationsWithPod'))
    server_list = res['data']['DataCenter']['PodsWithDataCenter'][0]['ServerLocationsWithPod']

    server_list.each do |server|
      addr = server['Server']['PrimaryIPAddress']
      if config['scrape_unresponsive'] || is_port_open?(addr, port)
        addresses << "#{addr}:#{port}"
      end
    end if response.code and servers_available

    if addresses.empty?
      # This should pretty much never be empty. If it is, we probably have an error happening somewhere.
      node.override['rblx_prometheus']['config']['telegraf_input']['_disable'] = true
      node.override['rblx_prometheus']['config']['telegraf_input']['_target_list'] = ['EMPTY']
    else
      node.override['rblx_prometheus']['config']['telegraf_input']['_target_list'] = addresses
    end 
  rescue
    # We had some error querying infraDB
    node.override['rblx_prometheus']['config']['telegraf_input']['_disable'] = true
    node.override['rblx_prometheus']['config']['telegraf_input']['_target_list'] = ['ERROR']
  end
end
