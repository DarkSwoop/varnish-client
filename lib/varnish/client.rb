require 'net/http'

module Varnish
  class Client
    def initialize(host, port, target, options={})
      @http   = Net::HTTP.new(host, port)
      @target = URI.parse(target.to_s)
      @auth_header = options.delete(:auth_header)
    end

    def purge(cmd)
      req = Purge.new(cmd)
      req['Host'] = host_with_port(@target)
      req[@auth_header] = 'true' if @auth_header
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

