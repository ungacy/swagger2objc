require 'swagger2objc/struct/request'
require 'swagger2objc/struct/model'
module Swagger2objc
  module Struct
    class Controller < Base
      attr_reader :apis
      attr_reader :apiVersion
      attr_reader :basePath
      attr_reader :consumes
      attr_reader :models
      attr_reader :produces
      attr_reader :resourcePath
      attr_reader :swaggerVersion
      attr_reader :category

      def setup
        apis.map! { |item| Request.new(item) }
        models.transform_values! { |item| Model.new(item) }
        @category = resourcePath.sub('/', '')
        @category.capitalize!
        @category.gsub!(/\_\w/) { |match| match[1].upcase }
      end

      def result
        apis.each do |item|
          puts item.result
        end
      end
    end
  end
end
