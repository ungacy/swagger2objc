require 'swagger2objc/generator/abstract_generator'

module Swagger2objc
  module Generator
    class SDKGenerator < AbstractGenerator
      @@extra_method_subfix = {}

      def wrap_response_class_header(response_class)
        template = "\n/**
 The class of response object[s]\n @return [#{response_class} class]*/
+ (Class /*#{response_class}*/ __nullable)responseClass;\n"
        template
      end

      def wrap_response_class_body(response_class)
        template = "\n/**
 The class of response object[s]\n @return [#{response_class} class]\n*/
+ (Class)responseClass {
    return [#{response_class} class];
}\n"
        template
      end

      def add_subfix(class_name, method)
        result = if method == 'GET'
                   class_name + 'Query'
                 elsif method == 'PUT'
                   class_name + 'Update'
                 elsif method == 'DELETE'
                   class_name + 'Remove'
                 elsif method == 'POST'
                   class_name + 'Submit'
                 else
                   class_name + method
                     end
        result
      end

      def generate
        sim = {}
        module_header = {}
        service_module = {}
        return if model.nil?
        model.each do |controller|
          controller.operations.each do |operation|
            class_name = Swagger2objc::Utils.sdk_name_formatter(operation,
                                                                controller,
                                                                Swagger2objc::Config::SDK)

            if controller.category != 'Message' && controller.category != 'Permission'
              if operation.add_subfix
                class_name = add_subfix(class_name, operation.method)
              end
            end

            sim[class_name] = {
              parameters: operation.parameters,
              category: controller.category,
              service: controller.service,
              operation: operation
            }
            header_array = module_header[controller.category]
            if header_array.nil?
              header_array = [class_name]
              module_header[controller.category] = header_array
              service_module[controller.category] = controller.service
            else
              header_array << class_name
            end
          end
        end

        result = {}
        link_map = Swagger2objc::Configure.config[Swagger2objc::Config::LINK]
        model.each do |controller|
          controller.operations.each do |operation|
            hash = operation.result
            hash[:path] = operation.path
            hash[:category] = controller.category
            class_name = Swagger2objc::Utils.sdk_name_formatter(operation,
                                                                controller,
                                                                Swagger2objc::Config::SDK)
            if controller.category != 'Message' && controller.category != 'Permission'
              if operation.add_subfix
                class_name = add_subfix(class_name, operation.method)
              end
            end
            if link_map && link_map[controller.category]
              hash[:link] = link_map[controller.category]
            end
            result[class_name] = hash
          end
        end
        # Swagger2objc::Generator::TemplateReplacer.replace_plist_content(result.to_plist_xml)
        sim.each do |class_name, hash|
          category = hash[:category]
          operation = hash[:operation]

          # puts "---------#{class_name}-------#{category}-------"
          config = result[class_name]
          param_generate(class_name, hash[:parameters], category, operation, config, hash[:service])
        end
        module_header_string = ''
        module_header.each do |key, array|
          replacement = {
            service: service_module[key],
            project: project,
            company: company,
            author: author
          }
          type = Swagger2objc::Config::SDK
          class_prefix = Swagger2objc::Configure.config[Swagger2objc::Config::CLASS_PREFIX][type]
          replacement[:category] = key
          replacement[:module_name] = class_prefix + key
          header = ''
          array.to_set.to_a.sort.each do |item|
            header << "#import \"#{item}.h\"\n"
          end
          replacement[:header] = header
          module_header_string += Swagger2objc::Generator::TemplateReplacer.replace_module_header_content(replacement)
          module_header_string += "\n"
        end
        # Swagger2objc::Generator::TemplateReplacer.replace_framework_header_content(module_header_string)
      end

      def objc_code_from_hash(hash)
        result = "    return @{\n"
        hash.each do |key, value|
          if value.is_a? Array
            # result << "        \@\"#{key}\": \@\"#{value}\",\n"
            result << "        \@\"#{key}\": \@[\n"
            value.each do |sub_hash|
              result << "            @{\n"
              sub_hash.each do |key, value|
                result << "                \@\"#{key}\": \@\"#{value}\",\n"
              end
              result << "            },\n"
            end
            result << "        ],\n"
          else
            if value
              value = value.gsub(/\"/, '\"')
              result << "        \@\"#{key}\": \@\"#{value}\",\n"
            end
          end
        end
        result << '    };'
        result
      end

      def param_generate(class_name, parameters, category, operation, config, service)
        comment = operation.output
        srk_config = objc_code_from_hash(config)
        properties = ''
        import = ''
        response_class_header = ''
        response_class_body = ''
        avoid_map = {}
        model_name = class_name.clone
        response_class = operation.response_class
        class_prefix = Swagger2objc::Configure.config[Swagger2objc::Config::CLASS_PREFIX][Swagger2objc::Config::MODEL]
        if response_class.start_with?(class_prefix)
          import << "#import \"#{response_class}.h\"\n"
          response_class_header = wrap_response_class_header(response_class)
          response_class_body = wrap_response_class_body(response_class)
        end
        parameters.each do |parameter|
          properties << parameter.output(import, avoid_map)
        end
        property_mapping = custom_property_map(avoid_map)
        replacement = {
          service: service,
          import: import,
          class_name: model_name,
          properties: properties,
          project: project,
          company: company,
          author: author,
          container_mapping: {},
          property_mapping: property_mapping,
          category: category,
          comment: comment,
          response_class_header: response_class_header,
          response_class_body: response_class_body,
          srk_config: srk_config
        }
        TemplateReplacer.replace(replacement, Swagger2objc::Config::SDK)
      end
    end
  end
end
