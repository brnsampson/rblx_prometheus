#
# Cookbook:: rblx_prometheus
# Recipe:: install
#
# Copyright:: 2020, Roblox, All Rights Reserved.

image_name = 'prom/prometheus:latest'
config_location = '/etc/prometheus/prometheus.yml'
rules_location = '/etc/prometheus/prometheus.rules.yml'
mount_string = "-v #{config_location}:#{config_location} -v #{rules_location}:#{rules_location}"

scrape_override = node['rblx_prometheus']['config']['telegraf_input']['target_list_override']
alert_override = node['rblx_prometheus']['config']['alertmanager']['target_list_override']
prom_override = node['rblx_prometheus']['config']['prometheus']['target_list_override']

scrape_list = scrape_override.empty? ? node['rblx_prometheus']['config']['telegraf_input']['_target_list'] : scrape_override
alert_list = alert_override.empty? ? node['rblx_prometheus']['config']['alertmanager']['_target_list'] : alert_override
prom_list = prom_override.empty? ? node['rblx_prometheus']['config']['prometheus']['_target_list'] : prom_override

service_name = 'prometheus'
docs = 'https://prometheus.io/docs/'

docker_service 'default' do
  action [:create, :start]
end

docker_image 'prometheus' do
  repo 'prom/prometheus'
  tag 'latest'
  action :pull
end

directory '/etc/prometheus' do
  mode '0755'
  action :create
end

template rules_location do
  source 'prometheus/prometheus.rules.yml.erb'
  mode '0755'
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
  notifies :restart, "service[prometheus]", :delayed
  not_if { node['rblx_prometheus']['config']['alertmanager']['_disable'] and alert_override.empty? }
  not_if { node['rblx_prometheus']['config']['telegraf_input']['_disable'] and scrape_override.empty? }
  not_if { node['rblx_prometheus']['config']['prometheus']['_disable'] and prom_override.empty? }
end

systemd_unit 'prometheus.service' do
  content({
	  Unit: {
		  Description: "#{service_name} service",
		  Documentation: [docs],
		  After: 'docker.service',
		  Requires: 'docker.socket',
	  },
	  Service: {
		  Type: 'simple',
		  ExecStartPre: "-/bin/bash -c '/usr/bin/docker kill $(docker ps -q -f name=%p) || true'",
		  ExecStartPre: "-/bin/bash -c '/usr/bin/docker rm $(docker ps -a -q -f name=%p) || true'",
		  ExecStart: %Q(/usr/bin/docker run --log-driver=journald --net=host #{mount_string} --name %p #{image_name}),
                  ExecStop: '/usr/bin/docker stop %p',
		  Restart: 'on-failure',
		  RestartSec: '30s',
	  },
	  Install: {
		  WantedBy: 'multi-user.target',
	  }
  })
  action [:create, :enable, :start]
  notifies :restart, 'service[prometheus]', :delayed
  not_if { node['rblx_prometheus']['absent'] }
end

systemd_unit 'prometheus.service' do
  action [:disable, :stop]
  only_if { node['rblx_prometheus']['absent'] }
end

service "prometheus" do
  supports :restart => true, :status => true
  restart_command "systemctl restart prometheus"
  action [ :enable, :start ]
end
