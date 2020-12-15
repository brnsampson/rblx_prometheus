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

scrape_override = node['rblx_prometheus']['config']['telegraf_input']['target_list_override']
alert_override = node['rblx_prometheus']['config']['alertmanager']['target_list_override']
prom_override = node['rblx_prometheus']['config']['prometheus']['target_list_override']
remote_write_override = node['rblx_prometheus']['config']['remote_write']['target_list_override']


infradb_available = (node.key?('infradb') and node['infradb'].key?('serverInfo') and node['infradb']['serverInfo'].key?('Server') and not node['infradb']['serverInfo']['Server'].nil?)
location_available = (infradb_available && !node['infradb']['serverInfo']['Server']['Location'].nil?)

pod = node['rblx_prometheus']['config']['pod']
if pod.nil?
  raise "#{recipe_name}: pod unspecified by attributes and graphql unavailable" unless location_available
  pod = node['infradb']['serverInfo']['Server']['Location']['Pod']['Name'].downcase()
end

dc = node['rblx_prometheus']['config']['datacenter']
if dc.nil?
  raise "#{recipe_name}: datacenter unspecified by attributes and graphql unavailable" unless location_available
  dc = node['infradb']['serverInfo']['Server']['Location']['DataCenter']['Abbreviation'].downcase()
end

req_tags = [pod, dc]

alert_list = []
prom_list = []
remote_list = []
begin
  alert_list = consul_addrs_lookup(config['consul_addr'], config['alertmanager']['consul_service'], req_tags)
  prom_list = consul_addrs_lookup(config['consul_addr'], config['prometheus']['consul_service'], req_tags)
  remote_write_list = consul_addrs_lookup(config['consul_addr'], config['remote_write']['consul_service'], req_tags)
rescue => e
  alert_list = alert_list || []
  prom_list = prom_list || []
  remote_write_list = remote_write_list || []
  Chef::Log.error(e)
  puts e
  skip_configure = true
end

scrape_list = scrape_override.empty? ? node['rblx_prometheus']['config']['telegraf_input']['_target_list'] : scrape_override
alert_list = alert_override.empty? ? alert_list : alert_override
prom_list = prom_override.empty? ? prom_list : prom_override
remote_write_list = remote_write_override.empty? ? remote_write_list : remote_write_override

log 'debug scrape_list' do
  message "Final scrape_list is #{scrape_list}"
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

directory config_location do
  action :delete
  only_if { ::Dir.exist?(config_location) }
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
  message "value of  target_list disable immediately before writing config is #{node['rblx_prometheus']['config']['telegraf_input']['_disable']}"
  level :debug
end

template config_location do
  source 'prometheus/prometheus.yml.erb'
  variables(
    alert_list: alert_list,
    scrape_list: scrape_list,
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
  not_if { node['rblx_prometheus']['config']['telegraf_input']['_disable'] && scrape_override.empty? }
end
