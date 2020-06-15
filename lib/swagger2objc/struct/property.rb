require 'swagger2objc/utils'
module Swagger2objc
  module Struct
    class Property < Base
      attr_reader :format
      attr_accessor :required
      attr_reader :type
      attr_reader :items
      attr_reader :description
      attr_reader :ref
      attr_reader :additionalProperties
      attr_accessor :name
      attr_accessor :service
      def setup
        # it's a hash
        if @additionalProperties
          # if @additionalProperties['items']
          #   some = @additionalProperties['items']['$ref']
          #   if some
          #     some = some.sub('#/definitions/', '')
          #     @all_ref << some
          #   end
          # end
          @type = 'HashMap'
          @format = @type
        end

        if @type == 'List' || @type == 'Array' || @type == 'array'
          @format = items['type']
          if items['format']
            @format = items['format'] if @format == 'integer' || @format == 'number'
          end
          @format = items['$ref'].sub('#/definitions/', '') if @format.nil? && items['$ref']
        elsif @type == 'integer'
          @format = 'int64' if @format.nil?
        elsif @type == 'number'
          if @format.nil?
            @type == 'string'
            @format = 'string'
          end

        else
          @format = @type
        end
        if @ref
          @format = @ref.sub('#/definitions/', '')
          if @format == 'Timestamp'
            @format = 'double'
            @type = 'number'
          end
          @type = @format.dup if @type.nil?
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
        imported_set = Set.new
        info = "\n/**\n"
        info << " format      : #{format}\n"
        info << " required    : #{required}\n" unless required.nil?
        info << " type        : {#{type}}\n"
        info << " name        : #{name}\n"
        if description && !description.delete(' ').empty?
          info << " notes       : #{description}\n"
        end
        info << "*/\n"

        avoid = Swagger2objc::Configure.config[Swagger2objc::Config::AVOID]
        circular_dependency = Swagger2objc::Configure.config['circular_dependency']

        at_class = circular_dependency[model.id]
        # puts 'model.id : ' + at_class.to_s if at_class

        if @format.nil? || format == ''
          puts "model : #{model.id}"
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
        oc_type = Swagger2objc::Generator::Type::OC_MAP[@format]
        raise "unkown format : #{name}" if oc_type.nil? && @format == 'object'

        if oc_type == 'NSString'
          if @type == 'List' || @type == 'Array' || @type == 'array'
            info << "@property (nonatomic, strong, nullable) NSArray<#{oc_type} *> *#{format_name};\n"
            info.sub!("{#{type}}", "[#{oc_type}]")
          else
            info << "@property (nonatomic, copy, nullable) #{oc_type} *#{format_name};\n"
            info.sub!("{#{type}}", oc_type)
          end
        elsif oc_type == 'id'
          info << "@property (nonatomic, strong, nullable) id #{format_name};\n"
          info.sub!("{#{type}}", 'id')
        elsif oc_type.nil? # Custom Model Type
          if type.start_with?('HashMap')
            info.sub!("{#{type}}", 'NSDictionary')
            info << "@property (nonatomic, strong, nullable) NSDictionary *#{format_name};\n"
          else
            class_name = Swagger2objc::Utils.class_name_formatter(@format, service)
            if !items.nil?
              if class_name.start_with?('SIEntry«')
                info << "@property (nonatomic, strong, nullable) NSDictionary *#{format_name};\n"
                info.sub!("{#{type}}", "[#{class_name}]")
              else
                new_import = "#import \"#{class_name}.h\"\n"
                if at_class && at_class.include?(@format)
                  new_import = "@class #{class_name};\n"
                end
                import << new_import if format != model.id && !import.include?(new_import)
                info << "@property (nonatomic, strong, nullable) NSArray<#{class_name} *> *#{format_name};\n"
                class_map[name] = class_name
                info.sub!("{#{type}}", "[#{class_name}]")
              end
            else
              new_import = "#import \"#{class_name}.h\"\n"
              if at_class && at_class.include?(@format)
                new_import = "@class #{class_name};\n"
              end
              import << new_import if format != model.id && !import.include?(new_import)
              info.sub!("{#{type}}", class_name)
              info << "@property (nonatomic, strong, nullable) #{class_name} *#{format_name};\n"
            end
          end

        else
          info.sub!("{#{type}}", oc_type)

          if @type == 'List' || @type == 'Array' || @type == 'array'
            if !oc_type.start_with?('NS') && !oc_type.start_with?('UI')
              info << "@property (nonatomic, strong, nullable) NSArray<NSNumber /*#{oc_type}*/ *> *#{format_name};\n"
            else
              info << "@property (nonatomic, strong, nullable) NSArray<#{oc_type} *> *#{format_name};\n"
            end

          else
            info << "@property (nonatomic, strong, nullable) NSNumber /*#{oc_type}*/ *#{format_name};\n"
          end
        end
        info
      end
    end
  end
end
