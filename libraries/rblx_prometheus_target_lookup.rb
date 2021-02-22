#
# Cookbook:: rblx_prometheus
# Library:: target_lookup
#
# Copyright:: 2021, Roblox, All Rights Reserved.
#

require 'net/http'
require 'uri'
require 'json'
require 'socket'


def is_port_open?(ip, port, timeout=5)
  begin
    Socket.tcp(ip, port, connect_timeout: timeout)
    return true
  rescue
    return false
  end
end

def graphql_query(graphql, query)

  query_uri = %Q(https://#{graphql}/graphql?query=#{query})
  begin
    uri = URI.parse(query_uri)
    response = Net::HTTP.get_response(uri)
   
    res = {}
    if response.code 
      res = JSON.parse(response.body)
    else
      raise "Failed to query graphql at https://#{graphql}/graphql with query #{query}!"
    end
  end
  return res
end

module RblxPrometheus
  module TargetLookup
    def target_lookup(graphql, port, dc, pod, scrape_unresponsive=true)
      #
      # graphql: location of the graphql instance to query for server info
      #
      # port: port used for target scrape addresses
      #
      # dc: filter out targets outside of this datacenter
      #
      # pod: filter out targets outside of this pod
      #
      # scrape_unresponside: if false, attempt to connect ot each target and only return targets which are listening on <port>
      #

      addresses = {}

      query = %Q({DataCenter(Abbreviation:"#{dc}"){PodsWithDataCenter(Name:"#{pod}"){ServerLocationsWithPod{Server{HostName,PrimaryIPAddress}}}}})
      query_uri = %Q(https://#{graphql}/graphql?query=#{query})

      res = graphql_query(graphql, query)
      
      unless res.empty?
        addrs = []
        pod = res.dig('data', 'DataCenter', 'PodsWithDatacenter')
        server_list = pod ? pod[0]['ServerLocationsWithPod'] : []
     
        server_list.each do |server|
          addr = server['Server']['PrimaryIPAddress']
          if scrape_unresponsive || is_port_open?(addr, port)
            addrs << "#{addr}:#{port}"
          end
        end
        # This might seem unecessary, but it allows us to return the same structure here and in the pops
        addresses[dc] = addrs
      end

      return addresses
    end

    def target_lookup_pop(graphql, port, dc, scrape_unresponsive=true)
      #
      # graphql: location of the graphql instance to query for server info
      #
      # port: port used for target scrape addresses
      #
      # dc: filter out targets outside of this datacenter
      #
      # pod: filter out targets outside of this pod
      #
      # scrape_unresponside: if false, attempt to connect ot each target and only return targets which are listening on <port>
      #

# Example query:
# {
#   DataCenters(Abbreviation: "iad4")
#   {
#     Name
#     ServersWithDataCenter {
#       HostName
#       PrivateIPAddress
#     }
#   }
# }
#
#NOTE: we no longer have to worry about this because all pop DCs have the same abbreviation # get child DCs from parent DC
# {
#   DataCenters(ParentDataCenterID: 299)
#   {
#     ID
#     Name
#     ServersWithDataCenter {
#       HostName
#       PrivateIPAddress
#     }
#   }
# }



      addresses = {}

      query = %Q({ DataCenters(Abbreviation: "#{dc}") {Name ServersWithDataCenter { HostName PrivateIPAddress } } })
      query_uri = %Q(https://#{graphql}/graphql?query=#{query})

      res = graphql_query(graphql, query_uri)
      
      unless res.empty?
        datacenters = res.dig('data', 'DataCenters')
	datacenters = datacenters ? datacenters : []

        name = ''
        dc_addrs = []
        datacenters.each do |dc|
          name = dc['Name']
          server_list = dc['ServersWithDataCenter']
	  server_list = server_list ? server_list : []

          server_list.each do |server|
            # We use private instead of primary because we don't want to use a public IP
            addr = server['PrivateIPAddress']
            if scrape_unresponsive || is_port_open?(addr, port)
              dc_addrs << "#{addr}:#{port}"
            end
          end
        end
        addresses[name] = dc_addrs
      end
      
      return addresses
    end
  end
end
