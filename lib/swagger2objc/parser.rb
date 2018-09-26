require 'swagger2objc/client/client'
require 'swagger2objc/struct'
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
      @server_array = []
      Swagger2objc::Generator::AbstractGenerator.clear(only)
      if only
        single_service(name, path)
      else
        puts 'Parsing : ' + base_uri
        all_service
      end
      @server_array.sort! do |s_a, s_b|
        a = s_a.name
        b = s_b.name
        if a == 'affair'
          -1
        elsif b == 'affair'
          1
        else
          a <=> b
        end
      end
      @server_array.each do |service|
        # puts service.name
        sdk_result(service)
        model_result(service)
      end
    end

    def all_service
      ignore_service = Swagger2objc::Configure.config[Swagger2objc::Config::IGNORE_SERVICE]
      replace_service = Swagger2objc::Configure.config['replace_service']
      replace_service = {} if replace_service.nil?
      client = Swagger2objc::Client.new(@base_uri + @path)
      services = client.object_from_uri
      services.each do |service_hash|
        name = service_hash['name']
        next if ignore_service.include?(name)
        location = service_hash['location']
        replace = replace_service[name]
        single_service(name, replace ? replace : location)
      end
    end

    def single_service(name, location)
      uri = @base_uri + location
      uri = location if location.start_with?('http')
      puts 'Fetching swagger from ' + uri
      client = Swagger2objc::Client.new(uri)
      swagger_hash = client.object_from_uri
      return nil if swagger_hash['code'] == 500
      puts 'Generating code from : [' + name + ']'
      # puts 'swagger_hash : ' + swagger_hash.to_s
      service = Swagger2objc::Struct::Service.new(swagger_hash, nil, name)
      @server_array << service
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
