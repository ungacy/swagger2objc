require 'swagger2objc/client/client'
require 'swagger2objc/struct'
require 'swagger2objc/constants'
require 'swagger2objc/generator/model_generator'
require 'swagger2objc/generator/sdk_generator'
require 'swagger2objc/config'
require 'swagger2objc/generator/template_replacer'

module Swagger2objc
  class Parser
    def initialize(base_uri, path, only = nil)
      Swagger2objc::Configure.setup
      puts 'Parsing : ' + base_uri
      @request = Swagger2objc::Client.new(base_uri + path)
      @only = only
      @base_uri = base_uri
      unless only
        Swagger2objc::Generator::ModelGenerator.clear
        Swagger2objc::Generator::SDKGenerator.clear
      end
      setup
    end

    def setup
      services = @request.object_from_uri
      services.each do |service_hash|
        next if service_hash['name'].start_with?('tss')
        location = service_hash['location']
        request = Swagger2objc::Client.new(@base_uri + location)
        swagger_hash = request.object_from_uri
        root = Swagger2objc::Struct::Root.new(swagger_hash, nil)
        sdk_result(root)
        model_result(root)
      end
    end

    def sdk_result(root)
      sdk = Swagger2objc::Generator::SDKGenerator.new(nil, root.controllers)
      sdk.generate
    end

    def model_result(root)
      root.controllers.each do |controller|
        next if controller.models.nil?
        controller.models.each do |ref|
          ref_hash = root.definitions[ref].dup
          ref_hash['id'] = ref
          model = Swagger2objc::Struct::Model.new(ref_hash)
          generator = Swagger2objc::Generator::ModelGenerator.new(controller.category, model)
          generator.generate
        end
      end

      # @root.definitions.each do |ref, ref_hash|
      #   next if ref == 'Null'
      #   ref_hash['id'] = ref
      #   model = Swagger2objc::Struct::Model.new(ref_hash)
      #   generator = Swagger2objc::Generator::ModelGenerator.new('All', model)
      #   generator.generate
      # end
    end
  end
end
