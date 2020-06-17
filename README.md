# rblx_prometheus

Installs Prometheus in a docker container with a default configuration. Works on ubuntu 20.04 and centos 7.

"kitchen test" results:

  Service docker
     ✔  is expected to be installed
     ✔  is expected to be enabled
     ✔  is expected to be running
  Port 9090
     ✔  is expected to be listening
  Command: `curl -XGET -s http://localhost:9090/-/healthy`
     ✔  stdout is expected to eq "Prometheus is Healthy.\n"

Test Summary: 5 successful, 0 failures, 0 skipped
