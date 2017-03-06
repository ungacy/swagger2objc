require 'swagger2objc/struct/model'
require 'swagger2objc/generator/type'
require 'swagger2objc/generator/template_replacer'
require 'swagger2objc/generator/file_generator'
require 'swagger2objc/constants'
require 'swagger2objc/config'

module Swagger2objc
  module Generator
    class ModelGenerator
      attr_reader :category
      attr_reader :author
      attr_reader :company
      attr_reader :project
      attr_reader :date
      attr_reader :template
      attr_reader :class_prefix
      attr_reader :model

      def self.clear
        FileGenerator.clear
      end

      def initialize(category, model)
        config = Configure.config
        @author = config[Swagger2objc::Config::AUTHOR]
        @company = config[Swagger2objc::Config::COMPANY]
        @project = config[Swagger2objc::Config::PROJECT]
        @category = category
        @model = model
        setup
      end

      def custom_class_map(hash)
        return '' if hash.count == 0
        template = "\n/**
 The generic class mapper for container properties.\n*/
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
{line}            };
}\n"
        line = ''
        hash.each do |key, value|
          line << "            @\"#{key}\": [#{value} class],\n"
        end
        template.sub('{line}', line)
      end

      def custom_property_map(hash)
        return '' if hash.count == 0
        template = "/**
 Custom property mapper.\n*/
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
{line}            };
}\n"
        line = ''
        hash.each do |key, value|
          line << "            @\"#{key}\": @\"#{value}\",\n"
        end
        template.sub('{line}', line)
      end

      def setup
        ignore = Configure.config[Swagger2objc::Config::IGNORE]
        return if ignore.include?(model.id)
        properties = ''
        import = ''
        class_map = {}
        avoid_map = {}
        model_name = Swagger2objc::Utils.class_name_formatter(model.id)
        model.properties.each do |_key, property|
          properties << property.output(import, model, class_map, avoid_map)
        end
        container_mapping = custom_class_map(class_map)
        property_mapping = custom_property_map(avoid_map)
        replacement = {
          import: import,
          class_name: model_name,
          properties: properties,
          project: project,
          company: company,
          author: author,
          container_mapping: container_mapping,
          property_mapping: property_mapping,
          category: category
        }
        TemplateReplacer.replace(replacement)
      end

      def result; end
    end
  end
end
