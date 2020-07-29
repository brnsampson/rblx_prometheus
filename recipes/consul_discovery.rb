#
# Cookbook:: rblx_prometheus
# Recipe:: consul_discovery
#
# Copyright:: 2020, Roblox, All Rights Reserved.

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
      addr = "#{instance['ServiceAddress']}:#{instance['ServicePort']}"
      addresses << addr
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