require 'swagger2objc/generator/abstract_generator'

module Swagger2objc
  module Generator
    class ModelGenerator < AbstractGenerator
      def generate
        ignore = Configure.config[Swagger2objc::Config::IGNORE]
        return if ignore.include?(model.id) || model.id == 'Null' || model.id.start_with?('Entry')
        properties = ''
        import = ''
        primary_key = ''
        class_map = {}
        avoid_map = {}
        plan_b = ''

        model_name = Swagger2objc::Utils.class_name_formatter(model.id)

        return if !model_name
        rename_config = Swagger2objc::Configure.config[Swagger2objc::Config::RENAME]
        if rename_config
          rename = rename_config[model_name]
        end
        if rename
          rename.each {|key, value| avoid_map[value] = key}
        end
        model.properties.each do |_key, property|
          properties << property.output(import, model, class_map, avoid_map, rename)
          if property.name == 'id'
            primary_key = avoid_map.key('id')
          elsif property.name.length > 2 && property.name.downcase.end_with?('id')
            maybe = property.name.downcase.sub('id', '')
            if model_name.downcase.include?(maybe)
              plan_b = property.name
            end
          end
        end
        if primary_key == ''
          primary_key = plan_b
        end
        if primary_key != ''
          primary_key = wrap_primary_key(primary_key)
        end
        primary_config = Swagger2objc::Configure.config[Swagger2objc::Config::PRIMARY]
        if primary_config && primary_config[model_name]
          primary_key = wrap_primary_key(primary_config[model_name])
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
            category: category,
            primary_key: primary_key
        }
        TemplateReplacer.replace(replacement, Swagger2objc::Config::MODEL)
      end

      def result;
      end
    end
  end
end
