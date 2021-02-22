#
# Cookbook:: rblx_prometheus
# Recipe:: config
#
# Copyright:: 2020, Roblox, All Rights Reserved.

::Chef::Recipe.send(:include, RblxPrometheus::ConsulLookup)

config = node['rblx_prometheus']['config']
image_name = "#{node['rblx_prometheus']['image']}:#{node['rblx_prometheus']['tag']}"
config_location = '/etc/prometheus/prometheus.yml'
rules_location = '/etc/prometheus/prometheus.rules.yml'
data_location = '/var/lib/prometheus'
skip_configure = false

scrape_override = node['rblx_prometheus']['config']['scrape_input']['target_list_override']
alert_override = node['rblx_prometheus']['config']['alertmanager']['target_list_override']
prom_override = node['rblx_prometheus']['config']['prometheus']['target_list_override']
remote_write_override = node['rblx_prometheus']['config']['remote_write']['target_list_override']

##### copy-paste blob to get pod and dc
infradb_attr = node['infradb'].to_h
infradb_available = infradb_attr.dig('serverInfo', 'Server') ? true : false
location_available = infradb_attr.dig('serverInfo', 'Server', 'Location') ? true : false

pod = config['pod'] || infradb_attr.dig('serverInfo', 'Server', 'Location', 'Pod', 'Name')
raise 'target_discovery: pod unspecified by attributes and graphql unavailable' unless pod || config['pop_mode'] 
pod = pod.downcase() if pod

dc = config['datacenter'] || infradb_attr.dig('serverInfo', 'Server', 'Location', 'DataCenter', 'Abbreviation')
raise 'target_discovery: datacenter unspecified by attributes and graphql unavailable' if dc.nil?
dc = dc.downcase()
##### end of copy-paste blob

req_tags = [dc]
req_tags << pod if pod

alert_list = []
prom_list = []
remote_list = []
begin
  alert_list = consul_addrs_lookup(config['alertmanager']['consul_service'], req_tags, [], config['consul_addr'])
  prom_list = consul_addrs_lookup(config['prometheus']['consul_service'], req_tags, [], config['consul_addr'])
  remote_write_list = consul_addrs_lookup(config['remote_write']['consul_service'], req_tags, [], config['consul_addr'], 1)
rescue => e
  alert_list = alert_list || []
  prom_list = prom_list || []
  remote_write_list = remote_write_list || []
  Chef::Log.error(e)
  puts e
  skip_configure = true
end

if scrape_override.empty?
  scrape_hash = node['rblx_prometheus']['config']['scrape_input']['_target_hash']
else
  scrape_hash = { dc => scrape_override }
end
alert_list = alert_override.empty? ? alert_list : alert_override
prom_list = prom_override.empty? ? prom_list : prom_override
remote_write_list = remote_write_override.empty? ? remote_write_list : remote_write_override

log 'debug scrape_hash' do
  message "Final scrape_hash is #{scrape_hash}"
  level :debug
end

log 'debug alert_list' do
  message "Final alert_list is #{alert_list}"
  level :debug
end

log 'debug prom_list' do
  message "Final prom_list is #{prom_list}"
  level :debug
end

log 'debug remote_write_list' do
  message "Final remote_write_list is #{remote_write_list}"
  level :debug
end

directory '/etc/prometheus' do
  mode '0755'
  owner 'prometheus'
  group 'prometheus'
  action :create
end

directory data_location do
  mode '0755'
  owner 'prometheus'
  group 'prometheus'
  action :create
end

# If for any reason the docker container was started before the config was created, there will be folders created at these mount points.
directory rules_location do
  action :delete
  only_if { ::Dir.exist?(rules_location) }
end

# If the config file does not exist, then docker will assume it is a missing directly and create it for us, This is not good.
# Since we don't modify the template resource below if we have any errors from the consul query and consul isn't running the very first
# chef run, we should protect ourselves by removing a directory if that was created and create an empty file if it does not exist yet.
directory config_location do
  action :delete
  only_if { ::Dir.exist?(config_location) }
end

file config_location do
  action :create_if_missing
end

template rules_location do
  source 'prometheus/prometheus.rules.yml.erb'
  mode '0755'
  owner 'prometheus'
  group 'prometheus'
  notifies :reload, "service[prometheus]", :delayed
end

log 'debug skip_configure' do
  message "value of skip_configure immediately before writing config is #{skip_configure}"
  level :debug
end

log 'debug target_list disable' do
  message "value of  target_list disable immediately before writing config is #{node['rblx_prometheus']['config']['scrape_input']['_disable']}"
  level :debug
end

template config_location do
  source 'prometheus/prometheus.yml.erb'
  variables(
    alert_list: alert_list,
    scrape_hash: scrape_hash,
    prom_list: prom_list,
    remote_write_list: remote_write_list,
    rr_drop_metric_regex: config['remote_write']['drop_metric_regex'],
    pod: pod,
    dc: dc
  )
  mode '0755'
  owner 'prometheus'
  group 'prometheus'
  notifies :reload, "service[prometheus]", :delayed
  not_if { skip_configure && (alert_list.empty? || prom_list.empty? || remote_write_list.empty?) }
  not_if { node['rblx_prometheus']['config']['scrape_input']['_disable'] && scrape_override.empty? }
end
