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
      attr_reader :summary
      attr_reader :type
      attr_reader :response_class
      attr_accessor :path

      def setup
        parameters.map! { |item| Parameter.new(item) }
        responseMessages.select! { |item| item['code'] == '200' }
        # NO responseMessages
        if responseMessages.count == 0
          @response_class = type
        else
          @response_class = responseMessages.first[responseModel]
        end
        if @response_class == 'integer'
          @response_class = format
        end
        raise 'No response model' if @response_class.nil?
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
          notes: notes.sub('<', '[').sub('>', ']'),
          summary: summary,
          type: type,
          param: parameter_result,
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
        if format
          info << " format     : #{format}\n"
        end
        info << " response   : #{@response_class}\n"
        info << "*/"
      end

    end
  end
end
