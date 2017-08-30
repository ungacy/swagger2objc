require 'swagger2objc/struct/operation'

module Swagger2objc
  module Struct
    class Request < Base
      attr_reader :description

      attr_reader :operation
      attr_accessor :path
      attr_reader :method_hash


      def setup
        if @operations
          @operation = Operation.new(operations.first)
          @operation.path = path
        else
          method_hash.each do |method, operation|
            @operation = Operation.new(operation,)
            @operation.path = path
          end
        end
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
