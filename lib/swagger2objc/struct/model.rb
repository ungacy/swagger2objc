require 'swagger2objc/struct/property'
module Swagger2objc
  module Struct
    class Model < Base
      attr_reader :description
      attr_reader :id
      attr_reader :properties
      attr_reader :required
      attr_accessor :service

      def setup
        # puts '----------Model--------------'

        hash = {}
        @properties.each do |key, item|
          property = Property.new(item)
          property.name = key
          property.service = service
          property.required = @required.include?(key) if @required
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
