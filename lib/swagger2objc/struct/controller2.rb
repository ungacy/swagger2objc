require 'swagger2objc/struct/request'
require 'swagger2objc/struct/model'
module Swagger2objc
  module Struct
    class Controller2 < Base
      attr_reader :apis
      attr_reader :definitions
      attr_reader :info
      attr_reader :models
      attr_reader :paths
      attr_reader :swagger
      attr_reader :category
      attr_reader :resourcePath

      def setup
        @resourcePath = ''
        @category = 'Message'
        @apis = []
        models = []
        paths.each do |path, request_hash|
          request = Request.new({ method_hash: request_hash }, path)
          @apis << request
        end
      end

      def result
        paths.each do |item|
          puts item
        end
      end
    end
  end
end
