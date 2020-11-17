#
# Cookbook:: rblx_prometheus
# Recipe:: default
#
# Copyright:: 2020, Roblox, All Rights Reserved.

#include_recipe 'rblx_prometheus::prom_discovery'
#include_recipe 'rblx_prometheus::alertmanager_discovery'
#include_recipe 'rblx_prometheus::remote_write_discovery'
include_recipe 'rblx_prometheus::target_discovery'
include_recipe 'rblx_prometheus::user'
include_recipe 'rblx_prometheus::config'
include_recipe 'rblx_prometheus::commandline_args'
include_recipe 'rblx_prometheus::install'
include_recipe 'rblx_prometheus::consul_service'
