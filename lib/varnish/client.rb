require 'net/http'

module Varnish
  class Client
    def initialize(host, port, target, options={})
      @http   = Net::HTTP.new(host, port)
      @target = URI.parse(target.to_s)
      @auth_header = options.delete(:auth_header)
    end

    # possible options:
    #   - scope:
    #     - all: expires over all hosts
    #     - single: expires for a single host
    #   - host: hostname like www.example.com
    def purge(cmd, options={})
      options.symbolize_keys!
      req = Purge.new(cmd)
      req['Host'] = if options[:host]
        host_with_port(URI.parse(options[:host].to_s))
      else
        host_with_port(@target)
      end
      req[@auth_header] = (options[:scope] || 'single') if @auth_header
      res = @http.request(req)
      res.code == '200'
    end

    def fetch(path, headers = {})
      req = Net::HTTP::Get.new(path, headers)
      req['Host'] = @target.host
      res = @http.request(req)
      return nil unless res.code == '200'
      res.body
    end

    private

    class Purge < Net::HTTPRequest
      METHOD            = 'PURGE'
      REQUEST_HAS_BODY  = false
      RESPONSE_HAS_BODY = true
    end
    
    def host_with_port(uri)
      address = uri.host
      address += ":#{uri.port}" if uri.port && uri.port != 80
      address
    end
  end
end

