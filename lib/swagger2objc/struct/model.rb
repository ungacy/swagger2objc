require 'swagger2objc/struct/property'
require 'swagger2objc/config'
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
        @properties = !@properties.nil? ? @properties : []
        @properties.each do |key, item|
          property = Property.new(item)
          property.name = key
          property.service = service
          property.required = @required.include?(key) if @required
          hash[key] = property
        end
        add_property = Swagger2objc::Configure.config['add_property'][id]
        if add_property
          add_property.each do |key, item|
            property = Property.new(item)
            property.name = key
            property.service = service
            property.required = @required.include?(key) if @required
            hash[key] = property
          end
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
