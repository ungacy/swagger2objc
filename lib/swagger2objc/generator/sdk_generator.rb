require 'swagger2objc/generator/abstract_generator'
require 'nokogiri-plist'

module Swagger2objc
  module Generator
    class SDKGenerator < AbstractGenerator

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
        model.each do |controller|
          controller.apis.each do |request|
            class_name = Swagger2objc::Utils.sdk_name_formatter(request.path.sub(controller.resourcePath, ''), controller.category, Swagger2objc::Config::SDK)
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



        sim.each do |class_name, config|
          category = config[:category]
          operation = config[:operation]
          # puts "---------#{class_name}--------------"
          param_generate(class_name, config[:parameters], category, operation)
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

      def param_generate(class_name, parameters, category, operation)
        comment = operation.output
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
          response_class_body: response_class_body
        }
        TemplateReplacer.replace(replacement, Swagger2objc::Config::SDK)
      end
    end
  end
end
