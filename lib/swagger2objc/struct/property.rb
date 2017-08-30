require 'swagger2objc/utils/utils'
module Swagger2objc
  module Struct
    class Property < Base
      attr_reader :format
      attr_reader :required
      attr_reader :type
      attr_reader :items
      attr_reader :description
      attr_reader :ref
      attr_accessor :name

      def setup
        if @type == 'List' || @type == 'Array' || @type == 'array'
          @format = items['type']
          @format = items['format'] if @format == 'integer'
          @format = items['$ref'].sub('#/definitions/', '') if @format.nil?
        elsif 'integer' == @type
          @format = 'int64' if @format.nil?
        elsif 'number' == @type
          @format = 'double' if @format.nil?
        else
          @format = @type
        end
        if @ref
          @format = @ref.sub('#/definitions/', '')
          @type = @format.dup
        end
      end

      def result
        {
          format: format,
          required: required,
          type: type,
          name: name
        }
      end

      def output(import, model, class_map, avoid_map, rename)
        puts model.id
        puts @type
        puts @format
        imported_set = Set.new
        info = "\n/**\n"
        info << " format      : #{format}\n"
        info << " required    : #{required}\n"
        info << " type        : {#{type}}\n"
        info << " name        : #{name}\n"
        if description && !description.delete(' ').empty?
          info << " description : #{description}\n"
        end
        info << "*/\n"

        avoid = Swagger2objc::Configure.config[Swagger2objc::Config::AVOID]

        if @format.nil?

          puts @ref
          puts "format : #{name}"
          raise "format : #{name}"
        end

        format_name = name.clone
        if avoid[format_name] && !avoid[format_name].empty?
          format_name = avoid[format_name]
          avoid_map[format_name] = name
        end
        format_name = rename[format_name] if rename && rename[format_name]
        oc_type = Swagger2objc::Generator::Type::OC_MAP[format]
        raise "unkown format : #{name}" if oc_type.nil? && format == 'object'

        if oc_type == 'NSString'
          if @type == 'List' || @type == 'Array'
            info << "@property (nonatomic, strong) NSArray<#{oc_type} *> *#{format_name};\n"
            info.sub!("{#{type}}", "[#{oc_type}]")
          else
            info << "@property (nonatomic, copy) #{oc_type} *#{format_name};\n"
            info.sub!("{#{type}}", oc_type)
          end
        elsif oc_type == 'id'
          info << "@property (nonatomic, strong) id #{format_name};\n"
          info.sub!("{#{type}}", 'id')
        elsif oc_type.nil? # Custom Model Type
          if type.start_with?('HashMap')
            info.sub!("{#{type}}", 'NSDictionary')
            info << "@property (nonatomic, strong) NSDictionary *#{format_name};\n"
          else
            class_name = Swagger2objc::Utils.class_name_formatter(format)
            if !items.nil?
              if class_name.start_with?('SIEntry«')
                info << "@property (nonatomic, strong) NSDictionary *#{format_name};\n"
                info.sub!("{#{type}}", "[#{class_name}]")
              else
                import << "#import \"#{class_name}.h\"\n" if format != model.id
                info << "@property (nonatomic, strong) NSArray<#{class_name} *> *#{format_name};\n"
                class_map[name] = class_name
                info.sub!("{#{type}}", "[#{class_name}]")
              end
            else
              import << "#import \"#{class_name}.h\"\n" if format != model.id
              info.sub!("{#{type}}", class_name)
              info << "@property (nonatomic, strong) #{class_name} *#{format_name};\n"
            end
          end

        else
          info.sub!("{#{type}}", oc_type)

          if @type == 'List' || @type == 'Array' || @type == 'array'
            info << "@property (nonatomic, strong) NSArray<NSNumber /*#{oc_type}*/ *> *#{format_name};\n"
          else
            info << "@property (nonatomic, strong) NSNumber /*#{oc_type}*/ *#{format_name};\n"
          end
        end
        info
      end
    end
  end
end
