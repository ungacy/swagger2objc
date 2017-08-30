require 'swagger2objc/struct/parameter'

module Swagger2objc
  module Struct
    class Operation < Base
      attr_reader :consumes
      attr_reader :deprecated
      attr_reader :format
      attr_reader :method
      attr_reader :nickname
      attr_reader :notes
      attr_reader :parameters
      attr_reader :produces
      attr_reader :responseMessages
      attr_reader :responses
      attr_reader :operationId
      attr_reader :summary
      attr_reader :type
      attr_reader :response_class
      attr_accessor :path

      def initialize(hash = {}, method = nil)
        hash.each do |k, v|
          instance_variable_set("@#{k}", v)
          self.class.send(:define_method, k, proc { instance_variable_get("@#{k}") })
          self.class.send(:define_method, "#{k}=", proc { |v| instance_variable_set("@#{k}", v) })
        end
        @method = method if method

        setup
      end

      def setup
        @notes = summary if @notes.nil?
        parameters.map! { |item| Parameter.new(item) }
        if responseMessages
          responseMessages.select! { |item| item['code'] == '200' }
        elsif responses
          # responses.select! { |item| item['code'] == '200' }
          if responses['200'].nil?
            # puts path
            # puts responses
          else
            type = responses['200']['schema']['type']
            if type.nil?
              type = responses['200']['schema']['$ref'].sub('#/definitions/', '')
            end
          end

        end

        @response_class = type
        @response_class = format if @response_class == 'integer'
        if @response_class == 'Null'
          @response_class = 'string'
          @type = 'string'
        end
        @response_class = 'object' if @response_class.nil?
        return 'No response model' if @response_class.nil?
        oc_type = Swagger2objc::Generator::Type::OC_MAP[@response_class]
        if oc_type.nil?
          @response_class = Swagger2objc::Utils.class_name_formatter(@response_class)
        else
          @response_class = oc_type
        end
      end

      def result
        parameter_result = []
        parameters.each { |item| parameter_result << item.result }
        hash = {
          method: method,
          notes: notes.tr('<', '[').tr('>', ']').gsub('&', '&amp;'),
          summary: summary,
          type: type,
          param: parameter_result
        }
        class_prefix = Swagger2objc::Configure.config[Swagger2objc::Config::CLASS_PREFIX][Swagger2objc::Config::MODEL]
        if @response_class.start_with?(class_prefix)
          hash[:response] = @response_class
        end
        hash
      end

      def output
        info = "\n/**\n"
        info << " path       : #{path}\n"
        info << " method     : #{method}\n"
        info << " notes      : #{notes}\n"
        info << " summary    : #{summary}\n"
        info << " type       : #{type}\n"
        info << " format     : #{format}\n" if format
        info << " response   : #{@response_class}\n"
        info << '*/'
      end
    end
  end
end
