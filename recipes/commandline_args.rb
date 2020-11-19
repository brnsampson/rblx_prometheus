#
# Cookbook:: rblx_prometheus
# Recipe:: commandline_args
#
# Copyright:: 2020, Roblox, All Rights Reserved.
#

config = node['rblx_prometheus']['config']
args = []

args << "--storage.tsdb.retention.time #{config['retention_time']}"
args << "--config.file /etc/prometheus/prometheus.yml"

node.default['rblx_prometheus']['config']['_command_args'] = args.join(' ')
