#
# Cookbook:: rblx_prometheus
# Recipe:: testing
#
# Copyright:: 2020, Roblox, All Rights Reserved.

node.override['rblx_prometheus']['config']['pod'] = 'fake-pod'
node.override['rblx_prometheus']['config']['datacenter'] = 'fake-datacenter'

include_recipe 'rblx_prometheus::install'
include_recipe 'rblx_prometheus::consul_service'
