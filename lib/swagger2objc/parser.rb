require 'swagger2objc/client/client'
require 'swagger2objc/struct'
require 'swagger2objc/constants'
require 'swagger2objc/generator/model_generator'
require 'swagger2objc/generator/sdk_generator'
require 'swagger2objc/config'
require 'nokogiri-plist'

module Swagger2objc
  class Parser
    def initialize(base_uri, filter = nil)
      Swagger2objc::Configure.setup
      Swagger2objc::Generator::ModelGenerator.clear
      @request = Swagger2objc::Client.new(base_uri)
      @filter = filter
      setup
    end

    def setup
      @apis = @request.object_from_uri[Swagger2objc::APIS]
      @controllers = []
      if @apis
        @apis.each do |dict|
          path = dict[Swagger2objc::PATH]
          next if @filter && !path.include?(@filter)
          result = @request.object_from_uri(path)
          controller = Swagger2objc::Struct::Controller.new(result)
          @controllers << controller
        end
      end
    end

    def sdk_result
      sdk = Swagger2objc::Generator::SDKGenerator.new(@controllers)
      sdk.generate
    end

    def model_result
      @controllers.each do |controller|
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
