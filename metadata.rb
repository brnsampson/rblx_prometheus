name 'rblx_prometheus'
maintainer 'Brian Sampson'
maintainer_email 'bsampson@roblox.com'
license 'All Rights Reserved'
description 'Installs/Configures rblx_prometheus'
version '0.1.10'
chef_version '>= 13.0'

supports 'centos', '>= 7'
supports 'ubuntu', '>= 18.04'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.

issues_url 'https://github.com/Roblox/rblx_prometheus/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.

source_url 'https://github.com/Roblox/rblx_prometheus'

depends 'docker'
