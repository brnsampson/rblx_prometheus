#
# Cookbook:: rblx_prometheus
# Recipe:: install
#
# Copyright:: 2020, Roblox, All Rights Reserved.

config = node['rblx_prometheus']['config']

command_args = config['_command_args']

image_name = "#{node['rblx_prometheus']['image']}:#{node['rblx_prometheus']['tag']}"
config_location = '/etc/prometheus/prometheus.yml'
rules_location = '/etc/prometheus/prometheus.rules.yml'
data_location = '/var/lib/prometheus'
mounts = "-v #{config_location}:#{config_location} -v #{rules_location}:#{rules_location} -v #{data_location}:/prometheus"
label = config['docker_label']
labels = "--label #{label}"

#cleanup_command = "/usr/bin/docker kill $(docker ps -q -f name=%p) || true; /usr/bin/docker rm $(docker ps -a -q -f name=%p) || true; /usr/bin/docker volume prune --filter label=#{config['docker_label']} || true"
cleanup_command = "/usr/bin/docker kill $(docker ps -q -f name=%p) || true; /usr/bin/docker container prune -f --filter label=#{label} || true; /usr/bin/docker volume prune -f --filter label=#{label} || true"

service_name = 'prometheus'
docs = 'https://prometheus.io/docs/'

user = config['uid'] || "34090"
uid_override_string = user.empty? ? "" : "--user #{user}:#{user}"

docker_image 'prometheus' do
  repo 'prom/prometheus'
  tag 'latest'
  action :pull
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
		  ExecStartPre: "-/bin/bash -c '#{cleanup_command}'",
		  ExecStart: %Q(/usr/bin/docker run --log-driver=journald --net=host #{mounts} #{labels} #{uid_override_string} --name %p #{image_name} #{command_args}),
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
