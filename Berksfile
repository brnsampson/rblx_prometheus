# frozen_string_literal: true
source 'https://supermarket.chef.io'

cookbook 'rblx_consul_template', '~> 0.1', git: 'https://github.com/Roblox/rblx_consul_template.git', tag: 'v0.1.2'

group :integration do
  cookbook 'rblx_docker', '~> 0.1', git: 'https://github.rbx.com/Roblox/orchestration-chef.git', rel: 'cookbooks/rblx_docker/'
  cookbook 'consul-cluster', '9002.2.2', git: 'https://github.com/Roblox/consul-cluster-cookbook', tag: 'v9002.2.2'
  cookbook 'consul', '9003.1.10', git: 'https://github.com/Roblox/consul-cookbook', tag: 'v9003.1.10'
  cookbook 'docker', '4.9'
end

metadata
