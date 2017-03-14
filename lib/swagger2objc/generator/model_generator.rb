require 'swagger2objc/generator/abstract_generator'

module Swagger2objc
  module Generator
    class ModelGenerator < AbstractGenerator
      def generate
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
        TemplateReplacer.replace(replacement, Swagger2objc::Config::MODEL)
      end

      def result; end
    end
  end
end
