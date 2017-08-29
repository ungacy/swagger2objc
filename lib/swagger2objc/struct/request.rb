require 'swagger2objc/struct/operation'

module Swagger2objc
  module Struct
    class Request < Base
      attr_reader :description
      attr_reader :operations
      attr_reader :operation
      attr_accessor :path
      attr_reader :method_hash

      def initialize(hash = {}, path = nil)
        hash.each do |k, v|
          instance_variable_set("@#{k}", v)
          self.class.send(:define_method, k, proc { instance_variable_get("@#{k}") })
          self.class.send(:define_method, "#{k}=", proc { |v| instance_variable_set("@#{k}", v) })
        end
        @path = path
        setup
      end

      def setup
        if @operation
          @operation = Operation.new(operations.first)
          @operation.path = path
        else
          method_hash.each do |_method, operation|
            @operation = Operation.new(operation)
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
