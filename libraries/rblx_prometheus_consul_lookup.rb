#
# Cookbook:: rblx_prometheus
# Library:: consul_lookup
#
# Copyright:: 2020, Roblox, All Rights Reserved.
#

module RblxPrometheus
  module ConsulLookup
    def consul_lookup(consul_addr, consul_service, req_tags=[], req_meta=[])
      require 'net/http'
      require 'uri'
      require 'json'
      
      # The following might raise an exception if consul cannot be reached. I think it's best to just buddle that up?
      filtered_services = []
      err_msg = ""
      uri = URI.parse("http://#{consul_addr}/v1/catalog/service/#{consul_service}")
      puts "Querying consul at http://#{consul_addr}/v1/catalog/service/#{consul_service}."
      response = Net::HTTP.get_response(uri)

      # We prefer to raise an exception and let the calling code handle it instead of returning a bad response.
      err_msg = "Error querying consul at http://#{consul_addr}/v1/catalog/service/#{consul_service}. Recieved response code #{response.code}"
      raise err_msg unless response.code
      
      res = JSON.parse(response.body)

      # Determin what we actually need to filter on
      filter_tags = req_tags.empty? ? false : true 
      filter_meta = req_meta.empty? ? false : true

      res.each do |instance|
	tags_match = instance['ServiceTags'].nil? ? false : (req_tags.to_a - instance['ServiceTags']).empty?
	meta_match = instance['Meta'].nil? ? false : (req_meta - instance['Meta'].keys).empty?
	meta = meta_match ? instance['Meta'] : {}

	filters_passed = true
	filters_passed = filters_passed && tags_match if filter_tags
	filters_passed = filters_passed && meta_match if filter_meta

        if filters_passed
          addr = "#{instance['Address']}:#{instance['ServicePort']}"
          filtered_services << {'addr': addr, 'meta': meta}
        end
      end
      
      return filtered_services
    end

    def consul_addrs_lookup(consul_addr, consul_service, req_tags, req_meta=[])
      res = consul_lookup(consul_addr, consul_service, req_tags, req_meta=[])
      addrs = res.map { |service| service[:addr] }
      return addrs
    end
  end
end
