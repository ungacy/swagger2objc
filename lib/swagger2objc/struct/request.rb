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
      end

      def result
        hash =  {
          path: path,
          description: description
        }
        operation.result.each {|key, value|
          hash[key] = value
        }
        hash
      end
    end
  end
end
