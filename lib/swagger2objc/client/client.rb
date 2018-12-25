require 'open-uri'
require 'json'
require 'swagger2objc/config'

module Swagger2objc
  class Client
    @base_uri

    def initialize(base_uri)
      @base_uri = base_uri
    end

    def object_from_uri(path = nil)
      uri = @base_uri
      uri = @base_uri + path if path
      html_response = nil
      label = Configure.config['label']
      label = '' if label.nil?
      open(uri,
           'X-label' => 'label') do |http|
        html_response = http.read
      end
      JSON.parse(html_response)
    end
  end
end
