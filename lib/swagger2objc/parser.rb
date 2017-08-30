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
      unless only
        Swagger2objc::Generator::ModelGenerator.clear
        Swagger2objc::Generator::SDKGenerator.clear
      end
      setup
    end

    def setup
      # swagger_hash = @request.object_from_uri()
      json = Swagger2objc::Generator::TemplateReplacer.read_file_content('./swagger.txt')
      swagger_hash = JSON.parse(json)
      @root = Swagger2objc::Struct::Root.new(swagger_hash)
    end

    def sdk_result
      sdk = Swagger2objc::Generator::SDKGenerator.new(nil, @root.controllers)
      sdk.generate
    end

    def model_result
      @root.definitions.each do |ref, ref_hash|
        next if ref == 'Null'
        ref_hash['id'] = ref
        model = Swagger2objc::Struct::Model.new(ref_hash)
        generator = Swagger2objc::Generator::ModelGenerator.new('All', model)
        generator.generate
      end
    end
  end
end
