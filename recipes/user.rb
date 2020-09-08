#
# Cookbook:: rblx_prometheus
# Recipe:: user
#
# Copyright:: 2020, Roblox, All Rights Reserved.

user = node['rblx_prometheus']['config']['uid'] || "34090"

group 'prometheus' do
  action :create
  not_if { user.empty? }
end

user 'prometheus' do
  uid user
  gid 'prometheus'
  not_if { user.empty? }
end
