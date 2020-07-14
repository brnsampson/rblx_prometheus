#
# Cookbook:: rblx_prometheus
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

include_recipe 'rblx_prometheus::consul_discovery'
include_recipe 'rblx_prometheus::install'
include_recipe 'rblx_prometheus::consul_service'
