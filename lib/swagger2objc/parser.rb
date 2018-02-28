require 'swagger2objc/client/client'
require 'swagger2objc/struct'
require 'swagger2objc/constants'
require 'swagger2objc/generator/model_generator'
require 'swagger2objc/generator/sdk_generator'
require 'swagger2objc/config'
require 'swagger2objc/generator/template_replacer'

module Swagger2objc
  class Parser
    def initialize(base_uri, path, only = nil, name = nil)
      Swagger2objc::Configure.setup
      @only = only
      @path = path
      @base_uri = base_uri
      Swagger2objc::Generator::AbstractGenerator.clear(only)
      if only
        single_service(name, path)
      else
        puts 'Parsing : ' + base_uri
        setup
      end
    end

    def setup
      ignore = Swagger2objc::Configure.config[Swagger2objc::Config::IGNORE]

      request = Swagger2objc::Client.new(@base_uri + @path)
      services = request.object_from_uri
      services.each do |service_hash|
        name = service_hash['name']
        next if ignore.include?(name)
        location = service_hash['location']
        single_service(name, location)
      end
    end

    def single_service(name, location)
      puts 'Fetching swagger from ' + @base_uri + location
      request = Swagger2objc::Client.new(@base_uri + location)
      swagger_hash = request.object_from_uri
      raise swagger_hash.to_s if swagger_hash['code'] == 500
      puts 'Generating code from : [' + name + ']'
      service = Swagger2objc::Struct::Service.new(swagger_hash, nil, name)
      sdk_result(service)
      model_result(service)
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
          ref_hash['service'] = controller.service
          model = Swagger2objc::Struct::Model.new(ref_hash)
          generator = Swagger2objc::Generator::ModelGenerator.new(controller.category, model)
          generator.service = controller.service
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
