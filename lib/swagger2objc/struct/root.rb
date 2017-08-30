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
        model_type = Swagger2objc::Config::MODEL
        model_class_prefix = Swagger2objc::Configure.config[Swagger2objc::Config::CLASS_PREFIX][model_type]

        controller_hash = {}
        @controllers = []
        definitions_copy = definitions.dup
        if @paths
          @paths.each do |path, dict|
            dict.each do |method, operation_hash|
              controller_key = operation_hash['tags'].first
              controller = controller_hash[controller_key]
              category = controller_key.sub('-controller', '')
              category.capitalize!
              category.gsub!(/\-\w/) { |match| match[1].upcase }
              category = 'File' if category == 'AppFile'
              next if @only && !@only.include?(category)
              Swagger2objc::Generator::ModelGenerator.clear([category])
              Swagger2objc::Generator::ModelGenerator.clear([category])
              operation_hash['method'] = method.upcase
              operation_hash['path'] = path
              operation = Swagger2objc::Struct::Operation.new(operation_hash)
              if controller.nil?
                controller = Swagger2objc::Struct::Controller.new
                controller.category = category
                @controllers << controller
                controller_hash[controller_key] = controller
              end
              controller.operations << operation
              if operation.response_class.start_with?(model_class_prefix) && definitions_copy[operation.ref]
                controller.models << operation.ref
                definitions_copy.delete(operation.ref)
              end
            end
          end
        end
        puts definitions_copy.count
      end

      def result
        paths.each do |item|
          puts item
        end
      end
    end
  end
end
