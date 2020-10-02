# rblx_prometheus CHANGELOG

This file is used to list changes made in each version of the rblx_prometheus cookbook.

## 0.1.11
- Do not skip creating the config file if the alertmanager or prometheus discovery list are empty
- This is not necessarily incorrect and will be watched by monitoring ideally.

## 0.1.10
- Do not trust node['graphql'] to have useful data anymore
- Include dc in consul service tags
- Filter target/prom/alertmanager discovery on dc and pod
- Add logic to each discovery recipe to perfer attributes and fallback to graphql. If graphql attrs are empty, then raise error

## 0.1.9
- Rework cleanup command to make sure we cleanup old containers
- Label docker containers for easier purge/deletion
- Separate out user and configuration stuff for readability
- Create user/group and pass that UID to the container
- Mount data directory inside container for persistence. Defaults to /var/lib/prometheus/

## 0.1.8
- Configured new alerts for each system component

## 0.1.7
- Fixup target discovery bugs

## 0.1.6
- Graphql fix and consul_discovery tweak

## 0.1.5
- Added target discovery using graphql to query infradb
- Added consul service discovery of alertmanagers
- Circleci test fix
- More linting

## 0.1.4
- Created recipe to add prometheus-pod-telemetry consul service
- Code cleanup

## 0.1.3
- Updated prometheus.yml to monitor itself with corresponding tests
- Fixed kitchen versioning issues
- Modernized chef config stuff

## 0.1.2
- Added test databag for consul-cluster
- Fixed up some testing bugs that might have been caused by chef doing caching yesterday

## 0.1.1

- Added systemd unit file for prometheus docker service
- delint
- other stuff

## 0.1.0

Initial release.

- change 0
- change 1
