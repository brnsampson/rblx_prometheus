#
# Cookbook:: rblx_prometheus
# Recipe:: consul_discovery
#
# Copyright:: 2020, Roblox, All Rights Reserved.

if node['rblx_prometheus']['config']['alertmanager_output']['enable'] == true
  require 'net/http'
  require 'uri'
  require 'json'

  addresses = []
  alertmanager_service = node['rblx_prometheus']['config']['alertmanager_output']['service']
  begin
    uri = URI.parse("http://127.0.0.1:8500/v1/catalog/service/#{alertmanager_service}")
    response = Net::HTTP.get_response(uri)
  
    res = JSON.parse(response.body)
    res.each do |instance|
      addr = "#{instance['ServiceAddress']}:#{instance['ServicePort']}"
      addresses << addr
    end if response.code
   
    if addresses.empty?
      node.override['rblx_prometheus']['config']['alertmanager_output']['disable'] = true
      node.override['rblx_prometheus']['config']['alertmanager_output']['alert_list'] = ['ERROR']
    else
      node.override['rblx_prometheus']['config']['alertmanager_output']['alert_list'] = addresses
    end 
  rescue
    # We had some error looking up the consul service, then disable the kafka output for this run.
    node.override['rblx_prometheus']['config']['alertmanager_output']['disable'] = true
    node.override['rblx_prometheus']['config']['alertmanager_output']['alert_list'] = ['ERROR']
  end
else
  node.override['rblx_prometheus']['config']['alertmanager_output']['disable'] = false
  node.override['rblx_prometheus']['config']['alertmanager_output']['alert_list'] = node['rblx_prometheus']['config']['alertmanager_output']['service']
end
