require 'swagger2objc/struct/property'
module Swagger2objc
  module Struct
    class Model < Base
      attr_reader :description
      attr_reader :id
      attr_reader :properties

      def setup
        # puts '----------Model--------------'
        properties.transform_values! { |item| Property.new(item) }
        properties.each do |key, item|
          item.name = key
          # puts item.result
        end
      end

      def result
        {
          id: id
        }
      end
    end
  end
end
