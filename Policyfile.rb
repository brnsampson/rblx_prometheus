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
cookbook 'docker', '~> 6.0.3', :supermarket
