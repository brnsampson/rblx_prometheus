#
# Cookbook:: rblx_prometheus
# Recipe:: config
#
# Copyright:: 2020, Roblox, All Rights Reserved.

image_name = "#{node['rblx_prometheus']['image']}:#{node['rblx_prometheus']['tag']}"
config_location = '/etc/prometheus/prometheus.yml'
rules_location = '/etc/prometheus/prometheus.rules.yml'
data_location = '/var/lib/prometheus'

scrape_override = node['rblx_prometheus']['config']['telegraf_input']['target_list_override']
alert_override = node['rblx_prometheus']['config']['alertmanager']['target_list_override']
prom_override = node['rblx_prometheus']['config']['prometheus']['target_list_override']

scrape_list = scrape_override.empty? ? node['rblx_prometheus']['config']['telegraf_input']['_target_list'] : scrape_override
alert_list = alert_override.empty? ? node['rblx_prometheus']['config']['alertmanager']['_target_list'] : alert_override
prom_list = prom_override.empty? ? node['rblx_prometheus']['config']['prometheus']['_target_list'] : prom_override

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
  notifies :restart, "service[prometheus]", :delayed
end

template config_location do
  source 'prometheus/prometheus.yml.erb'
  variables(
    alert_list: alert_list,
    scrape_list: scrape_list,
    prom_list: prom_list
  )
  mode '0755'
  owner 'prometheus'
  group 'prometheus'
  notifies :restart, "service[prometheus]", :delayed
  not_if { node['rblx_prometheus']['config']['alertmanager']['_disable'] and alert_override.empty? }
  not_if { node['rblx_prometheus']['config']['telegraf_input']['_disable'] and scrape_override.empty? }
  not_if { node['rblx_prometheus']['config']['prometheus']['_disable'] and prom_override.empty? }
end

