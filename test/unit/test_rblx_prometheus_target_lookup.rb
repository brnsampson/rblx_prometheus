# test things here
require "../../libraries/rblx_prometheus_target_lookup.rb"

def is_port_open?(ip, port, timeout=5)
  return true
end

# Actual example of results for dc query
#{
#  "data": {
#    "DataCenter": {
#      "PodsWithDataCenter": [
#        {
#          "ServerLocationsWithPod": [
#            {
#              "Server": {
#                "HostName": "ASH1-DB3",
#                "PrimaryIPAddress": "10.130.65.42"
#              }
#            },
#            {
#              "Server": {
#                "HostName": "ASH1-LApp391",
#                "PrimaryIPAddress": "10.130.1.151"
#              }
#            },
#          ]
#        }
#      ]
#    }
#  }
#}
#
# Actual example of results for pop query
#
#{
#  "data": {
#    "DataCenters": [
#      {
#        "Name": "RBX-IAD4-AMDRome",
#        "ServersWithDataCenter": [
#          {
#            "HostName": "ec03a-ak06-iad4",
#            "PrivateIPAddress": "10.200.5.6"
#          },
#          {
#            "HostName": "ec03b-ak06-iad4",
#            "PrivateIPAddress": "10.200.5.7"
#          },
#    ]
#  }
#}

def graphql_query(graphql, query)
  res = {
	  "data" => {
            "DataCenter" => {
              "PodsWithDatacenter"=> [{
                "ServerLocationsWithPod"=> [
                  {"Server" => { "HostName" => "testeroo-3", "PrimaryIPAddress" => "10.10.10.10" }},
                  {"Server" => { "HostName" => "testeroo-4", "PrimaryIPAddress" => "1.1.1.1" }}
		]
              }]
            },
            "DataCenters" => [{
              "Name" => "RBX-TEST",
              "ServersWithDataCenter" => [
                {"HostName" => "tester-1", "PrivateIPAddress" => "1.2.3.4"},
                {"HostName" => "tester-2", "PrivateIPAddress" => "5.6.7.8"}
              ]
            }]
          }
        }
  return res
end


class TestClass
  include RblxPrometheus::TargetLookup
end

tester = TestClass.new

test_dc = tester.target_lookup('graphql.testing.com', '8372', 'test-dc', 'test-pod', true)
test_pop = tester.target_lookup_pop('graphql.testing.com', '8372', 'test-dc', true)

expect_dc = {"test-dc"=>["10.10.10.10:8372", "1.1.1.1:8372"]}
expect_pop = {"RBX-TEST"=>["1.2.3.4:8372", "5.6.7.8:8372"]}

if  test_dc == expect_dc
  puts "target_lookup passed: got expected result #{expect_dc}"
else
  puts "target_lookup failed:"
  puts "    expect: #{expect_dc}"
  puts "    actual: #{test_dc}"
end

if  test_pop == expect_pop
  puts "target_lookup_pop passed: got expected result #{expect_pop}"
else
  puts "target_lookup_pop failed:"
  puts "    expect: #{expect_pop}"
  puts "    actual: #{test_pop}"
end
