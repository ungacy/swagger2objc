require 'swagger2objc/struct/model'
module Swagger2objc
  module Struct
    class Controller < Base
      attr_accessor :operations
      attr_accessor :apiVersion
      attr_accessor :basePath
      attr_accessor :consumes
      attr_accessor :models
      attr_accessor :category
      attr_accessor :service

      def setup
        @operations = []
        @models = []
      end

      def result
        operations.each do |item|
          puts item.result
        end
      end
    end
  end
end
