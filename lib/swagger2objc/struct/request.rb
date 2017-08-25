require 'swagger2objc/struct/operation'

module Swagger2objc
  module Struct
    class Request < Base
      attr_reader :description
      attr_reader :operations
      attr_reader :operation
      attr_reader :path

      def setup
        @operation = Operation.new(operations.first)
        @operation.path = path
      end

      def result
        hash = {
          path: path,
          description: description
        }
        operation.result.each do |key, value|
          hash[key] = value
        end
        hash
      end
    end
  end
end
