require 'swagger2objc/generator/template_replacer'
require 'swagger2objc/generator/file_generator'
require 'swagger2objc/struct/model'
require 'swagger2objc/generator/type'
require 'swagger2objc/config'

module Swagger2objc
  module Generator
    class AbstractGenerator
      attr_accessor :service
      attr_reader :category
      attr_reader :author
      attr_reader :company
      attr_reader :project
      attr_reader :model
      attr_reader :only

      def self.clear(only = nil)
        FileGenerator.clear(only)
      end

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
        count = 0
        hash.each do |key, _value|
          count += 1 unless key.start_with?('X_SIMU_')
        end
        return '' if count == 0

        template = "\n/**
 Custom property mapper.\n*/
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
{line}    };
}\n"
        line = ''
        hash.each do |key, value|
          unless key.start_with?('X_SIMU_')
            line << "        @\"#{key}\": @\"#{value}\",\n"
          end
        end
        template.sub('{line}', line)
      end

      def wrap_primary_key(primary_key)
        if primary_key.instance_of? String
          template = "\n/**
 Defined for database.\n*/
+ (NSString *)primaryKey {
    return @\"{primary_key}\";
}\n"
          template.sub('{primary_key}', primary_key)
        elsif primary_key.instance_of? Array

          template = "\n/**
 Defined for database.\n*/
+ (NSArray *)primaryKeyArray {
    return @[{primary_key}];
}\n"
          result = ''
          primary_key.each do |key|
            result += "@\"#{key}\", "
          end
          template.sub('{primary_key}', result[0..-3])
        end
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
