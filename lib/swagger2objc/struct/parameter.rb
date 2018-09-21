require 'swagger2objc/utils'

module Swagger2objc
  module Struct
    class Parameter < Base
      attr_reader :description
      attr_reader :format
      attr_reader :in
      attr_reader :name
      attr_reader :required
      attr_reader :type
      attr_reader :schema
      attr_reader :items
      attr_reader :rename
      attr_accessor :service
      attr_reader :all_ref

      def setup
        @all_ref = []
        if schema
          if schema['$ref']
            @type = schema['$ref'].sub('#/definitions/', '')
            @all_ref << @type
          else
            @type = schema['type']
            @items = schema['items']
          end
        else
          @type = @format if @type == 'integer' || @type == 'number'
        end
        if @in == 'formData'
          @type = 'File'
          @in = 'form'
        end

        format_name = name.clone
        format_name = description.clone if @in.nil?
        avoid = Swagger2objc::Configure.config[Swagger2objc::Config::AVOID]
        if avoid[format_name] && !avoid[format_name].empty?
          format_name = avoid[format_name]
          @rename = format_name.dup
        end
      end

      def output(import, avoid_map)

        if @in == 'query' && 'array' == type
          @type = 'string'
        end

        info = "\n/**\n"
        info << " paramType  : #{@in}\n"
        info << " key        : #{name}\n"
        info << " type       : #{type}\n"
        info << " required   : #{required}\n"
        info << " notes      : #{description}\n"
        if type.nil?
          puts "type : #{description}"
          raise "type : #{description}"
        end
        format_name = name.clone
        format_name = description.clone if @in.nil?

        avoid = Swagger2objc::Configure.config[Swagger2objc::Config::AVOID]
        if avoid[format_name] && !avoid[format_name].empty?
          format_name = avoid[format_name]
          avoid_map[format_name] = description
          @rename = format_name.dup
          # puts @rename
          info << " rename     : #{format_name}\n"
        end
        info << "*/\n"

        oc_type = Swagger2objc::Generator::Type::OC_MAP[type]
        raise "unkown format : #{name}" if oc_type.nil? && format == 'object'

        if oc_type == 'NSString'
          info << "@property (nonatomic, copy, nullable) #{oc_type} *#{format_name};\n"
        elsif oc_type == 'UIImage'
          info << "@property (nonatomic, strong, nullable) #{oc_type} *#{format_name};\n"
        elsif oc_type == 'id'
          info << "@property (nonatomic, strong, nullable) id #{format_name};\n"
        elsif oc_type.nil? # Custom Model Type
          if type.start_with?('HashMap')
            info << "@property (nonatomic, strong, nullable) NSDictionary *#{format_name};\n"
          else
            class_name = Swagger2objc::Utils.class_name_formatter(type, service)
            import << "#import \"#{class_name}.h\"\n"
            info << "@property (nonatomic, strong, nullable) #{class_name} *#{format_name};\n"
          end
        elsif oc_type == 'NSArray'
          element_type = @items['format'] ? @items['format'] : items['type']
          oc_element_type = Swagger2objc::Generator::Type::OC_MAP[element_type]
          if oc_element_type.nil?
            info << "@property (nonatomic, strong, nullable) NSArray *#{format_name};\n"
          elsif !oc_element_type.start_with?('NS') && !oc_element_type.start_with?('UI')
            info << "@property (nonatomic, strong, nullable) NSArray<NSNumber /*#{oc_element_type}*/ *> *#{format_name};\n"
          else
            info << "@property (nonatomic, strong, nullable) NSArray<#{oc_element_type} *> *#{format_name};\n"
          end

        else
          info << "@property (nonatomic, strong, nullable) NSNumber /*#{oc_type}*/ *#{format_name};\n"
        end
        info
      end

      def result
        hash = {
          paramType: @in,
          key: name,
          type: type,
          required: required
        }

        if @rename
          # puts @rename
          hash[:rename] = @rename
        end
        hash
      end
    end
  end
end
