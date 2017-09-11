module Swagger2objc
  module Struct
    class Base
      def initialize(hash = {})
        hash.each do |k, v|
          key = k.sub('$', '')
          instance_variable_set("@#{key}", v)
          self.class.send(:define_method, key, proc { instance_variable_get("@#{key}") })
          self.class.send(:define_method, "#{key}=", proc { |v| instance_variable_set("@#{key}", v) })
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
