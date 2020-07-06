image_name = 'prom/prometheus:latest'
config_location = '/etc/prometheus/prometheus.yml'
mount_string = "-v #{config_location}:#{config_location}"

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

template config_location do
  source 'prometheus/prometheus.yml.erb'
  variables(scrape_list: node['rblx_prometheus']['collection']['scrape_list'])
  mode '0755'
  notifies :restart, "service[prometheus]", :delayed
end

service_name = 'prometheus'
docs = 'https://prometheus.io/docs/'

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
