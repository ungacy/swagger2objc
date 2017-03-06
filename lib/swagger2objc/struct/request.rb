require 'swagger2objc/struct/operation'

module Swagger2objc
  module Struct
    class Request < Base
      attr_reader :description
      attr_reader :operations
      attr_reader :operation
      attr_reader :path

      def setup
        operation = Operation.new(operations.first)
      end

      def result
        {
          operation: operation.result,
          path: path,
          description: description
        }
      end
    end
  end
end
