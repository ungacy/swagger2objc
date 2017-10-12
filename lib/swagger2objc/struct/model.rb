require 'swagger2objc/struct/property'
module Swagger2objc
  module Struct
    class Model < Base
      attr_reader :description
      attr_reader :id
      attr_reader :properties
      attr_reader :required

      def setup
        # puts '----------Model--------------'

        hash = {}
        @properties.each do |key, item|
          property = Property.new(item)
          property.name = key
          property.required = false
          property.required = true if @required && @required.include?(key)

          hash[key] = property
        end
        @properties = hash
      end

      def result
        {
          id: id
        }
      end
    end
  end
end
