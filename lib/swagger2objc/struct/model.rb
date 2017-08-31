require 'swagger2objc/struct/property'
module Swagger2objc
  module Struct
    class Model < Base
      attr_reader :description
      attr_reader :id
      attr_reader :properties

      def init_with_hash(hash = {})
        @description = hash['description']
        @id = hash['id']
        @properties = hash['properties']
        setup
      end

      def setup
        # puts '----------Model--------------'

        hash = {}
        @properties.each do |key, item|
          property = Property.new
          item['name'] = key
          property.init_with_hash(item)
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
