module Swagger2objc
  module Struct
    class Base
      def initialize(hash = {})
        hash.each do |k, v|
          instance_variable_set("@#{k}", v)
          self.class.send(:define_method, k, proc { instance_variable_get("@#{k}") })
          self.class.send(:define_method, "#{k}=", proc { |v| instance_variable_set("@#{k}", v) })
        end
        setup
      end

      def setup; end

      # @return [HASH]
      def result; end
    end
  end
end

require 'swagger2objc/struct/controller'
require 'swagger2objc/struct/root'
require 'swagger2objc/struct/parameter'
require 'swagger2objc/struct/operation'
