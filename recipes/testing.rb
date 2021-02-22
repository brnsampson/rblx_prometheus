#
# Cookbook:: rblx_prometheus
# Recipe:: testing
#
# Copyright:: 2020, Roblox, All Rights Reserved.

node.override['rblx_prometheus']['config']['scrape_input']['target_list_override'] = ['fake-target-1', 'fake-target-2']
node.override['rblx_prometheus']['config']['alertmanager']['target_list_override'] = ['fake-alertmanager-1', 'fake-alertmanager-2']
#node.override['rblx_prometheus']['config']['prometheus']['target_list_override'] = ['fake-prom-1', 'fake-prom-2']
#node.override['rblx_prometheus']['config']['remote_write']['target_list_override'] = ['fake-rw-1']

node.override['rblx_prometheus']['config']['pod'] = 'fake-pod'
node.override['rblx_prometheus']['config']['datacenter'] = 'fake-datacenter'

consul_definition 'alertmanager' do
  type 'service'
  parameters(
    name: 'alertmanager-pod-telemetry',
    port: 1234,
    tags: ['fake-pod', 'fake-datacenter']
  )
  notifies :reload, 'consul_service[consul]', :delayed
end

consul_definition 'prometheus' do
  type 'service'
  parameters(
    name: 'prometheus-pod-telemetry',
    port: 9090,
    tags: ['fake-pod', 'fake-datacenter']
  )
  notifies :reload, 'consul_service[consul]', :delayed
end

consul_definition 'remote-write' do
  type 'service'
  parameters(
    name: 'prom-write-adapters-pod-telemetry',
    port: 1236,
    tags: ['fake-pod', 'fake-datacenter']
  )
  notifies :reload, 'consul_service[consul]', :delayed
end

include_recipe 'rblx_prometheus::default'
