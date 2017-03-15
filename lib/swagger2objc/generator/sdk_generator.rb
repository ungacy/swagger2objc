require 'swagger2objc/generator/abstract_generator'
require 'nokogiri-plist'

module Swagger2objc
  module Generator
    class SDKGenerator < AbstractGenerator
      def generate
        sim = {}
        model.each do |controller|
          controller.apis.each do |request|
            class_name = Swagger2objc::Utils.sdk_name_formatter(request.path.sub(controller.resourcePath, ''), controller.category, Swagger2objc::Config::SDK)
            sim[class_name] = {
              parameters: request.operation.parameters,
              category: controller.category,
              operation: request.operation
            }
          end
        end

        sim.each do |class_name, config|
          category = config[:category]
          operation = config[:operation]
          # puts "---------#{class_name}--------------"
          param_generate(class_name, config[:parameters], category, operation.output)
        end
        result = {}
        model.each do |controller|
          controller.apis.each do |request|
            hash = request.operation.result
            hash['path'] = request.path
            hash['category'] = controller.category
            class_name = Swagger2objc::Utils.sdk_name_formatter(request.path.sub(controller.resourcePath, ''), controller.category, Swagger2objc::Config::SDK)
            result[class_name] = hash
          end
        end
        Swagger2objc::Generator::TemplateReplacer.replace_plist_content(result.to_plist_xml)
      end

      def param_generate(class_name, parameters, category, comment)
        properties = ''
        import = ''
        avoid_map = {}
        model_name = class_name.clone
        parameters.each do |parameter|
          properties << parameter.output(import, avoid_map)
        end
        property_mapping = custom_property_map(avoid_map)
        replacement = {
          import: import,
          class_name: model_name,
          properties: properties,
          project: project,
          company: company,
          author: author,
          container_mapping: {},
          property_mapping: property_mapping,
          category: category,
          comment: comment
        }
        TemplateReplacer.replace(replacement, Swagger2objc::Config::SDK)
      end
    end
  end
end
