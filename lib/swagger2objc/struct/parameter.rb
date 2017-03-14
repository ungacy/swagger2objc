require 'swagger2objc/utils/utils'

module Swagger2objc
  module Struct
    class Parameter < Base
      attr_reader :allowMultiple
      attr_reader :defaultValue
      attr_reader :description
      attr_reader :format
      attr_reader :name
      attr_reader :paramType
      attr_reader :required
      attr_reader :type

      def setup
        @type = @format if 'integer' == @type || 'number' == @type
      end

      def output(import, _class_map, avoid_map)
        info = "\n/**\n"
        info << " paramType  : #{paramType}\n"
        info << " key        : #{description}\n"
        info << " type       : #{type}\n"
        info << " required   : #{required}\n"
        info << "*/\n"

        raise "type : #{description}" if type.nil?
        format_name = description.clone
        avoid = Swagger2objc::Configure.config[Swagger2objc::Config::AVOID]
        if avoid[format_name] && !avoid[format_name].empty?
          format_name = avoid[format_name]
          avoid_map[format_name] = description
        end
        oc_type = Swagger2objc::Generator::Type::OC_MAP[type]
        raise "unkown format : #{name}" if oc_type.nil? && format == 'object'

        if oc_type == 'NSString'
          info << "@property (nonatomic, copy) #{oc_type} *#{format_name};\n"
        elsif oc_type == 'UIImage'
          info << "@property (nonatomic, strong) #{oc_type} *#{format_name};\n"
        elsif oc_type == 'id'
          info << "@property (nonatomic, strong) id #{format_name};\n"
        elsif oc_type.nil? # Custom Model Type
          class_name = Swagger2objc::Utils.class_name_formatter(type)
          import << "#import \"#{class_name}.h\"\n"
          info << "@property (nonatomic, strong) #{class_name} *#{format_name};\n"
        else
          info << "@property (nonatomic, assign) #{oc_type} #{format_name};\n"
        end
        info
      end

      def result
        {
          paramType: paramType,
          key: description,
          type: type,
          required: required,
          defaultValue: defaultValue ? defaultValue : ' ',
          format: format ? format : ''
        }
      end
    end
  end
end
