#
# Cookbook:: rblx_prometheus
# Recipe:: target_discovery
#
# Copyright:: 2020, Roblox, All Rights Reserved.

::Chef::Recipe.send(:include, RblxPrometheus::TargetLookup)

config = node['rblx_prometheus']['config']

#### copy-paste blob to get pod and dc
infradb_attr = node['infradb'].to_h
infradb_available = infradb_attr.dig('serverInfo', 'Server') ? true : false
location_available = infradb_attr.dig('serverInfo', 'Server', 'Location') ? true : false

pod = config['pod'] || infradb_attr.dig('serverInfo', 'Server', 'Location', 'Pod', 'Name')
raise 'target_discovery: pod unspecified by attributes and graphql unavailable' unless pod || config['pop_mode'] 
pod = pod.downcase() if pod

dc = config['datacenter'] || infradb_attr.dig('serverInfo', 'Server', 'Location', 'DataCenter', 'Abbreviation')
raise 'target_discovery: datacenter unspecified by attributes and graphql unavailable' if dc.nil?
dc = dc.downcase()
#### end of copy-paste blob

if config['scrape_input']['enable'] && dc
  begin
    graphql = config['scrape_input']['graphql']
    port = config['scrape_input']['port']
    scrape_unresponsive = config['scrape_unresponsive']
    if config['pop_mode']
      addresses = target_lookup_pop(graphql, port, dc, scrape_unresponsive)
    else
      addresses = target_lookup(graphql, port, dc, pod, scrape_unresponsive)
    end

    if addresses.empty?
      # This should pretty much never be empty. If it is, we probably have an error happening somewhere.
      node.override['rblx_prometheus']['config']['scrape_input']['_disable'] = true
      node.override['rblx_prometheus']['config']['scrape_input']['_target_hash'] = {}
    else
      node.override['rblx_prometheus']['config']['scrape_input']['_target_hash'] = addresses
    end 
  rescue
    # We had some error querying infraDB
    node.override['rblx_prometheus']['config']['scrape_input']['_disable'] = true
    node.override['rblx_prometheus']['config']['scrape_input']['_target_hash'] = {}
  end
end
