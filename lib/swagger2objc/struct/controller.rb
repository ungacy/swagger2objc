require 'swagger2objc/struct/request'
require 'swagger2objc/struct/model'
module Swagger2objc
  module Struct
    class Controller < Base
      attr_accessor :apis
      attr_accessor :apiVersion
      attr_accessor :basePath
      attr_accessor :consumes
      attr_accessor :models
      attr_accessor :category

      def setup
        @apis = []
        @models = []
      end

      def result
        apis.each do |item|
          puts item.result
        end
      end
    end
  end
end
