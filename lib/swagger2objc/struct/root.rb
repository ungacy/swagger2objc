require 'swagger2objc/struct/request'
require 'swagger2objc/struct/model'
module Swagger2objc
  module Struct
    class Root < Base
      attr_reader :basePath
      attr_reader :definitions
      attr_reader :host
      attr_reader :info
      attr_accessor :paths
      attr_reader :swagger

      attr_reader :controllers

      def setup
        controller_hash = {}
        @controllers = []
        if @paths
          @paths.each do |path, dict|
            puts path
            dict.each do |method, operation_hash|
              puts method
              controller_key = operation_hash['tags'].first
              controller = controller_hash[controller_key]
              category = controller_key.sub('-controller', '')
              category.capitalize!
              category.gsub!(/\-\w/) { |match| match[1].upcase }
              if category == 'AppFile'
                category = 'File'
              end
              next if @only && !@only.include?(category)
              Swagger2objc::Generator::ModelGenerator.clear([category])
              Swagger2objc::Generator::ModelGenerator.clear([category])
              operation_hash['method'] = method
              operation_hash['path'] = path
              operation = Swagger2objc::Struct::Operation.new(operation_hash)
              if controller.nil?
                controller = Swagger2objc::Struct::Controller.new
                controller.category = category
                @controllers << controller
                controller_hash[controller_key] = controller
              end
              controller.apis << operation
            end
            # path = dict[Swagger2objc::PATH]
            # next if @filter && @filter.include?(path)
            # result = @request.object_from_uri(path)
            # controller = Swagger2objc::Struct::Controller.new(result)
            # next if @only && !@only.include?(controller.category)
            # Swagger2objc::Generator::ModelGenerator.clear([controller.category])
            # Swagger2objc::Generator::SDKGenerator.clear([controller.category])
            # @controllers << controller
          end
        end
      end

      def result
        paths.each do |item|
          puts item
        end
      end
    end
  end
end
