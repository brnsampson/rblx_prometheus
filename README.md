# rblx_prometheus

# Description

Installs/Configures prometheus running in docker

# Requirements

## Platform

* centos 7
* ubuntu 18.04

## Cookbooks

* docker
* ssl_certificate
* rblx_docker
* consul-cluster
* consul

## Recipes

* rblx_prometheus::default
* rblx_prometheus::install
* rblx_prometheus::consul_service
