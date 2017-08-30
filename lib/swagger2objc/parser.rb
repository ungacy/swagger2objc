require 'swagger2objc/client/client'
require 'swagger2objc/struct'
require 'swagger2objc/constants'
require 'swagger2objc/generator/model_generator'
require 'swagger2objc/generator/sdk_generator'
require 'swagger2objc/config'
require 'nokogiri-plist'
require 'swagger2objc/generator/template_replacer'

module Swagger2objc
  class Parser
    def initialize(base_uri, filter = nil, only = nil)
      Swagger2objc::Configure.setup
      @request = Swagger2objc::Client.new(base_uri)
      @filter = filter
      @only = only
      setup
    end

    def setup
      # swagger_hash = @request.object_from_uri()
      json = Swagger2objc::Generator::TemplateReplacer.read_file_content('./swagger.txt')
      swagger_hash = JSON.parse(json)

      @root = Swagger2objc::Struct::Root.new(swagger_hash)

      if @paths
        @paths.each do |path, dict|
          puts path
          dict.each do |method, operation_hash|
            puts method
            controller_name = operation_hash['tags'].first
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

    def sdk_result
      sdk = Swagger2objc::Generator::SDKGenerator.new(nil, @root.controllers)
      sdk.generate
    end

    def model_result
      @root.controllers.each do |controller|
        next if controller.models.nil?
        controller.models.each do |_key, model|
          begin
            generator = Swagger2objc::Generator::ModelGenerator.new(controller.category, model)
            generator.generate
          rescue => err
            puts err
            puts model.result
            puts controller.resourcePath
          end
        end
      end
    end
  end
end
