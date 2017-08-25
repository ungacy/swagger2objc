require 'swagger2objc/generator/abstract_generator'
require 'nokogiri-plist'

module Swagger2objc
  module Generator
    class SDKGenerator < AbstractGenerator
      @@extra_method_subfix = {}

      def wrap_response_class_header(response_class)
        template = "\n/**
 The class of response object[s]\n @return [#{response_class} class]*/
+ (Class /*#{response_class}*/)responseClass;\n"
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

      def generate
        sim = {}
        module_header = {}
        return if model.nil?
        subfix_array = Swagger2objc::Configure.config[Swagger2objc::Config::SUBFIX]
        model.each do |controller|
          controller.apis.each do |request|
            sub_path = request.path.sub(controller.resourcePath, '')
            # puts "---------#{sub_path}-------#{controller.category}-------"
            if controller.category == 'Chat'
              sub_path = request.path.sub('/'+controller.category.downcase, '')
              # puts "---------#{sub_path}-------#{controller.category}-------"
            end
            class_name = Swagger2objc::Utils.sdk_name_formatter(sub_path, controller.category, Swagger2objc::Config::SDK)

            if subfix_array.include?(class_name)
              if request.operation.method == 'GET'
                class_name = class_name + 'Query'
              else
                class_name = class_name + 'Submit'
              end
            end
            sim[class_name] = {
                parameters: request.operation.parameters,
                category: controller.category,
                operation: request.operation
            }
            header_array = module_header[controller.category]
            if header_array.nil?
              header_array = [class_name]
              module_header[controller.category] = header_array
            else
              header_array << class_name
            end
          end
        end

        result = {}
        model.each do |controller|
          controller.apis.each do |request|
            hash = request.operation.result
            hash[:path] = request.path
            hash[:category] = controller.category
            sub_path = request.path.sub(controller.resourcePath, '')
            if controller.category == 'Chat'
              sub_path = request.path.sub('/'+controller.category.downcase, '')
            end
            class_name = Swagger2objc::Utils.sdk_name_formatter(sub_path, controller.category, Swagger2objc::Config::SDK)
            if subfix_array.include?(class_name)
              if request.operation.method == 'GET'
                class_name = class_name + 'Query'
              else
                class_name = class_name + 'Submit'
              end
            end
            result[class_name] = hash

          end
        end
        #Swagger2objc::Generator::TemplateReplacer.replace_plist_content(result.to_plist_xml)

        sim.each do |class_name, hash|
          category = hash[:category]
          operation = hash[:operation]

          #puts "---------#{class_name}-------#{category}-------"
          config = result[class_name]
          param_generate(class_name, hash[:parameters], category, operation, config)
        end

        module_header.each do |key, array|
          replacement = {
              project: project,
              company: company,
              author: author,
          }
          type = Swagger2objc::Config::SDK
          class_prefix = Swagger2objc::Configure.config[Swagger2objc::Config::CLASS_PREFIX][type]
          replacement[:category] = key
          replacement[:module_name] = class_prefix + key
          header = ''
          array.each do |item|
            header << "#import \"#{item}.h\"\n"
          end
          replacement[:header] = header
          Swagger2objc::Generator::TemplateReplacer.replace_module_header_content(replacement)
        end
      end

      def objc_code_from_hash(hash)
        result= "    return @{\n"
        hash.each {|key, value|
          if value.is_a? Array
            #result << "        \@\"#{key}\": \@\"#{value}\",\n"
            result << "        \@\"#{key}\": \@[\n"
            value.each {|sub_hash|
              result << "            @{\n"
              sub_hash.each {|key, value|
                result << "               \@\"#{key}\": \@\"#{value}\",\n"
              }
              result << "            },\n"
            }
            result << "        ],\n"
          else
            value.gsub!(/\"/, '\"')
            result << "        \@\"#{key}\": \@\"#{value}\",\n"
          end

        }
        result << "\n    };"
        result
      end

      def param_generate(class_name, parameters, category, operation, config)
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
