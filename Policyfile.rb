# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/

# A name that describes what the system you're building with Chef does.
name 'rblx_prometheus'

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list ['consul-cluster', 'rblx_docker::default', 'rblx_prometheus::default']


# Specify a custom source for a single cookbook:
cookbook 'rblx_prometheus', path: '.'
cookbook 'docker', '4.9', :supermarket
cookbook 'ssl_certificate', '~> 2.1', :supermarket
cookbook 'rblx_docker', '~> 0.1', git: 'https://github.com/Roblox/orchestration-chef', rel: 'cookbooks/rblx_docker/'
cookbook 'consul-cluster', '9002.2.2', git: 'https://github.com/Roblox/consul-cluster-cookbook', tag: 'v9002.2.2'
cookbook 'consul', '9003.1.10', git: 'https://github.com/Roblox/consul-cookbook', tag: 'v9003.1.10'
