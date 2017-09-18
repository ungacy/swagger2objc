require 'swagger2objc/struct/model'
module Swagger2objc
  module Struct
    class Root < Base
      attr_reader :basePath
      attr_reader :definitions
      attr_reader :common
      attr_reader :host
      attr_reader :info
      attr_accessor :paths
      attr_reader :swagger

      attr_reader :controllers

      def setup
        model_type = Swagger2objc::Config::MODEL
        model_class_prefix = Swagger2objc::Configure.config[Swagger2objc::Config::CLASS_PREFIX][model_type]
        definitions.delete('Null')
        definitions.delete('Timestamp')
        controller_hash = {}
        @controllers = []
        @common = definitions.dup
        if @paths
          @paths.each do |path, dict|
            dict.each do |method, operation_hash|
              if operation_hash['tags']
                controller_key = operation_hash['tags'].first
                next if controller_key == 'Sender'
                next if controller_key == 'Inner'
              else
                next
              end

              controller = controller_hash[controller_key]
              category = controller_key.sub('-controller', '').sub('Resource', '')
              category.capitalize!
              category.gsub!(/\-\w/) { |match| match[1].upcase }
              category = 'File' if category == 'AppFile'
              next if @only && !@only.include?(category)
              Swagger2objc::Generator::ModelGenerator.clear([category])
              Swagger2objc::Generator::SDKGenerator.clear([category])
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

              all_ref = Swagger2objc::Utils.all_ref_of_ref(operation.all_ref, @common)
              controller.models += all_ref
              all_ref.each { |ref| @common.delete(ref) }
            end
          end
        end
        # raise "remain #{@common.count} for common" if @common.count != 0
      end

      def result
        paths.each do |item|
          puts item
        end
      end
    end
  end
end
