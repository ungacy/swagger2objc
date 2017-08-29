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
      if base_uri
        @request = Swagger2objc::Client.new(base_uri)
        @filter = filter
        @only = only
        setup
      else
        json = Swagger2objc::Generator::TemplateReplacer.read_file_content('./swagger.txt')
        hash = JSON.parse(json)
        controller = Swagger2objc::Struct::Controller2.new(hash)
        #        puts controller.result
        @controllers = [controller]
        setup_2_0
      end
    end

    def setup_2_0; end

    def setup
      @apis = @request.object_from_uri[Swagger2objc::APIS]
      @controllers = []
      if @apis
        @apis.each do |dict|
          path = dict[Swagger2objc::PATH]
          next if @filter && @filter.include?(path)
          result = @request.object_from_uri(path)
          controller = Swagger2objc::Struct::Controller.new(result)
          next if @only && !@only.include?(controller.category)
          Swagger2objc::Generator::ModelGenerator.clear([controller.category])
          Swagger2objc::Generator::SDKGenerator.clear([controller.category])
          @controllers << controller
        end
      end
    end

    def sdk_result
      sdk = Swagger2objc::Generator::SDKGenerator.new(nil, @controllers)
      sdk.generate
    end

    def model_result
      @controllers.each do |controller|
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
