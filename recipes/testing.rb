#
# Cookbook:: rblx_prometheus
# Recipe:: testing
#
# Copyright:: 2020, Roblox, All Rights Reserved.

node.override['rblx_prometheus']['config']['telegraf_input']['target_list_override'] = ['fake-target-1', 'fake-target-2']
node.override['rblx_prometheus']['config']['alertmanager']['target_list_override'] = ['fake-alertmanager-1', 'fake-alertmanager-2']
node.override['rblx_prometheus']['config']['prometheus']['target_list_override'] = ['fake-prom-1', 'fake-prom-2']

node.override['rblx_prometheus']['config']['pod'] = 'fake-pod'
node.override['rblx_prometheus']['config']['datacenter'] = 'fake-datacenter'

include_recipe 'rblx_prometheus::install'
include_recipe 'rblx_prometheus::consul_service'
