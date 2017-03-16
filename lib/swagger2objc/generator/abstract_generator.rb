require 'swagger2objc/generator/template_replacer'
require 'swagger2objc/generator/file_generator'
require 'swagger2objc/struct/model'
require 'swagger2objc/generator/type'
require 'swagger2objc/constants'
require 'swagger2objc/config'

module Swagger2objc
  module Generator
    class AbstractGenerator
      attr_reader :category
      attr_reader :author
      attr_reader :company
      attr_reader :project
      attr_reader :model

      def custom_class_map(hash)
        return '' if hash.count == 0
        template = "\n/**
 The generic class mapper for container properties.\n*/
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
{line}    };
}\n"
        line = ''
        hash.each do |key, value|
          line << "        @\"#{key}\": [#{value} class],\n"
        end
        template.sub('{line}', line)
      end

      def custom_property_map(hash)
        return '' if hash.count == 0
        template = "\n/**
 Custom property mapper.\n*/
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
{line}    };
}\n"
        line = ''
        hash.each do |key, value|
          line << "        @\"#{key}\": @\"#{value}\",\n"
        end
        template.sub('{line}', line)
      end

      def wrap_primary_key(primary_key)
        template = "\n/**
 Defined for database.\n*/
+ (NSString *)primaryKey {
    return @\"{primary_key}\";
}\n"
        template.sub('{primary_key}', primary_key)
      end

      def self.clear
        FileGenerator.clear(Swagger2objc::Config::MODEL)
        FileGenerator.clear(Swagger2objc::Config::SDK)
      end

      def initialize(category = nil, model)
        config = Configure.config
        @author = config[Swagger2objc::Config::AUTHOR]
        @company = config[Swagger2objc::Config::COMPANY]
        @project = config[Swagger2objc::Config::PROJECT]
        @category = category
        @model = model
      end

      def generate; end
    end
  end
end
