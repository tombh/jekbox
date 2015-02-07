require 'net/http'
require 'enumerator'
require_relative 'jekbox.rb'

# Very simple reverse proxy
class Proxy
  def call(env)
    req = Rack::Request.new(env)

    # Determine the HTTP method being
    method = req.request_method.downcase
    method[0..0] = method[0..0].upcase

    # Where we're forwarding to
    uri = Jekbox.find_destination(req)
    return [200, {}, ['No site found at this address']] unless uri

    # Prepare the proxied request
    query = "#{'?' if uri.query}#{uri.query}"
    sub_request = Net::HTTP.const_get(method).new("#{uri.path}#{query}")

    if sub_request.request_body_permitted? && req.body
      sub_request.body_stream = req.body
      sub_request.content_length = req.content_length
      sub_request.content_type = req.content_type
    end

    forwarding_addresses = (
      req.env['X-Forwarded-For'].to_s.split(/, +/) + [req.env['REMOTE_ADDR']]
    ).join(', ')
    sub_request['X-Forwarded-For'] = forwarding_addresses
    sub_request['Accept-Encoding'] = req.accept_encoding
    sub_request['Referer'] = req.referer

    # Get the response from the proxied request
    begin
      sub_response = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(sub_request)
      end
    rescue EOFError
      return [
        500,
        {},
        ["The site #{uri.host} does not seem to be up"]
      ]
    end

    # Return the proxied request
    headers = {}
    sub_response.each_header do |k, v|
      headers[k] = v unless k.to_s =~ /cookie|content-length|transfer-encoding/i
    end

    [sub_response.code.to_i, headers, [sub_response.read_body]]
  end
end
