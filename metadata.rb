name 'rblx_prometheus'
maintainer 'Brian Sampson'
maintainer_email 'bsampson@roblox.com'
license 'All Rights Reserved'
description 'Installs/Configures rblx_prometheus'
version '0.1.2'
chef_version '>= 14.0'
issues_url 'https://github.com/Roblox/rblx_prometheus/issues'
source_url 'https://github.com/Roblox/rblx_prometheus'

supports 'centos', '>= 7'
supports 'ubuntu', '>= 16.04'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/rblx_prometheus/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/rblx_prometheus'

depends 'docker'
