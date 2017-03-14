require 'swagger2objc/client/client'
require 'swagger2objc/struct'
require 'swagger2objc/constants'
require 'swagger2objc/generator/model_generator'
require 'swagger2objc/config'

module Swagger2objc
  class Parser
    def initialize(base_uri, filter = nil)
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
      Swagger2objc::Configure.setup
      Swagger2objc::Generator::ModelGenerator.clear
    end

    def result
      @controllers.each(&:result)
    end

    def model_result
      @controllers.each do |controller|
        controller.models.each do |_key, model|
          begin
            Swagger2objc::Generator::ModelGenerator.new(controller.resourcePath.sub('/', ''), model)
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
