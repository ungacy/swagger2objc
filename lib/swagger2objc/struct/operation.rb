require 'swagger2objc/struct/parameter'

module Swagger2objc
  module Struct
    class Operation < Base
      attr_reader :consumes
      attr_reader :operationId
      attr_reader :parameters
      attr_reader :produces
      attr_reader :responses
      attr_reader :summary
      attr_reader :response_class

      attr_reader :type
      attr_reader :format

      attr_reader :ref

      attr_accessor :path
      attr_accessor :method
      attr_accessor :add_subfix
      attr_accessor :service
      attr_reader :all_ref

      def setup
        @all_ref = []
        if @parameters
          @parameters.map! do |item|
            parameter = Parameter.new(item)
            parameter.service = service
            @all_ref += parameter.all_ref
            parameter
          end
        else
          @parameters = []
        end
        type = 'object'
        if responses
          if @responses['200'] && responses['200']['schema']
            type = responses['200']['schema']['type']
            type = responses['200']['schema']['format'] if type == 'integer'
            if type == 'array'
              ref = responses['200']['schema']['items']['$ref']
              type = ref.sub('#/definitions/', '') if ref
            end
            if type.nil?
              @ref = responses['200']['schema']['$ref'].sub('#/definitions/', '')
              type = @ref.dup
            end
          end
        end

        @response_class = type
        if @response_class == 'Null'
          @response_class = 'string'
          @type = 'string'
        end
        @response_class = 'object' if @response_class.nil?
        @response_class = 'string' if @response_class == 'SimpleResponse'
        oc_type = Swagger2objc::Generator::Type::OC_MAP[@response_class]
        if oc_type.nil?
          all_ref << type
          @response_class = Swagger2objc::Utils.class_name_formatter(@response_class, service)
        else
          @response_class = oc_type
        end
        @type = type
        @summary = '' if @summary.nil?
      end

      def result
        parameter_result = []
        parameters.each { |item| parameter_result << item.result }
        hash = {
          method: method,
          summary: summary.tr('<', '[').tr('>', ']').gsub('&', '&amp;'),
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
        info << " summary    : #{summary}\n"
        info << " type       : #{type}\n"
        info << " format     : #{format}\n" if format
        info << " response   : #{@response_class}\n"
        info << '*/'
      end
    end
  end
end
