#
# Cookbook:: rblx_prometheus
# Recipe:: target_discovery
#
# Copyright:: 2020, Roblox, All Rights Reserved.

def is_port_open?(ip, port, timeout=5)
  begin
    Socket.tcp(ip, port, connect_timeout: timeout)
    return true
  rescue
    return false
  end
end

infradb_available = (node.key?('infradb') and node['infradb'].key?('serverInfo') and node['infradb']['serverInfo'].key?('Server') and not node['infradb']['serverInfo']['Server'].nil?)
location_available = (infradb_available && !node['infradb']['serverInfo']['Server']['Location'].nil?)

if infradb_available && location_available
  dc = node['infradb']['serverInfo']['Server']['Location']['DataCenter']['Abbreviation']
  pod = node['infradb']['serverInfo']['Server']['Location']['Pod']['Name']
end

if node['rblx_prometheus']['config']['telegraf_input']['enable'] and dc and pod
  require 'net/http'
  require 'uri'
  require 'json'
  require 'socket'

  addresses = []
  port = node['rblx_prometheus']['config']['telegraf_input']['port']
  graphql = node['rblx_prometheus']['config']['telegraf_input']['graphql']
  begin
    uri = URI.parse(%Q(https://#{graphql}/graphql?query={DataCenter(Abbreviation:"#{dc}"){PodsWithDataCenter(Name:"#{pod}"){ServerLocationsWithPod{Server{HostName,PrimaryIPAddress}}}}}))
    response = Net::HTTP.get_response(uri)
    
    res = JSON.parse(response.body)
    servers_available = (res.key?('data') and res['data'].key?('DataCenter') and res['data']['DataCenter'].key?('PodsWithDataCenter') and
                         not res['data']['DataCenter']['PodsWithDataCenter'].nil? and res['data']['DataCenter']['PodsWithDataCenter'][0].key?('ServerLocationsWithPod'))
    server_list = res['data']['DataCenter']['PodsWithDataCenter'][0]['ServerLocationsWithPod']

    server_list.each do |server|
      addr = server['Server']['PrimaryIPAddress']
      if is_port_open?(addr, port)
        addresses << "#{addr}:#{port}"
      end
    end if response.code and servers_available

    if addresses.empty?
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
