#
# Cookbook:: rblx_prometheus
# Recipe:: default
#
# Copyright:: 2020, Roblox, All Rights Reserved.

include_recipe 'rblx_prometheus::consul_discovery'
include_recipe 'rblx_prometheus::target_discovery'
include_recipe 'rblx_prometheus::install'
include_recipe 'rblx_prometheus::consul_service'
